# External Audit Prompt for ChatGPT 5.4 Pro Deep Research

## Instructions for Oded
1. Open ChatGPT 5.4 Pro → Deep Research mode
2. Paste the prompt below
3. It will browse the GitHub repo and produce a structured report
4. Save the output to `.claude/teams/r106-multi-terminal/external-audit-r106.md`
5. Next session reads this file FIRST before planning

---

## PROMPT (Copy everything below this line)

---

I need a comprehensive hostile technical audit of an AI casino host agent codebase. This is a production system for Hey Seven (heyseven.ai) — an AI that handles all digital casino host tasks 24/7.

**GitHub Repository**: https://github.com/Oded-Ben-Yair/hey-seven (main branch, latest commit)

**Your role**: You are a hostile senior engineer reviewing this codebase for a seed-stage startup before they deploy to production. Your job is to find EVERY weakness, not to be nice. Score each dimension 1-10 with specific file:line evidence.

## AUDIT STRUCTURE: 40 Dimensions

Score each dimension 1-10. For each dimension:
- **Score**: X/10
- **Evidence**: Specific file paths and line numbers
- **Strengths**: What's done well (be specific)
- **Weaknesses**: What's missing or broken (be specific)
- **Priority fix**: The ONE thing to fix first for this dimension

### Technical Dimensions (D1-D10)

**D1: Graph/Agent Architecture** — Review `src/agent/graph.py`, `src/agent/agents/_base.py`, `src/agent/state.py`. Check: SRP (<100 LOC/fn), validation loops, structured routing, bounded retries, StateGraph node count, conditional edges.

**D2: RAG Pipeline** — Review `src/rag/pipeline.py`, `src/rag/firestore_retriever.py`, `src/rag/reranking.py`, `src/rag/embeddings.py`. Check: per-item chunking, RRF reranking, idempotent ingestion, version-stamp purging, relevance score filtering.

**D3: Data Model** — Review `src/agent/state.py`, `src/data/models.py`, `src/data/guest_profile.py`. Check: TypedDict state with custom reducers, parity checks, serialization safety, accumulated state fields.

**D4: API Design** — Review `src/api/app.py`, `src/api/middleware.py`, `src/api/models.py`. Check: pure ASGI middleware, SSE streaming, rate limiting, security headers, Cache-Control/ETag.

**D5: Testing Strategy** — Review `tests/` directory structure, `tests/conftest.py`, count test files. Check: coverage config, test count, E2E graph tests, property-based tests, live LLM tests.

**D6: Docker & DevOps** — Review `Dockerfile`, `.github/` or CI config, `requirements*.txt`. Check: multi-stage build, non-root user, --require-hashes, HEALTHCHECK, SBOM, pip-audit.

**D7: Prompts & Guardrails** — Review `src/agent/guardrails.py`, `src/agent/compliance_gate.py`, `src/agent/prompts.py`. Check: multi-layer normalization, pre-LLM deterministic guardrails, fail-closed, guardrail pattern count, re2 compatibility.

**D8: Scalability & Production** — Review `src/agent/circuit_breaker.py`, `src/api/middleware.py`, `src/state_backend.py`. Check: TTL jitter, circuit breaker with Redis sync, graceful shutdown, per-client locks, backpressure via semaphore.

**D9: Trade-off Documentation** — Review `docs/` directory, any ADR files. Check: ADR count, status lifecycle, version parity across docs, runbook sections.

**D10: Domain Intelligence** — Review `src/casino/config.py` (CASINO_PROFILES), `knowledge-base/` directory, `src/agent/incentives.py`. Check: multi-property configs, regulatory accuracy, onboarding completeness.

### Behavioral Dimensions (B1-B10)

For each: review `src/agent/prompts.py`, `src/agent/agents/_base.py`, relevant test scenarios in `tests/scenarios/`.

**B1: Sarcasm Detection** — Review `src/agent/sentiment.py` (context-contrast detection). Does the agent recognize and respond appropriately to sarcasm?

**B2: Implicit Understanding** — Can the agent read between the lines? Check prompt instructions for subtext handling.

**B3: Engagement Quality** — Review few-shot examples in prompts.py. Does the agent maintain conversation quality over multiple turns?

**B4: Agentic Decisiveness** — Does the agent make decisions ("Booked!") or hedge ("Would you like me to...")?  Check prompt identity section.

**B5: Emotional Intelligence** — Review `src/agent/crisis.py`, sentiment detection. How does the agent handle grief, frustration, celebration?

**B6: Tone Calibration** — Check `src/agent/persona.py`, branding config. Does tone adapt per-casino (luxury Wynn vs casual Hard Rock)?

**B7: Multi-turn Coherence** — Review sliding window in `_base.py`, whisper planner. Does context persist correctly across turns?

**B8: Cultural Sensitivity** — Review `tests/scenarios/cultural_sensitivity.yaml` (15 scenarios). Coverage: LGBTQ+, religious, disability, tribal heritage, military, multilingual.

**B9: Safety & Compliance** — Review guardrails (5 layers), crisis escalation (4 levels), responsible gaming detection. Is it fail-closed?

**B10: Overall Quality** — Holistic assessment of response quality based on prompt engineering, few-shot examples, and validation loop.

### Profiling Dimensions (P1-P10)

**P1: Natural Extraction** — Review `src/agent/extraction.py`. Does the agent extract guest info naturally without interrogating?

**P2: Active Probing** — Review whisper planner (`src/agent/whisper_planner.py`). Does the agent ask profiling questions every turn?

**P3: Give-to-Get** — Does the agent offer value before asking for info? Check few-shot examples.

**P4: Assumptive Bridging** — Does the agent make reasonable assumptions from context?

**P5: Progressive Sequencing** — Review `src/agent/profiling.py` golden path. Does profiling follow a logical order?

**P6: Incentive Framing** — Review `src/agent/incentives.py`. Are incentives woven naturally or forced?

**P7: Privacy Respect** — Does the agent respect boundaries when guests decline to share info?

**P8: Profile Completeness** — Review extraction prompt, profile fields. How complete are profiles after 5 turns?

**P9: Host Handoff** — Review `src/agent/behavior_tools/handoff.py`. Is handoff data structured and actionable for human hosts? NEW: 5 handoff modes (frustration, farewell, VIP, transition, long_conversation).

**P10: Cross-Turn Memory** — Does the agent remember and USE info from earlier turns?

### Host Triangle Dimensions (H1-H10)

**H1: Property Knowledge** — Can the agent name specific venues, hours, features?

**H2: Need Anticipation** — Does the agent anticipate unstated needs?

**H3: Solution Synthesis** — Does the agent create plans, not lists?

**H4: Emotional Attunement** — Does the agent match emotional register?

**H5: Trust Building** — Does the agent admit limitations honestly?

**H6: Rapport Depth** — Review `src/agent/behavior_tools/rapport_ladder.py`. Genuine rapport vs transactional?

**H7: Revenue Generation** — Natural upselling without being salesy?

**H8: Upsell Timing** — Appropriate timing of premium suggestions?

**H9: Comp Strategy** — Review `src/agent/casino_tools.py` (NEW R106 tool-use), `src/agent/behavior_tools/comp_strategy.py`. NEW: Agent can now CALL tools mid-conversation for real comp data. Check tool definitions and integration in `_base.py`.

**H10: Lifetime Value** — Review `src/agent/behavior_tools/ltv_nudge.py`. Does the agent plant seeds for return visits?

## SPECIAL ATTENTION: R106 Tool-Use Architecture (NEW)

This is the latest architectural change. Deep-dive into:
1. `src/agent/casino_tools.py` — 4 @tool functions. Are the tool descriptions good enough for the LLM to choose correctly?
2. `src/agent/agents/tool_binding.py` — Per-agent tool mapping. Is the mapping logical?
3. `src/agent/agents/_base.py` lines 1332-1434 — Tool-call loop. Is it safe? Max 1 round? Error handling?
4. `src/casino/feature_flags.py` — `tool_use_enabled` defaults to False. Is the rollout strategy sound?
5. Fine-tuning prep: `scripts/export_gold_traces.py`, `data/training/`. Format correct for Vertex AI?

## OUTPUT FORMAT

```markdown
# Hey Seven R106 External Audit Report

Date: YYYY-MM-DD
Auditor: ChatGPT 5.4 Pro Deep Research
Commit: [hash from GitHub]

## Executive Summary
[3-5 sentences: overall assessment, biggest strengths, biggest risks]

## Scores Summary Table
| Dimension | Score | Priority Fix |
|-----------|-------|-------------|
| D1 | X/10 | ... |
| ... | ... | ... |
| H10 | X/10 | ... |

## Dimension Details
[For each of 40 dimensions: score, evidence, strengths, weaknesses, priority fix]

## Critical Findings (Score < 5)
[List all dimensions scoring below 5 with remediation plan]

## Architecture Assessment
[Specific to R106 tool-use: is this the right direction?]

## Fine-Tuning Readiness
[Assessment of gold traces, JSONL format, training strategy]

## Top 10 Priority Fixes (Ordered)
1. ...
2. ...
...

## Recommendation
[Ship/Hold/Major rework needed]
```

Be thorough. Be hostile. Miss nothing. The startup's production deployment depends on this audit being honest.
