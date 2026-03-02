# Sentimark V2 Priority List

**Created**: 2026-01-19
**Updated**: 2026-01-19 12:20 UTC (Post-Production Audit)
**Based On**: Comprehensive Frontend Audit - PRODUCTION URL
**Purpose**: Actionable fix list for production readiness

---

## P0 - Critical (Fix Before Launch)

### 1. ~~ML Pipeline Prediction Timeout~~ ✅ RESOLVED
- **Status**: **WORKING ON PRODUCTION** (verified 2026-01-19)
- **Evidence**: BTC shows BEARISH 50%, 97% LLM Agreement; AAPL shows BULLISH, 100% Agreement
- **Note**: Only timed out on localhost, production Azure deployment works correctly

### 2. Pro Analysis Tabs COMPLETELY BROKEN (NEW - 2026-01-19)
- **Location**: `/v2/assets/[symbol]` - Pro Analysis section (Fundamentals, ESG, Insider tabs)
- **Symptom**: "Failed to load fundamental/ESG/insider data" - 500 errors
- **Impact**: **ENTIRE Pro Analysis feature non-functional for ALL asset types**
- **Root Cause**: Backend API `polymarket-analyzer.azurewebsites.net` returns HTTP 500
- **Evidence**: Tested BTC (crypto), AAPL (stock), GOLD (commodity) - ALL return 500 on ALL 3 tabs
- **Screenshots**: prod-15, prod-16, prod-17 (BTC), prod-20-22 (AAPL), prod-25-27 (GOLD)
- **Action**: Debug polymarket-analyzer backend - this is the highest priority fix

### 3. NextAuth Security Configuration
- **Location**: All pages (console warnings)
- **Symptom**: `[next-auth][warn][NO_SECRET]` warning
- **Impact**: Security vulnerability in production
- **Action**: Set `NEXTAUTH_SECRET` environment variable in production

### 4. NextAuth URL Configuration
- **Location**: All pages (console warnings)
- **Symptom**: `[next-auth][warn][NEXTAUTH_URL]` warning
- **Impact**: Authentication may fail in production
- **Action**: Set `NEXTAUTH_URL` to production domain

---

## P1 - High Priority (Fix Soon)

### 5. Signal Alignment vs ML Pipeline Contradiction (NEW - 2026-01-19)
- **Location**: `/v2/assets/[symbol]` - Signal Alignment vs ML Pipeline sections
- **Symptom**: GOLD shows "Bulls leading (3 vs 0)" in Signal Alignment BUT "BEARISH (52%)" in ML Pipeline
- **Impact**: Confusing for users - which signal should they trust?
- **Evidence**: Screenshot prod-24-gold-ml-pipeline.png shows contradiction clearly
- **Action**:
  1. Clarify which signal is authoritative
  2. Add explanation of relationship between the two
  3. Consider consolidating into single "confidence" metric

### 6. Signals Display UX - "Not Clear" Issue
- **Location**: `/v2/assets/[symbol]` - Signal Alignment section
- **Symptom**: "Signals in conflict - no clear direction" message
- **User Feedback**: "Signals not clear"
- **Root Cause**:
  - Most signals stuck at 50 (neutral)
  - Only 1 BUY signal out of 70+ assets tested
  - Never predicts bearish (known backend issue)
- **Action**:
  1. Fix backend signal calculation (too conservative)
  2. Redesign "conflict" message to be actionable
  3. Add explanation of what signals mean
  4. Consider showing confidence level instead of binary BUY/SELL

### 7. Missing API Endpoint
- **Location**: Homepage, Asset pages
- **Symptom**: `/api/intelligence/OIL` returns 404
- **Impact**: Console errors, potential broken features
- **Action**: Implement missing endpoint or remove references

### 8. Favicon Missing
- **Location**: All pages
- **Symptom**: `favicon.ico 404` in console
- **Impact**: Unprofessional appearance, browser tab looks incomplete
- **Action**: Add `favicon.ico` to `/public` directory

---

## P2 - Medium Priority (Nice to Have)

### 9. Search Bar Contrast
- **Location**: Header search input
- **Symptom**: Placeholder text has low contrast on dark background
- **Impact**: Minor accessibility issue
- **Action**: Increase placeholder text opacity or use lighter color

### 10. Sticky Headers on Asset List
- **Location**: `/v2/assets`
- **Symptom**: Headers scroll out of view on long lists
- **Impact**: User loses context when scrolling
- **Action**: Add `position: sticky` to category tabs and column headers

### 11. Market Pulse Indicator Explanation
- **Location**: `/v2/assets/[symbol]`
- **Symptom**: Users don't understand what the pulse score means
- **Impact**: Feature value not communicated
- **Action**: Add tooltip or info icon explaining the 0-100 scale

### 12. Missing Price Data for Some Assets
- **Location**: `/v2/assets` - Futures section
- **Symptom**: Some futures show blank price/pulse
- **Impact**: Incomplete data presentation
- **Action**: Add fallback display or hide assets without data

---

## P3 - Low Priority (Defer to Later)

### 13. Keyboard Navigation in Search
- **Location**: Header search
- **Symptom**: Arrow key navigation not tested
- **Action**: Verify and fix if broken

### 14. Watchlist Freemium Limits
- **Location**: Asset detail pages
- **Symptom**: Limit behavior not tested
- **Action**: Verify 5-asset limit for free tier works

### 15. Session Persistence in Chatbot
- **Location**: Chat widget
- **Symptom**: Not tested if chat history persists
- **Action**: Verify and document behavior

---

## Remove - Delete These Features/Links

### 1. Rankings Page Link
- **Location**: Homepage navigation (if still present)
- **Reason**: Page doesn't exist, removed in signals-first pivot
- **Action**: Remove any links to `/v2/rankings`

### 2. Chat Page Link
- **Location**: Homepage (if present)
- **Reason**: Only FAB widget exists, no dedicated chat page
- **Action**: Remove any links to `/v2/chat`

### 3. Trading Page References
- **Location**: Various
- **Reason**: `/v2/trading?symbol=*` causes 404 errors
- **Action**: Remove all references to trading page

### 4. Contact Page Link (or Add Page)
- **Location**: Pricing page footer
- **Reason**: `/v2/contact` returns 404
- **Action**: Either add contact page OR remove link

---

## Defer - Move to V3

### 1. Real-time Price Updates
- **Reason**: Would require WebSocket infrastructure
- **Current**: Prices update on page load only

### 2. Advanced Portfolio Analytics
- **Reason**: Complex feature, current implementation sufficient
- **Current**: Basic virtual portfolios working

### 3. Social Trading Features
- **Reason**: Requires significant backend work
- **Current**: Leaderboard exists but limited

### 4. Mobile App
- **Reason**: Web responsive is sufficient for launch
- **Current**: Web app works on mobile browsers

---

## Verification Checklist

After fixes, verify:

- [x] ML Pipeline Prediction shows results (not timeout) ✅ **WORKING** (verified 2026-01-19)
- [ ] Pro Analysis tabs return data (not 500 errors) **← NEW P0**
- [ ] No console errors on any page
- [ ] NextAuth warnings resolved in production
- [ ] At least some assets show BUY or SELL (not all NEUTRAL)
- [ ] Signal alignment and ML Pipeline show consistent direction **← NEW P1**
- [ ] Favicon appears in browser tab
- [ ] All navigation links work (no 404s)
- [ ] Search contrast is readable

---

## Quick Wins (Can Fix Today)

1. **Add favicon.ico** - 5 min
2. **Fix search bar contrast** - 5 min
3. **Remove dead links** - 15 min
4. **Add NextAuth env vars** - 10 min

---

## Requires Backend Work

1. ~~**ML Pipeline timeout**~~ ✅ RESOLVED on production
2. **Pro Analysis 500 errors** - Debug polymarket-analyzer API **← P0 CRITICAL**
3. **Signal calculation** - Algorithm adjustment
4. **Signal vs ML Pipeline consistency** - Need unified signal source
5. **Missing /api/intelligence/OIL** - Endpoint implementation

---

## Summary Table

| Priority | Count | Effort | Impact |
|----------|-------|--------|--------|
| P0 Critical | 4 (1 resolved) | Medium-High | Blocking |
| P1 High | 4 | Medium | Important |
| P2 Medium | 4 | Low | Nice to have |
| P3 Low | 3 | Low | Can defer |
| Remove | 4 | Low | Cleanup |
| Defer to V3 | 4 | High | Future |

**Recommended Focus**:
1. **HIGHEST PRIORITY**: Fix Pro Analysis 500 errors (polymarket-analyzer backend)
2. Fix NextAuth env vars for security
3. Address Signal Alignment vs ML Pipeline contradiction (confuses users)
