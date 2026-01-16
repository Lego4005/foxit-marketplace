---
skill_id: memory
mcp_server: memory
category: productivity
tags: [memory, persistence, knowledge-graph]
last_updated: 2026-01-16
---

# Memory MCP Skill

## Purpose

**Persistent memory** across Claude Code sessions using a local knowledge graph. Remember context, decisions, and learned patterns.

**Use when:**
- Want to remember project context across sessions
- Building up knowledge about a codebase
- Tracking decisions and their reasoning
- Creating persistent notes

## MCP Server Configuration

**Command:** `npx -y @modelcontextprotocol/server-memory`

**Environment Variables:** None required

**Data Location:** `~/.claude/memory/` (local, private)

## Tools Available

### create_entities

Store new knowledge as entities.

**Arguments:**
```json
{
  "entities": [
    {
      "name": "string - Entity name",
      "entityType": "string - Type (person, project, concept, decision)",
      "observations": ["string - Facts about this entity"]
    }
  ]
}
```

**Example:**
```
Use memory to remember:
Entity: "auth-system"
Type: "decision"
Observations:
- "Using JWT with httpOnly cookies"
- "Refresh tokens stored in Redis"
- "Decided on 2026-01-15"
```

### create_relations

Link entities together.

**Arguments:**
```json
{
  "relations": [
    {
      "from": "string - Source entity",
      "to": "string - Target entity",
      "relationType": "string - How they relate"
    }
  ]
}
```

**Example:**
```
Use memory to link:
"auth-system" --uses--> "Redis"
"auth-system" --decided-by--> "team-meeting-jan15"
```

### search_nodes

Find relevant memories.

**Arguments:**
```json
{
  "query": "string - Search query"
}
```

**Example:**
```
Use memory to recall what we decided about authentication
```

### open_nodes

Get all information about specific entities.

**Arguments:**
```json
{
  "names": ["string - Entity names to retrieve"]
}
```

**Example:**
```
Use memory to open the "auth-system" and "api-design" entities
```

## Complete Examples

### Example 1: Remember a Decision

```
Use memory to store this decision:

Entity: "database-choice"
Type: "decision"
Observations:
- "Chose PostgreSQL over MongoDB"
- "Reasons: ACID compliance, complex queries needed"
- "Team familiar with SQL"
- "Date: 2026-01-16"
```

### Example 2: Track Project Context

```
Use memory to remember:

Entity: "acme-project"
Type: "project"
Observations:
- "E-commerce platform"
- "Stack: Next.js, Prisma, PostgreSQL"
- "Team: 3 developers"
- "Launch target: Q2 2026"

Then link it:
"acme-project" --uses--> "PostgreSQL"
"acme-project" --built-with--> "Next.js"
```

### Example 3: Recall Past Work

```
Use memory to search for everything related to "authentication"
```

## Memory Types

| Type | Use For | Example |
|------|---------|---------|
| `project` | Project metadata | Stack, team, timeline |
| `decision` | Architectural choices | Why we chose X over Y |
| `person` | Team members | Roles, expertise |
| `concept` | Domain knowledge | Business rules |
| `issue` | Problems & solutions | Bug fixes, workarounds |
| `pattern` | Recurring approaches | "Always use X for Y" |

## Building a Knowledge Base

Start each project by storing:

```
1. Project overview (name, stack, goals)
2. Key decisions made (with reasoning)
3. Team structure
4. Important patterns/conventions
5. Known issues and workarounds
```

## Common Issues

### Memory not persisting
**Cause:** Server not configured correctly
**Fix:** Ensure `~/.claude/memory/` exists and is writable

### Can't find stored memory
**Cause:** Search query too specific
**Fix:** Use broader terms, or use `open_nodes` with exact name

### Too much irrelevant memory
**Fix:** Use more specific entity types and relations

## Privacy Note

All memory is stored **locally** in `~/.claude/memory/`. Nothing is sent to external servers. You can delete the folder to clear all memory.

## Pro Tips

1. **Be consistent with naming** - Use same entity names across sessions
2. **Add context to decisions** - Include WHY, not just WHAT
3. **Link everything** - Relations make memories more findable
4. **Review periodically** - Search for old entities, update if stale

## References

- [MCP Memory Server](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)
- [Knowledge Graph Concepts](https://en.wikipedia.org/wiki/Knowledge_graph)
