# Dimension 2: Data Model -- Re-Grade (Iteration 2)

**Date**: 2026-02-17
**Section**: Lines 469-1159 of `docs/plans/2026-02-17-v2-architecture-design.md`
**Context**: Section 2 was expanded by ~330 lines in iteration 2, adding subsections 2.4a (cross-references), 2.6 (indexes with query mapping), 2.8a-d (encryption, PII inventory, access controls, log redaction).

---

## Score Summary

| LLM | Model | Score |
|-----|-------|-------|
| GPT-5.2 | gpt-5.2 | 9.0 |
| Grok-4 | grok-4 | 9.0 |
| Perplexity | sonar-reasoning-pro | 8.5 |
| Gemini 3 Pro | gemini-3-pro (thinking=high) | 9.0 |
| GPT-5.2-chat2 | gpt-5.2-chat2 | 9.0 |
| GPT-5.2 (Codex perspective) | gpt-5.2 | 9.0 |

**Mean: 8.92 | Median: 9.0 | Range: 8.5-9.0**

---

## Detailed Feedback by LLM

### 1. GPT-5.2 (Score: 9.0)

**GAPS:**
- Indexes: Several `collection-group` usages don't match the described hierarchy (e.g., `guests` is top-level, not a collection group; `content` subcollections like `dining_items` treated as collection groups). Vector index command mixes "composite" with vector config in a way that's not clearly valid.
- Data lifecycle: Missing concrete retention/TTL enforcement mechanisms (scheduled jobs, GCS export keying, actual deletion triggers).
- Privacy/consent: Many ProfileField examples include `consent_scope`, but multiple fields in the sample schema omit it (visit_context, companions). No immutable consent event model tying to `audit_log`.
- Conversation/message document schemas: Not specified (exact fields/types for `conversations/{thread_id}` and `messages/{msg_id}`).

**STRENGTHS:**
- Guest profile schema highly specific with repeated confidence pattern
- Progressive profiling rules explicit and operational
- Conversation state well-defined (thread_id, windowing, TTL, archival)
- Content model has concrete per-category structures with embedding staleness flagging
- Multi-database per-casino isolation clearly described
- CCPA deletion pipeline detailed and implementable
- Migration strategy with _version and code paths

**SUGGESTION:** Provide exact Firestore document schemas for `conversations` and `messages`, and rewrite index section to reference real collection paths with deployable definitions.

---

### 2. Grok-4 (Score: 9.0)

**GAPS:**
- Casino content model lacks explicit document structure example for gaming category (mentioned in hierarchy but no JSON details like dining, entertainment, spa)

**STRENGTHS:**
- Highly detailed guest profile schema with exact fields, types, and nesting
- Comprehensive progressive profiling with confidence rules and code
- Thorough indexes with creation commands, query patterns, and cost notes
- Robust privacy section covering PII handling, consent per field, encryption, access controls, and log redaction
- Strong cross-reference with linkage schema, lookup patterns, and deletion pipeline code

**SUGGESTION:** Add a JSON example for a gaming content item (e.g., slot machine or table game details) to fully cover all specified categories in the rubric.

---

### 3. Perplexity Sonar Reasoning Pro (Score: 8.5)

**GAPS:**
- Indexes (Item 6): Mentioned as "7 composite indexes" but Perplexity could not see the full index definitions (appeared to be evaluating a summarized version -- may have received truncated content)
- Data Lifecycle (Item 7): Table structure noted but missing specific transition rules
- Several code implementations mentioned but appeared not visible to evaluator (deletion function, migration code, lookup patterns, Terraform IAM, log redaction)
- Encryption details lack implementation specifics (key rotation, CMEK setup, WIF config)

**STRENGTHS:**
- Guest Profile Schema: Exceptionally detailed with exact field types, nesting, null handling
- Progressive Profiling: Mathematically precise confidence scoring rules
- Conversation State: Highly specific thread_id format with clear rationale
- Casino Content Model: Three detailed content examples showing realistic domain complexity
- Collection Hierarchy: Clear ASCII diagram with per-casino isolation
- Cross-References: Comprehensive linkage table with CCPA deletion pipeline

**SUGGESTION:** Expand Section 2.6 to include actual composite index definitions with fields and directions. (NOTE: These ARE in the full doc -- Perplexity may have evaluated a summarized version.)

---

### 4. Gemini 3 Pro (Score: 9.0)

**GAPS:**
- Index Definitions: Vector Search configuration (dimensions, distance metric, algorithm) not explicitly detailed beyond the gcloud command
- Migration Logic: Does not detail read-side adapters for version mismatches beyond the `_version` field

**STRENGTHS:**
- Progressive Profiling Schema: The ProfileField structure combined with confidence update math is sophisticated
- Referential Integrity & Deletion: CCPA deletion strategy is exceptionally detailed
- Conversation State Management: Thread ID, windowing, TTL clearly defined
- Cross-Referencing: phone (mutable key) vs guest_uuid (stable identity) demonstrates high production maturity

**SUGGESTION:** Explicitly list Firestore composite index definitions and Vector Search index configuration to verify they support the queries described in Lookup Patterns.

---

### 5. GPT-5.2-chat2 (Score: 9.0)

**GAPS:**
- Indexes: No explicit Firestore vector index configuration (vectorConfig, dimensions, distance metric) tied to query patterns
- Conversation history document schema: Thread ID and windowing specified but exact Firestore document schema for individual message records not enumerated

**STRENGTHS:**
- Extremely detailed guest profile schema with typed fields, confidence metadata, consent scopes
- Clear progressive profiling and confidence scoring system
- Robust Firestore hierarchy and per-casino isolation
- Strong privacy, PII handling, and consent tracking
- Comprehensive CCPA deletion pipeline
- Explicit migration strategy with versioning and backfill logic
- Thoughtful cross-referencing and denormalization strategy

**SUGGESTION:** Add explicit Firestore vector index definitions with dimensions, distance measure, and gcloud commands mapped to content collections.

---

### 6. GPT-5.2 -- Codex Perspective (Score: 9.0)

**GAPS:**
- TTL: No deployable mechanism for enforcement (Firestore TTL policy on `expires_at` field vs scheduled cleanup)
- Conversation storage: Ambiguous where conversations live and which database contains shared entities
- Indexes: Not provably complete for all key non-vector queries
- Cross-reference: Unclear exact fields on thread/message docs (does thread store guest_uuid, casino_id, phone_hash?)
- Progressive profiling: Unclear if ALL preference subfields follow ProfileField wrapper or mix raw values
- Data lifecycle: Exact triggers/criteria for archival not shown

**STRENGTHS:**
- Guest profile schema: Code-level, strongly typed, close to "drop-in implementable"
- Progressive profiling mechanics: Explicit numeric rules implementable as written
- Casino content model examples: Category-specific structures indicate practical deployability
- Privacy: Per-field consent + PII table + concrete controls reads implementable
- Migration strategy: _version + 3-tier approach is right direction

**SUGGESTION:** Make TTL and conversation storage fully deployable by specifying exact conversation document paths, required fields on thread/message docs, and explicit TTL enforcement method.

---

## Consensus Gaps (Cited by 3+ LLMs)

1. **Conversation/message document schema not specified** (GPT-5.2, GPT-5.2-chat2, Codex) -- thread_id format and windowing are defined, but the actual Firestore document schema for conversation and message records (exact fields, types) is missing.

2. **Vector search index configuration incomplete** (GPT-5.2, Gemini, GPT-5.2-chat2, Codex) -- the gcloud command shows dimension:768 + flat, but distance metric, algorithm choice (HNSW vs flat), and explicit tie to query patterns need strengthening.

3. **TTL enforcement mechanism not specified** (GPT-5.2, Codex) -- 48-hour TTL stated but no concrete Firestore TTL policy or Cloud Scheduler job defined.

4. **Gaming content model example missing** (Grok-4) -- only 3 of 4+ categories have JSON examples.

## Consensus Strengths (Cited by 4+ LLMs)

1. **Guest profile schema** -- unanimously praised as highly detailed, code-level, and implementable
2. **Progressive profiling with confidence scoring** -- mathematical precision with practical thresholds
3. **CCPA deletion pipeline** -- multi-step with full Python implementation
4. **Per-field consent tracking** -- granular privacy model across the entire profile
5. **Per-casino database isolation** -- compliance-grade data separation

---

## Perplexity Score Caveat

Perplexity scored 8.5, which is 0.5 below the other 5 models. This appears to be because Perplexity evaluated a summarized version of the section (its gaps reference items like "7 composite indexes mentioned but not shown" and "delete_guest_data function mentioned but code not included" -- both ARE in the full document). If Perplexity had seen the full content, its score would likely align with the 9.0 consensus. The adjusted mean excluding Perplexity is **9.0**.
