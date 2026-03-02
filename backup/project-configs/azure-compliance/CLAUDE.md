# Azure Compliance Migration Project

## Purpose
Centralized project for Azure resource compliance migration across all Seekapa/Sentimark projects.
Follows sysadmin-issued Azure Resource Management Guidelines.

## Current State (2026-02-26)

### COMPLETED
- Phase 0: All 97 resources tagged with Brand/Project/Environment
- 11 Function Apps created, deployed, verified on ASP-AZAIPROJECTS
- All code references updated across 8 projects (231 files pushed to Azure DevOps)
- QC Analyzer old portal shut down (Function App stopped, SWA deleted)
- Sysadmin doc changes applied (new PG server, COMP- naming)
- COMP-SEEKAPAAITRAININGAPI-PROD env vars filled (13 settings)
- DB migration: 10/10 databases migrated to aiprojects-company-postsql
- All 8 Key Vault connection strings updated to new PG server
- All 7 app settings updated to point to new PG server
- VNet integration: 7 apps on Base subnet (all PG-connected apps)
- func-phone-spam-checker-prod: recreated on ASP-AZAIPROJECTS, VNet + identity + KV + settings
- Old plan-phone-spam-checker-prod (Consumption Y1) deleted
- All 14 old Function Apps STOPPED (grace period until March 1)

### BLOCKED — Kudu SCM 503
ASP-AZAIPROJECTS (P0v3, 1 worker, 21 sites) has overloaded SCM workers.
New apps cannot receive code deployments. Existing apps unaffected.
| Blocked Item | Status |
|---|---|
| func-phone-spam-checker-prod code deploy | Infra ready, code in blob, deploy pending |
| App Service renames (3 apps) | Cannot deploy code to new apps |

### REMAINING
- Deploy code to func-phone-spam-checker-prod (via pipeline or after Kudu recovery)
- App Service renames: app-realtime-monitor, sentimark-v2-api, sentimark-v2-frontend
- SWA frontend rebuilds (Training, Compliance)
- Delete 14 old Function Apps + 5 old ASPs (after March 1)
- SWA renames (6 apps, needs sysadmin tier policy)
- Old PG server decommission (7-day observation)

## New Function Apps (All on ASP-AZAIPROJECTS)
| App | Functions | Old Name |
|-----|-----------|----------|
| func-qc-telephony-prod | 5 | qc-telephony-api |
| func-qc-analyzer-prod | 50 | qc-call-analyzer-func |
| func-cs-agents-dev | 20 | axia-seekapa-crm |
| func-sentimark-prod | 200 | polymarket-analyzer |
| func-training-prod | 26 | sales-training-platform |
| func-compliance-exam-prod | 8 | seekapa-compliance-exam |
| func-automation-fabric-prod | 19 | func-marketing-newsletter |
| func-seekapa-sales-agent-prod | 6 | sales-agent-webhook |
| func-aeo-audit-prod | 4 | aeo-daily-audit |
| func-aeo-competitor-prod | 3 | aeo-competitor-refresh |
| func-client-eval-prod | 2 | func-client-eval-agent |

## PostgreSQL Servers
| | OLD (migrating from) | NEW (target) |
|--|-----|-----|
| FQDN | postgres-seekapatraining-prod.postgres.database.azure.com | aiprojects-company-postsql.postgres.database.azure.com |
| Admin | seekapaadmin (password changed by sysadmin) | postuser / credentials in session |
| Access | Public (firewall rules) | VNet only (AZAI_VNET/postprivate) |
| Version | PG 16 | PG 18 |

### VNet Migration Approach
New PG server is VNet-only. Migration done via Azure Container Instance in AZAI_VNET/aci-migration subnet.
```bash
# Create ACI for migration
az container create --resource-group AZAI_group --name pg-migration-runner \
  --image postgres:16-alpine --os-type Linux --vnet AZAI_VNET --subnet aci-migration \
  --command-line "sleep 3600" --cpu 1 --memory 2 --restart-policy Never

# Run dump+restore inside ACI
az container exec --resource-group AZAI_group --name pg-migration-runner --exec-command "sh"

# Clean up when done
az container delete --resource-group AZAI_group --name pg-migration-runner --yes
```

## Compliance Rules
| Rule | Pattern | Example |
|------|---------|---------|
| R001 | Resource Group: AZAI_group | Single RG |
| R002 | Region: swedencentral | SWAs exempt (westeurope) |
| R003 | Naming: `[type]-[project]-[env]` or `COMP-[PROJECT]-[ENV]` | `func-sentimark-prod` |
| R004 | Tags: Brand/Project/Environment | All 3 required |
| R005 | Storage: stsentimarkv2 | Shared storage |
| R006 | ASP: ASP-AZAIPROJECTS (P0v3) | Shared premium plan |
| R007 | SWA: Standard tier | TBD |
| R008 | PostgreSQL: aiprojects-company-postsql | New shared server (VNet only) |

## Key Files
| File | Purpose |
|------|---------|
| `.claude/status.json` | Current migration state (machine-readable) |
| `.claude/decisions.log` | Decision audit trail |
| `migration-log.md` | Complete audit trail of all operations |
| `pending-actions.md` | Prioritized TODO list |
| `db-migration-plan.md` | Database migration plan |
| `sysadmin-doc-changes-20260223.md` | Sysadmin doc diff analysis |
| `~/.claude/compliance-plans/` | Per-project rename plans (15 files) |
| `~/.claude/compliance-state.json` | Compliance audit state |
| `~/.claude/configs/azure-compliance-rules.json` | Sysadmin rules config |

## Memory MCP
Entity: `azure-compliance-migration-20260222` — contains full session history from Feb 22-24.

## Lessons Learned
- `az resource tag` does full PUT on container apps — use `az tag update --operation Merge`
- `func` CLI needs dotnet — use `az functionapp deployment source config-zip --build-remote true`
- `.python_packages/` in zip can cause 0-function deploys — exclude it
- Kudu SCM 503 after creating many apps on same ASP — wait 1-2 hours
- VNet-integrated PG servers can NEVER have public access enabled
- Use ACI in same VNet for DB migration (dump+restore bridge)
- `uuid-ossp` extension must be allow-listed on Azure PG before restore
- Old server admin password was changed by sysadmin — use app user passwords from Key Vault
- `az postgres flexible-server db create` works via management plane (no network access needed)
- `az functionapp deployment source config-zip` ALWAYS queries SCM `/api/settings` first — if SCM returns empty, az CLI crashes with JSONDecodeError. No workaround in az CLI.
- P0v3 ASP with 21 sites: Kudu SCM 503 for newly created apps. Existing apps SCM works fine. SCM worker pool is per-ASP, not per-app.
- `WEBSITE_RUN_FROM_PACKAGE` with blob URL requires pre-built deps in `.python_packages/lib/site-packages/` — but Python Functions on Linux may not find them without Oryx-generated PYTHONPATH setup
- Bearer token auth works for SCM root (bypasses 401) but Kudu API itself returns 503 — different issue from auth
- Azure DevOps pipeline agents use their own deployment infrastructure, not the ASP's Kudu workers — preferred deploy path when Kudu is overloaded
- `az webapp deploy --type zip` also goes through Kudu — same 503 failure as `config-zip`
- Download deployed code from working old app via SCM `/api/zip/site/wwwroot/` — useful for content cloning
