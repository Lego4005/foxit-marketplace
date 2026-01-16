---
description: Design perfect Claude Code hooks - guided discovery, self-healing, auto-updates
triggers: [hook-architect, hooks, design-hooks, ha]
---

# Hook Architect

Design perfect Claude Code hooks for any codebase through guided discovery, intelligent recommendations, and self-healing.

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `/hook-architect` | Full guided workflow |
| `/hook-architect --review` | Audit & grade existing hooks (A-F) |
| `/hook-architect --update` | Check Anthropic docs for API updates |
| `/hook-architect --heal` | Auto-fix common issues |
| `/hook-architect --recipes` | Browse hook templates |

## Hook Types

| Type | When | Use For |
|------|------|---------|
| `PreToolUse` | Before tool runs | Permission gates, file protection |
| `PostToolUse` | After tool completes | Logging, auto-format, notifications |
| `UserPromptSubmit` | User sends message | Context injection, routing |
| `SubagentStart` | Agent spawns | Enrichment, duplicate detection |
| `SubagentStop` | Agent completes | Output compression, scoring |

## Progression Levels

### Level 1: Safety (Essential)
- **file-guardian** - Block .env, lock files, generated code
- **command-bouncer** - Block rm -rf, DROP TABLE, force push

### Level 2: Productivity
- **auto-formatter** - Run prettier/eslint after edits
- **test-watcher** - Run tests when files change

### Level 3: Intelligence
- **memory-inject** - Pull relevant past work
- **duplicate-detect** - Warn if similar work exists

## Install Hooks

```bash
# From plugin templates directory:
./scripts/install-hooks.sh --safety      # Essential hooks
./scripts/install-hooks.sh --all         # All hooks
./scripts/install-hooks.sh file-guardian # Specific hook
```

## Hook I/O Contract

**Input (stdin):**
```json
{"tool_name": "Edit", "tool_input": {"file_path": "..."}}
```

**Output (stdout):**
```json
{"decision": "proceed"}
{"decision": "block", "reason": "Protected file"}
```

## Self-Healing

- `--review` grades hooks A-F on security, performance, reliability
- `--update` checks Anthropic docs for API changes
- `--heal` auto-fixes: missing set -e, unquoted vars, deprecated fields
