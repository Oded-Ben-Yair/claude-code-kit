# GCP Safety Rules

## Credential Safety

- **NEVER** hardcode credentials in source code or config files
- **NEVER** commit service account key files (.json) to git
- **NEVER** share service account keys via chat, email, or tickets
- **ALWAYS** use Secret Manager for sensitive values
- **ALWAYS** use Application Default Credentials (ADC) for local development
- **ALWAYS** use Workload Identity for GKE/Cloud Run service accounts

```python
# GOOD: From Secret Manager
from google.cloud import secretmanager
client = secretmanager.SecretManagerServiceClient()
secret = client.access_secret_version(name="projects/PROJECT/secrets/SECRET/versions/latest")
value = secret.payload.data.decode("utf-8")

# GOOD: From environment variable (set by Cloud Run secret mount)
import os
db_password = os.environ["DB_PASSWORD"]

# BAD: Hardcoded
db_password = "supersecret123"  # NEVER
```

## IAM Safety

- **NEVER** grant `roles/owner` or `roles/editor` to service accounts
- **ALWAYS** use least-privilege custom roles or predefined narrow roles
- **ALWAYS** scope service account permissions to specific resources
- Review IAM bindings before deploying new services

```bash
# GOOD: Narrow role
gcloud projects add-iam-policy-binding PROJECT \
  --member="serviceAccount:SA@PROJECT.iam.gserviceaccount.com" \
  --role="roles/run.invoker"

# BAD: Overly broad
gcloud projects add-iam-policy-binding PROJECT \
  --member="serviceAccount:SA@PROJECT.iam.gserviceaccount.com" \
  --role="roles/editor"  # NEVER for service accounts
```

## Data Safety

- **NEVER** use production data in development environments
- **NEVER** export production database snapshots to local machines
- **NEVER** run destructive queries without WHERE clause verification
- **ALWAYS** use separate GCP projects for dev/staging/production
- **ALWAYS** verify `gcloud config get-value project` before any operation

```bash
# Pre-query checklist (MANDATORY)
gcloud config get-value project  # Verify correct project
gcloud sql instances list        # Verify correct instance

# NEVER assume schema -- verify first
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = '<table>';
```

## Network Safety

- **NEVER** expose Cloud SQL instances with public IP without authorized networks
- **ALWAYS** use VPC connectors for Cloud Run to Cloud SQL communication
- **ALWAYS** use IAP (Identity-Aware Proxy) for internal admin UIs
- **ALWAYS** set `--ingress=internal` for internal-only services

## Resource Deletion Safety

- **NEVER** delete GCP resources without explicit user confirmation
- **ALWAYS** check for dependent resources before deletion
- **ALWAYS** disable before delete (grace period for discovery)

```bash
# Check for dependents before deleting
gcloud run services describe SERVICE_NAME --region REGION
# Verify no other services depend on this

# Disable first (redirect traffic, then delete after 24h)
gcloud run services update-traffic SERVICE_NAME --to-revisions=""
# ... wait 24h ...
gcloud run services delete SERVICE_NAME --region REGION
```

## Audit Trail

- **ALWAYS** enable Cloud Audit Logs for sensitive operations
- **ALWAYS** use resource labels for ownership tracking
- **ALWAYS** tag resources with `environment`, `team`, and `project` labels

```bash
gcloud run deploy SERVICE_NAME \
  --labels "environment=production,team=backend,project=myapp"
```
