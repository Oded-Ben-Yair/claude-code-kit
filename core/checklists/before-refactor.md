# Before Refactor Checklist

Surface when: refactoring, restructuring, reorganizing, deleting files, moving code.

## Understand First (Rule 11)

- [ ] Read the code you're about to change
- [ ] Grep callers: `grep -r "from module import" *.py shared/**/*.py`
- [ ] Check tests: `glob **/test_*.py` for the affected module
- [ ] Map dependencies — what breaks if this changes?

## File Deletion Safety

- [ ] Check grep for imports (necessary but NOT sufficient)
- [ ] Check `__init__.py` chains (grep misses these)
- [ ] Check dynamic imports (`importlib`, `__import__`)
- [ ] Delete ONE file at a time, verify pipeline succeeds between each
- [ ] NEVER bulk-delete from CI/CD trigger paths (`shared/`, `function_app.py`, `requirements.txt`)

## Durable Functions Activity Audit (if applicable)

- [ ] Extract ALL `context.call_activity("name")` from orchestrators
- [ ] Extract ALL `@app.activity_trigger` registrations from function_app.py
- [ ] Assert: called_activities is a subset of registered_activities
- [ ] Pipeline success is NOT sufficient — activity resolution is at RUNTIME

## Async Migration (if converting sync to async)

- [ ] Grep ALL callers of the converted function
- [ ] Add `await` to every call site
- [ ] Check `except Exception` handlers downstream (they mask coroutine errors)
- [ ] Convert lock types consistently (threading.Lock vs asyncio.Lock)
- [ ] Run tests for EACH converted caller

## Consumer Wiring Verification (MANDATORY for utility/hook/library refactors)

- [ ] For each new utility/hook created: grep ALL intended consumers to verify they import and USE it
- [ ] Count API calls before and after (DevTools Network tab or `grep -c "fetch\|useEffect" page.tsx`)
- [ ] If adding caching layer (SWR/React Query): verify pages use hooks, not raw fetch
- [ ] If extracting providers for SSR: verify layout actually lost `'use client'`
- [ ] If removing fonts/dependencies: verify build size decreased (`npm run build` output)
- [ ] Rule: Creating infrastructure without connecting consumers = zero improvement

## Extract-to-Helper Refactor (if moving code to a new function)

- [ ] Trace ALL variable dependencies in the extracted block — ensure they're defined BEFORE the call site
- [ ] Check if extracted code was BETWEEN two blocks that share a variable (e.g., `history` used above and below)
- [ ] If the helper returns values used later, update ALL references from direct access to return-value access
- [ ] Run syntax check (`python3 -c "import ast; ast.parse(open('file').read())"`) before running tests

## Post-Refactor

- [ ] Production Wiring Check: trace entry point to your changed code
- [ ] Hostile Audit Gate (if 3+ files changed): launch code-judge
- [ ] Run full test suite, not just changed modules
- [ ] Runtime verification: test in browser, not just build pass (use /browser-control or DevTools)

## References

- `rules/code-quality.md`: File Deletion Safety, Async Migration Safety, Production Wiring Check
- `rules/azure-functions.md`: Activity Audit
