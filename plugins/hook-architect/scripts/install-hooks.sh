#!/bin/bash
# install-hooks.sh - Install hook templates to current project
# Usage: ./install-hooks.sh [--all | --safety | --productivity | hook-name...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates/hooks"
TARGET_DIR=".claude/hooks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Available hooks
SAFETY_HOOKS=("file-guardian" "command-bouncer")
PRODUCTIVITY_HOOKS=("auto-formatter")
ALL_HOOKS=("${SAFETY_HOOKS[@]}" "${PRODUCTIVITY_HOOKS[@]}")

install_hook() {
  local hook_name=$1
  local source="$TEMPLATE_DIR/${hook_name}.sh"
  local target="$TARGET_DIR/${hook_name}.sh"

  if [[ ! -f "$source" ]]; then
    echo -e "${YELLOW}⚠️  Template not found: $hook_name${NC}"
    return 1
  fi

  cp "$source" "$target"
  chmod +x "$target"
  echo -e "${GREEN}✅ Installed: $hook_name${NC}"
}

update_settings() {
  local settings_file=".claude/settings.json"

  # Create settings if doesn't exist
  if [[ ! -f "$settings_file" ]]; then
    echo '{"hooks": {}}' > "$settings_file"
  fi

  # This is a simple approach - in production, use jq to merge properly
  echo -e "${YELLOW}📝 Remember to add hooks to $settings_file${NC}"
  echo ""
  echo "Example settings.json hooks section:"
  echo '{'
  echo '  "hooks": {'
  echo '    "PreToolUse": ['
  echo '      {"matcher": "Edit|Write", "command": [".claude/hooks/file-guardian.sh"]},'
  echo '      {"matcher": "Bash", "command": [".claude/hooks/command-bouncer.sh"]}'
  echo '    ],'
  echo '    "PostToolUse": ['
  echo '      {"matcher": "Edit|Write", "command": [".claude/hooks/auto-formatter.sh"]}'
  echo '    ]'
  echo '  }'
  echo '}'
}

# Parse arguments
HOOKS_TO_INSTALL=()

if [[ $# -eq 0 ]] || [[ "$1" == "--safety" ]]; then
  HOOKS_TO_INSTALL=("${SAFETY_HOOKS[@]}")
elif [[ "$1" == "--all" ]]; then
  HOOKS_TO_INSTALL=("${ALL_HOOKS[@]}")
elif [[ "$1" == "--productivity" ]]; then
  HOOKS_TO_INSTALL=("${PRODUCTIVITY_HOOKS[@]}")
else
  HOOKS_TO_INSTALL=("$@")
fi

# Create target directory
mkdir -p "$TARGET_DIR"

echo ""
echo "🪝 Hook Architect - Installing hooks..."
echo ""

# Install each hook
for hook in "${HOOKS_TO_INSTALL[@]}"; do
  install_hook "$hook"
done

echo ""
update_settings
echo ""
echo -e "${GREEN}Done! Run your hooks with Claude Code.${NC}"
