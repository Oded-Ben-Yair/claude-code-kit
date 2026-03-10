---
name: azure-unified
description: |
  Comprehensive Azure expertise: Deployment, DevOps, Functions, Static Web Apps, Key Vault, SSO, AI Foundry.
  Use this skill for ANY Azure-related task including:
  - Deploying to Azure (Functions, Static Web Apps, Container Apps)
  - Azure DevOps repos, pipelines, PRs (NOT GitHub!)
  - Creating new repos and multi-repo architecture
  - SSH-based git operations
  - Troubleshooting deployment failures and runtime errors
  - Azure AD/Entra ID SSO configuration
  - Key Vault and secrets management
  - Azure AI Foundry model access

  Keywords: azure, deploy, devops, functions, static web app, pipeline, pr, sso, key vault, ai foundry, ssh, repo, workload identity, federated credential, wif
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, mcp__azure-ai-foundry__*
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# Unified Azure Skill

## Reference Routing

Read the appropriate reference file for your task:

| Topic | Reference File |
|-------|---------------|
| SSH keys, PAT auth, SSO, Workload Identity Federation, Kudu API | `references/auth.md` |
| Azure Functions deployment, logs, Application Insights, troubleshooting | `references/functions.md` |
| Static Web Apps deployment, Azure Pipelines YAML templates | `references/static-web-apps.md` |
| Key Vault secrets, PostgreSQL databases, managed identity access | `references/key-vault.md` |
| AI Foundry models, MCP tools, multi-model routing, Gemini integration | `references/ai-foundry.md` |

---

## Your Azure Environment

| Resource | Value |
|----------|-------|
| **Subscription** | U-BTech - CSP (Z-Online) |
| **Resource Group** | AZAI_group |
| **Location** | swedencentral |
| **AI Foundry** | brn-azai |
| **Key Vault** | kv-seekapa-apps |
| **DevOps Org** | https://dev.azure.com/Corp-domain |
| **DevOps Project** | Corp-AI |
| **SSH Key** | `~/.ssh/azure-devops` |

---

## Azure DevOps (NOT GitHub!)

**CRITICAL**: Oded uses Azure DevOps, NOT GitHub. Never use `gh` CLI.

### Check Remote Configuration First
```bash
git remote -v
# Should show 'azure' remote pointing to ssh.dev.azure.com or dev.azure.com
```

### Repos
```bash
# List repos
az repos list --org https://dev.azure.com/Corp-domain --project Corp-AI -o table

# Create repo
az repos create --name <repo-name> --org https://dev.azure.com/Corp-domain --project Corp-AI

# Add SSH remote (preferred)
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>

# Add HTTPS remote (fallback)
git remote add azure https://Corp-domain@dev.azure.com/Corp-domain/Corp-AI/_git/<repo-name>

# Push all branches
git push -u azure --all
```

### Pull Requests
```bash
# Create PR
az repos pr create --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --source-branch feature/xyz --target-branch main \
  --title "PR Title" --description "Description"

# List PRs
az repos pr list --org https://dev.azure.com/Corp-domain --project Corp-AI --status active

# Show PR details
az repos pr show --id <pr-id> --org https://dev.azure.com/Corp-domain --project Corp-AI
```

### Pipelines
```bash
# List pipelines
az pipelines list --org https://dev.azure.com/Corp-domain --project Corp-AI -o table

# Run pipeline
az pipelines run --org https://dev.azure.com/Corp-domain --project Corp-AI --name "<pipeline-name>"

# Show pipeline runs
az pipelines runs list --org https://dev.azure.com/Corp-domain --project Corp-AI --pipeline-id <id>
```

---

## Multi-Repo Architecture

**NEW**: Each project can now have its own dedicated repository.

### Project-to-Repo Mapping (Migrated 2025-12-18)

| Project | Repository | SSH Clone URL | Branch |
|---------|------------|---------------|--------|
| Sentimark | `sentimark` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/sentimark` | master |
| QC Call Analyzer | `qc-call-analyzer` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/qc-call-analyzer` | v2-dev, master |
| CS Agents | `axia-seekapa-cs-agents` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/axia-seekapa-cs-agents` | master |
| Training Platform | `seekapa-training-platform` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/seekapa-training-platform` | master |
| Khaleeji Brand Video | `khaleeji-brand-video` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/khaleeji-brand-video` | master |
| Compliance Exam | `seekapa-compliance-exam` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/seekapa-compliance-exam` | main |
| Phone Spam Checker | `phone-spam-checker` | `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/phone-spam-checker` | main |
| Monorepo (legacy) | `Seekapa-AI-Assistance` | - | Archived |

### Create New Repository
```bash
# 1. Create repo in Azure DevOps
az repos create --name <project-name> \
  --org https://dev.azure.com/Corp-domain \
  --project Corp-AI

# 2. Initialize with SSH remote
cd ~/projects/<project-name>
git init
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project-name>

# 3. Initial push
git add .
git commit -m "feat: initial commit"
git push -u azure main
```

### Migrate from Monorepo to Dedicated Repo
```bash
# 1. Create the new repo
az repos create --name <project-name> \
  --org https://dev.azure.com/Corp-domain \
  --project Corp-AI

# 2. In project directory, update remote
cd ~/projects/<project-name>
git remote remove azure 2>/dev/null || true
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project-name>

# 3. Push with history
git push -u azure main --force
```

### Production-Safe Migration (IMPORTANT)

**For apps that are currently running in production:**

| Step | Action | Safe? |
|------|--------|-------|
| 1 | Create new repo | Safe |
| 2 | Backup old remote as `azure-old` | Safe |
| 3 | Add new SSH remote | Safe |
| 4 | Push code to new repo | Safe |
| 5 | **Switch pipeline to new repo** | CAREFUL |
| 6 | Delete old remote | Wait until verified |

```bash
# SAFE: Create repo and push (doesn't affect running app)
az repos create --name <project-name> \
  --org https://dev.azure.com/Corp-domain --project Corp-AI

git remote rename azure azure-old  # Keep backup
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project-name>
git push -u azure main

# STOP HERE for production apps!
# Pipeline still points to old repo = app keeps running
```

**To switch pipeline (do with user confirmation):**
1. Update `azure-pipelines.yml` repository reference
2. Update Static Web App deployment token if needed
3. Test deployment to staging first
4. Have rollback plan ready

---

## Quick Reference

```bash
# Check resource group
az resource list -g AZAI_group -o table

# Check Azure login
az account show

# Set default subscription
az account set --subscription "U-BTech - CSP (Z-Online)"

# DevOps defaults
az devops configure --defaults organization=https://dev.azure.com/BRN-Dev project=Seekapa
```
