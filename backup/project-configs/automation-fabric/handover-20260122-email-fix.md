# CRITICAL HANDOVER: Daily Email Template Complete Rebuild Required

**Date**: January 22, 2026
**Priority**: P0 - BLOCKING
**Previous Session Failed**: Superficial fixes applied, root causes not addressed

---

## EXECUTIVE SUMMARY

The Seekapa Daily Briefing email system is fundamentally broken. Previous session made cosmetic CSS fixes but missed the core issues:

1. **WRONG LOGO** - Email uses incorrect logo file, not the branded SEEKAPA logo with gradient K
2. **NO REAL CHARTS** - Email uses static placeholder images, not actual market charts
3. **SAMPLE DATA** - Email sends hardcoded test data, not real market prices
4. **IMAGES BLOCKED** - Outlook blocks all images, shows only alt text
5. **LANDING PAGE WORKS** - The Market Overview landing page is correct and shows what email SHOULD look like

---

## SCREENSHOT ANALYSIS

### Email in Outlook (BROKEN):
- **Logo**: Shows text "SEEKAPA" or "سيكابا" - image blocked/wrong file
- **Icons**: Show alt text (Gold, Oil, Silver, EUR/USD, Event) - images not rendering
- **Charts**: Show alt text "مخطط الذهب - السعر الحالي: $2,048.50" - placeholder images
- **Data**: Hardcoded sample: Gold $2,048.50, Oil $77.80 - NOT REAL PRICES

### Landing Page (CORRECT - reference for what email should match):
- **Logo**: Proper SEEKAPA with gradient purple "K" on dark background
- **Real Data**: XAU $4827, NSDQ $25327, CL $60.58, EURUSD $1.17
- **Proper Sections**: Big Movers, AI Stocks, Trading Ideas, Upcoming Events
- **Dark Theme**: Professional dark UI matching Seekapa brand

---

## ROOT CAUSE ANALYSIS

### Issue 1: Wrong Logo File
**Current**: `https://stmarketingnewsletter.blob.core.windows.net/brand-assets/email-assets/seekapa-logo.png`
**Problem**: This is NOT the correct Seekapa logo
**Evidence**: Landing page shows correct logo with gradient K at:
- Footer of landing page (screenshot 6)
- Header of landing page (screenshot 9)

**Action Required**:
1. Export correct logo from landing page or brand assets
2. Upload to Azure Blob as `seekapa-logo-email.png` (light version for white email background)
3. Upload `seekapa-logo-white.png` for dark footer
4. Update template to use correct files

### Issue 2: No Chart Generation System
**Current**: Template expects `{{gold_chart_url}}` and `{{oil_chart_url}}`
**Problem**: These point to static placeholder images that don't exist or are generic
**Evidence**: Charts show sample data, not real TradingView-style charts

**Action Required**:
1. Create chart generation service (TradingView widget screenshots or Chart.js)
2. Generate charts daily with real FMP data
3. Upload to Azure Blob with timestamped URLs
4. Pass real URLs to email renderer

### Issue 3: Sample Data Instead of Real Data
**Current**: `send_daily_briefing_test.py` uses hardcoded `SAMPLE_BRIEF_EN`, `SAMPLE_GOLD`, etc.
**Problem**: Email always shows same fake data: Gold $2,048.50, Oil $77.80
**Evidence**: Landing page shows REAL prices: XAU $4827, NSDQ $25327

**Action Required**:
1. Integrate with FMP client (`integrations/fmp_client.py`) for real prices
2. Generate morning brief dynamically using Grok MCP
3. Calculate real T1/T2 targets based on technical analysis
4. Remove all hardcoded sample data

### Issue 4: Outlook Image Blocking
**Current**: All images show alt text in Outlook
**Problem**:
- No proper Content-ID (CID) embedding
- No fallback for blocked images
- Missing VML fallbacks for buttons

**Action Required**:
1. Consider embedding critical images as base64 (logo, icons)
2. Add proper MSO VML fallbacks for all images
3. Ensure alt text is meaningful (already improved)
4. Test with "Download Pictures" in Outlook

### Issue 5: Email vs Landing Page Disconnect
**Current**: Email template is completely separate from landing page system
**Problem**: Landing page has correct branding, real data - email has neither
**Evidence**: Compare screenshot 9 (landing page) vs screenshot 2 (email)

**Action Required**:
1. Use same data source for both (FMP + Grok intelligence)
2. Use same brand assets
3. Consider email as "teaser" that links to landing page

---

## FILES TO FIX

### Primary Files:
```
src/runtime/templates/email/daily_briefing_en.html  - English template
src/runtime/templates/email/daily_briefing_ar.html  - Arabic template
src/runtime/templates/email/email_renderer.py       - Renderer logic
src/runtime/send_daily_briefing_test.py             - Test sender (uses sample data!)
```

### Integration Files Needed:
```
src/runtime/integrations/fmp_client.py              - Already exists, use for real data
src/runtime/activities/grok_activities.py           - Use for morning brief generation
src/runtime/utils/chart_generator.py                - NEEDS TO BE CREATED
```

### Brand Assets to Fix:
```
Azure Blob: brand-assets/email-assets/seekapa-logo.png      - WRONG FILE
Azure Blob: brand-assets/email-icons/icon-*.png             - May be wrong/blocked
Azure Blob: charts/email-assets/gold_chart.png              - Static placeholder
Azure Blob: charts/email-assets/oil_chart.png               - Static placeholder
Azure Blob: charts/email-assets/blurred-teaser.png          - Static placeholder
```

---

## CORRECT LOGO REFERENCE

From landing page (screenshot 9), the correct SEEKAPA logo has:
- Dark navy/purple background
- "SEEK" in white
- "K" with gradient (purple to pink)
- "APA" in white
- Clean, modern typography

The current email logo appears to be a text-based placeholder or wrong file entirely.

---

## STEP-BY-STEP FIX PLAN

### Phase 1: Fix Brand Assets (30 min)
1. [ ] Take screenshot of correct logo from landing page
2. [ ] Create transparent PNG version for email (light background)
3. [ ] Create white version for dark footer
4. [ ] Upload both to Azure Blob with new names
5. [ ] Update templates to use new logo URLs
6. [ ] Verify icons exist and are accessible

### Phase 2: Create Chart Generation (2-3 hours)
1. [ ] Create `utils/chart_generator.py` using Chart.js or lightweight charting
2. [ ] Pull real price data from FMP client
3. [ ] Generate gold chart with current price, buy/sell signal
4. [ ] Generate oil chart with current price, buy/sell signal
5. [ ] Generate blurred teaser image with overlay text baked in
6. [ ] Upload generated charts to Azure Blob
7. [ ] Return URLs for email renderer

### Phase 3: Dynamic Morning Brief (1 hour)
1. [ ] Create `activities/morning_brief_activity.py`
2. [ ] Use Grok MCP `grok_search` for market intelligence
3. [ ] Generate 5-6 morning brief items with real data
4. [ ] Translate to AR/ES/PT using existing translation patterns
5. [ ] Replace hardcoded `SAMPLE_BRIEF_*` with dynamic generation

### Phase 4: Real Data Integration (1 hour)
1. [ ] Modify `send_daily_briefing_test.py` to use real data
2. [ ] Pull gold/oil prices from FMP
3. [ ] Calculate T1/T2 targets (support/resistance levels)
4. [ ] Pull today's events from economic calendar
5. [ ] Remove all `SAMPLE_*` constants

### Phase 5: Outlook Compatibility (1 hour)
1. [ ] Embed logo as base64 or ensure proper CID
2. [ ] Add MSO conditionals for all images
3. [ ] Test with Outlook "Download Pictures" disabled
4. [ ] Test with Outlook "Download Pictures" enabled
5. [ ] Verify all fallback text is meaningful

### Phase 6: End-to-End Testing (30 min)
1. [ ] Send test email with real data
2. [ ] Verify in Outlook (desktop and web)
3. [ ] Verify in Gmail
4. [ ] Verify Arabic RTL renders correctly
5. [ ] Verify all links work (Azure Blob landing pages)
6. [ ] Verify charts show real prices
7. [ ] Verify logo displays correctly

---

## MEMORY UPDATES REQUIRED

After fixing, update Memory MCP with:

```
Entity: seekapa-email-system
Type: system_configuration
Observations:
- Logo URL: [new correct URL]
- Chart generation: utils/chart_generator.py
- Data source: FMP client + Grok MCP
- Tested: Outlook desktop, Outlook web, Gmail
```

---

## DO NOT REPEAT THESE MISTAKES

1. **DO NOT** make CSS-only fixes without testing in actual Outlook
2. **DO NOT** trust browser preview - Outlook renders completely differently
3. **DO NOT** use sample/hardcoded data for testing - always verify real data flow
4. **DO NOT** assume images will render - Outlook blocks by default
5. **DO NOT** skip verifying logo file is correct before sending

---

## SUCCESS CRITERIA

Email is fixed when:
- [ ] Correct SEEKAPA logo visible (gradient K)
- [ ] Real market prices shown (matching landing page)
- [ ] Charts display actual price data
- [ ] Icons visible (or graceful fallback)
- [ ] Morning brief has relevant market news
- [ ] All CTAs link to working Azure Blob landing pages
- [ ] Renders correctly in Outlook with images blocked
- [ ] Renders correctly in Outlook with images enabled
- [ ] Arabic RTL version works correctly

---

## REFERENCE URLS

**Working Landing Page**:
`https://stmarketingnewsletter.blob.core.windows.net/landing-pages/market-overview/latest/ar.html`

**Current (Broken) Logo**:
`https://stmarketingnewsletter.blob.core.windows.net/brand-assets/email-assets/seekapa-logo.png`

**FMP Client**: `src/runtime/integrations/fmp_client.py`
**Grok Activities**: `src/runtime/activities/grok_activities.py`

---

## ESTIMATED EFFORT

| Phase | Time | Complexity |
|-------|------|------------|
| Brand Assets | 30 min | Low |
| Chart Generation | 2-3 hours | High |
| Morning Brief | 1 hour | Medium |
| Real Data | 1 hour | Medium |
| Outlook Compat | 1 hour | Medium |
| Testing | 30 min | Low |
| **Total** | **6-7 hours** | **High** |

---

*This handover created after analyzing 9 screenshots showing the disconnect between broken email and working landing page.*
