# Before Bugfix Checklist

Surface when: fixing bugs, errors, failures.

## DIAGNOSIS Block (output before first edit)

1. **Symptom**: What exact error/behavior is observed?
2. **Hypothesis**: What do I think causes it? (max 2 hypotheses)
3. **Evidence**: What have I READ that confirms/denies? (file:line references)
4. **Root cause file**: Which SPECIFIC file contains the bug?
5. **Verification plan**: How will I PROVE the fix works?

## Mandatory Checks

- [ ] Read the error log/output (not just the error message)
- [ ] Read the file I'm about to edit (Rule 11: understand before changing)
- [ ] If multiple config files exist, check ALL of them
- [ ] If API/endpoint issue: verify actual URL/deployment name from config, not memory

## Debugging Discipline

- [ ] Use specific exception types (not broad `except Exception`)
- [ ] After 2 failed fix attempts: ADD LOGGING to trace runtime values
- [ ] When removing features: grep ALL references (result dicts, log statements, templates)
- [ ] Test what production sees: `json.loads(json.dumps(context))`

## Fix Validation (R47-R51 Learnings)

- [ ] **Trace consumers**: When changing a return value, grep ALL callers and check what they do with it (R49: confidence=0.5 silently bypassed 0.8 threshold in different file)
- [ ] **Check serialization boundary**: If changing a constant/sentinel type, verify it survives JSON roundtrip (R49: object() sentinel broke Firestore)
- [ ] **Wire both ends**: When adding a detection layer, verify the RESPONSE handler also exists (R50: self-harm detected but no crisis response wired)
- [ ] **Pre-validate fix approach**: Ask "will this fix create a new attack surface?" before applying (R48: fail-open classifier created bypass vector)

## Production Bugs

- [ ] Pull actual runtime logs (`az webapp log download`) BEFORE re-reading code
- [ ] "Deploy succeeded" != "Bug fixed"
- [ ] Check if old code still running (12+ hours on Consumption Plan warm instances)
- [ ] Version assertion: `curl` health endpoint, assert version matches deployed version

## After Fix

- [ ] Write regression test for this specific bug
- [ ] Verify fix with real data, not just unit tests
- [ ] If production: follow full deploy checklist (`checklists/before-deploy.md`)
- [ ] **Parity sweep**: grep old value across ALL file types (*.py, *.md, *.json, *.yaml) in src/, tests/, docs/, data/ — fix every hit (R69: 12+ stale references missed)
- [ ] **Wiring check**: if new module/function created, grep for imports in src/ — zero hits = scaffolded, not wired (R69: validators.py dead code for 1 round)

## Skip Conditions

- Trivial fixes: typos, single-line, obvious syntax errors
- User says "just fix it" or "#urgent"
- Already read the file and error output in this session

## References

- `CLAUDE.md`: Bug Fix Protocol
- `rules/code-quality.md`: Debugging Discipline
- `rules/azure-deploy.md`: Production Logs Before Code Re-Read
