# Hey Seven v2 Architecture Design — Grading Rubric

## Grading Rules
- Each dimension scored 1-10 by each of 6 LLMs
- Target: 9.5/10 minimum per dimension per LLM (unanimous)
- 6 LLMs: GPT-5.2, Grok-4, Perplexity, Gemini 3 Pro, GPT-5 Pro, Codex
- Grade ONLY on what's written in the doc — no assumptions about "they probably know this"

## 10 Dimensions

### 1. Agent Architecture (Weight: Critical)
**9.5 requires ALL of:**
- LangGraph In-Memory Swarm pattern clearly described with code-level specificity
- Outer StateGraph topology: every node named, every edge defined, every conditional explained
- Inner agent modules: each agent's responsibilities, tools, system prompt intent
- Silent handoff mechanism: how create_handoff_tool() works in-process
- LangGraph 1.0 middleware usage: before_model, after_model, wrap_tool_call with casino-specific examples
- State management: full TypedDict schema, Annotated reducers, per-turn vs persistent fields
- Whisper Track Planner: architecture, how it interfaces with the speaking agents
- Validation loop: generate → validate → retry → fallback with retry limits
- Error handling at every node boundary
- Why this architecture over alternatives (supervisor, pure custom, etc.)

### 2. Data Model (Weight: Critical)
**9.5 requires ALL of:**
- Guest profile Firestore document schema (exact fields, types, nesting)
- Progressive profiling: how fields are added over time, confidence scoring
- Conversation state: thread_id format, message windowing strategy, TTL
- Casino content model: document structure per category (dining, entertainment, spa, gaming, etc.)
- Firestore collection hierarchy (per-casino database → collections → subcollections)
- Indexes needed for vector search and queries
- Data lifecycle: creation, update, archival, deletion policies
- Cross-reference: how guest profile connects to conversation history
- Privacy: PII handling, data retention, consent tracking per field
- Migration strategy: schema evolution over time

### 3. SMS/Communication Design (Weight: Critical)
**9.5 requires ALL of:**
- Telnyx integration architecture: webhook flow, send/receive, error handling
- 10DLC registration process and requirements
- TCPA compliance: opt-in verification, consent storage, opt-out (STOP) handling
- 160-character GSM-7 segment management (splitting, concatenation, Unicode handling)
- Human-like delay injection: variable timing, how it's calculated, where in the pipeline
- Carrier filtering mitigation: content risk scoring, template rotation, avoid spam triggers
- Rate limiting: per-number (1 MPS), per-casino, burst handling
- Session management: 48-hour timeout, session resumption, context loading
- Outbound first-message flow: trigger, content, AI disclosure, CTA
- Error handling: delivery failures, retry logic, fallback channels
- Cost model: per-message breakdown, monthly estimates at scale
- Multilingual: English + Spanish message handling, language detection

### 4. RAG/Embeddings Pipeline (Weight: High)
**9.5 requires ALL of:**
- Embedding model: gemini-embedding-001, dimensions (768 vs 3072), Matryoshka explanation
- Firestore native vector search: setup, indexing, query patterns, limitations (2048 dim max)
- Per-item chunking strategy for structured casino data (not text splitters)
- Category-specific formatters with examples (dining item → text, event → text)
- SHA-256 content hashing for idempotent ingestion (re-run = no duplicates)
- RRF reranking: multi-strategy retrieval, fusion algorithm, k=60
- Property ID metadata filtering (multi-tenant safety)
- Relevance score thresholds and quality filtering
- Re-indexing flow: content change → webhook → incremental update (not full rebuild)
- Batch vs real-time embedding costs
- FakeEmbeddings for testing (deterministic, no API keys needed)
- Performance: query latency targets, caching strategy

### 5. Content Management System (Weight: High)
**9.5 requires ALL of:**
- Google Sheets as CMS: why this choice, UX for non-technical staff
- Sheet structure: one sheet per category? columns? validation rules?
- Webhook integration: Google Apps Script → Cloud Function → re-index pipeline
- Schema validation: what happens when staff enters invalid data?
- Instant effect: how changes propagate to agent knowledge (latency target)
- Content categories: exhaustive list with examples (menus, hours, events, rules, promotions, regulations)
- Version control: how to track what changed, who changed it, rollback
- Multi-casino: separate sheets per casino? Template sheets?
- Guardrails: what content changes are allowed/blocked (e.g., can't remove all restaurants)
- Migration path: from Sheets to proper CMS if needed later
- Training: how to onboard a casino marketing manager

### 6. Per-Casino Deployment & Infrastructure (Weight: High)
**9.5 requires ALL of:**
- GCP project structure: single project with namespace isolation
- Firestore: separate database per casino (not just collections)
- Cloud Run: service configuration, autoscaling, min instances
- Terraform/IaC: module structure for duplicating casino infrastructure
- Feature flags: per-casino configuration (prompts, branding, rules)
- Environment variables and secrets management (Secret Manager)
- Cost model: per-casino monthly estimate (Cloud Run, Firestore, Telnyx, LLM API)
- DNS/routing: how requests route to correct casino context
- CI/CD: Cloud Build pipeline, deployment strategy
- Monitoring: per-casino health checks, alerting
- Onboarding: step-by-step process to add a new casino (< 1 day)
- Scaling: what changes at 5 casinos? 10? 50?

### 7. Security & Compliance (Weight: Critical)
**9.5 requires ALL of:**
- AI disclosure: CA SB 243 compliance, exact first-message disclosure text
- TCPA: opt-in mechanics, consent storage, audit trail
- Opt-out: STOP handling, graceful response, immediate cessation
- Pre-LLM deterministic guardrails: prompt injection, responsible gaming, BSA/AML, patron privacy, age verification
- Guardrail patterns: regex examples, language coverage (EN/ES)
- Data privacy: CCPA considerations, data retention, deletion rights
- Per-casino data isolation: no cross-casino data leakage
- API security: Telnyx webhook verification, API key management
- LLM safety: prompt injection defense, output validation, hallucination prevention
- Audit logging: what's logged, retention, format, accessibility
- Escalation: human handoff triggers, notification system
- Incident response: what happens when the agent says something wrong?

### 8. Observability & Evaluation (Weight: High)
**9.5 requires ALL of:**
- LangFuse integration: trace structure, span hierarchy, cost tracking
- Per-node metrics: latency, token usage, success/failure rates
- Conversation-level metrics: completion rate, data points collected, escalation rate
- Retrieval quality metrics: relevance scores, hit/miss rates
- Evaluation framework: what to evaluate, how often, automated vs manual
- A/B testing: how to test different prompts/agents/strategies
- Replay capability: re-run past conversations against new prompts
- Alerting: what triggers alerts, who gets notified
- Dashboard: key metrics for casino operators vs engineering team
- LangFuse vs alternatives: why LangFuse, cost, self-hosted option
- OpenTelemetry integration with LangGraph
- Testing strategy: unit tests, integration tests, eval tests with real scenarios

### 9. Conversation Design (Weight: Critical)
**9.5 requires ALL of:**
- Progressive profiling strategy: what data to collect, in what order, how to ask
- Persona design: "Seven Concierge" — voice, tone, style guidelines for SMS
- Whisper Track Planner: how it plans conversational beats, interface with speaking agents
- First message design: AI disclosure + CTA + personality, exact example
- Incentive mechanics: types of incentives, when to offer, how to track
- Contextual data extraction: examples for each domain (dining → kids, entertainment → dates, etc.)
- Reciprocity pattern: agent shares value first, then asks
- Human-like timing: delay calculation, variance, per-message-type
- Multi-turn conversation arcs: onboarding → rapport → preferences → offers → post-visit
- Escalation triggers: when AI should hand off to human
- Opt-out handling: graceful, potential incentive to understand why
- Language handling: English/Spanish, detection, switching mid-conversation
- Consent mechanics: how to get and track consent for data collection
- Edge cases: angry guest, confused guest, guest testing if it's AI, guest sharing sensitive info

### 10. Production Readiness (Weight: High)
**9.5 requires ALL of:**
- Error handling: circuit breaker for LLM calls, retry with backoff, fallback responses
- Scaling: Cloud Run autoscaling configuration, Firestore capacity
- Cold start mitigation: min instances, warm-up, pre-loaded embeddings
- Cost analysis: detailed per-component costs, monthly projections, cost optimization strategies
- Health endpoint: what it checks, expected response
- Operational runbook: common issues, troubleshooting steps, escalation path
- Message windowing: strategy for conversations exceeding Firestore 1MB limit
- Graceful degradation: what happens when Gemini API is down? Telnyx is down? Firestore is slow?
- Rate limiting: per-guest, per-casino, global
- Logging: structured JSON logging, log levels, PII redaction
- Backup: Firestore backup strategy, conversation export
- SLA targets: response time, uptime, delivery rate
- Load testing: approach, tools, expected throughput
- Deployment: zero-downtime deployment strategy, rollback procedure
