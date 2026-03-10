# Before New File Checklist

Surface when: creating new modules, adding new files to a project.

## Before Creating

- [ ] Is a new file really needed? Prefer editing existing files over creating new ones.
- [ ] Check for similar existing modules: `glob **/*<keyword>*.py`

## Production Wiring (MANDATORY)

- [ ] Trace from entry point (function_app.py / page.tsx) to your new code
- [ ] Verify import path exists: `grep -r "from <module> import" *.py shared/**/*.py`
- [ ] Zero results = NOT WIRED = FIX BEFORE COMMIT

## Test Coverage (MANDATORY for new modules)

- [ ] Create corresponding test file alongside new module (e.g., `src/data/validators.py` → `tests/test_validators.py`)
- [ ] New module at 0% coverage drops total coverage below threshold (R68: validators.py caused 89.43% < 90% gate)
- [ ] Verify coverage stays above threshold: `python3 -m pytest --cov=src -q 2>&1 | grep TOTAL`

## Schema-First (if DB-related)

- [ ] Query `information_schema.columns` for actual schema before writing SQL
- [ ] Verify expected columns exist in actual result set

## After Creating 3+ Files

- [ ] Launch code-judge with hostile review mandate (Hostile Audit Gate)
- [ ] Judge traces production code paths (every file reachable from entry point?)
- [ ] Judge verifies SQL queries match real schema
- [ ] Judge checks for dead imports / uncalled functions
- [ ] Fix all critical/high findings before committing

## References

- `rules/code-quality.md`: Production Wiring Check, Hostile Audit Gate, Schema-First Development
