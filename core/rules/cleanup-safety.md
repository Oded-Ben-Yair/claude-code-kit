# Cleanup Safety Rules (On-Demand Module)

Load when: cleanup, clean up, remove unused, delete old, janitor

## Critical Safety Rules

1. **NEVER auto-delete anything** - Always list first, ask for confirmation
2. **NEVER delete .git directories** - Ever, under any circumstances
3. **NEVER delete .env files** - Even if they look unused
4. **NEVER delete without git status check** - Ensure no uncommitted work
5. **ALWAYS use dry-run first** - Show what WOULD be deleted

## Cleanup Workflow

1. `git status` — STOP if uncommitted changes exist
2. List all candidates with sizes
3. Present report table with Safe/Review/Danger categories
4. Ask for explicit confirmation
5. Delete with `-v` for verbose output

## What NOT to Clean

- `.git/` — Never
- `.env*` — Never without review
- `node_modules/` — Only if package.json exists (can reinstall)
- `*.md` — Documentation, keep
- `CLAUDE.md` — Critical, never delete
- `~/.claude/` — Configuration, never delete
- `~/.ssh/` — Critical, never delete
- `shared/` in CI/CD paths — See file-deletion-safety rules in code-quality.md

## Dead Code False Positive Rate

Explore agent dead code detection has **87% false positive rate** — never trust without exhaustive manual verification including:
- `grep -r "import"` checks
- `__init__.py` chain checks
- Dynamic import checks (`importlib`, `__import__`)
- Delete ONE file at a time, verify pipeline succeeds
