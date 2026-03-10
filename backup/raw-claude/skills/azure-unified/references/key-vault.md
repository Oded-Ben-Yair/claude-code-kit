# Key Vault & PostgreSQL Reference

## Key Vault

### Read Secrets
```bash
# List secrets
az keyvault secret list --vault-name kv-seekapa-apps -o table

# Get secret value
az keyvault secret show --vault-name kv-seekapa-apps --name <secret-name> --query value -o tsv
```

### Set Secrets
```bash
az keyvault secret set --vault-name kv-seekapa-apps \
  --name "<SecretName>" \
  --value "<secret-value>"
```

### Grant Access (Managed Identity)
```bash
# Enable Managed Identity on Function App
az functionapp identity assign -g AZAI_group -n <app-name>

# Grant Key Vault access (get principal-id from above command)
az keyvault set-policy --name kv-seekapa-apps \
  --object-id <principal-id> \
  --secret-permissions get
```

---

## Shared PostgreSQL Infrastructure

**Server**: `postgres-seekapatraining-prod.postgres.database.azure.com:5432`

| Project | Database | User | Key Vault Secret |
|---------|----------|------|------------------|
| Training Platform | `seekapa_training` | `training_app_user` | `TrainingPlatform-DbConnectionString` |
| Sentimark | `polymarket_analyzer` | `sentimark_app_user` | `Sentimark-DbConnectionString` |
| QC Analyzer | `qc_analyzer` | `qc_app_user` | `QCAnalyzer-DbConnectionString` |
| Chatbot | `axia_seekapa_chatbot` | `chatbot_app_user` | `Chatbot-DbConnectionString` |
| CRM | `seekapa_workspace` | `crm_app_user` | `CRM-DbConnectionString` |

**CRITICAL**: Each user can ONLY access its own database. Cross-database access is blocked.

### New Database Setup
```sql
-- Connect as admin
psql -h postgres-seekapatraining-prod.postgres.database.azure.com -U seekapaadmin -d postgres

-- Create role and user
CREATE ROLE newapp_role;
CREATE USER newapp_user WITH PASSWORD 'strong_password';
GRANT newapp_role TO newapp_user;

-- Create database with isolation
CREATE DATABASE newapp_db;
GRANT CONNECT ON DATABASE newapp_db TO newapp_role;
REVOKE CONNECT ON DATABASE newapp_db FROM PUBLIC;

-- Grant schema permissions (connect to newapp_db first)
\c newapp_db
GRANT ALL ON SCHEMA public TO newapp_role;
```

Then add to Key Vault:
```bash
az keyvault secret set --vault-name kv-seekapa-apps \
  --name "NewApp-DbConnectionString" \
  --value "postgresql://newapp_user:REDACTED@postgres-seekapatraining-prod.postgres.database.azure.com:5432/newapp_db?sslmode=require"
```
