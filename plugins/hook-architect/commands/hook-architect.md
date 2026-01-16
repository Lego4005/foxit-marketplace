# /hook-architect

Design perfect Claude Code hooks for any codebase through guided discovery, intelligent recommendations, and self-healing.

## Usage

```
/hook-architect              # Full guided workflow
/hook-architect [path]       # Analyze specific project
/hook-architect --review     # Review & grade existing hooks (A-F)
/hook-architect --update     # Check Anthropic docs for API updates
/hook-architect --heal       # Auto-fix common hook issues
/hook-architect --recipes    # List available hook recipes
```

## What This Command Does

When you run `/hook-architect`, it will:

1. **DISCOVER** - Analyze your codebase
   - Detect languages (TypeScript, Python, Rust, Go, etc.)
   - Find structure (monorepo, tests, migrations, CI/CD)
   - Identify existing tools (linters, formatters, test runners)
   - Check for existing hooks

2. **INTERVIEW** - Ask targeted questions
   - Pain points ("Ever accidentally edited .env?")
   - Workflow patterns ("Test before commit?")
   - Comfort level (start simple or go advanced)

3. **DESIGN** - Map requirements to hooks
   - Select appropriate hook types (PreToolUse, PostToolUse, etc.)
   - Design hook dependency graph
   - Estimate performance impact

4. **GENERATE** - Create the hooks
   - Generate hook implementations (shell or TypeScript)
   - Create configuration files
   - Update settings.json
   - Generate test harness

5. **TEST & REFINE** - Validate and iterate
   - Run hook tests
   - Profile performance
   - Suggest refinements

## Hook Progression Levels

### Level 1: Safety (Essential)
| Recipe | Purpose |
|--------|---------|
| `file-guardian` | Block edits to .env, lock files, generated code |
| `command-bouncer` | Block `rm -rf`, `DROP TABLE`, force pushes |
| `secret-detector` | Warn before committing secrets |

### Level 2: Productivity (Quality of Life)
| Recipe | Purpose |
|--------|---------|
| `auto-formatter` | Run prettier/eslint after changes |
| `test-watcher` | Run related tests when files change |
| `session-context` | Inject recent file changes at start |

### Level 3: Intelligence (Memory & Learning)
| Recipe | Purpose |
|--------|---------|
| `memory-inject` | Pull relevant past work on prompt |
| `episode-capture` | Record what was learned |
| `duplicate-detect` | Warn if similar work exists |

### Level 4: Orchestration (Advanced)
| Recipe | Purpose |
|--------|---------|
| `agent-router` | Route tasks to specialized agents |
| `output-compress` | Compress agent outputs for efficiency |
| `cost-tracker` | Track token/API costs |

## Self-Healing Capabilities

### Review Mode (`--review`)

Audits existing hooks and grades them A-F based on:
- **Security** (30%): Input validation, injection risks
- **Performance** (25%): Execution time, early exits
- **Reliability** (20%): Error handling, JSON format
- **Maintainability** (15%): Comments, modularity
- **Best Practices** (10%): Logging, timeouts

### Update Mode (`--update`)

Checks Anthropic's documentation for API changes:
- New hook types
- New input/output fields
- Deprecated features
- Security advisories

### Heal Mode (`--heal`)

Auto-fixes common issues:
- Missing `set -e`
- Unquoted variables
- Missing timeouts
- Deprecated field names
- Missing error handling

## Example Session

```
> /hook-architect

╔═══════════════════════════════════════════════════════════════╗
║   🪝  HOOK ARCHITECT                                          ║
╚═══════════════════════════════════════════════════════════════╝

Analyzing codebase...

DETECTED:
  Languages: TypeScript, Rust
  Structure: Monorepo (12 packages), Jest tests, GitHub Actions
  Tools: ESLint, Prettier, Vitest
  Existing hooks: 3 found

RECOMMENDATIONS:
  🔴 ESSENTIAL: file-guardian (protect .env files)
  🔴 ESSENTIAL: command-bouncer (block dangerous commands)
  🟡 RECOMMENDED: auto-formatter (eslint --fix after edits)
  🟡 RECOMMENDED: test-watcher (run vitest on change)

Would you like to:
1. Install essential hooks only
2. Install essential + recommended
3. Customize selection
4. Review existing hooks first

> 2

Generating hooks...
✅ Created hooks/01-file-guardian.sh
✅ Created hooks/02-command-bouncer.sh
✅ Created hooks/03-auto-formatter.sh
✅ Created hooks/04-test-watcher.sh
✅ Updated .claude/settings.json

Testing hooks...
✅ All hooks pass validation
✅ Average latency: 23ms (target: <50ms)

Done! Your hooks are ready. Run /hook-architect --review anytime.
```

## See Also

- `/hook-architect:review` - Audit existing hooks
- `/hook-architect:recipes` - Browse all available recipes
- [Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)
