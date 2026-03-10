# 30-Dimension Perfection Blueprint — Session Reference

This file is the single source of truth for what each session should deliver.
Updated after each session based on actual progress.

---

## Targets

| Dimension Group | Current | Target | Gap |
|----------------|---------|--------|-----|
| Behavioral B10 | 6.2 | 8.0 | 1.8 |
| Profiling P-avg | 5.0 | 7.0 | 2.0 |
| Host H-avg | 0 | 6.0 | 6.0 |
| Safety | 95% | 100% | 5% |

---

## Session Map

### R86 (Phase A) — COMPLETED 2026-03-04
- [x] Eval v2 system (tests/evaluation/v2/)
- [x] BSA/AML CTR threshold removal
- [x] Canned deflection elimination
- Commit: a85e687

### R87 (Phase A) — Next
**Goal**: Fix two biggest structural blockers

**Deliverable 1: Pre-extraction node** (fixes one-turn profiling lag)
- CREATE `src/agent/pre_extract.py` — regex for name, party_size, occasion, visit_duration (<1ms)
- MODIFY `src/agent/graph.py` — insert NODE_PRE_EXTRACT between whisper and generate
- MODIFY `src/agent/constants.py` — add constant, update _KNOWN_NODES
- Keep existing post-generate profiling_enrichment_node for nuanced extraction

**Deliverable 2: Handoff SSE emission**
- MODIFY `src/agent/graph.py:650` — after done event, read final state, emit handoff event if handoff_request set

**Deliverable 3: Wire incentive approval path**
- MODIFY `src/agent/incentives.py` — when check_auto_approve() returns False, call build_host_approval_request()
- Lower completeness gate from 50% → 25%

**Deliverable 4: Run eval v2 baseline**
- Run `python -m tests.evaluation.v2.cli run` on 20-scenario subset
- Compare to R85 responses
- Get R86 behavioral baseline scores

**Expected impact**: P1: 4.4→6.0, P6: 3.8→5.5, P8: 3.6→5.0, P9: 4.9→6.5

**Recommended mode**: SOLO (sequential deliverables, graph topology change needs care)

**Key tools**:
- `code-worker` for implementation
- `code-judge` for review after graph change
- Eval v2 CLI for baseline measurement
- `pytest tests/test_graph_v2.py -x` after topology change

### R88 (Phase B)
**Goal**: Multi-turn scenarios + post-gen enforcement

- CREATE `tests/scenarios/behavioral_multiturn_deep.yaml` (10 scenarios, 5-8 turns)
- CREATE `tests/scenarios/behavioral_escalation_journey.yaml` (10 scenarios)
- CREATE `tests/scenarios/behavioral_profile_memory.yaml` (10 scenarios)
- CREATE `src/agent/response_validator.py` — regex: has_concrete_fact, has_followup, is_not_repetitive
- MODIFY `src/agent/nodes.py` — extend _SLOP_PATTERNS
- Wire response_validator from persona_envelope_node (log-only for MVP)

**Recommended mode**: TEAM (2 teammates: scenario-writer + code-worker)

### R89 (Phase B)
**Goal**: Sarcasm + signals + cultural + profiling techniques

- MODIFY `src/agent/sentiment.py` — sarcasm_detected boolean
- MODIFY `src/agent/agents/_base.py` — sarcasm instruction, signal patterns, cultural sensitivity
- MODIFY `src/agent/profiling.py` — give-to-get templates, assumptive bridging
- CREATE `tests/scenarios/behavioral_sarcasm_v2.yaml` (5 scenarios)
- CREATE `tests/scenarios/behavioral_cultural_v2.yaml` (5 scenarios)

**Recommended mode**: TEAM (2 workers: behavioral + profiling, in parallel)
**Key research**: Use `perplexity_research` for assumptive bridging techniques in luxury hospitality

### R90 (Phase B)
**Goal**: Experience design + coherence + profiling optimization

- MODIFY `src/agent/whisper_planner.py` — experience_plan field
- MODIFY `src/agent/agents/_base.py` — time-sequenced cross-domain suggestions
- CREATE `src/agent/coherence.py` — cross-turn contradiction + repetition detection
- CREATE `tests/scenarios/behavioral_experience_design.yaml` (8 scenarios)
- MODIFY `src/agent/profiling.py` — adaptive phase, profile status injection

**Expected**: B10→8.0 (target met)

### R91 (Phase C)
**Goal**: Profiling polish + H1-H4 first measurement

- Polish P1/P6/P10 dimensions
- CREATE 4 host scenario files (8 scenarios each)
- Expand judge rubric with H-dimensions

**Expected**: P-avg→7.2 (target met)

### R92 (Phase D)
**Goal**: Casino outcomes (H5-H7)

- Retention behavior, offer correctness, proactive responsible gaming
- CREATE 3 host scenario files

### R93 (Phase D)
**Goal**: Host workflow (H8-H10) + Host API

- CREATE `src/api/host_api.py`, `src/data/host_card.py`
- Enhanced handoff packet
- Host action API stub

### R94 (Phase E)
**Goal**: Cross-dimension optimization

- Full 30-dimension eval
- Cross-dimension edge cases
- Fix anything below target

### R95 (Phase E)
**Goal**: Final polish + ship

- Ship criteria: B10>=8.0, P-avg>=7.0, H-avg>=6.0, Safety 100%

---

## Dimension Targets (Quick Reference)

### Behavioral
| Dim | Name | Target |
|-----|------|--------|
| B1 | Sarcasm & Tone | 8.0 |
| B2 | Implicit Signals | 8.0 |
| B3 | Conversational Engagement | 8.0 |
| B4 | Agentic Proactivity | 8.0 |
| B5 | Emotional Intelligence | 8.0 |
| B6 | Tone Calibration | 8.0 |
| B7 | Multi-Turn Coherence | 8.5 |
| B8 | Cultural & Multilingual | 7.5 |
| B9 | Safety & Compliance | 9.5 |
| B10 | Overall Quality | 8.0 |

### Profiling
| Dim | Name | Target |
|-----|------|--------|
| P1 | Natural Extraction | 7.5 |
| P2 | Active Probing | 7.0 |
| P3 | Give-to-Get Balance | 7.0 |
| P4 | Assumptive Bridging | 7.0 |
| P5 | Progressive Sequencing | 7.5 |
| P6 | Incentive Framing | 7.0 |
| P7 | Privacy Respect | 9.0 |
| P8 | Profile Completeness | 7.0 |
| P9 | Host Handoff Quality | 7.5 |
| P10 | Cross-Turn Memory | 8.0 |

### Host Triangle
| Dim | Name | Target |
|-----|------|--------|
| H1 | Host Data Feed Quality | 7.5 |
| H2 | Bidirectional Sync | 7.0 |
| H3 | Comp Coordination | 7.0 |
| H4 | Guest Journey Orchestration | 6.5 |
| H5 | Casino ROI Intelligence | 6.0 |
| H6 | Host Workload Optimization | 7.0 |
| H7 | Escalation Intelligence | 7.5 |
| H8 | Cross-Channel Consistency | 6.5 |
| H9 | Real-Time Event Awareness | 5.0 |
| H10 | Guest Lifetime Value | 6.0 |
