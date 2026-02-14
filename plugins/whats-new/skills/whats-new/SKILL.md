---
description: Analyze Claude Code release notes - what changed, how it impacts you, and what actions to take
triggers:
  - whats-new
  - what's new
  - version changes
  - release notes
  - changelog
  - should i update
allowed-tools:
  - Bash
  - Read
  - WebFetch
---

# /whats-new - Claude Code Release Impact Analysis

Analyzes Claude Code release notes to understand what changed, how it impacts your workflow, and what actions you should take.

## Two Modes

1. **Post-Update Analysis** (default): "What changed since I last used Claude Code?"
2. **Pre-Update Preview**: "Should I update? What's new in the latest version?"

## Execution Steps (Follow in Order)

### Step 1: Get Version Info
```bash
# Current installed version
CURRENT=$(claude --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
echo "Current: $CURRENT"

# Previous version (what we updated from, if tracked)
PREVIOUS=$(cat ~/.claude/last-known-version 2>/dev/null || echo "unknown")
echo "Previous: $PREVIOUS"

# Latest available version (from GitHub)
LATEST=$(curl -s "https://api.github.com/repos/anthropics/claude-code/releases/latest" | jq -r '.tag_name' | sed 's/^v//')
echo "Latest: $LATEST"
```

### Step 2: Fetch Changelog from GitHub
```bash
# The official changelog - this is the source of truth
curl -s "https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md"
```

### Step 3: Determine Analysis Mode

**If CURRENT < LATEST** (user hasn't updated yet):
- Show: "Update Available: {CURRENT} to {LATEST}"
- Analyze what's NEW in versions they don't have yet
- Recommend: Should they update? (based on criticality)

**If PREVIOUS < CURRENT** (user just updated):
- Show: "Just Updated: {PREVIOUS} to {CURRENT}"
- Analyze what changed in versions they just received
- Recommend: Actions to take post-update

### Step 4: Filter to Relevant Versions
From the changelog, extract only versions between:
- **Post-update**: PREVIOUS to CURRENT
- **Pre-update**: CURRENT to LATEST

### Step 5: Categorize & Output
Parse changes into impact categories and generate action plan.

---

## Impact Categories

### CRITICAL - Immediate Action Required
- **Breaking Changes**: Incompatible behavior changes
- **Security Fixes**: Patched vulnerabilities
- **Deprecations**: Features being removed soon

### IMPORTANT - Review This Week
- **API/Tool Changes**: Modified parameters or behavior
- **Hook Changes**: New events, changed inputs/outputs
- **Permission Changes**: New permission requirements

### NEW FEATURES - Opportunities
- **New Commands**: Fresh slash commands
- **New Tools**: Additional capabilities
- **Performance**: Speed/memory improvements

### BUG FIXES - Awareness
- **Crashes Fixed**: Stability improvements
- **Behavior Fixes**: Corrected functionality

---

## Pre-Update Decision Helper

When showing available updates, include:

```markdown
## Should You Update?

**Update Now If:**
- Security fixes are included
- Bugs affecting you are fixed
- Features you want are added

**Wait If:**
- Breaking changes need preparation
- You want others to test first

**Verdict**: [RECOMMEND UPDATE / WAIT / CRITICAL - UPDATE NOW]
```

---

## Output Format

```markdown
# Claude Code: vX.Y.Z to vA.B.C

## CRITICAL (N items)
| Change | Impact | Action |
|--------|--------|--------|

## IMPORTANT (N items)
| Change | Impact | Recommendation |
|--------|--------|----------------|

## NEW FEATURES (N items)
| Feature | Benefit | How to Use |
|---------|---------|------------|

## FIXES (N items)
| Fix | What Was Broken |
|-----|-----------------|

## Recommended Actions
- [ ] Action 1
- [ ] Action 2

## Should You Update?
**Verdict**: [recommendation]
```
