---
name: ship-it
description: Anti-perfectionism skill. Declares "good enough" and blocks endless improvement loops. Use when scope creep or perfectionism threatens delivery.
argument-hint: [optional: specific feature to ship]
allowed-tools: Read, AskUserQuestion
auto-trigger: false
manual-invoke: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# Ship-It Skill

**Purpose**: Declare "good enough" and stop perfectionism loops. Prevents "it would be better if we also..." from derailing delivery.

---

## When to Use

**Invoke when**:
- Caught in "one more improvement" loop
- Task keeps expanding beyond original scope
- Spending time on diminishing returns
- User says "is this done yet?" or shows impatience
- Internal voice says "but we could also..."

**Signs of perfectionism trap**:
- 3rd+ iteration on same feature
- Adding features not in original request
- Refactoring code that already works
- Writing docs for internal-only code
- Optimizing before measuring

---

## Procedure

### Step 1: Scope Check

Compare current state to **original request**:

```markdown
## Scope Check

**Original request**: [exact user words]

**What was delivered**:
- [x] [Core requirement 1]
- [x] [Core requirement 2]
- [x] [Core requirement 3]

**What was NOT requested but added**:
- [ ] [Scope creep item 1]
- [ ] [Scope creep item 2]

**Verdict**: [On-scope / Scope creep detected]
```

### Step 2: Define "Done"

Explicit acceptance criteria — what MUST be true to ship:

```markdown
## Definition of Done

**Functional**:
- [ ] Core feature works with real data
- [ ] Error states handled (not swallowed)
- [ ] User can complete primary workflow

**Quality**:
- [ ] No console errors
- [ ] No TypeScript/lint errors
- [ ] Tests pass (if tests exist)

**NOT required to ship**:
- Edge case optimization
- Performance tuning (unless slow)
- Additional documentation
- Code cleanup/refactoring
- "Nice to have" features
```

### Step 3: Ship Decision

Present clear options to human:

```markdown
## Ship Decision

**Status**: [All core requirements met / Gaps exist]

**Option A: Ship Now**
- Meets original request
- Can iterate later if needed
- [List any known limitations]

**Option B: One More Thing**
- Specific item: [what exactly]
- Estimated effort: [time]
- Risk: Scope creep

**Option C: Not Ready**
- Missing: [specific gap]
- Blocking because: [why it matters]

**Recommendation**: [A/B/C]
```

### Step 4: Commit to Decision

Once human decides:
- **Ship Now** → Stop all "improvement" work, finalize and deliver
- **One More Thing** → Do ONLY that item, then return to Step 3
- **Not Ready** → Fix ONLY the blocker, then return to Step 3

---

## NEVER

- Add features after "ship now" decision
- Refactor working code during shipping
- Start new improvements without explicit approval
- Say "while we're at it..." or "it would be better if..."
- Optimize without profiling data
- Write documentation that wasn't requested
- Clean up code outside the change scope
- Second-guess a "ship now" decision

---

## Perfectionism Triggers to Block

When you catch yourself thinking:

| Thought | Response |
|---------|----------|
| "While we're here, let's also..." | STOP. Ship first, iterate later. |
| "This could be cleaner..." | Does it work? Ship it. |
| "We should add error handling for..." | Is it a likely error? If not, ship. |
| "Let me add some tests for..." | Were tests requested? If not, ship. |
| "The code style isn't consistent..." | Does it work? Ship it. |
| "We could optimize this..." | Is it slow? If not, ship. |
| "Let me document this..." | Was docs requested? If not, ship. |

---

## Integration with Orchestrator

Ship-it can interrupt any phase:

```
Planning → Implementation → Verification → [SHIP-IT CHECK] → Done
                                               ↓
                                    "Is this scope creep?"
                                               ↓
                              [Yes: Cut scope] [No: Continue]
```

---

## Failed Approaches

*Document approaches that didn't work to prevent future sessions from repeating them.*

| Date | Approach | Why It Failed |
|------|----------|---------------|
| — | — | — |

---

## Examples

### Example 1: Feature Complete but Tempted to Polish

**Original request**: "Add a logout button"

**Delivered**:
- [x] Logout button in header
- [x] Clears session
- [x] Redirects to login

**Temptation**: "Let me also add a confirmation modal, and maybe improve the login page styling while I'm at it..."

**Ship-it verdict**: SHIP NOW. Logout works. Modal and styling weren't requested.

### Example 2: Genuine Gap vs Perfectionism

**Original request**: "Fix the login bug"

**Delivered**:
- [x] Login works with valid credentials
- [ ] Error message for invalid credentials (shows blank)

**Temptation**: "Let me also add rate limiting and password strength indicator..."

**Ship-it verdict**: ONE MORE THING — the error message gap is a real UX issue. Rate limiting and password indicator are scope creep.

---

*Part of Silent Kernel Architecture v8.0*
