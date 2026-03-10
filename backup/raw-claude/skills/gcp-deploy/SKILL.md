---
name: gcp-deploy
description: Deploy to Cloud Run or Vertex AI Agent Engine with pre/post checks. Triggers on "deploy to GCP", "gcloud run deploy", "deploy agent", "/gcp-deploy".
argument-hint: [cloud-run|agent-engine] [--service=NAME]
allowed-tools: Read, Bash, Glob, Grep
metadata:
  version: 1.0.0
  author: odedbe
---

# GCP Deploy Skill

## Pre-Deploy Checklist (MANDATORY)

Before ANY deployment:

1. **Version bump**: Verify version incremented in code
2. **Tests pass**: `pytest` with 0 failures
3. **Secrets configured**: `gcloud secrets list` — all required secrets exist
4. **No hardcoded creds**: `grep -rn "password\|secret\|api_key" src/ --include="*.py"` returns 0

## Cloud Run Deployment

```bash
# Build and push
gcloud builds submit --tag gcr.io/$PROJECT_ID/SERVICE:$(git rev-parse --short HEAD)

# Deploy
gcloud run deploy SERVICE \
    --image gcr.io/$PROJECT_ID/SERVICE:$(git rev-parse --short HEAD) \
    --region us-central1 \
    --platform managed \
    --set-secrets=DATABASE_URL=DbConnectionString:latest \
    --min-instances=1 \
    --max-instances=5 \
    --memory=2Gi \
    --cpu=2 \
    --concurrency=10 \
    --http-startup-probe-path=/live \
    --http-liveness-probe-path=/live
```

## Agent Engine Deployment

```python
import vertexai
from vertexai import agent_engines
from vertexai.agent_engines import LanggraphAgent

vertexai.init(project="PROJECT_ID", location="us-central1")

agent = LanggraphAgent(
    model="gemini-3.1-pro",
    runnable=compiled_graph,
    tools=[...],
)

remote = agent_engines.create(
    agent=agent,
    display_name="SERVICE-NAME",
    requirements=["langgraph==0.2.60", ...],
)
print(f"Deployed: {remote.name}")
```

## Post-Deploy Verification (MANDATORY)

```bash
# 1. Wait for cold start
sleep 60

# 2. Health check
curl -s https://SERVICE-URL/health | python3 -m json.tool

# 3. Version assertion
DEPLOYED_VERSION=$(curl -s https://SERVICE-URL/health | python3 -c "import sys,json; print(json.load(sys.stdin).get('version','UNKNOWN'))")
echo "Deployed: $DEPLOYED_VERSION"

# 4. Functional test
curl -s -X POST https://SERVICE-URL/api/query \
    -H "Content-Type: application/json" \
    -d '{"message": "test"}' | python3 -m json.tool
```

## Rollback

```bash
# Cloud Run: instant traffic shift
gcloud run revisions list --service=SERVICE --region=us-central1
gcloud run services update-traffic SERVICE \
    --to-revisions=PREVIOUS_REVISION=100 \
    --region=us-central1

# Agent Engine: delete and redeploy
gcloud ai agent-engines delete AGENT_ID --region=us-central1
# Then redeploy previous version
```

## CI/CD Template (cloudbuild.yaml)

```yaml
steps:
  - name: 'python:3.12'
    entrypoint: 'bash'
    args:
      - '-c'
      - 'pip install -r requirements.txt && pytest tests/ -x'

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

options:
  logging: CLOUD_LOGGING_ONLY
```
