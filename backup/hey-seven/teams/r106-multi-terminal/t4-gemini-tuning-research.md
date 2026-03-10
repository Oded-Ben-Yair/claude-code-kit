# T4: Gemini Fine-Tuning API Research

Date: 2026-03-09
Sources: google-developer-knowledge MCP (official Vertex AI docs + Gemini API deprecation page)
Confidence: High (verified against 5 official Google Cloud documentation pages)

## CRITICAL: Model Deprecation Schedule

From official Google deprecation page (ai.google.dev/gemini-api/docs/deprecations):

| Model | Shutdown Date | Replacement |
|-------|-------------|-------------|
| `gemini-3-pro-preview` | **March 9, 2026 (TODAY)** | `gemini-3.1-pro-preview` |
| `gemini-2.0-flash` | **June 1, 2026** | `gemini-2.5-flash` |
| `gemini-2.0-flash-lite` | **June 1, 2026** | `gemini-2.5-flash-lite` |
| `gemini-2.5-pro` (GA) | June 17, 2026 | `gemini-3.1-pro-preview` |
| `gemini-2.5-flash` (GA) | June 17, 2026 | `gemini-3-flash-preview` |
| `gemini-2.5-flash-lite` (GA) | July 22, 2026 | `gemini-3.1-flash-lite-preview` |

**Gemini 3.x models are ALL preview** — no GA versions, no shutdown dates announced yet.

### Implication for Fine-Tuning

- **Gemini 2.5 Flash** is GA but shuts down June 17, 2026 (~3 months). Any tuned model based on it will also stop working.
- **Gemini 2.0 Flash** shuts down June 1, 2026. DO NOT tune this.
- **Gemini 3.x** has no fine-tuning support and no GA timeline.
- **Best strategy**: Tune 2.5 Flash now for immediate behavioral improvement. When 3.x GA launches with tuning support, migrate training data (same JSONL format expected).

## Key Finding: Gemini 3.x Does NOT Support Fine-Tuning

As of March 2026, **no Gemini 3.x model supports fine-tuning**. The Gemini API / AI Studio fine-tuning was deprecated with Gemini 1.5 Flash-001 in May 2025. Only Vertex AI supports tuning.

**Best candidate: Gemini 2.5 Flash** — GA (until June 2026), widest adapter sizes (1-16), preference tuning also available.

## Supported Models (Vertex AI Only)

From official docs (docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-supervised-tuning):

| Model | SFT | Preference Tuning | Continuous Tuning | Adapter Sizes | Max Tokens/Example |
|-------|-----|-------------------|-------------------|---------------|-------------------|
| Gemini 2.5 Pro | YES | NO | YES | 1, 2, 4, 8 | 131,072 |
| **Gemini 2.5 Flash** | **YES** | **YES** | **YES** | **1, 2, 4, 8, 16** | **131,072** |
| Gemini 2.5 Flash-Lite | YES | YES | YES | 1, 2, 4, 8, 16 | 131,072 |
| Gemini 2.0 Flash | YES | NO | NO | 1, 2, 4, 8 | 131,072 |
| Gemini 2.0 Flash-Lite | YES | NO | NO | 1, 2, 4, 8 | 131,072 |

**Key**: Gemini 2.5 Flash is the ONLY model that supports ALL three: SFT + Preference Tuning + Continuous Tuning + max adapter size 16.

## JSONL Format (Vertex AI Contents Format)

From official text tuning docs (docs.cloud.google.com/vertex-ai/generative-ai/docs/models/tune_gemini/text_tune):

**NOT OpenAI messages format.** Uses `role: "user"` and `role: "model"` (not "assistant").

### Official Example (from Google docs):
```jsonl
{"systemInstruction": {"role": "system", "parts": [{"text": "You are a pirate dog named Captain Barktholomew."}]}, "contents": [{"role": "user", "parts": [{"text": "Hi"}]}, {"role": "model", "parts": [{"text": "Argh! What brings ye to my ship?"}]}, {"role": "user", "parts": [{"text": "What's your name?"}]}, {"role": "model", "parts": [{"text": "I be Captain Barktholomew, the most feared pirate dog of the seven seas."}]}]}
```

### Key Format Rules (from official docs):
- `systemInstruction` is **optional** top-level field, separate from `contents`
- `systemInstruction.role` is ignored by the model (but must be present in schema)
- `contents[].role`: `"user"` or `"model"` only
- `contents[].parts[]`: array of `{"text": "..."}` or `{"fileData": {...}}` for multimodal
- Last message MUST be `"model"` role (that's the training target)
- Also supports `tools` field for function calling tuning

### Sample Datasets (Google-provided):
```
gs://cloud-samples-data/ai-platform/generative_ai/gemini-2_0/text/sft_train_data.jsonl
gs://cloud-samples-data/ai-platform/generative_ai/gemini-2_0/text/sft_validation_data.jsonl
```

## Dataset Requirements

- **Minimum recommended**: 100 examples ("start with 100, scale up to thousands if needed")
- **Quality > quantity**: Official docs emphasize this repeatedly
- **Maximum**: 10M text examples or 300K multimodal, 1 GB file size
- **Validation**: Up to 5,000 examples or 30% of training count
- **Max tokens per example**: 131,072 (input + output combined)

## Cost

Pricing page defers to Vertex AI pricing (cloud.google.com/vertex-ai/generative-ai/pricing).
Training tokens = (tokens in dataset) × (number of epochs).
Inference cost = same as base model (no premium for tuned).

From Perplexity research (not in official MCP docs):
- Gemini 2.5 Flash: ~$5/M training tokens
- Gemini 2.5 Pro: ~$25/M training tokens

**Hey Seven estimate**: 200 conversations × 800 tokens × 4 epochs = 640K tokens ≈ **$3-5 per run**.

## Training Time

Not published in official docs. Community reports: 100-500 examples = minutes to ~1 hour.

## Platform

- **Vertex AI**: YES — full support (Console, Python SDK, REST API, BigQuery ML, Colab)
- **AI Studio / Gemini API (ai.google.dev)**: NO — deprecated since May 2025
- **Requires**: GCP project with billing (we already target GCP)

## Configurable Parameters

| Parameter | Values | Default |
|-----------|--------|---------|
| epochCount | 1-10+ | Auto-determined |
| adapterSize | 1/2/4/8/16 (Flash) | Model-dependent |
| learningRateMultiplier | 0.1-2.0 | 1.0 |
| exportLastCheckpointOnly | boolean | false |
| evaluationConfig | object | None (preview: auto-run Gen AI eval) |

### Adapter Size Guidance
- 1-2: Minimal changes (formatting, simple tone)
- **4: Good default** for behavioral changes
- 8: Complex reasoning pattern changes
- 16 (Flash only): Maximum expressiveness, needs large dataset

### Thinking Budget
For thinking models (2.5 Flash, 2.5 Pro): **set thinking budget to OFF or lowest value** for tuned models. SFT teaches direct answer patterns, thinking becomes redundant.

## Output

- Auto-deployed endpoint: `projects/{ID}/locations/{REGION}/endpoints/{ENDPOINT_ID}`
- Invoke same as base model via Vertex AI SDK or LangChain
- Inference cost = same as base model (no premium)
- Supports tuning checkpoints (compare performance across checkpoints)
- Supports continuous tuning (add more data/epochs to existing tuned model)

## Python SDK Example

```python
import vertexai
from vertexai.tuning import sft

vertexai.init(project="hey-seven-prod", location="us-central1")

job = sft.train(
    source_model="gemini-2.5-flash",
    train_dataset="gs://hey-seven-training/gold-traces-r106.jsonl",
    validation_dataset="gs://hey-seven-training/gold-traces-manual.jsonl",
    epochs=4,
    adapter_size=4,
    learning_rate_multiplier=1.0,
    tuned_model_display_name="hey-seven-host-v1",
)

# Use the tuned model
from vertexai.generative_models import GenerativeModel
tuned = GenerativeModel(job.tuned_model_endpoint_name)
response = tuned.generate_content("Hi, celebrating our anniversary!")
```

## Known Issues (from official docs)

1. **Controlled generation (JSON mode) + tuned models**: decreased quality due to data misalignment. SFT already teaches structured output — don't apply controlled generation at inference.
2. **Thinking models**: disable thinking budget for tuned endpoints
3. **Quota**: 1 concurrent tuning job per project (request increase)
4. **Gemini 3.x fine-tuning**: no support, no timeline
5. **SFT is not a Covered Service**: excluded from SLA

## Preference Tuning (Also Available for 2.5 Flash)

Gemini 2.5 Flash and Flash-Lite support **preference tuning** (RLHF/DPO). This could be valuable for Hey Seven:
- Use judge scores as preference signals (7/10 response preferred over 3/10)
- Can be applied AFTER SFT for further refinement
- Token cost: (prompt_tokens × 2) + completion_tokens per example

## Actionable Next Steps

1. **Immediate**: Export gold traces (done: 51 conversations at 7.0 threshold) → JSONL ✅
2. **Next**: Upload to GCS bucket (`gsutil cp data/training/*.jsonl gs://hey-seven-training/`)
3. **First experiment**: 2.5 Flash, adapter_size=4, epochs=4 (~$3-5)
4. **Eval**: Run same 85-scenario eval against tuned model, compare B-avg/P-avg/H-avg
5. **Integration**: Add tuned endpoint as routing option in `nodes.py` model routing
6. **Preference tuning**: After SFT baseline, use 3/6/9 judge-scored pairs for DPO
7. **Migration plan**: When Gemini 3.x GA + tuning launches, re-tune with same training data

## Sources (Official Google Cloud Documentation via MCP)

- `docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-supervised-tuning` — Overview + limitations
- `docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-use-supervised-tuning` — How to tune
- `docs.cloud.google.com/vertex-ai/generative-ai/docs/models/gemini-supervised-tuning-prepare` — Dataset format
- `docs.cloud.google.com/vertex-ai/generative-ai/docs/models/tune_gemini/text_tune` — Text tuning specifics
- `docs.cloud.google.com/vertex-ai/generative-ai/docs/models/tune-models` — Tuning methods overview
- `docs.cloud.google.com/vertex-ai/generative-ai/docs/learn/model-versions` — Model lifecycle + stable versions
- `ai.google.dev/gemini-api/docs/deprecations` — Deprecation schedule (CRITICAL)
- `ai.google.dev/gemini-api/docs/changelog` — Release notes
