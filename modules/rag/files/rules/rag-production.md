# RAG Production Patterns

Origin: Production LLM agent — RRF reranking, idempotent ingestion, multi-tenant safety. 18 RAG findings across 12 review rounds.

## Per-Item Chunking for Structured Data (MANDATORY)

For structured data (menus, hours, addresses, product listings), chunk PER ITEM -- not with text splitters.

```python
# GOOD: Each item becomes its own chunk with rich metadata
for item in catalog_data["items"]:
    text = _format_item(item)  # Category-specific formatter
    metadata = {"category": "dining", "item_name": item["name"],
                "source": source_file, "tenant_id": tenant_id}
    chunks.append((text, metadata))

# BAD: Text splitter destroys structured boundaries
splitter = RecursiveCharacterTextSplitter(chunk_size=800)
chunks = splitter.split_text(json.dumps(catalog_data))
```

Category-specific formatters produce richer text and better embeddings than raw JSON dumps.

Origin: Production LLM agent — all 5 review models unanimously praised per-item chunking as "shows deep understanding of RAG. Text splitters destroy structured context."

## RRF (Reciprocal Rank Fusion) Reranking

```python
def _rerank_by_rrf(result_lists, top_k=5, k=60):
    rrf_scores = {}
    doc_map = {}
    for results in result_lists:
        for rank, (doc, score) in enumerate(results):
            doc_id = hashlib.sha256(
                (doc.page_content + str(doc.metadata.get("source", ""))).encode()
            ).hexdigest()
            if doc_id not in doc_map or score > doc_map[doc_id][1]:
                doc_map[doc_id] = (doc, score)
            rrf_scores[doc_id] = rrf_scores.get(doc_id, 0.0) + 1.0 / (k + rank + 1)
    sorted_ids = sorted(rrf_scores, key=lambda x: rrf_scores[x], reverse=True)
    return [doc_map[doc_id] for doc_id in sorted_ids[:top_k]]
```

- Use multi-strategy retrieval per query type (e.g., semantic + entity-augmented)
- k=60 per original RRF paper
- Document identity via SHA-256 of content+source
- Keep highest original cosine score per document for quality filtering after fusion

Origin: Production LLM agent — review round 9. RRF improved recall for proper noun queries where augmented search ranked differently.

## SHA-256 Content Hashing for Idempotent Ingestion

```python
ids = [
    hashlib.sha256((text + str(meta.get("source", ""))).encode()).hexdigest()
    for text, meta in zip(texts, metadatas)
]
vectorstore = Chroma.from_texts(texts=texts, metadatas=metadatas, ids=ids, ...)
```

Re-ingestion produces identical IDs -- no duplicate chunks. Content+source hash, not content-only (same text from different sources = different documents).

Origin: Production LLM agent — review round 10. Running ingestion multiple times created duplicate embeddings until hash-based dedup added.

## Dev/Prod Vector DB Abstraction

```python
# Config-driven: ChromaDB for local dev, cloud vector search for prod
if settings.VECTOR_DB == "chroma":
    from langchain_community.vectorstores import Chroma
    vectorstore = Chroma(...)
else:
    from langchain_google_vertexai import VertexAIVectorSearch
    vectorstore = VertexAIVectorSearch(...)
```

- Lazy import dev-only dependencies (~200MB) inside function, not at module level
- Same retriever interface for both backends
- `RAG_MIN_RELEVANCE_SCORE` config for quality gate

## Always Return Similarity Scores

```python
# GOOD: Scores enable monitoring and filtering
results = vectorstore.similarity_search_with_relevance_scores(query, k=top_k)
filtered = [(doc, score) for doc, score in results if score >= min_score]

# BAD: No quality signal
results = vectorstore.similarity_search(query, k=top_k)
```

No relevance score threshold = garbage in LLM context. Every multi-model review flagged this.

## Cosine Distance Math

Cosine distance range is **[0, 2]**, not [0, 1]. Cosine similarity = 1 - cosine distance.
- Score of 0.8 means similarity = 0.8 (good)
- Score of 1.2 means distance = 1.2, similarity = -0.2 (bad)

**NEVER** invert the metric: "score > 0.8" should mean HIGH similarity, not high distance.

Origin: Production LLM agent — review round 6. Monitoring metric inverted cosine distance, showing "good retrieval" when it was terrible.

## Tenant ID Metadata Isolation (Multi-Tenant Safety)

```python
def retrieve_with_scores(self, query, top_k=5):
    tenant_id = get_settings().TENANT_NAME.lower().replace(" ", "_")
    return self.vectorstore.similarity_search_with_relevance_scores(
        query, k=top_k, filter={"tenant_id": tenant_id},
    )
```

Every retrieval call filters by `tenant_id` metadata. Prevents cross-tenant leakage in shared vector stores.

## FakeEmbeddings for Testing (No API Keys)

```python
class FakeEmbeddings:
    def embed_documents(self, texts):
        return [self._hash_embed(t) for t in texts]

    @staticmethod
    def _hash_embed(text):
        h = hashlib.sha384(text.encode()).digest()
        return [float(b) / 255.0 for b in h]
```

Deterministic SHA-384 hash-based embeddings. Consistent vectors for same input. Use with `RAG_MIN_RELEVANCE_SCORE=-100` in integration tests (hash embeddings produce low cosine scores).

## Embedding Model Version Pinning

Embedding model version mismatch = different vector spaces. Always pin embedding model version alongside vector DB schema version.

```python
# GOOD
EMBEDDING_MODEL = "text-embedding-004"  # Pinned

# BAD: Version drift between ingestion and retrieval
EMBEDDING_MODEL = "text-embedding-latest"
```

Origin: Production LLM agent — review round 1. `text-embedding-004` vs `005` fallback produced different vector spaces, making retrieval unreliable.

## Data Validation at Ingestion Time

Validate JSON items before embedding. Malformed items silently produce empty chunks.

```python
def _validate_item(item: dict, required_fields: list[str]) -> bool:
    return all(item.get(field) for field in required_fields)
```

## Version-Stamp Purging for Stale RAG Chunks (MANDATORY)

SHA-256 idempotent IDs prevent duplicates on re-ingestion of identical content. But edited content creates NEW IDs without deleting old chunks. Ghost data accumulates and returns stale information.

```python
def _purge_stale_chunks(self, tenant_id: str, source: str, current_version: str):
    """After successful upsert, remove chunks from previous ingestion versions."""
    stale = self.vectorstore.get(
        where={
            "$and": [
                {"tenant_id": tenant_id},
                {"source": source},
                {"_ingestion_version": {"$ne": current_version}},
            ]
        }
    )
    if stale["ids"]:
        logger.info(f"Purging {len(stale['ids'])} stale chunks for {source}")
        self.vectorstore.delete(ids=stale["ids"])
```

- Add `_ingestion_version` metadata (ISO timestamp) to every chunk at ingestion time
- After successful upsert, query for same `tenant_id` + `source` with different `_ingestion_version`
- Delete stale chunks (purge failure is non-critical -- log, don't raise)
- This is simpler and safer than delete-then-create (which has a downtime window)

Origin: Production LLM agent — review rounds 5-20. Ghost data from previous ingestions returned stale information. Version-stamp purging praised by all 4 review models as "correct approach for structured data."

## Key Anti-Patterns

- No relevance score threshold = LLM context pollution (always filter)
- `json.dumps(data)` as embedding input = poor retrieval (use category-specific formatters)
- `text-embedding-latest` = version drift between ingestion and retrieval
- Delete-then-create ingestion = downtime window (use blue/green for production)
- Same collection, no tenant_id filter = cross-tenant data leakage
