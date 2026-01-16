#!/bin/bash
# sync-index.sh - Synchronize mcp-skills/INDEX.md with skill files
# Usage: ./sync-index.sh

set -e

SKILLS_DIR="mcp-skills"
INDEX_FILE="$SKILLS_DIR/INDEX.md"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      MCP Skills - Sync Index           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check skills directory exists
if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Skills directory not found. Run init-skills.sh first."
  exit 1
fi

# Build skills list
SKILLS_LIST=""
SKILL_COUNT=0

for skill_file in "$SKILLS_DIR"/*.md; do
  [[ ! -f "$skill_file" ]] && continue

  filename=$(basename "$skill_file")

  # Skip INDEX and template
  [[ "$filename" == "INDEX.md" ]] && continue
  [[ "$filename" == "_template.md" ]] && continue

  # Extract frontmatter
  skill_id=$(grep -m1 "^skill_id:" "$skill_file" 2>/dev/null | sed 's/skill_id: *//' || echo "$filename")
  category=$(grep -m1 "^category:" "$skill_file" 2>/dev/null | sed 's/category: *//' || echo "uncategorized")

  # Get first line of Purpose section as description
  description=$(sed -n '/^## Purpose/,/^##/{/^## Purpose/d;/^##/d;p;}' "$skill_file" | head -1 | sed 's/^[[:space:]]*//')
  [[ -z "$description" ]] && description="*No description*"

  SKILLS_LIST+="| [$skill_id](./$filename) | $category | $description |\n"
  ((SKILL_COUNT++))
done

# Generate INDEX.md
cat > "$INDEX_FILE" << INDEX
# MCP Skills Directory

Your MCP servers documented as searchable skills.

## Quick Commands

| Command | What It Does |
|---------|-------------|
| \`/mcp-skills\` | Browse and search skills |
| \`/mcp-skills --import\` | Import from global Claude settings |
| \`/mcp-skills --discover <name>\` | Auto-discover tools for an MCP |
| \`./scripts/sync-index.sh\` | Rebuild this index |

## Skills ($SKILL_COUNT total)

| Skill | Category | Description |
|-------|----------|-------------|
$(echo -e "$SKILLS_LIST")

## Categories

Skills are organized by:

- **imported** - Auto-imported from global settings
- **development** - GitHub, GitLab, CI/CD tools
- **data** - Databases, APIs, data processing
- **communication** - Slack, Discord, email
- **infrastructure** - AWS, Docker, Kubernetes
- **custom** - Project-specific integrations

## Adding New Skills

### From Global MCPs
\`\`\`bash
./scripts/import-mcps.sh
\`\`\`

### Manually
1. Copy \`_template.md\` to \`<skill-name>.md\`
2. Fill in skill details and tool documentation
3. Run \`./scripts/sync-index.sh\`

## See Also

- [\`_template.md\`](./_template.md) - Template for new skills

---
*Last synced: $(date '+%Y-%m-%d %H:%M:%S')*
INDEX

echo -e "${GREEN}✓${NC} Updated: $INDEX_FILE"
echo -e "${GREEN}✓${NC} Found $SKILL_COUNT skill(s)"
echo ""
