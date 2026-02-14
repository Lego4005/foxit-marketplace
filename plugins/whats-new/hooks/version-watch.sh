#!/bin/bash
# Version Watch Hook - Detects Claude Code version changes
# Auto-triggers version impact analysis when updates are detected
# Hook: SessionStart

VERSION_FILE="$HOME/.claude/last-known-version"

# Detect version from WHAT'S ACTUALLY RUNNING, not what's installed
get_version() {
    local version=""

    # Step 1: Find the actual running Claude process and its binary path
    local running_binary=""

    # Check for running claude process (get the actual binary path)
    running_binary=$(ps -o comm= -p $PPID 2>/dev/null | head -1)
    if [[ -z "$running_binary" || "$running_binary" != *"claude"* ]]; then
        # Try to find any running claude process
        running_binary=$(pgrep -a claude 2>/dev/null | grep -v grep | head -1 | awk '{print $2}')
    fi

    # Step 2: If we found a running binary, check its version
    if [[ -n "$running_binary" && -x "$running_binary" ]]; then
        version=$("$running_binary" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        [[ -n "$version" ]] && echo "$version" && return
    fi

    # Step 3: Check common install locations in order of likelihood

    # Native binary (~/.local/bin/claude) - most common for CLI users
    if [[ -x "$HOME/.local/bin/claude" ]]; then
        version=$("$HOME/.local/bin/claude" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        [[ -n "$version" ]] && echo "$version" && return
    fi

    # VS Code extension binary (updates separately via marketplace)
    local vscode_ext=$(find "$HOME/.vscode/extensions" "$HOME/.antigravity/extensions" -name "claude" -type f -executable 2>/dev/null | head -1)
    if [[ -n "$vscode_ext" && -x "$vscode_ext" ]]; then
        version=$(echo "$vscode_ext" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        [[ -n "$version" ]] && echo "$version" && return
    fi

    # npm global install
    local npm_prefix=$(npm prefix -g 2>/dev/null)
    if [[ -n "$npm_prefix" && -f "$npm_prefix/lib/node_modules/@anthropic-ai/claude-code/package.json" ]]; then
        version=$(jq -r '.version' "$npm_prefix/lib/node_modules/@anthropic-ai/claude-code/package.json" 2>/dev/null)
        [[ -n "$version" && "$version" != "null" ]] && echo "$version" && return
    fi

    # Bun global install
    if [[ -f "$HOME/.bun/install/global/node_modules/@anthropic-ai/claude-code/package.json" ]]; then
        version=$(jq -r '.version' "$HOME/.bun/install/global/node_modules/@anthropic-ai/claude-code/package.json" 2>/dev/null)
        [[ -n "$version" && "$version" != "null" ]] && echo "$version" && return
    fi

    # macOS .app bundle
    if [[ -f "/Applications/Claude Code.app/Contents/Info.plist" ]]; then
        version=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "/Applications/Claude Code.app/Contents/Info.plist" 2>/dev/null)
        [[ -n "$version" ]] && echo "$version" && return
    fi

    # Windows installs
    if [[ -n "$LOCALAPPDATA" && -f "$LOCALAPPDATA/Programs/claude-code/package.json" ]]; then
        version=$(jq -r '.version' "$LOCALAPPDATA/Programs/claude-code/package.json" 2>/dev/null)
        [[ -n "$version" && "$version" != "null" ]] && echo "$version" && return
    fi

    # Last resort: which claude + --version
    local which_claude=$(which claude 2>/dev/null)
    if [[ -n "$which_claude" && -x "$which_claude" ]]; then
        version=$("$which_claude" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        [[ -n "$version" ]] && echo "$version" && return
    fi

    echo "unknown"
}

CURRENT_VERSION=$(get_version)

# Detect multiple installations and their versions
detect_multi_install() {
    local installs=()
    local versions=()

    # Native binary
    if [[ -x "$HOME/.local/bin/claude" ]]; then
        local v=$("$HOME/.local/bin/claude" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        [[ -n "$v" ]] && installs+=("native:$v")
    fi

    # VS Code extension
    local vscode_ext=$(find "$HOME/.vscode/extensions" "$HOME/.vscode-server/extensions" "$HOME/.antigravity/extensions" -path "*claude-code*" -name "claude" -type f 2>/dev/null | head -1)
    if [[ -n "$vscode_ext" ]]; then
        local v=$(echo "$vscode_ext" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        [[ -n "$v" ]] && installs+=("vscode-ext:$v")
    fi

    # npm
    local npm_prefix=$(npm prefix -g 2>/dev/null)
    if [[ -n "$npm_prefix" && -f "$npm_prefix/lib/node_modules/@anthropic-ai/claude-code/package.json" ]]; then
        local v=$(jq -r '.version' "$npm_prefix/lib/node_modules/@anthropic-ai/claude-code/package.json" 2>/dev/null)
        [[ -n "$v" && "$v" != "null" ]] && installs+=("npm:$v")
    fi

    # Bun
    if [[ -f "$HOME/.bun/install/global/node_modules/@anthropic-ai/claude-code/package.json" ]]; then
        local v=$(jq -r '.version' "$HOME/.bun/install/global/node_modules/@anthropic-ai/claude-code/package.json" 2>/dev/null)
        [[ -n "$v" && "$v" != "null" ]] && installs+=("bun:$v")
    fi

    # macOS .app
    if [[ -f "/Applications/Claude Code.app/Contents/Info.plist" ]]; then
        local v=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "/Applications/Claude Code.app/Contents/Info.plist" 2>/dev/null)
        [[ -n "$v" ]] && installs+=("macos-app:$v")
    fi

    # Return if multiple found
    if [[ ${#installs[@]} -gt 1 ]]; then
        echo "${installs[*]}"
    fi
}

MULTI_INSTALL=$(detect_multi_install)

# Create version file directory if needed
mkdir -p "$(dirname "$VERSION_FILE")"

# Read last known version
LAST_VERSION=""
if [[ -f "$VERSION_FILE" ]]; then
    LAST_VERSION=$(cat "$VERSION_FILE" 2>/dev/null)
fi

# Check for version change
if [[ "$CURRENT_VERSION" != "unknown" && "$LAST_VERSION" != "$CURRENT_VERSION" ]]; then
    # Store new version
    echo "$CURRENT_VERSION" > "$VERSION_FILE"

    # Build warning for multiple installs
    MULTI_WARN=""
    if [[ -n "$MULTI_INSTALL" ]]; then
        MULTI_WARN=" Warning: Multiple installs detected: $MULTI_INSTALL"
    fi

    if [[ -n "$LAST_VERSION" ]]; then
        # Version changed! Auto-trigger analysis
        cat << EOF
{
  "systemMessage": "Claude Code updated: $LAST_VERSION to $CURRENT_VERSION${MULTI_WARN}",
  "additionalContext": "AUTO_RUN_SKILL: Claude Code version changed from $LAST_VERSION to $CURRENT_VERSION. You MUST immediately invoke the Skill tool with skill='whats-new' to analyze the release notes and show the user what changed, how it impacts them, and what actions to take. Do this BEFORE responding to any user message.${MULTI_WARN:+ IMPORTANT: User has multiple Claude Code installations ($MULTI_INSTALL) which may have different versions - warn them about potential confusion.} Start by running: Skill(skill='whats-new', args='$LAST_VERSION to $CURRENT_VERSION')"
}
EOF
    else
        # First time tracking
        cat << EOF
{
  "systemMessage": "Tracking Claude Code v$CURRENT_VERSION${MULTI_WARN}"
}
EOF
    fi
else
    # No change - silent success
    echo '{"status": "ok"}'
fi
