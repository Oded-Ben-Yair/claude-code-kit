---
name: gcp-logs
description: View and filter Cloud Run service logs
metadata:
  version: 1.0.0
  triggers:
    - logs
    - gcp logs
    - cloud run logs
---

# GCP Logs

View and filter Cloud Run logs using Cloud Logging.

## Common Log Queries

### Recent Logs (Last 10 Minutes)

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME} AND timestamp>=\"$$(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%SZ)\"" \
  --limit=50 --format='value(timestamp, severity, textPayload)'
```

### Error Logs Only

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME} AND severity>=ERROR" \
  --limit=20 --format='value(timestamp, textPayload)'
```

### Startup Logs (Cold Start Debugging)

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME} AND textPayload=~\"started|listening|ready|startup\"" \
  --limit=10 --format='value(timestamp, textPayload)'
```

### Request Logs with Latency

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME} AND httpRequest.requestUrl!=\"\"" \
  --limit=20 --format='table(timestamp, httpRequest.requestMethod, httpRequest.requestUrl, httpRequest.status, httpRequest.latency)'
```

### Structured JSON Logs

```bash
gcloud logging read \
  "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME} AND jsonPayload!=\"\"" \
  --limit=20 --format=json
```

## Tips

- Add `--freshness=1h` to limit to last hour (faster query)
- Use `severity>=WARNING` to filter noise
- For live tailing: `gcloud beta logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=${SERVICE_NAME}"`
- Logs may be delayed 1-2 minutes in Cloud Logging
