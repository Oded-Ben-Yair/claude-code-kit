# GCP Secret Manager Patterns

Load when: Secret Manager, secrets, credentials, API key storage

## Overview

Secret Manager stores API keys, database passwords, and certificates. Replaces Azure Secret Manager. Secrets are versioned, audited, and IAM-controlled.

## CLI Operations

```bash
# Create a secret
gcloud secrets create HaySeven-DbConnectionString \
    --data-file=db-conn.txt \
    --replication-policy="automatic"

# Access latest version
gcloud secrets versions access latest --secret=HaySeven-DbConnectionString

# Add a new version
echo -n "new-connection-string" | \
    gcloud secrets versions add HaySeven-DbConnectionString --data-file=-

# List all secrets
gcloud secrets list --format="table(name, createTime)"

# Disable old version
gcloud secrets versions disable VERSION_ID --secret=HaySeven-DbConnectionString
```

## Python SDK

```python
from google.cloud import secretmanager

client = secretmanager.SecretManagerServiceClient()

def get_secret(secret_id: str, project_id: str = None) -> str:
    """Access the latest version of a secret."""
    project_id = project_id or os.environ.get("GOOGLE_CLOUD_PROJECT")
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

# Usage
db_url = get_secret("HaySeven-DbConnectionString")
api_key = get_secret("HaySeven-ApiKey")
```

## Cloud Run Integration

### Volume Mount (Preferred — supports auto-rotation)

```bash
gcloud run deploy SERVICE \
    --set-secrets=/secrets/db-conn=HaySeven-DbConnectionString:latest \
    --set-secrets=/secrets/api-key=HaySeven-ApiKey:latest
```

```python
# Read from mounted path
with open("/secrets/db-conn") as f:
    db_connection_string = f.read().strip()
```

### Environment Variable

```bash
gcloud run deploy SERVICE \
    --set-secrets=DATABASE_URL=HaySeven-DbConnectionString:latest \
    --set-secrets=OPENAI_API_KEY=HaySeven-OpenAiKey:latest
```

## Cloud Build Integration

```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'IMAGE', '.']
    secretEnv: ['DB_PASSWORD']

availableSecrets:
  secretManager:
    - versionName: projects/PROJECT/secrets/HaySeven-DbPassword/versions/latest
      env: DB_PASSWORD
```

## IAM Permissions

```bash
# Grant Cloud Run service account access to secrets
gcloud secrets add-iam-policy-binding HaySeven-DbConnectionString \
    --member="serviceAccount:PROJECT_NUM-compute@developer.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

# Grant Cloud Build access
gcloud secrets add-iam-policy-binding HaySeven-DbPassword \
    --member="serviceAccount:PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"
```

## Secret Naming Convention

| Project | Secret Name | Contents |
|---------|-------------|----------|
| Hey Seven | `HaySeven-DbConnectionString` | Cloud SQL connection string |
| Hey Seven | `HaySeven-ApiKey` | External API key |
| Hey Seven | `HaySeven-GeminiKey` | Gemini API key (if not using ADC) |

## Key Differences from Azure Secret Manager

| Azure Secret Manager | GCP Secret Manager |
|-----------------|-------------------|
| `az keyvault secret show` | `gcloud secrets versions access` |
| `${SECRET_STORE:-secret-manager}` vault name | Project-scoped (no vault name) |
| `keyvault_client.get_secret()` | `client.access_secret_version()` |
| Access policies | IAM roles |
| Secret Manager reference in App Settings | Volume mount or env var in Cloud Run |
| `@Microsoft.KeyVault(SecretUri=...)` | `--set-secrets=ENV=SECRET:latest` |

## Safe Connection Pattern

```python
# GOOD: From Secret Manager
db_url = get_secret("HaySeven-DbConnectionString")

# GOOD: From environment (set by Cloud Run --set-secrets)
db_url = os.environ["DATABASE_URL"]

# BAD: Hardcoded
db_url = "postgresql://user:pass@host/db"  # NEVER
```

## Anti-Patterns

- Don't hardcode secrets — use Secret Manager or env vars
- Don't use default service account for production — create dedicated SA
- Don't store secrets in Cloud Storage — use Secret Manager
- Don't skip IAM review — principle of least privilege
- Don't use `latest` in production without rotation plan — pin versions for stability
