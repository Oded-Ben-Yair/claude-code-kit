## Code Quality

### Always-Loaded Rules

| Rule File | Covers |
|-----------|--------|
| `code-quality.md` | Language standards, error handling, test requirements, production wiring, security |
| `db-safety.md` | Schema-first development, pre-query checklist, migration safety, cross-project protection |
| `cleanup-safety.md` | Safe deletion workflow, dry-run-first policy, protected file patterns |

### Hook Reference

| Hook | Event | Purpose |
|------|-------|---------|
| `post-tool-autoformat.sh` | PostToolUse (Edit/Write) | Auto-format Python (ruff/black), TS/JS (prettier), JSON (jq) after file changes |
| `pre-tool-file-guard.sh` | PreToolUse (Bash/Write/Edit) | Block writes to .env, .pem, .key, secrets, cross-project |
| `dead-code-check.sh` | PreToolUse (Bash: git commit) | Block commits with new Python files that have zero imports (orphan detection) |
| `quality-validation.sh` | PreToolUse (Bash/Write/Edit) | Block dangerous commands (rm -rf, force push, DROP TABLE), warn on .format() near user text |
| `schema-verify.sh` | PreToolUse (Bash: SQL) | Block SQL queries referencing tables without prior `information_schema` verification |

### Action Checklists

| Trigger | Checklist | Key Focus |
|---------|-----------|-----------|
| fix, bug, error | `before-bugfix.md` | DIAGNOSIS block, consumer tracing, regression test |
| deploy, push to prod | `before-deploy.md` | Pre/post snapshots, version assertion, pipeline wait |
| ML, model, prediction | `before-ml-change.md` | Feature schema, evaluation baselines, shadow mode |
| new file creation | `before-new-file.md` | Production wiring, test coverage, hostile audit |
| pipeline, processing | `before-pipeline-change.md` | Format contracts, multi-language safety, full pipeline test |
| refactor, restructure | `before-refactor.md` | Caller grep, file deletion safety, async migration |

### Pre-Query Database Checklist (MANDATORY)

Before ANY database operation:
1. `pwd` -- verify correct project directory
2. Verify connection string matches project (from secret manager/env vars, not hardcoded)
3. Query actual schema before writing SQL:
```sql
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '<table>';
SELECT * FROM <table> LIMIT 5;
SELECT COUNT(*) FROM <table>;
```
