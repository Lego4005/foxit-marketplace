#!/bin/bash
# file-guardian.sh - Protect critical files from accidental edits
# Hook Type: PreToolUse (Edit, Write)
# Version: 1.0.0

set -e

# Read JSON input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Early exit for non-edit tools
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  echo '{"decision": "proceed"}'
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
    echo "{\"decision\": \"block\", \"reason\": \"🛡️ Protected file: $FILE_PATH (matches pattern: $pattern)\"}"
    exit 0
  fi
done

echo '{"decision": "proceed"}'
