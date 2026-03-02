# Daily Market Overview Email System - Architecture Document

**Version**: 2.0 (Rebuild)
**Date**: 2026-01-25
**Author**: Claude Code / Orchestrator
**Status**: Draft - Pending Approval

---

## 1. Executive Summary

The Daily Market Overview Email System generates and sends daily market intelligence emails to Seekapa's marketing team and subscribers. The system was previously functional but broke during recent changes that collapsed the two-part architecture (teaser email + full report landing page) into a single email-only output.

This rebuild restores the original architecture: a **teaser email** with dark theme, mini charts, and blurred preview sections that drives traffic to a **full report landing page** hosted on Azure Blob Storage. The landing page provides interactive charts, detailed trading ideas, and comprehensive market analysis.

**Key Value Proposition**: Professional, Bloomberg-style market intelligence delivered daily at 7 AM Israel Time, with clear conversion funnel from email teaser to full report engagement.

---

## 2. System Overview

### 2.1 Purpose

Provide daily market overview to:
- 8 internal marketers (personalized by language preference)
- Subscribers (4 languages: EN, AR, ES, PT)
- Drive traffic to Seekapa trading platform via CTAs

### 2.2 Scope

**In Scope**:
- Email generation (teaser with blur)
- Landing page generation (full report)
- FMP market data integration
- Technical signal calculation
- Chart rendering (PNG for email, interactive for landing)
- Azure Blob deployment
- 4-language support (EN, AR, ES, PT)

**Out of Scope**:
- Email sending (SendGrid/Mailchimp - separate system)
- User authentication
- Real-time data updates
- PDF export
- V7 React app integration (deferred)

### 2.3 Key Stakeholders

| Role | Responsibility |
|------|----------------|
| Marketers (8) | Consume content, distribute to clients |
| Subscribers | Receive email, click to full report |
| Trading Desk | Provide trading ideas input |
| DevOps | Maintain infrastructure, monitor pipeline |

---

## 3. Architecture Overview

### 3.1 High-Level Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DATA SOURCES                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                          │
│  │  FMP API    │  │  Grok MCP   │  │  Economic   │                          │
│  │  (Quotes)   │  │  (Intel)    │  │  Calendar   │                          │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                          │
│         │                │                │                                  │
│         └────────────────┼────────────────┘                                  │
│                          ▼                                                   │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                  EMAIL OVERVIEW ORCHESTRATOR                           │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │  │
│  │  │Phase 1  │  │Phase 2  │  │Phase 3  │  │Phase 4  │  │Phase 5      │  │  │
│  │  │Collect  │─▶│Calculate│─▶│Generate │─▶│Render   │─▶│Generate     │  │  │
│  │  │Data     │  │Signals  │  │Content  │  │Charts   │  │Email HTML   │  │  │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────────┘  │  │
│  │                                                              │         │  │
│  │  ┌─────────────┐  ┌─────────────┐                           │         │  │
│  │  │Phase 5.5    │  │Phase 5.6    │◄──────────────────────────┘         │  │
│  │  │Generate     │─▶│Deploy to    │        NEW PHASES                   │  │
│  │  │Landing Page │  │Azure Blob   │                                     │  │
│  │  └─────────────┘  └──────┬──────┘                                     │  │
│  │                          │                                             │  │
│  │  ┌─────────────┐         │                                             │  │
│  │  │Phase 6      │◄────────┘                                             │  │
│  │  │Send/Preview │  (full_report_url passed back)                        │  │
│  │  └─────────────┘                                                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         OUTPUT ARTIFACTS                                     │
│                                                                              │
│  ┌─────────────────────────┐         ┌─────────────────────────────────┐   │
│  │     TEASER EMAIL        │  LINK   │       FULL REPORT               │   │
│  │  ┌───────────────────┐  │ ──────▶ │  ┌───────────────────────────┐  │   │
│  │  │ Dark Theme        │  │         │  │ Dark Theme                │  │   │
│  │  │ Morning Brief     │  │         │  │ Hero + Headline           │  │   │
│  │  │ Ticker Strip      │  │         │  │ Morning Brief (expanded)  │  │   │
│  │  │ 6 Asset Cards     │  │         │  │ Market Signals + Charts   │  │   │
│  │  │   - Mini Charts   │  │         │  │ Top Movers (animated)     │  │   │
│  │  │   - T1/T2 targets │  │         │  │ Trading Ideas (6 cards)   │  │   │
│  │  │   - BUY/SELL      │  │         │  │ Week Ahead                │  │   │
│  │  │ Trading Ideas     │  │         │  │ Seekapa CTA               │  │   │
│  │  │   (BLURRED)       │  │         │  └───────────────────────────┘  │   │
│  │  │ "View Full Report"│  │         │                                  │   │
│  │  │ CTA Button        │  │         │  URL: blob.../landing-pages/    │   │
│  │  └───────────────────┘  │         │        market-overview/{date}/  │   │
│  │                         │         │        {lang}.html              │   │
│  │  Delivered via Email    │         │                                  │   │
│  └─────────────────────────┘         └─────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Component Description

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Email Overview Orchestrator** | Azure Durable Functions (Python) | Coordinates 6-phase workflow |
| **FMP Client** | Python + httpx | Fetches market quotes, OHLC data |
| **Grok Client** | Python + MCP | Generates morning brief, thesis text |
| **Signal Calculator** | Python + TA-Lib | Calculates RSI, MA crossovers, signal scores |
| **Chart Renderer** | Playwright + ApexCharts | Renders PNG charts for email |
| **Email Template (V9)** | Jinja2 + HTML | Dark theme teaser email |
| **Landing Page Template** | Jinja2 + HTML + Tailwind | Full report with interactive charts |
| **Azure Blob Storage** | Azure SDK | Hosts landing pages, chart images |

### 3.3 Data Flow

```
1. Timer/HTTP triggers orchestrator at 5 AM UTC (7 AM Israel)
2. Parallel data collection:
   - FMP API → quotes for 8 ticker symbols, OHLC for 6 featured assets
   - Economic Calendar API → next 7 days events
   - Grok MCP → market intelligence summary
3. Signal calculation using TA indicators
4. Content generation via Grok (morning brief bullets, asset thesis)
5. Chart rendering via Playwright (6 PNG charts)
6. Email HTML generation (V9 dark template)
7. Landing page HTML generation (V6-based template)
8. Deploy landing page to Azure Blob
9. Pass full_report_url to email template
10. Upload email preview / send via external service
```

---

## 4. Technical Details

### 4.1 Technology Stack

| Layer | Technology | Version | Justification |
|-------|------------|---------|---------------|
| Orchestration | Azure Durable Functions | Python 3.12 | Existing infra, parallel task support |
| Data Fetch | httpx + FMP API | 0.27+ | Async HTTP, reliable market data |
| AI Content | Grok MCP | Latest | Real-time market intelligence |
| Charts | Playwright + ApexCharts | 1.40+ | Headless rendering, professional charts |
| Templates | Jinja2 | 3.x | Flexible HTML generation |
| Styling | Tailwind CSS (CDN) | 3.x | Rapid dark theme styling |
| Storage | Azure Blob | Latest SDK | Existing container, static hosting |
| Database | PostgreSQL | 15+ | Existing shared infra |

### 4.2 API Design

#### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/email-overview/generate` | Manual trigger (optional: preview_only, languages, send_to) |
| GET | `/api/email-overview/status/{instance_id}` | Check orchestration status |
| Timer | `0 0 5 * * *` | Daily trigger at 5 AM UTC |

#### Request/Response Examples

**Generate Email**:
```json
POST /api/email-overview/generate
{
  "trigger": "manual",
  "languages": ["en", "ar"],
  "preview_only": true,
  "featured_assets": ["XAUUSD", "CLUSD", "EURUSD", "BTCUSD"]
}

Response:
{
  "instance_id": "abc123",
  "status_url": "/api/email-overview/status/abc123"
}
```

**Status Check**:
```json
GET /api/email-overview/status/abc123

Response:
{
  "success": true,
  "generated_at": "2026-01-25T05:30:00Z",
  "emails": {
    "en": {
      "html_url": "https://stmarketingnewsletter.blob.core.windows.net/email-previews/2026-01-25/preview_en.html",
      "html_size": 85432,
      "sent": false
    }
  },
  "landing_pages": {
    "en": "https://stmarketingnewsletter.blob.core.windows.net/landing-pages/market-overview/2026-01-25/en.html"
  },
  "phases": {
    "data_collection": true,
    "signals": true,
    "content_generation": true,
    "charts": {"rendered": 6, "failed": 0},
    "email_generation": {"en": true, "ar": true},
    "landing_page_generation": {"en": true, "ar": true},
    "landing_page_deployment": true
  }
}
```

### 4.3 Data Models

#### Featured Asset

```python
@dataclass
class FeaturedAsset:
    symbol: str           # "XAUUSD"
    name: str             # "Gold"
    category: str         # "commodity"
    price: float          # 2048.50
    change_percent: float # 2.3
    change_display: str   # "+2.30%"
    signal_score: int     # 8 (0-10)
    signal_label: str     # "bullish" | "bearish" | "neutral"
    is_bullish: bool
    is_bearish: bool
    ohlc_data: List[OHLC] # Last 30 candles
    chart_png_url: str    # Blob URL
    thesis_line_1: str    # "Gold breaks $2,048 resistance..."
    thesis_line_2: str    # "Watch for Fed speech impact"
    target_1: float       # 2065.00
    target_2: float       # 2085.00
    stop_loss: float      # 2020.00
    trade_url: str        # "https://seekapa.com/trade/xauusd"
```

#### Ticker Strip Item

```python
@dataclass
class TickerItem:
    symbol: str           # "XAUUSD"
    change_percent: float # 2.3
    is_positive: bool     # True
```

#### Trading Idea

```python
@dataclass
class TradingIdea:
    symbol: str           # "XAUUSD"
    direction: str        # "LONG" | "SHORT"
    entry: float          # 2920.00
    target: float         # 2980.00
    stop: float           # 2890.00
    reward_risk: str      # "3:1"
    rationale: str        # "Breakout above resistance..."
```

### 4.4 Template Variables

#### Email Template (V9) Context

```python
{
    "language": "en",
    "is_rtl": False,
    "date_display": "January 25, 2026",
    "market_regime": "risk_on",  # risk_on | risk_off | neutral
    "morning_brief": [
        "Gold breaks $2,048 resistance on Fed pause signal +2.3%",
        "Oil +1.8% — surprise inventory draw, watch $79 pivot",
        ...
    ],
    "ticker_strip": [TickerItem, ...],
    "featured_assets": [FeaturedAsset, ...],
    "top_movers": {
        "gainers": [...],
        "losers": [...]
    },
    "trading_ideas": [TradingIdea, ...],  # BLURRED in email
    "week_ahead": [EconomicEvent, ...],
    "full_report_url": "https://...",  # NEW
    "cta_url": "https://seekapa.com/register",
    "t": {translations dict}
}
```

---

## 5. Infrastructure

### 5.1 Deployment Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           AZURE CLOUD                                     │
│                                                                           │
│  ┌─────────────────────┐     ┌─────────────────────────────────────────┐ │
│  │  Azure Functions    │     │  Azure Blob Storage                      │ │
│  │  (automation-       │     │  (stmarketingnewsletter)                 │ │
│  │   fabric-func)      │     │                                          │ │
│  │                     │     │  /email-previews/{date}/preview_{lang}   │ │
│  │  - Orchestrator     │────▶│  /landing-pages/market-overview/{date}/  │ │
│  │  - Activities       │     │  /email-charts/{date}/{symbol}.png       │ │
│  │  - HTTP Triggers    │     │  /brand-assets/seekapa-logo-v3.png       │ │
│  └─────────────────────┘     └─────────────────────────────────────────┘ │
│           │                                                               │
│           │                                                               │
│  ┌────────▼────────┐     ┌─────────────────┐     ┌─────────────────────┐ │
│  │  Key Vault      │     │  PostgreSQL     │     │  Application        │ │
│  │  (kv-seekapa-   │     │  (automation_   │     │  Insights           │ │
│  │   apps)         │     │   fabric)       │     │  (monitoring)       │ │
│  │                 │     │                 │     │                     │ │
│  │  - FMP_API_KEY  │     │  - marketers    │     │  - Logs             │ │
│  │  - GROK_API_KEY │     │  - email_runs   │     │  - Metrics          │ │
│  │  - DB_CONN_STR  │     │  - assets       │     │  - Alerts           │ │
│  └─────────────────┘     └─────────────────┘     └─────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Environment Configuration

| Environment | URL | Purpose |
|-------------|-----|---------|
| Local Dev | localhost:7076 | Development, debugging |
| Production | automation-fabric-func.azurewebsites.net | Live system |

### 5.3 Storage URLs

| Asset Type | URL Pattern |
|------------|-------------|
| Email Preview | `https://stmarketingnewsletter.blob.core.windows.net/email-previews/{date}/preview_{lang}.html` |
| Landing Page | `https://stmarketingnewsletter.blob.core.windows.net/landing-pages/market-overview/{date}/{lang}.html` |
| Chart Images | `https://stmarketingnewsletter.blob.core.windows.net/email-charts/{date}/{symbol}.png` |
| Brand Assets | `https://stmarketingnewsletter.blob.core.windows.net/brand-assets/` |

### 5.4 Timer Schedule

```
Trigger: 0 0 5 * * * (5 AM UTC = 7 AM Israel Time)
Timeout: 10 minutes
Retry: 3 attempts with exponential backoff
```

---

## 6. Security

### 6.1 Secrets Management

| Secret | Storage | Purpose |
|--------|---------|---------|
| FMP_API_KEY | Key Vault | Market data API |
| GROK_API_KEY | Key Vault | AI content generation |
| DB_CONNECTION_STRING | Key Vault | PostgreSQL access |
| STORAGE_CONNECTION_STRING | Key Vault | Blob storage access |

### 6.2 Access Control

- Landing pages are **public** (no auth required)
- Email previews are **unlisted** (URL-based access)
- API endpoints require **Function Key** for manual triggers
- Database uses **app-specific user** (automation_app_user)

### 6.3 Security Checklist

- [x] Secrets stored in Key Vault (not hardcoded)
- [x] SQL parameterized queries (via ORM)
- [x] Input validation on API endpoints
- [x] CORS configured for dashboard domain
- [ ] Rate limiting (TODO)
- [ ] Content Security Policy headers (TODO)

---

## 7. Monitoring & Operations

### 7.1 Logging

| Log Level | Content |
|-----------|---------|
| INFO | Phase transitions, success metrics |
| WARNING | Non-critical failures (single chart fail) |
| ERROR | Phase failures, API errors |

### 7.2 Key Metrics

| Metric | Alert Threshold |
|--------|-----------------|
| Orchestrator duration | > 5 minutes |
| FMP API failures | > 2 consecutive |
| Chart render failures | > 1 per run |
| Email size | > 100KB |

### 7.3 Recovery Procedures

| Failure | Recovery |
|---------|----------|
| FMP API timeout | Retry 3x, then use cached data |
| Chart render fail | Skip chart, log warning |
| Blob upload fail | Retry 3x, alert on fail |
| Orchestrator crash | Auto-retry via Durable Functions |

---

## 8. Implementation Plan

### 8.1 Task Breakdown

| # | Task | Priority | Effort | Dependencies |
|---|------|----------|--------|--------------|
| 1 | Create Dark Theme Email Template (V9) | P0 | Medium | None |
| 2 | Fix FMP Data Pipeline | P0 | Medium | None |
| 3 | Create Landing Page Generator Activity | P0 | Medium | None |
| 4 | Add Phase 5.5/5.6 to Orchestrator | P0 | Low | Task 3 |
| 5 | Update Email HTML Activity for V9 | P1 | Low | Tasks 1, 4 |
| 6 | E2E Tests & Visual Validation | P1 | Medium | All above |

### 8.2 Execution Sequence

```
Week 1 (Parallel):
├── Task 1: Dark Theme Email Template (V9)
├── Task 2: Fix FMP Data Pipeline
└── Task 3: Create Landing Page Generator Activity

Week 2 (Sequential):
├── Task 4: Add Landing Page Deployment Phase (depends on Task 3)
├── Task 5: Update Email HTML Activity (depends on Tasks 1, 4)
└── Task 6: E2E Tests and Visual Validation (depends on all)
```

### 8.3 Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `templates/email/market_overview_v9.html` | CREATE | Dark theme teaser email |
| `templates/landing-pages/market_overview_full.html` | CREATE | Full report landing page |
| `activities/landing_page_activities.py` | CREATE | Generate + deploy landing |
| `activities/email_overview_activities.py` | MODIFY | Fix FMP pipeline, V9 support |
| `orchestrators/email_overview_orchestrator.py` | MODIFY | Add Phase 5.5/5.6 |
| `tests/test_fmp_integration.py` | CREATE | FMP data validation |
| `tests/test_email_overview_v9_e2e.py` | CREATE | E2E tests |

---

## 9. Decisions Log

| Date | Decision | Rationale | Status |
|------|----------|-----------|--------|
| 2026-01-25 | Use V6 HTML template for landing (not V7 React) | V7 uses mock data, would require significant refactoring | Active |
| 2026-01-25 | Blur Trading Ideas in email teaser | Drive clicks to full report for conversion | Active |
| 2026-01-25 | Dark theme for both email and landing | Match former good state, professional appearance | Active |
| 2026-01-25 | Inline SVG sparklines in email | PNG charts have rendering issues in some clients | Proposed |

---

## 10. Appendix

### 10.1 Color Palette (V6 Dark Theme)

| Name | Hex | Usage |
|------|-----|-------|
| Background | #171515 | Page/email background |
| Card | #1E1C1C | Card surfaces |
| Elevated | #262424 | Elevated elements |
| Border | #333131 | Borders, dividers |
| Seekapa Indigo | #190571 | Primary brand |
| Seekapa Lavender | #9CA0F4 | Secondary brand |
| Success/Bullish | #10B981 | Positive values |
| Error/Bearish | #EF4444 | Negative values |
| Warning | #F59E0B | Warnings |
| Text Primary | #FFFFFF | Primary text |
| Text Secondary | #A3A3A3 | Secondary text |

### 10.2 Featured Assets (Default)

| Symbol | Name | Category |
|--------|------|----------|
| XAUUSD | Gold | Commodity |
| CLUSD | Oil | Commodity |
| EURUSD | EUR/USD | Forex |
| BTCUSD | Bitcoin | Crypto |
| ^GSPC | S&P 500 | Index |
| ^NDX | Nasdaq | Index |

### 10.3 Ticker Strip Symbols

XAUUSD, CLUSD, EURUSD, USDJPY, BTCUSD, ETHUSD, ^GSPC, ^NDX

### 10.4 Languages Supported

| Code | Language | RTL |
|------|----------|-----|
| en | English | No |
| ar | Arabic (Khaleeji) | Yes |
| es | Spanish (LatAm) | No |
| pt | Portuguese (Brazil) | No |

---

## 11. References

- Former Good State Screenshots: `25-01 context/former good one only missing charts upgrade/`
- Current Broken State Screenshots: `25-01 context/current email (no full report, clickable assest and missing data)/`
- V6 Landing Template: `src/runtime/templates/static-pages/market_overview_v6.html`
- V8 Email Template: `src/runtime/templates/email/market_overview_v8.html`
- Current Orchestrator: `src/runtime/orchestrators/email_overview_orchestrator.py`
- FMP Client: `src/runtime/integrations/fmp_client.py`

---

*Document generated by Claude Code Orchestrator - 2026-01-25*
*Part of automation-fabric project*
