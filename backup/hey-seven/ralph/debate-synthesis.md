# 6-Model Debate Synthesis — Architecture Decision

## Date: 2026-02-17
## Result: UNANIMOUS — "In-Memory Swarm"

## The Winning Architecture

All 6 models converged on the same approach (different names):
- Gemini: "In-Memory Swarm"
- GPT-5 Pro: "Ghost Swarm Monolith"
- GPT-5.2: "B-first + bounded swarm hook"
- Grok: "Ghost Swarm with skill registry"

**One process. One deploy. Multiple logical agents. Silent handoffs.**

## Architecture Diagram

```
Single Cloud Run Container
+-- Outer StateGraph (LangGraph)
|   +-- compliance_gate (deterministic guardrails, AI disclosure)
|   +-- router (explicit triggers, not LLM-decided)
|   +-- agent_modules (in-process, silent handoffs)
|   |   +-- host_agent (greeting, general, data collection)
|   |   +-- dining_agent (restaurants, reservations)
|   |   +-- entertainment_agent (shows, events, spa)
|   |   +-- comp_agent (offers, incentives)
|   +-- validation_node (compliance check)
|   +-- persona_envelope (160-char formatting, delay injection)
|   +-- whisper_planner (silent: predicts next conversational beat)
+-- Firestore (checkpointing, guest profiles, casino content)
+-- Firestore Vector Search (embeddings)
+-- Telnyx SMS Gateway
+-- LangFuse (observability)
```

## Why This Won (Unanimous Reasons)
1. Ships fast — single repo, single deploy, 2 engineers handle in weeks
2. Impresses CTO — agent graph visualization, swarm handoffs, hooks/middleware
3. SMS-perfect — silent handoffs in milliseconds, no HTTP round-trips
4. Debuggable — single process, single Firestore checkpointer
5. Scales honestly — feature flags externalize agents when metrics justify

## Final Scores (All Models Combined)
- Technical Excellence: 9/10
- CTO Impression: 9/10
- Time-to-MVP: 9/10
- Scalability: 8/10
- Differentiation: 9/10

## Key Creative Concepts from Debate
1. Whisper Track Planner — silent model predicts next conversational beat
2. Persona Envelope 160 — microcopy gate enforces brand voice + 160 chars
3. Consent/Memory Ledger — profile attributes tagged: source, confidence, consent scope
4. In-Memory Silent Handoff — agent switches in milliseconds
5. Skill ABI with Flip-bit — config flag routes skills in-process or remote
6. Shadow Swarm Simulator — offline "what-if" multi-agent test tool

## Implementation Priority (Consensus)
1. Deliverability + Compliance foundation (Week 1)
2. Core StateGraph + Firestore checkpointing (Week 1-2)
3. First vertical agent - Dining (Week 2)
4. Host/Concierge + silent handoffs (Week 2-3)
5. Whisper Track Planner + profiling (Week 3)
6. Google Sheets CMS + re-indexing (Week 3-4)
7. Observability, replay, policy gates (Week 4)

## Risk Mitigations
- Module boundary erosion → Skill ABI enforced in CI
- Context window pollution → Sanitize/summarize on handoff
- Carrier filtering → Content risk scoring, template rotation
- Firestore 1MB limit → Message windowing + summarization
- CTO wants microservices → Show agent graph + migration path

## Research Findings Informing This Decision

### LangGraph 1.0 (Stream 1)
- Full middleware system: before_model, after_model, wrap_model_call, wrap_tool_call
- create_react_agent deprecated → create_agent with middleware
- langgraph-swarm v0.0.14: peer-to-peer handoffs, create_swarm() + create_handoff_tool()
- langgraph-supervisor v0.0.31: hierarchical, create_supervisor()
- Swarm benchmarks: 18% fewer tokens, higher accuracy vs supervisor on multi-domain
- "Pre-agents" / "pre-evals" NOT official terms — meant middleware + agentevals
- FirestoreSaver: community package, not official. Thread-based checkpointing.
- LangMem: cross-thread semantic memory for guest profiles
- Recommended: Hybrid Custom Graph (outer) + Swarm (inner)

### SMS & Communication (Stream 2)
- Telnyx recommended: $0.004/msg, Google Cloud Marketplace integration
- AI disclosure legally required: CA SB 243 (Jan 2026, $1K/violation), SB 1001, Maine, NJ, CO
- Cost: 5K guests x 4 msgs/mo x 1.5 segments = 30K segments/month = ~$231/mo on Telnyx
- 10DLC numbers: $0.50-$1/mo (vs short codes $500-$1K/mo)
- A2P 10DLC registration: $4.50-$46 one-time + $10-15/mo campaign fees
- English + Spanish covers ~91% of US casino guests
- 1-3 second intentional delay, 48-hour session timeout
- Keep under 160 chars (GSM-7) to avoid 2x cost from segmentation
- Carrier surcharges: AT&T $0.003, T-Mobile $0.0025, Verizon $0.004

### GCP Infrastructure (Stream 3)
- gemini-embedding-001: $0.15/1M tokens, 3072 dims with Matryoshka (768 for cost), 100+ languages
- Firestore native vector search (GA since Sep 2024): max 2048 dims, near-zero cost
- Vertex AI Vector Search 2.0: hybrid search + built-in RRF, but ~$55/mo minimum
- Per-casino: separate Firestore databases (not projects, not collections)
- Estimated cost: ~$600-700/month for 10 casinos
- langgraph-checkpoint-firestore: community package, functional, 1MB doc limit
- LangFuse Cloud: $29/month managed, MIT open source, self-hostable on Cloud Run

### Content Management & Profiling (Stream 4)
- Google Sheets + webhook-triggered re-indexing: proven pattern for non-technical users
- Incremental vector upserts via content hash IDs (no full rebuilds)
- Headless CMS (Sanity, Strapi) heavier alternatives
- Firestore document model: core_identity, preferences, inferred_preferences, consent
- Subcollections for conversations and behavioral_signals (avoid 1MB limit)
- Bayesian preference inference from conversation signals
- "Seven Concierge" hybrid naming recommended
- CA SB 243 MANDATES AI disclosure — disclosure before engagement prevents trust reversal
- Variable artificial delays (~300ms/sentence) increase cognitive trust
- SMS under 160 chars, professional-friendly tone
- Reciprocity works: agent shares purpose first, then asks
- LangFuse: free tier 50K units/month, no per-seat fees, LangGraph integration ~10 lines
