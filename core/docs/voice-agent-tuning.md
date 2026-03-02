# Voice Agent Tuning Rules

## ElevenLabs Conversational AI

### Prompt Design
- NEVER use exact-quote examples — LLM will parrot them verbatim
- NEVER use response-by-response scripts — LLM takes "just say X" literally
- Use guideline descriptions: "when someone greets, return greeting and ask who's calling"
- Add anti-parroting instruction: "examples are ideas, not text to copy"
- Add hesitation markers for naturalness: "آآه...", "يعني...", "والله..."

### Three-Lever Humanization
| Lever | Robotic | Natural | Too Noisy |
|-------|---------|---------|-----------|
| Temperature | <0.4 | 0.5-0.7 | >0.8 |
| Stability | >0.55 | 0.40-0.50 | <0.35 |
| Style | 0.0 | 0.35-0.40 | >0.50 |

### Arabic TTS Specifics
- Spell out ALL numbers: "خمس مية" not "500", "ألفين وستة وعشرين" not "2026"
- Brand names in ENGLISH letters: "Seekapa" not "سيكابا" (diacritics swallowed by TTS)
- Add comma before brand name for pause: "الفريق، من Seekapa"
- Add "دولار" after every price mention
- max_tokens: 150 for Arabic conversations (prevents info-dumping)

### Settings Cheat Sheet
| Setting | Clean Audio | Warm Conversational | V7 Lowest Latency |
|---------|-------------|---------------------|-------------------|
| Model | eleven_turbo_v2_5 | eleven_multilingual_v2 | eleven_flash_v2_5 |
| Stability | 0.40 | 0.35-0.40 | 0.65-0.67 |
| Similarity | 0.80 | 0.70-0.75 | 0.65-0.70 |
| Style | 0.35 | 0.35-0.40 | 0.0 |
| Speed | 1.0 | 0.92-0.95 | 1.01-1.02 |
| Speaker Boost | true | true | true |
| Streaming Latency | 2 | 2 | 3 |
| Turn Timeout | 15s | 15s | 1s |
| Turn Eagerness | patient | patient | eager |
| Speculative Turn | false | false | true |

### V7 "Lowest Latency" Profile (2026-02-05)

**Use for fast-paced conversations where responsiveness beats naturalness.**
Tested on Abu Faisal + Al Anoud retention agents.

```
TTS Model: eleven_flash_v2_5 (fastest, ~100ms first-byte)
stability: 0.65-0.67 (higher for consistent output)
similarity_boost: 0.65-0.70
speed: 1.01-1.02 (slightly faster)
style: 0.0 (prompt handles emotion)
optimize_streaming_latency: 3 (aggressive)

Turn timeout: 1.0s (ultra-responsive)
Turn eagerness: eager (jump in quickly)
Speculative turn: true (predict when user stops)
turn_model: turn_v2 (latest)

LLM: gemini-2.5-flash
Temperature: 0.3
max_tokens: 140 (short responses)
thinking_budget: 0 (no reasoning delay)
ignore_default_personality: true

Audio Tags (for emotional cues):
- "Angry": when speak about losing money
- "Concerned": when speaking on adding more funds
```

**Trade-offs:**
- PRO: Near-instant responses, great for Arabic retention scenarios
- CON: May interrupt user more, less "patient listener" feel
- Use for: Retention agents, fast-paced objection handling
- Avoid for: Empathy-heavy, first-contact situations

### Full Agent Settings Reference (2026 Optimal for Arabic)

**MANDATORY for every new agent** — copy this block as baseline:

```
LLM: gemini-2.5-flash (ElevenLabs recommended, fast, 1M context)
Temperature: 0.3 (voice agents need consistency)
reasoning_effort: OMIT for gemini models (returns 422 "not supported")
thinking_budget: null (disabled — no reasoning delay for voice)
ignore_default_personality: true (ALWAYS — default personality is Western-centric)
max_tokens: -1 (unlimited)

TTS Model: eleven_turbo_v2_5 (stable, Arabic-optimized; v3 is alpha)
agent_output_audio_format: pcm_16000
stability: 0.35
similarity_boost: 0.65
speed: 1.0
style: 0.0 (let prompt handle emotion)
optimize_streaming_latency: 2 (balanced; 0=quality, 4=fastest, avoid 4 for Arabic)

ASR Provider: elevenlabs (uses Scribe v2 — best Arabic WER)
ASR Quality: high
user_input_audio_format: pcm_16000
ASR language field: IGNORED by elevenlabs provider — use agent.language instead

Turn timeout: 15s (patient for real conversations)
Turn eagerness: patient
speculative_turn: false (unreliable for Arabic turn-taking patterns)
background_voice_detection: true

Max duration: 1500s (25 min buffer for 15-20 min calls)
```

**Settings that DON'T persist on create (must PATCH after):**
- `ASR language` — always returns None with elevenlabs provider; irrelevant
- `optimize_streaming_latency` — may default to 3 instead of 2; verify with GET

**Settings NOT to touch:**
- `model_family` — not exposed in current API
- `limit_token_usage_predict` — not available for convai agents
- `use_scribe` — implicit when provider=elevenlabs

**Convai TTS field limitations (2026-02-16):**
- PATCH-able: `voice_id`, `model_id`, `stability`, `similarity_boost`, `speed`, `optimize_streaming_latency`
- NOT supported (return None silently): `style`, `use_speaker_boost`
- Always verify with GET after PATCH

### Anti-Loop Prompt Rule (MANDATORY for retention agents)

Add to Section 0 of every retention agent prompt:
```
لا تكرر نفس السؤال أكثر من مرتين. إذا ما جاوب — انتقل لموضوع ثاني أو وافق بشرط.
```
Without this, hidden goal sections (e.g., "wants proof before commitment") create infinite topic fixation loops where the agent keeps asking the same question.

### Gender-Voice Matching (MANDATORY before QA)

ALWAYS verify voice gender matches prompt conjugation BEFORE deployment.
If mismatch found: swap voice (1 API call) rather than rewrite prompt.
Arabic prompts use gendered conjugation throughout — rewriting is hundreds of edits with high regression risk.

### Persona Design: Call-Receiving Pattern

**Retention agents receive calls, they don't initiate them.**
- `first_message`: Just `"ألو؟"` — no name, no introduction
- Prompt must include a pre-Section-0 block explaining:
  1. Agent picks up phone not knowing who's calling
  2. "ألو؟" → rep introduces → agent slowly recognizes company
  3. First 2 minutes: guarded, short answers ("إيه", "لا", "وش تبون؟")
  4. Progressive warmup ONLY if rep asks good questions
- NEVER have retention agents introduce themselves — they're being called

### 12-Section Prompt Structure (Retention Agents)

```
Section 0: Core speech/identity rules (short responses, no echoing)
Section 1: Visible goal (what they say after recognizing the company)
Section 2: Hidden goal (real emotional need — revealed after good questions)
Section 3: Trading background (specific numbers, specific losses)
Section 4: 4-layer progressive revelation (Hidden Pain-Point Ladder)
Section 5: Real objections with emotional subtext (one per turn, 8+)
Section 6: Rep tests (how agent reacts to good/bad handling)
Section 7: Vocal artifacts (SSML <break time="X.Xs"/> ONLY, no Arabic cues)
Section 8: Dialect & speech patterns (Najdi vs Hijazi specifics)
Section 9: Endings (retain/hesitant/loss with specific deposit amounts)
Section 10: NEVER REVEAL (anti-AI-disclosure)
Section 11: Personal details (names, stories, specific background)
```

### SSML Rules for Arabic Voice Agents
- Use `<break time="X.Xs"/>` for ALL pauses — NEVER use Arabic action cues like `[وقفة]`
- Emotional moments: 1.0-1.5s breaks
- Thinking pauses: 0.5-0.8s breaks
- Frustration/tension: 0.3s break (short, sharp)
- ElevenLabs TTS respects SSML breaks in system prompts

### Integration Rules
- After PATCH to agent config: wait 30-60s before testing (propagation delay)
- `reasoning_effort` not supported on gemini models or gpt-5-mini — omit parameter entirely
- NEVER use FFmpeg `atempo` for slowdown — use native ElevenLabs `speed` parameter
- Webhook JSON: add parsing instructions in BOTH tool description AND system prompt
- One change per test call to isolate cause-effect
- When creating agents via API (POST /convai/agents/create): verify all settings with GET after creation — some fields (streaming_latency, VAD) may not take on first create
- ASR keywords: 25+ per agent (shared domain terms + persona-specific names/terms)
