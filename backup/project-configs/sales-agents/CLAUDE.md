# Sales Agents Project - Claude Code Configuration

**Project**: Arabic Voice Agents for Sales/Retention Calls
**Platform**: ElevenLabs Conversational AI
**Last Updated**: 2026-02-02

---

## Quick Start

```bash
# Test v7 agents (live)
# Khaled: https://elevenlabs.io/app/talk-to?agent_id=agent_3201kgf1m5q0fkvazvfxqsdg1x5c
# Nouf:   https://elevenlabs.io/app/talk-to?agent_id=agent_2901kgespgzqf6eb3724ftfg4yvr

# Create v7 agents
python3 scripts/create_v7_agents.py
```

---

## Current State (v7)

### Active Agents (v7 - Human-Like Arabic Voice Agents)

| Agent | ID | LLM | Voice | Status |
|-------|-----|-----|-------|--------|
| **Khaled v7.4** | `agent_3201kgf1m5q0fkvazvfxqsdg1x5c` | Claude Sonnet 4.5 | `oUCSlKjkoFDoKamPHpAV` | Awaiting QA |
| **Nouf v7 Final** | `agent_2901kgespgzqf6eb3724ftfg4yvr` | Gemini 2.5 Flash | `4wf10lgibMnboGJGCLrP` | QA Approved |

### Khaled v7.4 Settings (Recovery Client)
- **LLM**: claude-sonnet-4-5, temp=0.6, max_tokens=150
- **TTS**: eleven_turbo_v2_5, stability=0.45, similarity=0.75, speed=1.0
- **Prompt**: `prompts/khaled-v7-ar-DEPLOYED.md` (7959 chars, anti-parroting design)
- **Config**: `config/v7-khaled-voices.json`
- **P0 Next Session**: QA verification of humanization changes

### Nouf v7 Final Settings (New Client - Onboarding)
- **Config**: `config/v7-nouf-final.json`
- **Prompt**: `prompts/nouf-v7-final-DEPLOYED.md`

### v7 Key Innovations
- **Anti-parroting prompt design**: Guidelines instead of exact-quote examples
- **Three-lever humanization**: Temperature + TTS stability + prompt de-scripting
- **Arabic number pronunciation**: Spell out ("خمس مية" not "500")
- **Brand name in English**: "Seekapa" in Latin letters inside Arabic text
- **LLM Shootout winner**: Gemini 2.5 Flash (Nouf), Claude Sonnet 4.5 (Khaled)

---

## Previous State (v6.8 - Archive)

### v6.8 Agents (Still Active)
| Agent | ID | LLM | Latency |
|-------|-----|-----|---------|
| Maryam-Claude | `agent_9901kfae5g8he788z86ve0p4bp2g` | Claude Sonnet 4.5 | 1798ms avg |
| Maryam-Gemini | `agent_5701kfae5dh6fgw9ezvsqvvnrqdz` | Gemini 3 Flash | 3237ms avg |
| Nouf-Claude | `agent_6201kfae5hgze9ws5f4sj5jkrdym` | Claude Sonnet 4.5 | - |
| Nouf-Gemini | `agent_4501kfae5ewmegmavr7rbk7ak3ar` | Gemini 3 Flash | - |

### v6.8 Fixes Applied
- **Gender**: Plural/formal addressing (كيف الحال؟, الله يسعدكم)
- **Latency**: Prompt reduced 70%, streaming level 4, eager mode
- **Status**: Gender PASS, Latency IMPROVED (1798ms, target <1500ms)

---

## Project Structure

```
sales-agents/
├── config/                    # Agent configurations
│   ├── v7-khaled-voices.json    # ✅ Current (Khaled v7.4)
│   ├── v7-nouf-final.json       # ✅ Current (Nouf v7 Final)
│   ├── v7-llm-shootout.json     # LLM comparison results
│   ├── v7-arabic-ab-test.json   # A/B test configs
│   ├── v6.8-gemini-agents.json  # Archive (v6.8)
│   └── v6.8-claude-agents.json  # Archive (v6.8)
├── prompts/                   # System prompts
│   ├── khaled-v7-ar-DEPLOYED.md # ✅ Current - anti-parroting humanized
│   ├── khaled-v7-DEPLOYED.md    # English reference version
│   ├── nouf-v7-final-DEPLOYED.md # ✅ Current - QA approved
│   ├── nouf-v7-ar-DEPLOYED.md   # Arabic version
│   ├── maryam-v6.8-DEPLOYED.md  # Archive (v6.8)
│   └── nouf-v6.8-DEPLOYED.md    # Archive (v6.8)
├── scripts/                   # Automation scripts
│   ├── create_v7_agents.py      # ✅ Current
│   ├── update_v6.8_prompts.py   # Migration helper
│   └── realtime_audio_processor.py
├── tests/
│   └── qa_scripts/           # QA test cases
│       └── karim_onboarding.json
├── test-results/             # Test output
│   ├── v6.8/                 # Archive
│   └── v6.7/                 # Archive
├── docs/                     # Documentation
│   ├── v7-status-and-results.md    # ✅ Current status
│   ├── pre-production-checklist-v7.md # Verification checklist
│   ├── elevenlabs-2026-research.md # Platform research
│   └── v6.8-status-and-results.md  # Archive
└── braintrust-testing/        # Evaluation framework
    ├── elevenlabs_caller.py
    ├── honest_analyzer.py
    ├── honest_scorers.py
    └── run_evaluation.py
```

### v7 Prompts

**Khaled v7.4**: 7959 chars — anti-parroting design with guidelines instead of exact quotes
**Nouf v7 Final**: QA approved — Gemini 2.5 Flash optimized

---

## Key Technical Details

### ElevenLabs API
- Base URL: `https://api.elevenlabs.io/v1`
- WebSocket: `wss://api.elevenlabs.io/v1/convai/conversation`
- Auth: `xi-api-key` header
- API Key: In `.env` as `ELEVENLABS_API_KEY`

### Voice IDs
- Khaled: `oUCSlKjkoFDoKamPHpAV` (Custom male Gulf)
- Nouf: `4wf10lgibMnboGJGCLrP` (Custom female)
- Maryam: `a1KZUXKFVFDOb33I1uqr` (Salma Dubai)

### Safety Blocking
New agents may be auto-blocked if prompt contains sensitive content.
**Workaround**: Use v6.5.3 prompt structure as base.
See `docs/v6.7-status-and-next-steps.md` for details.

---

## Critical Rules

### DO NOT
- Create new prompts from scratch (use v6.5.3 base to avoid blocking)
- Use exact-quote examples in prompts (causes parroting — use guidelines instead)
- Use response-by-response opening scripts ("رد 1: X بس" kills personality)
- Use FFmpeg atempo for slowdown (destroys rhythm — use native ElevenLabs speed)
- Use Arabic spelling for brand names (use English: "Seekapa" not "سيكابا")
- Push to GitHub (use Azure DevOps only)

### ALWAYS
- Check `is_blocked_ivc` status after creation
- Spell out numbers in Arabic ("خمس مية" not "500", add "دولار" after prices)
- Use comma pauses before brand names ("الفريق، من Seekapa")
- A/B test 3 variations before committing to settings
- Wait 30-60s after PATCH for ElevenLabs propagation before testing
- Document changes in relevant markdown files

### Voice Tuning Cheat Sheet
```
Humanization levers (apply together):
  Temperature: 0.5-0.7 (higher = more varied phrasing)
  Stability: 0.35-0.45 (lower = more vocal range)
  Prompt: Guidelines not exact quotes + anti-parroting instruction

Clean audio:
  similarity_boost: 0.75-0.80 (higher = less background noise)
  style: 0.35-0.40 (amplifies personality)
  speed: 0.92-1.0 native (NEVER FFmpeg post-processing)
```

---

## API Examples

### List Agents
```python
import requests
headers = {'xi-api-key': API_KEY}
resp = requests.get('https://api.elevenlabs.io/v1/convai/agents', headers=headers)
```

### Get Agent Details
```python
resp = requests.get(f'https://api.elevenlabs.io/v1/convai/agents/{agent_id}', headers=headers)
```

### Update Agent
```python
resp = requests.patch(f'https://api.elevenlabs.io/v1/convai/agents/{agent_id}',
    headers={**headers, 'Content-Type': 'application/json'},
    json={'conversation_config': {...}}
)
```

---

## Testing

### A2A Test
```bash
python3 scripts/test_v6.8_a2a.py
```

Tests:
- Latency per turn (target: <1500ms)
- Gender addressing (plural forms)
- Persona timeline ("اليوم" vs "الأسبوع اللي فات")
- App knowledge (should not ask how to open)

### Manual Test URLs (v7 — Current)
- [Khaled v7.4](https://elevenlabs.io/app/talk-to?agent_id=agent_3201kgf1m5q0fkvazvfxqsdg1x5c) **AWAITING QA**
- [Nouf v7 Final](https://elevenlabs.io/app/talk-to?agent_id=agent_2901kgespgzqf6eb3724ftfg4yvr) **QA APPROVED**

### Manual Test URLs (v6.8 — Archive)
- [Maryam-Claude](https://elevenlabs.io/app/talk-to?agent_id=agent_9901kfae5g8he788z86ve0p4bp2g)
- [Nouf-Claude](https://elevenlabs.io/app/talk-to?agent_id=agent_6201kfae5hgze9ws5f4sj5jkrdym)

---

## Related Memory Entities

Query memory for:
- `sales-agents-session-20260202-khaled-v74` - Khaled v7.4 humanization session
- `sales-agents-khaled-v74-settings` - Exact agent settings (recreatable)
- `elevenlabs-voice-agent-tuning-playbook` - Reusable tuning methodology
- `sales-agents-v6.8` - Previous v6.8 project status
- `gender-addressing-fix` - Cultural validation research
- `elevenlabs-safety-blocking` - Blocking workarounds
