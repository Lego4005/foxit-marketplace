#!/bin/bash
# statusline.sh - Beautiful statusline for Claude Code
# Hook Type: Notification (runs periodically)
# Version: 1.0.0
#
# Displays: [git branch] [status] [directory] [session time] [indicators]

set -e

# ============================================================================
# CONFIGURATION - Customize these!
# ============================================================================
SHOW_GIT=true
SHOW_TIME=true
SHOW_DIR=true
SHOW_SESSION=true
MAX_DIR_LENGTH=30

# Colors (ANSI)
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_BLUE='\033[34m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_CYAN='\033[36m'
C_MAGENTA='\033[35m'

# Icons (using Unicode - works in most terminals)
ICON_BRANCH=""
ICON_CLEAN="✓"
ICON_DIRTY="●"
ICON_AHEAD="↑"
ICON_BEHIND="↓"
ICON_CLOCK="◷"
ICON_FOLDER="▸"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Shorten path for display
shorten_path() {
  local path="$1"
  local max="$2"

  # Replace home with ~
  path="${path/#$HOME/~}"

  # If short enough, return as-is
  if [[ ${#path} -le $max ]]; then
    echo "$path"
    return
  fi

  # Shorten middle directories
  local parts=()
  IFS='/' read -ra parts <<< "$path"
  local result=""
  local len=${#parts[@]}

  for ((i=0; i<len; i++)); do
    if [[ $i -eq 0 ]]; then
      result="${parts[i]}"
    elif [[ $i -eq $((len-1)) ]]; then
      result="$result/${parts[i]}"
    else
      result="$result/${parts[i]:0:1}"
    fi
  done

  echo "$result"
}

# Get git info
get_git_info() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo ""
    return
  fi

  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  local status=""

  # Check if dirty
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    status="${C_YELLOW}${ICON_DIRTY}${C_RESET}"
  else
    status="${C_GREEN}${ICON_CLEAN}${C_RESET}"
  fi

  # Check ahead/behind
  local upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
    local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)

    [[ $ahead -gt 0 ]] && status="$status${C_GREEN}${ICON_AHEAD}${ahead}${C_RESET}"
    [[ $behind -gt 0 ]] && status="$status${C_RED}${ICON_BEHIND}${behind}${C_RESET}"
  fi

  echo -e "${C_MAGENTA}${ICON_BRANCH} ${branch}${C_RESET} $status"
}

# Get session duration
get_session_time() {
  local session_file="${HOME}/.claude-session-start"

  # Create session file if doesn't exist
  if [[ ! -f "$session_file" ]]; then
    date +%s > "$session_file"
  fi

  local start=$(cat "$session_file")
  local now=$(date +%s)
  local diff=$((now - start))

  local hours=$((diff / 3600))
  local mins=$(((diff % 3600) / 60))

  if [[ $hours -gt 0 ]]; then
    echo "${hours}h${mins}m"
  else
    echo "${mins}m"
  fi
}

# ============================================================================
# MAIN STATUSLINE BUILDER
# ============================================================================

build_statusline() {
  local parts=()

  # Git info
  if [[ "$SHOW_GIT" == "true" ]]; then
    local git_info=$(get_git_info)
    [[ -n "$git_info" ]] && parts+=("$git_info")
  fi

  # Current directory
  if [[ "$SHOW_DIR" == "true" ]]; then
    local dir=$(shorten_path "$(pwd)" $MAX_DIR_LENGTH)
    parts+=("${C_BLUE}${ICON_FOLDER} ${dir}${C_RESET}")
  fi

  # Current time
  if [[ "$SHOW_TIME" == "true" ]]; then
    local time=$(date +"%H:%M")
    parts+=("${C_DIM}${ICON_CLOCK} ${time}${C_RESET}")
  fi

  # Session duration
  if [[ "$SHOW_SESSION" == "true" ]]; then
    local session=$(get_session_time)
    parts+=("${C_CYAN}⏱ ${session}${C_RESET}")
  fi

  # Join with separator
  local separator=" ${C_DIM}│${C_RESET} "
  local result=""
  for ((i=0; i<${#parts[@]}; i++)); do
    if [[ $i -gt 0 ]]; then
      result="$result$separator"
    fi
    result="$result${parts[i]}"
  done

  echo -e "$result"
}

# ============================================================================
# HOOK OUTPUT
# ============================================================================

# Build the statusline
STATUSLINE=$(build_statusline)

# Output for Claude Code
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Notification",
    "statusline": "$STATUSLINE"
  }
}
EOF
