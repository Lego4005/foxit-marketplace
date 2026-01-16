---
skill_id: fetch
mcp_server: fetch
category: data
tags: [web, http, markdown]
last_updated: 2026-01-16
---

# Fetch MCP Skill

## Purpose

**Fetch web content** and convert HTML to clean markdown. Read documentation, articles, API responses without leaving Claude Code.

**Use when:**
- Need to read a webpage
- Fetching API documentation
- Getting content from URLs user provides
- Converting HTML to readable markdown

## MCP Server Configuration

**Command:** `npx -y @anthropic-ai/mcp-fetch`

**Environment Variables:** None required

## Tools Available

### fetch

Fetch a URL and return content as markdown.

**Arguments:**
```json
{
  "url": "string - URL to fetch",
  "max_length": "number - Optional, max characters to return",
  "start_index": "number - Optional, start from this character",
  "raw": "boolean - Optional, return raw HTML instead of markdown"
}
```

**Example:**
```
Use fetch to get the content from https://docs.anthropic.com/en/docs/claude-code
```

```
Use fetch to read https://github.com/anthropics/claude-code/blob/main/README.md
```

## Complete Examples

### Example 1: Read Documentation

```
Use fetch to get the Prisma getting started guide from
https://www.prisma.io/docs/getting-started
```

### Example 2: Check API Status

```
Use fetch to get https://status.anthropic.com and tell me
if there are any ongoing incidents
```

### Example 3: GitHub README

```
Use fetch to read the README from
https://github.com/modelcontextprotocol/servers
```

### Example 4: Limited Content

```
Use fetch to get the first 5000 characters from
https://example.com/long-article
with max_length: 5000
```

## Common Issues

### "URL not accessible"
**Cause:** Site blocks automated requests or requires auth
**Fix:** Some sites require authentication or block bots

### Content too long
**Fix:** Use `max_length` parameter to limit response

### Raw HTML needed
**Fix:** Set `raw: true` to get HTML instead of markdown

## What It's Good For

| Use Case | Example |
|----------|---------|
| Documentation | Read official docs |
| GitHub READMEs | Get project info |
| API references | Check endpoints |
| Articles | Read blog posts |
| Status pages | Check service health |

## What It Can't Do

- Fetch content requiring JavaScript rendering
- Access authenticated pages
- Submit forms
- Handle CAPTCHAs

## References

- [MCP Fetch Server](https://github.com/anthropics/mcp-servers/tree/main/src/fetch)
