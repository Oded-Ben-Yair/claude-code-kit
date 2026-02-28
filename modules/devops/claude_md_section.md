## DevOps & Cloud Deployment

### Cloud Deployment Rules

Generalized deployment rules applicable to any cloud platform (GCP, AWS, Azure). See `rules/cloud-deploy.md` for full details.

**Key principles**:
- NEVER hardcode credentials -- use secret managers / env vars
- NEVER force push to main/master without explicit confirmation
- ALWAYS search for existing deploy scripts before manual CLI commands
- ALWAYS verify deployment via health endpoint after pipeline completes
- ALWAYS bump version in code BEFORE deploying (for post-deploy version assertion)

### Post-Deploy Verification Protocol (MANDATORY)

1. **Pre-deploy snapshot**: Hit 2-3 key endpoints, save responses
2. **Wait for pipeline**: Do NOT verify before pipeline completes
3. **Post-deploy check**: Hit SAME endpoints, compare behavior
4. **Version assertion**: Health endpoint version must match deployed version

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| deploy-gate.sh | PreToolUse (Bash) | Blocks premature verification after git push (5-min cooldown) |
| periodic-commit-check.sh | Stop | Auto-save reminder -- commits and pushes every N exchanges |

### Checklists

| Checklist | When |
|-----------|------|
| `before-deploy.md` | Deploying, pushing to production, pipeline trigger |
| `before-pipeline-change.md` | Modifying multi-stage pipelines, processing logic |
