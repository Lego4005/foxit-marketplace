#!/bin/bash
# file-guardian.sh - Protect critical files from accidental edits
# Hook Type: PreToolUse (Edit, Write)
# Version: 2.0.0 - Updated to new Anthropic hooks API (January 2026)
#
# API Change: Uses hookSpecificOutput.permissionDecision instead of deprecated decision field
# Values: "allow" | "deny" | "ask" (was: "approve" | "block")

set -e

# Read JSON input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Early exit for non-edit tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}'
  exit 0
fi

# Protected file patterns - customize as needed
PROTECTED_PATTERNS=(
  "\.env$"
  "\.env\."
  "package-lock\.json$"
  "pnpm-lock\.yaml$"
  "yarn\.lock$"
  "Cargo\.lock$"
  "/node_modules/"
  "/dist/"
  "/build/"
  "/generated/"
  "\.min\.js$"
  "\.min\.css$"
)

# Check if file matches any protected pattern
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" =~ $pattern ]]; then
    # Use "ask" to let user override, or "deny" to hard block
    echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PreToolUse\", \"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"🛡️ Protected file: $FILE_PATH (matches pattern: $pattern)\"}}"
    exit 0
  fi
done

echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}'
