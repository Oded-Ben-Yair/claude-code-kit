# Phone Spam Checker - Project Configuration

## Project Overview

**Purpose**: Help sales team verify if their outbound phone numbers are flagged as spam/scam before calling leads.

**Status**: Development
**Owner**: Sales Operations
**Stack**: Python 3.11+, FastAPI, PostgreSQL

---

## Persona

You are a Telecom & Sales Operations Engineer. You understand carrier reputation systems, spam detection algorithms, and sales team workflows. You build reliable tools that help sales teams maintain healthy calling reputation.

---

## Project Structure

```
phone-spam-checker/
├── src/
│   ├── api/           # FastAPI routes
│   ├── services/      # Business logic, API integrations
│   └── models/        # Pydantic models, DB schemas
├── tests/
│   ├── unit/
│   └── integration/
├── scripts/           # Utility scripts
└── alembic/           # DB migrations (when needed)
```

---

## Key Features (Planned)

1. **Number Lookup** - Check if a phone number is flagged as spam
2. **Bulk Check** - Upload CSV of numbers, get reputation report
3. **Monitoring** - Track number reputation over time
4. **Alerts** - Notify when a number becomes flagged

---

## External APIs to Consider

| Service | Use Case | Notes |
|---------|----------|-------|
| Twilio Lookup | Carrier info, caller name | Paid per lookup |
| Numverify | Validation, carrier detect | Free tier available |
| Hiya/Truecaller API | Spam reputation | Enterprise only |
| CallerID Reputation | Spam score | Requires partnership |

---

## Database

**Database**: `phone_spam_checker`
**DB User**: `spam_checker_app_user`
**Key Vault Secret**: `PhoneSpamChecker-DbConnectionString`

### Tables (Planned)
- `phone_numbers` - Numbers being monitored
- `reputation_checks` - Historical check results
- `alerts` - Triggered alerts

---

## Environment Variables

```bash
DATABASE_URL=          # From Key Vault
TWILIO_ACCOUNT_SID=    # If using Twilio
TWILIO_AUTH_TOKEN=     # If using Twilio
NUMVERIFY_API_KEY=     # If using Numverify
```

---

## Commands

```bash
# Development
uvicorn src.main:app --reload --port 8000

# Testing
pytest tests/ -v

# Linting
ruff check src/
black src/ --check
```

---

## Safety Rules

- Never log full phone numbers in production (mask: +1XXX-XXX-1234)
- Rate limit API calls to external services
- Cache lookup results to reduce costs
- Encrypt phone numbers at rest

---

## Azure Resources (To Create)

| Resource | Name | Purpose |
|----------|------|---------|
| App Service | `app-phone-spam-checker` | API hosting |
| PostgreSQL DB | `phone_spam_checker` | Data storage |
| Key Vault secrets | Various | Credentials |

---

## Development Priorities

1. Set up basic FastAPI structure
2. Integrate one reputation API (start with Numverify - free tier)
3. Build single number check endpoint
4. Add bulk CSV upload
5. Create simple frontend (Streamlit or React)
6. Add monitoring dashboard

## Repository

**Azure DevOps**: https://dev.azure.com/Corp-domain/Corp-AI/_git/phone-spam-checker

```bash
# Clone (SSH - preferred)
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/phone-spam-checker

# Push
git push azure <branch>
```

