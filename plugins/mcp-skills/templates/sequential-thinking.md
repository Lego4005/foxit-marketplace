---
skill_id: sequential-thinking
mcp_server: sequential-thinking
category: reasoning
tags: [thinking, planning, problem-solving]
last_updated: 2026-01-16
---

# Sequential Thinking MCP Skill

## Purpose

**Deep reasoning** with step-by-step thinking, revision, and branching. Perfect for complex problems where you need to think through multiple approaches.

**Use when:**
- Complex architectural decisions
- Debugging tricky issues
- Planning multi-step implementations
- Need to backtrack and try alternatives

## MCP Server Configuration

**Command:** `npx -y @anthropic-ai/mcp-sequentialthinking`

**Environment Variables:** None required

## Tools Available

### create_thought

Add a thought to the reasoning chain.

**Arguments:**
```json
{
  "thought": "string - The thought content",
  "thought_number": "number - Position in sequence",
  "total_thoughts": "number - Estimated total",
  "next_thought_needed": "boolean - More thinking required?"
}
```

**Example:**
```
Use sequential-thinking to reason through:
"How should we structure the authentication system?"
Start with thought 1 of 5.
```

### revise_thought

Go back and revise an earlier thought.

**Arguments:**
```json
{
  "thought": "string - Revised thought",
  "thought_number": "number - Current position",
  "revises_thought": "number - Which thought to revise",
  "total_thoughts": "number - Updated estimate"
}
```

**Example:**
```
Use sequential-thinking to revise thought 2 -
I realized we need to consider rate limiting.
```

### branch_thought

Explore an alternative approach.

**Arguments:**
```json
{
  "thought": "string - Alternative thought",
  "thought_number": "number - Position",
  "branches_from": "number - Which thought to branch from",
  "branch_id": "string - Name for this branch"
}
```

**Example:**
```
Use sequential-thinking to branch from thought 3 -
explore using Redis instead of PostgreSQL for sessions.
Branch ID: redis-sessions
```

## Complete Examples

### Example 1: Architecture Decision

```
Use sequential-thinking to decide:
"Should we use microservices or monolith for our MVP?"

Think through:
1. Current team size and expertise
2. Expected scale in 6 months
3. Deployment complexity
4. Development velocity tradeoffs
5. Conclusion with reasoning
```

### Example 2: Debugging

```
Use sequential-thinking to debug:
"Users report intermittent 500 errors on checkout"

Reason through:
1. What could cause intermittent errors?
2. What's different about failing requests?
3. Most likely root causes
4. How to verify each hypothesis
5. Recommended fix
```

### Example 3: With Revision

```
Use sequential-thinking:
1. "Initial approach: Use JWT for auth"
2. "Store tokens in localStorage"
3. [REVISE 2] "Actually, localStorage is XSS-vulnerable. Use httpOnly cookies."
4. "Final recommendation with cookie-based approach"
```

## Thinking Patterns

### Linear Chain
```
Thought 1 → Thought 2 → Thought 3 → Conclusion
```

### With Revision
```
Thought 1 → Thought 2 → Thought 3
                ↑
            Revise 2 → Thought 4 → Conclusion
```

### With Branching
```
Thought 1 → Thought 2 → Thought 3 → Conclusion A
                ↓
            Branch → Alt 3 → Conclusion B
```

## When to Use

| Scenario | Thoughts |
|----------|----------|
| Quick decision | 3-4 |
| Architecture choice | 5-7 |
| Complex debugging | 7-10 |
| Major refactor planning | 10-15 |

## Common Issues

### Thoughts getting too long
**Fix:** Break into smaller, focused thoughts

### Losing track of branches
**Fix:** Name branches descriptively: `branch_id: "redis-approach"`

### Not reaching conclusion
**Fix:** Set realistic `total_thoughts` and commit to concluding

## Pro Tips

1. **Start broad, get specific** - First thoughts frame the problem, later thoughts solve it
2. **Revise freely** - The power is in being able to backtrack
3. **Branch to compare** - Don't just pick one approach, explore alternatives
4. **End with action** - Final thought should be a clear recommendation

## References

- [MCP Sequential Thinking](https://github.com/anthropics/mcp-sequentialthinking)
- [Anthropic MCP Servers](https://github.com/anthropics/mcp-servers)
