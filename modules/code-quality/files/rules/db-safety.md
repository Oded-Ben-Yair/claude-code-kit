# Database Safety Rules

## Project-Database Mapping

| Project | Database | DB User | Secret Store Key |
|---------|----------|---------|------------------|
| <!-- Add your projects here --> | | | |

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
- **NEVER** hardcode connection strings - use Secret Manager/env var references
- **NEVER** assume a column exists because a plan mentions it
- **NEVER** assume table shape without checking (lookup vs time-series)
- **NEVER** run destructive queries without WHERE verification
- **NEVER** modify schema on databases you don't own

## Safe Connection Pattern

```python
# GOOD: From environment / Secret Manager
conn_string = os.environ.get("DATABASE_URL")
secret = secret_client.get_secret("ProjectName-DbConnectionString")

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
- DDL operations (CREATE TABLE, ALTER, migrations) require admin user
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

Origin: Production project — stored function updated current_price every 5 min, API read from a different table with different cadence. 30-second diagnosis once both paths traced.
