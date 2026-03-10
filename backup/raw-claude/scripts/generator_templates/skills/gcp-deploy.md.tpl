---
name: gcp-deploy
description: Deploy application to GCP Cloud Run with Artifact Registry
metadata:
  version: 1.0.0
  triggers:
    - deploy
    - cloud run deploy
    - push to prod
---

# GCP Deploy

Deploy the current project to Cloud Run via Artifact Registry.

## Pre-Deploy Checklist

1. Verify you are in the correct project directory: `pwd`
2. Verify all tests pass: `pytest` or `npm test`
3. Verify no uncommitted changes: `git status`
4. Record current health endpoint response for comparison

## Steps

### 1. Build Container Image

```bash
# Build with Cloud Build
gcloud builds submit --tag ${ARTIFACT_REGISTRY}/${GCP_PROJECT}/${REPO_NAME}/${SERVICE_NAME}:${TAG}

# Or build locally and push
docker build -t ${ARTIFACT_REGISTRY}/${GCP_PROJECT}/${REPO_NAME}/${SERVICE_NAME}:${TAG} .
docker push ${ARTIFACT_REGISTRY}/${GCP_PROJECT}/${REPO_NAME}/${SERVICE_NAME}:${TAG}
```

### 2. Deploy to Cloud Run

```bash
gcloud run deploy ${SERVICE_NAME} \
  --image ${ARTIFACT_REGISTRY}/${GCP_PROJECT}/${REPO_NAME}/${SERVICE_NAME}:${TAG} \
  --region ${GCP_REGION} \
  --platform managed \
  --allow-unauthenticated \
  --set-env-vars "VERSION=${TAG}" \
  --set-secrets "DB_URL=db-connection-string:latest"
```

### 3. Verify Deployment

```bash
# Check new revision is serving
gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='value(status.traffic[0].revisionName)'

# Hit health endpoint
SERVICE_URL=$$(gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='value(status.url)')
curl -s "$$SERVICE_URL/health" | python3 -m json.tool

# Compare with pre-deploy snapshot
```

### 4. Rollback if Needed

```bash
# Route traffic back to previous revision
gcloud run services update-traffic ${SERVICE_NAME} \
  --region ${GCP_REGION} \
  --to-revisions PREVIOUS_REVISION=100
```

## Post-Deploy

- Verify version in health endpoint matches deployed tag
- Check Cloud Logging for startup errors
- Monitor error rate for 5 minutes
