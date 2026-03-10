---
name: pre-mortem
description: Risk assessment before implementation. Imagines failure to discover problems early. Auto-triggers on tasks touching 3+ files or involving auth/secrets/crypto/infra/DB schema.
argument-hint: [task description]
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion
auto-trigger: true
trigger-conditions:
  - task touches 3+ files
  - involves auth, secrets, crypto, infrastructure
  - database schema changes
  - PII handling
  - production deployments
metadata:
  version: "1.0.0"
  author: odedbe
---

# Pre-Mortem Skill

**Purpose**: Imagine the task has already failed. Work backwards to discover what went wrong before you start.

---

## When to Use

**Auto-trigger when**:
- Task touches 3+ files
- Involves: auth, secrets, crypto, infrastructure, DB schema, PII
- Production deployments or migrations
- User says "this is risky" or "be careful"

**Skip when**:
- User says "just do it", "quick fix", "#urgent"
- Single-file changes with clear scope
- Pure documentation updates

---

## Procedure

### Step 1: Assume Failure (30 seconds)

Mentally fast-forward: **"It's tomorrow. This task failed catastrophically. What went wrong?"**

Generate 3-5 failure scenarios:

```markdown
## Pre-Mortem: [Task Name]

**Imagined failures:**
1. [Failure mode 1] — e.g., "DB migration corrupted production data"
2. [Failure mode 2] — e.g., "New auth flow locked out all users"
3. [Failure mode 3] — e.g., "API change broke mobile clients"
4. [Failure mode 4] — e.g., "Test passed locally but failed in Azure"
5. [Failure mode 5] — e.g., "Deleted file was actually imported dynamically"
```

### Step 2: Reverse-Engineer Prevention

For each failure mode, identify:
- **Detection**: How would we know this happened?
- **Prevention**: What check/test/gate prevents this?
- **Recovery**: If it happens anyway, how do we roll back?

```markdown
| Failure Mode | Detection | Prevention | Recovery |
|--------------|-----------|------------|----------|
| DB corruption | Row counts, checksums | Backup before migration | Restore from backup |
| Auth lockout | Smoke test login | Keep old auth path until verified | Feature flag rollback |
| API breakage | Integration tests | Version API, deprecation period | Revert commit |
```

### Step 3: Add Safety Gates

Based on prevention analysis, add explicit gates to the plan:

```markdown
## Required Safety Gates

- [ ] Backup database before migration
- [ ] Run integration tests against staging
- [ ] Verify feature flag rollback works
- [ ] Test with production-like data volume
- [ ] Confirm rollback procedure documented
```

### Step 4: Present to Human

**GATE**: Present the pre-mortem analysis and safety gates. Get explicit approval before proceeding.

```markdown
## Pre-Mortem Complete

**Task**: [description]
**Risk Level**: [Low/Medium/High/Critical]
**Top Risks**:
1. [Most likely failure]
2. [Most damaging failure]

**Safety Gates Added**: [count]
**Estimated Overhead**: [minimal/moderate/significant]

**Proceed with implementation?** [Yes/Modify/Abort]
```

---

## NEVER

- Skip pre-mortem for "simple" tasks that touch production
- Assume a failure mode is impossible
- Proceed without human approval on High/Critical risk
- Let time pressure bypass safety gates
- Trust "it worked in dev" for production changes

---

## Integration with Orchestrator

When orchestrator detects a qualifying task:
1. Run pre-mortem BEFORE planning phase
2. Feed safety gates into planner as constraints
3. Verifier checks safety gates were honored

```
User Request → Pre-Mortem → Planner → Implementer → Verifier
                  ↓
           Safety Gates
```

---

## Failed Approaches

*Document approaches that didn't work to prevent future sessions from repeating them.*

| Date | Approach | Why It Failed |
|------|----------|---------------|
| — | — | — |

---

## Examples

### Example 1: Database Migration

**Task**: Add `subscription_tier` column to users table

**Pre-Mortem Failures**:
1. Migration fails mid-way, table locked
2. Default value wrong, all users get wrong tier
3. App code references column before migration runs
4. Rollback migration doesn't restore original state

**Safety Gates**:
- [ ] Test migration on copy of prod data
- [ ] Verify default value matches business logic
- [ ] Deploy code change AFTER migration completes
- [ ] Test rollback migration explicitly

### Example 2: Auth System Change

**Task**: Switch from JWT to session-based auth

**Pre-Mortem Failures**:
1. Active sessions invalidated, all users logged out
2. Mobile app breaks (expects JWT)
3. Session store (Redis) not provisioned
4. CORS issues with new cookie-based flow

**Safety Gates**:
- [ ] Support both auth methods during transition
- [ ] Coordinate with mobile team on timeline
- [ ] Verify Redis is provisioned and configured
- [ ] Test CORS with all client origins

---

*Part of Silent Kernel Architecture v8.0*
