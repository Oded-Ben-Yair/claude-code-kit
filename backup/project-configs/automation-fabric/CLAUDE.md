# AutomationFabric - Marketing Portal

**Project**: AutomationFabric / Marketing Portal
**Purpose**: Production-ready marketing content automation for 8 marketers with personalized AI-generated content
**Status**: Phase 15 COMPLETE - V7 React Landing Page Live in Production
**Created**: December 11, 2025
**Last Updated**: January 23, 2026
**Production Readiness**: V7 Live | Azure Functions Python 3.12

---

## 🚀 PRIMARY FLOW: Static Market Overview

**NEW** - The primary daily flow is now the **Static Market Overview** system.

| Component | Status | File |
|-----------|--------|------|
| FMP API Client | Complete | `src/runtime/integrations/fmp_client.py` |
| Asset Registry (108 symbols) | Complete | `src/runtime/utils/market_config.py` |
| Baseline Storage | Complete | `src/runtime/utils/baseline_storage.py` |
| 8 Activity Functions | Complete | `src/runtime/activities/static_page_activities.py` |
| Orchestrator | Complete | `src/runtime/orchestrators/static_market_overview_orchestrator.py` |
| HTML Template (dark theme) | Complete | `src/runtime/templates/static-pages/market_overview.html` |
| Translations (en, ar, es, pt) | Complete | `src/runtime/templates/static-pages/i18n/*.json` |

### API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `POST /api/market-overview/generate` | Manual trigger |
| `GET /api/market-overview/status/{id}` | Check status |
| Timer: `0 0 7 * * *` | Daily at 9 AM Israel Time |

### Output URLs

```
https://stmarketingnewsletter.blob.core.windows.net/landing-pages/market-overview/latest/{lang}.html
```

### Next Step

✅ **VALIDATED** - All 4 languages working correctly (Dec 28, 2025)

⚠️ **V6 will be REPLACED by V7 React rebuild - See next section**

---

## 🚀 V7 REACT LANDING PAGE - PRODUCTION LIVE (Phase 15 COMPLETE)

> **STATUS**: ✅ PRODUCTION LIVE
> **Completed**: January 23, 2026
> **Timeline**: 4 weeks (Weeks 1-4 all complete)
> **Reference**: `docs/V7_REACT_IMPLEMENTATION_PLAN.md`, `docs/GAP_ANALYSIS_V7.md`

### Production URLs

| Language | URL |
|----------|-----|
| 🇺🇸 English | https://stmarketingnewsletter.z1.web.core.windows.net/market-overview-v7/index.html?lang=en |
| 🇸🇦 Arabic (RTL) | https://stmarketingnewsletter.z1.web.core.windows.net/market-overview-v7/index.html?lang=ar |
| 🇪🇸 Spanish | https://stmarketingnewsletter.z1.web.core.windows.net/market-overview-v7/index.html?lang=es |
| 🇧🇷 Portuguese | https://stmarketingnewsletter.z1.web.core.windows.net/market-overview-v7/index.html?lang=pt |

**For screenshots/exports**: Add `&static=true` to bypass scroll animations.

### V7 Implementation Summary

| Week | Focus | Status |
|------|-------|--------|
| Week 1 | React + ApexCharts + Tailwind | ✅ Complete |
| Week 2 | FMP Integration + Indicators | ✅ Complete |
| Week 3 | 10 Assets + RTL + i18n | ✅ Complete |
| Week 4 | PNG Export + Azure Deployment | ✅ Complete |

### What V7 Delivers (vs V6)

| Aspect | V6 (Old) | V7 (Current) | Status |
|--------|----------|--------------|--------|
| Charts | SVG placeholders | Real ApexCharts candlesticks | ✅ Fixed |
| Indicators | None | Bollinger Bands + MA50 + RSI | ✅ Fixed |
| Technical Analysis | None | Pivot, T1/T2 targets, stops | ✅ Fixed |
| Theme | Dark | Professional white | ✅ Fixed |
| Data | Static prices | Live FMP OHLC | ✅ Fixed |
| Export | HTML only | PNG via Puppeteer | ✅ Fixed |
| RTL Arabic | Basic | Full RTL support | ✅ Fixed |

### V7 Technology Stack

```
React 18 + TypeScript + Vite
├── ApexCharts (candlestick + RSI subplot)
├── TailwindCSS (light theme)
├── React Query (FMP data fetching)
├── TA-Lib/pandas-ta (indicator calculations)
└── Puppeteer (PNG export for emails)
```

### V7 Color Palette (Trading Central Inspired)

| Element | Color | Hex |
|---------|-------|-----|
| Background | White | `#FFFFFF` |
| Bullish Candle | White/hollow | `#FFFFFF` stroke `#1976D2` |
| Bearish Candle | Black/filled | `#000000` |
| Bollinger Bands | Pink shading | `#FFEBEE` (30-50% opacity) |
| Bollinger Lines | Red | `#E57373` |
| MA50 | Blue | `#1976D2` |
| RSI Line | Blue | `#1976D2` |
| RSI Signal | Red | `#F44336` |
| Target Levels | Green | `#4CAF50` |
| Stop Levels | Red | `#F44336` |
| Pivot | Blue | `#1976D2` |
| Direction Arrow | Blue | `#1976D2` |

### V7 Architecture (Actual Implementation)

```
src/market-overview-v7/                    # React App (Vite + TypeScript)
├── src/
│   ├── components/
│   │   ├── charts/
│   │   │   ├── CandlestickChart.tsx      # ApexCharts candlestick + Bollinger + MA50
│   │   │   └── RSISubplot.tsx            # RSI(14) with signal line
│   │   ├── sections/
│   │   │   ├── AssetSection.tsx          # Asset container with static mode
│   │   │   └── TechnicalAnalysis.tsx     # Pivot, targets, scenarios text
│   │   └── layout/
│   │       ├── Header.tsx                # Seekapa branding
│   │       └── MarketOverviewPage.tsx    # Main page with all 10 assets
│   ├── hooks/
│   │   └── useMarketData.ts              # React Query + FMP data fetching
│   ├── services/
│   │   └── api.ts                        # API client for backend
│   ├── types/
│   │   └── market.ts                     # TypeScript types + theme config
│   ├── styles/
│   │   └── index.css                     # Tailwind + ApexCharts fixes
│   └── App.tsx                           # Language routing
├── vite.config.ts                        # Base path: /market-overview-v7/
├── tailwind.config.js
└── package.json

src/runtime/activities/
└── v7_export_activities.py               # Puppeteer PNG export pipeline
```

### V7 Implementation Timeline

| Week | Focus | Key Deliverables |
|------|-------|------------------|
| **Week 1** | Foundation | React skeleton, ApexCharts candlestick, Trading Central colors |
| **Week 2** | Indicators | Bollinger Bands, MA50, RSI subplot, FMP integration |
| **Week 3** | Analysis | Price levels, technical text, direction arrows, 10 assets |
| **Week 4** | Export | Puppeteer PNG, Azure Blob, API endpoint, 4 languages |

### V7 Assets Coverage (10 Total)

| Category | Assets |
|----------|--------|
| Commodities | Gold, Oil, Silver, Natural Gas |
| Forex | EUR/USD, GBP/USD, USD/JPY |
| Indices | Nasdaq, Dow Jones, S&P 500 |

### API Endpoints (V7 - Planned)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v7/generate` | POST | Generate React landing + PNG export |
| `/api/v7/preview/{lang}` | GET | Preview without export |
| `/api/v7/status/{id}` | GET | Check generation status |

### Memory MCP References

Three entities persisted for V7 planning:
- `automation-fabric-v7-decision` - Architectural decisions
- `automation-fabric-v7-week1-tasks` - Week 1 implementation tasks
- `automation-fabric-trading-central-specs` - Design specifications

---

## ⚠️ DEPRECATED: 32-SLOT SHARED ASSET SYSTEM

> **!!! DEPRECATED AS OF JANUARY 2026 !!!**
> **USE 16-SLOT SYSTEM INSTEAD - SEE NEXT SECTION**

The 32-slot system has been replaced by the 16-slot system which offers:
- Lower daily cost (~$7-9 vs ~$15-20)
- Intelligence-driven content via Grok MCP
- Quality scoring and brand voice integration
- X-ready content (tweet + image pairs)

### Architecture Status: ❌ REMOVED (Jan 15, 2026)

| Component | Status | Notes |
|-----------|--------|-------|
| Orchestrator | ❌ DELETED | Was `orchestrators/daily_shared_assets_orchestrator.py` |
| Activity Functions | ❌ DELETED | Was `activities/shared_asset_activities.py` |
| Veo 3.1 Client | ✅ Still Used | `integrations/veo_client.py` (by 16-slot) |
| Sora-2 Client | ✅ Still Used | `integrations/sora_client.py` (by 16-slot) |
| Video Router | ✅ Still Used | `integrations/video_tools.py` (by 16-slot) |
| Banner Generator | ⚠️ Unused | `agents/banner_generator.py` (X Bundles replaced) |
| Landing Page Generator | ✅ Still Used | `agents/landing_page_activity.py` |
| Database Schema | 📁 Historical | `migrations/006_shared_32_slot_system.sql` |
| HTTP Trigger | ❌ REMOVED | Endpoints deleted from function_app.py |
| Timer Trigger | ❌ REMOVED | Code deleted |

### Slot Configuration (DEPRECATED)

| Slots | Type | Engine | Brand |
|-------|------|--------|-------|
| 1-4 | Video | Sora-2 | Seekapa (EN/AR/ES/PT) |
| 5-8 | Video | Veo 3.1 | Seekapa (EN/AR/ES/PT) |
| 9-12 | Video | Sora-2 | Seekapa (EN/AR/ES/PT) |
| 13-16 | Video | Sora-2 | Unbranded (EN/AR/ES/PT) |
| 17-20 | Video | Veo 3.1 | Unbranded (EN/AR/ES/PT) |
| 21-24 | Video | Sora-2 | Unbranded (EN/AR/ES/PT) |
| 25-28 | Banner | GPT-Image + NanoBanano | Dual-engine (EN/AR/ES/PT) |
| 29-32 | Landing | Gemini 3 Pro | Brand × Language |

### API Endpoints (DEPRECATED - Return X-Deprecated Header)

| Endpoint | Method | Purpose | Replacement |
|----------|--------|---------|-------------|
| `/api/shared-assets/generate` | POST | DEPRECATED | Use `/api/16-slot/generate` |
| `/api/shared-assets/today` | GET | DEPRECATED | Use `/api/16-slot/today` |
| `/api/shared-assets/status/{id}` | GET | DEPRECATED | Use `/api/16-slot/status/{id}` |
| `/api/shared-assets/regenerate/{slot}` | POST | DEPRECATED | N/A |

---

## 🚀 24-SLOT SYSTEM - CANONICAL (Phase 14.5 COMPLETE)

> **THIS IS THE PRIMARY SYSTEM - 32-SLOT IS DEPRECATED**
> **Video Quality Upgrade: Arabic Khaleeji Focus + Social-First Enhancement**

Intelligence-first asset generation using Grok MCP for market intelligence and X-ready content.
Includes full quality infrastructure: scoring, brand voices, quality gates.

### Phase 14.5 Improvements (January 2026)

- **Arabic Khaleeji Priority**: 4 dedicated video slots (9-12) with Gulf-relevant assets
- **Correct Seekapa Branding**: Deep blue #1E3A5F + gold #D4AF37 (NOT green)
- **Trading Chart Guidance**: Explicit green #22C55E / red #EF4444 for candles
- **Grok-Enhanced Video Briefs**: Social hooks with headlines, key stats, urgency
- **Asset-Specific Visuals**: Gold, forex, oil, crypto, indices templates
- **Backup Veo Key**: Rate limit fallback via Key Vault

### Why 24 Slots (vs Old 16)?

| Aspect | Old (16 slots) | New (24 slots) |
|--------|----------------|----------------|
| Daily cost | ~$7-9 | ~$10-12 |
| Videos | 4 (1 per language) | **12 (3× more, asset-specific)** |
| Arabic Khaleeji videos | 1 | **4 (gold, forex, oil, indices)** |
| Social content | 8 X bundles | 8 X bundles |
| Landing pages | 4 (Gemini) | 4 (Gemini, renumbered 21-24) |
| Video briefs | None | **Grok-enhanced hooks** |

### Architecture Status: ✅ 100% COMPLETE (Jan 18, 2026)

| Component | Status | File |
|-----------|--------|------|
| Grok Client Wrapper | ✅ Complete | `integrations/grok_client.py` |
| Grok Activities (24 slots) | ✅ Complete | `activities/grok_activities.py` |
| 24-Slot Orchestrator | ✅ Complete | `orchestrators/daily_16_slot_orchestrator.py` |
| **Video Brief Activity** | ✅ Complete | `activities/video_brief_activity.py` |
| **Social Video Prompts** | ✅ Complete | `templates/video_prompts/social_hooks.py` |
| **Brand Asset Library** | ✅ Complete | `templates/brand_assets/seekapa.py` |
| **Quality Scorer** | ✅ Complete | `utils/quality_scorer.py` |
| **Quality Gates** | ✅ Complete | `utils/quality_gates.py` |
| Veo Client (backup key) | ✅ Complete | `integrations/veo_client.py` |
| Sora Client (briefs) | ✅ Complete | `integrations/sora_client.py` |
| Database Migration | ✅ Complete | `migrations/013_expand_video_slots.sql` |
| HTTP Triggers | ✅ Complete | `POST /api/16-slot/generate` (or `/api/24-slot/generate`) |
| Unit Tests | ✅ Complete | `tests/test_grok_activities.py` |

### 24-Slot Configuration

| Slot | Type | Engine | Brand | Language | Asset Focus |
|------|------|--------|-------|----------|-------------|
| 1 | X Bundle | Grok | Seekapa | EN | - |
| 2 | X Bundle | Grok | Unbranded | EN | - |
| 3 | X Bundle | Grok | Seekapa | AR (Khaleeji) | - |
| 4 | X Bundle | Grok | Unbranded | AR (Khaleeji) | - |
| 5 | X Bundle | Grok | Seekapa | ES (LatAm) | - |
| 6 | X Bundle | Grok | Unbranded | ES (LatAm) | - |
| 7 | X Bundle | Grok | Seekapa | PT (Brazil) | - |
| 8 | X Bundle | Grok | Unbranded | PT (Brazil) | - |
| **9** | **Video** | **Veo** | **Seekapa** | **AR (Khaleeji)** | **Gold** |
| **10** | **Video** | **Sora** | **Seekapa** | **AR (Khaleeji)** | **Forex EUR/USD** |
| **11** | **Video** | **Veo** | **Seekapa** | **AR (Khaleeji)** | **Oil** |
| **12** | **Video** | **Sora** | **Seekapa** | **AR (Khaleeji)** | **Indices Dubai** |
| 13 | Video | Veo | Seekapa | EN | Gold |
| 14 | Video | Sora | Seekapa | EN | Forex |
| 15 | Video | Veo | Seekapa | EN | Crypto BTC |
| 16 | Video | Sora | Seekapa | ES (LatAm) | Gold |
| 17 | Video | Veo | Seekapa | ES (LatAm) | Forex |
| 18 | Video | Sora | Seekapa | PT (Brazil) | Gold |
| 19 | Video | Veo | Unbranded | EN | Trending |
| 20 | Video | Sora | Unbranded | AR (Khaleeji) | Trending |
| 21 | Landing Page | Gemini | Seekapa | EN | - |
| 22 | Landing Page | Gemini | Seekapa | AR | - |
| 23 | Landing Page | Gemini | Seekapa | ES | - |
| 24 | Landing Page | Gemini | Seekapa | PT | - |

**Arabic Khaleeji gets 4 dedicated video slots (9-12) with Gulf-relevant assets.**

### X Bundle = Tweet + Image Pair

Each X bundle contains:
- **Tweet text**: Market insight + brand voice + CTA URL
- **Image**: Aurora-generated trading visual ($0.07/image)
- **Hashtags**: 3-5 relevant hashtags
- **Market context**: Real-time intelligence from Grok Search

### Grok MCP Tools Used

| Tool | Purpose | Cost |
|------|---------|------|
| `grok_search` | Real-time market intelligence | ~$0.01/query |
| `grok_brand_content` | Tweet generation with brand voice | ~$0.002/tweet |
| `grok_image_generate` | Aurora image generation | $0.07/image |

### API Endpoints (24-Slot)

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/16-slot/generate` | POST | Manual trigger (optional: slots, test_mode) - defaults to 24 slots |
| `/api/24-slot/generate` | POST | Alias for 16-slot/generate |
| `/api/16-slot/today` | GET | Get today's 24-slot assets |
| `/api/16-slot/status/{id}` | GET | Check orchestration status |
| Timer: `0 0 5 * * *` | - | **Daily at 7 AM Israel Time** (FMP + Grok) |

### Orchestrator Flow (Phase 14.5)

```
┌─────────────────────────────────────────────────────────────────┐
│              DAILY 24-SLOT ORCHESTRATOR (5 AM UTC)              │
├─────────────────────────────────────────────────────────────────┤
│  1. create_16_slot_run_activity()                               │
│                          │                                      │
│  2. PARALLEL: Market Intelligence                               │
│     ├─ collect_fmp_market_data_activity()  ─┬─► MarketData      │
│     └─ collect_grok_intelligence_activity() ─┘  + MarketContext │
│                          │                                      │
│  3. PARALLEL: X Bundles (Slots 1-8) - ALL AT ONCE               │
│     └─ 8 × generate_x_bundle_activity()                         │
│                          │                                      │
│  3.5 PARALLEL: Video Briefs (Slots 9-20) - Grok-Enhanced        │
│     └─ 12 × generate_video_brief_activity()                     │
│                          │                                      │
│  4. BATCHED: Videos (Slots 9-20) - 3 per batch, 60s delay       │
│     └─ 12 × generate_shared_video_activity() (with briefs)      │
│                          │                                      │
│  5. PARALLEL: Landing Pages (Slots 21-24)                       │
│     └─ 4 × generate_shared_landing_activity()                   │
│                          │                                      │
│  6. finalize_16_slot_run_activity()                             │
└─────────────────────────────────────────────────────────────────┘
```

### Database Changes (Migration 013)

```sql
-- Video quality upgrade columns
ALTER TABLE daily_asset_slots ADD COLUMN IF NOT EXISTS asset_focus VARCHAR(50);
ALTER TABLE daily_asset_slots ADD COLUMN IF NOT EXISTS video_brief JSONB;

-- New views
CREATE VIEW v_today_24_slot_assets AS ...
CREATE VIEW v_video_performance_by_asset AS ...
CREATE VIEW v_arabic_khaleeji_videos AS ...
```

### Known Issues

1. **Grok API 422 errors**: `grok_social_pulse` and `grok_x_search` return 422 errors
   - **Workaround**: Using `grok_search` with `mode="on"` instead
2. **Aurora image URLs expire**: URLs are temporary
   - **Solution**: Immediate download to Azure Blob after generation

---

## ⚠️ DEPRECATED - Old PDF Newsletter System

The old PDF newsletter system is deprecated. Do NOT use:
- `nightly_orchestrator.py` for market overviews (still used for marketer assets)
- `pdf_generator.py` for market overviews
- `docs/SESSION_HANDOFF_DEC21.md` (old issues)

---

## Quick Start

```bash
# Backend - Azure Functions
cd src/runtime
source .venv/bin/activate
func start --port 7076

# Frontend - Next.js Dashboard
cd src/dashboard
npm run dev:test  # Uses local API on port 7076

# Run All Tests (293 passing)
cd src/runtime && pytest tests/ -v --ignore=tests/test_content_generator.py
cd src/dashboard && npm run test:e2e
```

---

## Current State Summary

### What's Working (Tested & Verified)

| Component | Status | Tests |
|-----------|--------|-------|
| PostgreSQL Database | Connected | 15 |
| User Preferences API | Complete | 15 |
| Feedback API | Complete | 12 |
| Assets/Runs API | Complete | 15 |
| Learning Engine Logic | Complete | 26 |
| PDF Generator Logic | Complete | 36 |
| Video Overlays (4 languages) | Complete | 34 |
| E2E User Flow | Complete | 4 |
| Chat Context Builder | Complete | 30 |
| Chat Learning Extractor | Complete | 29 |
| Chat Handler | Complete | 60 |
| Marketer Orchestrator Activities | Complete | 17 |
| **Grok Activities (16-slot)** | Complete | 35+ |
| **Total** | **328+ tests passing** | |

### Video Providers (ALL VALIDATED Dec 17, 2025)

| Provider | Status | Quality | Notes |
|----------|--------|---------|-------|
| **Veo 3.1** | ✅ Working | 95/100 | Duration must be 4-8s |
| **Sora-2** | ✅ Working | 98/100 | Avoid "crypto" in prompts (moderation) |
| **HeyGen** | ✅ Working | 85/100 | AI avatar with voice |
| **ElevenLabs TTS** | ✅ Working | 90/100 | Multi-voice support |
| **Gemini Landing Pages** | ✅ Working | 94/100 | Full HTML generation |

### X/Social Content Providers (Phase 14 - NEW)

| Provider | Status | Purpose | Notes |
|----------|--------|---------|-------|
| **Grok Search** | ✅ Working | Market intelligence | Real-time web + X search |
| **Grok Brand Content** | ✅ Working | Tweet generation | Brand voices for 4 languages |
| **Grok Aurora** | ✅ Working | Image generation | $0.07/image, URLs expire quickly |

### Critical Gaps (Priority Order)

| Priority | Gap | Status | Impact |
|----------|-----|--------|--------|
| **P0** | Azure Blob Storage | ✅ Complete | Connection configured |
| **P0** | Video text overlays | ✅ Complete | 4 languages, logo, metrics, CTA |
| **P1** | Nightly orchestrator | ✅ Complete | Timer trigger 10 PM UTC + HTTP trigger |
| **P1** | Marketer orchestrator | ✅ Complete | All 9 activities registered |
| **P1** | Landing page deployment | ✅ Blob hosting | Static website ready |
| **P1** | Multi-language PDFs | ✅ Config ready | 4 languages supported |
| **P2** | Video + TTS merge | ⚠️ Separate | FFmpeg pipeline available |

### Database (PostgreSQL - LIVE)

**Server**: `postgres-seekapatraining-prod.postgres.database.azure.com:5432`
**Database**: `automation_fabric`
**User**: `automation_app_user`

**Tables (All Created & Seeded)**:
- `marketers` - 8 seeded users
- `user_preferences` - 56 preferences (7 per user)
- `user_feedback` - Feedback storage with FK to learning_events
- `marketer_assets` - Asset metadata and storage URLs
- `learning_events` - Preference learning history
- `chat_sessions` / `chat_messages` - Chat history

**View**: `v_user_profile` - Aggregated user profile with preferences

### API Endpoints (All Tested & Working)

| Endpoint | Method | Status | Purpose |
|----------|--------|--------|---------|
| `/api/health` | GET | Working | Health check |
| `/api/users/{id}/preferences` | GET | Working | Get user preferences |
| `/api/users/{id}/preferences` | PATCH | Working | Update preferences |
| `/api/feedback` | POST | Working | Record feedback + learning |
| `/api/assets/recent` | GET | Working | Get recent assets (real DB) |
| `/api/runs/today` | GET | Working | Get today's run status |
| `/api/content/trigger` | POST | Working | Trigger daily asset orchestrator |
| `/api/content/marketer/{id}/trigger` | POST | Working | Trigger marketer content generation |
| `/api/assets/{id}/regenerate` | POST | Working | Regenerate asset |
| `/api/chat` | POST | Working | Chat endpoint with learning |
| `/api/workspace/{lang}/slots` | GET | Working | Get workspace slots by language |
| `/api/16-slot/generate` | POST | Working | Trigger 16-slot Grok generation |
| `/api/16-slot/today` | GET | Working | Get today's 16-slot assets |
| `/api/16-slot/status/{id}` | GET | Working | Check 16-slot orchestration status |

### Frontend (Next.js Dashboard)

| Page | Status | Features |
|------|--------|----------|
| `/auth/` | Working | Dropdown user selection, preview card |
| `/` (Dashboard) | Working | Personalized greeting, KPI cards, asset list |
| `/chat/` | Exists | Chat interface (needs API integration review) |

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         MARKETING PORTAL FRONTEND                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Auth       │  │  Dashboard  │  │  Asset      │  │  Chat       │        │
│  │  (Dropdown) │→ │  (Personal) │→ │  Gallery    │→ │  (Learning) │        │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘        │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │ API Calls (localhost:7076 dev / Azure prod)
                                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    AZURE FUNCTIONS (src/runtime)                             │
│  function_app.py - HTTP endpoints with asyncpg database connections          │
│  Orchestrators: nightly_orchestrator, marketer_content_orchestrator         │
│  Agents: learning_engine, video_producer, content_generator                 │
└────────────────────────────────┬────────────────────────────────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────────────┐
         ▼                       ▼                               ▼
┌─────────────────┐    ┌─────────────────┐            ┌─────────────────┐
│ PostgreSQL      │    │ Blob Storage    │            │ Key Vault       │
│ automation_     │    │ (TBD)           │            │ kv-seekapa-apps │
│ fabric          │    │                 │            │                 │
└─────────────────┘    └─────────────────┘            └─────────────────┘
```

---

## The 8 Marketers (Seeded in Database)

| ID | Name | Default Languages | Default Brand |
|----|------|-------------------|---------------|
| `muhammad` | Muhammad | en, ar_khaleeji | seekapa |
| `ali` | Ali | en, ar_khaleeji | seekapa |
| `daniel` | Daniel | en, es_latam | seekapa |
| `adnhan` | Adnhan | en, ar_khaleeji | seekapa |
| `amir` | Amir | en | seekapa |
| `whaaala` | Whaaala | en, ar_khaleeji | seekapa |
| `fima` | Fima | en, pt_br | seekapa |
| `nasrin` | Nasrin | en, ar_khaleeji | unbranded |

---

## Test Coverage

### Backend Tests (289 passing)

```bash
cd src/runtime
pytest tests/ -v --ignore=tests/test_content_generator.py
```

| File | Tests | Coverage |
|------|-------|----------|
| `test_database.py` | 15 | DB connection, tables, seed data |
| `test_api_users.py` | 15 | GET/PATCH preferences, validation |
| `test_api_feedback.py` | 12 | POST feedback, learning events |
| `test_api_assets.py` | 15 | Assets, runs, regenerate, CORS |
| `test_learning_engine.py` | 26 | Signal strengths, merge logic |
| `test_pdf_generator.py` | 36 | Brand/language config, formatting |
| `test_chat_context.py` | 30 | Context builder, market data, assets |
| `test_chat_learning.py` | 29 | Signal extraction, preference updates |
| `test_chat_handler.py` | 60 | Intent detection, handlers, edge cases |
| `test_marketer_activities.py` | 17 | Orchestrator activities |
| `test_grok_activities.py` | 35+ | Grok client, X bundles, slots, CTA URLs |

### E2E Tests (4 passing)

```bash
cd src/dashboard
npm run test:e2e
```

- Auth flow with user selection
- Dashboard personalization
- Feedback button interaction
- Logout flow

### Visual Validation (Gemini)

- Auth page: 100/100
- Dashboard: 95/100

---

## Implementation Status

### Phase 1-5: Core Implementation ✅ COMPLETE
- Auth page with marketer dropdown
- Personalized dashboard with KPI cards
- PDF generator with multi-language/brand support
- Video tool abstraction (Sora-2, Veo 3.1, HeyGen, Nano Banano)
- Learning engine with feedback signals
- Per-marketer orchestration

### Phase 6: TDD Integration ✅ COMPLETE
- Database connectivity tests
- User preferences API tests & implementation
- Feedback API tests & implementation
- Assets/Runs API tests & implementation
- Learning engine unit tests
- PDF generator unit tests
- E2E Playwright tests
- Gemini Vision screenshot validation

### Phase 7: P0 Blockers Resolved ✅ COMPLETE (Dec 17, 2025)
- Azure Blob Storage connected (stmarketingnewsletter)
- Video text overlays implemented (4 languages)
- CTA translations module created
- FFmpeg filter chain bug fixed
- 34 overlay unit tests
- Visual validation complete (3 video variants)

### Phase 8: Quality Review ✅ COMPLETE (Dec 17, 2025)
- Playwright screenshots at 3 viewports (30 screenshots)
- API endpoint testing (all 11 endpoints working)
- QUALITY_REVIEW.md created with 88/100 score
- 0 critical issues, 2 medium, 3 low priority items

### Phase 9: Chat & Orchestrator ✅ COMPLETE (Dec 17, 2025)
- Chat context builder tests (30 tests)
- Chat learning extractor tests (29 tests)
- Chat handler tests (60 tests)
- Fixed import issues in agents (data_collector.py, video_producer.py)
- Fixed sentiment detection bug in chat_learning.py
- Registered 9 missing activities for marketer orchestrator
- Added HTTP trigger for marketer content generation
- Marketer activity tests (17 tests)

### Phase 14: 16-Slot Grok Integration ✅ COMPLETE (Jan 15, 2026)
- Grok client wrapper with mock support (`integrations/grok_client.py`)
- Grok activities for X bundles and market intel (`activities/grok_activities.py`)
- 16-slot orchestrator with parallel/sequential execution
- Database migration for X bundle fields (tweet_text, hashtags, market_context)
- HTTP triggers for 16-slot generation and status
- Unit tests for all Grok activities (27 tests passing)
- Brand voices for 4 languages × 2 brands (8 total)
- Multi-stage pipeline: intel→hook→tweet→image with quality gate
- 32-slot legacy system fully removed

### Phase 14.5: Video Quality Upgrade ✅ COMPLETE (Jan 18, 2026)
**Focus**: Arabic Khaleeji priority, 12 video slots, social-first hooks

- **Brand Asset Library** (`templates/brand_assets/seekapa.py`)
  - Correct Seekapa colors: deep blue #1E3A5F + gold #D4AF37
  - Trading chart colors: bullish #22C55E, bearish #EF4444
  - VEO_BRAND_STYLES and SORA_BRAND_STYLES configurations
  - Language-specific cultural contexts (ar_khaleeji, en, es_latam, pt_br)

- **Social Video Prompts** (`templates/video_prompts/social_hooks.py`)
  - Asset-specific templates: gold, forex, oil, crypto, indices, trending
  - Arabic Khaleeji prompts with Gulf luxury aesthetic
  - Camera sequences for scroll-stopping first 2 seconds
  - Cultural elements: Dubai skyline, Islamic geometric patterns

- **Video Brief Activity** (`activities/video_brief_activity.py`)
  - Multi-stage Grok pipeline: grok_search → grok_reason → visual template
  - Stage 1: Deep market intelligence for specific asset
  - Stage 2: Hook extraction (headline, key_stat, momentum, urgency)
  - Stage 3: Apply asset-specific visual template with brand colors

- **24-Slot Expansion** (from 16 to 24 slots)
  - Slots 1-8: X Bundles (unchanged)
  - Slots 9-12: Arabic Khaleeji videos (gold, forex, oil, indices)
  - Slots 13-15: English videos (gold, forex, crypto)
  - Slots 16-17: Spanish LatAm videos (gold, forex)
  - Slot 18: Portuguese Brazil video (gold)
  - Slots 19-20: Unbranded trending videos (EN, AR)
  - Slots 21-24: Landing pages (renumbered from 13-16)

- **Database Migration 013** (`migrations/013_expand_video_slots.sql`)
  - Added `asset_focus` column for video slots
  - Added `video_brief` JSONB column for Grok briefs
  - Created `v_today_24_slot_assets` view
  - Created `v_video_performance_by_asset` view
  - Created `v_arabic_khaleeji_videos` priority tracking view

- **Orchestrator Updates** (`daily_16_slot_orchestrator.py`)
  - Added Step 3.5: Parallel video brief generation
  - Batched video generation (3 per batch, 60s delay)
  - Brief parameter passed to video generation activities

- **Video Client Enhancements**
  - `veo_client.py`: Backup API key support, brand color guidance
  - `sora_client.py`: Chart color guidance, momentum hints, cultural elements

---

## Production Deployment Checklist

### Ready to Deploy
| Component | Status | Notes |
|-----------|--------|-------|
| Backend API | ✅ Ready | All endpoints tested |
| Frontend Dashboard | ✅ Ready | Auth, Dashboard, Workspace, Chat |
| Database Schema | ✅ Ready | All tables created and seeded |
| Orchestrators | ✅ Ready | Daily + Marketer orchestrators complete |
| Test Suite | ✅ Ready | 293 tests passing |
| Quality Review | ✅ Ready | 88/100 overall score |

### Optional Improvements (Post-Launch)
| Priority | Task | Effort | Status |
|----------|------|--------|--------|
| P2 | Azure AD B2C Auth | 4h | Using dropdown (works for demo) |
| P2 | Application Insights | 1h | No telemetry yet |
| P2 | Fix Phase/Quality N/A display | 1h | Cosmetic issue |
| P3 | Create /preferences page | 2h | Nav link exists but page missing |
| P3 | RTL Arabic deep validation | 2h | Basic testing done |

---

## File Structure

```
automation-fabric/
├── CLAUDE.md                          # THIS FILE
├── .gitignore                         # Git ignore rules
├── src/
│   ├── dashboard/                     # Next.js Frontend
│   │   ├── app/
│   │   │   ├── auth/page.tsx          # User selection auth
│   │   │   ├── page.tsx               # Personalized dashboard
│   │   │   └── chat/page.tsx          # Chat interface
│   │   ├── contexts/UserContext.tsx   # User state management
│   │   ├── __tests__/e2e/             # Playwright E2E tests
│   │   └── playwright.config.ts       # E2E config (port 3001)
│   │
│   ├── runtime/                       # Azure Functions (Python)
│   │   ├── function_app.py            # All HTTP endpoints (main file)
│   │   ├── orchestrators/             # Durable Function orchestrators
│   │   ├── agents/                    # Business logic agents
│   │   │   ├── learning_engine.py     # Preference learning
│   │   │   ├── video_producer.py      # Video generation
│   │   │   └── content_generator.py   # LLM content
│   │   ├── generators/
│   │   │   └── pdf_generator.py       # PDF generation (WeasyPrint)
│   │   ├── integrations/              # External API clients
│   │   │   ├── grok_client.py         # Grok MCP wrapper (Phase 14)
│   │   │   ├── sora_client.py         # Sora-2 video generation
│   │   │   ├── veo_client.py          # Veo 3.1 video generation
│   │   │   └── fmp_client.py          # Financial Market API
│   │   ├── activities/
│   │   │   ├── grok_activities.py     # X bundle & 24-slot config (Phase 14)
│   │   │   └── video_brief_activity.py # Grok video briefs (Phase 14.5)
│   │   ├── templates/
│   │   │   ├── brand_assets/
│   │   │   │   └── seekapa.py         # Seekapa brand colors (Phase 14.5)
│   │   │   └── video_prompts/
│   │   │       └── social_hooks.py    # Social video templates (Phase 14.5)
│   │   ├── migrations/
│   │   │   ├── 001_user_preferences.sql
│   │   │   ├── 006_shared_32_slot_system.sql
│   │   │   ├── 010_16_slot_schema.sql  # X bundle support (Phase 14)
│   │   │   └── 013_expand_video_slots.sql # 24-slot video upgrade (Phase 14.5)
│   │   └── tests/                     # 328+ pytest tests
│   │       └── test_grok_activities.py # Grok/16-slot tests (Phase 14)
│   │
│   └── mcp-server/                    # MCP Server (TypeScript) - Not yet implemented
│
├── templates/
│   ├── pdf/                           # PDF HTML templates
│   └── brands/                        # Brand configurations
│
├── infra/bicep/                       # Azure Infrastructure
└── azure-pipelines.yml                # CI/CD pipeline
```

---

## Environment Variables

```bash
# Database (CURRENTLY HARDCODED - move to Key Vault)
DATABASE_URL=postgresql://automation_app_user:REDACTED@postgres-seekapatraining-prod.postgres.database.azure.com:5432/automation_fabric?sslmode=require

# Frontend API (dev)
NEXT_PUBLIC_API_URL=http://localhost:7076/api
NEXT_PUBLIC_API_BASE=http://localhost:7076/api

# To Add to Key Vault for Production:
# - AutomationFabric-DbConnectionString
# - Sentimark-ApiKey
# - OpenAI-ApiKey (Sora-2)
# - Google-AI-Key (Veo 3.1)
# - HeyGen-ApiKey
# - ElevenLabs-ApiKey
# - Storage-ConnectionString
# - XAI-ApiKey (Grok API for 16-slot system)
```

---

## Known Issues & Technical Debt

1. **test_content_generator.py** - Import issues with relative imports, excluded from test suite
2. **WeasyPrint** - Not installed in venv (uses fpdf2 fallback for PDF generation)
3. **Next.js static export** - Has `output: 'export'` - may need to change for dynamic routes
4. **Database credentials** - Currently hardcoded, should move to Key Vault for production
5. **Phase/Quality N/A** - Dashboard shows "N/A" for phase and quality score (cosmetic)
6. **Missing pages** - /preferences and /assets pages linked but not implemented

---

## Quick Commands

```bash
# Run all backend tests
cd src/runtime && pytest tests/ -v --ignore=tests/test_content_generator.py

# Run specific test file
cd src/runtime && pytest tests/test_api_users.py -v

# Run E2E tests
cd src/dashboard && npm run test:e2e

# Start backend (dev)
cd src/runtime && source .venv/bin/activate && func start --port 7076

# Start frontend (dev with local API)
cd src/dashboard && npm run dev:test
```

---

## Azure DevOps

**Repository (SSH)**: `git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/automation-fabric`
**Repository (HTTPS)**: https://dev.azure.com/Corp-domain/Corp-AI/_git/automation-fabric
**Pipeline ID**: 99 (automation-fabric-cicd)
**Resource Group**: AZAI_group
**Key Vault**: kv-seekapa-apps
**Database Server**: postgres-seekapatraining-prod.postgres.database.azure.com

### Recent Changes (Jan 18, 2026) - Phase 14.5: Video Quality Upgrade
- **Arabic Khaleeji Priority**: 4 dedicated video slots (9-12) with Gulf assets
- **24-Slot Expansion**: 8 X bundles + 12 videos + 4 landing pages
- **Correct Brand Colors**: Deep blue #1E3A5F + gold #D4AF37 (fixed from green)
- **Trading Chart Guidance**: Bullish #22C55E, bearish #EF4444
- Created `templates/brand_assets/seekapa.py` - brand color library
- Created `templates/video_prompts/social_hooks.py` - social video templates
- Created `activities/video_brief_activity.py` - Grok multi-stage briefs
- Created `migrations/013_expand_video_slots.sql` - video schema upgrade
- Updated orchestrator with video brief step and batched generation
- Updated Veo/Sora clients with brand colors and chart guidance
- Added `/api/24-slot/generate` endpoint alias

### Previous Changes (Jan 15, 2026) - Production-Ready Plan COMPLETE
- **DELETED**: 32-slot orchestrator and activities (legacy cleanup)
- **DELETED**: Frontend workspace (32-slot) and assets redirect pages
- Added market overview guardrails (5KB HTML min, BLOCKING checks, Grok fallback)
- Enhanced X bundles with multi-stage Grok pipeline (intel→hook→tweet→image)
- Added Grok-driven video briefs with GCC language configs
- Simplified frontend to minimal nav (Assets/Chat only)
- 27/27 Grok activity tests passing
- Handover doc: `docs/SESSION_HANDOFF_JAN15_2026.md`

### Previous Changes (Jan 13, 2026) - Phase 14: Grok Integration
- Implemented 16-slot system with Grok MCP integration
- Created `grok_client.py` wrapper for Azure Functions
- Created `grok_activities.py` with X bundle generation
- Created `daily_16_slot_orchestrator.py` with parallel/sequential execution
- Added database migration `010_16_slot_schema.sql` for X bundle fields
- Added HTTP triggers: `/api/16-slot/generate`, `/api/16-slot/today`, `/api/16-slot/status/{id}`
- Created unit tests for all Grok functionality (35+ tests)
- Configured brand voices and CTA URLs for 4 languages × 2 brands

### Previous Changes (Dec 19, 2025)
- Migrated from monorepo (Seekapa-AI-Assistance) to dedicated SSH repo
- Created new pipeline (ID 99) with fixed SWA deployment using `skip_app_build: true`
- Added system user for shared nightly assets (marketer_id: 'system')
- Implemented DB storage in `store_marketer_asset_activity`
- Added E2E tests for workspace and chat pages
