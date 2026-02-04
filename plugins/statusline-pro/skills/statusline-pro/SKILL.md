---
description: Beautiful, informative statusline for Claude Code - git info, session time, system stats & more
triggers: [statusline-pro, statusline, status]
---

# ✨ Statusline Pro

> Level up your Claude Code experience with a stunning, informative statusline.

```
╭──────────────────────────────────────────────────────────────────────────────╮
│  main ✓ │ ▸ ~/my-project │ 󰍛 2.1G │ ◷ 14:30 │ ⏱ 23m │  98%           │
╰──────────────────────────────────────────────────────────────────────────────╯
```

## 🚀 One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/anthropics/claude-code/main/statusline-pro/install.sh | bash
```

**Or clone and run:**

```bash
git clone https://github.com/anthropics/claude-code-plugins.git
cd claude-code-plugins/statusline-pro && ./scripts/install-statusline.sh
```

## 🎨 Themes

Pick your style with `--theme`:

### 🔥 Powerline (requires Nerd Fonts)

```
  main  ✓    ~/project    14:30   23m    2.1G
```

### ⚡ Cyberpunk

```
┃ ⟨main⟩ ✓ ┃ ⌁ ~/project ┃ ⌚ 14:30 ┃ ⚡ 23m ┃
```

### 🌙 Minimal

```
main ✓ · ~/project · 14:30
```

### 🤖 Hacker

```
[git:main|✓] [dir:~/project] [mem:2.1G] [⏱23m]
```

### 🎮 Retro

```
░▒▓ main ▓▒░ ~/project ░▒▓ 14:30 ▓▒░
```

### 🌈 Nyan

```
█▀▀ main ▀▀█ ═══ ~/project ═══ ★ 14:30 ★
```

## 📊 Available Segments

| Segment     | Icon | Description                    |
| ----------- | ---- | ------------------------------ |
| **git**     |      | Branch, status, ahead/behind   |
| **dir**     | ▸    | Smart-shortened directory path |
| **time**    | ◷    | Current time (12h or 24h)      |
| **session** | ⏱    | How long you've been coding    |
| **memory**  | 󰍛    | System memory usage            |
| **cpu**     |      | CPU load percentage            |
| **battery** |      | Battery level (laptops)        |
| **weather** |      | Current temp (needs API key)   |
| **spotify** |      | Now playing track              |

## ⚙️ Configuration

After install, edit `~/.config/claude-statusline/config.sh`:

```bash
# ═══════════════════════════════════════════
#  STATUSLINE PRO CONFIG
# ═══════════════════════════════════════════

# Theme: powerline, cyberpunk, minimal, hacker, retro, nyan
THEME="powerline"

# Segments to show (order matters!)
SEGMENTS=(git dir memory time session)

# Time format: 12h or 24h
TIME_FORMAT="24h"

# Directory shortening
MAX_DIR_LENGTH=25
SHOW_FULL_HOME=false    # ~/Code vs /Users/you/Code

# Colors: dracula, nord, gruvbox, monokai, solarized, catppuccin
COLOR_SCHEME="dracula"

# Separators (for powerline theme)
SEP_LEFT=""
SEP_RIGHT=""

# Refresh rate in seconds (for dynamic segments)
REFRESH_RATE=30

# ═══════════════════════════════════════════
#  OPTIONAL INTEGRATIONS
# ═══════════════════════════════════════════

# OpenWeather API (free tier works)
WEATHER_API_KEY=""
WEATHER_CITY="San Francisco"
WEATHER_UNITS="imperial"  # imperial or metric

# Show warnings when...
WARN_MEMORY_ABOVE=80      # Memory usage %
WARN_SESSION_AFTER=120    # Minutes
```

## 🎯 Quick Examples

**Developer Focus (git + session only):**

```bash
SEGMENTS=(git session)
#  main ✓ │ ⏱ 1h23m
```

**System Monitor:**

```bash
SEGMENTS=(cpu memory battery)
#  12% │ 󰍛 8.2G/16G │  87%
```

**Full Dashboard:**

```bash
SEGMENTS=(git dir memory cpu time session)
#  main ✓ │ ▸ ~/project │ 󰍛 2.1G │  5% │ ◷ 14:30 │ ⏱ 23m
```

## 🛠 Commands

```bash
# Preview a theme without installing
statusline-pro preview cyberpunk

# Switch theme
statusline-pro theme powerline

# Toggle a segment
statusline-pro toggle memory

# Show current config
statusline-pro config

# Update to latest
statusline-pro update
```

## 🔧 Manual Setup

If you prefer manual installation:

1. **Copy hooks to your project:**

```bash
cp templates/statusline.sh ~/.config/claude-statusline/
cp templates/session-start.sh ~/.config/claude-statusline/
chmod +x ~/.config/claude-statusline/*.sh
```

2. **Add to `~/.claude/settings.json`:**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/claude-statusline/session-start.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.config/claude-statusline/statusline.sh"
          }
        ]
      }
    ]
  }
}
```

## 🎨 Color Schemes

| Scheme          | Preview                      |
| --------------- | ---------------------------- |
| **Dracula**     | 🟣 Purple/pink/cyan on dark  |
| **Nord**        | 🔵 Cool blues and teals      |
| **Gruvbox**     | 🟤 Warm retro browns/oranges |
| **Monokai**     | 🟢 Vibrant greens/pinks      |
| **Solarized**   | 🟡 Classic tan/blue          |
| **Catppuccin**  | 🌸 Soft pastels              |
| **Tokyo Night** | 🌃 Purple/blue neon          |

## ❓ Troubleshooting

### Icons look weird?

Install a [Nerd Font](https://www.nerdfonts.com/) or switch to ASCII theme:

```bash
statusline-pro theme hacker  # Uses ASCII-only icons
```

### Not seeing the statusline?

```bash
# Test the hook directly
~/.config/claude-statusline/statusline.sh

# Check Claude sees it
claude --debug
```

### Session time stuck at 0m?

```bash
# Manually trigger session start
~/.config/claude-statusline/session-start.sh
```

### CPU/Memory not showing?

These use system commands (`top`, `free`, `vm_stat`). Make sure they're available:

```bash
# macOS
which vm_stat

# Linux
which free
```

## 📋 Requirements

- **Claude Code** 2.1.x or later
- **Bash** 4.0+ (ships with macOS/Linux)
- **Git** (for git segments)
- **Nerd Font** (optional, for fancy icons)

## 🤝 Contributing

Got a cool theme? Submit a PR!

```bash
# Create your theme
cp themes/minimal.sh themes/mytheme.sh
# Edit and test
statusline-pro preview mytheme
```

---

<p align="center">
  <i>Made with ☕ for the Claude Code community</i>
</p>
