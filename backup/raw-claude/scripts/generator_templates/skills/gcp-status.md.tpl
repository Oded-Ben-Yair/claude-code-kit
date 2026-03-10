---
name: gcp-status
description: Check GCP Cloud Run service status and health
metadata:
  version: 1.0.0
  triggers:
    - status
    - gcp status
    - service status
---

# GCP Status

Check the status of Cloud Run services and related GCP resources.

## Steps

### 1. List Cloud Run Services

```bash
gcloud run services list --region ${GCP_REGION} \
  --format='table(name, status.url, status.traffic[0].revisionName, status.conditions[0].status)'
```

### 2. Describe Specific Service

```bash
gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='yaml(status)'
```

### 3. Check Health Endpoints

```bash
SERVICE_URL=$$(gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='value(status.url)')
echo "Health: $$(curl -s -o /dev/null -w '%{http_code}' "$$SERVICE_URL/health")"
curl -s "$$SERVICE_URL/health" | python3 -m json.tool
```

### 4. Check Recent Logs

```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME}" \
  --limit=20 --format='value(timestamp, textPayload)'
```

### 5. Check Instance Count

```bash
gcloud run services describe ${SERVICE_NAME} --region ${GCP_REGION} \
  --format='value(spec.template.spec.containerConcurrency, spec.template.metadata.annotations["autoscaling.knative.dev/minScale"], spec.template.metadata.annotations["autoscaling.knative.dev/maxScale"])'
```

## Quick Status Summary

Run all checks and summarize:
- Service URL reachable: yes/no
- Current revision: name + age
- Instance count: min/max
- Recent errors: count in last hour
- Health endpoint: status code + version
