---
name: cf-doctor
description: Diagnose and fix claude-flow + ruvector integration issues
---

# /cf-doctor

Run comprehensive environment validation for claude-flow + ruvector integration. Diagnoses installation issues, missing packages, broken imports, and learning persistence problems.

## What to do

### Step 1: Check if cf-doctor CLI is available
```bash
npx cf-doctor --version 2>/dev/null || echo "NOT_INSTALLED"
```

### Step 2: If installed, run the diagnostic
```bash
npx cf-doctor --json
```

Parse the JSON and present results as a traffic-light table. For any RED or YELLOW checks, explain what's wrong using the knowledge base below.

### Step 3: If NOT installed, run manual checks

```bash
# Prerequisites
node --version    # Need >= 20
pnpm --version    # Need >= 8

# claude-flow
npx claude-flow --version 2>/dev/null

# MCP handshake
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | timeout 10 npx claude-flow mcp 2>/dev/null

# Directories
ls -la .claude-flow/{agents,memory,sessions,learning} 2>/dev/null || echo "MISSING"

# Database
node -e "require('better-sqlite3')" 2>/dev/null && echo "native" || node -e "require('sql.js')" 2>/dev/null && echo "wasm" || echo "NONE"
```

### Step 4: Auto-fix (if user asks)
```bash
npx cf-doctor --fix
```
Or manually:
```bash
mkdir -p .claude-flow/{agents,memory,sessions,learning}
npm install sql.js 2>/dev/null || echo "Install sql.js for database support"
```

## Knowledge Base: Known Integration Bugs

### CRITICAL: 3 Broken Direct Imports

These crash claude-flow when @ruvector WASM packages aren't installed:

1. **`v3/@claude-flow/neural/src/sona-integration.ts:13`**
   - Bug: `import { SonaEngine } from '@ruvector/sona'` — static import, no fallback
   - Fix: Convert to `await import('@ruvector/sona').catch(() => null)` + MockSonaEngine
   - Patch: `npx cf-doctor` includes `sona-integration.patch`

2. **`v3/@claude-flow/neural/index.ts`**
   - Bug: Re-exports from sona-integration without guard
   - Fix: Conditional re-export after sona-integration is patched

3. **`v3/@claude-flow/performance/src/examples/quick-test.ts`**
   - Bug: `import { FlashAttention } from '@ruvector/attention'`
   - Fix: Dynamic import with MockFlashAttention fallback

### CRITICAL: Version Mismatch

- **`npm/packages/agentic-integration/swarm-manager.ts`** calls `npx claude-flow@alpha hooks`
- But users have claude-flow v3 which uses `npx claude-flow mcp --hooks`
- Fix: `version-bridge.patch` adds auto-detection

### 8 Bridge Modules (These WORK)

The 8 bridge files in `v3/plugins/ruvector-upstream/` already use `.catch(() => null)`:
- hnsw.ts, learning.ts, sona.ts, attention.ts, gnn.ts, hyperbolic.ts, cognitive.ts, exotic.ts
- All have functional mock fallbacks — these are NOT bugs

### Learning Persistence (Missing Feature)

- Q-learning router holds Q-table in memory only — lost on exit
- SONA mock stores patterns in Map — lost on exit
- No episode recall for new agents
- Fix: Install cf-doctor for file-based persistence layer

### Database Layer

- `better-sqlite3` requires native compilation (may fail on some Linux)
- `sql.js` is the WASM fallback — always works but slower
- If neither: JSON file fallback works for basic usage

### Ubuntu/Linux-Specific Issues

- `timeout` command may not exist (use `coreutils` package)
- Node.js from apt may be outdated — use `nvm` or `fnm`
- pnpm not pre-installed — `npm install -g pnpm`
- Rust needed only for building @ruvector from source (optional)

## Troubleshooting Decision Tree

```
Problem: "Module not found: @ruvector/sona"
  → Apply sona-integration.patch OR install @ruvector/sona

Problem: "claude-flow hooks not working"
  → Check version: npx claude-flow --version
  → If v3.x: Apply version-bridge.patch to ruvector
  → If v2.x: Hooks should work, check PATH

Problem: "MCP handshake timeout"
  → Check: npx claude-flow --version (is it installed?)
  → Check: Is another process using stdin?
  → Try: npx claude-flow mcp < /dev/null (should return error JSON)

Problem: "Agent doesn't remember anything"
  → Install cf-doctor for learning persistence
  → Check: ls .claude-flow/learning/ (should have q-table.json, sona-patterns.json)
  → Check: ls .claude-flow/memory/episodes.json

Problem: "Database initialization failed"
  → Try: npm install better-sqlite3
  → Fallback: npm install sql.js
  → Last resort: Set DATABASE_DRIVER=json in config
```
