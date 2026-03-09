# R106 Multi-Terminal Orchestration Learnings

Date: 2026-03-09
Session: R106 Architecture Shift

## What Worked

1. **4 terminals, 0 merge conflicts** — strict file ownership matrix in status.md prevented all conflicts
2. **Interface-spec-in-prompt** — T2 coded _base.py integration against casino_tools.py function signatures before T1 delivered the files. When T1 finished, T2's imports resolved immediately.
3. **Independent work (T4) finished first** — research + data prep had zero code deps, completed in ~30 min
4. **T1 as lead with merge authority** — fixed T4's missing expected_keywords and config parity across terminals
5. **Prompt files in .claude/teams/ directory** — each terminal read its own detailed prompt, kept copy-paste prompts short
6. **Execute mode, not plan mode** — no approval gate, terminals started working immediately

## What Failed / Could Improve

1. **T4 didn't read existing scenario format** — created YAML without `expected_keywords` (required by test). Fix: prompt must say "read an existing scenario file first for format"
2. **`replace_all` on config.py missed nested indentation** — DEFAULT_CONFIG (8-space) matched, casino profiles (12-space) didn't. Fix: grep ALL indentation levels, or add flag at both levels explicitly
3. **MCP model list was stale** — `list_models` didn't show GPT-5.4 that user deployed today. Fix: trust user over MCP cache for recent deployments
4. **No real-time progress visibility** — T1 couldn't see T3's progress without asking user. Fix: simple progress file or scenario counter
5. **Multiple background pytest runs got confusing** — 5 different task IDs, hard to track which was latest. Fix: use foreground for the "final" run

## Comparison: Multi-Terminal vs Swarm Teams

| Dimension | Multi-Terminal (R106) | Swarm Teams (R68, R105) |
|-----------|----------------------|------------------------|
| Context per worker | Full Opus 1M | Shared/limited |
| MCP access | Full per terminal | Limited/lazy-loaded |
| File ownership | Strict matrix | Strict matrix |
| Communication | Human message bus | Team memory file |
| Merge validation | T1 lead runs tests | Lead reviews |
| Setup overhead | ~15 min (write prompts) | ~5 min (TeamCreate) |
| Best for | 4+ hour multi-stream work | 2 workers, quick tasks |
| Rate limit impact | 4x API usage | Shared budget |
| Context overflow risk | None (independent) | High for complex tasks |

## Key Numbers

- 4 terminals × ~2 hours each = ~2 hours wall clock (vs ~6-8 sequential)
- 922 critical tests, 0 failures
- 0 merge conflicts
- T4 finished in ~30 min, T1 in ~45 min, T2 in ~35 min, T3 in ~60 min (eval-bound)
- 46 + 33 = 79 new tests across T1 + T2
- 15 new B8 scenarios (T4)
- 51 gold traces exported (T4)
- 3-model judge panel upgraded (T3)

## Pattern: When to Use Each

```
Single file change     → Default session (no parallelism)
Quick focused task     → Subagent (fire-and-forget)
2 independent workers  → Swarm Teams (low overhead)
3-4 independent streams → Multi-Terminal (max parallelism)
5+ streams             → Too much coordination → split into 2 sessions
```
