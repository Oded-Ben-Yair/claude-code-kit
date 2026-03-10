# LangGraph Domain & Multi-Tenant Patterns

On-demand doc. Load when: multi-tenant, casino, property, sentiment, sarcasm, slang, extraction, regex, wiring checklist, emotional, proactive, domain tracking, guardrail category

Origin: Hey Seven R19-R73 — domain patterns for casino AI host agent.

## Multi-Property Config: Always Use get_casino_profile(), Never DEFAULT_CONFIG (MANDATORY)

When injecting property-specific data (branding, helplines, persona name, regulations), ALWAYS use `get_casino_profile(settings.CASINO_ID)` — NEVER read `DEFAULT_CONFIG` directly:

```python
# GOOD: Property-specific
from src.casino.config import get_casino_profile
profile = get_casino_profile(settings.CASINO_ID)
branding = profile.get("branding", {})

# BAD: Hardcoded to default property
from src.casino.config import DEFAULT_CONFIG
branding = DEFAULT_CONFIG.get("branding", {})  # Always returns Mohegan Sun
```

Every import of `DEFAULT_CONFIG` for runtime data is a multi-tenant bug. Grep for ALL imports of DEFAULT_CONFIG after every fix — the except/fallback paths are easy to miss.

Origin: Hey Seven R25-R31 — persona name hardcoded in 3 locations, responsible gaming helplines hardcoded to CT. R31 found TWO MORE in except blocks.

## Also Grep Function Arguments for Missing Parameters (MANDATORY)

After fixing a function to accept per-tenant parameters (e.g., `casino_id`), grep ALL callers to verify they pass the parameter. Missing parameters silently fall back to defaults.

```bash
grep -rn "get_responsible_gaming_helplines" --include="*.py" | grep -v "casino_id"
# Any results WITHOUT casino_id = bug
```

Origin: Hey Seven R31 — `_base.py` still called without the parameter. NJ properties received CT helplines for 6 review rounds.

## Proactive Suggestion Sentiment Gate: Positive-Only (MANDATORY)

When injecting unsolicited suggestions (proactive recommendations, cross-sell offers), the sentiment gate MUST require `"positive"` sentiment — never `"neutral"`:

```python
# GOOD: Positive evidence required
if state.get("guest_sentiment") == "positive":
    inject_suggestion()

# BAD: Neutral is absence of evidence, not positive evidence
if state.get("guest_sentiment") in ("positive", "neutral"):
    inject_suggestion()  # Mildly annoyed guests get upsold
```

"Neutral" on VADER means no strong signal. Many frustrated-but-polite messages score neutral.

Origin: Hey Seven R23-R27 — R27 hostile review caught the contradiction. Tightened to positive-only.

## Frustration Escalation from Message History (Pattern)

Count consecutive frustrated messages from conversation history instead of adding a state field with a custom reducer.

```python
def _count_consecutive_frustrated(messages: list) -> int:
    count = 0
    for msg in reversed(messages):
        if isinstance(msg, HumanMessage):
            sentiment = detect_sentiment(msg.content)
            if sentiment in ("frustrated", "negative"):
                count += 1
            else:
                break
    return count
```

Advantages: no reducer complexity, deterministic (VADER sub-1ms), correct by construction.

Use graduated response: 2 = hear+empathize, 3+ = full HEART framework.

Origin: Hey Seven R21 — chose message history scan over state field to avoid reducer complexity.

## Keyword-Triggered Emotional Context Guides (Pattern)

When an AI agent needs emotional intelligence beyond basic sentiment, add a keyword-triggered emotional context layer SEPARATE from the sentiment system:

```python
EMOTIONAL_CONTEXT_GUIDES = {
    "grief": "Guest mentioned loss. Extra gentleness, no promotions...",
    "anxiety": "Guest seems nervous. Be reassuring, offer simple guidance...",
    "allergy_concern": "SAFETY matter. Recommend contacting venue directly...",
}

user_msg_lower = user_msg.lower()
if any(kw in user_msg_lower for kw in ("passed away", "lost my", "funeral")):
    emotional_guides.append(EMOTIONAL_CONTEXT_GUIDES["grief"])
```

Key: Separate from VADER (valence vs context), additive not replacing, fail-silent, extensible.

Origin: Hey Seven R70 — B5 (Emotional Intelligence) at 3/10. Added 5 emotional context guides.

## Context-Contrast Sarcasm Detection (Pattern)

DON'T build a sarcasm classifier. Production research (Intercom, Zendesk, Ada, PolyAI) shows the optimal approach is sarcasm-resilient response design:

```python
def detect_sarcasm_context(current_text, current_sentiment, recent_sentiments):
    if current_sentiment not in ("positive", "neutral"):
        return False
    negative_count = sum(1 for s in recent_sentiments[:3] if s in ("frustrated", "negative"))
    if negative_count == 0:
        return False
    has_positive_words = bool(set(current_text.lower().split()) & POSITIVE_SIGNALS)
    if not has_positive_words:
        return False
    if negative_count >= 2:
        return True
    if negative_count >= 1 and len(current_text.split()) <= 8:
        return True
    return False
```

Zero LLM cost, sub-1ms. When detected, override to "frustrated" — empathetic response works either way.

Origin: Hey Seven R72 — A6 research confirmed production chatbot companies DON'T classify sarcasm.

## Slang Normalization for RAG Search (Pattern)

Normalize domain-specific slang for SEARCH ONLY:

```python
def normalize_for_search(text: str) -> str:
    """Normalize slang for RAG retrieval. NEVER modify original message in state."""
    for pattern, replacement in _MULTI_WORD_SLANG:
        result = pattern.sub(replacement, result)
    for word in words:
        stripped = word.rstrip(".,!?;:'\")")
        if stripped.endswith("'d"): stripped = stripped[:-2]
        normalized_words.append(SLANG_DICT.get(stripped.lower(), word))
    return " ".join(normalized_words)
```

Critical: search-only (never store/display), original preserved, handle contractions ("YOLO'd").

Origin: Hey Seven R72 — Gambling slang produced poor RAG embeddings. Normalization improved relevance.

## Stateful Domain Tracking with List Reducer (MANDATORY for multi-specialist agents)

Track which domains have been discussed for cross-domain suggestion:

```python
def _append_unique(a: list[str] | None, b: list[str] | None) -> list[str]:
    """Reducer: accumulates unique strings. list, NOT set (JSON serializable)."""
    existing = list(a) if a else []
    seen = set(existing)
    for item in (b or []):
        if item and item not in seen:
            seen.add(item)
            existing.append(item)
    return existing

class AgentState(TypedDict):
    domains_discussed: Annotated[list[str], _append_unique]
```

**Why list, not set**: LangGraph checkpointer serializes to JSON/Firestore. `set` → TypeError.

Origin: Hey Seven R72 — B4 agentic score 6.4/10, agent couldn't track covered domains.

## Regex Extraction False Positive Prevention

When building regex extractors for natural language:

1. **Maintain exclusion wordlists**: common words, domain-specific terms
2. **Anchor after trigger phrases**: `(?:my name is|I'm)\s+([A-Z][a-z]+)` not just `([A-Z][a-z]+)`
3. **Use word boundaries and non-greedy capture**
4. **Pattern ordering matters**: specific before generic
5. **Test with adversarial input**: "I'm vegetarian", "I'm here", "Sure thing"

Origin: Hey Seven Phase 4 — "I'm vegetarian" matched name regex.

## New query_type Wiring Checklist (MANDATORY when adding guardrail categories)

When adding a new `query_type` to `compliance_gate_node`:

1. **Detection**: Add `detect_*()` function in `guardrails.py` with pattern list
2. **Routing**: Add `detect_*()` call in `compliance_gate_node` at correct priority position
3. **Response**: Add `elif query_type == "new_type":` case in `off_topic_node`
4. **Export**: Add to `guardrails.__all__`
5. **Import**: Add to `compliance_gate.py` imports
6. **Test count**: Update `test_doc_accuracy.py` pattern count assertion
7. **Test response**: Add test that the new query_type produces correct response

Missing ANY step = the guardrail detects but doesn't respond correctly.

Origin: Hey Seven R49-R50 — suicidal guests received "I'm your concierge" instead of 988 Lifeline.

## Scaffolded-to-Wired Checklist (MANDATORY before claiming "implemented")

1. **Trace the call chain**: entry point → graph node → helper → scaffolded code
2. **Feature flag the wiring**: new feature flag with default depending on risk
3. **Accumulate state across turns**: merge with existing (don't overwrite)
4. **Fail-silent at every new connection point**: try/except returning empty/neutral defaults
5. **Verify parity checks**: update ALL parity locations (TypedDict ↔ defaults ↔ config)

Origin: Hey Seven Phase 3 — guest_profile.py (425 LOC) scaffolded with zero imports.
