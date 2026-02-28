# Claude Code Kit v2.0

A modular, battle-tested configuration kit for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Install the modules you need, skip the ones you don't.

Born from 74 review rounds across 8 production projects. Every rule, hook, and pattern earned its place through real bugs, real outages, and real fixes.

## Quick Start

```bash
git clone https://github.com/Oded-Ben-Yair/claude-code-kit.git
cd claude-code-kit
python3 install.py
```

The interactive installer walks you through module selection, handles dependencies, backs up your existing config, and validates the result.

## What's Inside

| Category | Count | Examples |
|----------|-------|---------|
| Hooks | 21 | Auto-router, debug-first, stop-verify, deploy-gate |
| Skills | 10 | /go, /ship-it, /pre-mortem, /create-diagram |
| Agents | 6 | code-judge, architect-planner, code-simplifier |
| Rules | 11 | Code quality, LangGraph patterns, RAG production |
| Checklists | 6 | Before deploy, before refactor, before bugfix |
| Docs | 5 | LangGraph safety/scalability/testing/domain, FastAPI streaming |

## Modules

### Required

| Module | Description |
|--------|-------------|
| **core** | Base CLAUDE.md with identity, hard rules, bug fix protocol, and settings template |

### Universal (recommended for all projects)

| Module | Description |
|--------|-------------|
| **session-management** | Session lifecycle: /go for recovery, /end-of-session for handover, compact/restore hooks |
| **code-quality** | Code standards, schema-first development, auto-formatting, file guards, 6 checklists |
| **engineering-discipline** | Systematic debugging, TDD, code review workflows, stop-verify enforcement |
| **orchestration** | Planning, parallel execution, Agent Teams, pre-mortem risk assessment |
| **productivity** | /ship-it anti-perfectionism, /create-diagram, auto-router, learning loops |

### Domain (install if relevant to your stack)

| Module | Description |
|--------|-------------|
| **devops** | Cloud deployment rules, deploy-gate hook, pipeline verification, commit discipline |
| **langgraph** | LangGraph production patterns: StateGraph, validation loops, guardrails, testing |
| **rag** | RAG production: per-item chunking, RRF reranking, idempotent ingestion, multi-tenant safety |
| **mcp-advanced** | Specialist agents for Gemini, Perplexity, Grok MCP servers |

## CLI Reference

```bash
# Interactive module selection (default)
python3 install.py

# Install everything
python3 install.py --all

# Install specific modules (dependencies auto-resolved)
python3 install.py --modules session-management,code-quality,orchestration

# Preview without making changes
python3 install.py --dry-run

# List available modules and install status
python3 install.py --list

# Remove a module
python3 install.py --remove code-quality

# Install to custom location
python3 install.py --claude-home /path/to/.claude

# Remove everything the kit installed
python3 uninstall.py --all

# Remove a specific module
python3 uninstall.py --module langgraph
```

## How It Works

1. **Module discovery** — Scans `modules/*/manifest.json` for available modules
2. **Dependency resolution** — Topological sort ensures dependencies install first
3. **Backup** — Creates `~/.claude.backup-{timestamp}/` before any changes
4. **File copy** — Each module's `files/` directory maps to `~/.claude/` structure
5. **Settings merge** — Hook arrays are *merged* (not overwritten) into `settings.json`
6. **CLAUDE.md assembly** — Base template + module sections injected at markers
7. **Path resolution** — `{CLAUDE_HOME}` placeholders replaced with actual paths
8. **Validation** — JSON validity, executable hooks, no unresolved placeholders

## Configuration

After installation:

1. **Edit `~/.claude/CLAUDE.md`** — Add your projects to the Project Map
2. **Review `~/.claude/settings.json`** — Adjust permissions and model settings
3. **Power User section** — Uncomment the bottom of CLAUDE.md for Opus model, Agent Teams, and production app tracking

## Upgrade Guide

```bash
cd claude-code-kit
git pull
python3 install.py --all  # Re-installs with automatic backup
```

The installer backs up your existing config before any changes. Your customizations in CLAUDE.md (project map, power user settings) are in sections outside module markers and will be preserved if you copy them back from the backup.

## Module Anatomy

Each module contains:

```
modules/example-module/
  manifest.json          # Metadata, dependencies, file list, settings merge
  claude_md_section.md   # Text injected into CLAUDE.md at module's marker
  files/                 # Files copied to ~/.claude/
    hooks/               #   -> ~/.claude/hooks/
    rules/               #   -> ~/.claude/rules/
    skills/              #   -> ~/.claude/skills/
    agents/              #   -> ~/.claude/agents/
    docs/                #   -> ~/.claude/docs/
    checklists/          #   -> ~/.claude/checklists/
```

## Contributing

### Adding a Module

1. Create `modules/your-module/manifest.json` with metadata and dependencies
2. Write `claude_md_section.md` — the text users see in their CLAUDE.md
3. Add files under `files/` using `{CLAUDE_HOME}` for path references
4. Test: `python3 install.py --modules your-module --dry-run`
5. Submit a PR

### Module Manifest Format

```json
{
  "name": "your-module",
  "version": "2.0.0",
  "description": "Short description",
  "when_to_use": "When to install this module",
  "type": "universal|domain",
  "depends_on": ["core"],
  "files": {
    "hooks": ["your-hook.sh"],
    "rules": ["your-rules.md"]
  },
  "settings_merge": {
    "hooks": {
      "PreToolUse": [
        {"matcher": "Bash", "hooks": [{"type": "command", "command": "{CLAUDE_HOME}/hooks/your-hook.sh", "timeout": 5}]}
      ]
    }
  },
  "claude_md_section": "your-module"
}
```

## Origin

Every rule and pattern in this kit has an `Origin:` annotation explaining *why* it exists — what bug it prevented, what outage it fixed, what review round discovered it. These annotations are the most valuable part of the kit. Read them.

## License

MIT
