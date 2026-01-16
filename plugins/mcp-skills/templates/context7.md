---
skill_id: context7
mcp_server: context7
category: development
tags: [documentation, libraries, api-reference]
last_updated: 2026-01-16
---

# Context7 MCP Skill

## Purpose

Fetch **up-to-date library documentation** directly from official sources. Prevents Claude from hallucinating outdated or incorrect APIs.

**Use when:**
- Working with any library/framework
- Need accurate, current API docs
- Want to avoid outdated information

## MCP Server Configuration

**Command:** `npx -y @anthropic-ai/context7-mcp@latest`

**Environment Variables:** None required

## Tools Available

### get_library_docs

Fetch documentation for a specific library.

**Arguments:**
```json
{
  "library": "string - Library name (e.g., 'react', 'express', 'prisma')",
  "topic": "string - Optional specific topic (e.g., 'hooks', 'middleware')"
}
```

**Example:**
```
Use context7 to look up React useState hooks documentation
```

```
Use context7 to get the latest Next.js App Router docs
```

```
Use context7 to find Prisma schema syntax for relations
```

### search_docs

Search across documentation for a specific term.

**Arguments:**
```json
{
  "query": "string - Search query",
  "library": "string - Optional, limit to specific library"
}
```

**Example:**
```
Use context7 to search for "server components" in React docs
```

## Complete Examples

### Example 1: Get Framework Docs
```
I'm building a Next.js app. Use context7 to get the current
documentation for the App Router file conventions.
```

### Example 2: API Reference
```
Use context7 to look up the Stripe API for creating subscriptions,
then show me the required parameters.
```

### Example 3: Compare Versions
```
Use context7 to get React 18 useTransition docs - I want to
understand the new concurrent features.
```

## Supported Libraries

Context7 supports 1000+ libraries including:

| Category | Examples |
|----------|----------|
| **Frontend** | React, Vue, Svelte, Angular, Solid |
| **Backend** | Express, Fastify, Hono, NestJS |
| **Database** | Prisma, Drizzle, TypeORM, Mongoose |
| **Auth** | NextAuth, Clerk, Auth0, Supabase Auth |
| **Testing** | Jest, Vitest, Playwright, Cypress |
| **AI/ML** | LangChain, OpenAI SDK, Anthropic SDK |

## Common Issues

### "Library not found"
**Cause:** Library name doesn't match context7's index
**Fix:** Try the npm package name (e.g., `@tanstack/react-query` not just `react-query`)

### Outdated docs returned
**Cause:** Context7 cache
**Fix:** Specify version: "React 18 docs" or "Next.js 14 App Router"

## Why Use This?

| Without Context7 | With Context7 |
|------------------|---------------|
| Claude guesses APIs from training | Gets actual current docs |
| May suggest deprecated methods | Always up-to-date |
| Version confusion | Can target specific versions |

## References

- [Context7 on npm](https://www.npmjs.com/package/@anthropic-ai/context7-mcp)
- [MCP Protocol](https://modelcontextprotocol.io)
