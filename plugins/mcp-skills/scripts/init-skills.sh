#!/bin/bash
# init-skills.sh - Initialize MCP skills directory in a project
# Usage: ./init-skills.sh [--force]

set -e

SKILLS_DIR="mcp-skills"
FORCE=false

[[ "$1" == "--force" ]] && FORCE=true

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      MCP Skills - Initialize           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if already initialized
if [[ -d "$SKILLS_DIR" && "$FORCE" == "false" ]]; then
  echo -e "${YELLOW}!${NC} Skills directory already exists: $SKILLS_DIR"
  echo "  Use --force to reinitialize"
  exit 0
fi

# Create directory
mkdir -p "$SKILLS_DIR"
echo -e "${GREEN}✓${NC} Created: $SKILLS_DIR/"

# Create template
cat > "$SKILLS_DIR/_template.md" << 'TEMPLATE'
---
skill_id: SKILL_ID_HERE
mcp_server: MCP_SERVER_NAME
category: CATEGORY_HERE
tags: [tag1, tag2]
last_updated: YYYY-MM-DD
---

# SKILL_NAME MCP Skill

## Purpose

Brief description of what this skill does and when to use it.

## MCP Server Configuration

**Command:** `npx -y <mcp-server-package>`

**Environment Variables:**
- `API_KEY`: Your API key for this service

## Tools Available

### tool_name

Description of what this tool does.

**Arguments:**
```json
{
  "arg1": "string - description",
  "arg2": "number - optional, default 10"
}
```

**Example:**
```
Use MCP tool skill_id:tool_name with {"arg1": "value"}
```

**Returns:**
```json
{
  "result": "description",
  "status": "success"
}
```

## Complete Examples

### Example: Common Use Case

```
Use MCP tool skill_id:tool_name with {"arg1": "example"}
```

## Common Issues

### Error: "Invalid API key"
**Cause:** Missing or incorrect API_KEY
**Fix:** Set API_KEY in your environment

### Error: "Rate limit exceeded"
**Cause:** Too many requests
**Fix:** Add delays between calls

## References

- [Official Docs](https://example.com)
- [MCP Server Repo](https://github.com/org/mcp)

---
*Template version 1.0*
TEMPLATE

echo -e "${GREEN}✓${NC} Created: $SKILLS_DIR/_template.md"

# Create initial INDEX
cat > "$SKILLS_DIR/INDEX.md" << 'INDEX'
# MCP Skills Directory

Your MCP servers documented as searchable skills.

## Quick Commands

| Command | What It Does |
|---------|-------------|
| `/mcp-skills` | Browse and search skills |
| `/mcp-skills --import` | Import from global Claude settings |
| `./scripts/sync-index.sh` | Rebuild this index |

## Skills

*No skills yet. Run `./scripts/import-mcps.sh` to import from global settings.*

## Adding New Skills

### From Global MCPs
```bash
./scripts/import-mcps.sh
```

### Manually
1. Copy `_template.md` to `<skill-name>.md`
2. Fill in skill details and tool documentation
3. Run `./scripts/sync-index.sh`

---
*Initialized: $(date '+%Y-%m-%d')*
INDEX

echo -e "${GREEN}✓${NC} Created: $SKILLS_DIR/INDEX.md"

echo ""
echo -e "${GREEN}✅ Initialization complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Import MCPs: ./scripts/import-mcps.sh"
echo "  2. Or create manually: cp $SKILLS_DIR/_template.md $SKILLS_DIR/my-skill.md"
echo "  3. Sync index: ./scripts/sync-index.sh"
echo ""
