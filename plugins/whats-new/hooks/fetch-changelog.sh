#!/bin/bash
# Fetch and cache Claude Code changelog from GitHub
# Returns path to cached changelog and extracts relevant version entries

set -euo pipefail

CHANGELOG_DIR="$HOME/.claude/changelogs"
CHANGELOG_URL="https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md"
CACHE_FILE="$CHANGELOG_DIR/CHANGELOG-latest.md"
VERSION_INDEX="$CHANGELOG_DIR/version-index.json"

# Ensure cache directory exists
mkdir -p "$CHANGELOG_DIR"

# Fetch fresh changelog (with cache headers for efficiency)
fetch_changelog() {
    local etag_file="$CHANGELOG_DIR/.etag"
    local etag=""

    if [[ -f "$etag_file" ]]; then
        etag=$(cat "$etag_file")
    fi

    # Fetch with conditional request
    local http_code
    http_code=$(curl -s -w "%{http_code}" \
        -H "If-None-Match: $etag" \
        -o "$CACHE_FILE.tmp" \
        -D "$CHANGELOG_DIR/.headers" \
        "$CHANGELOG_URL")

    if [[ "$http_code" == "200" ]]; then
        # New content - save it
        mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        # Extract and save ETag for future requests
        grep -i "^etag:" "$CHANGELOG_DIR/.headers" | cut -d' ' -f2 | tr -d '\r' > "$etag_file" 2>/dev/null || true
        echo "fresh"
    elif [[ "$http_code" == "304" ]]; then
        # Not modified - use cached
        rm -f "$CACHE_FILE.tmp"
        echo "cached"
    else
        # Error - try to use cached if available
        rm -f "$CACHE_FILE.tmp"
        if [[ -f "$CACHE_FILE" ]]; then
            echo "cached-fallback"
        else
            echo "error:$http_code"
            exit 1
        fi
    fi
}

# Extract version entries between two versions
extract_version_range() {
    local from_version="$1"
    local to_version="$2"
    local changelog_file="${3:-$CACHE_FILE}"

    if [[ ! -f "$changelog_file" ]]; then
        echo "Error: Changelog not found at $changelog_file" >&2
        return 1
    fi

    # Extract content between version headers
    # Handles formats like: ## [2.1.25] or ## 2.1.25 or ### Version 2.1.25
    awk -v from="$from_version" -v to="$to_version" '
        BEGIN { printing = 0; found_to = 0 }
        /^##+ .*[0-9]+\.[0-9]+\.[0-9]+/ {
            # Extract version number from header
            match($0, /[0-9]+\.[0-9]+\.[0-9]+/)
            ver = substr($0, RSTART, RLENGTH)

            # Compare versions (simple string compare works for semver)
            if (ver == to || (found_to == 0 && ver != "" && ver <= to && ver > from)) {
                printing = 1
                found_to = 1
            } else if (ver == from || ver < from) {
                printing = 0
            }
        }
        printing { print }
    ' "$changelog_file"
}

# Get list of all versions in changelog
list_versions() {
    local changelog_file="${1:-$CACHE_FILE}"

    grep -oE '##+ .*[0-9]+\.[0-9]+\.[0-9]+' "$changelog_file" | \
        grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | \
        sort -V -r | \
        uniq
}

# Build version index for quick lookups
build_index() {
    local changelog_file="${1:-$CACHE_FILE}"

    echo "{"
    echo '  "versions": ['
    list_versions "$changelog_file" | head -20 | while read -r ver; do
        echo "    \"$ver\","
    done | sed '$ s/,$//'
    echo "  ],"
    echo "  \"cached_at\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
    echo "  \"source\": \"$CHANGELOG_URL\""
    echo "}"
}

# Main command dispatch
case "${1:-fetch}" in
    fetch)
        fetch_changelog
        ;;
    extract)
        # extract <from_version> <to_version>
        extract_version_range "${2:-0.0.0}" "${3:-99.99.99}"
        ;;
    versions)
        list_versions
        ;;
    index)
        build_index > "$VERSION_INDEX"
        cat "$VERSION_INDEX"
        ;;
    path)
        echo "$CACHE_FILE"
        ;;
    diff)
        # diff <old_version> <new_version> - outputs just the new entries
        FROM="${2:-}"
        TO="${3:-}"
        if [[ -z "$FROM" || -z "$TO" ]]; then
            echo "Usage: $0 diff <old_version> <new_version>" >&2
            exit 1
        fi

        # Save version-specific cache
        VERSION_CACHE="$CHANGELOG_DIR/CHANGELOG-${FROM}-to-${TO}.md"
        extract_version_range "$FROM" "$TO" > "$VERSION_CACHE"

        echo "# Changelog: $FROM to $TO"
        echo "# Cached at: $(date)"
        echo "# Source: $CHANGELOG_URL"
        echo ""
        cat "$VERSION_CACHE"
        ;;
    *)
        echo "Usage: $0 {fetch|extract|versions|index|path|diff}" >&2
        echo "  fetch              - Download/update changelog from GitHub"
        echo "  extract <from> <to> - Extract entries between versions"
        echo "  versions           - List all versions in changelog"
        echo "  index              - Build version index JSON"
        echo "  path               - Print path to cached changelog"
        echo "  diff <old> <new>   - Extract and cache diff between versions"
        exit 1
        ;;
esac
