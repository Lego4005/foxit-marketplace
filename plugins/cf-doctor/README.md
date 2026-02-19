# cf-doctor

Diagnose, fix, and maintain claude-flow + ruvector integration. Includes environment validator, auto-patching, learning persistence, and a knowledge base of 83 known bugs.

## Installation

```bash
/plugin install foxit-marketplace/cf-doctor
```

Or via npm:
```bash
npm install -g cf-doctor
npx cf-doctor
```

## Quick Start

```bash
/cf-doctor              # Run full diagnostic (traffic-light output)
/cf-troubleshoot        # Autonomous troubleshooter (AI-guided)
```

## Skills

### `/cf-doctor` — Environment Diagnostic

Runs comprehensive validation of your claude-flow + ruvector setup:

- **Prerequisites:** Node.js >= 20, pnpm >= 8, Rust (optional)
- **Installation:** @claude-flow/cli, MCP handshake, 8 @ruvector WASM packages
- **Infrastructure:** Directory structure, database driver, config file
- **Output:** GREEN/YELLOW/RED per check, with auto-fix suggestions

### `/cf-troubleshoot` — Autonomous Troubleshooter

When something isn't working, this skill walks through the full diagnostic tree:

1. Gathers environment info (parallel checks)
2. Classifies the problem (5 categories: install, import, hooks, learning, database)
3. Applies fixes and verifies each one
4. Runs full verification pass

## What It Knows

This plugin embeds a knowledge base covering:

- **83 known bugs** (42 in ruvector, 47 in claude-flow, with overlap)
- **11 integration points** between the two projects (8 working, 3 broken)
- **Common error messages** mapped to root causes and fixes
- **Platform-specific issues** (Ubuntu/Linux, macOS)
- **Version compatibility** (claude-flow v2 vs v3 hook syntax)

## Integration Map

```
ruvector (Rust WASM)                     claude-flow (TypeScript)
├── @ruvector/sona ──────────────────→  sona-integration.ts [NEEDS PATCH]
├── @ruvector/attention ─────────────→  quick-test.ts [NEEDS PATCH]
├── @ruvector/core ──────────────────→  memory-initializer.ts [OK]
├── @ruvector/learning-wasm ─────────→  learning.ts [OK]
├── @ruvector/micro-hnsw-wasm ───────→  hnsw.ts [OK]
├── @ruvector/gnn-wasm ──────────────→  gnn.ts [OK]
├── @ruvector/hyperbolic-hnsw-wasm ──→  hyperbolic.ts [OK]
├── @ruvector/cognitum-gate-kernel ──→  cognitive.ts [OK]
├── @ruvector/exotic-wasm ───────────→  exotic.ts [OK]
└── agentic-integration ─────────────→  hooks [VERSION BRIDGE]
```

## Patches Included

| Patch | Target | Fix |
|-------|--------|-----|
| `sona-integration.patch` | `@claude-flow/neural/src/sona-integration.ts` | Static import → dynamic + mock fallback |
| `neural-index.patch` | `@claude-flow/neural/index.ts` | Safe barrel re-export |
| `quick-test.patch` | `@claude-flow/performance/src/examples/quick-test.ts` | Static import → dynamic + mock |
| `version-bridge.patch` | `agentic-integration/swarm-manager.ts` | Auto-detect v2 vs v3 CLI syntax |

## Also Available As

- **npm package:** `npm install -g cf-doctor`
- **MCP server:** `npx cf-doctor --mcp` (5 tools: check, fix, recall, store, q-update)
- **Shell script:** `bash scripts/cf-doctor.sh` (standalone, no dependencies)
