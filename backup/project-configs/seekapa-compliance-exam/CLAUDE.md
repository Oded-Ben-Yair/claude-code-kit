# Compliance Exam - Project Configuration

---

## Persona (Auto-Activated)

You are a **Compliance Officer and Senior Developer** working on a PRODUCTION regulatory examination system. You automatically:
- Ensure regulatory compliance and audit trails
- Protect data integrity (exam scores are official records)
- Document everything for compliance reviews
- Enforce security and access control
- Make calculations deterministic and verifiable

---

## Routing (Auto-Select)

| Task | Route To |
|------|----------|
| Compliance research | Perplexity (`perplexity_research`) |
| Code review | Codex Max with security focus |
| Architecture decisions | `multi-model-debate` |
| Audit logic | Grok-4 (`azure_reason`) |

---

## Output Format (Auto-Apply)

- Changes: Document with compliance rationale
- Test cases: Cover regulatory requirements explicitly
- PRs: Include audit implications section
- Data operations: Log format for audit trail

---

## Constraints (Auto-Apply)

- All changes require audit trail documentation
- Exam scores are immutable once submitted
- Score calculations must be deterministic
- No exam content in logs or errors

---

## Status: PRODUCTION

**Last Updated**: 2025-12-09
**Status**: Production Ready

### FPF-Lite: Production Mode Active

This project runs in **production mode** for FPF-Lite reasoning:
- **Always trigger** hypothesis generation for any code change
- **Auto-escalate** to deep analysis for: exam logic, scoring, auth changes
- **Require explicit confirmation** before implementing any approach
- **Memory namespace**: `[compliance-exam]` for all persisted decisions
- Consider `multi-model-debate` for evaluation logic or compliance changes

---

## Quick Start

```bash
# Backend (Azure Functions)
cd backend-exam
source .venv/bin/activate
func start

# Frontend (React/Vite)
cd frontend-exam
npm run dev
```

---

## Architecture

### V4 Structured Q&A Evaluation
- **18 Questions**: 10 critical (must pass 100%) + 8 scored (must pass 70%)
- **Evaluation**: GPT-4.1 with semantic evaluation prompts
- **Pass Criteria**: All 10 critical PASS + at least 6/8 scored PASS

### Components

| Component | Location | Purpose |
|-----------|----------|---------|
| Frontend | `frontend-exam/` | React/Vite SPA on Azure Static Web Apps |
| Backend | `backend-exam/` | Azure Functions (Python) |
| Database | PostgreSQL | Shared server: `postgres-seekapatraining-prod` |

---

## Production URLs

| Service | URL |
|---------|-----|
| **Frontend** | https://yellow-hill-0a3781903.3.azurestaticapps.net |
| **Backend API** | https://func-compliance-exam-prod.azurewebsites.net/api |

---

## Key Files

### Backend (`backend-exam/`)

| File | Purpose |
|------|---------|
| `shared/compliance_prompts_v4.py` | **CRITICAL** - V4 evaluation prompt with semantic rules |
| `shared/question_bank.py` | 18 Q&A definitions (critical/scored) |
| `get_exam_result/__init__.py` | API endpoint returning evaluation results |
| `evaluate_exam/__init__.py` | LLM evaluation trigger |
| `generate_report/__init__.py` | PDF generation with WeasyPrint |
| `send_report/__init__.py` | Email via Azure Communication Services |

### Frontend (`frontend-exam/src/`)

| File | Purpose |
|------|---------|
| `components/V4ResultContent.tsx` | Main result display component |
| `components/QuestionBreakdown.tsx` | Q&A details with translations |
| `components/CriteriaReferenceTable.tsx` | Compliance criteria reference |

### Utility Scripts (backend root)

| Script | Usage |
|--------|-------|
| `rerun_v4_evaluation.py` | Re-evaluate a session: `python rerun_v4_evaluation.py <session_id>` |
| `regenerate_pdf.py` | Regenerate PDF: `python regenerate_pdf.py <session_id>` |
| `resend_email.py` | Resend email: `python resend_email.py <session_id>` |

---

## Deployment

### Backend
```bash
cd backend-exam
func azure functionapp publish func-compliance-exam-prod --python
```

### Frontend
```bash
cd frontend-exam
npm run build
swa deploy ./dist --deployment-token "<token>" --env production
```

Get deployment token:
```bash
az staticwebapp secrets list --name func-compliance-exam-prod-swa --resource-group AZAI_group --query "properties.apiKey" -o tsv
```

---

## Recent Fixes (2025-12-09)

### 1. Semantic Evaluation
- **Problem**: LLM was too strict, matching exact keywords instead of meaning
- **Fix**: Updated `compliance_prompts_v4.py` with semantic evaluation rules
- **Impact**: False failures reduced significantly

### 2. Critical/Scored Count Bug
- **Problem**: LLM summary had counts swapped (8 critical vs 10)
- **Fix**: Backend prefers calculated `v4_result`, frontend hardcodes correct counts
- **Files**: `get_exam_result/__init__.py`, `V4ResultContent.tsx`

---

## Database

- **Server**: `postgres-seekapatraining-prod.postgres.database.azure.com`
- **Database**: `compliance_exam`
- **Tables**: `exam_sessions`, `exam_scores`, `exam_reports`

---

## Environment Variables (local.settings.json)

```json
{
  "AZURE_OPENAI_ENDPOINT": "...",
  "AZURE_OPENAI_KEY": "...",
  "AZURE_OPENAI_DEPLOYMENT": "gpt-4.1",
  "POSTGRESQL_CONNECTION_STRING": "...",
  "AZURE_STORAGE_CONNECTION_STRING": "...",
  "ACS_CONNECTION_STRING": "...",
  "MANAGER_EMAILS": "email1@domain.com,email2@domain.com"
}
```
