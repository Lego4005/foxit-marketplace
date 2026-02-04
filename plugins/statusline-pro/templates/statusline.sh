#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Statusline Pro v2.0.0                                                     ║
# ║  Beautiful, customizable statusline for Claude Code                        ║
# ║  Hook Type: Notification                                                   ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

# Load config if exists
CONFIG_FILE="${HOME}/.config/claude-statusline/config.sh"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# ════════════════════════════════════════════════════════════════════════════
# CONFIGURATION (override via config.sh)
# ════════════════════════════════════════════════════════════════════════════
THEME="${THEME:-powerline}"
SEGMENTS="${SEGMENTS:-(git dir time session)}"
TIME_FORMAT="${TIME_FORMAT:-24h}"
MAX_DIR_LENGTH="${MAX_DIR_LENGTH:-25}"
COLOR_SCHEME="${COLOR_SCHEME:-dracula}"

# ════════════════════════════════════════════════════════════════════════════
# COLOR SCHEMES
# ════════════════════════════════════════════════════════════════════════════
load_colors() {
  case "$COLOR_SCHEME" in
    dracula)
      C_PRIMARY='\033[38;5;141m'   # Purple
      C_SECONDARY='\033[38;5;117m' # Cyan
      C_ACCENT='\033[38;5;212m'    # Pink
      C_SUCCESS='\033[38;5;84m'    # Green
      C_WARNING='\033[38;5;228m'   # Yellow
      C_ERROR='\033[38;5;210m'     # Red
      ;;
    nord)
      C_PRIMARY='\033[38;5;110m'   # Frost blue
      C_SECONDARY='\033[38;5;109m' # Teal
      C_ACCENT='\033[38;5;139m'    # Purple
      C_SUCCESS='\033[38;5;108m'   # Green
      C_WARNING='\033[38;5;222m'   # Yellow
      C_ERROR='\033[38;5;174m'     # Red
      ;;
    gruvbox)
      C_PRIMARY='\033[38;5;208m'   # Orange
      C_SECONDARY='\033[38;5;142m' # Olive
      C_ACCENT='\033[38;5;175m'    # Pink
      C_SUCCESS='\033[38;5;142m'   # Green
      C_WARNING='\033[38;5;214m'   # Yellow
      C_ERROR='\033[38;5;167m'     # Red
      ;;
    *)
      C_PRIMARY='\033[35m'
      C_SECONDARY='\033[36m'
      C_ACCENT='\033[34m'
      C_SUCCESS='\033[32m'
      C_WARNING='\033[33m'
      C_ERROR='\033[31m'
      ;;
  esac
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_DIM='\033[2m'
}

# ════════════════════════════════════════════════════════════════════════════
# THEME DEFINITIONS
# ════════════════════════════════════════════════════════════════════════════
load_theme() {
  case "$THEME" in
    powerline)
      SEP="" SEP_R=""
      ICON_BRANCH="" ICON_FOLDER=""
      ICON_CLEAN="✓" ICON_DIRTY="●"
      ICON_AHEAD="↑" ICON_BEHIND="↓"
      ICON_TIME="◷" ICON_SESSION="⏱"
      ICON_MEM="󰍛" ICON_CPU=""
      ;;
    cyberpunk)
      SEP="┃" SEP_R="┃"
      ICON_BRANCH="⟨" ICON_BRANCH_END="⟩" ICON_FOLDER="⌁"
      ICON_CLEAN="✓" ICON_DIRTY="✗"
      ICON_AHEAD="▲" ICON_BEHIND="▼"
      ICON_TIME="⌚" ICON_SESSION="⚡"
      ICON_MEM="◈" ICON_CPU="◉"
      ;;
    minimal)
      SEP="·" SEP_R="·"
      ICON_BRANCH="" ICON_FOLDER=""
      ICON_CLEAN="✓" ICON_DIRTY="●"
      ICON_AHEAD="+" ICON_BEHIND="-"
      ICON_TIME="" ICON_SESSION=""
      ICON_MEM="" ICON_CPU=""
      ;;
    hacker)
      SEP="] [" SEP_R="]"
      PREFIX="[" SUFFIX="]"
      ICON_BRANCH="git:" ICON_FOLDER="dir:"
      ICON_CLEAN="ok" ICON_DIRTY="*"
      ICON_AHEAD="+" ICON_BEHIND="-"
      ICON_TIME="@" ICON_SESSION="t:"
      ICON_MEM="mem:" ICON_CPU="cpu:"
      ;;
    retro)
      SEP="░▒▓" SEP_R="▓▒░"
      ICON_BRANCH="" ICON_FOLDER=""
      ICON_CLEAN="+" ICON_DIRTY="~"
      ICON_AHEAD="^" ICON_BEHIND="v"
      ICON_TIME="" ICON_SESSION=""
      ICON_MEM="" ICON_CPU=""
      ;;
    nyan)
      SEP="═══" SEP_R="═══"
      ICON_BRANCH="★" ICON_FOLDER="☆"
      ICON_CLEAN="♥" ICON_DIRTY="♠"
      ICON_AHEAD="↑" ICON_BEHIND="↓"
      ICON_TIME="★" ICON_SESSION="★"
      ICON_MEM="☆" ICON_CPU="☆"
      ;;
  esac
}

# ════════════════════════════════════════════════════════════════════════════
# SEGMENT FUNCTIONS
# ════════════════════════════════════════════════════════════════════════════

get_git() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  local status=""

  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    status="${C_WARNING}${ICON_DIRTY}${C_RESET}"
  else
    status="${C_SUCCESS}${ICON_CLEAN}${C_RESET}"
  fi

  local upstream=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [[ -n "$upstream" ]]; then
    local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
    local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
    [[ $ahead -gt 0 ]] && status="$status${C_SUCCESS}${ICON_AHEAD}${ahead}${C_RESET}"
    [[ $behind -gt 0 ]] && status="$status${C_ERROR}${ICON_BEHIND}${behind}${C_RESET}"
  fi

  if [[ "$THEME" == "cyberpunk" ]]; then
    echo -e "${C_PRIMARY}${ICON_BRANCH}${branch}${ICON_BRANCH_END}${C_RESET} $status"
  else
    echo -e "${C_PRIMARY}${ICON_BRANCH} ${branch}${C_RESET} $status"
  fi
}

get_dir() {
  local path="${PWD/#$HOME/\~}"
  if [[ ${#path} -gt $MAX_DIR_LENGTH ]]; then
    local parts=() result=""
    IFS='/' read -ra parts <<< "$path"
    for ((i=0; i<${#parts[@]}; i++)); do
      if [[ $i -eq 0 ]]; then result="${parts[i]}"
      elif [[ $i -eq $((${#parts[@]}-1)) ]]; then result="$result/${parts[i]}"
      else result="$result/${parts[i]:0:1}"; fi
    done
    path="$result"
  fi
  echo -e "${C_ACCENT}${ICON_FOLDER} ${path}${C_RESET}"
}

get_time() {
  local fmt="%H:%M"
  [[ "$TIME_FORMAT" == "12h" ]] && fmt="%I:%M%p"
  echo -e "${C_DIM}${ICON_TIME} $(date +"$fmt")${C_RESET}"
}

get_session() {
  local session_file="${HOME}/.claude-session-start"
  [[ ! -f "$session_file" ]] && date +%s > "$session_file"
  local start=$(cat "$session_file") now=$(date +%s)
  local diff=$((now - start)) hours=$((diff / 3600)) mins=$(((diff % 3600) / 60))
  local display=$([[ $hours -gt 0 ]] && echo "${hours}h${mins}m" || echo "${mins}m")
  echo -e "${C_SECONDARY}${ICON_SESSION} ${display}${C_RESET}"
}

get_memory() {
  local mem=""
  if [[ "$(uname)" == "Darwin" ]]; then
    local pages=$(vm_stat | awk '/Pages active/ {print $3}' | tr -d '.')
    mem="$((pages * 4096 / 1024 / 1024 / 1024)).$(((pages * 4096 / 1024 / 1024) % 1024 / 100))G"
  else
    mem=$(free -h 2>/dev/null | awk '/Mem:/ {print $3}' || echo "N/A")
  fi
  echo -e "${C_WARNING}${ICON_MEM} ${mem}${C_RESET}"
}

get_cpu() {
  local cpu=""
  if [[ "$(uname)" == "Darwin" ]]; then
    cpu=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f%%", s/4}')
  else
    cpu=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "N/A")
    cpu="${cpu}%"
  fi
  echo -e "${C_ERROR}${ICON_CPU} ${cpu}${C_RESET}"
}

# ════════════════════════════════════════════════════════════════════════════
# BUILD STATUSLINE
# ════════════════════════════════════════════════════════════════════════════

build_statusline() {
  load_colors
  load_theme

  local parts=()
  for seg in ${SEGMENTS[@]}; do
    case $seg in
      git) local v=$(get_git); [[ -n "$v" ]] && parts+=("$v") ;;
      dir) parts+=("$(get_dir)") ;;
      time) parts+=("$(get_time)") ;;
      session) parts+=("$(get_session)") ;;
      memory) parts+=("$(get_memory)") ;;
      cpu) parts+=("$(get_cpu)") ;;
    esac
  done

  local result=""
  if [[ "$THEME" == "hacker" ]]; then
    result="${PREFIX}"
    for ((i=0; i<${#parts[@]}; i++)); do
      [[ $i -gt 0 ]] && result="$result$SEP"
      result="$result${parts[i]}"
    done
    result="$result${SUFFIX}"
  else
    for ((i=0; i<${#parts[@]}; i++)); do
      [[ $i -gt 0 ]] && result="$result ${C_DIM}│${C_RESET} "
      result="$result${parts[i]}"
    done
  fi
  echo -e "$result"
}

# ════════════════════════════════════════════════════════════════════════════
# OUTPUT
# ════════════════════════════════════════════════════════════════════════════
STATUSLINE=$(build_statusline)
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Notification",
    "statusline": "$STATUSLINE"
  }
}
EOF
