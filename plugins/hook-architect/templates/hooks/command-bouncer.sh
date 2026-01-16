#!/bin/bash
# command-bouncer.sh - Block dangerous shell commands
# Hook Type: PreToolUse (Bash)
# Version: 2.0.0 - Updated to new Anthropic hooks API (January 2026)
#
# API Change: Uses hookSpecificOutput.permissionDecision instead of deprecated decision field
# Values: "allow" | "deny" | "ask" (was: "approve" | "block")

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only check Bash commands
if [[ "$TOOL_NAME" != "Bash" ]]; then
  echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}'
  exit 0
fi

# Dangerous command patterns
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \.\."
  "rm -rf \*"
  "> /dev/sd"
  "mkfs\."
  "dd if=/dev"
  ":(){ :|:& };:"
  "chmod -R 777 /"
  "chown -R"
  "DROP TABLE"
  "DROP DATABASE"
  "TRUNCATE TABLE"
  "DELETE FROM .* WHERE 1"
  "git push.*--force.*main"
  "git push.*--force.*master"
  "git push.*-f.*main"
  "git push.*-f.*master"
  "git reset --hard.*origin"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if [[ "$COMMAND" =~ $pattern ]]; then
    echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"🚫 Dangerous command blocked: matches pattern '$pattern'\"}}"
    exit 0
  fi
done

echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}'
