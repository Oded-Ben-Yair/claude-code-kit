# Database Safety Rules

## Shared PostgreSQL Hosts

**NEW (sysadmin, 2026-02-23):** `aiprojects-company-postsql.postgres.database.azure.com:5432`
**OLD (migrating from):** `postgres-seekapatraining-prod.postgres.database.azure.com:5432`

> Sysadmin is consolidating all DBs to the new server. Migration in progress.

## Project-Database Mapping

| Project | Database | DB User | Secret Manager Secret |
|---------|----------|---------|------------------|
| Training Platform | `seekapa_training` | `training_app_user` | `TrainingPlatform-DbConnectionString` |
| Sentimark | `polymarket_analyzer` | `sentimark_app_user` | `Sentimark-DbConnectionString` |
| QC Analyzer | `qc_analyzer` | `qc_app_user` | `QCAnalyzer-DbConnectionString` |
| Chatbot | `axia_seekapa_chatbot` | `chatbot_app_user` | `Chatbot-DbConnectionString` |
| CRM | `seekapa_workspace` | `crm_app_user` | `CRM-DbConnectionString` |
| Compliance Exam | `compliance_exam` | `compliance_app_user` | `ComplianceExam-DbConnectionString` |
| Phone Spam Checker | `phone_spam_checker` | `spam_checker_app_user` | `PhoneSpamChecker-DbConnectionString` |

## Pre-Query Checklist (MANDATORY)

Before ANY database operation:
1. `pwd` - verify you are in the correct project directory
2. Verify connection string matches project (Secret Manager, not hardcoded)
3. Query actual schema before writing SQL:

```sql
-- Step 1: Check columns exist
SELECT column_name, data_type FROM information_schema.columns
WHERE table_name = '<table>';

-- Step 2: Understand data shape
SELECT * FROM <table> LIMIT 5;

-- Step 3: Check cardinality (1 row per entity vs time-series?)
SELECT COUNT(*) FROM <table>;
```

## Hard Rules

- **NEVER** cross-database queries - each project has isolated DB user
- **NEVER** hardcode connection strings - use Secret Manager references
- **NEVER** assume a column exists because a plan mentions it
- **NEVER** assume table shape without checking (lookup vs time-series)
- **NEVER** run destructive queries without WHERE verification
- **NEVER** modify schema on databases you don't own

## Safe Connection Pattern

```python
# GOOD: From environment / Secret Manager
conn_string = os.environ.get("DATABASE_URL")
secret = keyvault_client.get_secret("ProjectName-DbConnectionString")

# BAD: Hardcoded or cross-project
conn_string = "postgresql://user:pass@host/db"  # NEVER
```

## Migration Safety

```bash
pwd                          # Verify directory
alembic current              # Check state
alembic upgrade head --sql   # Review SQL first
alembic upgrade head         # Apply
```

## DDL vs DML Permissions

- App users (`*_app_user`) have DML only (SELECT, INSERT, UPDATE, DELETE)
- DDL operations (CREATE TABLE, ALTER, migrations) require admin user (`seekapaadmin`)
- `gcloud run function list` returns 0 for consumption plan apps — use health endpoint instead
- After deploy touching `shared/`: verify function count > 0 via health endpoint

## Cross-Project Data Safety

- NEVER export/copy data between project databases
- Each project has isolated DB user — cross-database queries will fail silently
- Check `pwd` matches project before ANY database operation

## Read/Write Path Tracing for Data Freshness Bugs

When data appears stale, trace BOTH the write path (what updates the data) AND the read path (what the API returns) — they often use different tables.

1. Find the background job/stored function that WRITES the data — note which table and column
2. Find the API endpoint that READS the data — note which table and column
3. If write table != read table, that IS the bug
4. Fix: read from the same table the writer updates
5. Add SQL comment: `-- reads from X, updated by Y() every Z min`

Origin: Sentimark Feb 2026 — stored function updated vpp.current_price every 5 min, API read from ap.current_price (different table, different cadence). 30-second diagnosis once both paths traced.
