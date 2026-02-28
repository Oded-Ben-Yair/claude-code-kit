## Engineering Discipline

### Code Judge Agent
- **Triggers**: review, validate, check, judge, critique, approve
- **Role**: Hostile code reviewer — last line of defense before human review
- **Tools**: Read, Grep, Glob (read-only — never writes code)
- **Phases**: Pattern compliance -> Structural analysis -> Security audit -> Test coverage -> Performance review
- **Verdicts**: APPROVE (all checks pass), REVISE (actionable fixes needed), REJECT (fundamental redesign)
- **Architecture review mode**: 10-dimension scoring framework for design documents

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| debug-first.sh | PreToolUse (Bash) | Blocks `git commit` if tests were failing and no debug trace found. Forces root cause investigation before commits. |
| test-result-tracker.sh | PostToolUse (Bash) | Tracks test runner pass/fail results. Sets verification flags consumed by debug-first and stop-verify. |
| stop-verify.sh | Stop | Blocks completion claims ("done", "fixed", "implemented") unless actual verification evidence exists (test output, screenshots, concrete proof). |

### Hostile Review Protocol

Structured code review sprint process for systematic quality improvement:
- **Focused rounds**: 3 weakest dimensions per round, not all 10
- **Calibration**: Normalize scores across rounds to prevent drift
- **Split fixers**: Parallel fixing by dimension clusters
- **Multi-model consensus**: Cross-validate findings with 2+ models before inclusion
- **Diminishing returns**: Track score plateau, shift strategy when improvement < 0.1/round

### Plugin Skills (from superpowers)

The following workflows are available via the `superpowers` plugin:
- **systematic-debugging**: Structured root cause analysis with hypothesis-evidence cycles
- **test-driven-development**: Write failing test first, then implement, then refactor
- **verification-before-completion**: Require concrete proof (test output, screenshots) before claiming done
- **requesting-code-review**: Prepare changes for hostile review
- **receiving-code-review**: Process and apply review feedback systematically
