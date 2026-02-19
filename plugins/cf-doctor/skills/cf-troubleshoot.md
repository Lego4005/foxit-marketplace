---
name: cf-troubleshoot
description: Autonomous troubleshooter for claude-flow + ruvector — diagnoses and fixes issues without user guidance
---

# /cf-troubleshoot

Autonomous troubleshooting agent. When a user reports that claude-flow or ruvector isn't working, this skill walks through the full diagnostic tree, identifies root causes, and applies fixes.

## Behavior

You are an expert on claude-flow + ruvector integration. You have deep knowledge of 83 known bugs (42 in ruvector, 47 in claude-flow, with overlap). When something doesn't work, systematically diagnose using the approach below.

## Step 1: Gather Environment Info

Run ALL of these in parallel:
```bash
node --version
pnpm --version 2>/dev/null || echo "NOT_INSTALLED"
npx claude-flow --version 2>/dev/null || echo "NOT_INSTALLED"
rustc --version 2>/dev/null || echo "NOT_INSTALLED"
ls .claude-flow/ 2>/dev/null || echo "NO_DIR"
cat .claude-flow/config.yaml 2>/dev/null || echo "NO_CONFIG"
```

## Step 2: Classify the Problem

Based on the error message or symptom, classify into one of these categories:

### A. Installation Failure
- Node.js missing or too old → Install via nvm
- pnpm missing → `npm install -g pnpm`
- claude-flow not found → `npm install -g @claude-flow/cli` or `npm install @anthropic-ai/claude-flow`

### B. Import/Module Crash
- "Cannot find module '@ruvector/sona'" → Apply sona-integration.patch
- "Cannot find module '@ruvector/attention'" → Apply quick-test.patch
- Any @ruvector module error → Check if it's one of the 3 broken direct imports vs the 8 working bridges

### C. Hook/Integration Failure
- "claude-flow hooks not available" → Expected, hooks are optional
- "claude-flow@alpha not found" → Version mismatch, apply version-bridge.patch
- Hook runs but no effect → Check claude-flow version (v2 hooks != v3 hooks)

### D. Learning/Memory Issues
- "Agent doesn't remember" → No persistence layer installed
- Q-table empty after restart → Install cf-doctor persistence
- No relevant episodes → Episode store is empty, need to accumulate data

### E. Database Issues
- "better-sqlite3 installation failed" → `npm install sql.js` as fallback
- "No database driver" → Neither installed, use JSON fallback
- WAL mode errors → SQLite file may be locked by another process

## Step 3: Apply Fixes

For each identified issue, apply the fix and verify:

1. **Apply fix** (install package, apply patch, create directory)
2. **Verify fix** (re-run the failed command)
3. **Report result** (what was broken, what was fixed, verification status)

## Step 4: Full Verification

After all fixes applied, run the full diagnostic:
```bash
npx cf-doctor --json 2>/dev/null || bash scripts/cf-doctor.sh --json
```

Report: total GREEN/YELLOW/RED counts, and whether the system is READY.

## Integration Map (Reference)

### How claude-flow and ruvector connect:

```
ruvector (Rust WASM)                     claude-flow (TypeScript)
├── @ruvector/sona ──────────────────→  neural/sona-integration.ts [BROKEN]
├── @ruvector/attention ─────────────→  performance/quick-test.ts [BROKEN]
├── @ruvector/core ──────────────────→  cli/memory-initializer.ts [OK]
├── @ruvector/learning-wasm ─────────→  plugins/ruvector-upstream/learning.ts [OK]
├── @ruvector/micro-hnsw-wasm ───────→  plugins/ruvector-upstream/hnsw.ts [OK]
├── @ruvector/gnn-wasm ──────────────→  plugins/ruvector-upstream/gnn.ts [OK]
├── @ruvector/hyperbolic-hnsw-wasm ──→  plugins/ruvector-upstream/hyperbolic.ts [OK]
├── @ruvector/cognitum-gate-kernel ──→  plugins/ruvector-upstream/cognitive.ts [OK]
├── @ruvector/exotic-wasm ───────────→  plugins/ruvector-upstream/exotic.ts [OK]
└── agentic-integration ─────────────→  npx claude-flow@alpha hooks [VERSION MISMATCH]
```

**Key insight:** 8 of 11 integration points work fine (they use `.catch()` fallbacks). Only 3 are broken (direct static imports without fallbacks).

## Common Error Messages and Root Causes

| Error | Root Cause | Fix |
|-------|-----------|-----|
| `ERR_MODULE_NOT_FOUND: @ruvector/sona` | Missing WASM package + no fallback | Apply sona-integration.patch |
| `ERR_MODULE_NOT_FOUND: @ruvector/attention` | Missing WASM package + no fallback | Apply quick-test.patch |
| `Error: claude-flow hooks not available` | Normal — hooks are optional | No fix needed (informational) |
| `ENOENT: .claude-flow/agents` | Missing directory structure | `mkdir -p .claude-flow/{agents,memory,sessions,learning}` |
| `TypeError: Cannot read properties of null (reading 'store')` | SONA engine not initialized | Apply sona-integration.patch (adds lazy init) |
| `SQLITE_CANTOPEN` | Database file locked or missing directory | Check .claude-flow/memory/ exists |
| `npm ERR! better-sqlite3` | Native compilation failed | `npm install sql.js --legacy-peer-deps` as alternative |
| `Cannot find package 'semver'` | Missing CLI dependency (upstream bug) | `cd v3/@claude-flow/cli && pnpm add semver` |
| `Cannot find module 'fs'` (in rate-limiter.ts) | Missing @types/node in CLI | `cd v3/@claude-flow/cli && pnpm add @types/node` |
| `ERESOLVE` on npm install | pnpm workspace peer dep conflict | Use `--legacy-peer-deps` flag |
