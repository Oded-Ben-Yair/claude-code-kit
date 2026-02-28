## RAG Production Patterns

Always-loaded rules: `rag-production.md`

Key patterns:
- **Per-item chunking** for structured data (menus, hours, product listings) -- never use text splitters on JSON
- **RRF reranking** (Reciprocal Rank Fusion) for multi-strategy retrieval
- **SHA-256 content hashing** for idempotent ingestion (no duplicate chunks)
- **Version-stamp purging** to remove stale chunks after content edits
- **Tenant ID metadata isolation** to prevent cross-tenant leakage in shared vector stores
- **Embedding model version pinning** to prevent vector space drift
- **FakeEmbeddings** (SHA-384 hash-based) for testing without API keys

### Key Anti-Patterns
- No relevance score threshold = LLM context pollution
- `json.dumps(data)` as embedding input = poor retrieval
- `text-embedding-latest` = version drift
- Delete-then-create ingestion = downtime window
- Same collection without tenant filter = cross-tenant data leakage
