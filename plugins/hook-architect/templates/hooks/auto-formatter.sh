#!/bin/bash
# auto-formatter.sh - Auto-format code after edits
# Hook Type: PostToolUse (Edit, Write)
# Version: 1.0.0

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run after Edit/Write
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  echo '{"decision": "proceed"}'
  exit 0
fi

# Skip if file doesn't exist
if [[ ! -f "$FILE_PATH" ]]; then
  echo '{"decision": "proceed"}'
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

# Format based on file type (silent failures - don't block on format errors)
case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|json|md|yaml|yml|html|css|scss)
    if command -v prettier &> /dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  py)
    if command -v black &> /dev/null; then
      black --quiet "$FILE_PATH" 2>/dev/null || true
    elif command -v autopep8 &> /dev/null; then
      autopep8 --in-place "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &> /dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  go)
    if command -v gofmt &> /dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rb)
    if command -v rubocop &> /dev/null; then
      rubocop -a "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

echo '{"decision": "proceed"}'
