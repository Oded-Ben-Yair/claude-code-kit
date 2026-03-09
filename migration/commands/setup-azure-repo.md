---
description: Safely migrate project to dedicated Azure DevOps repo with production checks
arguments:
  - name: mode
    description: "safe (production apps) or fresh (new/dev projects)"
    default: "safe"
---

# Azure DevOps Repository Setup

You are setting up a dedicated Azure DevOps repository for this project.

## Step 1: Read the azure-unified skill
Use the Skill tool to read `azure-unified` for full context on SSH and multi-repo setup.

## Step 2: Assess Current State

Run these checks and report findings:

```bash
# 1. Current git status
git remote -v
git status
git branch -a

# 2. Check if this is a production app
ls -la azure-pipelines.yml staticwebapp.config.json 2>/dev/null

# 3. Current working directory
pwd
```

## Step 3: Determine Mode

**Mode: {{ mode }}**

### If mode = "safe" (Production Apps)

**CRITICAL SAFETY RULES:**
1. **DO NOT** modify any deployment pipelines yet
2. **DO NOT** change any environment variables or secrets
3. **DO NOT** force push or rewrite history
4. **KEEP** the old remote as `azure-old` backup
5. **CREATE** the new repo but don't switch pipelines until verified

**Safe Migration Steps:**
1. Create new repo in Azure DevOps (if not exists)
2. Rename current remote: `git remote rename azure azure-old`
3. Add new SSH remote: `git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>`
4. Push to new repo: `git push -u azure main`
5. Verify push succeeded
6. **STOP HERE** - Do not touch pipelines

**Tell the user:**
> "Repo created and code pushed. The production app is still running from the OLD repo.
> When you're ready to switch the pipeline, let me know and we'll do it together with a rollback plan."

### If mode = "fresh" (New/Dev Projects)

**Fresh Setup Steps:**
1. Create new repo in Azure DevOps
2. Remove any existing remotes: `git remote remove origin 2>/dev/null; git remote remove azure 2>/dev/null`
3. Add SSH remote: `git remote add azure git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<repo-name>`
4. Initialize if needed: `git init` (if no .git)
5. Push: `git push -u azure main`
6. Create azure-pipelines.yml if needed

## Step 4: Update Project CLAUDE.md

After successful setup, update the project's CLAUDE.md with:
- New repo URL
- SSH clone command
- Any pipeline changes needed (for fresh mode)

## Step 5: Report Summary

Provide a summary:
- Old remote (if any)
- New remote URL
- Push status
- What's still needed (pipeline switch for safe mode)
- Any warnings or issues found
