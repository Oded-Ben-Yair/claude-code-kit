# Training Platform Memory

## Architecture
- Frontend: React/Vite/TS on Azure Static Web App (`gray-field-011716a03.3.azurestaticapps.net`)
- Backend: Python Azure Functions (`func-training-prod`)
- DB: PostgreSQL `seekapa_training` on `postgres-seekapatraining-prod`
- Voice: ElevenLabs AI agents (15 levels: 5 EN + 5 AR + 5 ES)
- LLM: Azure OpenAI `gpt-5` (primary), `gpt-5.2`/`gpt-5-pro` (fallbacks)
- Email: Azure Communication Services

## Key Patterns
- `VITE_API_URL` is baked at build time from `.env.production` — must rebuild+redeploy frontend after changes
- GPT-5+ requires `max_completion_tokens` (NOT `max_tokens`) — breaks silently with `Unsupported parameter`
- Azure Functions CORS needs BOTH platform-level (`az functionapp cors add`) AND function-level OPTIONS handler
- Webhook email failures are non-fatal (caught, logged, don't break webhook response)
- Arabic reports: webhook sends full detailed report to `nissreen.s@axia.trade`; manual script `scripts/email_arabic_reports_nissreen.py` is daily backup

## Recent Changes (2026-03-05)
- Renamed function app: `sales-training-platform` -> `func-training-prod`
- LLM deployment: `gpt-4.1` -> `gpt-5` (with `max_completion_tokens` migration)
- Wired `send_full_arabic_report_email()` into webhook for Arabic sessions
- Language detection moved before LLM eval block to ensure availability at email routing

## Database
- Schema verified via `information_schema.columns`
- Core tables: `training_sessions`, `session_scores`, `training_levels`, `users`, `teams`
- 10 scoring dimensions (1-10 scale)
- Roles: rep, manager, director, admin

## Deploy
- Backend: `func azure functionapp publish func-training-prod --python`
- Frontend: `cd frontend && npm run build` then deploy to SWA
- DevOps: `git push azure master`
