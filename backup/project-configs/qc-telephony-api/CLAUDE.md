# QC Telephony API - Project Configuration

## Overview

Azure Functions API for call transcript translation and Q&A, designed for telephony system integration.

**Endpoints:**
- `GET /api/health` - Health check (anonymous)
- `POST /api/translate` - Translate call JSON (AR/ES/PT → EN/HE)
- `POST /api/agent/query` - RAG-style Q&A with citations

## Architecture

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Platform | Azure Functions (Python v2) | Pay-per-use, auto-scale |
| LLM | Azure OpenAI GPT-5 | Dialect-aware, high quality |
| Auth | Function Key | Simple API-to-API auth |
| Storage | Stateless | Caller owns data |

## Project Structure

```
qc-telephony-api/
├── src/api/
│   ├── function_app.py           # HTTP endpoints
│   ├── host.json                 # Functions config
│   ├── local.settings.json       # Local dev (gitignored)
│   ├── requirements.txt          # Dependencies
│   └── shared/
│       ├── models.py             # Pydantic models
│       ├── llm_client.py         # Azure OpenAI wrapper
│       ├── translation_service.py # Multi-language translation
│       └── qa_agent_service.py   # Q&A with citations
├── tests/
│   ├── test_translation.py
│   └── test_qa_agent.py
├── samples/
│   ├── input/                    # Sample call JSONs
│   └── schemas/                  # JSON schemas
└── CLAUDE.md
```

## Development Commands

```bash
# Setup
cd ~/projects/qc-telephony-api/src/api
cp local.settings.json.example local.settings.json  # Add your keys
pip install -r requirements.txt

# Run locally
func start  # Runs on port 7072

# Test endpoints
curl http://localhost:7072/api/health

# Run tests
cd ~/projects/qc-telephony-api
pytest tests/ -v

# Deploy
func azure functionapp publish func-qc-telephony-prod --python
```

## API Contracts

### POST /api/translate

```json
// Request
{
  "callId": "sample_ar_001",
  "language": "ar",           // ar | es | pt
  "targetLanguage": "en",     // en | he (default: en)
  "segments": [
    {"speakerId": "speaker_0", "start": 1.2, "end": 28.98, "text": "..."}
  ]
}

// Response
{
  "callId": "sample_ar_001",
  "sourceLanguage": "ar",
  "targetLanguage": "en",
  "segments": [
    {
      "speakerId": "speaker_0",
      "start": 1.2,
      "end": 28.98,
      "originalText": "...",
      "translatedText": "..."
    }
  ]
}
```

### POST /api/agent/query

```json
// Request
{
  "callId": "sample_ar_001",
  "language": "ar",
  "question": "What was discussed about pricing?",
  "segments": [...],
  "translatedSegments": [...]  // optional
}

// Response
{
  "callId": "sample_ar_001",
  "question": "What was discussed about pricing?",
  "answer": "The agent discussed a special offer...",
  "confidence": 0.85,
  "relevantSegments": [
    {
      "speakerId": "speaker_0",
      "start": 48.5,
      "end": 70.22,
      "text": "...",
      "translation": "..."
    }
  ]
}
```

## Environment Variables

```
AZURE_OPENAI_ENDPOINT=https://brn-azai.openai.azure.com/
AZURE_OPENAI_KEY=<from Key Vault>
AZURE_OPENAI_DEPLOYMENT=gpt-5
```

## Supported Languages

| Source | Dialects Handled |
|--------|------------------|
| Arabic (ar) | Levantine, Gulf/Khaleeji, MSA |
| Spanish (es) | Latin American, Castilian |
| Portuguese (pt) | Brazilian, European |

| Target | |
|--------|---|
| English (en) | Natural conversational |
| Hebrew (he) | Modern spoken Hebrew |

## Key Features

1. **Dialect-Aware Translation**: Language-specific prompts handle regional variations
2. **Chunking**: Long transcripts (>6000 chars) split and translated in parts
3. **Citations**: Q&A returns specific segments supporting the answer
4. **Retry Logic**: 3 attempts with exponential backoff for LLM calls
5. **Token Tracking**: Cumulative usage stats available

## Testing with Samples

```bash
# Translate Arabic sample
curl -X POST http://localhost:7072/api/translate \
  -H "Content-Type: application/json" \
  -d @samples/input/call_arabic_01.json

# Q&A about the call
curl -X POST http://localhost:7072/api/agent/query \
  -H "Content-Type: application/json" \
  -d '{
    "callId": "sample_ar_001",
    "language": "ar",
    "question": "What time is best to contact the customer?",
    "segments": [...]
  }'
```

## Azure DevOps

**Repository**: `https://dev.azure.com/Corp-domain/Corp-AI/_git/qc-telephony-api`

```bash
# Clone
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/qc-telephony-api

# Push
git push azure main
```

## Related Projects

- **QC Call Analyzer**: Full audio pipeline + UI
- **Pattern Reference**: `~/projects/qc-call-analyzer/src/api/shared/chat_service.py`
