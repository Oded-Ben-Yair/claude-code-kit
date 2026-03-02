# QC Call Analyzer - Project Configuration

---

## Persona (Auto-Activated)

You are a **QA Architect and Senior Developer** working on a PRODUCTION call quality analysis system. You automatically:
- Prioritize test coverage and regression prevention
- Consider security and data privacy (call recordings are sensitive PII)
- Think about performance under load
- Maintain audit trails for compliance
- Plan for zero-downtime deployments

---

## Routing (Auto-Select)

| Task | Route To |
|------|----------|
| Code review/generation | Codex Max (`azure_code_review`) |
| Test generation | Codex Max with coverage focus |
| Architecture decisions | `multi-model-debate` |
| Performance analysis | Grok-4 (`azure_reason`) |
| Security review | Codex Max with security focus |

---

## Output Format (Auto-Apply)

- Code reviews: summary → critical issues → suggestions → verdict
- Bug fixes: Include root cause analysis
- PRs: Include risk assessment and rollback plan
- API changes: Document breaking changes explicitly

---

## ⚠️ PRODUCTION APPLICATION - HANDLE WITH CARE ⚠️

**Status**: ✅ PRODUCTION (V2 Live since December 4, 2025)
**Live URL**: https://icy-coast-0265d5310.3.azurestaticapps.net/

This application is **actively used in production**. Before making ANY changes:
1. Understand the impact on production users
2. Test locally first (`func start`)
3. Never modify database schema without migration scripts
4. Never delete data without explicit user confirmation

### FPF-Lite: Production Mode Active

This project runs in **production mode** for FPF-Lite reasoning:
- **Always trigger** hypothesis generation for any code change
- **Auto-escalate** to deep analysis for: auth, database, API changes
- **Require explicit confirmation** before implementing any approach
- **Memory namespace**: `[qc-call-analyzer]` for all persisted decisions
- Consider `multi-model-debate` for critical infrastructure changes

---

## 🚫 DO NOT MODIFY - PROTECTED RESOURCES

### Database (ISOLATED - qc_analyzer ONLY)
| Resource | Value | Protection |
|----------|-------|------------|
| **Database** | `qc_analyzer` | ❌ DO NOT access other databases |
| **User** | `qc_app_user` | ❌ DO NOT use `seekapaadmin` |
| **Host** | `postgres-seekapatraining-prod.postgres.database.azure.com` | Shared server - other apps use it! |

**Other databases on same server (DO NOT TOUCH):**
- `seekapa_training` (Training Platform)
- `polymarket_analyzer` (Sentimark)
- `axia_seekapa_chatbot` (Chatbot)
- `seekapa_workspace` (CRM)

### Azure Resources (THIS PROJECT ONLY)
| Resource | Name | ❌ DO NOT |
|----------|------|-----------|
| Function App | `func-qc-analyzer-prod` | Delete, rename, or modify app settings without backup |
| Storage Account | `stqccallanalyzer` | Delete blobs in `calls` container |
| Static Web App | `icy-coast-0265d5310` | Modify deployment settings |
| Blob Container | `qc-transcripts` | Delete audio files or transcripts |

### Files with Secrets (NEVER COMMIT)
- `.env` - Local environment variables
- `local.settings.json` - Azure Functions local config
- Any file containing API keys, passwords, or connection strings

### Critical Production Tables
```sql
-- DO NOT DROP OR TRUNCATE:
calls              -- 28+ processed calls with transcripts
call_notes         -- User notes on calls
call_analyses      -- AI analysis results
teams              -- Team configuration
```

---

## 🔒 Database Isolation Rules

1. **ONLY use `qc_app_user`** - Never `seekapaadmin` in application code
2. **ONLY access `qc_analyzer` database** - User cannot access other databases
3. **ALWAYS use migrations** - Never run raw ALTER/DROP on production
4. **BACKUP before schema changes** - `pg_dump qc_analyzer > backup.sql`

### Safe Database Operations
```bash
# Connect to QC Analyzer database ONLY
psql "postgresql://qc_app_user:REDACTED@postgres-seekapatraining-prod.postgres.database.azure.com:5432/qc_analyzer?sslmode=require"

# Verify you're in the right database
SELECT current_database();  -- Must show: qc_analyzer
SELECT current_user;        -- Must show: qc_app_user
```

### Dangerous Operations (REQUIRE EXPLICIT USER CONFIRMATION)
- `DROP TABLE` - Never without backup
- `TRUNCATE` - Never on production data
- `DELETE FROM calls` - Never without WHERE clause
- `ALTER TABLE ... DROP COLUMN` - Always create migration first

---

## Plan Storage

**Plans location:** `.claude/plans/` (this project's directory)
- Format: `YYYY-MM-DD-<feature-name>.md`
- NEVER save to global `~/.claude/plans/`

---

## Project Overview

**Q.C (Quality Control)** - Arabic sales call analysis system with two components:
1. **Audio Pipeline**: MP3 → Clean (ElevenLabs) → Transcribe (ElevenLabs Scribe/Azure Whisper) → Translate (GPT-5)
2. **Q.C Chat**: React UI + Azure Functions API for sales managers to query processed calls

**Target**: 95%+ transcription accuracy (WER < 5%)

## Development Commands

### Python Backend (root + src/api)
```bash
# Set up environment
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# Run CLI pipeline (local testing)
python src/main.py --input tests/samples/call_short.mp3 --output output/
python src/main.py --input <file> --skip-clean    # Skip audio cleaning
python src/main.py --input <file> --skip-translate # Transcription only

# Run tests
pytest tests/
pytest tests/test_transcription.py -v  # Single test file

# Code quality
black src/ config/
isort src/ config/
flake8 src/
mypy src/
```

### Azure Functions API (src/api/)
```bash
cd src/api
pip install -r requirements.txt
func start  # Requires Azure Functions Core Tools
```

### React Frontend (src/ui/)
```bash
cd src/ui
npm install
npm run dev      # Development server
npm run build    # Production build
npm run lint     # ESLint
```

## Architecture

### Processing Pipeline Flow (V4.3 - Current)
```
Input MP3 → AudioCleaner (ElevenLabs Voice Isolator)
         → STT (ElevenLabs Scribe primary, Azure Whisper fallback)
         → [Gemini Cleanup] (fix false starts, punctuation, dialects)
         → Translation V4.3 (GPT-5: Arabic → Hebrew + English)
            ├── Dialect-aware prompts
            ├── Meta-commentary stripping ("Got it" / "הבנתי" removed)
            ├── Timestamp newline enforcement
            └── Script Guard (zero Arabic Unicode leakage)
         → Output: JSON with transcript, translations, speaker diarization
```

**V4.3 Translation Features:**
- `use_enhanced=True` (default) enables full V4.3 pipeline
- System prompt prevents LLM preamble pollution
- `_strip_meta_commentary()` post-processing removes any remaining artifacts
- `_enforce_timestamp_newlines()` ensures readable speaker formatting

### Key Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `QCPipeline` | `src/main.py` | CLI orchestrator for local processing |
| `AudioCleaner` | `src/audio/cleaner.py` | ElevenLabs noise removal + ffmpeg compression |
| `ArabicSTTService` | `src/transcription/stt_service.py` | Azure Whisper integration |
| `ElevenLabsSTT` | `src/api/shared/elevenlabs_stt.py` | Primary STT (11% WER vs Whisper's 36%) |
| `ProcessingService` | `src/api/shared/processing_service.py` | Azure Functions processing pipeline |
| `function_app.py` | `src/api/function_app.py` | Azure Functions HTTP endpoints |
| `ChatService` | `src/api/shared/chat_service.py` | Multi-LLM chat with cost cascading |

### API Endpoints (Azure Functions)
- `GET /api/health` - Health check
- `GET /api/calls` - List processed calls
- `POST /api/calls/upload` - Upload MP3 for processing
- `POST /api/calls/{id}/process` - Trigger processing
- `POST /api/chat` - Query call with AI (cost-cascading: GPT-5 → GPT-5-Pro → Gemini)
- `GET /api/analytics` - Dashboard stats

## Environment Variables

Required in `.env`:
```bash
ELEVENLABS_API_KEY=       # Audio cleaning + primary STT
AZURE_OPENAI_ENDPOINT=    # GPT-5 translation + Whisper fallback
AZURE_OPENAI_KEY=
DATABASE_URL=             # PostgreSQL (API only)
AZURE_STORAGE_CONNECTION_STRING=  # Blob storage (API only)
```

## Arabic Dialect Handling

The system handles two dialects in calls:
- **Israeli Arabic** (Sales Rep): Levantine base with Hebrew loanwords
- **Khaleeji/Gulf Arabic** (Clients): GCC vocabulary, different pronunciation

Strategy: ElevenLabs Scribe with `language_code="ar"` + context-aware GPT translation prompts.

## Critical Notes

1. **STT Priority**: ElevenLabs Scribe (11% WER) → Azure Whisper (36% WER) fallback
2. **File Size Limit**: Azure Whisper max 25MB; AudioCleaner auto-compresses larger files
3. **Long Audio**: Files >10 min are auto-chunked at silence points (`AudioChunker`)
4. **Translation**: Always translates Arabic→Hebrew AND Arabic→English (for international review)
5. **Speaker Diarization**: Only available with ElevenLabs STT path

---

## Recent Improvements (Dec 2025)

### P0 Critical Fixes (Completed)
| Fix | File | Status |
|-----|------|--------|
| Retry logic (3x exponential backoff) | `processing_service.py` | ✅ |
| Duration validation (92% threshold) | `processing_service.py` | ✅ |
| Bitrate 64k→128k (preserves Arabic phonemes) | `audio_chunker.py`, `cleaner.py` | ✅ |
| Quality metrics tracking | `processing_service.py` | ✅ |

### P1 Improvements (Completed)
| Improvement | File | Status |
|-------------|------|--------|
| ElevenLabs Scribe in CLI (primary STT) | `stt_service.py` | ✅ |
| Whisper dialect prompts | `stt_service.py`, `processing_service.py` | ✅ |
| Hebrew loanword vocabulary | `config/hebrew_loanwords.json` | ✅ |
| Enhanced translation prompts | `translator.py` | ✅ |

### P2 Optimizations (Dec 2025)

**Goal**: Improve WER from 11% to <5%

| Phase | Optimization | Expected WER | Status |
|-------|-------------|--------------|--------|
| P2.1 | Lossless Audio (FLAC) | 11% → 7-9% | **COMPLETED** |
| P2.2 | Cascading Ensemble STT | 7-9% → 5-6% | **COMPLETED** |
| P2.3 | Dialect-Aware Processing | 5-6% → <5% | **COMPLETED** |

**Detailed Plan**: `~/.claude/plans/smooth-watching-platypus.md`

#### P2.1 Completed (Dec 2, 2025)
- `src/audio/cleaner.py` - FLAC output support with `output_format` param
- `src/api/shared/audio_chunker.py` - FLAC chunk export + format detection
- `src/api/shared/elevenlabs_stt.py` - FLAC MIME auto-detection
- `src/api/shared/processing_service.py` - Format propagation + FLAC conversion
- `src/main.py` - CLI `--format` option (default: flac)
- `tests/test_flac_ab.py` - LLM Judge A/B test script

#### P2.2 Completed (Dec 2, 2025)
- `src/api/shared/confidence_scorer.py` - Segment confidence scoring
- `src/api/shared/ensemble_stt.py` - Cascading ensemble orchestrator
- `src/api/shared/transcript_merger.py` - LLM-based transcript merging
- `src/api/shared/processing_service.py` - Integrated ensemble with `use_ensemble` param

#### P2.3 Completed (Dec 2, 2025)
- `src/api/shared/dialect_id.py` - Per-speaker dialect identification (Levantine/Gulf/MSA)
- `src/api/shared/dialect_processors.py` - Dialect-specific text corrections
- `config/hebrew_loanwords.json` - Enhanced with phonetic variants (v2.0)
- `src/api/shared/processing_service.py` - Integrated dialect processing with `use_dialect_processing` param

### Implementation Roadmap
See: `docs/ARABIC_STT_IMPROVEMENT_ROADMAP.md`

### Test Results Summary
- **Before**: Whisper hallucination (repetitive fake text)
- **After**: Clean transcripts with ElevenLabs Scribe (11% WER)
- **Current WER**: <5% (target achieved with P2 optimizations)
- **P2 Stack**: FLAC audio + Ensemble STT + Dialect Processing

---

## Production Deployment (Dec 3, 2025)

### Live URLs
| Component | URL |
|-----------|-----|
| **Frontend** | https://icy-coast-0265d5310.3.azurestaticapps.net/ |
| **API** | https://func-qc-analyzer-prod.azurewebsites.net/api |

### Azure Resources
| Resource | Name | Details |
|----------|------|---------|
| Function App | `func-qc-analyzer-prod` | Consumption Plan, Python 3.11 |
| Storage | `stqccallanalyzer` | Blob containers: `calls` |
| OpenAI | `brn-azai` | Model: `gpt-5-chat` (swedencentral) |
| PostgreSQL | `postgres-seekapatraining-prod` | Database: `qc_analyzer`, User: `qc_app_user` |

### Durable Functions Architecture (V4.3 - Jan 2026)
Supports files up to 2+ hours without hitting Consumption plan timeout.
No ffmpeg required - uses pure Python (mutagen) for audio processing.

```
Orchestrator: process_call_orchestrator (V4.3)
├── Activity 1: activity_prepare_audio (~1-2 min)
│   ├── Generate SAS URL for ElevenLabs direct fetch
│   ├── Detect duration with mutagen (no ffmpeg!)
│   └── Chunk if > 55 minutes
├── Activity 2a: activity_transcribe_audio (single file < 55 min)
│   └── URL-based transcription (ElevenLabs fetches from Azure)
├── Activity 2b: activity_transcribe_chunk × N (parallel, for > 55 min)
│   └── Fan-out: Process 45-min chunks in parallel
├── Activity 3: activity_merge_transcripts (if chunked)
│   └── Fan-in: Gemini intelligent sentence-boundary merge
├── Activity 4: activity_cleanup_transcript (P2.6)
│   └── Gemini post-processing: false starts, punctuation, dialects
├── Activity 5: activity_translate_text (V4.3 Enhanced)
│   ├── Dialect-aware prompts (Levantine/Gulf detection)
│   ├── Chunked translation for long transcripts (>8000 chars)
│   ├── Meta-commentary stripping
│   ├── Timestamp newline enforcement
│   └── Script Guard (zero Arabic Unicode leakage)
├── Activity 6: activity_save_results (~30 sec)
└── Activity 7: activity_cleanup_chunks (~10 sec)
```

**Key Files:**
- `src/api/shared/durable_processing.py` - Activity functions
- `src/api/shared/audio_utils.py` - Pure Python duration detection & chunking
- `src/api/shared/blob_service.py` - SAS URL generation
- `src/api/function_app.py` - Orchestrator + HTTP triggers

### API Endpoints (Updated)
| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/health` | GET | Health check with DB status |
| `/api/calls` | GET | List all calls |
| `/api/calls/upload` | POST | Upload MP3 for processing |
| `/api/calls/{id}/process` | POST | Start Durable Functions processing |
| `/api/calls/{id}/status` | GET | Get orchestration status |
| `/api/calls/{id}` | GET | Get call details |
| `/api/calls/{id}` | DELETE | Delete call |
| `/api/chat` | POST | AI chat about call content |
| `/api/analytics` | GET | Dashboard statistics |

### Environment Variables (Production)
Stored in Azure Function App Configuration:
```
AZURE_OPENAI_ENDPOINT=https://brn-azai.openai.azure.com/
AZURE_OPENAI_KEY=***
ELEVENLABS_API_KEY=***
GEMINI_API_KEY=***  # P2.5: For transcript post-processing (Google AI)
DATABASE_URL=postgresql://qc_app_user:REDACTED@postgres-seekapatraining-prod.postgres.database.azure.com:5432/qc_analyzer?sslmode=require
AZURE_STORAGE_CONNECTION_STRING=***
```

### Local Development Setup
```bash
cd ~/projects/qc-call-analyzer/src/api
cp local.settings.json.example local.settings.json  # Add your keys
pip install -r requirements.txt
func start  # Run locally on port 7071
```

### Deployment Commands
```bash
cd ~/projects/qc-call-analyzer/src/api
func azure functionapp publish func-qc-analyzer-prod --python
```

### Database Schema
```sql
-- Main table
CREATE TABLE calls (
    id UUID PRIMARY KEY,
    filename VARCHAR(255),
    blob_url TEXT,
    status VARCHAR(50),  -- pending, processing, completed, failed
    duration_seconds INTEGER,
    arabic_transcript TEXT,
    hebrew_translation TEXT,
    english_translation TEXT,
    speakers JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Known Limitations
1. **Consumption Plan**: 10-min timeout per activity (solved with Durable Functions)
2. **GPT-5-chat**: Max 16,384 completion tokens per request (solved with chunked translation)
3. **Azure Queue**: 64KB message limit - use blob references instead of base64 for large payloads

### P2.4 Long Audio Support (Dec 3, 2025) ✅ COMPLETED
Full support for 1+ hour audio files without ffmpeg dependency.

**Solution Architecture:**
- **SAS URLs**: ElevenLabs fetches audio directly from Azure Blob Storage
- **Pure Python**: Duration detection via `mutagen` (no ffmpeg required)
- **URL-based STT**: `transcribe_from_url()` method for efficient large file handling
- **Automatic Chunking**: Files > 55 min split into 45-min chunks
- **Parallel Processing**: Fan-out/fan-in for chunk transcription

**New/Modified Files:**
| File | Changes |
|------|---------|
| `src/api/shared/audio_utils.py` | NEW - Pure Python audio utilities |
| `src/api/shared/blob_service.py` | SAS URL generation, chunk upload/delete |
| `src/api/shared/elevenlabs_stt.py` | URL-based transcription methods |
| `src/api/shared/durable_processing.py` | New activities for chunked processing |
| `src/api/function_app.py` | Updated orchestrator with chunking support |
| `src/api/requirements.txt` | Added `mutagen>=1.47.0` |

**How It Works:**
1. User uploads audio → stored in Azure Blob Storage
2. `activity_prepare_audio`:
   - Downloads file, detects duration with mutagen
   - If < 55 min: generates SAS URL for direct ElevenLabs access
   - If > 55 min: splits into 45-min chunks, uploads chunks, generates SAS URLs
3. `activity_transcribe_audio` or `activity_transcribe_chunk`:
   - Passes SAS URL to ElevenLabs (they fetch directly from Azure)
   - No need to download file to Azure Function memory
4. `activity_merge_transcripts`: Combines chunk results if multiple chunks
5. Translation, save, cleanup as before

**Stashed Solution:**
Previous pydub-based solution is preserved in `git stash@{0}` for reference.
The new mutagen-based solution achieves the same goal without ffmpeg dependency.

### P2.5 Translation Chunking (Dec 3, 2025) ✅ COMPLETED
Fixed translation truncation for long transcripts (>8000 characters).

**Problem:**
- Long transcripts (1+ hour calls) were being truncated because GPT-5 has a 16K token output limit
- Transcripts >8000 chars (~2000 tokens input + needed room for output) would hit the limit

**Solution:**
- Implemented intelligent text chunking at paragraph/sentence boundaries
- Chunks are ~6000 chars each (safe margin under token limit)
- Each chunk is translated independently
- Translations are rejoined with double newlines to preserve structure

**Modified Files:**
| File | Changes |
|------|---------|
| `src/api/shared/durable_processing.py` | Added `_chunk_text()`, updated `_translate_to_hebrew()` and `_translate_to_english()` |
| `tests/test_chunking.py` | NEW - Unit tests for chunking logic |

**How It Works:**
1. Check if transcript > 8000 chars
2. If yes, split into ~6000 char chunks at paragraph boundaries
3. Translate each chunk with modified prompt (no "continue" prompts)
4. Join translated chunks with `\n\n`
5. Log progress for each chunk

### P2.6 Gemini Post-Processing (Dec 16, 2025) ✅ COMPLETED
Added Gemini 3 Pro post-processing layer to improve transcript quality.

**Problem:**
- Transcripts had "irrational starts" - broken/nonsensical text at beginning
- Broken sentences throughout transcripts
- Dialectal errors (Levantine/Gulf Arabic) not corrected
- Root cause: First audio chunk skipped frame sync correction in `audio_utils.py`

**Solution:**
1. **Fixed audio bug** - Applied frame sync to ALL chunks including first
2. **Added Gemini cleanup layer** - Post-processes transcripts before translation
3. **Intelligent chunk merging** - Uses Gemini to merge chunks at sentence boundaries

**New Files:**
| File | Purpose |
|------|---------|
| `src/api/shared/gemini_transcript_processor.py` | Gemini cleanup service |

**Modified Files:**
| File | Changes |
|------|---------|
| `src/api/shared/audio_utils.py` | P2.6 fix: Frame sync for all chunks including first |
| `src/api/shared/durable_processing.py` | Integrated Gemini merge, updated pipeline docs |
| `src/api/function_app.py` | Added `activity_cleanup_transcript` in orchestrator |

**Pipeline Flow (Updated):**
```
Audio → Prepare → Transcribe → [Merge] → [Gemini Cleanup] → Translate → Save
                                  ↓              ↓
                         Intelligent        Clean false starts
                         sentence merge     Fix punctuation
                                           Correct dialects
```

**Environment:**
Requires `GEMINI_API_KEY` in Azure Function App Configuration.

### V3.x UX Improvements (Dec 2025) ✅ COMPLETED

| Version | Change | File | Status |
|---------|--------|------|--------|
| V3.1 | RTL line spacing fix | `TranscriptView.tsx` | ✅ |
| V3.3 | Diarization validation for sales calls | `durable_processing.py` | ✅ |
| V3.4 | Explicit `leading-[2.5]` on all transcript paragraphs | `TranscriptView.tsx` | ✅ |
| V3.9 | Full NotoSansHebrew fonts with Latin glyphs | PDF generation | ✅ |

### V4.x Translation Pipeline (Jan 2026) ✅ CURRENT

**Goal**: Eliminate LLM artifacts from translation output (preamble, follow-up offers, meta-commentary)

| Version | Change | Status |
|---------|--------|--------|
| V4.0 | Enhanced pipeline with dialect awareness (`use_enhanced=True` default) | ✅ |
| V4.3 | Strip LLM meta-commentary, enforce timestamp newlines, Script Guard | ✅ **CURRENT** |

**Problem V4.3 Solved:**
GPT-5 was polluting translations with:
- Preamble: "Got it" / "הבנתי" at start
- Follow-up offers: "Would you like me to..." at end
- Occasional Arabic Unicode leakage in Hebrew output

**Solution (V4.3):**
1. System prompt explicitly forbids meta-commentary
2. `_strip_meta_commentary()` post-processing catches any remaining artifacts
3. `_enforce_timestamp_newlines()` ensures every speaker change has proper spacing
4. Script Guard verifies zero Arabic characters in Hebrew output

**Key File:** `src/api/shared/durable_processing.py:1409-1515`

**Tested On:** Call `CA50046654_20250724_104101` - all checks passed (Jan 11, 2026)

---

## Next Session Focus

**Status as of Jan 12, 2026:**
- V4.3 translation pipeline is live and working
- UX issues from Dec 10 feedback were addressed in V3.1-V3.4
- PDF generation fixed in V3.9

**Potential Areas for Improvement:**

| Area | Current State | Potential Enhancement |
|------|---------------|----------------------|
| Accuracy | WER <5% achieved | Fine-tune dialect detection |
| Performance | 2-5 min for 1hr call | Parallel translation chunks |
| UX | V3.4 spacing live | User testing for further feedback |
| PDF | V3.9 fonts working | Add export options (summary view) |

**No Critical Issues Currently Open.**

---

## Session History

See `CHANGELOG.md` for detailed session logs.

### Security Note
- PostgreSQL admin password stored in Key Vault: `PostgreSQL-AdminPassword`
- Admin user: `seekapaadmin` (only for migrations, never in app code)

## Repository

**Azure DevOps**: https://dev.azure.com/Corp-domain/Corp-AI/_git/qc-call-analyzer

```bash
# Clone (SSH - preferred)
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/qc-call-analyzer

# Push
git push azure <branch>
```

