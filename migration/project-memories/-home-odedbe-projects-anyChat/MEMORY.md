# anyChat Project Memory

## Project Overview
Multi-tenant social media comment management platform: auto-moderation (keyword rules + AI), auto-reply (LangGraph agent), unified dashboard across 7 platforms.

## Live URLs
- Frontend: https://happy-pebble-0b573a503.6.azurestaticapps.net
- Backend: https://app-anychat-prod.azurewebsites.net
- Health: https://app-anychat-prod.azurewebsites.net/health

## Key Technical Decisions
- **bcrypt direct** (not passlib) — passlib unmaintained, crashes with bcrypt 5.0
- **SET LOCAL interpolation** — PostgreSQL SET doesn't support $1 parameterized queries; use UUID-validated string interpolation
- **Oryx default startup** — don't use custom startup commands; Oryx handles tar.zst extraction
- **SSE state extraction** — `sse_state.py` breaks circular import between app.py and dashboard.py
- **Kudu publish profile deploy** — SP lacks Contributor RBAC; publish profile works without it

## Azure Resources
| Resource | Name |
|----------|------|
| App Service | app-anychat-prod (P1v3, AZAI_VNET/Base) |
| Static Web App | swa-anychat-prod (Standard) |
| PostgreSQL | anychat on aiprojects-company-postsql |
| Redis | redis-anychat-prod |
| Pipeline | anyChat-CI-CD (ID: 112) |

## Meta Integration
- App ID: 986872827178955
- Webhook verify token: anychat-verify-b4ed7b8f71e796fc
- OAuth scopes: pages_manage_metadata, pages_read_engagement, pages_show_list, pages_manage_posts
- Full OAuth token exchange implemented (code → long-lived → page tokens → Key Vault → webhook subscribe)

## Session History
- 2026-02-24: Phases 1-4 built (211 tests). Blocked on Meta credentials.
- 2026-02-26: Meta credentials received. Fixed 12 bugs. Deployed backend + frontend. Implemented OAuth. 222 tests. MVP LIVE.
