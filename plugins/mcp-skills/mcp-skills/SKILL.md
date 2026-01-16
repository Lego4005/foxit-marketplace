---
description: Turn MCP servers into documented, searchable skills - import, discover, organize
triggers: [mcp-skills, mcps, mcp-manager]
---

# MCP Skills Manager

Transform your MCP servers into well-documented, searchable skills. Import from global settings, auto-discover tools, and keep everything organized.

## Why This Exists

MCP servers are powerful but:
- Hard to remember what tools are available
- No central documentation
- Easy to forget which MCPs you have
- Tool arguments aren't obvious

**MCP Skills** fixes this by creating a searchable skill file for each MCP with:
- Tool documentation with examples
- Common issues and fixes
- Copy-paste ready commands

## Quick Start

```bash
# 1. Initialize skills directory
./scripts/init-skills.sh

# 2. Import from your global Claude settings
./scripts/import-mcps.sh

# 3. Sync the index
./scripts/sync-index.sh
```

## Commands

| Command | What It Does |
|---------|-------------|
| `/mcp-skills` | Browse and search your MCP skills |
| `/mcp-skills --import` | Import MCPs from global settings |
| `/mcp-skills --sync` | Rebuild the INDEX.md |
| `/mcp-skills --discover <name>` | Auto-discover tools for an MCP |

## What Gets Created

```
mcp-skills/
├── INDEX.md           # Searchable directory of all skills
├── _template.md       # Template for new skills
├── github.md          # Auto-imported skill
├── memory.md          # Auto-imported skill
├── filesystem.md      # Auto-imported skill
└── ...
```

## Skill File Format

Each skill has:

```markdown
---
skill_id: github
mcp_server: github
category: development
tags: [git, repos, issues]
---

# GitHub MCP Skill

## Purpose
Interact with GitHub repos, issues, PRs...

## Tools Available

### search_repositories
Search for repos by query.

**Arguments:**
{
  "query": "string - search query",
  "per_page": "number - results per page (default 30)"
}

**Example:**
Use MCP tool github:search_repositories with {"query": "claude code"}
```

## Import Options

```bash
# See what would be imported (no changes)
./scripts/import-mcps.sh --dry-run

# Import with backup of global settings
./scripts/import-mcps.sh --backup

# Standard import
./scripts/import-mcps.sh
```

## Adding Skills Manually

1. Copy the template:
   ```bash
   cp mcp-skills/_template.md mcp-skills/my-mcp.md
   ```

2. Fill in:
   - `skill_id` - unique identifier
   - `mcp_server` - matches your MCP config
   - `category` - for organization
   - Tools with arguments and examples

3. Sync the index:
   ```bash
   ./scripts/sync-index.sh
   ```

## Categories

Organize skills by type:

| Category | For |
|----------|-----|
| `development` | GitHub, GitLab, CI/CD |
| `data` | Databases, APIs |
| `communication` | Slack, Discord, email |
| `infrastructure` | AWS, Docker, K8s |
| `imported` | Auto-imported (update these!) |
| `custom` | Project-specific |

## Discovering MCP Tools

Don't know what tools an MCP has? Ask Claude:

```
What tools are available in the github MCP server?
List all tools with their arguments.
```

Then document them in the skill file!

## Best Practices

1. **Update imported skills** - Auto-import creates stubs, fill in real docs
2. **Add examples** - Copy-paste ready commands save time
3. **Document errors** - Common issues section prevents repeated debugging
4. **Keep index synced** - Run sync-index.sh after changes
5. **Use categories** - Makes browsing easier

## Troubleshooting

### "No MCP servers found"
Your `~/.claude/settings.json` has no `mcpServers` configured.

### "jq not found"
Install jq: `brew install jq` (macOS) or `apt install jq` (Linux)

### Skills not showing in index
Run `./scripts/sync-index.sh` to rebuild.

## Integration

Works great with:
- **hook-architect** - Create hooks that use MCP tools
- **statusline-pro** - Show active MCP count in statusline

## Requirements

- Claude Code 2.1.x+
- Bash 4.0+
- jq (for JSON parsing)
