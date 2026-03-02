---
name: armageddon
description: Final account exit — push latest dev env to GitHub, then wipe all personal data from this machine. Irreversible. Last command before leaving an account.
metadata:
  version: 1.0.0
  author: odedbe
  created: 2026-03-02
disable-model-invocation: true
---

# /armageddon — Final Account Exit

**This is a one-way door. No undo.**

## Phase 1: Final Push (preserve everything worth keeping)

### 1.1 Re-export kit with latest changes

```bash
python3 ~/.claude/scripts/export-kit-generator.py --output ~/claude-code-kit --verbose
```

### 1.2 Validate

```bash
bash ~/.claude/scripts/validate-kit.sh ~/claude-code-kit
```

All 10 checks must pass. If not, fix before continuing.

### 1.3 Dump fresh Memory MCP

Use `mcp__memory__read_graph` to get ALL entities. Save to:
```
~/claude-code-kit/backup/memory-mcp/knowledge-graph-full-dump.json
```

### 1.4 Copy latest Hey Seven configs

```bash
mkdir -p ~/claude-code-kit/backup/project-configs/hey-seven
cp ~/projects/hey-seven/.claude/*.md ~/projects/hey-seven/.claude/*.json ~/projects/hey-seven/.claude/*.log \
   ~/claude-code-kit/backup/project-configs/hey-seven/ 2>/dev/null
```

### 1.5 Copy latest session index

```bash
cp ~/.claude/session-index.json ~/claude-code-kit/backup/sessions/session-index.json
```

### 1.6 Copy latest global CLAUDE.md and settings

```bash
mkdir -p ~/claude-code-kit/backup/global-config
cp ~/.claude/CLAUDE.md ~/claude-code-kit/backup/global-config/CLAUDE.md
cp ~/.claude/settings.json ~/claude-code-kit/backup/global-config/settings-reference.json
```

### 1.7 Scrub secrets from backup

```bash
# Scrub all known secret patterns from backup files
cd ~/claude-code-kit/backup

# API keys
grep -rlE "xai-[a-zA-Z0-9]{20,}" . | xargs -r sed -ri 's/xai-[a-zA-Z0-9]{20,}/REDACTED_XAI_KEY/g'
grep -rlE "pplx-[a-zA-Z0-9]{20,}" . | xargs -r sed -ri 's/pplx-[a-zA-Z0-9]{20,}/REDACTED_PPLX_KEY/g'
grep -rlE "AIza[a-zA-Z0-9]{20,}" . | xargs -r sed -ri 's/AIza[a-zA-Z0-9]{20,}/REDACTED_GOOGLE_KEY/g'
grep -rlE "sk-[a-zA-Z0-9]{20,}" . | xargs -r sed -ri 's/sk-[a-zA-Z0-9]{20,}/REDACTED_SK_KEY/g'

# Azure keys (base64 patterns ending in ==)
grep -rlP "[a-zA-Z0-9+/]{30,}==" . | xargs -r sed -ri 's/[a-zA-Z0-9+/]{30,}==/REDACTED_AZURE_KEY/g'

# Database connection strings
grep -rl "postgresql://" . | xargs -r sed -ri 's|(postgresql://[a-zA-Z_]+:)[^@]+(@)|\1REDACTED\2|g'

# Azure OpenAI keys (long hex strings)
grep -rlE '"[a-f0-9]{60,}"' . | xargs -r sed -ri 's/"[a-f0-9]{60,}"/"REDACTED_AZURE_OPENAI_KEY"/g'

# Function keys in URLs
grep -rl "code=" . | xargs -r sed -ri 's/code=[a-zA-Z0-9_/+=-]{20,}/code=REDACTED/g'
```

### 1.8 Verify no secrets remain

```bash
# This must return empty
grep -rnoP '(xai-|pplx-|AIza|sk-)[a-zA-Z0-9]{15,}' ~/claude-code-kit/backup/
grep -rnoP '[a-zA-Z0-9+/]{30,}==' ~/claude-code-kit/backup/
grep -rnP 'postgresql://\w+:[^R][^E]' ~/claude-code-kit/backup/
```

If ANY output, scrub manually before continuing.

### 1.9 Commit and push

```bash
cd ~/claude-code-kit
git add -A
git commit -m "Final armageddon export $(date +%Y-%m-%d) — complete env backup"
git push origin main --force
```

### 1.10 Verify push landed

```bash
git log origin/main --oneline -1
```

**GATE: Confirm push succeeded before proceeding to Phase 2. Phase 2 is IRREVERSIBLE.**

Ask user: "Push confirmed. Ready to wipe everything? Type YES to proceed."

---

## Phase 2: Wipe All Personal Data (IRREVERSIBLE)

### 2.1 Wipe Memory MCP (all entities)

Use `mcp__memory__read_graph` to get all entity names, then `mcp__memory__delete_entities` to delete ALL of them. Process in batches.

### 2.2 Wipe session data

```bash
# Session index
rm -f ~/.claude/session-index.json

# All project memory dirs
rm -rf ~/.claude/projects/*/memory/

# Telemetry
rm -rf ~/.claude/telemetry/

# Teams
rm -rf ~/.claude/teams/
rm -rf ~/.claude/tasks/

# Tool results cache
rm -rf ~/.claude/projects/*/tool-results/ 2>/dev/null
find ~/.claude/projects/ -name "*.txt" -delete 2>/dev/null
```

### 2.3 Wipe project handovers and configs

```bash
# All .claude/ dirs in projects (handovers, status, decisions)
for dir in ~/projects/*/; do
  rm -rf "$dir/.claude/" 2>/dev/null
done

# Project CLAUDE.md files
for dir in ~/projects/*/; do
  rm -f "$dir/CLAUDE.md" 2>/dev/null
done
```

### 2.4 Wipe git credentials

```bash
rm -f ~/.git-credentials
git config --global --unset credential.helper 2>/dev/null

# Azure DevOps PAT (if stored)
rm -f ~/.azure/accessTokens.json 2>/dev/null
```

### 2.5 Wipe shell history

```bash
# Bash history (contains commands with paths, keys, URLs)
cat /dev/null > ~/.bash_history
history -c

# Zsh history
cat /dev/null > ~/.zsh_history 2>/dev/null
```

### 2.6 Wipe MCP server persistent data

```bash
# Memory MCP file store
rm -rf ~/.local/share/mcp-memory/ 2>/dev/null
rm -rf ~/.config/mcp-memory/ 2>/dev/null

# Find and remove any memory.json / knowledge-graph files
find ~ -maxdepth 4 -name "memory.json" -path "*/mcp*" -delete 2>/dev/null
find ~ -maxdepth 4 -name "knowledge-graph.json" -delete 2>/dev/null
```

### 2.7 Wipe personal auto-memory

```bash
rm -rf ~/.claude/projects/*/memory/ 2>/dev/null
```

### 2.8 Wipe the export kit local copy (it's on GitHub now)

```bash
rm -rf ~/claude-code-kit/
```

### 2.9 Final verification

```bash
echo "=== WIPE VERIFICATION ==="

# Memory MCP should be empty
echo "Memory MCP: should return empty graph"
# Run mcp__memory__read_graph — verify empty

# No session data
echo "Session index: $(ls ~/.claude/session-index.json 2>/dev/null && echo EXISTS || echo GONE)"

# No handovers
echo "Project handovers: $(find ~/projects/ -path '*/.claude/handover*' 2>/dev/null | wc -l) remaining"

# No git credentials
echo "Git credentials: $(ls ~/.git-credentials 2>/dev/null && echo EXISTS || echo GONE)"

# No history
echo "Bash history lines: $(wc -l < ~/.bash_history 2>/dev/null || echo 0)"

echo "=== DONE ==="
```

Output to user: "Environment wiped. GitHub repo is your lifeline: https://github.com/Oded-Ben-Yair/claude-code-kit"
