# Recovery Guide - Recreate Claude Code Environment

## What's in this backup

```
backup/
  global-config/          # Your actual ~/.claude/ config files (secrets redacted)
    CLAUDE.md             # Master instructions (the real one, not the kit template)
    settings.json         # Full settings with hook configs, permissions, MCP servers
    settings.local.json   # Local overrides
    dot-claude.json       # ~/.claude.json (MCP server configs, API keys redacted)
    mcp-config.json       # ~/.config/claude-code/mcp-config.json
  memory-mcp/
    knowledge-graph-full-dump.json  # ALL Memory MCP entities (378K chars)
    MEMORY.md             # Auto-memory file
  sessions/
    session-index.json    # Full session history (3335 lines, all projects)
  project-configs/        # Per-project .claude/ directories
    <project>/
      CLAUDE.md           # Project-specific instructions
      status.json         # Last known project state
      decisions.log       # Architectural decision log
      handover-*.md       # Session handover documents
  scripts/
    export-kit-generator.py  # The generator that builds the public kit
    validate-kit.sh          # Kit validator
  configs/
    azure-compliance-rules.json  # Compliance audit config
```

## Step 1: Install the Public Kit

```bash
git clone https://github.com/Oded-Ben-Yair/claude-code-kit.git
cd claude-code-kit
chmod +x install.sh
./install.sh
```

This sets up the base structure in `~/.claude/`.

## Step 2: Restore Your Actual Configs

```bash
# Restore the real CLAUDE.md (not the GCP-transformed one)
cp backup/global-config/CLAUDE.md ~/.claude/CLAUDE.md

# Restore settings (has your hook configurations)
cp backup/global-config/settings.json ~/.claude/settings.json
cp backup/global-config/settings.local.json ~/.claude/settings.local.json

# Restore MCP configs (you'll need to re-add API keys)
cp backup/global-config/dot-claude.json ~/.claude.json
cp backup/global-config/mcp-config.json ~/.config/claude-code/mcp-config.json
# IMPORTANT: Search for REDACTED and replace with your actual API keys
```

## Step 3: Restore Memory MCP

The knowledge graph dump is in `backup/memory-mcp/knowledge-graph-full-dump.json`.
To reload entities into Memory MCP:

```bash
# Parse the JSON and use mcp__memory__create_entities to reload
# The dump contains all entities, relations, and observations
# You'll need to process this in a Claude Code session
```

Or just tell Claude: "Load all entities from backup/memory-mcp/knowledge-graph-full-dump.json into Memory MCP"

## Step 4: Restore Project Configs

```bash
# For each project you want to restore:
for project in backup/project-configs/*/; do
  name=$(basename "$project")
  target=~/projects/$name/.claude/
  mkdir -p "$target"
  cp -r "$project"/* "$target/"
  echo "Restored: $name"
done
```

## Step 5: Re-add API Keys

Keys that were redacted (you need to get new ones):
- `XAI_API_KEY` (Grok) - get from x.ai console
- `PERPLEXITY_API_KEY` - get from perplexity.ai
- Azure AI Foundry keys - get from Azure Key Vault (kv-seekapa-apps)
- Database passwords - get from Azure Key Vault

## Step 6: Verify

```bash
# Start Claude Code and verify:
# 1. Hooks load (session-start shows context)
# 2. MCP servers connect (memory, grok, perplexity)
# 3. Skills are available (/go, /end-of-session, etc.)
# 4. Rules are loaded (check CLAUDE.md sections)
```

## Projects Map

| Project | Purpose | Key Tech |
|---------|---------|----------|
| sentimark | Polymarket prediction platform | Next.js, Azure Functions, PostgreSQL |
| qc-call-analyzer | Call quality scoring | Python, Azure Functions, Whisper |
| axia-seekapa-cs-agents | Customer service chatbot | LangGraph, FastAPI |
| seekapa-training-platform | Sales training | Azure Functions, PostgreSQL |
| seekapa-compliance-exam | Compliance testing | Azure Functions |
| phone-spam-checker | Spam detection | Azure App Service |
| hey-seven | Casino concierge AI | LangGraph, RAG, Cloud Run |
| real-time | Real-time monitoring | FastAPI, WebSocket |
| automation-fabric | Workflow automation | Python |
| sales-agents | Voice sales agents | ElevenLabs, Arabic TTS |
| linkedin | LinkedIn automation | Playwright, Edge |
| tech4all | Tech4All project | Various |
| aeo | Answer Engine Optimization | SEO/AEO analysis |

## Important Notes

- All database passwords were REDACTED before pushing to GitHub
- API keys were REDACTED - you need fresh ones
- Azure DevOps PAT needs rotation anyway (was expiring)
- The memory-mcp dump has ALL your cross-session knowledge
- Session index has your full work history across all projects
