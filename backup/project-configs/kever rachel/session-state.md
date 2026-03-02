# Kever Rachel - Session State (2026-02-02)

## Project: Arabic Sales Audio Recordings (8 files)
Voice: Farah (ID: 4wf10lgibMnboGJGCLrP) | Model: eleven_multilingual_v2

## ElevenLabs Voice Settings (PROVEN)

### Warm Voice (approved by QA - Variation A)
```python
VOICE_SETTINGS = {
    "stability": 0.35,
    "similarity_boost": 0.70,
    "style": 0.40,
    "use_speaker_boost": True,
    "speed": 0.94
}
```

### Clean Audio (for scripts with background noise issues)
```python
VOICE_SETTINGS_CLEAN = {
    "stability": 0.40,
    "similarity_boost": 0.80,
    "style": 0.35,
    "use_speaker_boost": True,
    "speed": 0.94
}
```

## API Key Location
`~/projects/sales-agents/.env` → ELEVENLABS_API_KEY

## Brand Name Rule
ALWAYS write "Seekapa" in English (Latin) letters inside Arabic text.
NEVER use Arabic spelling سِيكَابَا — it gets swallowed by TTS.
Use comma pause: "معك الفريق، من Seekapa"

## Number Rules
- Spell out years: "ألفين وستة وعشرين" not "2026"
- Always add "دولار" after price: "ستة آلاف دولار" not "ستة آلاف"

## File Locations
- **Final audio**: `/home/odedbe/projects/kever rachel/final_audio/` (8 files)
- **Test variations**: `/home/odedbe/projects/kever rachel/test_variations/`
- **Backup (old robotic 0.83x)**: `/home/odedbe/projects/kever rachel/final_audio_083x_backup/`
- **Original warm source**: `/home/odedbe/projects/kever rachel/temp_audio/`

## Current Status of Each Script

### v1_gold_opportunity — APPROVED
- **Style**: Rhetorical question with real BofA $6K target
- **Duration**: 34.5s
- **Script**: Bank of America targets $6K gold, currently above $4K dollar, will it reach 6 or 8 thousand dollars?
- **Settings**: Warm voice + English Seekapa + spelled out year + دولار after prices
- **Final script text**:
```
ألو، كيفك؟ معك الفريق من Seekapa.
أنت تداولت معنا قبل، ولازم تسمع هالمعلومة:
بنك أوف أمريكا حطّ هدف للذهب ستة آلاف دولار للأونصة بسنة ألفين وستة وعشرين.
هلأ الذهب فوق أربع آلاف دولار... السؤال: رح يوصل لستة آلاف دولار؟ ولا ممكن يروح لثمانية آلاف دولار؟
اللي بيستغل الموجة هلأ—هو اللي بيربح.
مع Seekapa، عندك أدوات ذكاء اصطناعي وإشارات تداول دقيقة تساعدك تقرر.
ادخل حسابك بـ Seekapa هلأ—وشوف وين الذهب رايح.
تنبيه: التداول ينطوي على مخاطر.
```

### v2_us_market — NEEDS REVIEW (user hasn't given feedback yet)
- **Style**: Original script with "فريق من" fix + English Seekapa
- **Duration**: 29.2s
- **Settings**: Warm voice

### v3_crypto — APPROVED
- **Style**: Buy-the-dip with real data (BTC dropped from 120K to 80K = 35% discount)
- **Duration**: 38.1s
- **Script**: JPMorgan/BlackRock say heading to $170K+. "Do you buy now at 80 or wait until 120?"
- **Settings**: Warm voice + English Seekapa + comma pause
- **Final script text**:
```
ألو، كيفك؟ معك الفريق، من Seekapa.
أنت تداولت معنا قبل على الكريبتو، وهلأ في فرصة ما بتتكرر.
البيتكوين نزل من مية وعشرين ألف لتحت الثمانين—يعني خصم خمسة وتلاتين بالمية.
كل المحللين الكبار—جي بي مورغان، بلاك روك—عم يقولوا إنو رايح على مية وسبعين ألف وأكتر.
السؤال: إنت بتشتري هلأ بثمانين... ولا بتستنى لما يرجع على مية وعشرين؟
مع Seekapa، أدوات ذكاء اصطناعي وإشارات تداول تساعدك تقرر بالوقت المناسب.
ادخل حسابك بـ Seekapa هلأ—هالأسعار ما بتدوم.
تنبيه: التداول ينطوي على مخاطر.
```

### v4_seasonal (Ramadan) — IN A/B TESTING (3 variations)
- User requested: blessed month to take care of family, gold & oil historic prices (not silver)
- 3 versions in test_variations/:
  - **v4_A_blessing_family.mp3** (29.2s) — "God opened doors of rizq"
  - **v4_B_historic_opportunity.mp3** (30.5s) — "opportunity that doesn't come every day"
  - **v4_C_gentle_caring.mp3** (32.6s) — "you always think about your family"
- Settings: Clean audio (stability=0.40, similarity=0.80, style=0.35)
- **WAITING FOR USER CHOICE (A, B, or C)**

### v5_return_bonus — NEEDS REVIEW (user hasn't given feedback yet)
- **Style**: Original with "فريق من" fix + English Seekapa
- **Duration**: 26.0s
- **Settings**: Warm voice

### v6_vip_market — NEEDS REVIEW (user hasn't given feedback yet)
- **Style**: Original with "فريق من" fix + English Seekapa
- **Duration**: 28.4s
- **Settings**: Warm voice

### Recovery_1_Crypto — NEEDS REVIEW (user hasn't given feedback yet)
- **Duration**: 26.1s
- **Settings**: Warm voice

### Recovery_2_VIP — NEEDS REVIEW (user hasn't given feedback yet)
- **Duration**: 25.0s
- **Settings**: Warm voice

## Scripts Still Using Original Content (may need creative rewrite like v1/v3/v4)
- v2_us_market — US stocks/tech surge
- v5_return_bonus — special return bonus offer
- v6_vip_market — VIP comeback + market hook
- Recovery_1_Crypto — crypto opportunity (still uses old "ATH" angle, may need buy-the-dip like v3)
- Recovery_2_VIP — VIP return with bonuses

## Generation Command Template
```python
import os, requests
from pathlib import Path
from dotenv import load_dotenv
load_dotenv(os.path.expanduser('~/projects/sales-agents/.env'))
API_KEY = os.getenv('ELEVENLABS_API_KEY')
FARAH_VOICE_ID = '4wf10lgibMnboGJGCLrP'

url = f'https://api.elevenlabs.io/v1/text-to-speech/{FARAH_VOICE_ID}'
headers = {'xi-api-key': API_KEY, 'Content-Type': 'application/json'}
payload = {
    'text': TEXT_HERE,
    'model_id': 'eleven_multilingual_v2',
    'voice_settings': {
        'stability': 0.35,       # or 0.40 for cleaner
        'similarity_boost': 0.70, # or 0.80 for cleaner
        'style': 0.40,           # or 0.35 for cleaner
        'use_speaker_boost': True,
        'speed': 0.94
    }
}
response = requests.post(url, json=payload, headers=headers)
Path('final_audio/FILENAME.mp3').write_bytes(response.content)
```

## Key Learnings (persisted to Memory MCP)
- NEVER use FFmpeg for slowdown — native speed only
- NEVER use Arabic spelling for brand names — English in multilingual v2
- A/B test 3 variations before full batch
- Real analyst data + rhetorical questions = engaging scripts
- stability > 0.50 = robotic; style > 0.50 = noisy
- similarity_boost 0.80 = cleaner audio
