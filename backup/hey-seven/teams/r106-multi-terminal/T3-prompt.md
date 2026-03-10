# T3: Eval Runner + Judge Panel Upgrade

## Context
You are Terminal 3 in a 4-terminal parallel implementation of R106. Your job has two phases:
1. **Immediate**: Run P9 re-eval using EXISTING code (no code changes needed — the R105 handoff fix is already committed)
2. **Then**: Upgrade the judge panel to 3 models: GPT-5.4 + Grok 4 + DeepSeek Speciale

**Read `.claude/teams/r106-multi-terminal/status.md` for file ownership rules. You ONLY modify files assigned to T3.**

## Your Files (EXCLUSIVE)
- `tests/evaluation/run_r95_judge.py` — MODIFY (add GPT-5.4 + DeepSeek judge functions)
- `tests/evaluation/streaming_judge.py` — MODIFY (wire 3-model consensus)
- `tests/evaluation/results/r106-*` — CREATE (eval output files)

## DO NOT TOUCH (owned by other terminals)
- Anything in `src/` (T1 and T2)
- `tests/test_*.py` (T1 and T2)
- `scripts/*`, `data/*` (T4)

## Phase 1: P9 Re-Eval (Start Immediately)

The R105 handoff bug fix is already committed (c8b0cbc). Handoff prompts now inject BEFORE llm.ainvoke(). We need to re-eval to see if P9 improved.

### Steps:
1. Set up environment:
```bash
cd /home/odedbe/projects/hey-seven
export $(grep "^GOOGLE_API_KEY=" .env | xargs)
export FORCE_PRO_MODEL=true
```

2. Run host-triangle eval (30 scenarios, tests P9 + H9):
```bash
python3 tests/evaluation/run_live_eval.py \
  --pattern "host_triangle*.yaml" \
  --round r106-p9-reeval \
  --timeout 120 \
  --streaming-dir tests/evaluation/results/r106-p9-reeval-streaming
```

3. While eval runs, set up judge credentials in another terminal or wait for completion:
```bash
export AZURE_AI_ENDPOINT=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-Endpoint -o tsv --query value)
export AZURE_AI_KEY=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-ApiKey -o tsv --query value)
```

4. Judge the results with streaming judge:
```bash
python3 tests/evaluation/streaming_judge.py \
  --watch tests/evaluation/results/r106-p9-reeval-streaming \
  --category host-triangle
```

5. Record P9 and H9 scores from the rolling dashboard. Compare to R105 baseline:
   - P9 was 2.45 → target 3.5+ (handoff bug fix)
   - H9 was 2.35 → no change expected yet (tool-use not ready)

### Important Notes:
- The eval uses Gemini Pro (FORCE_PRO_MODEL=true) with 120s timeout
- Preview models have ~250 RPD free tier — one 30-scenario eval burns ~180 calls
- If you hit rate limits, wait 5 minutes and retry with `--skip-completed`
- The streaming judge currently uses GPT-5.2 — that's fine for P9 re-eval. You'll upgrade it in Phase 2.

## Phase 2: Judge Panel Upgrade to 3-Model Consensus

### Step 1: Verify GPT-5.4 deployment
```bash
# Check what models are deployed on Azure AI Foundry
export AZURE_AI_ENDPOINT=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-Endpoint -o tsv --query value)
export AZURE_AI_KEY=$(az keyvault secret show --vault-name kv-seekapa-apps --name AzureAIFoundry-ApiKey -o tsv --query value)

# List deployments to find exact GPT-5.4 deployment name
curl -s "${AZURE_AI_ENDPOINT}openai/deployments?api-version=2024-10-21" \
  -H "api-key: ${AZURE_AI_KEY}" | python3 -m json.tool | grep -i "model\|id"
```

### Step 2: Find DeepSeek deployment name
```bash
# DeepSeek Speciale may be deployed as a serverless model
# Check available models
curl -s "${AZURE_AI_ENDPOINT}openai/deployments?api-version=2024-10-21" \
  -H "api-key: ${AZURE_AI_KEY}" | python3 -m json.tool
```

If DeepSeek is not deployed as an OpenAI-compatible endpoint, use the Azure AI Inference SDK pattern. Check `~/.claude/configs/` for Azure AI Foundry model configs.

### Step 3: Update run_r95_judge.py

Read the full file first. Then:

1. **Rename `judge_with_gpt52` to `judge_with_gpt54`** and update the deployment name:
```python
async def judge_with_gpt54(prompt: str, endpoint: str, key: str) -> dict | None:
    """Score using GPT-5.4 via Azure AI Foundry."""
    import httpx
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{endpoint.rstrip('/')}/openai/deployments/gpt-5.4/chat/completions?api-version=2024-10-21",
            # ... rest same as gpt52 but with deployment name "gpt-5.4"
```
Keep `judge_with_gpt52` as a fallback but add `judge_with_gpt54` as the primary.

2. **Add `judge_with_deepseek`**:
```python
async def judge_with_deepseek(prompt: str, endpoint: str, key: str) -> dict | None:
    """Score using DeepSeek-V3.2-Speciale via Azure AI Foundry."""
    import httpx
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{endpoint.rstrip('/')}/openai/deployments/DeepSeek-V3-2-Speciale/chat/completions?api-version=2024-10-21",
            headers={"api-key": key, "Content-Type": "application/json"},
            json={
                "messages": [{"role": "user", "content": prompt}],
                "temperature": 0.1,
                "max_completion_tokens": 2000,
            },
            timeout=120.0,  # DeepSeek is slower
        )
```

3. **Add `--judge` choices**: Update argparse to support `gpt54`, `grok4`, `deepseek`, `all`, and `consensus`.

4. **Add consensus scoring**: When `--judge consensus`, run all 3 judges in parallel per scenario, take median of each dimension score.

### Step 4: Update streaming_judge.py

The streaming judge imports `judge_with_gpt52` from `run_r95_judge.py`. Update it to:
1. Import `judge_with_gpt54` instead of `judge_with_gpt52`
2. Add `--judges` flag: `gpt54` (default), `grok4`, `deepseek`, `consensus`
3. For consensus mode: run all 3 judges per scenario in parallel, report median + spread

### Step 5: Validate the upgrade
Run a quick 3-scenario test with all 3 judges:
```bash
# Pick 3 existing result files
python3 tests/evaluation/run_r95_judge.py \
  --results-dir tests/evaluation/results/r106-p9-reeval-streaming \
  --category host-triangle \
  --judge consensus \
  --output tests/evaluation/results/r106-judge-upgrade-test.json
```

Verify all 3 judges return valid scores. Check for:
- JSON parse errors (increase max_completion_tokens if needed)
- Timeout errors (increase timeout for DeepSeek)
- Auth errors (wrong deployment name)

### Step 6: Write completion status
Update `.claude/teams/r106-multi-terminal/status.md` — change T3 status to COMPLETED with:
- P9 re-eval scores (all H and P dimensions)
- Judge upgrade validation results
- Any issues encountered

## Success Criteria
- [ ] P9 re-eval completed with scores recorded
- [ ] GPT-5.4 judge function works (verified on 3+ scenarios)
- [ ] Grok 4 judge function works
- [ ] DeepSeek Speciale judge function works
- [ ] Consensus scoring (median of 3) implemented
- [ ] streaming_judge.py updated to use new judge functions
- [ ] No changes to files outside T3 ownership
