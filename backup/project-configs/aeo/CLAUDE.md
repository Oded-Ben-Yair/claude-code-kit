# AEO Platform - Seekapa.com

## Current Status: 10/10 Production Ready + Competitor Intelligence

| Metric | Value |
|--------|-------|
| **Dashboard Score** | 10/10 |
| **E2E Tests** | 25/25 passing |
| **Last Deploy** | January 20, 2026 |
| **API Version** | v23-writesonic-jan20 |
| **Competitor Profiles** | 19 brokers (data complete) |
| **Status** | Live in Production |

### Active Development: Competitor Comparison UX
**Handoff document**: `NEXT-SESSION.md` - Read this for full context on enhancement plans

---

## Production URLs

| Service | URL |
|---------|-----|
| **Dashboard** | https://thankful-rock-06e01f803.3.azurestaticapps.net/ |
| **Backend API** | https://aeo-api.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/ |
| **Daily Audit Function** | https://func-aeo-audit-prod.azurewebsites.net/ |

---

## Automated Daily Audits (January 12, 2026)

**Status**: ACTIVE - Azure Function running daily at 7 AM UTC

### Schedule
- **Time**: 7:00 AM UTC daily
- **Regions**: All 6 GCC (ae, sa, kw, qa, bh, om)
- **Platforms**: ChatGPT, Perplexity (Google AIO excluded - requires browser)

### Endpoints

| Endpoint | Auth | Purpose |
|----------|------|---------|
| `/api/health` | None | Health check |
| `/api/trigger` | Function Key | Manual full audit |
| `/api/quick?region=ae&prompts=10` | Function Key | Quick single-region audit |

### Manual Trigger

```bash
# Health check
curl "https://func-aeo-audit-prod.azurewebsites.net/api/health"

# Quick audit (requires function key)
curl "https://func-aeo-audit-prod.azurewebsites.net/api/quick?region=ae&prompts=10&code=<FUNCTION_KEY>"
```

### Function App Details
- **Name**: func-aeo-audit-prod
- **Resource Group**: AZAI_group
- **Runtime**: Python 3.11
- **Plan**: Consumption (serverless)

---

## Quick Start

```bash
# Run locally
cd /home/odedbe/projects/aeo

# Terminal 1: Backend API
source venv/bin/activate && PYTHONPATH=. uvicorn api.main:app --host 0.0.0.0 --port 8000

# Terminal 2: Dashboard
cd dashboard && npm run dev

# Run E2E tests
cd dashboard && npx playwright test --project=chromium

# Deploy to Azure
cd dashboard && npm run build && npx swa deploy out --app-name aeo-dashboard-swa --env production
```

---

## Project Overview

Answer Engine Optimization (AEO) platform for monitoring Seekapa.com's sentiment across AI answer engines.

| Aspect | Details |
|--------|---------|
| **Market** | GCC Region (UAE primary), Arabic language |
| **Platforms** | ChatGPT, Google AI Overviews, Perplexity |
| **Tech Stack** | Next.js 14, FastAPI, Azure Cosmos DB |

---

## Architecture

```
/home/odedbe/projects/aeo/
├── dashboard/                 # Next.js frontend (Azure Static Web Apps)
│   ├── app/                   # App Router pages
│   ├── components/            # React components
│   │   ├── dashboard/         # Page-specific components
│   │   └── ui/                # Reusable UI (skeleton, toast, error-boundary)
│   ├── lib/                   # Utilities (api-client, hooks, types)
│   └── e2e/                   # Playwright tests (25 tests)
│
├── api/                       # FastAPI backend (Azure Container Apps)
│   ├── routes/                # API endpoints
│   └── config.py              # Configuration
│
├── src/                       # Python core
│   ├── core/                  # auditor.py, analyzer.py, reporter.py
│   ├── platforms/             # Platform integrations
│   └── storage/               # Cosmos DB client
│
└── prompts/                   # Arabic/English prompt library
```

---

## Key Dashboard Components

| Component | Purpose | Location |
|-----------|---------|----------|
| ErrorBoundary | Catches React errors, Sentry integration | `components/ui/error-boundary.tsx` |
| Skeleton | Loading states with shimmer | `components/ui/skeleton.tsx` |
| Toast (Sonner) | Error notifications, glassmorphism | `lib/swr-provider.tsx` |
| useHydrated | Prevents hydration mismatches | `lib/hooks.ts` |
| useApiBaseUrl | Dynamic API URL (local/prod) | `lib/hooks.ts` |

---

## E2E Test Suites

| Suite | Tests | File |
|-------|-------|------|
| Accessibility (WCAG AA) | 9 | `e2e/accessibility.spec.ts` |
| Browser Compatibility | 9 | `e2e/browser-compat.spec.ts` |
| RTL/Responsive | 7 | `e2e/rtl.spec.ts` |

Run all: `npx playwright test --project=chromium`

---

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/metrics/kpi` | GET | KPI cards data |
| `/api/metrics/platforms` | GET | Platform breakdown |
| `/api/metrics/trend` | GET | 7-day sentiment trend |
| `/api/audits` | GET/POST | Audit history & trigger |
| `/api/alerts` | GET | Active alerts |
| `/api/prompts` | GET | Monitored prompts |

---

## Key Prompts Monitored

| Category | Arabic | English |
|----------|--------|---------|
| Safety | هل Seekapa آمن للتداول | is seekapa safe |
| Trust | is seekapa a scam? | is seekapa legitimate |
| Withdrawals | seekapa withdraw policy | withdrawal issues |
| Comparison | الفرق بين Seekapa و eToro | seekapa vs etoro |

---

## Development Notes

### Accessibility
- WCAG AA compliant (4.5:1+ contrast ratios)
- Use `text-gray-400` (not `text-gray-500`) for secondary text
- Focus indicators: purple glow (`#A605B6`)
- Supports reduced motion & high contrast modes

### Hydration
- Always use `useHydrated()` hook for client-only rendering
- Use `useApiBaseUrl()` for dynamic API URLs
- Add `suppressHydrationWarning` for time-based content

### Styling
- Glass morphism: `.glass-card` class
- Gradient text: `.gradient-text` class
- Skeleton shimmer: `<Skeleton shimmer />` prop
- Arabic font: Tajawal (applied automatically)

---

## Performance Optimization (Dec 7, 2025)

### Manus 99-Agent Audit Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Audit Score** | 4.9/10 | 8.5+/10 | +73% |
| **API Latency (p50)** | 600-900ms | ~230ms | ~70% faster |
| **Cache Headers** | None | max-age=300-3600 | Browser/CDN caching |
| **Static Assets** | 30s cache | Immutable (1yr) | Repeat visits instant |

### Issues Identified & Fixed

| Issue | Frequency | Solution |
|-------|-----------|----------|
| High API Latency | 97% | TTL caching with cachetools |
| Missing Cache Headers | 81% | CacheControlMiddleware |
| Poor LCP | 47% | Preconnect hints, lazy loading |
| Bundle Issues | 31% | Dynamic imports, SWR optimization |

### Caching Implementation

**Backend (api/main.py)**:
- `CacheControlMiddleware` adds Cache-Control headers per endpoint
- TTL varies: 3 min (alerts) → 1 hour (prompts)

**Backend (api/routes/dashboard.py)**:
- In-memory TTL caches using `cachetools.TTLCache`
- Fixed N+1 query with `_compute_prompt_stats()` helper

**Frontend (dashboard/lib/swr-provider.tsx)**:
- SWR deduping: 5s → 30s (matches API cache TTL)
- Focus throttle: 30s (prevents excessive revalidation)

**Static Assets (staticwebapp.config.json)**:
- JS/CSS/fonts: `max-age=31536000, immutable`
- Preconnect to API endpoint in layout.tsx

### Cache TTL Configuration

| Endpoint | TTL | Rationale |
|----------|-----|-----------|
| `/api/metrics/kpi` | 5 min | KPI data changes infrequently |
| `/api/metrics/trend` | 10 min | Trend data is stable |
| `/api/metrics/platforms` | 5 min | Platform stats |
| `/api/alerts` | 3 min | Alerts need fresher data |
| `/api/prompts` | 1 hour | Prompts are mostly static |
| `/api/audits` | 5 min | Audit list |
| `/strategy` | 30 min | Strategy recommendations |
| `/report` | 10 min | Reports |

### Deployment Commands

```bash
# Backend (Azure Container Apps)
az acr build --registry seekapatrainingacr --image aeo-api:v18-region-filter-fix --file Dockerfile .
az containerapp update --name aeo-api --resource-group AZAI_group --image seekapatrainingacr.azurecr.io/aeo-api:v18-region-filter-fix

# Frontend (Azure Static Web Apps)
cd dashboard && npm run build && npx swa deploy out --app-name aeo-dashboard-swa --env production
```

### Verification

```bash
# Check API cache headers
curl -I "https://aeo-api.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/api/metrics/kpi"
# Expected: cache-control: public, max-age=300

# Check API latency
curl -w "TTFB: %{time_starttransfer}s\n" -o /dev/null -s "https://aeo-api.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/api/metrics/kpi"
# Expected: ~230ms
```

---

## Environment Variables

Required in `.env`:
```
COSMOS_ENDPOINT=https://aeo-seekapa-db.documents.azure.com:443/
COSMOS_KEY=<primary-key>
COSMOS_DATABASE=aeo_data
AZURE_OPENAI_ENDPOINT=<endpoint>
AZURE_OPENAI_KEY=<key>
```

---

## Session History

| Date | Focus | Result |
|------|-------|--------|
| 2025-12-29 | **Competitor UX Overhaul** | Cleaned 24→19 brokers, new Slots Dock UX, data populated. See `NEXT-SESSION.md` |
| 2025-12-29 | **Regional Filter Fix** | Fixed build_region_filter() with IS_NULL(), updated docs, deployed v18 |
| 2025-12-11 | **Full Audit + Writesonic** | All 6 regions validated, Writesonic reports analyzed, sentiment analysis complete |
| 2025-12-09 | **Regional Fix** | Fixed audit.py enum serialization, added API keys to Container App, 6 regions audited |
| 2025-12-08 | **Marketing Research** | Multi-LLM research complete, Q1-Q4 2026 roadmap ready |
| 2025-12-07 | **GCC Regional System** | Region selector deployed, 6 regions audited (540 queries total) |
| 2025-12-07 | Performance Optimization | Manus audit 4.9→8.5+, API latency 70% faster, caching implemented |
| 2025-12-07 | Visual Testing + Manus Prep | All 6 pages visually verified, Manus 1000-agent prompt created |
| 2025-12-04 | 10/10 Production | 4 sprints, 25/25 tests, deployed |
| 2025-12-04 | Data Fix | Auditor-Analyzer integration, trend chart |

---

## Competitor Intelligence System (December 29, 2025)

**Status**: ACTIVE - New Slots Dock UX implemented, ready for enhancement
**Handoff**: See `NEXT-SESSION.md` for full enhancement roadmap

### Current State

| Metric | Value |
|--------|-------|
| Total Brokers | 19 (cleaned from 24) |
| Data Complete | 100% |
| UX Pattern | Compare Slots Dock |
| Seekapa Position | #1 of 18 (37.7% visibility) |

### Broker Tiers

| Tier | Brokers | Visibility |
|------|---------|------------|
| **Top Tier** | AvaTrade, Exness, XM, Pepperstone | 15%+ |
| **Major** | IC Markets, FxPro, Axi, Vantage, HFM, FBS, CFI Group | 5-14% |
| **MENA Regional** | FundedNext, ATFX MENA, ThinkTrader, Xlence MENA, Tadawol Pro, Traze, GFX | <5% |

### Key Files

| File | Purpose |
|------|---------|
| `dashboard/app/competitors/page.tsx` | Slots Dock UX (main enhancement target) |
| `api/routes/competitors.py` | Backend routes + COMPETITORS list |
| `dashboard/lib/hooks.ts` | SWR hooks for competitor data |

### Enhancement Opportunities (Next Session)

1. **Animations** - Framer Motion for slot transitions
2. **Drag-and-drop** - Reorder comparison slots
3. **Broker logos** - Visual identity for each broker
4. **Mobile optimization** - Responsive slots layout
5. **Export** - PDF/CSV comparison reports
6. **Historical trends** - Position changes over time

---

## Writesonic AEO Report (January 20, 2026) - LATEST

**Status**: INTEGRATED - Data updated in API + prompts library
**Location**: `/home/odedbe/projects/aeo/20-1-2026 reports/`
**Analysis**: `/home/odedbe/projects/aeo/20-1-2026 reports/ANALYSIS.md`

### Competitive Position (Improved from Dec 11)

| Rank | Brand | Visibility | Change | Notes |
|------|-------|-----------|--------|-------|
| 1 | AvaTrade | 32.41% | +6.46 | Market leader, growing |
| 2 | Exness | 26.88% | +4.28 | Strong growth |
| 3 | XM | 13.83% | +0.83 | Holding position |
| 4 | Pepperstone | 11.86% | +0.02 | Stable |
| **5** | **Seekapa** | **9.88%** | **+0.71** | Growing (+0.71) |
| 6 | Binance | 8.70% | +0.91 | Crypto crossover |
| 7 | Evest | 7.11% | +0.32 | Regional player |
| 8 | Equiti | 3.16% | -0.31 | Declining |

**Key Insight**: All top 6 growing. Seekapa maintains #5. Gap to leader widened (32.4% vs 9.9%).

### Platform Performance (Competitive Queries)

| Platform | Visibility | Change | Citation | Citation Change |
|----------|------------|--------|----------|-----------------|
| Perplexity | 11% | +1 | 6% | 0 |
| Google AI Overviews | 9% | +1 | 0% | 0 |
| ChatGPT | 9% | 0 | 11% | +2 |

### Brand-Specific Queries (100% Visibility Prompts)

Seekapa dominates brand queries with 92.3% Share of Voice:

**Top Arabic (100% visibility):**
- FSA Seychelles license protection (+13.06 change)
- Seekapa vs eToro vs AvaTrade Islamic accounts (+9.88)
- Seychelles license concerns (+5.35)
- Withdrawal complaints monitoring (+1.31)

**Top English (100% visibility):**
- "is seekapa a scam?" (+3.98)
- Mixed reviews confusion prompt (+4.00)
- Tool comparison (Currency Meter, Trend Analysis) (+1.73)
- Withdraw issues query (+0.98)

### Top Cited Seekapa Content

| Page | Citation Share | Change |
|------|----------------|--------|
| Homepage (EN) | 5.48% | -2.04 |
| Complaints (EN) | 5.48% | +2.32 |
| About Us (AR) | 3.56% | +1.85 |
| Homepage (AR) | 3.16% | +0.85 |
| Currency Meter | 2.74% | +1.11 |

**Note**: Complaints page gaining citations (+2.32%) - trust signals working.

### Content Opportunities (No Seekapa Mentions)

These prompts don't mention Seekapa - content gaps to fill:

**Arabic:**
- Islamic trading compliance verification
- Platform blacklist for withdrawal refusals
- Withdrawal fee solutions

**English:**
- Red flags for forex scams
- Best platforms for beginners
- Fastest withdrawal brokers

### Changes Made (Jan 20, 2026)

1. ✅ Updated competitor visibility in `api/routes/competitors.py`
2. ✅ Updated competitor insights with new data
3. ✅ Added 9 new Arabic prompts to monitoring
4. ✅ Added 5 new English prompts to monitoring
5. ✅ Prompts library updated to v2.1

---

## Writesonic AEO Report (December 11, 2025)

**Status**: HISTORICAL - Superseded by Jan 20 report
**Location**: `/home/odedbe/projects/aeo/12-11-2025 reports/`

### Competitive Position

| Rank | Brand | Visibility | Change |
|------|-------|-----------|--------|
| 1 | AvaTrade | 24% | -6% |
| 2 | Exness | 22% | +2% |
| 3 | XM | 16% | +7% |
| 4 | Pepperstone | 15% | +3% |
| **5** | **Seekapa** | **10%** | **+1%** |
| 6 | Binance | 6% | -1% |

**Key Insight**: Seekapa is mid-pack with modest positive momentum. Top 4 control 77%. XM gaining (+7%).

### Platform Visibility

| Platform | Visibility | Change |
|----------|-----------|--------|
| Google AI Overviews | 19% | -1% |
| ChatGPT | 18% | 0% |
| Perplexity | 18% | 0% |

### Domain Authority Analysis

| Domain | DR Score | Citations |
|--------|----------|-----------|
| brokerchooser.com | 64 | 29 |
| reddit.com | 95 | 18 |
| forexbrokers.com | 58 | 15 |
| youtube.com | 99 | 15 |
| **seekapa.com** | **35** | **12** |

**Gap**: Third-party sources cited 6x more than first-party. Domain authority improvement critical.

### Sentiment Analysis (CRITICAL)

| Type | Percentage |
|------|------------|
| Negative | 70% |
| Neutral (negative undertone) | 30% |
| Positive | 0% |

**Key Finding**: Zero positive-intent queries ranking. All top prompts are scam/withdrawal related.

### Top Negative Themes

**Arabic** (Higher emotional intensity):
- "نصب وسرقة فلوس" - Scam/theft accusations
- "ما يقدرون يسحبون" - Withdrawal inability

**English**:
- "is seekapa a scam?" - Direct accusation
- "seekapa withdraw issues" - Process concerns

### Regional Data (Live Production - Dec 11)

| Region | Visibility | Sentiment |
|--------|-----------|-----------|
| All GCC | 92% | 0.29 |
| UAE | 92% | 0.27 |
| Saudi Arabia | 92% | 0.35 |
| Kuwait | 92% | 0.38 |
| Qatar | 93% | 0.30 |
| Bahrain | 92% | 0.34 |
| Oman | 93% | 0.35 |

### Priority Actions

1. **Content Strategy**: Trust & Transparency Hub, Withdrawal Policy page
2. **Domain Authority**: Target backlinks from DR 50+ sites
3. **Video Content**: Testimonials of successful withdrawals
4. **Schema Markup**: Improve AI citation rate

---

## Marketing Research (December 2025)

**Status**: COMPLETE - Ready for Q1 2026 Execution
**Location**: `.claude/marketing-research/`

### Quick Reference

| Document | Purpose |
|----------|---------|
| `NEXT-SESSION-BRIEF.md` | Start here for implementation |
| `reports/executive-summary.md` | Full strategy + budget |
| `scorecards/tool-comparison.md` | Tool decisions |

### Tools Already Owned

| Tool | Use |
|------|-----|
| Writesonic Professional | Programmatic SEO (200-400% ROI) |
| ElevenLabs | Arabic voice content |
| HeyGen | AI video avatars |

### 2026 Roadmap Summary

| Quarter | Focus |
|---------|-------|
| Q1 | Security hardening (3.76→8.0+), Writesonic, E-E-A-T |
| Q2 | ElevenLabs + HeyGen multimedia |
| Q3 | Zoho CRM + ActiveCampaign |
| Q4 | Automation + 2027 planning |

### Key Finding

Arabic content generates **3x higher engagement** than English in GCC markets. Strategy is Arabic-first, not translations.

---

## Manus Deep Evaluation (COMPLETED)

**Status**: ✅ Audit completed, fixes implemented and deployed

**Audit Location**: `/home/odedbe/projects/sentimark/e2e-audit-research/`

**Audit Summary**:
- 99 Performance Engineer agents analyzed the platform
- Initial score: 4.9/10
- Post-optimization score: 8.5+/10

**All P0/P1 Issues Fixed**:
- ✅ High API latency (97%) → TTL caching
- ✅ Missing cache headers (81%) → CacheControlMiddleware
- ✅ Poor LCP (47%) → Preconnect hints
- ✅ Bundle issues (31%) → SWR optimization

---

## Visual Testing Completed (Dec 7, 2025)

All pages screenshot-verified on Azure production:

| Page | Status | Key Elements |
|------|--------|--------------|
| Dashboard | Verified | KPIs, Trend Chart, Platform Breakdown, Quick Actions |
| Reports | Verified | Filters, 50 results table, sorting |
| Prompts | Verified | 30 prompts (15 EN/15 AR), filters, priority badges |
| Alerts | Verified | Severity filter, empty state |
| Strategy | Verified | Risk Summary, Priority Actions, 5 Strategy Cards |
| Run Audit | Verified | Button triggers audit, progress indicator |

---

## Manus 204-Agent Audit Results (Dec 7, 2025)

**Overall Score: 5.07/10** - Requires urgent intervention

| Batch | Agents | Score | Status |
|-------|--------|-------|--------|
| Performance | 99 | 4.90/10 | ✅ **FIXED** |
| Security | 42 | 3.76/10 | 🔴 **CRITICAL** |
| UX | 63 | 6.19/10 | 🟡 **MODERATE** |

### Security Findings (P0 - CRITICAL)

| Issue | Consensus | Fix Required |
|-------|-----------|--------------|
| No API Authentication | 100% | Add JWT/OAuth 2.0 |
| Broken Access Control | 100% | Protect all endpoints |
| No Rate Limiting | 100% | Add slowapi middleware |
| Missing API Headers | 100% | HSTS, CSP, X-Frame-Options |
| Exposed /docs | 90% | Disable in production |
| Weak Frontend CSP | 85% | Remove unsafe-inline/eval |

### UX Findings (P0-P1)

| Issue | Consensus | Fix Required |
|-------|-----------|--------------|
| Non-Responsive Layout | 80% | Mobile hamburger menu |
| No Audit Feedback | 70% | Loading spinner + toast |
| Unlabeled View Button | 50% | Add text label |

### Fix Priority

1. **Week 1**: Security P0 (Auth, Rate Limiting, Headers)
2. **Week 2**: Security P1 + UX P0 (CSP, Responsive)
3. **Week 3-4**: UX Polish (Navigation, Tables)

**Full Report**: `MANUS_AUDIT_SUMMARY.md`

---

## GCC Regional Filtering System (Updated - Dec 29, 2025)

**Status**: ✅ Fully operational with improved null handling

### Regions Supported

| Region | Code | Data Records | Last Audit |
|--------|------|--------------|------------|
| UAE | `ae` | 3,238 | Dec 29, 2025 |
| Saudi Arabia | `sa` | 120 | Dec 11, 2025 |
| Kuwait | `kw` | 120 | Dec 11, 2025 |
| Qatar | `qa` | 120 | Dec 11, 2025 |
| Bahrain | `bh` | 120 | Dec 11, 2025 |
| Oman | `om` | 120 | Dec 11, 2025 |
| All GCC | `gcc` | 60 | Dec 29, 2025 |

### Key Files

| File | Purpose |
|------|---------|
| `dashboard/lib/region-context.tsx` | React context for region state |
| `dashboard/components/dashboard/region-selector.tsx` | Dropdown selector in navbar |
| `dashboard/lib/hooks.ts` | SWR hooks with region filtering |
| `src/storage/cosmos_client.py` | `build_region_filter()` function |
| `api/routes/*.py` | All endpoints accept `?region=` param |

### How It Works

1. **URL is source of truth**: `?region=sa` in URL
2. **localStorage persistence**: Saves last selected region
3. **All API calls filtered**: Data hooks pass region to backend
4. **Cosmos DB filtering**: `build_region_filter()` creates WHERE clause
5. **Cache invalidation**: Region-aware SWR cache keys

### Filter Logic (Updated Dec 29, 2025)

The `build_region_filter()` function handles:
- `gcc` or `null`: Returns all data (no filter)
- Specific region: Returns matching region OR null/undefined (legacy compatibility)

```python
# For specific regions, includes legacy data with null/undefined region
"AND (c.region = @region OR NOT IS_DEFINED(c.region) OR IS_NULL(c.region))"
```

### Important Notes

1. **KPI uses 7-day window**: Only shows data from last 7 days
2. **Regional audits need refresh**: SA/KW/etc have Dec 11 data (outside 7-day window)
3. **UAE is default**: When selecting "All GCC", audits run with region='ae'

### Testing

```bash
# Test region filtering
curl "https://aeo-api.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/api/metrics/kpi?region=sa"
curl "https://aeo-api.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/api/metrics/kpi?region=gcc"

# Test with longer time window (30 days)
curl "https://aeo-api.victoriousbeach-8c9d46fb.swedencentral.azurecontainerapps.io/api/metrics/trend?days=30&region=sa"
```

---

## Future Enhancements (Out of Scope)

Documented for future work:
- Full i18n framework (Arabic translations currently hardcoded)
- WebSocket real-time updates
- Offline support / service worker
- Export PDF functionality
- Automated daily audits via Azure Functions
- Region-specific prompts (different prompts per country)
