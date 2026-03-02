# Spanish Training Levels - DEPLOYMENT READY

**Date**: 2025-12-08
**Status**: ✅ **ALL 5 AGENTS CREATED SUCCESSFULLY**

---

## 🎉 ElevenLabs Agents Created

All 5 Spanish conversational AI agents have been successfully created via API.

| Level | Persona | City | Agent ID |
|-------|---------|------|----------|
| 1 | María Rodríguez | Bogotá, Colombia | `agent_4101kbyvr92eezxa9697g4188r9p` |
| 2 | Carlos Hernández | Mexico City, Mexico | `agent_1201kbyvracafada1qm4fyrd7wh3` |
| 3 | Diego Martínez | Buenos Aires, Argentina | `agent_5801kbyvrb9afrbsewhnfmgjfwv8` |
| 4 | Ana Morales | Santiago, Chile | `agent_5801kbyvrc77eyns14pntxse0ett` |
| 5 | Roberto Guzmán | Medellín, Colombia | `agent_9101kbyvre8cf4c9qbea5hnn92hc` |

**Verification**: All agents visible at https://elevenlabs.io/app/conversational-ai

---

## 📋 Deployment Steps

### 1. Apply Database Migration

Run from environment with Azure PostgreSQL access (Azure Cloud Shell or whitelisted IP):

```bash
cd /home/odedbe/projects/seekapa-training-platform

# Set admin credentials
export PGPASSWORD="<CURRENT_ADMIN_PASSWORD>"

# Apply migration
psql "host=postgres-seekapatraining-prod.postgres.database.azure.com port=5432 dbname=seekapa_training user=seekapaadmin sslmode=require" -f database/migrations/007_add_spanish_support.sql
```

**What it does**:
- Adds 'spanish' to language check constraint
- Inserts 5 Spanish training levels with placeholder agent IDs
- Unlocks Spanish Level 1 for all existing users

### 2. Update Agent IDs

```bash
# Set app user credentials
export POSTGRES_HOST="postgres-seekapatraining-prod.postgres.database.azure.com"
export POSTGRES_PORT="5432"
export POSTGRES_DB="seekapa_training"
export POSTGRES_USER="training_app_user"
export POSTGRES_PASSWORD="xxo19ZghEk*V20XJ4dUN9dW#"

# Run update script (already has real agent IDs!)
python3 update_spanish_agent_ids.py
```

**Agent IDs already configured in script**:
```python
SPANISH_AGENT_IDS = {
    1: 'agent_4101kbyvr92eezxa9697g4188r9p',
    2: 'agent_1201kbyvracafada1qm4fyrd7wh3',
    3: 'agent_5801kbyvrb9afrbsewhnfmgjfwv8',
    4: 'agent_5801kbyvrc77eyns14pntxse0ett',
    5: 'agent_9101kbyvre8cf4c9qbea5hnn92hc',
}
```

### 3. Deploy Backend

```bash
cd backend
func azure functionapp publish sales-training-platform --python
```

**What changed**:
- `shared/llm_evaluator.py`: Added 'es' to VALID_LANGUAGES
- `start_guest_session/__init__.py`: Language validation includes 'es'
- `webhook_elevenlabs/__init__.py`: Spanish language detection

### 4. Deploy Frontend

Frontend deploys automatically via GitHub Actions when pushed to main.

**What changed**:
- `types/training.ts`: Language type includes 'es'
- `utils/agentMapper.ts`: Spanish agent registry with real IDs
- `utils/levelDefinitions.ts`: Spanish level metadata
- `pages/PracticePage.tsx`: Spanish filter button
- `pages/PersonalDashboard.tsx`: Fixed auth context (no hardcoded userId)
- `pages/TeamDashboard.tsx`: Fixed auth context (no hardcoded teamId)

**Manual deployment** (if needed):
```bash
cd frontend
npm run build
# Deployment handled by Static Web App
```

---

## ✅ Code Changes Summary

### Files Modified (13)

**Backend (4)**:
1. `backend/shared/llm_evaluator.py` - VALID_LANGUAGES = {'en', 'ar', 'es'}
2. `backend/start_guest_session/__init__.py` - Language validation
3. `backend/webhook_elevenlabs/__init__.py` - Spanish detection
4. `database/migrations/002_seed_essential_data.sql` - Fixed Arabic agent IDs

**Frontend (6)**:
5. `frontend/src/types/training.ts` - Language type
6. `frontend/src/utils/agentMapper.ts` - Spanish registry with REAL agent IDs
7. `frontend/src/utils/levelDefinitions.ts` - Spanish metadata
8. `frontend/src/pages/PracticePage.tsx` - Spanish filter
9. `frontend/src/pages/PersonalDashboard.tsx` - Auth context fix
10. `frontend/src/pages/TeamDashboard.tsx` - Auth context fix

**Database (2)**:
11. `database/migrations/007_add_spanish_support.sql` - NEW migration
12. `update_spanish_agent_ids.py` - Updated with REAL agent IDs

**Scripts (1)**:
13. `scripts/create_spanish_agents.py` - NEW automation script

### Files Created (6)

1. `.claude/spanish_level_1.txt` - María prompt (13,036 chars)
2. `.claude/spanish_level_2.txt` - Carlos prompt (15,881 chars)
3. `.claude/spanish_level_3.txt` - Diego prompt (16,260 chars)
4. `.claude/spanish_level_4.txt` - Ana prompt (11,830 chars)
5. `.claude/spanish_level_5.txt` - Roberto prompt (15,463 chars)
6. `.claude/spanish_agents_created.json` - Creation results

**Total**: 72,470 characters of Spanish prompts

---

## 🧪 Testing

### Backend API Tests

```bash
# List Spanish levels
curl "http://localhost:7071/api/levels?language=spanish" | jq

# Start Spanish guest session
curl -X POST http://localhost:7071/api/sessions/start-guest \
  -H "Content-Type: application/json" \
  -d '{
    "anonymous_user_id": "test-es-001",
    "guest_name": "Test User",
    "guest_brand": "Seekapa",
    "guest_branch": "LATAM",
    "language": "es",
    "level": 1,
    "agent_id": "agent_4101kbyvr92eezxa9697g4188r9p"
  }' | jq
```

### Frontend Tests

```bash
cd frontend

# Run all E2E tests
npm run test

# Specific test (create this)
npm run test -- spanish-levels.spec.ts
```

### Manual Testing Checklist

- [ ] Spanish flag button appears on Practice Page
- [ ] Clicking Spanish shows 5 levels
- [ ] Level cards display correct Spanish names
- [ ] Clicking "Start Practice" launches agent
- [ ] Agent speaks Spanish correctly
- [ ] Conversation completes and webhook fires
- [ ] Session shows in dashboard with scores
- [ ] Transcript is in Spanish
- [ ] LLM evaluation works for Spanish

---

## 📊 Database Verification

After deployment, verify with:

```sql
-- Check Spanish levels exist
SELECT level_number, language, name, elevenlabs_agent_id
FROM training_levels
WHERE language = 'spanish'
ORDER BY level_number;

-- Expected output:
-- 1 | spanish | Principiante - Nivel 1 | agent_4101kbyvr92eezxa9697g4188r9p
-- 2 | spanish | Elemental - Nivel 2    | agent_1201kbyvracafada1qm4fyrd7wh3
-- 3 | spanish | Intermedio - Nivel 3   | agent_5801kbyvrb9afrbsewhnfmgjfwv8
-- 4 | spanish | Avanzado - Nivel 4     | agent_5801kbyvrc77eyns14pntxse0ett
-- 5 | spanish | Experto - Nivel 5      | agent_9101kbyvre8cf4c9qbea5hnn92hc

-- Count total levels (should be 15)
SELECT language, COUNT(*) FROM training_levels GROUP BY language;

-- Expected:
-- arabic   | 5
-- english  | 5
-- spanish  | 5
```

---

## 🎯 Success Criteria

- [x] 5 ElevenLabs Spanish agents created via API
- [x] Frontend code updated with real agent IDs
- [x] Backend validation supports 'es' language
- [x] Database migration file ready
- [x] Update script ready with real IDs
- [ ] Migration applied to production (PENDING - needs Azure access)
- [ ] Agent IDs updated in database (PENDING - needs Azure access)
- [ ] Backend deployed to Azure Functions (PENDING)
- [ ] Frontend deployed to Static Web App (PENDING)
- [ ] End-to-end testing completed (PENDING)

---

## 🚀 Next Actions

1. **Run from Azure Cloud Shell** or whitelisted IP:
   ```bash
   # Apply migration
   psql "host=postgres-seekapatraining-prod.postgres.database.azure.com ..." -f database/migrations/007_add_spanish_support.sql

   # Update agent IDs
   python3 update_spanish_agent_ids.py
   ```

2. **Deploy Backend**:
   ```bash
   cd backend && func azure functionapp publish sales-training-platform
   ```

3. **Deploy Frontend** (automatic on git push):
   ```bash
   git add .
   git commit -m "feat: Add Spanish (LATAM) training levels with 5 agents"
   git push origin master
   ```

4. **Test in Production**:
   - Navigate to https://gray-field-011716a03.3.azurestaticapps.net/practice
   - Click Spanish flag
   - Start Level 1 session
   - Complete conversation
   - Verify scores and transcript

---

## 📝 Platform Status After Deployment

| Language | Levels | Status |
|----------|--------|--------|
| English | 5 | ✅ Production |
| Arabic | 5 | ✅ Production |
| Spanish (LATAM) | 5 | ✅ **CODE READY** |

**Total Training Levels**: 15 (5 per language)

**Personas Created**:
- 🇨🇴 María Rodríguez (Bogotá) - Beginner trust-building
- 🇲🇽 Carlos Hernández (Mexico City) - Platform knowledge
- 🇦🇷 Diego Martínez (Buenos Aires) - **Ethics testing**
- 🇨🇱 Ana Morales (Santiago) - Technical sophistication
- 🇨🇴 Roberto Guzmán (Medellín) - High-net-worth scenarios

---

## 🔗 Links

- **ElevenLabs Dashboard**: https://elevenlabs.io/app/conversational-ai
- **Frontend Production**: https://gray-field-011716a03.3.azurestaticapps.net
- **Backend Functions**: Azure Portal → sales-training-platform
- **Database**: Azure Portal → postgres-seekapatraining-prod
- **Agent Creation Log**: `.claude/spanish_agents_created.json`

---

**Implementation Complete**: 2025-12-08
**Ready for Deployment**: YES ✅
**All Agent IDs**: CONFIRMED ✅
**Code Status**: READY ✅
