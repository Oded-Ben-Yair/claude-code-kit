---
description: Fully onboard session with Azure infra, repo, database, and project context
arguments: []
---

# Project Onboarding

You are starting a session on this project. Complete the following onboarding steps:

## Step 1: Read Azure Skill
Use the Skill tool to read `azure-unified` - this contains:
- SSH configuration
- Multi-repo architecture with all project mappings
- Database isolation rules
- Production safety guidelines

## Step 2: Identify This Project

```bash
# Get project identity
pwd
basename $(pwd)
```

Match against the project registry:

| Project | Database | DB User | Production? |
|---------|----------|---------|-------------|
| sentimark | `polymarket_analyzer` | `sentimark_app_user` | No |
| qc-call-analyzer | `qc_analyzer` | `qc_app_user` | **YES** |
| axia-seekapa-cs-agents | `axia_seekapa_chatbot` | `chatbot_app_user` | No |
| seekapa-training-platform | `seekapa_training` | `training_app_user` | No |
| khaleeji-brand-video | - | - | No |
| seekapa-compliance-exam | `compliance_exam` | `compliance_app_user` | **YES** |
| phone-spam-checker | `phone_spam_checker` | `spam_checker_app_user` | No |

## Step 3: Verify Git & Azure Setup

```bash
# Check git remote (should be SSH)
git remote -v

# Verify SSH connection works
ssh -T git@ssh.dev.azure.com 2>&1 | head -1

# Check current branch
git branch --show-current

# Check for uncommitted changes
git status --short
```

**Expected remote format**: `azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project-name>`

If remote is HTTPS or missing, fix it:
```bash
git remote remove azure 2>/dev/null
git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project-name>
```

## Step 4: Read Project CLAUDE.md

Read this project's CLAUDE.md for:
- Project-specific persona
- Key components and architecture
- Production URLs (if applicable)
- Special rules or constraints

## Step 5: Production Safety Check

**If this is a PRODUCTION project (qc-call-analyzer or seekapa-compliance-exam):**

**EXTRA CAUTION REQUIRED:**
- Do NOT modify deployment pipelines without explicit confirmation
- Do NOT run destructive database queries
- Do NOT change environment variables without review
- Always have rollback plan for significant changes
- Test changes locally/staging before production

**Production URLs to protect:**
- QC Analyzer: https://icy-coast-0265d5310.3.azurestaticapps.net/
- Compliance Exam: https://yellow-hill-0a3781903.3.azurestaticapps.net

## Step 6: Report Onboarding Status

Provide a brief status report:

```
Project: <name>
Database: <db_name> (user: <db_user>)
Remote: <git remote url>
Branch: <current branch>
Production: Yes/No
Uncommitted: <count> files

Ready to work on: <project description>
```

## Step 7: Check Memory for Context

Search memory for any previous decisions or context about this project:
```
mcp__memory__search_nodes with query: "<project-name>"
```

---

**After completing these steps, you are fully onboarded and ready to assist with this project.**
