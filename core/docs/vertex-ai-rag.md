# Vertex AI RAG Engine — Managed RAG + Vector Search

Load when: Vertex AI RAG, Vector Search, RAG corpus, managed RAG, embedding

## Overview

Vertex AI RAG Engine provides managed RAG with Vector Search backend, automatic chunking, and `text-embedding-005`. Replaces custom ChromaDB/Pinecone pipelines.

## Create RAG Corpus

```python
from vertexai import rag

# Create corpus with Vector Search backend
corpus = rag.create_corpus(
    display_name="hey-seven-mohegan",
    description="Mohegan Sun property knowledge base",
    embedding_model_config=rag.EmbeddingModelConfig(
        publisher_model="publishers/google/models/text-embedding-005",
    ),
)
```

### Pin Embedding Model Version (MANDATORY)

```python
# GOOD: Pinned version
publisher_model="publishers/google/models/text-embedding-005"

# BAD: Version drift between ingestion and retrieval
publisher_model="publishers/google/models/text-embedding-latest"
```

Origin: Hey Seven R1 — `text-embedding-004` vs `005` fallback produced different vector spaces.

## Import Files

```python
# From Cloud Storage
response = rag.import_files(
    corpus_name=corpus.name,
    paths=["gs://bucket/property-data/mohegan-sun/"],
    chunk_size=500,      # Characters per chunk
    chunk_overlap=100,   # Overlap between chunks
)

# From Google Drive
response = rag.import_files(
    corpus_name=corpus.name,
    paths=["https://drive.google.com/drive/folders/FOLDER_ID"],
)
```

### Per-Item Chunking for Structured Data (MANDATORY)

For structured data (menus, hours, addresses), DO NOT use automatic chunking. Pre-chunk per item and upload as individual documents.

```python
# Pre-chunk structured data into individual files
for item in restaurant_data["items"]:
    text = _format_restaurant(item)  # Category-specific formatter
    filename = f"dining-{item['name'].lower().replace(' ', '-')}.txt"
    # Upload to Cloud Storage, then import
    blob = bucket.blob(f"property-data/mohegan-sun/dining/{filename}")
    blob.upload_from_string(text)
```

Origin: Hey Seven — all 5 review models praised per-item chunking. Text splitters destroy structured context.

## Retrieval

```python
# Direct retrieval with relevance scores
response = rag.retrieval_query(
    rag_resources=[rag.RagResource(rag_corpus=corpus.name)],
    text="What dining options are available?",
    similarity_top_k=5,
    vector_distance_threshold=0.3,  # Filter low-relevance results
)

for result in response.contexts.contexts:
    print(f"Score: {result.score}, Text: {result.text[:100]}")
```

### Always Filter by Relevance Score

```python
# GOOD: Quality gate on retrieval
filtered = [ctx for ctx in response.contexts.contexts if ctx.score >= MIN_RELEVANCE]

# BAD: No quality signal — garbage in LLM context
all_results = response.contexts.contexts
```

## Multi-Tenant Isolation

Use separate RAG corpus per property (replaces `property_id` metadata filter).

```python
# One corpus per property
CORPUS_MAP = {
    "mohegan_sun": "projects/P/locations/L/ragCorpora/CORPUS_1",
    "foxwoods": "projects/P/locations/L/ragCorpora/CORPUS_2",
}

def get_corpus(property_id: str) -> str:
    return CORPUS_MAP[property_id]
```

**Advantage over metadata filter**: Complete data isolation. No risk of cross-tenant leakage.

## Version-Stamp Purging

Re-import with a new corpus version to handle stale data.

```python
# Option 1: Delete and recreate corpus (simple, small downtime)
rag.delete_corpus(corpus_name=old_corpus.name)
new_corpus = rag.create_corpus(...)
rag.import_files(corpus_name=new_corpus.name, ...)

# Option 2: Delete specific files (surgical)
rag.delete_file(file_name=stale_file.name)
rag.import_files(corpus_name=corpus.name, paths=[updated_file_path])
```

## RRF Reranking (Client-Side)

Vertex AI RAG Engine returns single-strategy results. For multi-strategy retrieval, implement RRF client-side:

```python
def rerank_by_rrf(result_lists, top_k=5, k=60):
    """Reciprocal Rank Fusion across multiple retrieval strategies."""
    rrf_scores = {}
    doc_map = {}
    for results in result_lists:
        for rank, ctx in enumerate(results):
            doc_id = hashlib.sha256(ctx.text.encode()).hexdigest()
            if doc_id not in doc_map or ctx.score > doc_map[doc_id].score:
                doc_map[doc_id] = ctx
            rrf_scores[doc_id] = rrf_scores.get(doc_id, 0.0) + 1.0 / (k + rank + 1)
    sorted_ids = sorted(rrf_scores, key=lambda x: rrf_scores[x], reverse=True)
    return [doc_map[doc_id] for doc_id in sorted_ids[:top_k]]
```

## Key Differences from Custom RAG

| Custom (ChromaDB) | Vertex AI RAG Engine |
|-------------------|---------------------|
| Self-managed vector DB | Managed Vector Search |
| Manual embedding calls | Built-in `text-embedding-005` |
| `property_id` metadata filter | Separate corpus per tenant |
| SHA-256 idempotent IDs | Managed deduplication |
| `_ingestion_version` purging | Delete + re-import |
| Local dev: ChromaDB | Local dev: same API (emulator or direct) |

## Anti-Patterns

- Don't use automatic chunking for structured data (menus, hours) — pre-chunk per item
- Don't mix properties in one corpus — use separate corpus per tenant
- Don't skip relevance score filtering — garbage results pollute LLM context
- Don't use `text-embedding-latest` — pin to `005` for consistent vector spaces
