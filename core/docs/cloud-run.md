# Cloud Run Deployment Guide

## Overview

Cloud Run is a fully managed compute platform for deploying containerized applications.
This guide covers deployment patterns, configuration, and troubleshooting.

## Deployment Methods

### 1. Direct Deploy (Source-Based)

```bash
# Deploy from source (Cloud Build builds the container)
gcloud run deploy SERVICE_NAME \
  --source . \
  --region REGION \
  --platform managed
```

### 2. Image Deploy (Pre-Built Container)

```bash
# Build and push to Artifact Registry
docker build -t REGION-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG .
docker push REGION-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG

# Deploy the image
gcloud run deploy SERVICE_NAME \
  --image REGION-docker.pkg.dev/PROJECT/REPO/IMAGE:TAG \
  --region REGION \
  --platform managed
```

### 3. Cloud Build + Cloud Run (CI/CD)

Use a `cloudbuild.yaml`:
```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_REPO}/${_SERVICE}:${SHORT_SHA}', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_REPO}/${_SERVICE}:${SHORT_SHA}']
  - name: 'gcr.io/cloud-builders/gcloud'
    args: ['run', 'deploy', '${_SERVICE}', '--image', '${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_REPO}/${_SERVICE}:${SHORT_SHA}', '--region', '${_REGION}']
```

## Environment Variables & Secrets

### Environment Variables
```bash
gcloud run deploy SERVICE_NAME \
  --set-env-vars "KEY1=value1,KEY2=value2"

# Update single env var without redeploying
gcloud run services update SERVICE_NAME \
  --update-env-vars "KEY1=new_value"
```

### Secret Manager Integration
```bash
# Create a secret
echo -n "secret-value" | gcloud secrets create my-secret --data-file=-

# Mount as env var in Cloud Run
gcloud run deploy SERVICE_NAME \
  --set-secrets "DB_PASSWORD=my-secret:latest"

# Mount as file
gcloud run deploy SERVICE_NAME \
  --set-secrets "/secrets/db-password=my-secret:latest"
```

## Scaling Configuration

```bash
gcloud run deploy SERVICE_NAME \
  --min-instances 0 \
  --max-instances 100 \
  --concurrency 80 \
  --cpu 1 \
  --memory 512Mi \
  --timeout 300
```

### Cold Start Mitigation
- Set `--min-instances 1` for latency-sensitive services
- Use startup CPU boost: `--cpu-boost`
- Keep container image small (<500MB)

## Health Checks

Cloud Run uses TCP startup probes by default. Add HTTP health checks:

```bash
gcloud run deploy SERVICE_NAME \
  --startup-probe httpGet.path=/health,initialDelaySeconds=5,periodSeconds=10
```

In your application:
```python
@app.get("/health")
async def health():
    return {"status": "healthy", "version": os.environ.get("VERSION", "unknown")}
```

## Traffic Management

```bash
# Gradual rollout
gcloud run services update-traffic SERVICE_NAME \
  --to-revisions NEW_REVISION=10,OLD_REVISION=90

# Full cutover
gcloud run services update-traffic SERVICE_NAME \
  --to-latest

# Instant rollback
gcloud run services update-traffic SERVICE_NAME \
  --to-revisions PREVIOUS_REVISION=100
```

## Troubleshooting

### Service Not Starting
1. Check logs: `gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=SERVICE_NAME AND severity>=ERROR" --limit=20`
2. Verify image exists: `gcloud artifacts docker images list REGION-docker.pkg.dev/PROJECT/REPO`
3. Check port: Cloud Run expects the app to listen on `$PORT` (default 8080)

### High Latency
1. Check cold starts: set `--min-instances 1`
2. Check memory: increase `--memory` if OOM kills occur
3. Check concurrency: lower `--concurrency` if CPU-bound

### Deployment Succeeded but Old Code Running
1. Verify revision: `gcloud run services describe SERVICE_NAME --format='value(status.traffic[0].revisionName)'`
2. Check traffic split: may still be routing to old revision
3. Force new revision: `gcloud run services update SERVICE_NAME --no-traffic`
