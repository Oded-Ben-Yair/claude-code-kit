# Hey Seven Session Close — 40-Dimension Perfection Tracker + External-Review-Ready Handover

name: hey-seven-session
description: End-of-session for Hey Seven project. Captures 40-dimension scores (D1-D10, B1-B10, P1-P10, H1-H10), ensures codebase is external-review-ready (tests green, committed, pushed, doc parity), generates deep next-session handover with exact commands, MCP tools, agents, teams, and skills the next session must use.
metadata:
  version: "2.0.0"
  project: hey-seven

---

## Purpose

This skill replaces `/end-of-session` for Hey Seven. It:
1. Captures the **40-dimension** state (D1-D10 tech + B1-B10 behavioral + P1-P10 profiling + H1-H10 host triangle)
2. Ensures the codebase is **external-review-ready** (all tests pass, zero uncommitted changes, pushed to GitHub, doc parity verified)
3. Generates a **deep next-session handover** that tells `/go` EXACTLY what to do — specific commands, MCP tool calls, agent compositions, team structures, and skills — not generic lists

---

## When to Use

Run `/hey-seven-session` at the end of every Hey Seven session instead of `/end-of-session`.

---

## Phase 1: Session Identity + Technical Snapshot [10 seconds]

### 1.1 Generate Session ID

```bash
cd $HOME/projects/hey-seven
SESSION_DATE=$(date '+%Y%m%d')
SESSION_HASH=$(echo "$$-$(date +%s)" | md5sum | cut -c1-6)
SESSION_ID="hey-seven-session-${SESSION_DATE}-${SESSION_HASH}"
echo "Session ID: $SESSION_ID"
```

### 1.2 Capture Technical State

Run ALL of these in parallel:

```bash
# Git state
git branch --show-current
git log --oneline -3
git status -s | head -30
git diff --stat HEAD | tail -5

# Tests (MANDATORY — do NOT skip)
python3 -m pytest tests/ -q --tb=short --no-header 2>&1 | tail -10

# Pattern counts
python3 -c "
import inspect, re
from src.agent import guardrails
src = inspect.getsource(guardrails)
compiled = len(re.findall(r'regex_engine\.compile\(', src))
print(f'Guardrail patterns: {compiled}')
from src.agent.prompts import SLOP_PATTERNS
print(f'Slop patterns: {len(SLOP_PATTERNS)}')
" 2>&1

# Module count
find src/ -name "*.py" -not -name "__pycache__" | wc -l

# Scenario count
find tests/scenarios/ -name "*.yaml" | xargs grep "^  - id:" | wc -l
```

### 1.3 Determine Round Number

Read MEMORY.md for the current round number. The NEW round = current + 1 if code changes were made this session, otherwise same round.

---

## Phase 2: Capture 40-Dimension Scores [15 seconds] — CRITICAL

### The 40 Dimensions

| Group | Dims | Source | Typical Eval |
|-------|------|--------|-------------|
| **Technical** | D1-D10 | Code review (multi-model) | R75: 9.63/10 |
| **Behavioral** | B1-B10 | Live eval + judge panel | R105: 6.62/10 |
| **Profiling** | P1-P10 | Live eval + judge panel | R105: 5.18/10 |
| **Host Triangle** | H1-H10 | Live eval + judge panel | R105: 5.09/10 |

### 2.1 Read Current Verified Scores

Read these files:
- `${CLAUDE_HOME:-$HOME/.claude}/projects/-home-odedbe-projects-hey-seven/memory/MEMORY.md` — latest scores
- `$HOME/projects/hey-seven/.claude/status.json` — per-dimension breakdown
- `memory/dimension-gaps.md` — if exists, for gap-to-target analysis

### 2.2 Build the Full 40-Dimension Scorecard

For EACH of the 40 dimensions, record:
- **Score**: latest verified value (from eval, not from code changes)
- **Round measured**: when was this score last evaluated?
- **Target**: D=9.0, B=8.0, P=7.0, H=6.0
- **Gap**: target - score
- **Status**: CRITICAL (<3.0), BELOW (<target-2), APPROACHING (<target), MET (>=target)
- **Blocker type**: prompt-ceiling / needs-tool / needs-eval / needs-fine-tuning / needs-architecture / DONE

### 2.3 Calculate Session Delta

Compare current scores to PREVIOUS session scores:
- Which dimensions **improved** (>+0.3)?
- Which dimensions **regressed** (<-0.3)?
- Which dimensions are **unchanged** (within noise)?
- Was an eval run this session? If not, scores are inherited.

### 2.4 Identify the P0 Gap

The single most impactful dimension to improve next session:
1. Sort all 40 dims by gap-to-target (descending)
2. Filter to dims where we have a **known fix path** (tool built, architecture change identified)
3. The top dim with a fix path = P0

---

## Phase 3: External Review Readiness Gate [20 seconds] — MANDATORY

**Every session MUST leave the codebase ready for an external multi-model audit.** This is non-negotiable. The gate has 6 checks:

### 3.1 Tests Green

```bash
python3 -m pytest tests/ -x --tb=short 2>&1 | tail -5
```

If ANY failures: FIX THEM before proceeding. Do NOT close the session with failing tests.

### 3.2 Zero Uncommitted Production Changes

```bash
git status -s src/ tests/ data/ knowledge-base/ docs/
```

If uncommitted changes exist in production paths:
1. Stage relevant files: `git add <specific files>`
2. Commit with round message: `feat: R{N} — {brief description of changes}`
3. Include `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>`

### 3.3 Pushed to GitHub

```bash
git push origin main
```

Hey Seven uses GitHub (Oded-Ben-Yair/hey-seven), NOT GitHub.

### 3.4 Doc Parity Verification

Run the deterministic doc accuracy tests:

```bash
python3 -m pytest tests/test_doc_accuracy.py -v --tb=short 2>&1 | tail -20
```

If failures: the README/ARCHITECTURE has stale counts (node count, pattern count, etc.). Fix them.

### 3.5 MEMORY.md Size Check

```bash
wc -l ${CLAUDE_HOME:-$HOME/.claude}/projects/-home-odedbe-projects-hey-seven/memory/MEMORY.md
```

If >200 lines: move detailed content to topic files, keep MEMORY.md as concise index. Lines after 200 are TRUNCATED and invisible to next session.

### 3.6 Readiness Verdict

Output a clear verdict:

```
EXTERNAL REVIEW READINESS:
  Tests: {PASS count} passed, {FAIL count} failed — {GREEN/RED}
  Uncommitted: {count} files — {CLEAN/DIRTY}
  Pushed: {YES/NO}
  Doc parity: {PASS/FAIL}
  MEMORY.md: {lines}/200 — {OK/OVER LIMIT}

  VERDICT: {READY FOR REVIEW / NOT READY — fix {issues}}
```

Do NOT proceed to Phase 4 until verdict is READY.

---

## Phase 4: Session Achievements + Learnings [10 seconds]

### 4.1 Deliverables Completed

From conversation context, extract:
1. Files created/modified (with paths)
2. Tests added (count and what they cover)
3. Scenarios added (count and dimensions)
4. Architecture changes (graph nodes, state fields, feature flags)
5. Eval results (if run)

### 4.2 Learnings to Persist

Extract learnings that must survive to next session:
- New anti-patterns discovered (add to `~/.claude/rules/code-quality.md` or `langgraph-patterns.md`)
- Effective techniques verified (add to MEMORY.md "What ALWAYS Works")
- Failed techniques (add to MEMORY.md "What NEVER Works")
- Tool/MCP effectiveness insights
- Model behavior observations (Flash vs Pro, judge reliability)

### 4.3 Agent Teams / Worktree Summary (if used)

If teams or worktrees were active:
- Team composition and what each teammate produced
- Coordination issues or successes
- File ownership matrix
- Lessons for next team composition

---

## Phase 5: Generate Deep Next-Session Handover [30 seconds] — CRITICAL

This is the most important phase. The handover must be so detailed that the next session can start executing within 60 seconds of reading it.

Write to `$HOME/projects/hey-seven/.claude/handover-{YYYYMMDD}-r{N}.md`

### Handover Template

```markdown
# Hey Seven Session Handover — R{N}

**Session**: {SESSION_ID}
**Date**: {DATE}
**Commit**: {COMMIT_HASH} (pushed to GitHub)
**Version**: v{VERSION}
**Tests**: {PASS}/{TOTAL} passed, 0 failures
**Next Round**: R{N+1}

---

## 40-Dimension Scorecard

### Technical (D1-D10): {AVG}/10 — Last evaluated: R{ROUND}
{STATUS_NOTE: e.g., "9.63/10 — infrastructure mature. Re-evaluate after major arch changes only."}

### Behavioral (B1-B10): {AVG}/10 — Target 8.0 — Last evaluated: R{ROUND}
| Dim | Name | Score | Target | Gap | Blocker |
|-----|------|-------|--------|-----|---------|
| B1 | Warmth & Naturalness | {score} | 8.0 | {gap} | {type} |
| B2 | Implicit Signal Detection | {score} | 8.0 | {gap} | {type} |
| B3 | Context Coherence | {score} | 8.0 | {gap} | {type} |
| B4 | Decisive Authority | {score} | 8.0 | {gap} | {type} |
| B5 | Recovery & Adaptation | {score} | 8.0 | {gap} | {type} |
| B6 | Rapport Building | {score} | 8.0 | {gap} | {type} |
| B7 | Multi-turn Memory | {score} | 8.0 | {gap} | {type} |
| B8 | Cultural Sensitivity | {score} | 8.0 | {gap} | {type} |
| B9 | Proactive Engagement | {score} | 8.0 | {gap} | {type} |
| B10 | Overall Host Quality | {score} | 8.0 | {gap} | {type} |

### Profiling (P1-P10): {AVG}/10 — Target 7.0 — Last evaluated: R{ROUND}
| Dim | Name | Score | Target | Gap | Blocker |
|-----|------|-------|--------|-----|---------|
| P1 | Natural Extraction | {score} | 7.0 | {gap} | {type} |
| P2 | Active Probing | {score} | 7.0 | {gap} | {type} |
| P3 | Give-to-Get | {score} | 7.0 | {gap} | {type} |
| P4 | Assumptive Bridge | {score} | 7.0 | {gap} | {type} |
| P5 | Progressive Sequence | {score} | 7.0 | {gap} | {type} |
| P6 | Incentive Framing | {score} | 7.0 | {gap} | {type} |
| P7 | Privacy Respect | {score} | 7.0 | {gap} | {type} |
| P8 | Profile Completeness | {score} | 7.0 | {gap} | {type} |
| P9 | Handoff Quality | {score} | 7.0 | {gap} | {type} |
| P10 | Data Accuracy | {score} | 7.0 | {gap} | {type} |

### Host Triangle (H1-H10): {AVG}/10 — Target 6.0 — Last evaluated: R{ROUND}
| Dim | Name | Score | Target | Gap | Blocker |
|-----|------|-------|--------|-----|---------|
| H1 | Guest Development | {score} | 6.0 | {gap} | {type} |
| H2 | Emotional Intelligence | {score} | 6.0 | {gap} | {type} |
| H3 | Resource Knowledge | {score} | 6.0 | {gap} | {type} |
| H4 | Personalization | {score} | 6.0 | {gap} | {type} |
| H5 | Trust Building | {score} | 6.0 | {gap} | {type} |
| H6 | Relationship Depth | {score} | 6.0 | {gap} | {type} |
| H7 | Revenue Awareness | {score} | 6.0 | {gap} | {type} |
| H8 | Operational Bridge | {score} | 6.0 | {gap} | {type} |
| H9 | Comp Navigation | {score} | 6.0 | {gap} | {type} |
| H10 | Lifetime Value | {score} | 6.0 | {gap} | {type} |

### Summary
- **Dims at target**: {count}/40
- **Dims within 1.0 of target**: {count}/40
- **Critical dims (<3.0)**: {list or "None"}
- **Sub-5.0 dims needing architecture**: {list with blocker types}

---

## This Session's Work

### Deliverables
{numbered list with file paths}

### Tests
- Total: {pass}/{total} | Coverage: ~{pct}%
- New tests this session: {count} ({what they cover})

### Decisions Made
{numbered list — each logged to .claude/decisions.log}

### Learnings Persisted
{numbered list — where each was saved}

---

## R{N+1} EXECUTION PLAN — Deep Prompt for Next Session

### P0: {SINGLE MOST IMPORTANT TASK}

**Why this is P0**: {1-2 sentences explaining why this specific task has the highest ROI for score improvement}

**Exact steps**:
1. {Step 1 with exact command or file path}
2. {Step 2}
3. {Step 3}
...

**Success criteria**: {What must be true for P0 to be "done"}

**Verification command**:
```bash
{exact pytest/eval/curl command to verify P0}
```

### P1: {SECOND PRIORITY}
{Same format as P0}

### P2: {THIRD PRIORITY}
{Same format as P0}

### DEFERRED (do NOT touch next session):
{List of tempting but lower-priority items with reason to defer}

---

## R{N+1} CAPABILITY PRESCRIPTION

### MCP Tools to Use (with EXACT invocations)

For each recommended MCP tool, specify WHEN and HOW to use it:

{Only list tools that are SPECIFICALLY needed for the P0/P1/P2 tasks above. Do NOT list generic tool catalogs.}

Example format:
- **`perplexity_research`** — BEFORE coding P0: research "{specific query}" to ground the approach
- **`vertex_chat` (GPT-5.2/GPT-5.4)** — AFTER coding P0: judge 5 sample transcripts with tools-enabled eval
- **`grok_reason`** — IF P0 eval shows <+1.0 improvement: use as alternative judge perspective
- **`mcp__google-developer-knowledge__search_documents`** — IF fine-tuning: query "Gemini 2.5 Flash fine-tuning format" for latest API docs
- **`mcp__memory__search_nodes`** — search "HeySeven" for cross-session decisions before any architecture change
- **`vertex_deepseek_reason`** — FOR regression analysis if any dim drops >0.5

### Skills to Invoke

{Only list skills that are SPECIFICALLY needed. With trigger condition.}

Example format:
- **`/pre-mortem`** — BEFORE any change touching 3+ files (mandatory per CLAUDE.md)
- **`/ship-it`** — IF scope creep: P0 eval takes >2 hours, cut to 20 scenarios
- **`/multi-model-debate`** — IF architectural decision needed (e.g., switch from Flash to Pro default)
- **`/browser-control` → perplexity-pro** — IF deep research needed (fine-tuning pricing, competitor analysis)
- **`/create-diagram`** — IF graph topology changes

### Agents to Deploy

{Specify exact agent type and task, not generic lists.}

Example format:
- **`research-specialist`** (background): "{specific research query}" — run BEFORE coding starts
- **`code-worker`** (worktree): "{specific implementation task}" — assign specific files
- **`code-judge`** (after implementation): hostile review of {specific files} against {specific criteria}
- **`code-simplifier`**: run on {specific file} if LOC > 100 after changes

### Agent Team Composition (if P0 requires parallel work)

{Only if the work genuinely benefits from parallelism. Specify:}

| Teammate | Role | Owns (specific files) | MCP Tools | Task |
|----------|------|----------------------|-----------|------|
| {name} | {role} | {exact file paths} | {tools} | {exact task description} |

**Lead strategy**: {delegate mode / direct management}
**File ownership rule**: {which files are shared, how to avoid conflicts}

### Eval Pipeline

{Exact commands for the eval this session needs to run:}

```bash
# Run live eval with tools enabled
python3 tests/evaluation/run_live_eval.py --pattern "{specific scenarios}" --round r{N+1} --timeout 120

# Stream-judge in parallel (separate terminal or background)
python3 tests/evaluation/streaming_judge.py --watch results/r{N+1}/ --category all

# OR: Run judge panel on existing results
python3 tests/evaluation/run_judge_panel.py --results-dir results/r{N+1}/ --models gpt-5.4,grok-4,deepseek
```

**Judge panel**: GPT-5.4 + Grok 4 + DeepSeek Speciale (3-model, per R106)
**Eval model**: Gemini 3 Flash (production) or Gemini 3.1 Pro (FORCE_PRO_MODEL=true)
**Scenario count**: {N} — {which YAML files}
**Timeout**: 120s

---

## External Review Readiness Checklist

Before ANY external review (Codex, GPT-5.4 Deep Research, multi-model audit):

- [ ] All tests pass (`pytest tests/ -x`)
- [ ] `test_doc_accuracy.py` passes (node count, pattern count, version parity)
- [ ] README.md reflects actual architecture (node count, pattern count, state fields)
- [ ] ARCHITECTURE.md matches code (graph topology, middleware stack)
- [ ] No dead code (grep all function defs, verify call sites exist)
- [ ] All feature flags have correct defaults (True for wired code, False for disabled)
- [ ] Gold traces align with current authority model (no "booked", no "loaded", CCD pattern)
- [ ] Eval rubrics match current architecture (tool-empowered scoring, not read-only)
- [ ] MEMORY.md under 200 lines
- [ ] Committed and pushed to GitHub

---

## Process Rules Reminder

These rules from `hey-seven-process.md` apply to EVERY session:

1. **Research before code** — at least 1 MCP query before any behavioral change
2. **Hypothesis testing** — if score plateau 3+ rounds, run failure taxonomy (60/40 split)
3. **Human judgment** — Oded reads 5+ transcripts, gives binary host/chatbot verdict
4. **TONE → RELATIONSHIP → AGENCY** framework drives next investment
5. **Anti-reversion locks** — no behavioral code without failure taxonomy, no new prompt sections without removing old ones
6. **Minimum 4 MCP tools** per behavioral session
7. **Gold traces as acceptance tests** — agent must score within 1.0 of gold trace on same scenario

---

## Quick Resume

```
/go
```
```

---

## Phase 6: Update MEMORY.md [10 seconds] — CRITICAL

Update `${CLAUDE_HOME:-$HOME/.claude}/projects/-home-odedbe-projects-hey-seven/memory/MEMORY.md`:

1. Update "Current State" header: round, date, test count, commit hash, version
2. Update per-dimension scores if eval was run this session
3. Add R{N} Changes section (concise: 1-2 lines per major change)
4. Update Strategy section with next session's P0/P1/P2
5. Update "Score Trajectory" one-liner
6. **CRITICAL**: Keep file under 200 lines. If over:
   - Move detailed round-by-round changes to `memory/round-history.md`
   - Move "What ALWAYS/NEVER Works" to `memory/verified-patterns.md` if >40 items
   - Keep MEMORY.md as concise index with latest state + scores + strategy + key references

---

## Phase 7: Update status.json [5 seconds]

Update `$HOME/projects/hey-seven/.claude/status.json`:

```json
{
  "project": "hey-seven",
  "currentState": {
    "summary": "R{N} complete — {brief} — {key change}",
    "lastModified": "{ISO timestamp}",
    "branch": "main",
    "commitHash": "{hash}",
    "tag": "v{VERSION}",
    "phase": "r{N}-{slug}"
  },
  "roundNumber": {N},
  "scores": {
    "technical_rXX": {score},
    "behavioral_rXX_{model}_{count}": {score},
    "profiling_rXX_{model}_{count}": {score},
    "hostTriangle_rXX_{model}_{count}": {score},
    "errorRate_rXX": "{rate}%",
    "per_dimension_rXX": {
      "B1": {x}, "B2": {x}, "...": "all 30 behavioral+profiling+host dims",
      "D_note": "D1-D10 last eval RXX: {score}/10"
    },
    "r{N}_changes": "{what changed, NOT YET RE-EVALUATED if no eval ran}"
  },
  "blockers": [],
  "nextSteps": [
    {"priority": 0, "description": "{P0 with specific action}"},
    {"priority": 1, "description": "{P1}"},
    {"priority": 2, "description": "{P2}"}
  ],
  "keyFiles": {
    "handover": ".claude/handover-{date}-r{N}.md",
    "{other key files from this session}": "{paths}"
  },
  "codebaseMetrics": {
    "tests": {count},
    "testFailures": 0,
    "graphNodes": {count},
    "stateFields": {count},
    "featureFlags": {count},
    "guardrailPatterns": {count},
    "totalScenarios": {count},
    "sourceModules": {count},
    "goldTraces": {count},
    "judgeModels": 3,
    "toolUseEnabled": "{casino list or 'all' or 'none'}"
  },
  "sessionNotes": {
    "lastSessionDate": "{date}",
    "lastSessionId": "{SESSION_ID}",
    "orchestration": "{how work was organized: solo / team / multi-terminal / worktrees}"
  }
}
```

---

## Phase 8: Update decisions.log [3 seconds]

Append architectural decisions made this session to `$HOME/projects/hey-seven/.claude/decisions.log`:

```
[{DATE}] R{N} DECISION: {decision description}
```

One line per decision. Include: what was decided, why, and what alternatives were rejected.

---

## Phase 9: Memory MCP Persistence [5 seconds]

Persist to Memory MCP for cross-session search:

```
mcp__memory__create_entities:
  Entity: {SESSION_ID}
  Type: HeySeven40DimSession
  Observations:
    - "Round: R{N}"
    - "B-avg: {score}/10 (B1={x}, B2={x}, ..., B10={x})"
    - "P-avg: {score}/10 (P1={x}, P2={x}, ..., P10={x})"
    - "H-avg: {score}/10 (H1={x}, H2={x}, ..., H10={x})"
    - "D-avg: {score}/10 (last eval R{XX})"
    - "Key change: {1-line summary}"
    - "P0 next: {next session priority}"
    - "Blockers: {list or 'none'}"
    - "Tests: {count} pass, 0 fail"
    - "Commit: {hash}"
```

---

## Phase 10: Git Finalize [10 seconds]

### 10.1 Commit Handover + State Files

If the handover file and status.json updates are uncommitted:

```bash
git add .claude/handover-*.md .claude/status.json .claude/decisions.log
git commit -m "$(cat <<'EOF'
docs: R{N} session handover + 40-dim scorecard

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

### 10.2 Push to GitHub

```bash
git push origin main
```

### 10.3 Verify Push

```bash
git log --oneline origin/main -1
```

Confirm the remote HEAD matches what we just pushed.

---

## Phase 11: Session Close Receipt — MANDATORY OUTPUT

Print this EXACTLY at the end. This is what the user sees as the final output.

```
=== Hey Seven Session Close ===

Round: R{N} | Date: {DATE}
Commit: {hash} | Pushed: {YES/NO} | Tests: {pass}/{total}

40-Dimension Scorecard:
  D-avg: {score}/10 (tech, last R{XX})   — {DONE/NEEDS REEVAL}
  B-avg: {score}/10 (target 8.0)         — {delta vs prev}
  P-avg: {score}/10 (target 7.0)         — {delta vs prev}
  H-avg: {score}/10 (target 6.0)         — {delta vs prev}

  Dims at target: {count}/40
  Critical (<3.0): {list or "None"}
  Sub-5.0 with fix path: {list}

External Review Ready: {YES / NO — {reason}}

Next Session (R{N+1}):
  P0: {one-line description}
  P1: {one-line description}
  P2: {one-line description}

  Key tools: {2-3 most critical MCP tools for P0}
  Key skill: {1 skill if applicable}
  Mode: {SOLO / TEAM / MULTI-TERMINAL}

Handover: .claude/handover-{date}-r{N}.md
Resume: /go

Session {SESSION_ID} closed.
```

---

## Why 40 Dimensions, Not 30

The original skill counted only B1-B10 + P1-P10 + H1-H10 = 30 behavioral dimensions. But the full quality framework includes:

- **D1-D10 (Technical)**: Graph architecture, RAG pipeline, data model, API design, testing, DevOps, prompts/guardrails, scalability, trade-off docs, domain intelligence
- **B1-B10 (Behavioral)**: Warmth, signals, coherence, authority, recovery, rapport, memory, cultural, proactive, overall
- **P1-P10 (Profiling)**: Extraction, probing, give-to-get, bridges, sequence, incentives, privacy, completeness, handoff, accuracy
- **H1-H10 (Host Triangle)**: Development, EQ, resources, personalization, trust, depth, revenue, operations, comp, LTV

All 40 must be tracked for external reviews to be comprehensive. The technical dimensions (D1-D10) are evaluated less frequently (every 10-20 rounds or after major arch changes) but they anchor the infrastructure quality that behavioral scores depend on.

## Why External-Review-Ready Matters

Oded expects every session to leave the codebase ready for a cold external audit. This means:
- A reviewer can clone the repo, run tests, and see green
- Documentation matches code (counts, topology, features)
- No dead code, no scaffolded-but-unwired modules
- Gold traces and eval rubrics align with current architecture
- The handover tells the NEXT session exactly what external reviewers would look for

If the session ends dirty (failing tests, uncommitted changes, stale docs), the next session wastes 30+ minutes cleaning up before it can do real work.
