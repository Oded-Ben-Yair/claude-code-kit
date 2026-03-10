# Session Start Template

Copy-paste this when starting a new session on any project:

---

## Quick Start (copy this)

```
Read the azure-unified skill, check this project's git remote and database config, verify SSH works, read the project CLAUDE.md, and give me a status report. If this is a production app, remind me of the safety rules.
```

---

## Detailed Start (for complex sessions)

```
I'm starting work on this project. Please:

1. Read the azure-unified skill for full Azure/DevOps context
2. Identify this project and its database configuration
3. Verify git remote is SSH: git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project>
4. Read this project's CLAUDE.md for specific context
5. Check memory for any previous decisions about this project
6. If production app, list safety rules

Give me a status report with: project name, database, git remote, branch, production status, and any uncommitted changes.
```

---

## Slash Command (simplest)

Just run:
```
/onboard-project
```

---

## Project Quick Reference

| Project | Database | Production | Key Constraint |
|---------|----------|------------|----------------|
| sentimark | polymarket_analyzer | No | - |
| qc-call-analyzer | qc_analyzer | **YES** | Don't touch pipelines |
| axia-seekapa-cs-agents | axia_seekapa_chatbot | No | - |
| seekapa-training-platform | seekapa_training | No | - |
| khaleeji-brand-video | - | No | - |
| seekapa-compliance-exam | compliance_exam | **YES** | Don't touch pipelines |
| phone-spam-checker | phone_spam_checker | No | - |

## SSH Commands

```bash
# Test SSH
ssh -T git@ssh.dev.azure.com

# Push
git push azure <branch>

# Clone any project
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/<project-name>
```
