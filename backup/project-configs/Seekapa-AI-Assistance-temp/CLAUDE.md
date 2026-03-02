# Sentimark - Project Configuration

**Project**: Sentimark (formerly Polymarket Analyzer)
**Type**: Next.js 14 + Python Azure Functions
**Status**: PRODUCTION READY - 100/100 All Dimensions Complete
**Last Updated**: December 10, 2025 (Session 30)

---

## Quick Start

```bash
cd ~/projects/sentimark
npm run dev          # Start dev server (http://localhost:3000)
```

**Live Site**: https://polymarket-frontend.azurewebsites.net

---

## Deployment URLs

| Service | URL |
|---------|-----|
| Frontend | https://polymarket-frontend.azurewebsites.net |
| Backend API | https://polymarket-analyzer.azurewebsites.net/api |
| Health Check | https://polymarket-analyzer.azurewebsites.net/api/health |

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Next.js 14, React 18, Tailwind CSS, Framer Motion |
| Backend | Python 3.11, Azure Functions v4 |
| Database | PostgreSQL (Azure Flexible Server) |
| Auth | NextAuth.js with CredentialsProvider |
| LLMs | 5-LLM System (see docs/LLM_ARCHITECTURE.md) |
| External Data | FMP Stable API, Polymarket API |

---

## LLM System Quick Reference

**READ `docs/LLM_ARCHITECTURE.md` FOR FULL DETAILS**

| Provider | Model | Weight | Role |
|----------|-------|--------|------|
| Perplexity | sonar-pro | 40% | News Aggregation (runs first) |
| Azure OpenAI | gpt-5-pro | 20% | Deep Analysis |
| Azure AI | grok-4-fast-reasoning | 20% | Fast Reasoning |
| Google | gemini-3-pro | 10% | Validation |
| Azure OpenAI | gpt-5.1 | 10% | Complex Markets |

**Consensus Formula**: `effective_weight = assigned_weight × confidence`

---

## Brand Guidelines

### Brand Assets Location
**Source Files**: `/sentimark-brand/` directory contains extracted brandbook assets.

### Colors (Exact Brandbook Values)
| Name | Hex | Tailwind Class |
|------|-----|----------------|
| Deep Purple | `#642C95` | `primary` |
| Electric Turquoise | `#2CE7E3` | `secondary` |
| Background Black | `#0E1118` | `bg-primary` |
| Success Green | `#44D540` | `success` |
| Danger Red | `#F83731` | `danger` |
| Warning Yellow | `#FBB724` | `warning` |

### Sentiment Pulse Gradient (Logo Waveform)
```
0%:   #642C95 (Deep Purple)
25%:  #C42C8E (Magenta)
50%:  #F83731 (Red)
75%:  #FBB724 (Yellow)
100%: #2CE7E3 (Turquoise)
```

### Typography
| Type | Font | Usage |
|------|------|-------|
| Display | Sulphur Point | Hero headlines, logo |
| Headings | Space Grotesk | H1-H3 |
| Body | Inter | Body text, UI |

---

## Key Files Reference

### Core Components
- `components/ui/SentimarkLogo.tsx` - Main logo component
- `components/layout/Header.tsx` - Navigation header
- `components/home/FlagshipAssets.tsx` - Asset categories grid
- `components/sentiment/IntelligenceHub.tsx` - 8 intelligence sources

### Pages
- `app/page.tsx` - Homepage
- `app/trading/page.tsx` - Three-pane trading workspace
- `app/assets/page.tsx` - Asset listing
- `app/rankings/page.tsx` - Top 10 Buy/Sell with SIS scores
- `app/portfolios/page.tsx` - 3 AI portfolios
- `app/accuracy/page.tsx` - Direction accuracy dashboard

### Backend
- `function_app.py` - Azure Functions (42 endpoints + timers)
- `shared/master_agent/` - Thompson Sampling bandits, dynamic weights
- `shared/master_agent/regime.py` - Market regime detection
- `shared/master_agent/chat.py` - AI chatbot implementation
- `docs/LLM_ARCHITECTURE.md` - Complete 5-LLM system documentation

---

## Database

**Server**: `postgres-seekapatraining-prod.postgres.database.azure.com`
**Database**: `polymarket_analyzer`
**User**: `sentimark_app_user`

### Key Tables
- `users` - User accounts with `plan` enum (Free, Pro, Elite)
- `markets` - Polymarket markets data
- `price_history` - Price snapshots
- `sentiment_scores` - Sentiment analysis results
- `prediction_daily` - AI predictions with outcomes
- `llm_raw_outputs` - Raw LLM data for model improvement
- `chat_sessions` - AI chatbot session persistence (NEW)
- `chat_messages` - Individual chat messages (NEW)

---

## Azure Resources

| Resource | Name | Type |
|----------|------|------|
| Resource Group | AZAI_group | - |
| Frontend | polymarket-frontend | Web App |
| Backend | polymarket-analyzer | Function App |
| Database | postgres-seekapatraining-prod | PostgreSQL Flexible |
| Key Vault | kv-seekapa-apps | Key Vault |

---

## Deployment Commands

```bash
# Build
npm run build

# Create deployment zip
zip -r deployment.zip .next package.json package-lock.json public node_modules templates -x "node_modules/.cache/*" -x ".next/cache/*"

# Deploy (recommended: use Kudu API for large files)
az webapp deploy --resource-group AZAI_group --name polymarket-frontend --src-path deployment.zip --type zip

# Backend deploy
func azure functionapp publish polymarket-analyzer
```

---

## Session 26 Completed: Feedback Loop + AI Chatbot

**Completed Tasks**:
- ✅ Feedback Loop: Bandits now update from prediction outcomes
- ✅ AI Chatbot: `POST /api/master-agent/chat` endpoint live
- ✅ Multi-Horizon Timers: 1h, 24h, 7d, 30d evaluation
- ✅ Market Regime: Daily classification (bull/bear/volatile/crash/range)
- ✅ Confidence Calibration: Weekly accuracy bucket updates

**New Components**:
- `shared/master_agent/regime.py` - Market regime detection
- `shared/master_agent/chat.py` - AI chatbot implementation

---

## Session 30 Completed: 100/100 Perfect Score Achievement

**ALL DIMENSIONS COMPLETE** (Session 30):
- ✅ WCAG Accessibility - All text colors meet AA standard (4.5:1+)
- ✅ Visual Tests - 128 desktop + 244 mobile = ALL PASSING
- ✅ Web Push API - Service worker + subscription hooks ready
- ✅ Chat Persistence - Migration 011 applied, tables live
- ✅ Multi-Model Debate - 6-LLM consensus plan executed

**Key Changes**:
- `tailwind.config.ts` - Updated text-tertiary/disabled for WCAG compliance
- `design-tokens.css` - Matching CSS custom properties
- `public/sw.js` - Service worker for Web Push notifications
- `lib/hooks/useRegimeAlerts.ts` - Web Push subscription support
- `tests/e2e/visual-validation.spec.ts` - NextAuth session mocking for Pro tier

**Database Tables Added**:
- `chat_sessions` - Session persistence with UUID user_id FK
- `chat_messages` - Message storage with role, content, intent, confidence

**Testing Commands**:
- `npm run test` - Run all Playwright tests (372+ tests)
- `npx playwright test --project=desktop` - Desktop only (128 tests)

---

## Next Session Focus: Phase 6 - Advanced Features

**Phase 6 Tasks** (optional enhancements):
1. **VAPID Keys**: Generate and add to Key Vault for live Web Push
2. **Chat History API**: Implement endpoints using new tables
3. **Email Alerts**: Regime change email notifications
4. **Mobile PWA**: Progressive Web App features
5. **API Rate Limiting**: Implement tier-based rate limits

**Reference Files**:
- Plan: `.claude/plans/memoized-hugging-truffle.md`
- Master Agent: `shared/master_agent/`
- Session History: See CHANGELOG.md for Sessions 25-30

---

## Important Notes

- **Brand Assets**: Always reference `/sentimark-brand/` for exact values
- **Deployment**: Large zips (200MB+) may timeout - use Kudu API or Azure specialist agent
- **DB Password**: Contains special char `&` - needs quoting in shell commands
- **Gemini**: Only use Gemini 3 models (never 2.5 or lower)
- **Session History**: See `CHANGELOG.md` for detailed session logs

---

## Plan Storage

**Location**: `.claude/plans/` (project directory)
- Format: `YYYY-MM-DD-<feature-name>.md`
- NEVER save to global `~/.claude/plans/`
