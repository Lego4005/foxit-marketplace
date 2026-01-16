#!/bin/bash
# install-statusline.sh - Install Statusline Pro to your project
# Usage: ./install-statusline.sh [--minimal | --full]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"
TARGET_DIR=".claude/hooks"
SETTINGS_FILE=".claude/settings.json"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Statusline Pro - Installation      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Create hooks directory
mkdir -p "$TARGET_DIR"

# Copy statusline hook
cp "$TEMPLATE_DIR/statusline.sh" "$TARGET_DIR/statusline.sh"
chmod +x "$TARGET_DIR/statusline.sh"
echo -e "${GREEN}✓${NC} Installed statusline.sh"

# Create session start hook to track session time
cat > "$TARGET_DIR/session-start.sh" << 'SESSIONHOOK'
#!/bin/bash
# Track session start time for statusline
set -e
echo "$(date +%s)" > "${HOME}/.claude-session-start"
echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "Session timer started"}}'
SESSIONHOOK
chmod +x "$TARGET_DIR/session-start.sh"
echo -e "${GREEN}✓${NC} Installed session-start.sh"

# Show settings instructions
echo ""
echo -e "${YELLOW}📝 Add to your .claude/settings.json:${NC}"
echo ""
cat << 'SETTINGS'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/statusline.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Your statusline will show:"
echo "   branch ● ▸ ~/project │ ◷ 14:30 │ ⏱ 23m"
echo ""
echo "Customize by editing: $TARGET_DIR/statusline.sh"
echo ""
