#!/bin/bash
# install-starter-mcps.sh - Install recommended MCPs for new Claude Code users
# Usage: ./install-starter-mcps.sh [--dry-run]

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[36m'
NC='\033[0m'

GLOBAL_SETTINGS="$HOME/.claude/settings.json"
DRY_RUN=false

[[ "$1" == "--dry-run" ]] && DRY_RUN=true

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    MCP Starter Pack - Essential MCPs   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check for jq
if ! command -v jq &> /dev/null; then
  echo -e "${YELLOW}!${NC} jq required. Install with: brew install jq"
  exit 1
fi

# Recommended MCPs with their configs
# Format: name|command|args|description
STARTER_MCPS=(
  "context7|npx|-y @anthropic-ai/context7-mcp@latest|Fetch up-to-date library docs - avoids hallucinated APIs"
  "sequential-thinking|npx|-y @anthropic-ai/mcp-sequentialthinking|Step-by-step reasoning with revision and branching"
  "memory|npx|-y @modelcontextprotocol/server-memory|Persistent memory across sessions using knowledge graph"
  "fetch|npx|-y @anthropic-ai/mcp-fetch|Fetch web content and convert to markdown"
)

echo -e "${CYAN}Recommended MCPs:${NC}"
echo ""
for mcp in "${STARTER_MCPS[@]}"; do
  IFS='|' read -r name cmd args desc <<< "$mcp"
  echo -e "  ${GREEN}◆${NC} ${name}"
  echo -e "    ${desc}"
  echo ""
done

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "${YELLOW}[DRY RUN]${NC} Would add these to $GLOBAL_SETTINGS"
  exit 0
fi

# Backup settings
BACKUP_FILE="$GLOBAL_SETTINGS.backup.$(date +%Y%m%d_%H%M%S)"
if [[ -f "$GLOBAL_SETTINGS" ]]; then
  cp "$GLOBAL_SETTINGS" "$BACKUP_FILE"
  echo -e "${GREEN}✓${NC} Backed up settings to: $BACKUP_FILE"
else
  # Create initial settings file
  mkdir -p "$(dirname "$GLOBAL_SETTINGS")"
  echo '{}' > "$GLOBAL_SETTINGS"
  echo -e "${GREEN}✓${NC} Created: $GLOBAL_SETTINGS"
fi

# Read current settings
CURRENT=$(cat "$GLOBAL_SETTINGS")

# Ensure mcpServers exists
if ! echo "$CURRENT" | jq -e '.mcpServers' > /dev/null 2>&1; then
  CURRENT=$(echo "$CURRENT" | jq '. + {mcpServers: {}}')
fi

# Add each MCP if not already present
ADDED=0
for mcp in "${STARTER_MCPS[@]}"; do
  IFS='|' read -r name cmd args desc <<< "$mcp"

  # Check if already exists
  if echo "$CURRENT" | jq -e ".mcpServers.\"$name\"" > /dev/null 2>&1; then
    echo -e "${YELLOW}!${NC} Skipping (already exists): $name"
    continue
  fi

  # Build args array
  ARGS_JSON=$(echo "$args" | tr ' ' '\n' | jq -R . | jq -s .)

  # Add MCP config
  CURRENT=$(echo "$CURRENT" | jq --arg name "$name" --arg cmd "$cmd" --argjson args "$ARGS_JSON" '
    .mcpServers[$name] = {
      command: $cmd,
      args: $args
    }
  ')

  echo -e "${GREEN}✓${NC} Added: $name"
  ((ADDED++))
done

# Write updated settings
echo "$CURRENT" | jq '.' > "$GLOBAL_SETTINGS"

echo ""
if [[ $ADDED -gt 0 ]]; then
  echo -e "${GREEN}✅ Added $ADDED MCP(s) to global settings!${NC}"
  echo ""
  echo -e "${YELLOW}⚠️  Restart Claude Code to activate new MCPs${NC}"
else
  echo -e "${YELLOW}All starter MCPs already installed.${NC}"
fi

echo ""
echo "Next steps:"
echo "  1. Restart Claude Code"
echo "  2. Run: ./scripts/import-mcps.sh  (to create skill docs)"
echo "  3. Run: ./scripts/sync-index.sh"
echo ""
echo "Test with:"
echo "  'Use context7 to look up React useState documentation'"
echo "  'Use sequential-thinking to plan this feature'"
echo ""
