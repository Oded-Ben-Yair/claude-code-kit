# LangGraph Safety & Failure Modes

On-demand doc. Load when: validation, fail-closed, fail-open, degraded, crisis, safety, compliance gate

Origin: Production LLM agent — safety patterns across 65 review rounds.

## Degraded-Pass Validation Strategy

When an adversarial validator LLM fails (timeout, API error, parsing error), behavior should differ by attempt number:

```python
async def validate_node(state) -> dict:
    retry_count = state.get("retry_count", 0)
    try:
        result = await validator_llm.ainvoke(prompt)
        return {"validation_result": result.status}
    except Exception:
        if retry_count == 0:
            # First attempt: deterministic guardrails already passed.
            # Validator might be temporarily down. Serve unvalidated.
            return {"validation_result": "PASS"}  # Degraded-pass
        else:
            # Retry attempt: prior validation issues exist + validator failure.
            # Suspect content. Fail closed, route to safe fallback.
            return {"validation_result": "FAIL"}
```

- **First attempt + validator failure = PASS** (availability over safety -- deterministic guardrails already ran, validator might just be down)
- **Retry attempt + validator failure = FAIL** (safety over availability -- prior issue + validator failure = suspect content)
- Do NOT fail-closed on all validator errors -- that blocks ALL responses during LLM outages

Origin: Production LLM agent — review rounds 8-12. R8 changed to fail-closed. R11 unanimously flagged doc-code mismatch. R12 implemented degraded-pass. All 4 R20 models praised as "nuanced" and "production-grade."

## Fail-Closed for Safety-Critical Paths (MANDATORY for PII/injection/compliance)

PII redaction, injection detection, and compliance checks MUST fail CLOSED on any error -- return safe placeholder, block message, or return fallback. NEVER return original/pass-through on error in safety paths.

```python
# GOOD: Fail closed
except Exception:
    logger.error("PII redaction failed", exc_info=True)
    return "[PII_REDACTION_ERROR]"  # Safe placeholder

# BAD: Fail open (data leaks to LLM)
except Exception:
    return original_text  # PII passes through!
```

Note: This is OPPOSITE to the ML gate rule (fail OPEN for availability). Safety systems protect data; ML gates protect availability. Different failure modes for different risk profiles.

Origin: Production LLM agent — review round 20. PII redaction fail-open would send SSN/credit card to LLM on regex error. All 4 models flagged as CRITICAL.

## Fail-Closed with Degradation Mode for Security Classifiers (MANDATORY)

Fail-closed on individual failures is correct. But fail-closed on EVERY failure during sustained LLM outage = self-DoS that blocks ALL legitimate traffic.

```python
# BAD: Every failure rejects
except Exception:
    return InjectionResult(is_injection=True)  # ALL users blocked during outage

# GOOD: Degrade after consecutive failures
_consecutive_failures = 0
async def classify(text):
    global _consecutive_failures
    try:
        result = await classifier_llm.ainvoke(text)
        _consecutive_failures = 0
        return result
    except Exception:
        _consecutive_failures += 1
        if _consecutive_failures >= 3:
            logger.warning("Classifier degraded -- deterministic guardrails only")
            return InjectionResult(is_injection=False)  # Fall back to regex-only
        return InjectionResult(is_injection=True)  # Fail-closed for first 1-2
```

Origin: Production LLM agent — review round 47. All 4 external models flagged fail-closed semantic classifier as availability risk. LLM outage = total service outage for all users.

## Graduated Crisis Escalation for Regulated Domains (MANDATORY)

Binary crisis detection misses nuance between mild concern and immediate danger. Use graduated 4-level system:

```python
CrisisLevel = Literal["none", "concern", "urgent", "immediate"]

# Check highest severity first (short-circuit)
for pattern in _IMMEDIATE_PATTERNS:  # suicidal ideation, active danger
    if pattern.search(text): return "immediate"
for pattern in _URGENT_PATTERNS:     # financial desperation, self-harm, stranded
    if pattern.search(text): return "urgent"
for pattern in _CONCERN_PATTERNS:    # chasing losses, extended sessions, addiction language
    if pattern.search(text): return "concern"
return "none"
```

Response mapping:
- **immediate** -- Stop ALL conversation, provide crisis hotline resources
- **urgent** -- Direct resource provision + offer human connection
- **concern** -- Empathy + gentle helpline mention

Integration: Runs BEFORE binary detectors in compliance gate.

Origin: Production LLM agent — review round 72. Research identified 3 distinct crisis types requiring different response protocols.

## Crisis Context Persistence via Sticky State Field (MANDATORY for safety)

When a safety-critical state (crisis, self-harm) is detected, it must persist across conversation turns. Per-message detection misses follow-up messages that don't re-trigger regex patterns.

```python
# State field with _keep_truthy reducer -- once True, stays True for session
crisis_active: Annotated[bool, _keep_truthy]

# In compliance_gate: check crisis_active BEFORE per-message detection
if state.get("crisis_active", False):
    if not _is_normal_question(user_message):
        return {"query_type": "crisis", "router_confidence": 1.0}
```

Without this: "I don't want to live anymore" -> crisis hotline (correct) -> "Nobody can help me" -> "How can I help you?" (catastrophic).

Origin: Production LLM agent — review round 73. Crisis safety pass rate went from 1/3 to 3/3 judges after adding crisis_active persistence.

## Router Must Classify Emotional/Conversational Messages as Ambiguous, Not Off-Topic (MANDATORY)

Emotional messages ("Nobody can help me"), terse follow-ups ("Fine. Whatever."), and conversational reactions are NOT off-topic -- they're part of an ongoing user conversation.

Add explicit guidance to the router prompt:
```
- ambiguous: Unclear intent, emotional reactions, terse follow-ups, gratitude, complaints,
  or conversational messages that relate to the user's experience
- off_topic: Questions completely unrelated to the domain (politics, homework, coding)
```

Without this: most behavioral scenarios hit the generic fallback because the router classified emotional messages as off_topic.

Origin: Production LLM agent — review round 73. Router prompt update + ambiguous routing eliminated generic fallback from 15/20 scenarios.
