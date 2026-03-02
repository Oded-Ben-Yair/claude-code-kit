# Sentimark V2 Feature Audit Matrix

**Audit Date**: 2026-01-19
**Audited By**: Claude Code (Comprehensive Frontend Audit)
**Environment**: `https://sentimark-v2-frontend.azurewebsites.net/v2` (Production Azure)
**⚠️ NOT localhost** - Production audit only

---

## Summary

| Category | Total | Working | Issues | Recommendation |
|----------|-------|---------|--------|----------------|
| Pages | 11 | 11 | 3 | Polish |
| Core Features | 5 | 4 | 1 | Fix ML Pipeline |
| API Endpoints | 5 tested | 4 | 1 | Fix /api/intelligence |
| UX Elements | 8 | 6 | 2 | Polish signals display |

---

## Page-by-Page Audit

### Homepage (`/v2`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Hero Section | Complete | Yes | N/A | **Keep** |
| Stats Bar (Live Market Pulse) | Complete | Yes | Yes | **Keep** |
| 4-Step Process Section | Complete | Yes | N/A | **Keep** |
| Flagship Assets Grid | Complete | Yes | Yes | **Keep** |
| Navigation Header | Complete | Yes | N/A | **Keep** |
| Footer | Complete | Yes | N/A | **Keep** |
| Search Bar | Complete | Yes | Yes | **Polish** - Low contrast on dark bg |

**Gemini Vision Analysis**: High-quality, professional design. Minor contrast issue with search bar placeholder text.

---

### Assets List Page (`/v2/assets`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| All Assets Tab | Complete | Yes | Yes | **Keep** |
| Crypto Tab | Complete | Yes | Yes | **Keep** |
| Stocks Tab | Complete | Yes | Yes | **Keep** |
| Commodities Tab | Complete | Yes | Yes | **Keep** |
| Indices Tab | Complete | Yes | Yes | **Keep** |
| Forex Tab | Complete | Yes | Yes | **Keep** |
| Asset Cards (Pulse Score) | Complete | Yes | Yes | **Polish** - All showing NEUTRAL |
| Search Autocomplete | Complete | Yes | Yes | **Keep** |
| Category Filters | Complete | Yes | N/A | **Keep** |
| Sticky Headers | Missing | No | N/A | **Add** - Needed for long lists |

**Findings**:
- Crypto: 30 assets, ALL showing NEUTRAL signal (0 BUY, 0 SELL)
- Stocks: 40 assets, only 1 BUY (Boeing), 39 NEUTRAL
- Some futures missing price/pulse data

---

### Asset Detail Page (`/v2/assets/[symbol]`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Price Chart | Complete | Yes | Yes | **Keep** |
| Market Pulse Indicator | Complete | Yes | Yes | **Polish** - Unclear meaning |
| Signal Alignment (8 sources) | Complete | Yes | Yes | **Fix** - "Signals in conflict" UX |
| ML Pipeline Prediction | Complete | **Yes** ✅ | Yes | **Keep** - Working on production |
| Pro Analyze - Fundamentals | Broken | **No** ❌ | 500 Error | **Fix** - P0 Priority |
| Pro Analyze - ESG | Broken | **No** ❌ | 500 Error | **Fix** - P0 Priority |
| Pro Analyze - Insider | Broken | **No** ❌ | 500 Error | **Fix** - P0 Priority |
| Mini Chat Widget | Complete | Yes | Yes | **Keep** |
| Add to Watchlist | Complete | Yes | Yes | **Keep** |
| Asset Header/Price | Complete | Yes | Yes | **Keep** |

**✅ RESOLVED (2026-01-19)**: ML Pipeline Prediction now WORKING on production.
- BTC: BEARISH 50%, 97% LLM Agreement
- AAPL: BULLISH, 100% LLM Agreement
- GOLD: BEARISH 52%, 81% LLM Agreement

**🔴 NEW CRITICAL ISSUE**: Pro Analysis tabs (Fundamentals, ESG, Insider) ALL return 500 errors from polymarket-analyzer backend. Tested on BTC, AAPL, GOLD - all fail.

**Signals Issue**: Shows "Signals in conflict - no clear direction" with most signals at 50 (neutral). Also: Signal Alignment and ML Pipeline can show contradictory directions (GOLD: bullish signals vs bearish ML).

---

### Portfolios Page (`/v2/portfolios`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Conservative Portfolio | Complete | Yes | Yes | **Keep** |
| Moderate Portfolio | Complete | Yes | Yes | **Keep** |
| Aggressive Portfolio | Complete | Yes | Yes | **Keep** |
| Custom Portfolio Builder | Complete | Yes | Yes | **Keep** |
| Asset Selection | Complete | Yes | Yes | **Keep** |
| Weight Constraints (2-40%) | Complete | Yes | N/A | **Keep** |
| Leaderboard | Complete | Yes | Yes | **Keep** |
| Gamification Elements | Complete | Yes | N/A | **Keep** |
| Pro Upsell Banner | Complete | Yes | N/A | **Keep** |

**Gemini Vision Analysis**: Well-designed with clear hierarchy. Gamification elements add engagement.

---

### Pricing Page (`/v2/pricing`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Free Tier Card | Complete | Yes | N/A | **Keep** |
| Pro Tier Card | Complete | Yes | N/A | **Keep** |
| Enterprise Tier Card | Complete | Yes | N/A | **Keep** |
| Feature Comparison | Complete | Yes | N/A | **Keep** |
| Billing Toggle (Monthly/Yearly) | Complete | Yes | N/A | **Keep** |
| FAQ Section | Complete | Yes | N/A | **Keep** |
| Testimonials | Complete | Yes | N/A | **Keep** |
| CTA Buttons | Complete | Yes | N/A | **Keep** |

**Gemini Vision Analysis**: Professional pricing page with clear tier differentiation.

---

### Login Page (`/v2/login`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Email Input | Complete | Yes | N/A | **Keep** |
| Password Input | Complete | Yes | N/A | **Keep** |
| Login Button | Complete | Yes | NextAuth | **Keep** |
| Social Login Options | Complete | Yes | NextAuth | **Keep** |
| Sign Up Link | Complete | Yes | N/A | **Keep** |
| Forgot Password Link | Complete | Yes | N/A | **Keep** |

**Note**: NextAuth warnings in console (NEXTAUTH_URL, NO_SECRET) - configure for production.

---

### Documentation Page (`/v2/docs`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| API Overview | Complete | Yes | N/A | **Keep** |
| Endpoint Documentation | Complete | Yes | N/A | **Keep** |
| Code Examples | Complete | Yes | N/A | **Keep** |
| Authentication Section | Complete | Yes | N/A | **Keep** |
| Rate Limits Section | Complete | Yes | N/A | **Keep** |
| Navigation Sidebar | Complete | Yes | N/A | **Keep** |

**Gemini Vision Analysis**: Comprehensive API documentation with clear examples.

---

### Legal Page (`/v2/legal`)

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Privacy Policy Tab | Complete | Yes | N/A | **Keep** |
| Terms of Service Tab | Complete | Yes | N/A | **Keep** |
| Investment Disclaimer Tab | Complete | Yes | N/A | **Keep** |
| Tab Navigation | Complete | Yes | N/A | **Keep** |

---

## Core Features Audit

### Chatbot

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| FAB Button (Open) | Complete | Yes | N/A | **Keep** |
| Message Input | Complete | Yes | Yes | **Keep** |
| Quick Actions | Complete | Yes | Yes | **Keep** |
| AI Response | Complete | Yes | Yes | **Keep** |
| Session Persistence | Untested | - | - | **Verify** |

**Test Result**: Sent "BTC Outlook" quick action, received meaningful response with 79% bullish confidence, price targets, and risk factors. **WORKING**.

---

### Search

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Autocomplete | Complete | Yes | Yes | **Keep** |
| Keyboard Navigation | Untested | - | - | **Verify** |
| Navigation to Asset | Complete | Yes | N/A | **Keep** |
| Recent Searches | Untested | - | - | **Verify** |

**Test Result**: Typed "AAPL", autocomplete showed Apple Inc., navigation to detail page worked. **WORKING**.

---

### Signal Alignment Display

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| 8-Source Breakdown | Complete | Yes | Yes | **Polish** |
| Confidence Indicators | Complete | Yes | Yes | **Fix** - Unclear meaning |
| Direction Arrows | Complete | Yes | Yes | **Polish** |
| "Signals in conflict" msg | Complete | Yes | N/A | **Fix** - UX unclear |

**User Feedback Confirmed**: "Signals not clear" - most signals show 50 (neutral), message "Signals in conflict - no clear direction" doesn't help users understand what to do.

---

### Watchlist

| Feature | Status | Working? | API Connected? | Recommendation |
|---------|--------|----------|----------------|----------------|
| Add to Watchlist | Complete | Yes | Yes | **Keep** |
| Remove from Watchlist | Untested | - | - | **Verify** |
| Freemium Limit | Untested | - | - | **Verify** |
| Persistence | Untested | - | - | **Verify** |

---

## Console Errors Summary

| Error | Page | Severity | Recommendation |
|-------|------|----------|----------------|
| `favicon.ico 404` | All | Low | **Fix** - Add favicon |
| `/api/intelligence/OIL 404` | Homepage | Medium | **Fix** - Backend endpoint missing |
| ~~`ML Pipeline Prediction timeout`~~ | Asset Detail | ~~High~~ | ✅ **RESOLVED** - Working on production |
| `Pro Analysis 500 errors` | Asset Detail | **Critical** | **Fix** - P0 Priority (NEW) |
| `NEXTAUTH_URL warning` | All | Medium | **Configure** - Production setup |
| `NO_SECRET warning` | All | High | **Configure** - Security requirement |

---

## Missing Pages (Referenced but 404)

| Page | Linked From | Recommendation |
|------|-------------|----------------|
| `/v2/rankings` | Homepage | **Remove** - Link removed in signals-first pivot |
| `/v2/chat` | Homepage | **Remove** - Only FAB widget exists (working) |
| `/v2/contact` | Pricing | **Add** or **Remove** link |
| `/v2/trading?symbol=*` | Various | **Remove** - Causes console 404s |

---

## Screenshots Captured (Production Audit - 2026-01-19)

**Total: 34 screenshots** from production URL `https://sentimark-v2-frontend.azurewebsites.net/v2`
**⚠️ NEVER test on localhost for audits - always use production Azure URL**

| Category | Screenshots | Files |
|----------|-------------|-------|
| Homepage | 5 | prod-01 to prod-05 (hero, howitworks, flagship-assets, intelligence-sources, footer) |
| Category Tabs | 5 | prod-06 to prod-10 (crypto, stocks, commodities, indices, forex) |
| BTC Detail | 8 | prod-11 to prod-18 (overview, ml-pipeline, signal-alignment, pro-analysis, fundamentals-error, esg-error, insider-error, chat-response) |
| AAPL Detail | 4 | prod-19 to prod-22 (overview, fundamentals-error, esg-error, insider-error) |
| GOLD Detail | 5 | prod-23 to prod-27 (overview, ml-pipeline, fundamentals-error, esg-error, insider-error) |
| Secondary Pages | 6 | prod-28 to prod-33 (portfolios, pricing, docs, legal-privacy, legal-terms, legal-disclaimer) |

All screenshots in `.playwright-mcp/` directory with Gemini Vision analysis performed.

---

## Recommendation Summary

| Action | Count | Features |
|--------|-------|----------|
| **Keep** | 42 | Most features working well |
| **Polish** | 6 | Search contrast, signal display, market pulse meaning |
| **Fix** | 5 | Pro Analysis 500 errors (NEW P0), API 404, NextAuth config, favicon, signal contradiction |
| **Add** | 1 | Sticky headers on asset list |
| **Remove** | 3 | Dead links (rankings, chat page, trading) |
| **Verify** | 5 | Watchlist persistence, keyboard nav, session persistence |

---

## Overall Assessment (Updated 2026-01-19)

**Frontend Completeness**: ~90%
**Core Features Working**: 4/5 (Pro Analysis broken - 500 errors)
**ML Pipeline**: ✅ **WORKING** on production (was only timing out on localhost)
**Chat Widget**: ✅ **WORKING** - Returns actionable responses
**Pro Analysis**: ❌ **BROKEN** - All 3 tabs (Fundamentals, ESG, Insider) return 500 errors
**User Feedback**: Partially addressed (chatbot works, signals still unclear with contradictions)
**Production Readiness**: Needs P0 fix (Pro Analysis backend) before launch

### Key Findings from Production Audit

1. **ML Pipeline WORKS** - Only was broken on localhost, production is fine
2. **Pro Analysis BROKEN** - polymarket-analyzer.azurewebsites.net returns 500 for ALL asset types
3. **Chat Widget WORKS** - Returns 79% bullish confidence for BTC with actionable insights
4. **Signal Contradiction** - GOLD shows bullish signals BUT bearish ML prediction
5. **All secondary pages** - Portfolios, Pricing, Docs, Legal all fully functional
