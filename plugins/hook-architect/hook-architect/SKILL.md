---
description: Design perfect Claude Code hooks - guided discovery, self-healing, auto-updates
triggers: [hook-architect, hooks, design-hooks, ha]
---

# Hook Architect

Design perfect Claude Code hooks for any codebase through guided discovery, intelligent recommendations, and self-healing.

**Last Updated:** January 2026 (Claude Code 2.1.x API)

## Quick Reference

| Command | What It Does |
|---------|-------------|
| `/hook-architect` | Full guided workflow |
| `/hook-architect --review` | Audit & grade existing hooks (A-F) |
| `/hook-architect --update` | Check Anthropic docs for API updates |
| `/hook-architect --heal` | Auto-fix common issues |
| `/hook-architect --recipes` | Browse hook templates |

## Hook Types (Updated January 2026)

| Type | When | Use For |
|------|------|---------|
| `PreToolUse` | Before tool runs | Permission gates, file protection, input modification |
| `PermissionRequest` | Permission dialog shown | Auto-allow/deny permissions |
| `PostToolUse` | After tool completes | Logging, auto-format, notifications, feedback to Claude |
| `UserPromptSubmit` | User sends message | Context injection, routing, validation |
| `SubagentStart` | Agent spawns | Enrichment, duplicate detection |
| `SubagentStop` | Agent completes | Output compression, scoring, evaluation |
| `Stop` | Main agent finishes | Control if Claude continues working |
| `SessionStart` | Session starts/resumes | Load context, setup environment |
| `SessionEnd` | Session ends | Cleanup, logging, save state |
| `PreCompact` | Before compaction | Intercept context compression |
| `Notification` | Background alerts | React to permission, idle, auth notifications |

## Hook I/O Contract (NEW API - January 2026)

### PreToolUse Input
```json
{
  "tool_name": "Edit",
  "tool_input": {"file_path": "/path/to/file.ts", "old_string": "...", "new_string": "..."},
  "tool_use_id": "toolu_01ABC123...",
  "session_id": "...",
  "cwd": "/project/path"
}
```

### PreToolUse Output (NEW FORMAT)
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Why this decision was made",
    "updatedInput": {"command": "modified command"}
  }
}
```

**Permission Decisions:**
- `allow` - Bypass permission system, proceed immediately
- `deny` - Block the tool call entirely
- `ask` - Show user permission dialog (NEW!)

**DEPRECATED** (still works but update your hooks):
```json
{"decision": "approve|block", "reason": "..."}
```

### PostToolUse Output
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Feedback for Claude about what happened"
  }
}
```

### UserPromptSubmit Output
```json
{
  "decision": "block",
  "reason": "Why blocked"
}
```
Or add context (printed to stdout or via JSON):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "Injected context for this prompt"
  }
}
```

### SessionStart Output
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Loaded project context..."
  }
}
```
**Special:** Use `$CLAUDE_ENV_FILE` to persist environment variables.

## Component-Scoped Hooks (NEW!)

Define hooks directly in Skills, Subagents, and Slash Commands via frontmatter:

```yaml
---
name: secure-coder
description: Code with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
  PostToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: "./scripts/run-linter.sh"
  once: true  # Run only once per session
---
```

**Supported events:** PreToolUse, PostToolUse, Stop

## Prompt-Based Hooks (NEW!)

Use LLM evaluation instead of shell scripts:

```json
{
  "hooks": {
    "Stop": [{
      "hooks": [{
        "type": "prompt",
        "prompt": "Evaluate if all tasks are complete. $ARGUMENTS",
        "timeout": 30
      }]
    }]
  }
}
```

LLM responds with:
```json
{"ok": true|false, "reason": "explanation if false"}
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `$CLAUDE_PROJECT_DIR` | Absolute path to project root |
| `$CLAUDE_PLUGIN_ROOT` | Plugin directory (for plugin hooks) |
| `$CLAUDE_CODE_REMOTE` | "true" for web, unset for CLI |
| `$CLAUDE_ENV_FILE` | File to persist env vars (SessionStart only) |

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

### Level 4: Orchestration
- **session-context** - Load project context on session start
- **agent-scorer** - Evaluate and score agent outputs

## Install Hooks

```bash
# From plugin templates directory:
./scripts/install-hooks.sh --safety      # Essential hooks
./scripts/install-hooks.sh --all         # All hooks
./scripts/install-hooks.sh file-guardian # Specific hook
```

## Configuration Structure (Updated)

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/file-guardian.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/auto-formatter.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/load-context.sh"
          }
        ]
      }
    ]
  }
}
```

## Self-Healing

- `--review` grades hooks A-F on security, performance, reliability
- `--update` checks Anthropic docs for API changes
- `--heal` auto-fixes: deprecated fields, missing hookEventName, old decision values

### Common Fixes (--heal)
| Issue | Auto-Fix |
|-------|----------|
| `decision: "approve"` | → `permissionDecision: "allow"` |
| `decision: "block"` | → `permissionDecision: "deny"` |
| Missing `hookEventName` | → Add based on hook type |
| Missing `set -e` | → Add to shell scripts |
| Unquoted variables | → Add quotes |

## MCP Tool Matching

Match MCP tools with pattern: `mcp__<server>__<tool>`

```json
{
  "matcher": "mcp__memory__.*",
  "hooks": [{"type": "command", "command": "..."}]
}
```

## Debugging

```bash
claude --debug  # Shows hook matching and execution details
```
