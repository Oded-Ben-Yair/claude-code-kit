# Hey Seven Project Memory

## GROUND RULE (Oded, 2026-03-09): NO MOCKING — FULL PURGE PENDING
Do NOT add, modify, or fix mock-based tests. All validation uses live LLM calls via `tests/evaluation/`. Existing mocks are legacy. When code changes break mock tests, skip them — do NOT fix the mock. This is non-negotiable.

**R110 ESCALATION (Oded)**: Next session P0 — deep scan ALL test files, remove ALL mock tests and mock references entirely. The skip-based approach creates confusion about what's real vs mocked. Aim: zero MagicMock/AsyncMock in the test suite. Only deterministic tests (guardrails, extraction, sentiment, incentives) and live eval remain.

## Current State (2026-03-09, R110 — PROMPT + ARCHITECTURE IMPROVEMENTS)
- **Tests**: 3536+ passing, ~350 mocks skipped (pending full purge next session)
- **Graph**: 13-node StateGraph v2.4, **31 state fields**, tool-call loop in execute_specialist()
- **Version**: v1.6.0
- **Feature flags**: 19 (tool_use_enabled=**True for Mohegan Sun**, False default)
- **Source files**: 74 modules, ~27K LOC, **0 scaffolded** (all wired)
- **Casino tools**: 4 @tool functions in `src/agent/casino_tools.py` — comp, tier, events, incentives
- **Tool binding**: per-agent mapping in `src/agent/agents/tool_binding.py`
- **Authority model**: Tool-empowered CCD (Checked-Confirmed-Dispatched)
- **Guardrail patterns**: 214 | **Slop patterns**: 17 | **Few-shot examples**: 27 | **Bridges**: 15
- **Eval**: 3-model judge panel (GPT-5.4 + Grok 4 + DeepSeek Speciale)
- **Scenarios**: 270 across 35 YAML files
- **Gold traces**: 51 conversations in `data/training/` (CCD-compliant)
- **Fine-tune target**: Gemini 2.5 Flash (100+ examples needed, have 51)
- **40-dim review prompt**: `docs/r108-external-review-prompt.md` (ready for GPT-5.4 Pro)

### R108 Critical Bug Fix
`get_casino_config()` fell back to DEFAULT_CONFIG (tool_use_enabled=False) in local dev, ignoring CASINO_PROFILES. **Tools were NEVER binding.** Fixed: Firestore → CASINO_PROFILES → DEFAULT_CONFIG.

### R108 Eval Results (5 scenarios, Flash + tools)
- Tool execution rate: **54%** (13/24 bindings → executions)
- 0% error rate, 27% fallback rate (3rd-turn confirmations)
- All 5 scenarios had tool invocations: host(6), entertainment(6), comp(2)
- CCD language confirmed in transcripts

### R105 Baselines (85 scenarios, Pro, GPT-5.2 judge)
- **B-avg**: 6.62 | **P-avg**: 5.18 | **H-avg**: 5.09
| B1:7.45 | B2:5.93 | B3:6.64 | B4:6.32 | B5:6.82 | B6:6.24 | B7:6.88 | B9:6.72 | B10:6.32 |
| P1:5.05 | P2:6.54 | P3:7.29 | P4:5.34 | P5:5.53 | P6:3.93 | P7:4.70 | P8:3.62 | P9:4.30 | P10:6.50 |
| H1:6.30 | H2:5.87 | H3:5.17 | H4:6.07 | H5:5.30 | H6:4.50 | H7:5.37 | H8:6.10 | H9:2.35 | H10:3.87 |

### Score Trajectory
R98(B:6.15,H:5.04) → R102(B:6.62,P:4.60) → R105(B:6.62,P:5.18,H:5.09) → R107(tools) → R108(tools confirmed) → **R109(research deployed, no eval)**

### R109 Deep Research (9 files, 294K)
- `research/r109-research-synthesis.md` — **START HERE**: 25 ranked recommendations
- T1: SFT/DPO guide ($225-370, tool calls supported, thinking=OFF)
- T2: Comp thresholds $100-150 industry norm, endowment framing 3x loyalty
- T3: 5 VIP motivations (Parke 2019), AI disclosure advantage (CASA), 25% guarded VIPs
- T4: 4 new profiling techniques (assumption_probe, anchor_expand, soft_binary, open_anchor)
- T5: 3-tier handoff (+23% upgrades), top 10 high-value data points
- T6: Flash outperforms Pro for tools (~20% Pro crash rate), ICC(3,k) metric
- T7: SAFE Bet Act threat, CCPA ADMT opt-out by Jan 2027, TCPA "any reasonable means"
- T8: QCI dominant (300+ casinos), no direct autonomous AI host competitor, zero brand presence

### R110 Changes (DONE)
- **Profiling**: 4 new techniques (assumption_probe, anchor_expand, soft_binary, open_anchor) — 7→11 total
- **Incentives**: Endowment framing ("you've earned") replaces transactional ("we'd like to offer") in Mohegan Sun rules
- **Few-shots**: 4 examples updated — profiling questions embedded IN recommendations, not appended
- **Specialists**: Profile-reference requirement injected when name/occasion/party_size/preferences known
- **Whisper planner**: Profiling intensity curve (T1-2: any technique, T3: inference only, T4: need_payoff, T5+: confirm only)
- **Extraction**: 3 contextual inference rules ("we"=group, "just arrived"=urgency, "the kids"=family)
- **Handoff**: 3-tier model (quick/standard/full) + hero_moment field
- **Comp**: Auto-approve raised $50→$100 regular, $250 VIP (industry benchmark)
- **Doc parity**: ARCHITECTURE.md fixed (12→13 nodes, 204→214 patterns)
- **GPT review**: `docs/r110-gpt-review-analysis.md` — score comparison + deferred items

### Strategy (R111+): EVAL → FINE-TUNE
1. **P0**: 7 prompt-only changes (4 techniques + endowment + embedded Qs + profile ref)
2. **P1**: 4 code changes (intensity curve, inference rules, 3-tier handoff, comp $100/$250)
3. **P2**: 30-scenario eval measuring P0+P1 impact vs R105
4. **P3**: Gold trace expansion to 100+ for SFT Phase 1
5. **GPT-5.4 Pro review**: submitted, results expected — cross-reference with synthesis

### Sub-5.0 Dims Status
- H9(2.35): Tool BUILT + ENABLED + CONFIRMED WORKING. Eval needed with Pro.
- P9(2.45→4.3): FIXED (+1.85). Handoff bug fix confirmed.
- P6(3.93): Tool built (check_incentive_eligibility). Needs eval.
- P8(3.62): Needs fine-tuning (extraction prompt ceiling confirmed).
- H10(3.87): Tool built (lookup_upcoming_events). Needs eval.
- H6(4.50): Rapport ladder built. Needs Pro eval.
- P7(4.70): Approaching target.

## Technical Notes
- Gemini 3.x returns `AIMessage.content` as `list[dict]` — use `_normalize_content()`
- Gemini 3.1 Pro: 250 RPD free tier. One 30-scenario eval = ~180 calls.
- GPT-5.2/5.4 is the reliable judge (100% completion, ±0.03-0.09 variance)
- `grep "^GOOGLE_API_KEY="` — MUST use ^ anchor
- Gemini MCP server: different leaked key (403). MCP Gemini tools unavailable.
- Flash with tools: ~45s/turn (vs ~20s without tools). Re-invocation adds latency.

## Judge Panel
- GPT-5.4 via Azure AI Foundry — 100% reliable, ~5s per scenario
- Grok 4 — 60% reliable, inflates 2-3 pts
- DeepSeek Speciale — best "guest lens" judge, harsh but calibrated
- Gemini as judge: DROP (20% success rate, too slow)

## Key Anti-Patterns (Top 10)
1. Mock behavioral scoring overestimates by 43%
2. Prompt instructions hit ceiling at 5.0 — architecture changes needed below
3. Flash ignores multi-section prompt injections (R98-R105 confirmed)
4. Sequential eval→judge wastes 40-60% wall-clock vs streaming
5. `source .env` doesn't export to subprocesses
6. Static DEFAULT_FEATURES.get() bypasses per-casino overrides (R108 bug)
7. FORCE_PRO_MODEL makes router Pro too → 77% deflection
8. Substring matching for keywords: "comp" matches "comparison"
9. Feature flag=False on wired code = dead code
10. Handoff prompt after llm.ainvoke() = dead code (R105 CRITICAL)

## What ALWAYS Works (Top 15)
1. Live eval with streaming judge → real-time scores
2. Few-shot examples > tone instructions
3. Per-item chunking for structured RAG data
4. Hypothesis testing before code changes
5. 3-model judge disagreement mining > averages
6. Fix at the SOURCE not downstream
7. "3→6 is TONE, 6→8 is RELATIONSHIP, 8→9 is AGENCY"
8. Research via MCPs BEFORE coding
9. Gold trace calibration anchors (3/6/9)
10. Cross-module field parity assertions
11. Lightweight bridge (3 lines) > full section injection
12. Wire dead code or delete it — grep call sites
13. Architecture audit BEFORE building
14. Structured behavior tools > prompt optimization below 5.0
15. CCD pattern: Checked-Confirmed-Dispatched (R107 industry standard)

## GCP Notes
- Fine-tuning: Gemini 2.5 Flash only (NO 3.x). SFT+DPO available.
- Cloud Run + Redis: Direct VPC egress > VPC connector
- Firestore Vector Search: native LangChain class available
- Use `mcp__google-developer-knowledge__search_documents` for GCP docs

## Detailed Topic Files
- `memory/round-history.md` — R97-R109 per-round changes
- `memory/honest-audit.md` — R81 honest answer + blind spots
- `memory/score-trajectory.md` — full score history R52-R82
- `memory/r101-phase0-findings.md` — failure taxonomy + gold traces
- `memory/r106-multi-terminal-learnings.md` — 4-terminal parallel pattern
- `research/r109-research-synthesis.md` — **R109 synthesis: 25 ranked recs, psychology playbook, fine-tuning blueprint**
