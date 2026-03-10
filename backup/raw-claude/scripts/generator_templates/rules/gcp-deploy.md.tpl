# GCP Deploy & Git Rules

## Git Remote (GitHub)

```bash
# SSH (preferred)
git remote add origin git@github.com:ORG_NAME/REPO_NAME.git
# HTTPS (fallback)
git remote add origin https://github.com/ORG_NAME/REPO_NAME.git
# Verify: git remote get-url origin  (must be github.com)
```

## Commit & Branch Format

```
# Commits: <type>(<scope>): <description>
# Types: feat | fix | refactor | docs | test | chore | perf
# Branches: <type>/<ticket-or-description>
# Example: feature/user-authentication
```

## Post-Push Verification (MANDATORY)

After every `git push origin <branch>`:
```bash
# 1. Check if Cloud Build was triggered
gcloud builds list --limit=1 --format='table(id, status, createTime, source.repoSource.branchName)'

# 2. Wait for build to complete
gcloud builds describe BUILD_ID --format='value(status)'
# Statuses: QUEUED, WORKING, SUCCESS, FAILURE, TIMEOUT, CANCELLED

# 3. Verify deployment after build succeeds
gcloud run services describe SERVICE_NAME --region REGION \
  --format='value(status.traffic[0].revisionName)'

# 4. Hit health endpoint
SERVICE_URL=$$(gcloud run services describe SERVICE_NAME --region REGION \
  --format='value(status.url)')
curl -s "$$SERVICE_URL/health"
```

## GCP Infrastructure

| Key | Value |
|-----|-------|
| Project | your-gcp-project-id |
| Region | us-central1 |
| Artifact Registry | us-central1-docker.pkg.dev |

## Safety Rules

- **NEVER** push to unauthorized repositories
- **NEVER** restart Cloud Run services manually after deploy -- let Cloud Build handle it
- **NEVER** hardcode credentials -- use Secret Manager / env vars
- **NEVER** delete GCP resources without explicit user confirmation
- **NEVER** force push to main/master without explicit confirmation
- **NEVER** modify IAM policies without review
- Secrets via: `gcloud secrets versions access latest --secret=SECRET_NAME`
- After deploy, verify via **database queries** (APIs may cache)

## Deploy Lessons

- ALWAYS search for existing deploy scripts (`ls *deploy*.sh`) before manual CLI commands
- Cloud Run deploys are revision-based -- old revisions stay available for rollback
- After deploy: check revision is serving traffic, not just that deploy succeeded
- Verification before Cloud Build completes shows PRE-deployment state -- wait for completion
- Cloud Run cold starts take 5-30 seconds depending on image size

## End-of-Session Deployment Verification (MANDATORY)

If ANY production code file (`src/`, `shared/`) was modified during the session:
1. `git status` -- ZERO modified production files (all committed)
2. `git log --oneline -1` -- latest commit includes your changes
3. `git push origin <branch>` -- pushed to remote
4. If deployed: health endpoint version matches what you just deployed
5. NEVER end a session with uncommitted changes to `src/` or `shared/`

## Rollback

```bash
# Route traffic to previous revision (instant)
gcloud run services update-traffic SERVICE_NAME \
  --region REGION \
  --to-revisions PREVIOUS_REVISION=100
```

## Dockerfile Exec Form CMD (MANDATORY)

Always use exec form for CMD in Dockerfiles:

```dockerfile
# GOOD: PID 1 = application (receives SIGTERM directly)
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8080"]

# BAD: PID 1 = /bin/sh (SIGTERM goes to shell, not app)
CMD uvicorn src.api.app:app --host 0.0.0.0 --port 8080
```

Cloud Run sends SIGTERM on scale-down. Shell form makes PID 1 = /bin/sh, so the app never receives SIGTERM.

## Post-Deploy Version Assertion (MANDATORY)

After every deployment, assert the running version matches what was deployed:

1. Bump version in code BEFORE committing
2. Commit + push + deploy
3. Wait 30s for new revision to become active
4. `curl` health endpoint and assert version matches
5. Only THEN run functional tests against production
