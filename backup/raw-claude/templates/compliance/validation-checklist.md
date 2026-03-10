# Azure Compliance Validation Checklist

**Project**: %%PROJECT_NAME%%
**Validation Date**: %%VALIDATION_DATE%%
**Validator**: Claude Opus 4.6 (automated)

---

## Pre-Validation

- [ ] All rename operations marked as complete in compliance-state.json
- [ ] Grace period has elapsed for decommissioned resources
- [ ] Pipeline has been triggered and completed successfully

---

## Naming Convention (R003)

```bash
# List all resources for this project
az resource list -g Az-ai --query "[?tags.Project=='%%PROJECT_NAME%%']" -o table
```

| Resource | Expected Name | Actual Name | Match? |
|----------|--------------|-------------|--------|
%%NAMING_TABLE%%

---

## Tags (R004)

```bash
# Check tags on all project resources
az resource list -g Az-ai --query "[?tags.Project=='%%PROJECT_NAME%%'].{Name:name, Brand:tags.Brand, Project:tags.Project, Env:tags.Environment}" -o table
```

| Resource | Brand | Project | Environment | Complete? |
|----------|-------|---------|-------------|-----------|
%%TAGS_TABLE%%

---

## Resource Group (R001)

```bash
az resource list -g Az-ai --query "[?tags.Project=='%%PROJECT_NAME%%'].{Name:name, RG:resourceGroup}" -o table
```

- [ ] All resources in `Az-ai` resource group

---

## Region (R002)

```bash
az resource list -g Az-ai --query "[?tags.Project=='%%PROJECT_NAME%%'].{Name:name, Location:location}" -o table
```

- [ ] All resources in `swedencentral`

---

## Shared Resources (R005, R006, R008)

- [ ] Storage account: uses `stsentimarkv2` (not a new account)
- [ ] App Service Plan: uses `ASP-AZAIPROJECTS` (not a new plan)
- [ ] Database: on shared PostgreSQL server `postgres-seekapatraining-prod`

---

## Functional Verification

### Health Endpoint
```bash
curl -s https://%%TARGET_FUNC_NAME%%.azurewebsites.net/api/health | jq .
```
- [ ] Returns 200 OK
- [ ] Version matches latest deployment

### SWA (if applicable)
```bash
curl -s -o /dev/null -w "%%{http_code}" https://%%TARGET_SWA_URL%%
```
- [ ] Returns 200

### Pipeline
```bash
az pipelines runs list --org https://dev.azure.com/Corp-domain --project Corp-AI \
  --pipeline-ids %%PIPELINE_ID%% --top 1 -o table
```
- [ ] Latest run succeeded
- [ ] References new resource names

### Key Vault
```bash
az keyvault secret list --vault-name kv-seekapa-apps --query "[?contains(name, '%%PROJECT_KEY%%')]" -o table
```
- [ ] Secrets reference new resource names where applicable

---

## Validation Result

| Rule | Status | Notes |
|------|--------|-------|
| R001 Resource Group | %%R001_RESULT%% | %%R001_NOTES%% |
| R002 Region | %%R002_RESULT%% | %%R002_NOTES%% |
| R003 Naming | %%R003_RESULT%% | %%R003_NOTES%% |
| R004 Tags | %%R004_RESULT%% | %%R004_NOTES%% |
| R005 Storage | %%R005_RESULT%% | %%R005_NOTES%% |
| R006 ASP | %%R006_RESULT%% | %%R006_NOTES%% |
| R007 SWA Tier | %%R007_RESULT%% | %%R007_NOTES%% |
| R008 PostgreSQL | %%R008_RESULT%% | %%R008_NOTES%% |

**Overall**: %%OVERALL_RESULT%% (%%PASS_COUNT%%/%%TOTAL_RULES%% rules passing)
