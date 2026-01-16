# Hook Architect Skill

Expert guidance for designing, implementing, and maintaining Claude Code hooks.

## Core Knowledge

### Hook Types Reference

| Hook Type | When It Fires | Common Uses |
|-----------|--------------|-------------|
| `PreToolUse` | Before any tool runs | Permission gates, file protection, command safety |
| `PostToolUse` | After tool completes | Logging, metrics, auto-formatting, notifications |
| `UserPromptSubmit` | User sends message | Context injection, routing, memory retrieval |
| `SubagentStart` | Task agent spawns | Context enrichment, duplicate detection |
| `SubagentStop` | Agent completes | Output compression, learning capture, scoring |
| `SessionStart` | Session begins | Environment setup, context loading |
| `Notification` | Background events | Alerts, status updates, integrations |

### Hook I/O Contract

**Input (stdin):**
```json
{
  "hook_type": "PreToolUse",
  "tool_name": "Edit",
  "tool_input": {
    "file_path": "/path/to/file.ts",
    "old_string": "...",
    "new_string": "..."
  },
  "session_id": "abc123"
}
```

**Output (stdout):**
```json
{"decision": "proceed"}
```
```json
{"decision": "block", "reason": "Cannot edit protected file"}
```
```json
{"decision": "proceed", "additionalContext": "Note: file in migrations/"}
```

### Security Best Practices

All hooks MUST follow these rules:

1. **Input Validation** - Use `jq` for JSON parsing, never `eval`
2. **Quote Variables** - Always `"$var"` not `$var`
3. **Path Validation** - Check paths before operations
4. **No Secrets in Logs** - Scrub sensitive data
5. **Timeout Enforcement** - 5s for safety hooks, 60s max
6. **Audit Trail** - Log decisions with timestamps

### Performance Targets

| Hook Type | Target Latency | Notes |
|-----------|---------------|-------|
| PreToolUse (safety) | <50ms | Blocking UX |
| PostToolUse (logging) | <100ms | Can batch |
| UserPromptSubmit | <200ms | Startup acceptable |
| SubagentStart | <500ms | Worth the context |

## Hook Templates

### Template: File Guardian (PreToolUse)

```bash
#!/bin/bash
set -e

# Read JSON input
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Early exit for non-edit tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  echo '{"decision": "proceed"}'
  exit 0
fi

# Protected patterns
PROTECTED_PATTERNS=(
  "\.env$"
  "\.env\."
  "package-lock\.json$"
  "pnpm-lock\.yaml$"
  "yarn\.lock$"
  "/generated/"
  "/dist/"
  "/node_modules/"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" =~ $pattern ]]; then
    echo "{\"decision\": \"block\", \"reason\": \"Protected file: $FILE_PATH matches $pattern\"}"
    exit 0
  fi
done

echo '{"decision": "proceed"}'
```

### Template: Command Bouncer (PreToolUse:Bash)

```bash
#!/bin/bash
set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ "$TOOL_NAME" != "Bash" ]]; then
  echo '{"decision": "proceed"}'
  exit 0
fi

# Dangerous patterns
DANGEROUS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \*"
  "DROP TABLE"
  "DROP DATABASE"
  "git push.*--force"
  "git push.*-f"
  "> /dev/sd"
  "mkfs\."
  "dd if="
)

for pattern in "${DANGEROUS[@]}"; do
  if [[ "$COMMAND" =~ $pattern ]]; then
    echo "{\"decision\": \"block\", \"reason\": \"Dangerous command blocked: matches '$pattern'\"}"
    exit 0
  fi
done

echo '{"decision": "proceed"}'
```

### Template: Auto Formatter (PostToolUse:Edit)

```bash
#!/bin/bash
set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  echo '{"decision": "proceed"}'
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Format based on extension
case "$EXT" in
  ts|tsx|js|jsx|json)
    if command -v prettier &> /dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v black &> /dev/null; then
      black "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &> /dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

echo '{"decision": "proceed"}'
```

## Codebase Analysis Patterns

When analyzing a codebase for hook recommendations:

### Language Detection
| Marker File | Language | Extensions |
|------------|----------|------------|
| `package.json` | Node/TypeScript | .ts, .tsx, .js, .jsx |
| `Cargo.toml` | Rust | .rs |
| `pyproject.toml` | Python | .py |
| `go.mod` | Go | .go |
| `Gemfile` | Ruby | .rb |

### Structure Detection
| Pattern | Indicates |
|---------|-----------|
| `packages/` or workspaces | Monorepo |
| `tests/` or `__tests__/` | Test directory |
| `migrations/` | Database migrations |
| `.github/workflows/` | CI/CD |
| `.env` files | Secrets to protect |

### Tool Detection
| Config File | Tool Type |
|------------|-----------|
| `.eslintrc*` | Linter |
| `.prettierrc*` | Formatter |
| `jest.config.*` | Test runner |
| `vitest.config.*` | Test runner |
| `tsconfig.json` | TypeScript |

## Review Criteria

When reviewing hooks, grade on:

### Security (30%)
- [ ] Uses jq for JSON parsing (not grep/sed)
- [ ] All variables quoted
- [ ] No eval usage
- [ ] Paths validated before use
- [ ] Secrets not logged

### Performance (25%)
- [ ] Early exit for irrelevant tools
- [ ] Timeout set appropriately
- [ ] No expensive operations in hot path
- [ ] Caching where beneficial

### Reliability (20%)
- [ ] Has `set -e` or error handling
- [ ] Valid JSON output always
- [ ] Handles missing fields gracefully
- [ ] Works with edge cases

### Maintainability (15%)
- [ ] Clear comments explaining logic
- [ ] Configuration separated from code
- [ ] Follows naming conventions
- [ ] Modular structure

### Best Practices (10%)
- [ ] Logging for debugging
- [ ] Shebang present
- [ ] Executable permissions documented
- [ ] Version/date in comments

## Auto-Healing Rules

Issues that can be auto-fixed:

| Issue | Fix |
|-------|-----|
| Missing shebang | Add `#!/bin/bash` |
| Missing `set -e` | Add after shebang |
| Unquoted `$var` | Change to `"$var"` |
| Uses `message` field | Change to `reason` |
| No timeout | Wrap with timeout command |
| Missing jq validation | Add input validation block |

Issues requiring manual review:

| Issue | Why |
|-------|-----|
| `eval` usage | Security implications |
| External API calls | May break integrations |
| Complex logic | Could change behavior |
| Permission model | User decision needed |

## Integration with Claude Code

Hooks are configured in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "command": [".claude/hooks/file-guardian.sh"],
        "timeout": 5000
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit",
        "command": [".claude/hooks/auto-formatter.sh"],
        "timeout": 10000
      }
    ]
  }
}
```
