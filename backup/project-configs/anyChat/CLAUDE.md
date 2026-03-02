# anyChat — Social Media Automation Platform

## Project Overview
Multi-tenant social media comment management: auto-moderation (keyword rules + AI), auto-reply (LangGraph agent), unified dashboard across Facebook, Instagram, WhatsApp, X/Twitter, LinkedIn, TikTok, YouTube.

## Tech Stack
- **Backend**: FastAPI + asyncpg + PostgreSQL (RLS) + Redis
- **AI**: GPT-5.2 via Azure AI Foundry, LangGraph custom StateGraph
- **Frontend**: React + Vite + TypeScript + TailwindCSS
- **Infra**: Azure App Service (API), Azure Functions (polling), Key Vault (secrets)
- **CI/CD**: Azure DevOps pipelines

## Database
- **Name**: `anychat` on `aiprojects-company-postsql.postgres.database.azure.com`
- **User**: `anychat_app_user`
- **Key Vault Secret**: `AnyChat-DbConnectionString`
- **RLS**: All tables use `app.current_tenant_id` session variable for tenant isolation

## Key Patterns

### Multi-Tenant Isolation
```python
# Every DB operation uses tenant_connection context manager
async with tenant_connection(pool, tenant_id) as conn:
    rows = await conn.fetch("SELECT * FROM comments")  # RLS filters automatically
```

### OAuth Tokens — Key Vault Only
```
Secret name format: AnyChat-{TenantSlug}-{Platform}-Token
Example: AnyChat-acme-agency-facebook-Token
NEVER store tokens in database or code.
```

### Platform Adapter Contract
All 7 adapters implement `PlatformAdapter` ABC from `src/platforms/base.py`.
Changing the ABC affects ALL adapters — treat as high-impact change.

### Dual-Layer Moderation
1. **Keyword Rules** (Layer 1): Deterministic, zero-cost, per-tenant cached rules
2. **AI Classification** (Layer 2): GPT-5.2 structured output, circuit breaker protected

### Auto-Reply Agent (LangGraph)
7-node StateGraph: input_guard → classify → route → generate → validate → approval → respond
Max 1 retry on validation failure. Degraded-pass on validator error (first attempt).

## File Ownership (Critical Paths)
| File | Impact | Risk |
|------|--------|------|
| `src/platforms/base.py` | ABC contract for all 7 adapters | Interface change breaks everything |
| `src/platforms/token_manager.py` | OAuth lifecycle | Bug = all accounts disconnect |
| `src/moderation/engine.py` | Comment fate decisions | Bug = spam through or legit hidden |
| `src/db/tenant_context.py` | RLS isolation | Bug = cross-tenant data leakage |
| `src/agent/graph.py` | Auto-reply core | Core AI logic |
| `src/api/routes/webhooks/meta.py` | Real-time events | Downtime = missed comments |

## Platform Rate Limits
| Platform | Limit | Notes |
|----------|-------|-------|
| Facebook | 200/hr/user | Free |
| Instagram | 200/hr/user | Same as Facebook |
| X/Twitter | 100/15min (Basic) | $100/mo minimum |
| LinkedIn | 100/day | Conservative polling |
| TikTok | 600/min | No hide/delete |
| YouTube | 10K quota units/day | Writes expensive |

## Commands
```bash
make install    # Install dependencies
make dev        # Install with dev deps
make test       # Run tests with coverage
make lint       # Ruff check
make format     # Ruff format
make run        # Start dev server
make migrate-up # Run Alembic migrations
```

## Azure Resources
| Resource | Name |
|----------|------|
| App Service | app-anychat-prod |
| Function App | func-anychat-polling-prod |
| Redis Cache | redis-anychat-prod |
| Static Web App | swa-anychat-prod (https://happy-pebble-0b573a503.6.azurestaticapps.net) |
| Key Vault | kv-seekapa-apps (shared) |
| Database | anychat (shared PostgreSQL) |
