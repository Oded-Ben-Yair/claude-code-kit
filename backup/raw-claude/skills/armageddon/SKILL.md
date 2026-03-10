---
name: armageddon
description: Final account exit — backup everything personal to GitHub, then wipe all personal data from this machine. Irreversible. Last command before leaving an account.
metadata:
  version: 2.1.0
  author: odedbe
  created: 2026-03-02
  updated: 2026-03-10
disable-model-invocation: true
---

# /armageddon — Final Account Exit v2.0

**This is a one-way door. No undo.**

Two main goals:
1. **PRESERVE**: Push everything personal to GitHub so you can rebuild on a new machine
2. **WIPE**: Remove all personal data from this machine without harming live Azure apps

---

## Phase 0: Pre-flight Verification

### 0.1 Verify GitHub authentication

```bash
gh auth status
git ls-remote https://github.com/Oded-Ben-Yair/claude-code-kit.git HEAD
git ls-remote https://github.com/Oded-Ben-Yair/hey-seven.git HEAD
```

If ANY fails: fix auth before proceeding. Check `~/.git-credentials` for valid PAT.

### 0.2 Display backup plan for user review

Present this classification to the user:

**WILL BE BACKED UP TO GITHUB + WIPED:**
| Category | Items | Destination |
|----------|-------|-------------|
| Export Kit (portable) | Transformed skills, agents, rules, hooks, scripts, docs | `claude-code-kit` repo (core/) |
| Raw Backup | ALL skills, agents, rules, docs, configs, templates, themes, checklists, hooks, scripts (untransformed originals) | `claude-code-kit` repo (backup/raw-claude/) |
| Memory MCP | All 270 entities, 52 relations | `claude-code-kit` repo (backup/memory-mcp/) |
| Hey Seven Code | Full source code (src/, tests/, docs/, configs) | `hey-seven` repo |
| Hey Seven Context | 65+ handovers, decisions.log, status.json, eval scenarios, research | `claude-code-kit` repo (backup/hey-seven/) |
| Team Memories | Gold traces, paradigm shift findings, audit findings | `claude-code-kit` repo (backup/team-memories/) |
| Session Data | Session index, pre-compact snapshots | `claude-code-kit` repo (backup/session-data/) |
| Global Config | CLAUDE.md, settings.json, .claude.json (MCP reference) | `claude-code-kit` repo (backup/global-config/) |

**PERSONAL PROJECTS — WILL BE BACKED UP + WIPED:**
| Project | Size | Action |
|---------|------|--------|
| `hey-seven/` | 1.1G | Push to existing GitHub repo, then delete local |
| `claude-code-orchestra/` | 780K | Push to existing GitHub repo, then delete local |
| `Or_project_2/` | ~45M (no .venv) | Create private GitHub repo, push, delete local |
| `Afik/` | 185M (images heavy) | Create private GitHub repo, push, delete local |
| `or/` | 12K | Tar.gz into backup, delete local |
| `personal-os/` | 4K | Tar.gz into backup, delete local |
| `lee/` | 8K | Tar.gz into backup, delete local |
| `interview-prep-hub/` | 4K | Tar.gz into backup, delete local |
| `vp-hr-presentation/` | 4K | Tar.gz into backup, delete local |
| `linkedin/` | 445M | **TOO LARGE for GitHub — FLAG for manual backup (USB/cloud)**, delete local |
| Loose files (MP3, MP4, portfolio-*) | ~40M | Tar.gz into backup, delete local |

**WILL BE WIPED (no backup needed):**
| Item | Reason |
|------|--------|
| Edge browser profile (`~/.config/microsoft-edge-playwright/`) | Contains login sessions, cookies |
| Git credentials (`~/.git-credentials`) | Contains GitHub PAT |
| Shell history (`~/.bash_history`, `~/.zsh_history`) | Contains commands with paths/keys |
| MCP persistent data (`~/.local/share/mcp-memory/`) | Contains knowledge graph |
| Claude Code session data (`~/.claude/projects/`, telemetry, teams, tasks) | Session logs |
| Personal env vars in `~/.bashrc` | API keys |

**WILL NOT BE TOUCHED (work property):**
| Directory | Why |
|-----------|-----|
| `~/projects/sentimark/` | Azure DevOps work project |
| `~/projects/automation-fabric/` | Azure DevOps work project |
| `~/projects/seekapa-training-platform/` | Azure DevOps work project |
| `~/projects/sales-agents/` | Azure DevOps work project |
| `~/projects/qc-call-analyzer/` | Azure DevOps work project |
| `~/projects/brokershub-latam/` | Azure DevOps work project |
| `~/projects/aeo/` | Azure DevOps work project |
| `~/projects/website/` | Azure DevOps work project |
| `~/projects/real-time/` | Azure DevOps work project |
| `~/projects/seekapa-compliance-exam/` | Azure DevOps work project |
| `~/projects/tech4all/` | Azure DevOps work project |
| `~/projects/anyChat/` | Azure DevOps work project |
| `~/projects/axia-seekapa-cs-agents/` | Azure DevOps work project |
| `~/projects/client-evaluation/` | Azure DevOps work project |
| `~/projects/qc-telephony-api/` | Azure DevOps work project |
| `~/projects/sentimark-feature-alt-technical/` | Azure DevOps work branch |
| `~/projects/Seekapa-AI-Assistance-temp/` | Work project |
| `~/projects/kever rachel/` | Azure DevOps work project (despite name) |
| `~/projects/seekapa brandbook final/` | Work brand assets |
| `~/projects/seekapa-ai-showcase/` | Work project |
| `~/projects/latam-earnings-reports/` | Work research |
| `~/projects/arabic-content-evaluator/` | Work tool |
| `~/projects/azure-compliance/` | Work tool |
| `~/projects/client to duplicate/` | Work data |
| `~/projects/seo/` | Work tool |
| Work tool projects (heygen-scripter, script-optimizer, research-orchestrator, llm-conv-router, super-design-pdf, bridgewise) | Work-adjacent tools — leave for next person |
| Azure cloud resources | Cloud-side, not local |
| Azure DevOps repos | Cloud-side, not local |

**GATE: Ask user to review and confirm the classification. Adjust if needed.**

---

## Phase 1: Preserve (push everything to GitHub)

### 1A: Export Kit (portable, transformed)

```bash
python3 ~/.claude/scripts/export-kit-generator.py --output ~/claude-code-kit --verbose
```

Validate:
```bash
bash ~/.claude/scripts/validate-kit.sh ~/claude-code-kit
```

All 10 checks must pass. Fix before continuing.

### 1B: Raw Backup (untransformed originals for full rebuild)

This captures EVERYTHING needed to rebuild the Claude Code environment as-is, without any Azure-to-GCP transformation. The export-kit (1A) is the portable version; this is the exact original.

```bash
BACKUP=~/claude-code-kit/backup
mkdir -p "$BACKUP"/{raw-claude,memory-mcp,hey-seven,session-data,global-config,team-memories,personal-archives}

# --- Raw .claude/ directories (full copy, untransformed) ---
for subdir in skills agents rules docs configs templates themes checklists; do
  if [ -d ~/.claude/$subdir ]; then
    cp -r ~/.claude/$subdir "$BACKUP/raw-claude/$subdir"
  fi
done

# Hooks (exclude archive to save space, archive is old versions)
mkdir -p "$BACKUP/raw-claude/hooks"
cp ~/.claude/hooks/*.{sh,py} "$BACKUP/raw-claude/hooks/" 2>/dev/null

# Scripts (all of them)
cp -r ~/.claude/scripts "$BACKUP/raw-claude/scripts" 2>/dev/null

# MCP server configs (launcher scripts and configs, not node_modules/dist)
mkdir -p "$BACKUP/raw-claude/mcp-servers"
for server_dir in ~/.claude/mcp-servers/*/; do
  server_name=$(basename "$server_dir")
  mkdir -p "$BACKUP/raw-claude/mcp-servers/$server_name"
  # Copy all non-binary config files from the server root (not subdirs)
  find "$server_dir" -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.json" -o -name "*.md" -o -name "*.env" -o -name "*.yml" -o -name "*.yaml" -o -name "*.ps1" \) -exec cp {} "$BACKUP/raw-claude/mcp-servers/$server_name/" \; 2>/dev/null
done

# Plugins: only backup the install manifest (cache/marketplaces are re-downloaded)
mkdir -p "$BACKUP/raw-claude/plugins"
cp ~/.claude/plugins/installed_plugins.json "$BACKUP/raw-claude/plugins/" 2>/dev/null
cp ~/.claude/plugins/known_marketplaces.json "$BACKUP/raw-claude/plugins/" 2>/dev/null
```

### 1B.2: Memory MCP Full Dump

Use `mcp__memory__read_graph` to get ALL entities and relations. Save the complete JSON response to:
```
~/claude-code-kit/backup/memory-mcp/knowledge-graph-full-dump.json
```

This is the full 270 entities + 52 relations cross-session knowledge base.

### 1B.3: Hey Seven Context (project intelligence)

```bash
HS_BACKUP="$BACKUP/hey-seven"

# Project .claude/ dir (handovers, decisions, status, research)
cp -r ~/projects/hey-seven/.claude/* "$HS_BACKUP/" 2>/dev/null

# Eval scenarios (behavioral test definitions)
mkdir -p "$HS_BACKUP/eval-scenarios"
cp -r ~/projects/hey-seven/tests/scenarios/ "$HS_BACKUP/eval-scenarios/" 2>/dev/null
cp -r ~/projects/hey-seven/tests/evaluation/ "$HS_BACKUP/eval-scenarios/" 2>/dev/null

# Project CLAUDE.md
cp ~/projects/hey-seven/CLAUDE.md "$HS_BACKUP/CLAUDE.md" 2>/dev/null

# Untracked research files
cp ~/projects/hey-seven/*.txt ~/projects/hey-seven/*.md "$HS_BACKUP/" 2>/dev/null

# Gold traces and team memories
for team_dir in ~/.claude/teams/r101-paradigm-shift ~/.claude/teams/hey-seven-v2-phase1 ~/.claude/teams/r97-audit; do
  if [ -d "$team_dir" ]; then
    team_name=$(basename "$team_dir")
    mkdir -p "$BACKUP/team-memories/$team_name"
    cp -r "$team_dir"/* "$BACKUP/team-memories/$team_name/" 2>/dev/null
  fi
done

# Copy ALL team directories that have team-memory.md
for team_dir in ~/.claude/teams/*/; do
  if [ -f "$team_dir/team-memory.md" ]; then
    team_name=$(basename "$team_dir")
    mkdir -p "$BACKUP/team-memories/$team_name"
    cp "$team_dir/team-memory.md" "$BACKUP/team-memories/$team_name/" 2>/dev/null
  fi
done
```

### 1B.4: Session Data

```bash
# Session index
cp ~/.claude/session-index.json "$BACKUP/session-data/" 2>/dev/null

# Pre-compact snapshots (today's context recovery files)
mkdir -p "$BACKUP/session-data/pre-compact-snapshots"
cp ~/.claude/session-memory/pre-compact-*.md "$BACKUP/session-data/pre-compact-snapshots/" 2>/dev/null

# Auto-memory files (the MEMORY.md that persists across sessions)
mkdir -p "$BACKUP/session-data/auto-memory"
cp -r ~/.claude/projects/*/memory/ "$BACKUP/session-data/auto-memory/" 2>/dev/null

# Root-level memory directory (if exists)
cp -r ~/.claude/memory/ "$BACKUP/session-data/root-memory/" 2>/dev/null
```

### 1B.5: Global Config

```bash
# CLAUDE.md (master instructions)
cp ~/.claude/CLAUDE.md "$BACKUP/global-config/CLAUDE.md"

# Settings
cp ~/.claude/settings.json "$BACKUP/global-config/settings.json"
cp ~/.claude/settings.local.json "$BACKUP/global-config/settings.local.json" 2>/dev/null

# .claude.json (MCP server configs — 97K, the full MCP routing table)
cp ~/.claude.json "$BACKUP/global-config/claude.json" 2>/dev/null
```

### 1B.6: Personal Project Archives (small ones)

```bash
# Small personal projects → tar.gz
cd ~/projects

# Tiny projects (< 1M) — tar directly
for proj in or personal-os lee interview-prep-hub vp-hr-presentation; do
  if [ -d "$proj" ]; then
    tar czf "$BACKUP/personal-archives/$proj.tar.gz" "$proj" 2>/dev/null
  fi
done

# Loose personal files (explicit names only — avoid broad *.txt glob)
tar czf "$BACKUP/personal-archives/loose-files.tar.gz" \
  portfolio-*.{png,jpg,b64,html,md,txt} \
  record*.mp3 \
  "Dividend Stocks for Wealth.mp4" \
  Screenshot*.png \
  "image (2).png" \
  "OPERATIONS_HANDOVER 1.txt" \
  "script.txt" \
  "status.txt" \
  "Taqyeem Broker QA.docx" \
  2>/dev/null
```

### 1C: Hey Seven Source Code → GitHub

```bash
cd ~/projects/hey-seven
git add -A
git commit -m "Final snapshot before machine handback $(date +%Y-%m-%d)"
git push origin main
```

Verify push:
```bash
git log origin/main --oneline -1
```

### 1D: Other Personal GitHub Repos

**claude-code-orchestra:**
```bash
cd ~/projects/claude-code-orchestra
git add -A
git diff --cached --quiet || git commit -m "Final snapshot $(date +%Y-%m-%d)"
git push origin main 2>/dev/null || git push origin master 2>/dev/null
```

**Or_project_2 (45M — create new private repo):**
```bash
cd ~/projects/Or_project_2
git init
gh repo create Oded-Ben-Yair/or-project-2 --private --source=. --push
```

**Afik (185M — create new private repo, exclude build artifacts):**
```bash
cd ~/projects/Afik
echo -e "node_modules/\nout/\n.next/\n.venv/\n__pycache__/" > .gitignore
git init
git add -A
git commit -m "Afik songbook project backup $(date +%Y-%m-%d)"
gh repo create Oded-Ben-Yair/afik-songbook --private --source=. --push
```

**LinkedIn (445M — TOO LARGE for GitHub):**
```
⚠️  MANUAL ACTION REQUIRED: ~/projects/linkedin/ is 445M (507 PNGs, 667 logs).
    Too large for GitHub. Options:
    1. Copy to USB drive / personal cloud storage
    2. Selective push (just the profile/ and content/ dirs — ~400K)
    3. Accept data loss

    Ask user which option they prefer. If option 2:
```
```bash
cd ~/projects/linkedin
echo -e "research/\n*.log\n*.png\n*.jpeg" > .gitignore
git init && git add -A && git commit -m "LinkedIn data backup (text only)"
gh repo create Oded-Ben-Yair/linkedin-data --private --source=. --push
```

### 1E: Secret Scrub

```bash
cd ~/claude-code-kit/backup

# --- API Keys ---
grep -rlE "xai-[a-zA-Z0-9]{20,}" . 2>/dev/null | xargs -r sed -ri 's/xai-[a-zA-Z0-9]{20,}/REDACTED_XAI_KEY/g'
grep -rlE "pplx-[a-zA-Z0-9]{20,}" . 2>/dev/null | xargs -r sed -ri 's/pplx-[a-zA-Z0-9]{20,}/REDACTED_PPLX_KEY/g'
grep -rlE "AIza[a-zA-Z0-9]{20,}" . 2>/dev/null | xargs -r sed -ri 's/AIza[a-zA-Z0-9]{20,}/REDACTED_GOOGLE_KEY/g'
grep -rlE "sk-[a-zA-Z0-9]{20,}" . 2>/dev/null | xargs -r sed -ri 's/sk-[a-zA-Z0-9]{20,}/REDACTED_SK_KEY/g'

# --- GitHub PATs ---
grep -rlE "ghp_[a-zA-Z0-9]{30,}" . 2>/dev/null | xargs -r sed -ri 's/ghp_[a-zA-Z0-9]{30,}/REDACTED_GITHUB_PAT/g'
grep -rlE "gho_[a-zA-Z0-9]{30,}" . 2>/dev/null | xargs -r sed -ri 's/gho_[a-zA-Z0-9]{30,}/REDACTED_GITHUB_TOKEN/g'

# --- Azure keys (base64) — only in config/env files to avoid corrupting data ---
grep -rl --include="*.json" --include="*.env" --include="*.sh" --include="*.yaml" --include="*.yml" \
  -P "[a-zA-Z0-9+/]{30,}==" . 2>/dev/null | xargs -r sed -ri 's/[a-zA-Z0-9+/]{30,}==/REDACTED_AZURE_KEY/g'

# --- Database connection strings ---
grep -rl "postgresql://" . 2>/dev/null | xargs -r sed -ri 's|(postgresql://[a-zA-Z_]+:)[^@]+(@)|\1REDACTED\2|g'

# --- Azure OpenAI keys (long hex) ---
grep -rlE '"[a-f0-9]{60,}"' . 2>/dev/null | xargs -r sed -ri 's/"[a-f0-9]{60,}"/"REDACTED_AZURE_OPENAI_KEY"/g'

# --- Function keys in URLs ---
grep -rl "code=" . 2>/dev/null | xargs -r sed -ri 's/code=[a-zA-Z0-9_/+=-]{20,}/code=REDACTED/g'

# --- ElevenLabs keys ---
grep -rlE "el_[a-zA-Z0-9]{20,}" . 2>/dev/null | xargs -r sed -ri 's/el_[a-zA-Z0-9]{20,}/REDACTED_ELEVENLABS/g'

# --- Personal email ---
grep -rlE "oded\.(be|benyair)@" . 2>/dev/null | xargs -r sed -ri 's/oded\.(be|benyair)@[a-zA-Z0-9.-]+/REDACTED_EMAIL/g'

# NOTE: Azure DevOps PATs are NOT scrubbed with regex (too broad, would corrupt data).
# They are handled by deleting ~/.git-credentials entirely in Phase 2.

# --- Scrub the global config file too (contains MCP env vars with keys) ---
cd ~/claude-code-kit/backup/global-config
if [ -f claude.json ]; then
  python3 -c "
import json, re
with open('claude.json') as f: data = json.load(f)
text = json.dumps(data, indent=2)
# Scrub all env var values that look like keys
text = re.sub(r'\"(XAI_API_KEY|PPLX_API_KEY|GOOGLE_API_KEY|ELEVENLABS_API_KEY|GROK_API_KEY|GOOGLE_DEVELOPER_KNOWLEDGE_API_KEY)\": \"[^\"]+\"',
              r'\"\1\": \"REDACTED\"', text)
with open('claude.json', 'w') as f: f.write(text)
"
fi
```

### 1F: Verify No Secrets Remain

```bash
echo "=== SECRET SCAN ==="
# This must return empty for each check
grep -rnoP '(xai-|pplx-|AIza|sk-|ghp_|gho_|el_)[a-zA-Z0-9]{15,}' ~/claude-code-kit/backup/ 2>/dev/null
grep -rnoP '[a-zA-Z0-9+/]{30,}==' ~/claude-code-kit/backup/ 2>/dev/null
grep -rnP 'postgresql://\w+:[^R][^E]' ~/claude-code-kit/backup/ 2>/dev/null
grep -rnoP 'ghp_[a-zA-Z0-9]{30,}' ~/claude-code-kit/backup/ 2>/dev/null
echo "=== END SCAN ==="
```

If ANY output → scrub manually before continuing.

### 1G: Commit and Push Everything

```bash
cd ~/claude-code-kit
git add -A
git commit -m "$(cat <<'EOF'
Armageddon export 2026-03-10 — complete environment backup

Includes:
- Portable export kit (core/)
- Raw .claude/ backup (skills, agents, rules, docs, hooks, scripts)
- Memory MCP full dump (270 entities)
- Hey Seven project context (65+ handovers, eval scenarios, research)
- Team memories (gold traces, paradigm shift findings)
- Session data and pre-compact snapshots
- Global config (CLAUDE.md, settings, MCP config)
- Personal project archives
EOF
)"
git push origin main --force
```

Verify:
```bash
git log origin/main --oneline -1
echo "Backup size: $(du -sh ~/claude-code-kit/ | cut -f1)"
```

### GATE: All Pushes Must Land

Verify ALL repos pushed successfully:
```bash
echo "=== PUSH VERIFICATION ==="
echo "claude-code-kit: $(cd ~/claude-code-kit && git log origin/main --oneline -1)"
echo "hey-seven: $(cd ~/projects/hey-seven && git log origin/main --oneline -1)"
echo "claude-code-orchestra: $(cd ~/projects/claude-code-orchestra && git log origin/main --oneline -1 2>/dev/null || echo 'N/A')"
echo "=== END ==="
```

**Ask user**: "All backups pushed to GitHub. Phase 2 will PERMANENTLY DELETE all personal data from this machine. Work projects (Azure DevOps) will NOT be touched. Type YES to proceed."

**If user says NO → stop. Everything is safely on GitHub.**

---

## Phase 2: Wipe All Personal Data (IRREVERSIBLE)

### 2.1 Wipe Memory MCP (all entities)

Use `mcp__memory__read_graph` to get ALL entity names.
Then `mcp__memory__delete_entities` in batches of 20 to delete ALL 270 entities.
Repeat until `mcp__memory__read_graph` returns empty.

### 2.2 Wipe Claude Code session/personal data

```bash
# Session index
rm -f ~/.claude/session-index.json

# All project memory dirs (session logs, handovers, memories)
rm -rf ~/.claude/projects/

# Telemetry
rm -rf ~/.claude/telemetry/

# Teams (gold traces, team memories)
rm -rf ~/.claude/teams/

# Tasks (subagent outputs)
rm -rf ~/.claude/tasks/

# Session memory (pre-compact snapshots)
rm -rf ~/.claude/session-memory/

# Auto-memory
rm -rf ~/.claude/memory/ 2>/dev/null

# Plugins cache and marketplace data (310M, re-downloadable)
rm -rf ~/.claude/plugins/
```

### 2.3 Wipe personal project directories

```bash
# Projects confirmed personal (GitHub or no remote)
rm -rf ~/projects/hey-seven/
rm -rf ~/projects/claude-code-orchestra/
rm -rf ~/projects/Afik/
rm -rf ~/projects/Or_project_2/
rm -rf ~/projects/or/
rm -rf ~/projects/personal-os/
rm -rf ~/projects/lee/
rm -rf ~/projects/interview-prep-hub/
rm -rf ~/projects/vp-hr-presentation/
rm -rf ~/projects/linkedin/

# Loose personal files
rm -f ~/projects/record*.mp3
rm -f ~/projects/"Dividend Stocks for Wealth.mp4"
rm -f ~/projects/portfolio-*
rm -f ~/projects/Screenshot*.png
rm -f ~/projects/"image (2).png"
rm -f ~/projects/status.txt
rm -f ~/projects/script.txt
rm -f ~/projects/"OPERATIONS_HANDOVER 1.txt"
rm -f ~/projects/"Taqyeem Broker QA.docx"
rm -rf ~/projects/.playwright-mcp/ 2>/dev/null
```

### 2.4 Wipe Edge browser profile (login sessions, cookies)

```bash
rm -rf ~/.config/microsoft-edge-playwright/
```

### 2.5 Wipe git credentials

```bash
# GitHub PAT
rm -f ~/.git-credentials

# Remove credential helper config (but keep gitconfig itself for work)
git config --global --unset credential.helper 2>/dev/null

# Azure access tokens
rm -f ~/.azure/accessTokens.json 2>/dev/null
```

### 2.6 Wipe shell history

```bash
cat /dev/null > ~/.bash_history
history -c 2>/dev/null

cat /dev/null > ~/.zsh_history 2>/dev/null
```

### 2.7 Clean personal env vars from .bashrc

```bash
# Remove lines containing personal API keys from .bashrc
# Be CAREFUL — only remove lines we KNOW are personal
sed -i '/GOOGLE_DEVELOPER_KNOWLEDGE_API_KEY/d' ~/.bashrc 2>/dev/null
sed -i '/GOOGLE_API_KEY/d' ~/.bashrc 2>/dev/null
sed -i '/XAI_API_KEY/d' ~/.bashrc 2>/dev/null
sed -i '/PPLX_API_KEY/d' ~/.bashrc 2>/dev/null
sed -i '/ELEVENLABS_API_KEY/d' ~/.bashrc 2>/dev/null
sed -i '/GROK_API_KEY/d' ~/.bashrc 2>/dev/null
```

### 2.7b Wipe GitHub CLI auth and archived SSH keys

```bash
# GitHub CLI auth (personal GitHub account)
rm -rf ~/.config/gh/ 2>/dev/null

# Archived personal GitHub SSH keys
rm -rf ~/.ssh/archived-github-keys-20251117/ 2>/dev/null

# Old MCP configs (superseded by .claude.json)
rm -f ~/.mcp.json 2>/dev/null

# DO NOT TOUCH: Azure DevOps SSH keys (work property)
# ~/.ssh/azure-devops, id_rsa_azure_devops*, config, known_hosts — KEEP
```

### 2.8 Wipe MCP server persistent data

```bash
# Memory MCP file store
rm -rf ~/.local/share/mcp-memory/ 2>/dev/null
rm -rf ~/.config/mcp-memory/ 2>/dev/null

# Find and remove memory.json / knowledge-graph files
find ~ -maxdepth 4 -name "memory.json" -path "*/mcp*" -delete 2>/dev/null
find ~ -maxdepth 4 -name "knowledge-graph.json" -delete 2>/dev/null
```

### 2.9 Wipe local backup copy (it's on GitHub now)

```bash
rm -rf ~/claude-code-kit/
```

### 2.10 Final Verification

```bash
echo "========================================="
echo "  ARMAGEDDON WIPE VERIFICATION"
echo "========================================="
echo ""

# Memory MCP
echo "Memory MCP: (run mcp__memory__read_graph to verify empty)"

# Session data
echo "Session index: $(ls ~/.claude/session-index.json 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
echo "Projects dir: $(ls -d ~/.claude/projects/ 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
echo "Telemetry: $(ls -d ~/.claude/telemetry/ 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
echo "Teams: $(ls -d ~/.claude/teams/ 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
echo "Tasks: $(ls -d ~/.claude/tasks/ 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"

# Personal projects
echo ""
echo "Personal projects:"
for proj in hey-seven claude-code-orchestra Afik Or_project_2 or personal-os lee interview-prep-hub vp-hr-presentation linkedin; do
  echo "  $proj: $(ls -d ~/projects/$proj/ 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
done

# Loose files
echo ""
echo "Loose personal files: $(ls ~/projects/portfolio-* ~/projects/record* ~/projects/*.mp4 2>/dev/null | wc -l) remaining"

# Credentials
echo ""
echo "Git credentials: $(ls ~/.git-credentials 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
echo "Edge profile: $(ls -d ~/.config/microsoft-edge-playwright/ 2>&1 && echo 'EXISTS ❌' || echo 'GONE ✓')"
echo "Bash history: $(wc -l < ~/.bash_history 2>/dev/null || echo 0) lines"

# Work projects still intact
echo ""
echo "Work projects (should be intact):"
for proj in sentimark automation-fabric seekapa-training-platform qc-call-analyzer; do
  echo "  $proj: $(ls -d ~/projects/$proj/ 2>&1 && echo 'INTACT ✓' || echo 'MISSING ❌')"
done

echo ""
echo "========================================="
echo "  VERIFICATION COMPLETE"
echo "========================================="
```

Use `mcp__memory__read_graph` to confirm Memory MCP is empty.

---

## Recovery Instructions (for new machine)

Output to user:

```
Environment wiped. Your data is on GitHub:

1. claude-code-kit:  https://github.com/Oded-Ben-Yair/claude-code-kit
   → Run install.sh to rebuild .claude/ environment
   → backup/ has raw originals, memory dump, hey-seven context

2. hey-seven:        https://github.com/Oded-Ben-Yair/hey-seven
   → Full source code, latest commit

3. Other repos:      Check https://github.com/Oded-Ben-Yair?tab=repositories

To rebuild on a new machine:
  git clone https://github.com/Oded-Ben-Yair/claude-code-kit.git
  cd claude-code-kit && bash install.sh
  # Then restore backup/ contents as needed
```
