# whats-new Plugin for Claude Code

**Automatic version change detection with intelligent release notes analysis.**

Never miss an important Claude Code update again! This plugin:
- Notifies you when Claude Code updates
- Analyzes changes and categorizes by impact
- Recommends actions you should take
- Highlights features worth exploring

## Installation

### From Marketplace
```bash
claude /plugin install whats-new
```

### Manual Installation
Copy this folder to `~/.claude/plugins/local/whats-new/`

## How It Works

```
SESSION START
      |
      v
version-watch.sh hook
  Compare: ~/.claude/last-known-version vs current
      |
      +-----------+-----------+
      |                       |
      v                       v
Same Version           Version Changed!
(silent)               "Updated: X to Y"
                       "Run /whats-new"
                              |
                              v
                       User runs /whats-new
                         CRITICAL: 0
                         IMPORTANT: 2
                         NEW: 5
                         FIXES: 8
                         Actions: [...]
```

## Usage

### Automatic Notification
When Claude Code updates, you'll see:
```
Claude Code updated: 2.1.15 to 2.1.16 | Run /whats-new to see what changed
```

### Manual Analysis
```
/whats-new
```

### Check Current Version
```bash
claude --version
cat ~/.claude/last-known-version
```

## Impact Categories

| Category | Meaning | Action |
|----------|---------|--------|
| CRITICAL | Breaking/security changes | Immediate action |
| IMPORTANT | Workflow-affecting changes | Review this week |
| NEW | New features/capabilities | Explore when ready |
| FIXES | Bug fixes | Awareness |

## Plugin Components

| File | Purpose |
|------|---------|
| `hooks/version-watch.sh` | SessionStart hook - detects version changes |
| `hooks/fetch-changelog.sh` | Downloads and caches GitHub changelog with ETags |
| `hooks/build-profile.sh` | Scans your Claude Code setup for personalized analysis |
| `hooks/actions-tracker.sh` | Tracks completed/pending/skipped action items |
| `skills/whats-new/SKILL.md` | The /whats-new skill definition |

## Configuration

The plugin stores version tracking in:
```
~/.claude/last-known-version
```

To reset tracking (will re-notify on next session):
```bash
rm ~/.claude/last-known-version
```

## Requirements

- Claude Code 2.0.0 or later
- Bash shell
- `jq` and `curl` (for changelog fetching and profile building)

## License

MIT

## Contributing

Issues and PRs welcome at https://github.com/Lego4005/foxit-marketplace
