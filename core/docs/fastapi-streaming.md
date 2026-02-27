# FastAPI SSE/Streaming Rules

On-demand: Load when working with SSE, streaming, FastAPI middleware, EventSource, real-time endpoints.

## Pure ASGI Middleware ONLY (MANDATORY)

`BaseHTTPMiddleware` breaks SSE streaming by buffering the response body. This is the #1 cause of broken streaming in FastAPI apps.

### ASGI Middleware Pattern

```python
class RequestLoggingMiddleware:
    def __init__(self, app: ASGIApp) -> None:
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] not in ("http", "websocket"):
            await self.app(scope, receive, send)
            return

        async def send_wrapper(message: Message) -> None:
            if message["type"] == "http.response.start":
                # Inject/modify headers via list append (NOT dict — dicts drop duplicates like Set-Cookie)
                message["headers"] = list(message.get("headers", [])) + extra_headers
            await send(message)

        await self.app(scope, receive, send_wrapper)
```

Standard middleware classes (all pure ASGI):
1. **RequestLogging** — X-Request-ID injection, structured JSON logging, X-Response-Time-Ms
2. **ErrorHandling** — Catches unhandled exceptions, returns structured 500 JSON
3. **SecurityHeaders** — CSP, HSTS, X-Frame-Options, X-Content-Type-Options, Referrer-Policy
4. **ApiKeyAuth** — `hmac.compare_digest()` for ALL secret comparisons (NEVER `==` or `!=`)
5. **RateLimit** — Sliding-window per IP, memory-bounded client tracking
6. **RequestBodyLimit** — Two-layer: Content-Length header + streaming byte counting

### SSE-Specific Rules

- `CancelledError` at INFO level, not ERROR — client disconnect is normal for SSE
- `asyncio.timeout()` on SSE streams to prevent hung connections
- Check `request.is_disconnected()` in SSE generators before each yield
- Security headers: use list append for `message["headers"]`, NOT dict roundtrip (dicts drop duplicate headers like Set-Cookie)
- Rate limiter must be ASGI, not HTTP middleware — HTTP middleware breaks SSE

### SSE Endpoint Pattern

```python
@app.post("/chat")
async def chat_endpoint(request: Request, body: ChatRequest):
    async def event_generator():
        async with asyncio.timeout(settings.SSE_TIMEOUT_SECONDS):
            async for event in stream_source:
                if await request.is_disconnected():
                    return
                yield event
    return EventSourceResponse(event_generator())
```

Origin: Hey Seven 2026-02-12 — BaseHTTPMiddleware silently broke all SSE endpoints. SecurityHeadersMiddleware dict-roundtrip dropped Set-Cookie headers. Rate limiter as HTTP middleware broke SSE. 5 separate streaming breakages across 12 review rounds.
