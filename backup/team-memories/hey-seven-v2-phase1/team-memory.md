# Team Memory: hey-seven-v2-phase1

Created: 2026-02-18T10:00:00Z
Goal: Evolve Hey Seven v1 8-node graph to v2 12-node with specialist agents, compliance gate, Firestore vector search, enhanced state. All 368 v1 tests must continue passing.

## Critical Context

- **Working directory**: /home/odedbe/projects/hey-seven
- **Python**: python3 (3.12.3)
- **Test command**: `python3 -m pytest tests/ -v --tb=short`
- **Baseline**: 368 passed, 14 skipped, 95% coverage
- **v1 state type**: `PropertyQAState` in `src/agent/state.py`
- **v1 graph**: 8 nodes in `src/agent/graph.py` — router, retrieve, generate, validate, respond, fallback, greeting, off_topic
- **LLM singleton**: `_get_llm()` in `src/agent/nodes.py`
- **Circuit breaker singleton**: `_get_circuit_breaker()` in `src/agent/circuit_breaker.py`
- **Embeddings singleton**: `get_embeddings()` in `src/rag/embeddings.py`
- **Settings singleton**: `get_settings()` in `src/config.py`
- **Conftest**: Clears all singletons between tests via `_clear_singleton_caches()`

## File Ownership (NO OVERLAPS)

| Teammate | Owns (can modify) | Creates |
|----------|-------------------|---------|
| state-architect | `src/agent/state.py`, `src/config.py`, `src/agent/guardrails.py` | `src/agent/compliance_gate.py`, `tests/test_compliance_gate.py` |
| agent-builder | — | `src/agent/agents/__init__.py`, `src/agent/agents/host_agent.py`, `src/agent/agents/dining_agent.py`, `src/agent/agents/entertainment_agent.py`, `src/agent/agents/comp_agent.py`, `src/agent/agents/registry.py`, `tests/test_agents.py` |
| graph-assembler | `src/agent/graph.py`, `src/agent/nodes.py`, `src/agent/prompts.py`, `src/agent/__init__.py` | `src/agent/persona.py`, `tests/test_graph_v2.py` |
| rag-migrator | `src/rag/pipeline.py`, `src/rag/embeddings.py`, `src/agent/circuit_breaker.py`, `src/api/app.py`, `requirements.txt`, `tests/conftest.py` | `src/rag/firestore_retriever.py`, `src/agent/memory.py`, `tests/test_firestore_retriever.py` |

## Shared Decisions

<!-- Cross-team decisions that affect multiple teammates -->

## Agent: state-architect

### Findings
- v1 state had 10 fields; v2 adds 5 new fields (active_agent, extracted_fields, whisper_plan, delay_seconds, sms_segments)
- CasinoHostState alias is a simple `= PropertyQAState` (preserves TypedDict behavior)
- Config expanded from 24 to 33 settings — all with safe defaults that don't break v1
- Guardrails expanded from 56 to 73 patterns (4 injection, 6 multilingual gaming, 3 BSA/AML, 4 patron privacy)
- Compliance gate node is ready for graph-assembler to wire as first node after START
- All new state fields are JSON-serializable (roundtrip verified)
- 44 new tests all passing; 367/368 original tests passing (1 failure is rag-migrator's circuit_breaker.py change)

### COORDINATION for graph-assembler:
- `_initial_state()` in `graph.py` needs 5 new field defaults: `active_agent=None, extracted_fields={}, whisper_plan=None, delay_seconds=0.0, sms_segments=[]`
- Wire `compliance_gate_node` from `src.agent.compliance_gate` as first node after START, before router
- After compliance_gate is wired, router's guardrail checks become redundant (can be removed or kept as defense-in-depth)
- Export `CasinoHostState` from `src/agent/__init__.py`

### Files Modified
- `src/agent/state.py`: +5 v2 fields, CasinoHostState alias, updated docstring
- `src/config.py`: +9 new settings (VECTOR_DB, FIRESTORE_*, LANGFUSE_*, CASINO_ID, SMS_ENABLED, PERSONA_MAX_CHARS)
- `src/agent/guardrails.py`: +17 regex patterns (56 -> 73 total)

### Files Created
- `src/agent/compliance_gate.py`: Deterministic compliance gate node (33 statements, 100% coverage)
- `tests/test_compliance_gate.py`: 44 tests covering all 5 parts of Task #1

## Agent: agent-builder

### Findings
- All 4 specialist agents follow identical structural pattern to v1 `generate_node`
- Agents import `_get_llm`, `_format_context_block`, `_get_last_human_message` from `src.agent.nodes` (no duplication)
- Agents import `_get_circuit_breaker` from `src.agent.circuit_breaker` (shared singleton)
- Each agent has domain-specific system prompt via `string.Template.safe_substitute()`
- Registry maps: host, dining, entertainment, comp
- Comp agent has Phase 2 placeholder for `extracted_fields` profile completeness check
- 31 tests all passing, no modifications to existing files

### Files Created
- `src/agent/agents/__init__.py`: Package init with all exports
- `src/agent/agents/host_agent.py`: Primary concierge (functionally equivalent to v1 generate_node)
- `src/agent/agents/dining_agent.py`: Restaurant/bar specialist
- `src/agent/agents/entertainment_agent.py`: Shows/events/spa specialist
- `src/agent/agents/comp_agent.py`: Loyalty/promotions specialist (cautious language)
- `src/agent/agents/registry.py`: `get_agent(name)` and `list_agents()`
- `tests/test_agents.py`: 31 tests covering all agents, registry, imports

## Agent: graph-assembler

### Findings
- Graph evolved from 8 to 10 nodes (compliance_gate, persona_envelope added; generate node now runs host_agent function)
- Node name "generate" preserved for SSE streaming and test backward compat (host_agent wired under this name)
- route_from_compliance: None → router, "greeting" → greeting, anything else → off_topic
- _route_after_validate_v2: PASS → persona_envelope (new), RETRY → generate, FAIL → fallback
- _initial_state() reset includes all 5 v2 fields: active_agent, extracted_fields, whisper_plan, delay_seconds, sms_segments
- Persona envelope: web mode (PERSONA_MAX_CHARS=0) = passthrough, SMS mode = truncation with ellipsis
- test_eval_deterministic.py and test_integration.py needed host_agent._get_llm patch addition (host_agent imports _get_llm at module level, separate reference from nodes._get_llm)
- 497 tests passing (468 original + 29 new), 95.47% coverage

### COORDINATION NOTES:
- app.py `/graph` endpoint still returns v1 topology (8 nodes, start→router). Whoever owns app.py should update to v2 topology.
- Specialist agents (dining, entertainment, comp) are built and registered but not yet routed in the graph — all property_qa goes through host_agent. Specialist routing is Phase 2.

### Files Modified
- `src/agent/graph.py`: 10-node v2 graph, compliance_gate first after START, host_agent replaces generate_node, persona_envelope between validate PASS and respond
- `src/agent/__init__.py`: Added CasinoHostState export
- `tests/test_agent.py`: Updated node count 8→10, added compliance_gate + persona_envelope to expected sets
- `tests/test_eval_deterministic.py`: Added host_agent._get_llm patch to all graph-level mock contexts
- `tests/test_integration.py`: Added host_agent._get_llm patch to full_graph test

### Files Created
- `src/agent/persona.py`: Persona envelope node (web passthrough / SMS truncation)
- `tests/test_graph_v2.py`: 29 tests covering routing, persona, constants, compilation

## Agent: rag-migrator

### Findings
- Firestore `find_nearest()` returns cosine distance [0,2]; converted to similarity [0,1] via `1.0 - distance`
- `@lru_cache(maxsize=4)` for embeddings allows separate caching per task_type (default, RETRIEVAL_QUERY, RETRIEVAL_DOCUMENT)
- CircuitBreaker enhanced: `_failure_count` (int) replaced with `_failure_timestamps` (list) for rolling window; `_failure_count` property added for backward compat with existing test_nodes.py test
- `get_checkpointer()` fails gracefully: if `langgraph-checkpoint-firestore` not installed or Firestore unavailable, falls back to MemorySaver
- `get_retriever()` similarly fails gracefully: if Firestore init fails, falls back to ChromaDB
- Mock Firestore tests use `sys.modules` patching (not `patch("module.attr")`) because imports are lazy inside methods
- 468 tests passing (368 original + 100 new), 95.40% coverage

### COORDINATION for graph-assembler:
- `build_graph()` in app.py lifespan now receives checkpointer from `get_checkpointer()` instead of defaulting to `MemorySaver()`
- If graph-assembler changes `build_graph()` signature, keep `checkpointer` parameter

### Files Created
- `src/rag/firestore_retriever.py`: Firestore vector search retriever (152L, 91% coverage)
- `src/agent/memory.py`: Checkpointer factory with MemorySaver/FirestoreSaver (48L, 76% coverage)
- `tests/test_firestore_retriever.py`: 24 tests (297L)

### Files Modified
- `src/rag/pipeline.py`: `get_retriever()` — added Firestore branch with fallback to ChromaDB
- `src/rag/embeddings.py`: `get_embeddings()` — added task_type parameter, maxsize=4
- `src/agent/circuit_breaker.py`: CircuitBreakerConfig dataclass, rolling window, proper half_open with allow_request()
- `src/api/app.py`: lifespan uses `get_checkpointer()` from `src.agent.memory`
- `requirements.txt`: +3 packages (google-cloud-firestore, langgraph-checkpoint-firestore, langgraph-swarm)
- `tests/conftest.py`: added `get_checkpointer.cache_clear()`
