# FoxIt Marketplace

Curated Claude Code plugins for power users. Hooks, agents, skills, and orchestration tools built by the FoxFlow team.

## Quick Start

```bash
# Add FoxIt Marketplace as a plugin source
/plugin marketplace add https://github.com/foxflow/foxit-marketplace

# Browse available plugins
/plugin search foxit

# Install a plugin
/plugin install hook-architect
```

## Available Plugins

| Plugin | Category | Description |
|--------|----------|-------------|
| **[hook-architect](plugins/hook-architect)** | Development | Design perfect hooks with guided discovery, self-healing, and auto-updates |
| **foxit-orchestrator** | Development | Multi-agent orchestration with FDAG learning and automatic swarm selection |
| **truth-manifesto** | Testing | Anti-hallucination framework with 15-step validation and falsification gates |
| **ultrathink** | Productivity | Deep sequential thinking with revision and branching |
| **goalie** | Productivity | GOAP-powered research with Perplexity, citations, and multi-agent planning |
| **foxscan** | Monitoring | Project health scanner - find gaps, rate importance, surface tech debt |

## Plugin Structure

Each plugin follows the [official Claude Code plugin format](https://docs.anthropic.com/en/docs/claude-code/plugins):

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json      # Plugin metadata
├── commands/            # Slash commands
├── agents/              # Specialized agents
├── skills/              # Agent skills
├── hooks/               # Event handlers
└── README.md            # Documentation
```

## Installation Methods

### From FoxIt Marketplace
```bash
/plugin marketplace add https://github.com/foxflow/foxit-marketplace
/plugin install <plugin-name>
```

### Direct from GitHub
```bash
/plugin install github:foxflow/foxit-marketplace/plugins/<plugin-name>
```

### Local Development
```bash
git clone https://github.com/foxflow/foxit-marketplace
/plugin install ./foxit-marketplace/plugins/<plugin-name>
```

## Creating Your Own Plugins

Use our plugin-dev tools:

```bash
# Install the plugin development kit
/plugin install foxit-marketplace/plugin-dev

# Create a new plugin
/plugin-dev:create my-awesome-plugin

# Validate your plugin
/plugin-dev:validate

# Test locally
/plugin install ./my-awesome-plugin
```

## Marketplace Schema

Our `marketplace.json` follows the [official Anthropic schema](https://anthropic.com/claude-code/marketplace.schema.json):

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "foxit-marketplace",
  "description": "Curated Claude Code plugins",
  "owner": {
    "name": "FoxFlow",
    "email": "plugins@foxflow.dev"
  },
  "plugins": [
    {
      "name": "hook-architect",
      "description": "Design perfect Claude Code hooks",
      "version": "1.0.0",
      "author": { "name": "FoxFlow" },
      "source": "./plugins/hook-architect",
      "category": "development"
    }
  ]
}
```

## Categories

| Category | Description |
|----------|-------------|
| `development` | Code quality, language servers, SDKs |
| `productivity` | Task management, automation, workflows |
| `testing` | Test frameworks, validation, quality gates |
| `monitoring` | Health checks, analytics, observability |
| `security` | Security scanning, vulnerability detection |
| `deployment` | CI/CD, cloud platforms, infrastructure |

## Contributing

We welcome contributions! To add your plugin:

1. Fork this repository
2. Create your plugin in `plugins/your-plugin-name/`
3. Follow the [plugin structure](#plugin-structure)
4. Add your plugin to `marketplace.json`
5. Submit a pull request

### Plugin Requirements

- [ ] Valid `plugin.json` in `.claude-plugin/`
- [ ] Comprehensive `README.md`
- [ ] At least one command, agent, skill, or hook
- [ ] MIT or compatible license
- [ ] No malicious code or security vulnerabilities
- [ ] Follows Claude Code best practices

## Support

- **Issues**: [GitHub Issues](https://github.com/foxflow/foxit-marketplace/issues)
- **Discussions**: [GitHub Discussions](https://github.com/foxflow/foxit-marketplace/discussions)
- **Email**: plugins@foxflow.dev

## License

MIT - See individual plugins for their licenses.

---

**FoxIt Marketplace** - Extending Claude Code, one plugin at a time. 🦊

*Built with ❤️ by [FoxFlow](https://foxflow.dev)*
