# Azure Resource Rename Plan

**Project**: %%PROJECT_NAME%%
**Brand**: %%BRAND%%
**Plan Created**: %%PLAN_DATE%%
**Plan Status**: %%PLAN_STATUS%% (draft | approved | executing | complete | rolled-back)

---

## IMPORTANT: Azure Resources Cannot Be Renamed In-Place

Azure does not support renaming resources. This plan implements:
1. **Create** new resource with compliant name
2. **Migrate** all settings, configurations, and data
3. **Swap** traffic from old to new
4. **Decommission** old resource after 7-day grace period

---

## Rename Operations

%%RENAME_OPERATIONS%%

### Operation Template (per resource):

#### %%OPERATION_INDEX%%: %%RESOURCE_TYPE%% -- %%CURRENT_NAME%% -> %%TARGET_NAME%%

**Impact Analysis**:
- Pipeline YAML files: %%PIPELINE_FILES%%
- Source code references: %%CODE_FILES%%
- Secret Manager secrets: %%KEYVAULT_SECRETS%%
- DNS/domain dependencies: %%DNS_DEPS%%
- Downstream consumers: %%DOWNSTREAM%%

**Step-by-Step Execution**:

1. **Create new resource**:
```bash
%%CREATE_COMMAND%%
```

2. **Migrate settings**:
```bash
# Export settings from old
az %%RESOURCE_CLI%% config appsettings list -n %%CURRENT_NAME%% -g Az-ai -o json > /tmp/%%CURRENT_NAME%%-settings.json
# Import to new
az %%RESOURCE_CLI%% config appsettings set -n %%TARGET_NAME%% -g Az-ai --settings @/tmp/%%CURRENT_NAME%%-settings.json
```

3. **Deploy code to new resource**:
```bash
%%DEPLOY_COMMAND%%
```

4. **Verify new resource**:
```bash
%%VERIFY_COMMAND%%
```

5. **Update pipeline YAML**:
%%PIPELINE_UPDATES%%

6. **Update Secret Manager secrets**:
%%KEYVAULT_UPDATES%%

7. **Update code references**:
%%CODE_UPDATES%%

8. **Tag resources**:
```bash
az resource tag --ids %%NEW_RESOURCE_ID%% --tags Brand=%%BRAND%% Project=%%PROJECT_NAME%% Environment=%%ENVIRONMENT%%
```

9. **Swap traffic** (requires helpdesk ticket for custom domains):
%%TRAFFIC_SWAP%%

10. **Grace period** (7 days):
- Old resource remains active as fallback
- Monitor new resource health and error rates
- Grace period ends: %%GRACE_PERIOD_END%%

11. **Decommission old resource**:
```bash
# HUMAN APPROVAL REQUIRED
az resource delete --ids %%OLD_RESOURCE_ID%%
```

**Rollback Procedure**:
1. Revert pipeline YAML to reference old resource name
2. Revert code references
3. Restore Secret Manager secrets if changed
4. Old resource is still running during grace period -- traffic reverts automatically if DNS not yet changed

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Pipeline failure after name change | Medium | High | Update YAML before decommissioning |
| DNS propagation delay | Low | Medium | 7-day grace period |
| Settings migration miss | Medium | High | Diff app settings before/after |
| Consumption -> ASP migration | High | High | Separate infrastructure change |

---

## Approvals Required

- [ ] Rename plan reviewed by human operator
- [ ] Per-operation approval during execution
- [ ] Helpdesk ticket for custom domain (if applicable)
- [ ] Grace period expiry confirmation before decommission

---

## Execution Log

| Date | Action | Resource | Result | Operator |
|------|--------|----------|--------|----------|
%%EXECUTION_LOG%%
