# Azure Compliance Audit Report

**Project**: %%PROJECT_NAME%%
**Brand**: %%BRAND%%
**Audit Date**: %%AUDIT_DATE%%
**Auditor**: Claude Opus 4.6 (automated)

---

## Summary

| Metric | Value |
|--------|-------|
| Rules Checked | %%RULES_CHECKED%% |
| Passed | %%RULES_PASSED%% |
| Failed | %%RULES_FAILED%% |
| Not Applicable | %%RULES_NA%% |
| Compliance Score | %%COMPLIANCE_SCORE%%% |

---

## Resource Inventory

| Resource Type | Current Name | Target Name | Status |
|---------------|-------------|-------------|--------|
%%RESOURCE_TABLE_ROWS%%

---

## Rule Results

### R001: Resource Group
- **Status**: %%R001_STATUS%%
- **Details**: %%R001_DETAILS%%

### R002: Region
- **Status**: %%R002_STATUS%%
- **Details**: %%R002_DETAILS%%

### R003: Naming Convention
- **Status**: %%R003_STATUS%%
- **Details**: %%R003_DETAILS%%
- **Current Names**: %%R003_CURRENT_NAMES%%
- **Target Names**: %%R003_TARGET_NAMES%%

### R004: Required Tags
- **Status**: %%R004_STATUS%%
- **Details**: %%R004_DETAILS%%
- **Missing Tags**: %%R004_MISSING_TAGS%%

### R005: Shared Storage
- **Status**: %%R005_STATUS%%
- **Details**: %%R005_DETAILS%%

### R006: Shared App Service Plan
- **Status**: %%R006_STATUS%%
- **Details**: %%R006_DETAILS%%

### R007: SWA Free Tier
- **Status**: %%R007_STATUS%%
- **Details**: %%R007_DETAILS%%

### R008: Shared PostgreSQL
- **Status**: %%R008_STATUS%%
- **Details**: %%R008_DETAILS%%

---

## Pipeline References

Files referencing current resource names that need updating:

%%PIPELINE_REFS%%

---

## Code References

Source code files referencing current resource names:

%%CODE_REFS%%

---

## Key Vault Secrets

Secrets that reference current resource names:

%%KEYVAULT_REFS%%

---

## Recommendations

%%RECOMMENDATIONS%%

---

## Next Steps

1. %%NEXT_STEP_1%%
2. %%NEXT_STEP_2%%
3. %%NEXT_STEP_3%%
