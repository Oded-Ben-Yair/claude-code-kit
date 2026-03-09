# Vertex AI Agent Engine — LangGraph Deployment

Load when: Vertex AI, Agent Engine, LangGraph deploy, agent_engines

## Overview

Vertex AI Agent Engine provides **native LangGraph support** — deploy LangGraph agents directly without containers. Replaces Azure Functions for agent hosting.

## SDK Setup

```bash
pip install google-cloud-aiplatform[agent_engines,langchain]>=1.112
```

```python
import vertexai
from vertexai import agent_engines

vertexai.init(project="PROJECT_ID", location="us-central1")
```

## Deploy a LangGraph Agent

```python
from vertexai.agent_engines import LanggraphAgent

# Wrap your compiled LangGraph graph
agent = LanggraphAgent(
    model="gemini-3.1-pro",
    runnable=compiled_graph,  # Your StateGraph().compile() output
    tools=[tool_a, tool_b],
)

# Deploy to Agent Engine
remote_agent = agent_engines.create(
    agent=agent,
    display_name="hey-seven-agent",
    description="Casino host concierge agent",
    requirements=[
        "langgraph==0.2.60",
        "langchain-google-vertexai>=2.0",
        "langchain-google-cloud-sql-pg>=0.12",
    ],
)
```

## Checkpointer: Cloud SQL PostgreSQL

Native LangGraph checkpointer for persistent memory across turns.

```python
from langchain_google_cloud_sql_pg import PostgresChatMessageHistory, PostgresCheckpoint

# Connection via Cloud SQL Auth Proxy or Unix socket
checkpoint = PostgresCheckpoint(
    project_id="PROJECT_ID",
    region="us-central1",
    instance="cloud-sql-hey-seven",
    database="hey_seven",
    user="hey_seven_app_user",
    table_name="langgraph_checkpoints",
)

# Use in graph compilation
compiled = graph.compile(checkpointer=checkpoint)
```

### Thread-Based Memory

```python
config = {"configurable": {"thread_id": f"guest-{guest_id}"}}
response = await compiled.ainvoke(state, config=config)
```

## Tool Types

| Tool Type | Use When |
|-----------|----------|
| Python functions | Custom business logic (comp lookup, RAG retrieval) |
| LangChain tools | Existing LangChain ecosystem tools |
| Grounding tools | Google Search grounding for factual accuracy |
| Vertex Extensions | Pre-built connectors (Code Interpreter, etc.) |

## Query the Deployed Agent

```python
# Get the deployed agent
remote_agent = agent_engines.get("projects/PROJECT/locations/us-central1/agents/AGENT_ID")

# Query with thread memory
response = remote_agent.query(
    input="What dining options do you have?",
    config={"configurable": {"thread_id": "guest-12345"}},
)
```

## Auth

| Environment | Method |
|-------------|--------|
| Local dev | `gcloud auth application-default login` |
| Cloud Run | Service account (auto-detected) |
| CI/CD | `GOOGLE_APPLICATION_CREDENTIALS` env var |

## Monitoring

```bash
# List deployed agents
gcloud ai agent-engines list --region=us-central1

# View logs
gcloud logging read 'resource.type="aiplatform.googleapis.com/AgentEngine"' --limit=50

# Delete agent
gcloud ai agent-engines delete AGENT_ID --region=us-central1
```

## Key Differences from Azure Functions

| Azure Functions | Vertex AI Agent Engine |
|-----------------|----------------------|
| Container/zip deploy | Native LangGraph deploy |
| `function_app.py` entry point | `LanggraphAgent(runnable=graph)` |
| `MemorySaver` / custom checkpointer | Cloud SQL PostgreSQL checkpointer |
| Secret Manager for secrets | Secret Manager |
| Consumption plan (cold start) | Always-on or auto-scale |
| HTTP trigger per endpoint | Single agent with tools |

## Anti-Patterns

- Don't deploy raw FastAPI to Agent Engine — use Cloud Run for custom APIs
- Don't use `MemorySaver` in production — use Cloud SQL checkpointer
- Don't hardcode project/region — use `vertexai.init()` with env vars
- Pin `langgraph` version exactly (API changes between minors)
