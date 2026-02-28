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
- [ ] Read the file I'm about to edit (understand before changing)
- [ ] If multiple config files exist, check ALL of them
- [ ] If API/endpoint issue: verify actual URL/deployment name from config, not memory

## Debugging Discipline

- [ ] Use specific exception types (not broad `except Exception`)
- [ ] After 2 failed fix attempts: ADD LOGGING to trace runtime values
- [ ] When removing features: grep ALL references (result dicts, log statements, templates)
- [ ] Test what production sees: `json.loads(json.dumps(context))`

## Fix Validation

- [ ] **Trace consumers**: When changing a return value, grep ALL callers and check what they do with it
- [ ] **Check serialization boundary**: If changing a constant/sentinel type, verify it survives JSON roundtrip
- [ ] **Wire both ends**: When adding a detection layer, verify the RESPONSE handler also exists
- [ ] **Pre-validate fix approach**: Ask "will this fix create a new attack surface?" before applying

Origin: confidence=0.5 silently bypassed 0.8 threshold in different file. object() sentinel broke Firestore serialization. fail-open classifier created bypass vector.

## Production Bugs

- [ ] Pull actual runtime logs BEFORE re-reading code
- [ ] "Deploy succeeded" != "Bug fixed"
- [ ] Check if old code still running (warm instances may serve old code for hours)
- [ ] Version assertion: `curl` health endpoint, assert version matches deployed version

## After Fix

- [ ] Write regression test for this specific bug
- [ ] Verify fix with real data, not just unit tests
- [ ] If production: follow full deploy checklist (`checklists/before-deploy.md`)
- [ ] **Parity sweep**: grep old value across ALL file types (*.py, *.md, *.json, *.yaml) in src/, tests/, docs/, data/ -- fix every hit
- [ ] **Wiring check**: if new module/function created, grep for imports in src/ -- zero hits = scaffolded, not wired
- [ ] **Live verification for behavioral bugs**: mock tests overestimate quality. Run >=3 scenarios through real LLM after fix
- [ ] **State field count test**: if adding/removing a state field, update the parity assertion test

## Skip Conditions

- Trivial fixes: typos, single-line, obvious syntax errors
- User says "just fix it" or "#urgent"
- Already read the file and error output in this session

## References

- `CLAUDE.md`: Bug Fix Protocol
- `rules/code-quality.md`: Debugging Discipline
