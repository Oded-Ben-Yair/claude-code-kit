# SYSADMIN-OPS.md Template

Generate this file as `SYSADMIN-OPS.md` in the project root after completing Docker setup.

```markdown
# <PROJECT_NAME> — Operations Guide

**Generated**: <DATE>
**Architecture**: Backend (Docker on Container Apps) + Frontend (Azure Static Web Apps)

---

## Architecture Overview

```
Frontend (Azure Static Web Apps)     Backend (Azure Container Apps)
  https://<FRONTEND_DOMAIN>    →→→    https://<BACKEND_DOMAIN>
  Static export (HTML/JS/CSS)          Docker: sentimarkregistry.azurecr.io/<IMAGE>:<TAG>
  Deployed via: swa deploy             Deployed via: Azure Pipelines → ACR
```

## Backend Docker

| Aspect | Value |
|--------|-------|
| Registry | `sentimarkregistry.azurecr.io` |
| Image | `<IMAGE>:<TAG>` |
| Port | `<BACKEND_PORT>` |
| Health | `https://<BACKEND_DOMAIN>/health` |

### Pull & Run Backend

\```bash
az acr login --name sentimarkregistry
docker pull sentimarkregistry.azurecr.io/<IMAGE>:<TAG>

# Configure
cp .env.template .env
# Edit .env — set ALL required variables:
<LIST_REQUIRED_VARS_WITH_DESCRIPTIONS>

# Run
docker-compose up -d

# Verify
curl http://localhost:<BACKEND_PORT>/health
docker-compose logs -f --tail=50
\```

## Frontend (Azure Static Web Apps — NOT Docker)

The frontend is a static export (NOT a Docker container).

### Deploy Frontend

\```bash
cd <frontend-dir>
npm ci
NEXT_PUBLIC_API_URL=https://<BACKEND_DOMAIN> npm run build
swa deploy ./out --deployment-token <TOKEN> --env production
\```

### Verify Frontend

\```bash
# Check deployment is fresh (last-modified should be recent)
curl -sI https://<FRONTEND_DOMAIN> | grep -i last-modified

# Check CSP includes correct backend domain
curl -sI https://<FRONTEND_DOMAIN> | grep -i content-security-policy

# Check actual page loads
curl -s https://<FRONTEND_DOMAIN> | grep -o 'preconnect.*href="[^"]*"'
\```

### IMPORTANT: Frontend Must Be Redeployed When...

- Backend domain changes (new Container App URL or custom domain)
- Any `NEXT_PUBLIC_*` environment variable changes
- Frontend code is updated

`NEXT_PUBLIC_*` variables are BAKED INTO the JavaScript at build time.
Changing them requires a full rebuild + redeploy.

## Update Procedure

### Backend Update
\```bash
docker pull sentimarkregistry.azurecr.io/<IMAGE>:<TAG>
docker-compose down && docker-compose up -d
curl http://localhost:<BACKEND_PORT>/health
\```

### Frontend Update (after code changes)
\```bash
cd <frontend-dir>
npm ci
NEXT_PUBLIC_API_URL=https://<BACKEND_DOMAIN> npm run build
swa deploy ./out --deployment-token <TOKEN> --env production
\```

## Connection: Frontend → Backend

| Setting | Where | Value |
|---------|-------|-------|
| API URL | `NEXT_PUBLIC_API_URL` (build time) | `https://<BACKEND_DOMAIN>` |
| CSP | `staticwebapp.config.json` connect-src | `https://<BACKEND_DOMAIN>` |
| CORS | Backend `config.py` CORS_ORIGINS | `https://<FRONTEND_DOMAIN>` |

**All three must be in sync.** If any changes, update all three and redeploy frontend.

## Rollback

### Backend
\```bash
az acr repository show-tags --name sentimarkregistry --repository <IMAGE> --orderby time_desc
docker pull sentimarkregistry.azurecr.io/<IMAGE>:<old-tag>
docker-compose down && docker-compose up -d
\```

### Frontend
\```bash
# Redeploy previous version
git checkout <previous-commit> -- <frontend-dir>/
cd <frontend-dir>
NEXT_PUBLIC_API_URL=https://<BACKEND_DOMAIN> npm run build
swa deploy ./out --deployment-token <TOKEN> --env production
\```

## Troubleshooting

| Symptom | Check | Fix |
|---------|-------|-----|
| Backend container won't start | `docker logs <container>` | Check env vars in .env |
| Backend health check fails | `curl localhost:<PORT>/health` | Is DB reachable? |
| Frontend shows "Loading..." | Browser console (F12) for CORS/CSP | Verify CORS + CSP config |
| Frontend data is stale | `curl -sI <frontend-url>` check last-modified | Rebuild + redeploy frontend |
| CORS error in browser | Backend CORS config | Add frontend domain to CORS_ORIGINS |
| CSP violation in browser | staticwebapp.config.json | Update connect-src with backend domain |
| API URL wrong in frontend | Source code correct but live is wrong | Frontend needs rebuild+redeploy |
```
