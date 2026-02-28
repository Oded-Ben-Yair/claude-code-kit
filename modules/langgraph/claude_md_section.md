## LangGraph Production Patterns

Always-loaded rules: `langgraph-patterns.md` -- StateGraph, validation loops, structured output routing, specialist DRY extraction, state reducers, feature flags.

### On-Demand Docs (loaded by trigger words)

| Trigger | Doc File |
|---------|----------|
| validation, fail-closed, degraded, crisis, compliance gate | `langgraph-safety.md` |
| circuit breaker, redis, TTL, rate limit, SSE, backpressure, async lock | `langgraph-scalability.md` |
| conftest, singleton, mock LLM, E2E test, behavioral scenario | `langgraph-testing.md` |
| multi-tenant, sentiment, sarcasm, slang, extraction, guardrail wiring | `langgraph-domain.md` |
