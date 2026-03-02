# Nouf v2 Secret Client Optimization Loop

## Current Target
Achieve ≥90% (45/50) human-likeness across ALL 4 test scenarios.

## Agent Information
- **Agent ID**: agent_1601kerqv2m7fhbatr46x4syeb6q
- **Name**: Nouf v2 - Secret Client (Enhanced)
- **Role**: Simulated client that tests sales agents
- **LLM**: gemini-2.5-flash (temperature 0.6)
- **Voice**: speed 0.92, stability 0.40

## 5-Pillar Scoring Framework

| Pillar | Description | Target |
|--------|-------------|--------|
| Human Naturalness | Voice variation, fillers, pauses | 9/10 |
| Response Appropriateness | Matches agent quality correctly | 9/10 |
| Layer Progression | Opens only with good agents | 9/10 |
| Emotional Authenticity | Sounds genuinely upset/happy | 9/10 |
| Test Validity | Actually tests agent skills | 9/10 |

## Test Scenarios

| Scenario | Expected Behavior |
|----------|-------------------|
| `empathetic_agent` | Nouf opens to Layer 3, ends with نجاح |
| `pushy_agent` | Nouf stays at Layer 1, ends with خسارة |
| `confused_agent` | Nouf asks for clarity, ends with محايد |
| `crisis_aware_agent` | Nouf trusts deeply, ends with نجاح كبير |

## Each Iteration Must:

1. **Read current scores** from `test-results/nouf_latest_scores.json`
2. **Identify the LOWEST scoring pillar**
3. **Make ONE targeted improvement** to address that pillar
4. **Update Nouf v2** via ElevenLabs API (PATCH)
5. **Run test**: `python3 scripts/test_nouf_v2.py <scenario>`
6. **Score transcript** with Gemini
7. **Save results** to `test-results/nouf_latest_scores.json`
8. **Git commit** with iteration number

## Improvement Strategies by Pillar

### Human Naturalness (if below 9/10)
- Add more filler variations to prompt
- Adjust stability (lower = more variation)
- Add more SSML pauses
- Add phrase diversity rules

### Response Appropriateness (if below 9/10)
- Tune agent-quality detection thresholds
- Add clearer open/close trigger phrases
- Calibrate sensitivity to agent behaviors

### Layer Progression (if below 9/10)
- Adjust trust-gating rules timing
- Add more trust accumulation signals
- Tune safety valve timing (currently 15 min)

### Emotional Authenticity (if below 9/10)
- Add more emotional response variations
- Tune SSML pause lengths for emotions
- Add voice instruction hints

### Test Validity (if below 9/10)
- Ensure distinct behaviors per scenario
- Add clearer pass/fail signals
- Verify layer system progression

## Files to Modify

| File | Purpose |
|------|---------|
| `prompts/nouf-v2-system-prompt.md` | Core prompt |
| `config/nouf_v2_config.json` | Voice/LLM settings |
| `config/nouf_test_scenarios.json` | Test definitions |

## API Commands

### Update prompt:
```python
import requests
requests.patch(
    f"https://api.elevenlabs.io/v1/convai/agents/{agent_id}",
    headers={"xi-api-key": API_KEY, "Content-Type": "application/json"},
    json={"conversation_config": {"agent": {"prompt": {"prompt": new_prompt}}}}
)
```

### Update voice settings:
```python
requests.patch(
    f"https://api.elevenlabs.io/v1/convai/agents/{agent_id}",
    json={"conversation_config": {"tts": {"stability": 0.38, "speed": 0.90}}}
)
```

### Run test:
```bash
python3 scripts/test_nouf_v2.py empathetic_agent
python3 scripts/test_nouf_v2.py pushy_agent
python3 scripts/test_nouf_v2.py confused_agent
python3 scripts/test_nouf_v2.py crisis_aware_agent
```

## Stop Condition

When average score ≥45/50 (90%+) across ALL 4 scenarios, output:

```
<promise>NOUF_PERFECTION_ACHIEVED</promise>
```

## Current Iteration Work

Read `test-results/nouf_latest_scores.json` for current state.
If file doesn't exist, run baseline test first:
```bash
python3 scripts/test_nouf_v2.py
```

Then identify weakest pillar and apply targeted fix.
