# Automation Fabric Memory

## Email Pipeline (V10)

### Architecture (2026-03-05)
- **Production delivery**: Azure Container Apps Job `job-email-autofabric-prod` in `sentimark-env`
- **Cron**: `5 5 * * *` (every day, 5:05 AM UTC = 7:05 Israel) — fixed 2026-03-06 (was `0-4` Sun-Thu only)
- **ACR image**: `seekapatrainingacr.azurecr.io/autofabric-email-pipeline:latest`
- **Build**: `bash src/container-email/build.sh` assembles 18 files from `src/runtime/` into `src/container-email/app/`
- **Key Vault secrets**: `AutomationFabric-AcsConnectionString`, `AutomationFabric-FmpApiKey`, `AutomationFabric-XaiApiKey`, `MarketingNewsletter-StorageConnection`
- **WSL cron**: DISABLED (commented out 2026-03-04)
- **Pipeline stage**: Stage 4 in `azure-pipelines.yml` builds + pushes on email-related changes

### Container Build Gotchas
- `utils/__init__.py`, `integrations/__init__.py`, `activities/__init__.py` must be MINIMAL in container (runtime versions import modules not in container)
- `utils/blob_storage.py` REQUIRED for landing page deploy (first run failed without it)
- `utils/event_priority.py` NOT included (non-critical, just skips critical events section)
- Script needs `signal` import for SIGALRM global timeout (Unix only, `hasattr` guard for Windows)

### Script Hardening (2026-03-05, updated 2026-03-06)
- ACS connection string: env var `ACS_CONNECTION_STRING` — must be read AFTER `load_env()`, not at module level (fixed line 1830)
- Global timeout: `signal.alarm(540)` = 9 minutes
- ACS poller: `poller.result(timeout=120)`
- FMP client + Grok API already had `timeout=30`

### Recipients (27 total)
- en: 10, ar: 9, es: 4, pt: 4

## Compliance
- Container Apps Job naming: `job-email-autofabric-prod` follows `[type]-[project]-[env]`
- Tags: Brand=Sentimark, Project=automation-fabric, Environment=prod
- Region: swedencentral
- ACR: `seekapatrainingacr` (both `seekapatrainingacr` and `sentimarkregistry` exist in AZAI_group)
