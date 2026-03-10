# Claude Code Kit

Production-grade Claude Code environment with hooks, rules, MCP servers, and skills.

## Quick Start

```bash
git clone <this-repo> ~/claude-code-kit
cd ~/claude-code-kit
bash install.sh
```

## What's Included

- **CLAUDE.md** -- Master instruction file with 13 hard rules
- **Rules** (${RULE_COUNT} files) -- Code quality, deployment, database safety, orchestration patterns
- **Hooks** (${HOOK_COUNT} hooks) -- Pre/post tool validation, security gates, auto-formatting
- **Skills** -- Reusable workflows (session management, diagrams, frontend, etc.)
- **MCP Servers** -- Multi-provider AI gateway, Playwright browser control
- **Scripts** -- Utility scripts for CI, cleanup, diagram generation
- **Docs** -- Domain-specific guides (Cloud Run, ML, streaming, etc.)
- **Checklists** -- Pre-action safety checklists

## Customization

1. Edit `core/CLAUDE.md` to add your projects to the Project Map
2. Configure MCP server API keys in your environment
3. Add project-specific rules to `core/rules/`

## Generated

This kit was generated from a production Claude Code environment using `export-kit-generator.py`.
Generated: ${GENERATED_DATE}
