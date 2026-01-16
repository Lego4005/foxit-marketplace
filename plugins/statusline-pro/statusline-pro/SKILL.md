---
description: Beautiful, informative statusline for Claude Code - git info, session time, and more
triggers: [statusline-pro, statusline, status]
---

# Statusline Pro

A beautiful, customizable statusline for Claude Code that shows git info, session duration, and more.

## What You Get

```
 main ✓ │ ▸ ~/my-project │ ◷ 14:30 │ ⏱ 23m
```

| Segment | Shows |
|---------|-------|
|  main | Current git branch |
| ✓ or ● | Clean or dirty working tree |
| ↑2 ↓1 | Commits ahead/behind remote |
| ▸ ~/path | Current directory (shortened) |
| ◷ 14:30 | Current time |
| ⏱ 23m | Session duration |

## Quick Install

```bash
# From plugin directory
./scripts/install-statusline.sh
```

Then add to `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {"type": "command", "command": ".claude/hooks/session-start.sh"}
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {"type": "command", "command": ".claude/hooks/statusline.sh"}
        ]
      }
    ]
  }
}
```

## Customization

Edit `.claude/hooks/statusline.sh` to customize:

```bash
# Show/hide segments
SHOW_GIT=true
SHOW_TIME=true
SHOW_DIR=true
SHOW_SESSION=true

# Directory length
MAX_DIR_LENGTH=30

# Change icons
ICON_BRANCH=""      # Git branch icon
ICON_CLEAN="✓"       # Clean repo
ICON_DIRTY="●"       # Uncommitted changes
ICON_AHEAD="↑"       # Commits ahead
ICON_BEHIND="↓"      # Commits behind
ICON_CLOCK="◷"       # Time icon
ICON_FOLDER="▸"      # Directory icon
```

## Themes

### Minimal
```bash
SHOW_GIT=true
SHOW_TIME=false
SHOW_DIR=true
SHOW_SESSION=false
```
Result: ` main ✓ │ ▸ ~/project`

### Full Info
```bash
SHOW_GIT=true
SHOW_TIME=true
SHOW_DIR=true
SHOW_SESSION=true
```
Result: ` main ✓ ↑2 │ ▸ ~/project │ ◷ 14:30 │ ⏱ 1h23m`

### Git Only
```bash
SHOW_GIT=true
SHOW_TIME=false
SHOW_DIR=false
SHOW_SESSION=false
```
Result: ` main ● ↑2 ↓1`

## How It Works

1. **SessionStart hook** - Records when your session begins
2. **Notification hook** - Updates the statusline periodically
3. **Git integration** - Reads from local git repo (no external calls)
4. **Zero dependencies** - Pure bash, works everywhere

## Troubleshooting

### Icons not showing?
Your terminal might not support Unicode. Use ASCII alternatives:

```bash
ICON_BRANCH="git:"
ICON_CLEAN="ok"
ICON_DIRTY="*"
ICON_AHEAD="+"
ICON_BEHIND="-"
ICON_CLOCK="@"
ICON_FOLDER=">"
```

### Session time always shows 0m?
Make sure the SessionStart hook is configured and runs when Claude Code starts.

### Not seeing the statusline?
1. Check hooks are in `.claude/hooks/` and executable
2. Verify `.claude/settings.json` has the hook configuration
3. Run `claude --debug` to see hook execution

## Requirements

- Claude Code 2.1.x+
- Bash 4.0+
- Git (for git info segments)
