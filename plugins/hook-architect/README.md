# Hook Architect

Design perfect Claude Code hooks for any codebase through guided discovery, intelligent recommendations, and self-healing.

## Installation

```bash
/plugin install foxit-marketplace/hook-architect
```

Or add to your marketplace sources:
```bash
/plugin marketplace add https://github.com/foxflow/foxit-marketplace
/plugin install hook-architect
```

## Quick Start

```bash
/hook-architect              # Full guided workflow
/hook-architect --review     # Audit existing hooks (A-F grades)
/hook-architect --update     # Check for Claude Code API updates
/hook-architect --heal       # Auto-fix common issues
/hook-architect --recipes    # Browse hook templates
```

## What It Does

```
┌─────────────────────────────────────────────────────────────────┐
│                    HOOK ARCHITECT WORKFLOW                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. DISCOVER        2. INTERVIEW       3. DESIGN                │
│  ┌──────────┐      ┌──────────┐       ┌──────────┐             │
│  │ Analyze  │ ──▶  │ Ask Smart│ ──▶   │ Map to   │             │
│  │ Codebase │      │ Questions│       │ Hook Types│             │
│  └──────────┘      └──────────┘       └──────────┘             │
│                                              │                   │
│  5. SELF-HEAL      4. GENERATE              ▼                   │
│  ┌──────────┐      ┌──────────┐       ┌──────────┐             │
│  │ Monitor  │ ◀──  │ Create   │ ◀──   │ Test &   │             │
│  │ & Fix    │      │ Hooks    │       │ Refine   │             │
│  └──────────┘      └──────────┘       └──────────┘             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Hook Progression

Start simple, evolve over time:

### Level 1: Safety (Essential)
- **file-guardian** - Block edits to .env, lock files, generated code
- **command-bouncer** - Block `rm -rf`, `DROP TABLE`, force pushes
- **secret-detector** - Warn before committing secrets

### Level 2: Productivity
- **auto-formatter** - Run prettier/eslint after changes
- **test-watcher** - Run related tests when files change
- **session-context** - Inject recent changes at session start

### Level 3: Intelligence
- **memory-inject** - Pull relevant past work on prompt
- **episode-capture** - Record what was learned
- **duplicate-detect** - Warn if similar work exists

### Level 4: Orchestration
- **agent-router** - Route tasks to specialized agents
- **output-compress** - Compress agent outputs
- **cost-tracker** - Track token/API costs

## Self-Healing

### Review Mode
Audits hooks and grades them A-F:

```
┌─────────────────────────────────────────────┐
│            HOOK REVIEW REPORT               │
├──────────────────┬───────┬──────────────────┤
│ Hook             │ Grade │ Issues           │
├──────────────────┼───────┼──────────────────┤
│ file-guardian.sh │  A    │ None             │
│ auto-format.sh   │  B+   │ Missing timeout  │
│ legacy-hook.sh   │  F    │ Uses eval        │
├──────────────────┴───────┴──────────────────┤
│ Overall: B-  │  Auto-fixable: 3            │
└─────────────────────────────────────────────┘
```

### Update Mode
Checks Anthropic docs for API changes:
- New hook types
- Deprecated fields
- Security advisories

### Heal Mode
Auto-fixes common issues:
- Missing `set -e`
- Unquoted variables
- Deprecated field names
- Missing error handling

## Generated Output

```
.claude/
├── hooks/
│   ├── 01-file-guardian.sh
│   ├── 02-command-bouncer.sh
│   ├── 03-auto-formatter.sh
│   └── config/
│       └── file-guardian.json
├── settings.json  (updated)
└── hooks-report.md
```

## Commands

| Command | Description |
|---------|-------------|
| `/hook-architect` | Full guided workflow |
| `/hook-architect:review` | Audit and grade hooks |
| `/hook-architect:update` | Check for API updates |
| `/hook-architect:heal` | Auto-fix issues |
| `/hook-architect:recipes` | Browse templates |

## Requirements

- Claude Code 1.0.0+
- Bash (for shell hooks)
- jq (recommended for JSON parsing)

## License

MIT

## Author

[FoxFlow](https://github.com/foxflow) - Building tools for AI-powered development.

---

Part of the [FoxIt Marketplace](https://github.com/foxflow/foxit-marketplace) - Curated Claude Code plugins for power users.
