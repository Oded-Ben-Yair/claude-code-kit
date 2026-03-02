---
name: dockerize-project
description: |
  Dockerize project backends for production deployment. Frontend stays on Azure Static Web Apps.
  Creates backend Dockerfile, backend-only docker-compose, CI/CD pipeline, sysadmin ops doc, and STORAGE-INFO.txt.

  ARCHITECTURE RULE: Frontend = Azure Static Web Apps (NOT Docker). Backend = Docker on Container Apps.
  This is the standard for ALL projects. Never Dockerize a frontend when SWA is available.

  Use when you need to:
  - Containerize a backend for Docker deployment (backend ONLY)
  - Connect an existing SWA frontend to a Docker backend
  - Verify/fix an existing Docker setup
  - Build and push Docker images to ACR
  - Generate sysadmin handoff documentation

  Keywords: docker, dockerize, containerize, deploy docker, acr, container
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
disable-model-invocation: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# Dockerize Project Skill

**CRITICAL**: This skill affects LIVE PRODUCTION apps. Every step requires verification.
Never skip checks. Never assume. Always confirm before destructive actions.

## Architecture: Frontend = SWA, Backend = Docker

**STANDARD ARCHITECTURE** (applies to ALL projects):

```
Frontend (Azure Static Web Apps)           Backend API (Azure Container Apps)
  Next.js/Vite static export       --->     Docker container (FastAPI/Functions)
  Deployed via: swa deploy                   Image: sentimarkregistry.azurecr.io/...
  CSP connect-src -> backend domain          CI/CD: Azure Pipelines -> ACR -> pull
                                                      |
                                                      v
                                             Database (Cosmos DB / PostgreSQL)
```

**WHY NOT Docker for frontends?**
- Azure SWA provides CDN, routing, CSP headers, custom domains natively
- Docker adds nginx complexity, image builds, port management for zero benefit
- `NEXT_PUBLIC_*` vars are BUILD-TIME -- Docker just adds a layer of indirection
- SWA handles TLS termination, global distribution, and rollback automatically

**docker-compose.yml = BACKEND ONLY** (no frontend service)

---

## Pre-Flight Check

Before anything, verify context:

```bash
# 1. Confirm we're in a project directory
pwd
# Must be a recognized project directory

# 2. Check git status — must be clean or committed
git status

# 3. MANDATORY BACKUP: Create a backup branch before ANY modifications
git checkout -b backup/docker-$(date +%Y%m%d)
git add -A && git commit -m "chore: backup before dockerize skill" --allow-empty
git checkout -  # Return to original branch

# 4. Check existing Docker files
ls -la Dockerfile docker-compose.yml azure-pipelines.yml .dockerignore DOCKER-DEPLOY.md 2>/dev/null
ls -la */Dockerfile 2>/dev/null
```

**STOP if not in a project directory.** This skill is per-project only.

---

## Phase 1: Project Discovery (READ ONLY -- no changes)

### 1.1 Detect Architecture FIRST (before project type)

Some projects have multiple tech stacks in subdirectories. Detect structure before classifying.

```bash
# Check for subdirectory-based architecture
ls -d backend/ frontend/ api/ dashboard/ ui/ web/ 2>/dev/null
ls -d backend-*/ frontend-*/ 2>/dev/null
# Check for nested structures (e.g., sentimark-v2/backend/)
find . -maxdepth 2 -name "Dockerfile" -type f 2>/dev/null
find . -maxdepth 2 -name "requirements.txt" -type f 2>/dev/null
find . -maxdepth 2 -name "package.json" -type f 2>/dev/null
```

| Pattern | Architecture |
|---------|-------------|
| Single `requirements.txt` or `package.json` at root | Monolith |
| `backend/` + `frontend/` | Two-tier (standard) |
| `backend-*/` + `frontend-*/` | Two-tier (named variant, e.g. compliance-exam) |
| `api/` + `dashboard/` or `ui/` | Two-tier (AEO-style) |
| Multiple `Dockerfile`s in subdirs | Multi-component -- WARN and ask user |

**WARNING**: If BOTH `function_app.py` AND `package.json`/`next.config.*` exist at root, the project
is likely a monorepo with SEPARATE backend and frontend. Ask the user which to Dockerize, or handle both.

### 1.2 Detect Project Type Per Component

For EACH component (backend, frontend), classify separately:

| Indicator | Project Type |
|-----------|-------------|
| `function_app.py` + `host.json` | Azure Functions (Python) |
| `requirements.txt` + `api/main.py` or `src/main.py` or `app.py` or `main.py` | Python FastAPI/Flask |
| `requirements.txt` + `manage.py` | Python Django |
| `package.json` + `next.config.*` | Next.js (frontend) |
| `package.json` + `vite.config.*` | Vite/React (frontend) |
| `package.json` + `nuxt.config.*` | Nuxt.js (frontend) |
| `package.json` only | Generic Node.js |

```bash
# Per-component detection
for dir in . backend/ backend-*/ api/ frontend/ frontend-*/ dashboard/ ui/; do
  [ -d "$dir" ] || continue
  echo "=== $dir ==="
  ls "$dir"/function_app.py "$dir"/host.json 2>/dev/null && echo "  -> Azure Functions"
  ls "$dir"/requirements.txt 2>/dev/null && echo "  -> Python"
  ls "$dir"/package.json 2>/dev/null && echo "  -> Node.js"
  ls "$dir"/vite.config.* 2>/dev/null && echo "  -> Vite/React"
  ls "$dir"/next.config.* 2>/dev/null && echo "  -> Next.js"
  ls "$dir"/manage.py 2>/dev/null && echo "  -> Django"
  # Find entry point
  ls "$dir"/main.py "$dir"/app.py "$dir"/src/main.py "$dir"/api/main.py 2>/dev/null && echo "  -> Entry point found"
done
```

### 1.3 Detect Database

```bash
grep -r "cosmos\|COSMOS" .env* docker-compose.yml **/*.py 2>/dev/null | head -5
grep -r "postgres\|POSTGRES\|DATABASE_URL\|libpq\|psycopg" .env* docker-compose.yml **/*.py requirements.txt 2>/dev/null | head -5
grep -r "mongodb\|MONGO" .env* docker-compose.yml **/*.py 2>/dev/null | head -5
grep -r "redis\|REDIS" .env* docker-compose.yml **/*.py 2>/dev/null | head -5
```

### 1.4 Detect System Dependencies

**CRITICAL**: Some projects need OS-level packages. Check requirements:

```bash
# PostgreSQL client libs
grep -l "psycopg\|asyncpg\|libpq" requirements.txt */requirements.txt 2>/dev/null && echo "NEEDS: libpq-dev (build) + libpq5 (runtime)"

# WeasyPrint / PDF generation
grep -l "weasyprint\|pango\|cairo" requirements.txt */requirements.txt 2>/dev/null && echo "NEEDS: libpango, libcairo, libgdk-pixbuf"

# FFmpeg / audio processing
grep -l "ffmpeg\|pydub\|librosa" requirements.txt */requirements.txt 2>/dev/null && echo "NEEDS: ffmpeg"

# Playwright / browser
grep -l "playwright" requirements.txt */requirements.txt 2>/dev/null && echo "NEEDS: playwright install --with-deps"

# Build tools
grep -l "gcc\|numpy\|pandas\|scikit" requirements.txt */requirements.txt 2>/dev/null && echo "NEEDS: gcc, build-essential (build stage only)"
```

### 1.5 Detect Existing Docker State

| File Exists | Meaning | Action |
|-------------|---------|--------|
| `Dockerfile` | Backend containerized | VERIFY correctness, don't overwrite |
| `*/Dockerfile` | Sub-component containerized | VERIFY, don't overwrite |
| `docker-compose.yml` | Orchestration exists | VERIFY, update if needed |
| `azure-pipelines.yml` | CI/CD exists | VERIFY, don't overwrite |
| `.dockerignore` | Build exclusions set | VERIFY completeness |
| `DOCKER-DEPLOY.md` | Docs exist | UPDATE, don't overwrite |

### 1.6 Detect Environment Variables

```bash
# Find all env vars used in code
grep -roh 'os\.environ\[.\{1,50\}\]\|os\.getenv(.\{1,50\})\|os\.environ\.get(.\{1,50\})' --include="*.py" . 2>/dev/null | sort -u
grep -roh 'process\.env\.\w\+' --include="*.ts" --include="*.tsx" --include="*.js" . 2>/dev/null | sort -u

# Check existing .env or .env.template
cat .env.template 2>/dev/null || cat .env.example 2>/dev/null || echo "No env template found"
```

### 1.7 Generate Discovery Report

Present to user:

```
## Discovery Report: <project-name>

| Aspect | Value |
|--------|-------|
| Architecture | [Monolith / Two-tier (backend + frontend)] |
| Backend Type | [Azure Functions / FastAPI / Flask / Django / None] |
| Backend Entry | [function_app.py / main.py / src/main.py / etc.] |
| Frontend Type | [Next.js / Vite-React / Vue / None] |
| Frontend Deploy | [Azure Static Web Apps (standard) / Docker (rare)] |
| Database | [Cosmos DB / PostgreSQL / None] |
| System Deps | [libpq / ffmpeg / WeasyPrint / None] |
| Existing Docker | [Full / Partial / None] |
| CI/CD Pipeline | [Exists / Missing] |

### Files to Create/Modify:
- [ ] Backend Dockerfile — [CREATE / VERIFY / UPDATE]
- [ ] Frontend Dockerfile — [N/A — frontend deploys to SWA, NOT Docker]
- [ ] nginx.conf — [N/A — SWA handles routing natively]
- [ ] staticwebapp.config.json — [VERIFY CSP connect-src matches backend domain]
- [ ] docker-compose.yml — [CREATE / VERIFY / UPDATE]
- [ ] azure-pipelines.yml — [CREATE / VERIFY / UPDATE]
- [ ] .dockerignore — [CREATE / VERIFY / UPDATE]
- [ ] .env.template — [CREATE / UPDATE]
- [ ] SYSADMIN-OPS.md — [CREATE / UPDATE]
```

**WAIT FOR USER APPROVAL before proceeding to Phase 2.**

---

## Phase 2: Planning (Human Decides)

### 2.1 Ask Critical Questions

Use AskUserQuestion -- NEVER assume:

1. **Production domain names**: Backend URL and Frontend URL?
2. **ACR image name(s)**: What to call the image(s)?
   - Registry: `sentimarkregistry.azurecr.io` (confirm this is correct)
3. **Existing files**: VERIFY or START FRESH? (if existing Docker files found)
4. **Frontend deployment**: Azure Static Web Apps (standard) or Docker?
   - **SWA (standard)**: Frontend deploys as static export, calls backend cross-origin
   - **Docker (rare)**: Only if SWA is not available -- requires nginx, CORS or proxy
5. **Frontend-Backend connection** (for SWA architecture):
   - Backend custom domain URL (for NEXT_PUBLIC_API_URL at build time)
   - SWA custom domain URL (for CORS origins in backend config)
   - CSP connect-src domain (in staticwebapp.config.json)
6. **Persistent volumes**: Anything that must survive container restarts?
7. **Port mapping**: Confirm backend and frontend ports
8. **SSL/TLS**: Who handles TLS termination? (reverse proxy / Azure / Cloudflare)

### 2.2 Present the Plan

Show EVERY file that will be created with its content. Wait for approval.

---

## Phase 3: File Generation -- Templates

### Template Selection Guide

| Backend Type | Use Template |
|-------------|-------------|
| Python FastAPI/Flask | **A** (multi-stage, non-root) |
| Azure Functions Python | **B** (official MS base image) |
| Node.js backend | Standard Node.js Dockerfile |

| Frontend Type | Deploy To | Use Template |
|--------------|-----------|-------------|
| Next.js (standard) | **Azure Static Web Apps** | NO frontend Dockerfile -- use Phase 4.5 (CORS/SWA config) |
| Vite/React (standard) | **Azure Static Web Apps** | NO frontend Dockerfile -- use Phase 4.5 (CORS/SWA config) |
| Next.js (Docker - rare) | Docker (only if no SWA) | **C** + **E** (static export + nginx.conf) |
| Vite/React (Docker - rare) | Docker (only if no SWA) | **D** (includes API proxy in nginx) |
| No frontend | N/A | Skip frontend templates |

| Architecture | CORS Needed? | Phase |
|-------------|-------------|-------|
| Frontend SWA + Backend Docker (STANDARD) | YES -- Phase 4 + Phase 4.5 | Standard path |
| Frontend Docker + nginx proxy to backend | NO (same-origin) | Rare -- only if no SWA |

### Template Reference Files

Read the appropriate reference file for template contents:

- **Templates A + B** (Python backends): Read `references/python-templates.md` for FastAPI multi-stage Dockerfile and Azure Functions Dockerfile.
- **Templates C + D + E** (Frontend Dockerfiles + nginx): Read `references/frontend-templates.md` for Next.js, Vite/React, and nginx.conf templates.
- **docker-compose, .dockerignore, azure-pipelines.yml, STORAGE-INFO.txt**: Read `references/compose-pipeline.md` for all build/orchestration/CI templates.
- **SYSADMIN-OPS.md**: Read `references/sysadmin-ops.md` for the full operations guide template.

---

## Phase 4 + 4.5: CORS and SWA Configuration

Read `references/cors-swa.md` for CORS configuration (Phase 4) and Azure Static Web Apps frontend setup (Phase 4.5), including staticwebapp.config.json, CSP headers, SWA deployment, and backend CORS origins.

---

## Phase 5: Build & Test Locally

### 5.1 Build Backend

```bash
docker build -t <project>-api:test -f <backend-dir>/Dockerfile <backend-dir>/
docker images <project>-api:test
# Verify size is reasonable (Python: 200-500MB, Azure Functions: 800MB-1.2GB)
```

### 5.2 Test Backend Connectivity

```bash
# Run with env vars
docker run --rm -p <PORT>:<PORT> --env-file .env <project>-api:test &
sleep 5

# Health check
curl http://localhost:<PORT>/health

# If database used, verify connectivity:
# curl http://localhost:<PORT>/api/<endpoint-that-queries-db>
# Must return real data, not connection error

docker stop $(docker ps -q --filter ancestor=<project>-api:test)
```

### 5.3 Build Frontend (if applicable)

```bash
docker build -t <project>-dashboard:test \
  --build-arg <API_URL_ARG>=<value> \
  -f <frontend-dir>/Dockerfile <frontend-dir>/

docker run --rm -p <FPORT>:<FPORT> <project>-dashboard:test &
sleep 3
curl http://localhost:<FPORT>/health
docker stop $(docker ps -q --filter ancestor=<project>-dashboard:test)
```

### 5.4 Test Full Stack

```bash
docker-compose up --build -d
docker-compose ps  # All should be "healthy"
curl http://localhost:<PORT>/health
curl http://localhost:<FPORT>/health  # If frontend
docker-compose logs --tail=20
docker-compose down
```

---

## Phase 6: Push to ACR

### 6.1 Backend (via Pipeline)

```bash
git add Dockerfile .dockerignore azure-pipelines.yml docker-compose.yml SYSADMIN-OPS.md STORAGE-INFO.txt .env.template
git commit -m "feat(docker): containerize for production deployment"
git push azure main

# Verify pipeline
gh workflow runs list --org https://github.com/${GITHUB_ORG:-your-org} --project ${GITHUB_PROJECT:-your-project} \
  --top 1 -o table
```

### 6.2 Frontend (Manual ACR Build)

```bash
az acr build \
  --registry sentimarkregistry \
  --image <frontend-image>:$(date +%Y%m%d) \
  --image <frontend-image>:latest \
  --file <frontend-dir>/Dockerfile \
  <frontend-dir>/
```

### 6.3 Verify Images

```bash
az acr repository show-tags --name sentimarkregistry --repository <backend-image> --orderby time_desc -o table
az acr repository show-tags --name sentimarkregistry --repository <frontend-image> --orderby time_desc -o table
```

---

## Phase 7: Verification Checklist (NON-NEGOTIABLE)

### Pre-Deploy

- [ ] Backend image in ACR with correct tag
- [ ] Frontend image in ACR (if applicable)
- [ ] .env.template documents ALL required variables
- [ ] SYSADMIN-OPS.md is complete and accurate
- [ ] STORAGE-INFO.txt generated (plain-text storage summary for sysadmin)
- [ ] Health endpoints work in local Docker test
- [ ] No secrets in Docker images (verified .dockerignore)
- [ ] docker-compose.yml tested locally
- [ ] If cross-origin: CORS domains are correct
- [ ] If Azure Functions: `FUNCTIONS_WORKER_RUNTIME=python` is set
- [ ] `local.settings.json` is NOT in the image

### Post-Deploy (after sysadmin deploys)

Use Playwright to verify:
1. Navigate to frontend URL
2. Wait 5s for data load
3. Check console for CORS errors
4. Verify actual data appears (not "Loading...")
5. Backend health: `curl https://<backend-domain>/health`
6. If database: verify real data returns from API endpoint

---

## Safety Rules (HARD -- NO EXCEPTIONS)

1. **BACKUP FIRST** -- create backup branch before any modifications
2. **NEVER include .env or local.settings.json in images** -- use .dockerignore
3. **NEVER hardcode credentials** in Dockerfiles or docker-compose
4. **NEVER push to GitHub** -- GitHub only
5. **NEVER use `COPY . .` in Azure Functions Dockerfiles** -- copy each directory
6. **NEVER overwrite working Dockerfiles without user approval**
7. **ALWAYS test locally** with docker-compose before pushing to ACR
8. **ALWAYS verify images in ACR** after push
9. **ALWAYS create SYSADMIN-OPS.md AND STORAGE-INFO.txt**
10. **ALWAYS use non-root user** in Python backend Dockerfiles (not Azure Functions)
11. **ALWAYS use multi-stage builds** for Python backends with system deps
12. **FRONTEND = SWA, BACKEND = DOCKER** -- Standard architecture for all projects
13. **ALWAYS rebuild frontend** after changing NEXT_PUBLIC_* vars or backend URL
14. **ALWAYS check live CSP headers** after frontend deploy (curl -sI)
15. **NEVER include frontend Docker service** in docker-compose.yml for SWA projects

---

## Common Pitfalls (From Real Incidents)

| Pitfall | Prevention |
|---------|-----------|
| Frontend using old backend URL | Grep ALL files, update, REBUILD image |
| CORS errors invisible in curl | Test with Playwright, not just curl |
| Sysadmin pulls old image | Include exact `docker pull` commands in ops doc |
| Next.js `NEXT_PUBLIC_*` not baked | These are BUILD-TIME vars -- must rebuild image |
| Azure Functions missing FUNCTIONS_WORKER_RUNTIME | Container starts but 0 functions registered |
| `local.settings.json` leaked in image | Add to .dockerignore -- contains dev secrets |
| `COPY . .` in Azure Functions | Copies secrets, tests, __pycache__ -- use selective COPY |
| Single-stage build too large | Multi-stage: builder has gcc, runtime has only libs |
| Running as root in container | Add `useradd appuser && USER appuser` |
| Frontend /api/ proxy misconfigured | Backend container name must match docker-compose service name |
| DB unreachable from container | Test connectivity: `docker exec <api> curl <db-host>:<port>` |
| Cold start timeout for Azure Functions | Use `start_period=60s` in healthcheck |
| Frontend in Docker when SWA available | Standard: Frontend = SWA, Backend = Docker. SWA is simpler. |
| Stale frontend after API URL change | NEXT_PUBLIC_* = build time. Must rebuild + redeploy SWA. |
| docker-compose with frontend service | Backend-only compose. Frontend deploys separately to SWA. |
| CSP connect-src mismatch | curl -sI to check live CSP. Must match backend domain. |
| Assumed local when cloud | Always check if project is cloud-deployed before configuring localhost. |
