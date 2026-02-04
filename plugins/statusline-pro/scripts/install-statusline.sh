#!/bin/bash
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Statusline Pro Installer                                                  ║
# ║  A beautiful statusline for Claude Code                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝

set -e

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

# Default to global install
INSTALL_MODE="global"
THEME="powerline"
CONFIG_DIR="${HOME}/.config/claude-statusline"
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"

# Colors
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RED='\033[31m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_BLUE='\033[34m'
C_MAGENTA='\033[35m'
C_CYAN='\033[36m'
C_WHITE='\033[97m'
C_BG_BLUE='\033[44m'
C_BG_MAGENTA='\033[45m'

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --local) INSTALL_MODE="local"; shift ;;
    --theme) THEME="$2"; shift 2 ;;
    --minimal) THEME="minimal"; shift ;;
    --cyberpunk) THEME="cyberpunk"; shift ;;
    --hacker) THEME="hacker"; shift ;;
    --help|-h)
      echo "Usage: install-statusline.sh [options]"
      echo ""
      echo "Options:"
      echo "  --local       Install to current project only"
      echo "  --theme NAME  Set theme (powerline, minimal, cyberpunk, hacker, retro, nyan)"
      echo "  --minimal     Shortcut for --theme minimal"
      echo "  --cyberpunk   Shortcut for --theme cyberpunk"
      echo "  --hacker      Shortcut for --theme hacker (ASCII-only)"
      echo ""
      exit 0
      ;;
    *) shift ;;
  esac
done

# Animated banner
show_banner() {
  clear
  echo ""
  echo -e "${C_MAGENTA}   _____ __        __            ___            ${C_CYAN} ____           ${C_RESET}"
  echo -e "${C_MAGENTA}  / ___// /_____ _/ /___  ______/ (_)___  ___  ${C_CYAN} / __ \_________ ${C_RESET}"
  echo -e "${C_MAGENTA}  \__ \/ __/ __ \`/ __/ / / / ___/ / / __ \/ _ \\${C_CYAN}/ /_/ / ___/ __ \\${C_RESET}"
  echo -e "${C_MAGENTA} ___/ / /_/ /_/ / /_/ /_/ (__  ) / / / / /  __/${C_CYAN} ____/ /  / /_/ /${C_RESET}"
  echo -e "${C_MAGENTA}/____/\__/\__,_/\__/\__,_/____/_/_/_/ /_/\___/${C_CYAN}_/   /_/   \____/ ${C_RESET}"
  echo ""
  echo -e "                    ${C_DIM}v${VERSION} - for Claude Code${C_RESET}"
  echo ""
}

# Theme previews
show_theme_preview() {
  local theme=$1
  echo -e "${C_BOLD}${C_WHITE}Preview:${C_RESET}"
  case $theme in
    powerline)
      echo -e "  ${C_BG_MAGENTA}${C_WHITE}  main ${C_RESET}${C_MAGENTA}${C_RESET} ${C_GREEN}✓${C_RESET} ${C_BG_BLUE}${C_WHITE} ~/project ${C_RESET}${C_BLUE}${C_RESET} ${C_DIM}◷ 14:30${C_RESET} ${C_CYAN}⏱ 23m${C_RESET}"
      ;;
    cyberpunk)
      echo -e "  ${C_CYAN}┃${C_RESET} ${C_MAGENTA}⟨main⟩${C_RESET} ${C_GREEN}✓${C_RESET} ${C_CYAN}┃${C_RESET} ${C_YELLOW}⌁${C_RESET} ~/project ${C_CYAN}┃${C_RESET} ${C_RED}⌚${C_RESET} 14:30 ${C_CYAN}┃${C_RESET} ${C_YELLOW}⚡${C_RESET} 23m ${C_CYAN}┃${C_RESET}"
      ;;
    minimal)
      echo -e "  ${C_MAGENTA}main${C_RESET} ${C_GREEN}✓${C_RESET} ${C_DIM}·${C_RESET} ~/project ${C_DIM}·${C_RESET} 14:30"
      ;;
    hacker)
      echo -e "  ${C_GREEN}[git:main|ok] [dir:~/project] [mem:2.1G] [t:23m]${C_RESET}"
      ;;
    retro)
      echo -e "  ${C_CYAN}░▒▓${C_RESET} ${C_WHITE}main${C_RESET} ${C_CYAN}▓▒░${C_RESET} ~/project ${C_MAGENTA}░▒▓${C_RESET} 14:30 ${C_MAGENTA}▓▒░${C_RESET}"
      ;;
    nyan)
      echo -e "  ${C_RED}█${C_YELLOW}█${C_GREEN}█${C_CYAN}█${C_BLUE}█${C_MAGENTA}█${C_RESET} main ✓ ${C_RED}═${C_YELLOW}═${C_GREEN}═${C_CYAN}═${C_RESET} ~/project ${C_YELLOW}★${C_RESET} 14:30 ${C_YELLOW}★${C_RESET}"
      ;;
  esac
  echo ""
}

# Interactive theme picker
pick_theme() {
  local themes=("powerline" "cyberpunk" "minimal" "hacker" "retro" "nyan")
  local descriptions=(
    "Nerd Font arrows & colors"
    "Futuristic brackets & symbols"
    "Clean & simple"
    "ASCII-only, terminal classic"
    "80s pixel vibes"
    "Rainbow fun"
  )
  local current=0

  # Check if interactive
  if [[ ! -t 0 ]]; then
    echo "powerline"
    return
  fi

  echo -e "${C_BOLD}${C_WHITE}Choose your theme:${C_RESET}"
  echo -e "${C_DIM}(Use arrow keys ↑↓ and Enter to select)${C_RESET}"
  echo ""

  while true; do
    # Show options
    for i in "${!themes[@]}"; do
      if [[ $i -eq $current ]]; then
        echo -e "  ${C_CYAN}▸${C_RESET} ${C_BOLD}${themes[$i]}${C_RESET} ${C_DIM}- ${descriptions[$i]}${C_RESET}"
      else
        echo -e "    ${C_DIM}${themes[$i]} - ${descriptions[$i]}${C_RESET}"
      fi
    done
    echo ""
    show_theme_preview "${themes[$current]}"

    # Read key
    read -rsn1 key
    case "$key" in
      A) ((current > 0)) && ((current--)) ;;  # Up arrow
      B) ((current < ${#themes[@]}-1)) && ((current++)) ;;  # Down arrow
      "") break ;;  # Enter
    esac

    # Clear for redraw
    for _ in $(seq 1 $((${#themes[@]} + 4))); do
      echo -e "\033[A\033[K"
    done
  done

  THEME="${themes[$current]}"
}

# Progress spinner
spinner() {
  local pid=$1
  local msg=$2
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${C_CYAN}${frames[$i]}${C_RESET} %s" "$msg"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.1
  done
  printf "\r  ${C_GREEN}✓${C_RESET} %s\n" "$msg"
}

# Main installation
install() {
  local target_dir
  local settings_file
  local hook_path

  if [[ "$INSTALL_MODE" == "global" ]]; then
    target_dir="$CONFIG_DIR"
    settings_file="$CLAUDE_SETTINGS"
    hook_path="~/.config/claude-statusline"
  else
    target_dir=".claude/hooks"
    settings_file=".claude/settings.json"
    hook_path=".claude/hooks"
  fi

  echo -e "${C_BOLD}Installing to: ${C_CYAN}${target_dir}${C_RESET}"
  echo ""

  # Create directory
  mkdir -p "$target_dir"
  mkdir -p "$(dirname "$settings_file")"

  # Copy and configure statusline
  {
    sleep 0.3
    cp "$TEMPLATE_DIR/statusline.sh" "$target_dir/statusline.sh"
    # Apply theme
    sed -i.bak "s/^THEME=.*/THEME=\"$THEME\"/" "$target_dir/statusline.sh" 2>/dev/null || true
    rm -f "$target_dir/statusline.sh.bak"
    chmod +x "$target_dir/statusline.sh"
  } &
  spinner $! "Installing statusline hook..."

  # Create session hook
  {
    sleep 0.2
    cat > "$target_dir/session-start.sh" << 'EOF'
#!/bin/bash
set -e
echo "$(date +%s)" > "${HOME}/.claude-session-start"
echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "Session timer started"}}'
EOF
    chmod +x "$target_dir/session-start.sh"
  } &
  spinner $! "Installing session hook..."

  # Create config file
  {
    sleep 0.2
    cat > "$target_dir/config.sh" << EOF
#!/bin/bash
# Statusline Pro Configuration
# Generated: $(date)

THEME="$THEME"
SEGMENTS=(git dir time session)
TIME_FORMAT="24h"
MAX_DIR_LENGTH=25
COLOR_SCHEME="dracula"
EOF
  } &
  spinner $! "Creating config file..."

  echo ""
  echo -e "${C_GREEN}${C_BOLD}✨ Installation complete!${C_RESET}"
  echo ""

  # Show final preview
  echo -e "${C_DIM}Your statusline:${C_RESET}"
  show_theme_preview "$THEME"

  # Settings instructions
  echo -e "${C_YELLOW}${C_BOLD}📝 Add to ${settings_file}:${C_RESET}"
  echo ""
  cat << SETTINGS
{
  "hooks": {
    "SessionStart": [{
      "hooks": [{"type": "command", "command": "${hook_path}/session-start.sh"}]
    }],
    "Notification": [{
      "hooks": [{"type": "command", "command": "${hook_path}/statusline.sh"}]
    }]
  }
}
SETTINGS
  echo ""
  echo -e "${C_DIM}Config: ${target_dir}/config.sh${C_RESET}"
  echo -e "${C_DIM}Docs:   statusline-pro --help${C_RESET}"
  echo ""
}

# Run
show_banner

# Interactive theme selection if no theme specified
if [[ "$THEME" == "powerline" ]] && [[ -t 0 ]]; then
  pick_theme
fi

install
