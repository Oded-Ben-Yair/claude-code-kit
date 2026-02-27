---
name: export-kit
description: Generate a portable, cloud-agnostic Claude Code kit from the current ~/.claude/ environment. Applies Azure-to-GCP transformations, generates new templates, outputs a ready-to-push repo, and auto-pushes to GitHub.
argument-hint: [--dry-run] [--output PATH] [--verbose] [--push]
allowed-tools: Read, Write, Bash, Glob
metadata:
  version: "1.0.0"
  author: odedbe
---

# /export-kit -- Export Claude Code Kit

**Purpose**: Generate a portable, cloud-agnostic Claude Code starter kit from the current `~/.claude/` environment. Strips Azure-specific config, transforms references to GCP equivalents, generates new cloud-agnostic skills/hooks/docs, and pushes to GitHub.

**Flow**: Generate -> Validate -> Review -> Push

---

## When to Use

- After significant changes to `~/.claude/` (new rules, hooks, skills)
- Before sharing your Claude Code setup publicly
- After adding new patterns that others would benefit from
- Periodic export to keep the public kit in sync

---

## Usage

```bash
# Full export + push (default workflow)
/export-kit

# Dry run (show what would be generated, no file writes)
/export-kit --dry-run

# Custom output directory
/export-kit --output ~/my-custom-kit

# Verbose logging
/export-kit --verbose
```

---

## Procedure

### Step 1: Run the Generator

```bash
python3 ~/.claude/scripts/export-kit-generator.py --output ~/claude-code-kit --verbose
```

This will:
- Copy universal files (rules, hooks, scripts, docs, checklists)
- Transform Azure-specific references to GCP equivalents
- Generate new GCP-specific skills, hooks, MCP skeleton, and docs
- Create `install.sh` for easy deployment to new machines
- Create `settings.json.template` with `{CLAUDE_HOME}` placeholders

### Step 2: Validate the Output

```bash
bash ~/.claude/scripts/validate-kit.sh ~/claude-code-kit
```

The validator checks 10 categories:
1. No hardcoded `$HOME` paths (except `Origin:` lines)
2. No Azure MCP tool names in `.md` files
3. No `github.com` references
4. Shell scripts are executable
5. JSON files are valid
6. `settings.json.template` has `{CLAUDE_HOME}` placeholders
7. `CLAUDE.md` has no `vertex-ai` / Secret Manager references
8. Required directories exist
9. `install.sh` exists and is executable
10. File count sanity (20-200 files)

**All 10 checks must pass before pushing.**

### Step 3: Review Key Files

Manually verify:
- `~/claude-code-kit/core/CLAUDE.md` -- sections rewritten correctly, no Azure leakage
- `~/claude-code-kit/core/settings.json.template` -- valid JSON, `{CLAUDE_HOME}` placeholders
- `~/claude-code-kit/install.sh` -- correct paths, no hardcoded user directories

### Step 4: Push to GitHub

```bash
cd ~/claude-code-kit
git init 2>/dev/null || true
git add -A
git commit -m "Export Claude Code kit $(date +%Y-%m-%d)"
git remote add origin https://github.com/oded-ben-yair/claude-code-kit.git 2>/dev/null || true
git push -u origin main --force
```

**NOTE**: The generator `--push` flag automates Steps 2-4.

---

## What Gets Exported

### Transformed (Azure to GCP)

| Source | Output | Changes |
|--------|--------|---------|
| `CLAUDE.md` | `core/CLAUDE.md` | 9 sections rewritten (MCP, deploy, project map, etc.) |
| `rules/azure-deploy.md` | `core/rules/cloud-deploy.md` | Azure CLI to `gcloud` equivalents |
| Hook scripts | `core/hooks/*.sh` | Paths use `$CLAUDE_HOME` variable |
| `settings.json` | `core/settings.json.template` | All paths become `{CLAUDE_HOME}` placeholders |

### Generated New

| File | Purpose |
|------|---------|
| `install.sh` | Cross-platform bootstrap (detects OS, creates dirs, copies files) |
| `core/skills/gcp-deploy.md` | Cloud Run deploy skill |
| `core/skills/gcp-rollback.md` | Cloud Run rollback skill |
| `core/skills/gcp-status.md` | GCP resource status skill |
| `core/skills/gcp-logs.md` | Cloud Logging query skill |
| `core/skills/gcp-compliance.md` | GCP resource compliance audit |
| `core/hooks/cloud-build-gate.sh` | Block premature verification after Cloud Build |
| `core/hooks/gcp-adc-check.sh` | Verify Application Default Credentials |
| `mcp-servers/multi-provider-ai/` | FastMCP skeleton (Vertex AI, Gemini, etc.) |
| `core/docs/cloud-run.md` | Cloud Run patterns and best practices |
| `core/docs/gcp-cli-reference.md` | Common gcloud commands |
| `core/rules/gcp-deploy.md` | GCP deployment safety rules |
| `core/rules/gcp-safety.md` | GCP-specific safety guardrails |

### Skipped (Machine-Specific)

- `.credentials.json`, `.env.secrets`, `.env` files
- `cache/`, `telemetry/`, session data
- Azure-only skills (`azure-compliance`, `azure-unified`, `fix-pipeline`)
- `session-index.json`, `teams/` directory
- MCP server node_modules and build artifacts

---

## Dry Run Mode

```bash
python3 ~/.claude/scripts/export-kit-generator.py --dry-run
```

Shows exactly what would be generated without writing any files. Use this to preview changes before committing.

---

## Safety Rules

1. **Never push without validation passing** -- all 10 checks must be green
2. **Never include credentials** -- generator skips `.env`, `.credentials.json`, Secret Manager refs
3. **Always review CLAUDE.md** -- the most user-visible file, must be clean
4. **Force push is intentional** -- the kit repo is a snapshot, not a history. Each export overwrites.
5. **GitHub only** -- this is the ONE exception to Rule 8 (GitHub only). The public kit goes to GitHub.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Validation fails on hardcoded paths | Check generator transformations, grep for `$HOME` |
| JSON parse error in settings template | Verify `{CLAUDE_HOME}` placeholders don't break JSON structure |
| Missing directories | Generator creates them; re-run if interrupted |
| Push fails (auth) | `gh auth status` or configure PAT for `github.com` |
| File count too low | Generator may have failed silently; check `--verbose` output |

---

## Integration

| Skill | Relationship |
|-------|-------------|
| `/end-of-session` | Run `/export-kit` after major `~/.claude/` changes, before session end |
| `/learning-loop` | New patterns added by learning-loop should trigger a kit re-export |
| `skill-audit.sh` | Run audit on exported skills to verify frontmatter standards |

---

*Part of the Claude Code Kit ecosystem. Generates the public repo at github.com/oded-ben-yair/claude-code-kit.*
