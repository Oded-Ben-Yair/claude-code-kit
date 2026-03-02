# Pipeline Safety Rules

On-demand: Load when working with multi-stage pipelines, transcription, audio/text processing, LLM output parsing.

## Pipeline Output Quality Gate (MANDATORY)

After ANY change to a multi-stage processing pipeline:

1. **Run a real input through the full pipeline**
2. **Assert OUTPUT properties, not just status**:
   - Segment count > expected minimum for input duration
   - Speaker count matches expectation
   - Output/input length ratio < 5x (hallucination check)
   - Speaker labels present in final output
3. **Never claim "fixed" based on**:
   - Pipeline status = completed (status doesn't measure quality)
   - Unit tests passing (tests verify code, not pipeline quality)
   - Code logic reading correctly (logic != runtime behavior)
   - Deployment succeeding (deployed != working)

## LLM Structured Output Parsing (MANDATORY)

When asking an LLM (GPT, Gemini) to return structured output:

1. **NEVER use exact string matching** (`token in ("A", "B")`)
2. **Use permissive regex extraction**: `re.findall(r'\b([AB])\b', output.upper())`
3. **Add a fallback parser** (split by comma, check last char, etc.)
4. **Log the raw LLM response** (first 200 chars) for debugging
5. **Assert expected output count** matches input count

## Pipeline Format Contracts (MANDATORY for multi-stage pipelines)

When multiple pipeline stages transform the same data (speaker labels, timestamps, translations):

1. **Single canonical format** — Define format in ONE shared constant/module, not per-stage
2. **Never run AI cleanup after formatting** — AI (Gemini, GPT) will destroy structured labels, timestamps, speaker markers. Run cleanup on RAW text first, THEN apply formatting
3. **Post-format validation must be READ-ONLY** — Generate warnings, never modify
4. **Test regex against ACTUAL output** — A regex for `נציג [HH:MM:SS]:` is a no-op when pipeline produces `[נציג MM:SS]`

## String Templating Safety (MANDATORY)

**NEVER** use Python `.format()` on strings containing user-generated text (transcripts, translations, Arabic/Hebrew/CJK). Curly braces `{}` in the text crash `.format()` with KeyError/ValueError.

```python
# BAD: Crashes on user text with braces
template = "Summary: {}".format(user_transcript)

# GOOD: Safe delimiter replacement
template = "Summary: %%CONTENT%%"
result = template.replace("%%CONTENT%%", user_transcript)
```

This applies to ALL template building where the text portion is not developer-controlled.

## Multi-Language Text Processing (MANDATORY)

When processing text that may be in different languages (Arabic, Spanish, Hebrew, etc.):

1. **NEVER** use a single regex for all languages — Arabic has different punctuation patterns than Latin
2. **ALWAYS** check `language_code` and branch processing logic:
   - Arabic (`ar`): Split on `\n+` (STT uses newlines as segment boundaries), include `؟`
   - Latin languages: Split on `[.!?¿¡。،]`
3. **ALWAYS** lower thresholds for Arabic (fewer punctuation marks = fewer detected segments)
4. **Test with real STT output** from each supported language before shipping

Origin: V7.1 Feb 2026 — sentence splitting regex designed for Spanish silently failed on Arabic, causing 67% of calls to show 1 speaker instead of 2.

## Graceful Degradation in Parallel Chunk Processing (MANDATORY)

When processing long inputs in parallel chunks (translation, summarization, analysis), pre-fill results with original input as fallback. On chunk failure, retry once then keep fallback.

1. Pre-fill results array with original input as fallback
2. Add timeout to `as_completed()` (batch-level) and `future.result()` (per-chunk)
3. On failure: retry that single chunk once
4. On retry failure: keep original text, log warning, continue
5. After all futures: log count of fallback chunks

Getting 63/65 segments processed with 2 in original form is far better than a 500 error.

Origin: QC Telephony Feb 2026 — parallel translation of 65-segment calls needed partial-success handling.

## Refusal-Retry for Stochastic Content Safety Filters

Azure AI Content Safety filters are stochastic (~20% refusal rate on financial/regulated topics). Detect and retry on refusal signatures:

1. Define refusal signature patterns (always English, always short or tail-end cutoff)
2. Check response: full refusal (<200 chars) OR mid-response cutoff (last 100 chars matches pattern)
3. Retry with exponential backoff (up to MAX_RETRIES - 1 attempts)
4. Track retry_count in response metadata for monitoring

Same query passes 8/10 times. Retry eliminates 20% false refusal rate to ~0%.

Origin: CS Agents Feb 2026 — Azure AI content safety filter blocked ~20% of valid financial queries stochastically.
