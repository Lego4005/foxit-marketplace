#!/bin/bash
# auto-formatter.sh - Auto-format code after edits
# Hook Type: PostToolUse (Edit, Write)
# Version: 2.0.0 - Updated to new Anthropic hooks API (January 2026)
#
# PostToolUse uses hookSpecificOutput.additionalContext to provide feedback to Claude

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only run after Edit/Write
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  echo '{"hookSpecificOutput": {"hookEventName": "PostToolUse"}}'
  exit 0
fi

# Skip if file doesn't exist
if [[ ! -f "$FILE_PATH" ]]; then
  echo '{"hookSpecificOutput": {"hookEventName": "PostToolUse"}}'
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"
FORMATTED=""

# Format based on file type (silent failures - don't block on format errors)
case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|json|md|yaml|yml|html|css|scss)
    if command -v prettier &> /dev/null; then
      if prettier --write "$FILE_PATH" 2>/dev/null; then
        FORMATTED="prettier"
      fi
    fi
    ;;
  py)
    if command -v black &> /dev/null; then
      if black --quiet "$FILE_PATH" 2>/dev/null; then
        FORMATTED="black"
      fi
    elif command -v autopep8 &> /dev/null; then
      if autopep8 --in-place "$FILE_PATH" 2>/dev/null; then
        FORMATTED="autopep8"
      fi
    fi
    ;;
  rs)
    if command -v rustfmt &> /dev/null; then
      if rustfmt "$FILE_PATH" 2>/dev/null; then
        FORMATTED="rustfmt"
      fi
    fi
    ;;
  go)
    if command -v gofmt &> /dev/null; then
      if gofmt -w "$FILE_PATH" 2>/dev/null; then
        FORMATTED="gofmt"
      fi
    fi
    ;;
  rb)
    if command -v rubocop &> /dev/null; then
      if rubocop -a "$FILE_PATH" 2>/dev/null; then
        FORMATTED="rubocop"
      fi
    fi
    ;;
esac

# Provide feedback to Claude about formatting
if [[ -n "$FORMATTED" ]]; then
  echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PostToolUse\", \"additionalContext\": \"✨ Auto-formatted $FILE_PATH with $FORMATTED\"}}"
else
  echo '{"hookSpecificOutput": {"hookEventName": "PostToolUse"}}'
fi
