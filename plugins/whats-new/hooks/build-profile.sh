#!/bin/bash
# Build and cache a profile of the user's Claude Code setup
# Used by /whats-new to personalize impact analysis without re-scanning

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$PLUGIN_DIR/data"
PROFILE_FILE="$DATA_DIR/repo-profile.json"
PROFILE_CACHE_HOURS=24

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Check if profile is fresh enough
if [[ -f "$PROFILE_FILE" ]]; then
    CACHE_AGE=$(( ($(date +%s) - $(stat -f %m "$PROFILE_FILE" 2>/dev/null || stat -c %Y "$PROFILE_FILE" 2>/dev/null)) / 3600 ))
    if [[ $CACHE_AGE -lt $PROFILE_CACHE_HOURS && "${1:-}" != "--force" ]]; then
        # Return cached profile
        cat "$PROFILE_FILE"
        exit 0
    fi
fi

# Build fresh profile
echo "Building fresh profile..." >&2

# Find project root (look for .claude directory)
PROJECT_ROOT="$(pwd)"
if [[ -d "$PROJECT_ROOT/.claude" ]]; then
    CLAUDE_DIR="$PROJECT_ROOT/.claude"
elif [[ -d "$HOME/.claude" ]]; then
    CLAUDE_DIR="$HOME/.claude"
else
    CLAUDE_DIR=""
fi

# Count hooks
HOOK_COUNT=0
HOOK_TYPES=()
if [[ -n "$CLAUDE_DIR" && -d "$CLAUDE_DIR/hooks" ]]; then
    HOOK_COUNT=$(find "$CLAUDE_DIR/hooks" -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
    # Get hook types from settings.json
    if [[ -f "$CLAUDE_DIR/settings.json" ]]; then
        HOOK_TYPES=($(jq -r '.hooks | keys[]' "$CLAUDE_DIR/settings.json" 2>/dev/null || echo ""))
    fi
fi

# Count skills
SKILL_COUNT=0
if [[ -n "$CLAUDE_DIR" && -d "$CLAUDE_DIR/skills" ]]; then
    SKILL_COUNT=$(find "$CLAUDE_DIR/skills" -name "SKILL.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# Count agents
AGENT_COUNT=0
if [[ -n "$CLAUDE_DIR" && -d "$CLAUDE_DIR/agents" ]]; then
    AGENT_COUNT=$(find "$CLAUDE_DIR/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
fi

# Count MCP servers
MCP_COUNT=0
if [[ -n "$CLAUDE_DIR" && -f "$CLAUDE_DIR/settings.json" ]]; then
    MCP_COUNT=$(jq '.mcpServers | length // 0' "$CLAUDE_DIR/settings.json" 2>/dev/null || echo 0)
fi

# Check IDE usage
USES_VSCODE=false
if [[ -d "$HOME/.vscode/extensions" ]] && find "$HOME/.vscode/extensions" -name "*claude*" -type d 2>/dev/null | grep -q .; then
    USES_VSCODE=true
fi

# Determine heavy user thresholds
HOOKS_HEAVY=$([[ $HOOK_COUNT -gt 20 ]] && echo true || echo false)
SKILLS_HEAVY=$([[ $SKILL_COUNT -gt 20 ]] && echo true || echo false)
AGENTS_HEAVY=$([[ $AGENT_COUNT -gt 10 ]] && echo true || echo false)

# Build impact filters based on what they use
HIGHLIGHT='["security"]'
DEPRIORITIZE='[]'

if [[ "$HOOKS_HEAVY" == "true" ]]; then
    HIGHLIGHT=$(echo "$HIGHLIGHT" | jq '. + ["hooks", "PreToolUse", "PostToolUse", "SessionStart"]')
fi
if [[ "$AGENTS_HEAVY" == "true" ]]; then
    HIGHLIGHT=$(echo "$HIGHLIGHT" | jq '. + ["subagents", "Task tool", "agents"]')
fi
if [[ "$SKILLS_HEAVY" == "true" ]]; then
    HIGHLIGHT=$(echo "$HIGHLIGHT" | jq '. + ["skills", "slash commands"]')
fi
if [[ "$MCP_COUNT" -eq 0 ]]; then
    DEPRIORITIZE=$(echo "$DEPRIORITIZE" | jq '. + ["MCP", "mcp"]')
fi
if [[ "$USES_VSCODE" == "false" ]]; then
    DEPRIORITIZE=$(echo "$DEPRIORITIZE" | jq '. + ["VSCode", "vscode", "IDE"]')
fi

# Add common deprioritized items
DEPRIORITIZE=$(echo "$DEPRIORITIZE" | jq '. + ["Windows", "Bedrock", "Vertex"]')

# Build profile JSON
cat > "$PROFILE_FILE" << EOF
{
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project_root": "$PROJECT_ROOT",
  "claude_dir": "$CLAUDE_DIR",
  "features": {
    "hooks": {
      "count": $HOOK_COUNT,
      "heavy_user": $HOOKS_HEAVY,
      "types": $(printf '%s\n' "${HOOK_TYPES[@]:-}" | jq -R . | jq -s . 2>/dev/null || echo '[]')
    },
    "skills": {
      "count": $SKILL_COUNT,
      "heavy_user": $SKILLS_HEAVY
    },
    "agents": {
      "count": $AGENT_COUNT,
      "heavy_user": $AGENTS_HEAVY,
      "uses_subagents": $([[ $AGENT_COUNT -gt 0 ]] && echo true || echo false)
    },
    "mcp": {
      "count": $MCP_COUNT,
      "has_servers": $([[ $MCP_COUNT -gt 0 ]] && echo true || echo false)
    },
    "ide": {
      "uses_vscode": $USES_VSCODE
    }
  },
  "impact_filters": {
    "highlight": $HIGHLIGHT,
    "deprioritize": $DEPRIORITIZE
  },
  "warnings": [
    $([[ "$HOOKS_HEAVY" == "true" ]] && echo '"Heavy hook user ('$HOOK_COUNT' hooks) - review hook changes carefully",' || echo '')
    $([[ "$AGENTS_HEAVY" == "true" ]] && echo '"Heavy agent user ('$AGENT_COUNT' agents) - Task tool changes may affect workflows",' || echo '')
    "null"
  ]
}
EOF

# Clean up the warnings array (remove trailing comma and null)
jq '.warnings = [.warnings[] | select(. != null and . != "")]' "$PROFILE_FILE" > "$PROFILE_FILE.tmp" && mv "$PROFILE_FILE.tmp" "$PROFILE_FILE"

echo "Profile saved to $PROFILE_FILE" >&2
cat "$PROFILE_FILE"
