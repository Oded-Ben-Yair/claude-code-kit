# LangGraph Scalability & Distributed Patterns

On-demand doc. Load when: circuit breaker, redis, TTL, rate limit, streaming, SSE, backpressure, lock, async lock, semaphore, scalability

Origin: Hey Seven R20-R47 — scalability patterns hardened across 27 review rounds + 4-model external review.

## Circuit Breaker for LLM Calls

```python
class CircuitBreaker:
    # States: closed (normal) -> open (blocking) -> half_open (probe)
    # Use asyncio.Lock for coroutine safety, @lru_cache(maxsize=1) for singleton
    async def call(self, func, *args):
        if self._state == "open" and not self._cooldown_expired():
            return SAFE_FALLBACK  # Fail open, not crash
```

- Check at start of generate_node before building prompts
- Fail OPEN with safe fallback (not crash) — same principle as ML gates

## TTL-Cached LLM Singletons (MANDATORY for cloud credential rotation)

Replace `@lru_cache(maxsize=1)` with `cachetools.TTLCache(maxsize=1, ttl=3600)` for LLM client singletons when using GCP Workload Identity, Azure MSI, or any rotating credential provider.

```python
from cachetools import TTLCache
_llm_cache = TTLCache(maxsize=1, ttl=3600)
_llm_lock = asyncio.Lock()

async def _get_llm():
    async with _llm_lock:
        if "llm" not in _llm_cache:
            _llm_cache["llm"] = ChatVertexAI(...)
        return _llm_cache["llm"]
```

`@lru_cache` never expires — credential rotation requires process restart. TTLCache gives 1-hour refresh window.

Origin: Hey Seven R20 — GCP Workload Identity credentials rotate, requiring periodic LLM client recreation.

## NEVER asyncio.to_thread() for Redis in Async LangGraph Apps (MANDATORY)

`asyncio.to_thread()` spawns OS threads from the default `ThreadPoolExecutor`. Cloud Run instances have ~8-10 threads. Under 50 concurrent requests, each Redis call via `to_thread()` causes thread starvation.

```python
# BAD: Exhausts thread pool under load
await asyncio.to_thread(self._redis_client.setex, key, ttl, value)

# GOOD: Native async, zero thread overhead
self._async_redis = redis.asyncio.Redis.from_url(url)
await self._async_redis.setex(key, ttl, value)

# GOOD for rate limiting: Atomic Lua script (1 round-trip instead of 4-5)
RATE_LIMIT_SCRIPT = """
local key = KEYS[1]
local now = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local max_tokens = tonumber(ARGV[3])
redis.call('ZREMRANGEBYSCORE', key, '-inf', now - window)
local count = redis.call('ZCARD', key)
if count < max_tokens then
    redis.call('ZADD', key, now, ARGV[4])
    redis.call('EXPIRE', key, window)
    return 1
end
return 0
"""
```

Origin: Hey Seven R47 — All 4 external models flagged `to_thread()` for Redis as CRITICAL.

## Never Hold Async Lock Across I/O (MANDATORY)

```python
# BAD: Redis I/O inside lock = head-of-line blocking
async with self._lock:
    await self._sync_from_backend()  # Redis round-trip while locked

# GOOD: I/O outside lock, fast mutation inside
remote_state = await self._sync_from_backend()  # No lock
async with self._lock:
    self._apply_remote_state(remote_state)  # Fast dict mutation only
```

Origin: Hey Seven R47 — R46 moved _sync_from_backend inside lock. R47 GPT-5.2 flagged as CRITICAL: 100ms Redis stall blocks all 50 concurrent callers.

## SSE Streaming with astream_events v2

```python
async for event in graph.astream_events(initial_state, config=config, version="v2"):
    kind = event.get("event")
    node = event.get("metadata", {}).get("langgraph_node", "")
    if kind == "on_chat_model_stream" and node == NODE_GENERATE:
        chunk = event.get("data", {}).get("chunk")
        if isinstance(chunk, AIMessageChunk) and chunk.content:
            yield {"event": "token", "data": chunk.content}
```

- Filter by `langgraph_node` metadata to isolate specific node outputs
- Track `on_chain_start`/`on_chain_end` for observability (duration_ms per node)
- Use `version="v2"` — v1 has different event structure

## Message Windowing

Limit conversation history to prevent unbounded growth:
```python
MAX_MESSAGES = 40
if len(state["messages"]) > MAX_MESSAGES:
    state["messages"] = state["messages"][-MAX_MESSAGES:]
```

## HITL Interrupt for Regulated Environments

```python
interrupt_before = [NODE_GENERATE] if settings.ENABLE_HITL_INTERRUPT else None
compiled = graph.compile(checkpointer=checkpointer, interrupt_before=interrupt_before)
```

Configurable via environment variable — clean on/off toggle without code changes.

## Reducer Must Support Explicit Deletion (MANDATORY for accumulated state)

```python
# BAD: Filters None, making fields "sticky" — cannot unset
def _merge_dicts(existing, new):
    merged = dict(existing or {})
    merged.update({k: v for k, v in (new or {}).items() if v is not None})
    return merged

# GOOD: Tombstone pattern allows explicit deletion
_UNSET = "__UNSET__"

def _merge_dicts(existing, new):
    merged = dict(existing or {})
    for k, v in (new or {}).items():
        if v == _UNSET:
            merged.pop(k, None)  # Explicit deletion
        elif v is not None and v != "":
            merged[k] = v
    return merged
```

Origin: Hey Seven R47 — 3/4 external models flagged _merge_dicts sticky state as CRITICAL.
