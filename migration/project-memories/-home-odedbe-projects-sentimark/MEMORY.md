# Sentimark Project Memory

## Key Learnings

### psycopg2 InFailedSqlTransaction (2026-03-01)
When multiple queries run on the same psycopg2 connection sequentially, if ANY query fails, the connection enters `InFailedSqlTransaction` state. ALL subsequent queries fail silently until `conn.rollback()` is called. Always add `try: conn.rollback() except: pass` in every exception handler when sharing a DB connection across multiple queries. See `shared/ml/regime_radar.py` for the fix pattern.

### Azure Deploy Patterns (2026-03-01)
- Kudu credentials go stale. Use `az webapp deploy --type zip --async true` or `az functionapp deployment source config-zip --build-remote true` instead.
- `SCM_DO_BUILD_DURING_DEPLOYMENT` must be `true` for Python function apps that need pip install during deploy.
- Consumption Plan cold starts take 60-90 seconds after restart.

### Market Radar Architecture (2026-03-01)
- `regime_radar.py:classify_regime()` runs 4 sequential DB queries on shared connection: VIX → FGI → correlation → geopolitical
- Crisis-context endpoint in `function_app.py` is independent (its own connection)
- Frontend regime page at `sentimark-v2/frontend/app/v2/regime/page.tsx` with components in `regime/components/`
- REGIME_CONFIG maps backend regime names to UI display. Backend normalizes `bull`→`risk_on`, `bear`→`risk_off`

### Consensus Algorithm Key Facts (2026-03-02)
- `_calculate_consensus()` at `shared/rotation/llm_prediction.py:1955` — the core function
- Phase 1 fixes wrapped in `CONSENSUS_V2_FIXED` env var (default true, false to revert)
- Old bug: `score = 0.6 * conf` AND `effective_weight = w * conf` → conf² crushed signal
- Old bug: neutral LLMs (score=0) diluted directional weighted average denominator
- Fix: score=0.6 (fixed), weight=w (no conf), neutral excluded from directional avg
- MIN_LLMS_REQUIRED changed 1→2 at line 535
- Category router at `shared/ml/category_router.py` — shadow mode via `ENABLE_CATEGORY_ROUTER` env var
- Router uses `_is_router_enabled()` (reads env at call time, not import time) for testability
- Accuracy tracker at `shared/ml/llm_accuracy_tracker.py` — needs migration 068 applied
- Migration 068 creates `llm_accuracy_stats` table — PENDING (DB unreachable from home)
- Deploy approach: `az functionapp deployment source config-zip --build-remote true` works; `func publish` times out; Oryx can be flaky (retry once)
- Pipeline `sentimark-backend-deploy` ID=101 — has been failing, use manual az CLI deploy

### DB Access from Home (2026-03-02)
- Both DB hosts unreachable from WSL at home (firewall/VPN)
- `postgres-seekapatraining-prod.postgres.database.azure.com` — times out
- `aiprojects-company-postsql.postgres.database.azure.com` — DNS fails
- API endpoints work (they query DB from Azure, not from WSL)
- Workaround: use API endpoints for monitoring, save DB migrations for office

### Users Table Schema (2026-03-08)
- `users` table does NOT have a `tier` column — queries must use dynamic column discovery
- Login and register endpoints need `information_schema.columns` check before referencing `tier`
- Admin users endpoint already handles this with `COALESCE(tier, 'free')` fallback
- Pattern: always check `information_schema.columns WHERE table_name = 'users' AND column_name = 'tier'` before SELECT/INSERT

### Admin Panel Access (2026-03-08)
- Role-based: `ADMIN_EMAILS` env var on backend (comma-separated emails)
- Login returns `role: 'admin'` when email matches → stored in JWT → enforced by middleware
- Admin user: `admin@sentimark.app` (created 2026-03-08)
- To add admins: `az functionapp config appsettings set -g AZAI_group -n func-sentimark-prod --settings "ADMIN_EMAILS=admin@sentimark.app,new@email.com"`
- Middleware at `middleware.ts:74-84` checks `token.role === 'admin'` for `/v2/admin/*`
- Admin layout at `app/v2/admin/layout.tsx` uses `useSession()` to check role (replaced research mode check)

### Frontend Deploy (2026-03-08)
- `deploy.sh` in `sentimark-v2/frontend/` is the ONLY way to deploy frontend
- Build requires `NODE_OPTIONS='--max-old-space-size=4096'`
- Deploy uses `az webapp deploy --type zip` (not raw curl to Kudu)
- Takes ~2.5 minutes total (npm ci + build + zip + deploy + verify)

## Topic Files
- `validation/mobile-audit-assets.md` — Asset pages mobile audit (25 issues)
- `validation/mobile-audit-all-pages.md` — All other pages mobile audit (37 issues)
- `validation/VERIFICATION-REPORT.md` — Production verification (24 screenshots, 10 API endpoints)
