# Kever Rachel — Project Memory

## Project Overview
IVR audio generation for Seekapa and Axia trading brands. Arabic scripts generated via ElevenLabs API.

## Key Parameters
- **Speed**: 0.85 (latest, changed from 0.94 in activation scripts)
- **Model**: eleven_multilingual_v2
- **Voice Settings**: stability=0.40, similarity=0.80, style=0.35, speaker_boost=True
- **Voices**: Farah (4wf10lgibMnboGJGCLrP), Salma/Nouf (a1KZUXKFVFDOb33I1uqr)
- **API Key**: from ~/projects/sales-agents/.env (ELEVENLABS_API_KEY)

## Brand Rules
- **Seekapa**: 2 voices (Farah + Salma-Nouf), activation/retention angle
- **Axia**: Farah only, funded account/recovery angle

## Script Sets Generated
| Set | Directory | Files | Context |
|-----|-----------|-------|---------|
| Ramadan V3 | ramadan_v3/ | 12 | Ramadan + blessings, speed 0.90 |
| Axia Ramadan | axia_ramadan/ | 4 | Axia + Ramadan + funded account, speed 0.94 |
| War + Markets | war_markets/ | 6 | War + Ramadan + oil/gas, speed 0.94, both brands |
| Activation V2 | ramadan_activation_v2/ | 12 | Seekapa activation, V1(50% discount) + V2(general), speed 0.85 |
| Post-Ramadan | post_ramadan/ | 16 | War continues, NO Ramadan refs, speed 0.85, both brands |
| Markets Only | markets_only/ | 16 | NO Ramadan NO war, volatile markets only, speed 0.85, both brands |
| Crazy Funded | crazy_funded/ | 12 | Ramadan + War + Funded account + 200%+ profits, speed 0.85, both brands, WILD energy |

## 3-Set Deployment Sequence
1. **ramadan_activation_v2/** — During Ramadan (current)
2. **post_ramadan/** — After Ramadan if war continues
3. **markets_only/** — General use, no time-specific context

## Script Structure
- Seekapa: V1 (50% discount, 250 EUR) + V2 (general promotions), 3 variations each (A/B/C)
- Axia: 4 scripts (A: funded, B: market action, C: caring family, D: mabruk deposit)

## Crazy Funded Script Structure (2026-03-08)
- **Based on**: Original reference recording ("alf mabruk, deposited in your account, 200%+ profits")
- **Request**: Account funded + Ramadan Kareem + War + "take it to crazy places"
- **Seekapa**: 4 scripts (A: alo mabruk, B: war urgency, C: gold+family, D: sunday explosion) x 2 voices = 8
- **Axia**: 4 scripts (A: mabruk+war, B: recover+gold, C: family+war, D: breaking news) x Farah = 4
- **Key elements**: ألف مبروك, حرب, أرباح 200%+, رمضان كريم, انفجار, فرصة العمر, مجنون

## Audio Transcription Technique
- Gemini API via Python (`google.generativeai`) can transcribe m4a audio files
- Use `genai.upload_file()` then `model.generate_content()` with audio + transcription prompt
- Working API key: hey-seven project's GOOGLE_API_KEY

## Arabic Text Adaptations (for reference)
- War line replacements (markets_only): الحرب بالأسواق → الأسواق عم تتحرك
- Ramadan removals: رمضان كريم, بمناسبة رمضان, بهالشهر المبارك, هالفرصة المباركة
