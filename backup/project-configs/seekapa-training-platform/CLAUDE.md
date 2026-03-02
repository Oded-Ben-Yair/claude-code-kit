# Training Platform - Project Configuration

---

## Persona (Auto-Activated)

You are a **Principal Engineer and Instructional Designer** building an educational platform. You automatically:
- Create clear, educational content anyone can understand
- Design progressive learning paths
- Ensure WCAG 2.1 AA accessibility compliance
- Build engaging user experiences
- Focus on measurable learning outcomes

---

## Routing (Auto-Select)

| Task | Route To |
|------|----------|
| Content creation | GPT-5 Pro (`azure_brainstorm`) |
| UI/UX design | Gemini + `design-to-code` skill |
| Code implementation | Codex Max (`azure_code_review`) |
| Accessibility review | Codex Max with a11y focus |
| Learning design | GPT-5 Pro |

---

## Output Format (Auto-Apply)

- Documentation: Learner-friendly language
- Code comments: Explain "why" not just "what"
- UI text: Review for clarity and accessibility
- Error messages: Helpful and non-technical

---

## Constraints (Auto-Apply)

- Content must be clear for non-technical users
- WCAG 2.1 AA compliance required
- Keyboard navigation must work
- Include examples for complex concepts

---

## Plan Storage

**Plans location:** `.claude/plans/` (this project's directory)
- Format: `YYYY-MM-DD-<feature-name>.md`
- NEVER save to global `~/.claude/plans/`

---

## Project Overview

Voice-based training platform for Seekapa sales representatives with ElevenLabs AI voice agents, real-time scoring, and performance analytics. Features **15 training levels** (5 English + 5 Arabic + 5 Spanish LATAM) with AI-powered session evaluation.

## Development Commands

```bash
# Frontend (React/Vite on port 5173, proxies /api to backend)
cd frontend && npm run dev

# Backend (Azure Functions on port 7071)
cd backend && func start

# Run both together (separate terminals)
```

### Testing

```bash
# All E2E tests (Playwright)
cd frontend && npm run test

# Specific test suites
npm run test:personal     # Personal dashboard tests
npm run test:team         # Team dashboard tests
npm run test:headed       # Run with visible browser
npm run test:ui           # Playwright UI mode

# Backend unit tests
cd backend && python -m pytest tests/
```

### Building & Deployment

```bash
# Frontend build
cd frontend && npm run build

# Backend deployment
cd backend && func azure functionapp publish func-training-prod --python

# Apply database migrations
./scripts/apply-database-schema.sh
```

## Architecture

### Frontend (React + Vite + TypeScript)

**Routing hierarchy** (`frontend/src/App.tsx`):
- Public: `/`, `/training`, `/guest-report/:sessionId`, `/login`, `/register`
- Rep+ role: `/practice`, `/personal`, `/session/:sessionId`
- Manager+ role: `/manager`, `/team`
- Director+ role: `/branch`

**State management**:
- `AuthContext` - JWT auth, roles (rep/manager/director/admin), token in localStorage as `auth_token`
- `BrandContext` - Theme switching (Seekapa/Axia brands)
- TanStack Query for server state (30s stale time, auto-refetch)

**Path alias**: `@/*` → `./src/*`

### Backend (Python Azure Functions)

**Shared modules** (`backend/shared/`):
- `database.py` - PostgreSQL connection pool (1-10 connections, singleton)
- `auth.py` - JWT + bcrypt password hashing
- `decorators.py` - `@require_auth`, `@require_role('manager')`
- `elevenlabs_client.py` - ElevenLabs API integration
- `llm_evaluator.py` - OpenAI-based session scoring

**Key function categories**:
- Auth: `login`, `register`, `set_manager_role`
- Training: `start_session`, `start_guest_session`, `get_elevenlabs_token`, `list_levels`
- Data: `get_session_detail`, `personal_stats`, `team_stats`, `get_team_performance`
- Background: `sync_sessions` (5-min timer), `webhook_elevenlabs`

### Database (PostgreSQL)

**IMPORTANT - Isolated Database Access**:
- **Database**: `seekapa_training`
- **User**: `training_app_user` (NOT seekapaadmin!)
- **Server**: `postgres-seekapatraining-prod.postgres.database.azure.com`
- **Key Vault Secret**: `TrainingPlatform-DbConnectionString`

This user can ONLY access `seekapa_training` database. Other project databases are blocked.

**Core tables**: `users`, `teams`, `branches`, `organizations`, `training_levels`, `training_sessions`, `session_scores`, `analysis_reports`

**10 scoring dimensions**: greeting, clarity, empathy, objection_handling, product_knowledge, closing_technique, professionalism, listening_skills, pace_rhythm, overall_effectiveness (1-10 scale)

**Roles**: rep, manager, director, admin (database check constraint)

## Key Integrations

### ElevenLabs Voice
- **15 AI agents** (5 English + 5 Arabic + 5 Spanish LATAM)
- Agent IDs stored in `training_levels.elevenlabs_agent_id`
- Sessions sync via timer function every 5 minutes
- Webhook endpoint for real-time completion events

**Training Levels by Language**:

| Language | Levels | Agent IDs | Cultural Focus |
|----------|--------|-----------|----------------|
| English | 5 | agent_2901k8tq... - agent_4501k8ts... | Western sales approach |
| Arabic | 5 | agent_7601k8ty... - agent_2601k8tz... | Gulf Arabic business etiquette |
| Spanish (LATAM) | 5 | agent_ES_LVL1... - agent_ES_LVL5... | Latin American markets (Colombia, Mexico, Argentina, Chile) |

**Spanish Levels** (Latin America):
1. **Principiante** - María Rodríguez (Bogotá, Colombia) - Basic trust-building, withdrawal concerns
2. **Elemental** - Carlos Hernández (Mexico City, Mexico) - Platform knowledge, regulatory transparency
3. **Intermedio** - Diego Martínez (Buenos Aires, Argentina) - **Ethics testing**: refuses manipulation requests
4. **Avanzado** - Ana Morales (Santiago, Chile) - Technical sophistication, institutional-grade answers
5. **Experto** - Roberto Guzmán (Medellín, Colombia) - High-net-worth scenarios, multi-layered objections

### Session Flow
1. User starts session → `start_session` creates DB record
2. User talks to ElevenLabs agent (external URL)
3. Timer/webhook detects completion → fetch transcript
4. `llm_evaluator` scores across 10 dimensions
5. Results stored in `session_scores` + `analysis_reports`

## Environment Variables

**Frontend** (`.env.production`):
- `VITE_API_URL` - Backend API endpoint

**Backend** (`local.settings.json`):
- `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
- `ELEVENLABS_API_KEY`
- `AZURE_OPENAI_KEY`, `AZURE_OPENAI_ENDPOINT`
- `JWT_SECRET`, `JWT_EXPIRY_HOURS`

## Production URLs

- Frontend: https://gray-field-011716a03.3.azurestaticapps.net
- Backend: Azure Function App `func-training-prod`
- Resource Group: `AZAI_group`

## Common Tasks

**Check backend logs**:
```bash
az webapp log tail --resource-group AZAI_group --name func-training-prod
```

**Query training levels**:
```sql
SELECT id, name, language, elevenlabs_agent_id FROM training_levels;
```

**Test API endpoints**:
```bash
./scripts/test_all_endpoints.sh
```

**Safe database migration**:
```bash
./scripts/run-migration.sh  # Has confirmation prompt
```

## Security Notes

- **Never use `seekapaadmin`** in application code - only for admin tasks
- **Passwords are in Key Vault**: `https://kv-seekapa-apps.vault.azure.net/`
- **`.env.example`** provided - copy to `.env` and fill in values
- This project's DB user is **blocked** from accessing other databases (Sentimark, QC, etc.)

## Repository

**Azure DevOps**: https://dev.azure.com/Corp-domain/Corp-AI/_git/seekapa-training-platform

```bash
# Clone (SSH - preferred)
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/seekapa-training-platform

# Push
git push azure <branch>
```

