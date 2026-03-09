# Migration Guide — Claude Code Kit v9.2 + GCP Stack

This guide covers setting up Claude Code on a new machine with GCP infrastructure.

## Prerequisites

- Claude Code CLI installed
- `gcloud` CLI installed and authenticated
- Node.js 22+ (for MCP servers)
- Python 3.12+

## Step 1: Clone and Install Core

```bash
git clone https://github.com/oded-ben-yair/claude-code-kit.git
cd claude-code-kit
bash install.sh
```

This copies `core/` files into `~/.claude/` (rules, hooks, scripts, skills, docs, agents).

## Step 2: Restore Memory MCP (Cross-Session Knowledge)

```bash
mkdir -p ~/.claude-memory
cp migration/memory-mcp/memory.json ~/.claude-memory/memory.json
```

Then configure the Memory MCP server to use this file:
- Set `MEMORY_FILE_PATH=~/.claude-memory/memory.json` in your MCP config

## Step 3: Restore Project Memories

```bash
# Copy all project memories
cp -r migration/project-memories/ ~/.claude/projects/
```

Each project memory contains session history, learnings, and round tracking.

## Step 4: Restore Team Memories

```bash
cp -r migration/teams/ ~/.claude/teams/
```

Key team memories:
- `r101-paradigm-shift/` — Hey Seven behavioral paradigm shift (gold traces, team context)
- `r97-audit/` — Hey Seven audit results
- `hey-seven-v2-phase1/` — Phase 1 implementation notes

## Step 5: Restore Commands and Schemas

```bash
cp -r migration/commands/ ~/.claude/commands/
cp -r migration/schemas/ ~/.claude/schemas/
```

## Step 6: Restore Config Files

```bash
cp migration/model-allocation.yml ~/.claude/model-allocation.yml
cp migration/capabilities-registry.json ~/.claude/capabilities-registry.json
```

## Step 7: GCP Authentication

```bash
# Authenticate with Google Cloud
gcloud auth application-default login

# Set project
gcloud config set project hey-seven

# Verify
gcloud config list
```

## Step 8: Environment Variables

Create `~/.env.secrets` (or add to `.bashrc`):

```bash
# Google Developer Knowledge MCP
export GOOGLE_DEVELOPER_KNOWLEDGE_API_KEY="<regenerate>"

# Google Cloud
export GOOGLE_CLOUD_PROJECT="hey-seven"
export GOOGLE_CLOUD_LOCATION="us-central1"

# XAI (Grok)
export XAI_API_KEY="<regenerate>"

# LunarCrush
export LUNARCRUSH_API_KEY="<regenerate>"

# Perplexity
export PERPLEXITY_API_KEY="<regenerate>"
```

## Step 9: MCP Servers

```bash
# Install dependencies for each MCP server
for dir in ~/.claude/mcp-servers/*/; do
    if [ -f "$dir/package.json" ]; then
        (cd "$dir" && npm install)
    fi
    if [ -f "$dir/requirements.txt" ]; then
        (cd "$dir" && pip install -r requirements.txt)
    fi
done
```

## Step 10: Verify Installation

```bash
# Check Claude Code loads rules
claude --version

# Check GCP skills are available
ls ~/.claude/skills/gcp-*/SKILL.md

# Check GCP docs are available
ls ~/.claude/docs/vertex-ai-agent-engine.md
ls ~/.claude/docs/cloud-run-patterns.md
ls ~/.claude/docs/vertex-ai-rag.md
ls ~/.claude/docs/gcp-secret-manager.md
```

## GCP Quick Reference

| Task | Command |
|------|---------|
| Deploy to Cloud Run | `/gcp-deploy` skill |
| Check resource status | `/gcp-status` skill |
| Rollback deployment | `/gcp-rollback` skill |
| Deploy LangGraph agent | See `~/.claude/docs/vertex-ai-agent-engine.md` |
| Manage secrets | See `~/.claude/docs/gcp-secret-manager.md` |
| RAG with Vector Search | See `~/.claude/docs/vertex-ai-rag.md` |
| GCP/Firebase docs | `google-developer-knowledge` MCP |

## Azure -> GCP Stack Mapping

| Azure | GCP |
|-------|-----|
| Azure Functions | Vertex AI Agent Engine (LangGraph) / Cloud Run (FastAPI) |
| Key Vault | Secret Manager |
| Azure DevOps Pipelines | Cloud Build + GitHub triggers |
| Azure AI Foundry | Vertex AI (Gemini 3 Pro) |
| Azure PostgreSQL | Cloud SQL PostgreSQL |
| Azure Blob Storage | Cloud Storage |
| Azure Static Web Apps | Firebase Hosting / Cloud Run |

## Hey Seven Specific

The Hey Seven project code is NOT in this repo. To continue:

1. Clone the hey-seven repo to `~/projects/hey-seven/`
2. The project memory is at `migration/project-memories/-home-odedbe-projects-hey-seven/`
3. Gold traces are at `migration/teams/r101-paradigm-shift/gold-traces.md`
4. LangGraph checkpointer: switch from MemorySaver to Cloud SQL PostgreSQL
5. RAG: migrate from ChromaDB to Vertex AI RAG Engine
6. Deploy: use Vertex AI Agent Engine instead of Azure Functions
