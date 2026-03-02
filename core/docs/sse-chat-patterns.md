# SSE Chat Patterns — Full Stack

Origin: Hey Seven 2026-02-15 — FastAPI SSE + browser EventSource, tested through 5 streaming breakages across 12 review rounds.

**Trigger words**: SSE, streaming chat, chat UI, real-time, EventSource, server-sent events

---

## FastAPI SSE Endpoint

### Dependencies
```
sse-starlette>=2.0
```

### Endpoint Pattern

```python
from sse_starlette.sse import EventSourceResponse

@app.post("/chat")
async def chat_endpoint(request: Request, body: ChatRequest):
    if not app.state.agent:
        return JSONResponse(status_code=503, content={"error": "Agent not ready"})

    async def event_generator():
        try:
            async with asyncio.timeout(settings.SSE_TIMEOUT_SECONDS):
                async for event in stream_source:
                    if await request.is_disconnected():
                        return
                    yield event
        except asyncio.TimeoutError:
            yield {"event": "error", "data": json.dumps({"error": "timeout"})}
        except Exception as e:
            yield {"event": "error", "data": json.dumps({"error": str(e)})}
        finally:
            yield {"event": "done", "data": "{}"}

    return EventSourceResponse(event_generator())
```

### SSE Event Types

| Event | Purpose | Data Shape |
|-------|---------|------------|
| `metadata` | Session info, thread_id | `{"thread_id": "..."}` |
| `graph_node` | Node lifecycle (for trace panel) | `{"node": "router", "status": "start/complete", "duration_ms": 42}` |
| `token` | Incremental text streaming | `{"content": "word "}` |
| `sources` | RAG source documents | `{"sources": [{"title": "...", "score": 0.85}]}` |
| `replace` | Full response (non-streaming nodes) | `{"content": "Full response text"}` |
| `error` | Error event | `{"error": "timeout"}` |
| `done` | Stream complete | `{}` |

## Frontend SSE Consumption

### Using ReadableStream (POST endpoints)

`EventSource` is GET-only. For POST endpoints, use `fetch()` with `ReadableStream`:

```javascript
const response = await fetch('/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message, thread_id })
});

const reader = response.body.getReader();
const decoder = new TextDecoder();
let buffer = '';

while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += decoder.decode(value, { stream: true });

    const lines = buffer.split('\n');
    buffer = lines.pop();  // Keep partial line in buffer

    let currentEvent = '';
    for (const line of lines) {
        if (line.startsWith('event: ')) currentEvent = line.substring(7).trim();
        if (line.startsWith('data: ')) {
            const data = JSON.parse(line.substring(6));
            handleSSEEvent(currentEvent, data);
        }
    }
}
```

### Event Handler

```javascript
function handleSSEEvent(event, data) {
    switch (event) {
        case 'token':
            appendToMessage(data.content);  // Incremental append
            break;
        case 'replace':
            replaceMessage(data.content);   // Full replacement
            break;
        case 'graph_node':
            updateTracePanel(data);          // Node lifecycle
            break;
        case 'sources':
            showSources(data.sources);       // RAG sources
            break;
        case 'error':
            showError(data.error);           // Error handling
            break;
        case 'done':
            finalizeMessage();               // Cleanup
            break;
    }
}
```

## Graph Trace Panel

Real-time visualization of LangGraph node execution:

```javascript
const GRAPH_NODES = [
    { id: 'router', name: 'Router', section: 'pipeline' },
    { id: 'retrieve', name: 'Retrieve', section: 'pipeline' },
    { id: 'generate', name: 'Generate', section: 'pipeline' },
    { id: 'validate', name: 'Validate', section: 'pipeline' },
    { id: 'respond', name: 'Respond', section: 'pipeline' },
    { id: 'greeting', name: 'Greeting', section: 'branch' },
    { id: 'off_topic', name: 'Off Topic', section: 'branch' },
    { id: 'fallback', name: 'Fallback', section: 'branch' },
];

// Visual states: pending (gray), active (pulsing gold), complete (green + timing), skipped (dimmed)
function updateGraphNode(data) {
    if (data.status === 'start') {
        el.className = 'graph-node active';  // Pulsing animation
    } else if (data.status === 'complete') {
        el.className = 'graph-node complete';
        el.querySelector('.duration').textContent = data.duration_ms + 'ms';
        // Show node-specific metadata (router: query_type, retrieve: doc_count, validate: PASS/FAIL)
    }
}
```

## Error Recovery

### Timeout Handling
- `asyncio.timeout()` on server side prevents hung connections
- Client-side: if no events for 30s, show reconnection UI
- Always emit `done` event in `finally` block

### Client Disconnect
- Check `request.is_disconnected()` before each yield
- Log `CancelledError` at INFO level (not ERROR — client disconnect is normal)

### Mid-Stream Failure
- Emit `error` event with structured JSON payload
- Frontend shows error inline in chat bubble (not modal)
- Offer "Retry" button that resends the same message

### Streaming-Before-Validation Race Condition
- In regulated environments, validation must complete before tokens stream
- Solution: configurable `STREAM_MODE` (stream tokens during generation vs wait for validation)
- Default to validation-first for safety-critical domains

## Branded Chat UI Patterns

### CSS Custom Properties for Brand Tokens
```css
:root {
    --brand-primary: #c5a467;      /* Gold accent */
    --brand-dark: #2c2926;         /* Dark brown */
    --brand-cream: #f5f3ef;        /* Background */
    --font-heading: 'Playfair Display', Georgia, serif;
    --font-body: 'Inter', system-ui, sans-serif;
}
```

### Thinking Indicators
- Pulsing dot animation during graph execution
- Node name displayed: "Routing...", "Retrieving...", "Generating..."
- Duration shown after completion

### Mobile Responsive
- Graph trace panel becomes bottom sheet on mobile (< 1024px)
- Chat messages use full width
- Input area fixed to bottom with auto-grow textarea

## Middleware Checklist (MANDATORY)

Before deploying any SSE endpoint:
- [ ] ALL middleware classes are pure ASGI (NOT BaseHTTPMiddleware)
- [ ] Security headers use list append, not dict roundtrip
- [ ] Rate limiter is ASGI middleware, not HTTP middleware
- [ ] `asyncio.timeout()` on SSE generator
- [ ] `request.is_disconnected()` check in generator loop
- [ ] `CancelledError` logged at INFO, not ERROR
- [ ] `done` event emitted in `finally` block
- [ ] Error events are structured JSON, not plain text
- [ ] Agent None check before streaming (return 503)
