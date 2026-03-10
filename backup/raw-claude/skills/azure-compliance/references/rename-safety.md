# Azure Compliance -- Rename Safety Reference

## Why Azure Resources Cannot Be Renamed

Azure ARM (Azure Resource Manager) does not support in-place renaming. The resource name is part of the resource ID:

```
/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Web/sites/{NAME}
```

Changing the name means a different resource ID, which means a different resource. There is no rename API.

**"Rename" = Create New + Migrate Settings + Deploy Code + Swap Traffic + Decommission Old**

This is a multi-step, potentially disruptive operation. Every step requires verification before proceeding to the next.

---

## Per-Resource-Type Procedures

### Azure Function App

```bash
# 1. Create new Function App on shared ASP
az functionapp create -g Az-ai -n <new-name> \
  --storage-account stsentimarkv2 \
  --plan ASP-AZAIPROJECTS \
  --runtime python --runtime-version 3.11 \
  --os-type Linux

# 2. Export app settings from old Function App
az functionapp config appsettings list -n <old-name> -g Az-ai -o json > /tmp/settings.json

# 3. Import app settings to new Function App
# Remove read-only settings first (WEBSITE_CONTENTSHARE, etc.)
az functionapp config appsettings set -n <new-name> -g Az-ai --settings @/tmp/settings.json

# 4. Deploy code
# Option A: Direct publish (for testing)
func azure functionapp publish <new-name> --python

# Option B: Pipeline-deployed apps
# Update azure-pipelines.yml to reference <new-name>
# Push to trigger pipeline

# 5. Verify health endpoint
curl -s https://<new-name>.azurewebsites.net/api/health | jq .

# 6. Verify function count (consumption plan returns 0 -- use health endpoint instead)
curl -s https://<new-name>.azurewebsites.net/api/health | jq '.function_count // .version'

# 7. Apply required tags
az resource tag \
  --ids $(az functionapp show -n <new-name> -g Az-ai --query id -o tsv) \
  --tags Brand=<brand> Project=<project> Environment=<env>
```

**Rollback**: Old Function App remains running. Revert pipeline YAML to reference old name. No data loss.

**Gotchas**:
- `az functionapp function list` returns 0 for consumption plan apps -- always verify via health endpoint
- Old code persists 12+ hours on warm instances after deploy (consumption plan)
- App settings export may include read-only settings that fail on import -- filter them

---

### App Service (Web App)

```bash
# 1. Create new App Service on shared plan
az webapp create -g Az-ai -n <new-name> \
  --plan ASP-AZAIPROJECTS \
  --runtime "PYTHON:3.11"

# 2. Export app settings
az webapp config appsettings list -n <old-name> -g Az-ai -o json > /tmp/settings.json

# 3. Import app settings
az webapp config appsettings set -n <new-name> -g Az-ai --settings @/tmp/settings.json

# 4. Deploy code
# Option A: Zip deploy
az webapp deployment source config-zip -g Az-ai -n <new-name> --src <zip-path>

# Option B: Pipeline deploy
# Update azure-pipelines.yml

# 5. Verify health
curl -s https://<new-name>.azurewebsites.net/api/health | jq .

# 6. Apply tags
az resource tag \
  --ids $(az webapp show -n <new-name> -g Az-ai --query id -o tsv) \
  --tags Brand=<brand> Project=<project> Environment=<env>
```

**Rollback**: Revert pipeline YAML. Old App Service still running.

**Gotchas**:
- Oryx build requires `requirements.txt` at ZIP root level (not nested in subdirectories)
- Shell-form CMD in Dockerfile breaks graceful shutdown -- use exec form
- Publish profile usernames start with `$` -- use Python for Kudu deploy, not bash curl

---

### Static Web App (SWA)

SWA names are assigned at creation and **CANNOT** be changed after creation. Auto-generated names like `icy-coast-0265d5310` or `gray-field-011716a03` are permanent Azure identifiers.

**Action**: The SWA resource name itself does not need renaming. Instead:

1. **For new SWAs**: Create with compliant name from the start
```bash
az staticwebapp create -n <compliant-name> -g Az-ai --sku Free \
  --location swedencentral
```

2. **For existing SWAs with auto-generated names**: Open helpdesk ticket to assign custom domain on corp-domain.com. The SWA resource keeps its auto-generated name, but users access it via the custom domain.

3. **For SWAs that need full replacement** (rare):
```bash
# Create new SWA with compliant name
az staticwebapp create -n <new-name> -g Az-ai --sku Free

# Get deployment token for new SWA
az staticwebapp secrets list -n <new-name> -g Az-ai --query 'properties.apiKey' -o tsv

# Update azure-pipelines.yml with new deployment token
# Push to trigger deployment to new SWA

# Verify new SWA
curl -s https://<new-auto-hostname>.azurestaticapps.net/
```

**Rollback**: Old SWA remains accessible at its original URL.

---

### Key Vault Secrets

Secrets CAN be updated in place -- no rename operation needed. However, if a secret's **value** contains an old resource URL or name, the value must be updated.

```bash
# Check current secret value
az keyvault secret show --vault-name kv-seekapa-apps --name <secret-name> --query value -o tsv

# Update secret value (if it references old resource name)
az keyvault secret set --vault-name kv-seekapa-apps \
  --name <secret-name> \
  --value "<new-connection-string-or-url>"

# List all secrets to find ones referencing old resource names
az keyvault secret list --vault-name kv-seekapa-apps -o table
```

**Safety**: Key Vault maintains version history. Previous secret values are NOT deleted and can be recovered:
```bash
# List secret versions
az keyvault secret list-versions --vault-name kv-seekapa-apps --name <secret-name>

# Recover previous version
az keyvault secret set --vault-name kv-seekapa-apps \
  --name <secret-name> --value "<old-value>"
```

---

### Container Registry

Azure Container Registry (ACR) names are globally unique and **CANNOT** be changed.

- `sentimarkregistry` is the shared ACR for all projects
- No rename action needed for the registry itself
- If images need re-tagging for new naming convention:
```bash
# Re-tag image
az acr import --name sentimarkregistry \
  --source sentimarkregistry.azurecr.io/<old-image>:<tag> \
  --image <new-image>:<tag>
```

---

## Consumption Plan to ASP Migration Notes

Some Function Apps may currently run on Consumption Plan and need to move to the shared `ASP-AZAIPROJECTS`. This is a **SEPARATE** infrastructure change from renaming.

| Aspect | Consumption Plan | App Service Plan |
|--------|-----------------|-----------------|
| Cold start | Yes (0-10s delay) | No (always warm) |
| Timeout | 10 min per execution | 30 min (configurable) |
| Scaling | Auto (0 to N) | Manual (fixed instances) |
| Billing | Per execution | Fixed monthly |
| Memory | 1.5 GB | Plan-dependent |

**Risks of migration**:
- Memory/CPU requirements may exceed shared plan capacity
- Cold start behavior changes (always warm = different timing)
- Billing model changes (per-execution to fixed monthly)
- Activity timeout behavior differs (Durable Functions)

**Document as a separate risk item** in the rename plan. Do NOT bundle with naming compliance changes unless explicitly approved.

---

## Grace Period Protocol

After a resource rename (new resource created, verified, and traffic swapped):

1. **Day 0**: New resource verified and serving traffic. Old resource still running.
2. **Days 1-6**: Both old and new coexist. Monitor:
   - Error rates on new resource vs old baseline
   - Response times
   - Function execution counts
   - Any client still hitting old resource (check old resource logs)
3. **Day 7**: Human confirms decommission readiness:
   - No traffic to old resource in last 48 hours
   - No error rate increase on new resource
   - All dependent services updated to new name
4. **Decommission**: `az resource delete --ids <old-resource-id>` (IRREVERSIBLE)

```bash
# Check old resource for remaining traffic
az monitor metrics list --resource <old-resource-id> \
  --metric "Requests" --interval PT1H --aggregation Total \
  --start-time $(date -u -d '-48 hours' +%Y-%m-%dT%H:%M:%SZ)
```

**Safety**: During grace period, rollback is instant -- revert pipeline YAML to point to old resource. After decommission, rollback requires full recreate.

---

## Pre-Rename Checklist

Before starting ANY rename operation:

- [ ] Audit completed and results saved to compliance-state.json
- [ ] Rename plan generated and reviewed by human
- [ ] Plan explicitly approved by human
- [ ] Azure CLI authenticated and subscription set
- [ ] Current resource health verified (baseline)
- [ ] Pipeline YAML backed up (git commit)
- [ ] Key Vault secrets documented (current values)
- [ ] Code references identified (grep results saved)
- [ ] Rollback procedure documented and tested mentally
- [ ] Only 1 project in scope for this session

## Post-Rename Checklist

After completing rename operations:

- [ ] New resource health endpoint responds
- [ ] New resource function count matches old (or health version correct)
- [ ] Pipeline YAML updated and committed
- [ ] Code references updated and committed
- [ ] Key Vault secrets updated (if applicable)
- [ ] Tags applied to new resource (Brand, Project, Environment)
- [ ] Old resource still running (grace period)
- [ ] compliance-state.json updated with execution results
- [ ] Grace period end date recorded
- [ ] Monitoring configured for new resource
