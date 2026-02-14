#!/bin/bash
# Actions Tracker - Tracks what you've already done per version update
# Prevents showing the same recommendations repeatedly

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$PLUGIN_DIR/data"
ACTIONS_FILE="$DATA_DIR/actions-log.json"

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Initialize if doesn't exist
if [[ ! -f "$ACTIONS_FILE" ]]; then
    cat > "$ACTIONS_FILE" << 'EOF'
{
  "schema_version": 1,
  "versions": {}
}
EOF
fi

# Commands
case "${1:-status}" in
    status)
        # Show current status for a version
        VERSION="${2:-$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)}"
        echo "=== Actions Status for v$VERSION ==="
        jq -r --arg v "$VERSION" '
            .versions[$v] // {actions: [], verified_fixes: [], skipped: []} |
            "Analyzed: \(.analyzed_at // "never")\n" +
            "From version: \(.from_version // "unknown")\n" +
            "\nPending Actions:" +
            (.actions // [] | map(select(.status == "pending")) |
                if length == 0 then "\n  (none)"
                else map("\n  [\(.priority)] \(.description)") | add end) +
            "\n\nCompleted:" +
            (.actions // [] | map(select(.status == "completed")) |
                if length == 0 then "\n  (none)"
                else map("\n  Done: \(.description)") | add end) +
            "\n\nSkipped (not applicable):" +
            (.skipped // [] | if length == 0 then "\n  (none)" else map("\n  Skipped: \(.)") | add end)
        ' "$ACTIONS_FILE"
        ;;

    complete)
        # Mark an action as completed
        VERSION="${2:-}"
        ACTION_ID="${3:-}"
        if [[ -z "$VERSION" || -z "$ACTION_ID" ]]; then
            echo "Usage: $0 complete <version> <action_id>" >&2
            exit 1
        fi

        jq --arg v "$VERSION" --arg id "$ACTION_ID" '
            .versions[$v].actions |= map(
                if .id == $id then .status = "completed" | .completed_at = (now | todate) else . end
            )
        ' "$ACTIONS_FILE" > "$ACTIONS_FILE.tmp" && mv "$ACTIONS_FILE.tmp" "$ACTIONS_FILE"
        echo "Marked '$ACTION_ID' as completed for v$VERSION"
        ;;

    skip)
        # Mark an action as skipped/not applicable
        VERSION="${2:-}"
        ACTION_ID="${3:-}"
        if [[ -z "$VERSION" || -z "$ACTION_ID" ]]; then
            echo "Usage: $0 skip <version> <action_id>" >&2
            exit 1
        fi

        jq --arg v "$VERSION" --arg id "$ACTION_ID" '
            .versions[$v].actions |= map(
                if .id == $id then .status = "skipped" else . end
            )
        ' "$ACTIONS_FILE" > "$ACTIONS_FILE.tmp" && mv "$ACTIONS_FILE.tmp" "$ACTIONS_FILE"
        echo "Marked '$ACTION_ID' as skipped for v$VERSION"
        ;;

    add)
        # Add a new action for a version
        VERSION="${2:-}"
        ACTION_ID="${3:-}"
        DESCRIPTION="${4:-}"
        PRIORITY="${5:-optional}"

        if [[ -z "$VERSION" || -z "$ACTION_ID" || -z "$DESCRIPTION" ]]; then
            echo "Usage: $0 add <version> <action_id> <description> [priority]" >&2
            exit 1
        fi

        jq --arg v "$VERSION" --arg id "$ACTION_ID" --arg desc "$DESCRIPTION" --arg pri "$PRIORITY" '
            .versions[$v].actions += [{
                id: $id,
                description: $desc,
                status: "pending",
                priority: $pri,
                added_at: (now | todate)
            }]
        ' "$ACTIONS_FILE" > "$ACTIONS_FILE.tmp" && mv "$ACTIONS_FILE.tmp" "$ACTIONS_FILE"
        echo "Added action '$ACTION_ID' for v$VERSION"
        ;;

    init-version)
        # Initialize tracking for a new version
        VERSION="${2:-}"
        FROM_VERSION="${3:-unknown}"

        if [[ -z "$VERSION" ]]; then
            echo "Usage: $0 init-version <version> [from_version]" >&2
            exit 1
        fi

        jq --arg v "$VERSION" --arg from "$FROM_VERSION" '
            .versions[$v] = {
                analyzed_at: (now | todate),
                from_version: $from,
                actions: [],
                verified_fixes: [],
                skipped: [],
                notes: ""
            }
        ' "$ACTIONS_FILE" > "$ACTIONS_FILE.tmp" && mv "$ACTIONS_FILE.tmp" "$ACTIONS_FILE"
        echo "Initialized tracking for v$VERSION (from $FROM_VERSION)"
        ;;

    pending)
        # List only pending actions (for skill to check)
        VERSION="${2:-$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)}"
        jq -r --arg v "$VERSION" '
            .versions[$v].actions // [] |
            map(select(.status == "pending")) |
            if length == 0 then "none" else map(.id) | join(",") end
        ' "$ACTIONS_FILE"
        ;;

    json)
        # Output raw JSON for a version (for skill parsing)
        VERSION="${2:-$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)}"
        jq --arg v "$VERSION" '.versions[$v] // {}' "$ACTIONS_FILE"
        ;;

    *)
        echo "Actions Tracker - Track what you've done per version update"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  status [version]              Show action status for version"
        echo "  pending [version]             List pending action IDs"
        echo "  complete <version> <id>       Mark action as completed"
        echo "  skip <version> <id>           Mark action as skipped"
        echo "  add <ver> <id> <desc> [pri]   Add new action"
        echo "  init-version <ver> [from]     Initialize tracking for version"
        echo "  json [version]                Output raw JSON"
        exit 1
        ;;
esac
