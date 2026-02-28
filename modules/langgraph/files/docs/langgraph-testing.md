# LangGraph Testing Patterns

On-demand doc. Load when: test, conftest, singleton, mock LLM, E2E test, integration test, behavioral scenario, env var isolation

Origin: Production LLM agent — testing patterns across 63 review rounds.

## Conftest Singleton Cleanup (MANDATORY for async test suites)

Create `autouse=True, scope='function'` fixture clearing ALL singleton caches between tests: LLM cache, circuit breaker, retriever, settings, embeddings, memory store, config cache.

```python
@pytest.fixture(autouse=True, scope="function")
def _clear_singletons():
    yield
    for cache_fn in [_get_llm, _get_circuit_breaker, _get_retriever, get_settings]:
        try:
            cache_fn.cache_clear()  # lru_cache
        except AttributeError:
            pass
    # Also clear TTLCache instances and module-level dicts
```

Singleton leakage is the #1 cause of flaky async tests. Circuit breaker state, stale LLM clients, and cached settings leak across tests.

Origin: Production LLM agent — review round 20. 13 singleton caches identified. Without cleanup, test order determined pass/fail.

## E2E Integration Test Through Full Pipeline (MANDATORY for 5+ nodes)

Write at least one integration test that sends a query through the FULL graph pipeline (all nodes) with mocked LLMs, verifying lifecycle events for every node start/complete.

```python
async def test_full_pipeline_lifecycle():
    result = await graph.chat("test query", config=test_config)
    events = collect_lifecycle_events(result)
    assert "router:start" in events
    assert "generate:complete" in events
    assert "validate:complete" in events
    # Verify WIRING, not just individual node logic
```

Unit tests verify nodes work individually. E2E tests verify WIRING works. Specialist dispatch bugs are invisible to unit tests.

Origin: Production LLM agent — review rounds 9-20. Flagged as #1 testing gap across 4 consecutive review rounds.

## Environment Variable Isolation in Test Suites (MANDATORY)

`os.environ.setdefault()` at module import time does NOT work reliably in test suites -- other tests may set the variable first, and setdefault is a no-op when the key exists.

```python
# BAD: Unreliable when run in full suite
os.environ.setdefault("API_KEY", "")  # No-op if another test set it

# GOOD: Per-test isolation via monkeypatch fixture
@pytest.fixture(autouse=True)
def _disable_api_key_auth(monkeypatch):
    monkeypatch.setenv("API_KEY", "")
    try:
        from src.config import get_settings
        get_settings.cache_clear()  # Settings cache must also be cleared
    except (ImportError, AttributeError):
        pass
    yield
```

Always clear cached settings after environment variable changes -- `@lru_cache` settings won't see the new value.

Origin: Production LLM agent — phase 5. 9 SSE E2E tests passed in isolation, failed in full suite.

## Mock vs Live Behavioral Evaluation Gap (MANDATORY)

Mock-based behavioral evaluation ALWAYS overestimates agent quality. Mock LLMs return template responses that score well on format but don't reflect real LLM behavior (tone, verbosity, fallback patterns).

- **Mock score**: 7.3/10 (measured code wiring, not agent behavior)
- **Live score**: 4.1/10 (real LLM through full pipeline)
- **Gap**: 3.2 points (43% overestimate)

Always use live agent evaluation with real LLM for behavioral scoring. Mock-based tests verify CODE correctness (routing, state, wiring). Live tests verify AGENT quality (tone, empathy, engagement).

Origin: Production LLM agent — review round 72. 74 scenarios through real LLM, 3-model judge panel, ICC 0.797.

## Behavioral Scenario Forbidden Keywords vs Mock LLMs (MANDATORY)

Adversarial behavioral test scenarios (YAML files with `forbidden_keywords`) are for LIVE agent evaluation, not mock-based unit tests. Mock LLMs don't understand sentiment or emotional context.

```yaml
# BAD: Mock LLM will include "happy to help" regardless of sarcasm detection
forbidden_keywords: ["happy to help", "excited"]

# GOOD: Only use expected_keywords with mock LLMs
expected_keywords: ["sorry", "help"]
```

If the test framework uses mock LLMs, remove `forbidden_keywords` from scenario YAML files. Reserve them for live agent evaluation or LLM-as-judge evaluation frameworks.

Origin: Production LLM agent — review round 70. 20 behavioral scenarios with forbidden_keywords broke mock-based tests.

## Research Agent Output Contract: Use code-worker for File-Writing Tasks (MANDATORY)

`research-specialist` and `realtime-specialist` agents do NOT have Write/Edit tools. If research output must be written to a file, either:

1. Use `code-worker` subagent type (has Write tool) with research instructions
2. Use `general-purpose` subagent type (has all tools)
3. Accept that the parent must write the file from the agent's returned content

Never assume a research agent can write its own output file.

Origin: Production LLM agent — review round 21. All 4 research agents completed research but couldn't write files.
