# Cloud Run Patterns — FastAPI Deployment

Load when: Cloud Run, FastAPI deploy, container deploy, health check, startup probe

## Overview

Cloud Run deploys containerized FastAPI applications with auto-scaling, health checks, and Secret Manager integration. Replaces Azure App Service / Azure Functions for custom API hosting.

## Dockerfile Template

```dockerfile
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --require-hashes -r requirements.txt

FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

# Non-root user
RUN useradd -r -u 1001 appuser && chown -R appuser /app
USER appuser

EXPOSE 8080

# MANDATORY: Exec form for graceful SIGTERM handling
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8080"]
```

## Health Checks

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/live")
async def liveness():
    """Liveness probe — always 200. Use for container restart decisions."""
    return {"status": "alive"}

@app.get("/health")
async def health():
    """Readiness probe — 200 if ready, 503 if degraded."""
    # Check dependencies (DB, Redis, etc.)
    if not await check_dependencies():
        return JSONResponse(status_code=503, content={"status": "degraded"})
    return {"status": "healthy", "version": VERSION}
```

### Configure Probes

```bash
gcloud run deploy SERVICE \
    --image IMAGE \
    --startup-cpu-boost \
    --cpu-throttling=false \
    --http-startup-probe-path=/live \
    --http-startup-probe-initial-delay=5s \
    --http-liveness-probe-path=/live \
    --http-liveness-probe-period=30s
```

**IMPORTANT**: Use `/live` (always 200) for probes, not `/health`. Health returns 503 when degraded (e.g., circuit breaker open), causing unnecessary container restarts.

## Secret Manager Integration

### Volume Mount (Preferred — supports rotation)

```bash
gcloud run deploy SERVICE \
    --set-secrets=/secrets/db-conn=HaySeven-DbConnectionString:latest \
    --set-secrets=/secrets/api-key=HaySeven-ApiKey:latest
```

```python
# Read from mounted volume
with open("/secrets/db-conn") as f:
    db_connection_string = f.read().strip()
```

### Environment Variable

```bash
gcloud run deploy SERVICE \
    --set-secrets=DATABASE_URL=HaySeven-DbConnectionString:latest
```

```python
import os
db_url = os.environ["DATABASE_URL"]
```

## Graceful Shutdown

Cloud Run sends SIGTERM before killing containers (default 10s).

```python
import signal
import asyncio

async def drain_connections():
    """Close DB pools, finish in-flight requests."""
    await db_pool.close()
    await redis_client.close()

def handle_sigterm(signum, frame):
    asyncio.get_event_loop().create_task(drain_connections())

signal.signal(signal.SIGTERM, handle_sigterm)
```

**Rule**: Drain timeout MUST be < platform SIGKILL timeout (10s default). Set drain to 8s max.

## Concurrency for LLM-Backed APIs

```bash
gcloud run deploy SERVICE \
    --concurrency=10 \       # Max concurrent requests per instance
    --min-instances=1 \      # Prevent cold start
    --max-instances=5 \      # Cost control
    --memory=2Gi \           # LLM clients need memory
    --cpu=2
```

For LLM-heavy APIs: lower concurrency (5-10), higher memory (2-4Gi).

## Cloud Build CI/CD

```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/SERVICE:$COMMIT_SHA', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/SERVICE:$COMMIT_SHA']
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    args:
      - 'gcloud'
      - 'run'
      - 'deploy'
      - 'SERVICE'
      - '--image=gcr.io/$PROJECT_ID/SERVICE:$COMMIT_SHA'
      - '--region=us-central1'
      - '--platform=managed'

options:
  logging: CLOUD_LOGGING_ONLY

# GitHub trigger (replaces Azure DevOps Pipelines)
trigger:
  name: deploy-on-push
  github:
    owner: GITHUB_ORG
    name: REPO_NAME
    push:
      branch: main
```

## Rollback

```bash
# List revisions
gcloud run revisions list --service=SERVICE --region=us-central1

# Rollback to previous revision
gcloud run services update-traffic SERVICE \
    --to-revisions=PREVIOUS_REVISION=100 \
    --region=us-central1
```

## Cloud SQL Connection

```bash
# Cloud Run connects via Unix socket (no Cloud SQL Proxy needed)
gcloud run deploy SERVICE \
    --add-cloudsql-instances=PROJECT:REGION:INSTANCE
```

```python
# Connect via Unix socket in Cloud Run
UNIX_SOCKET = f"/cloudsql/{PROJECT}:{REGION}:{INSTANCE}"
DATABASE_URL = f"postgresql+asyncpg://USER:PASS@/{DB}?host={UNIX_SOCKET}"
```

## Key Differences from Azure

| Azure App Service | Cloud Run |
|-------------------|-----------|
| `az webapp deploy` | `gcloud run deploy` |
| Kudu zip deploy | Cloud Build + Container Registry |
| `WEBSITE_RUN_FROM_PACKAGE=1` | Container image (always) |
| App Settings | Secret Manager volumes/env vars |
| `/home/` persistent storage | Cloud Storage (no local persistence) |
| Azure Front Door | Cloud Load Balancing |
| SIGTERM → 10s shell form bug | SIGTERM → exec form CMD (same fix) |
