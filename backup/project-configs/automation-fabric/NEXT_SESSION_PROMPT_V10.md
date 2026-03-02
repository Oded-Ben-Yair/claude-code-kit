# Next Session Prompt: Email V10 UX Redesign

**Copy this entire prompt to start your next session:**

---

## Context Priming

I'm continuing work on the **automation-fabric** project, specifically the **Daily Market Overview email and landing page system**.

**CRITICAL: Before ANY planning or coding:**
1. Run `/enforce-capabilities` skill
2. Read Memory MCP entity: `automation-fabric-email-v10-requirements`
3. Read handover: `.claude/handover-20260125-email-v10.md`
4. View reference: https://stmarketingnewsletter.blob.core.windows.net/landing-pages/market-overview/latest/en.html

---

## V10 Requirements (User Approved)

### Theme System
- **DEFAULT**: White/light background (NOT dark)
- **TOGGLE**: Add dark mode toggle button (top right)
- Professional, clean, Bloomberg-style appearance

### Chart System (6 Total)
| Slot | Asset | Type |
|------|-------|------|
| 1 | Gold (XAUUSD) | Permanent |
| 2 | Oil (CL=F) | Permanent |
| 3 | Silver (XAGUSD) | Permanent |
| 4 | Bitcoin (BTCUSD) | Permanent |
| 5 | [Most gained today] | Dynamic |
| 6 | [Most lost today] | Dynamic |

### Content Requirements
- **Dynamic headline** via Grok (like "Tech Rally Extends as AI Chips Lead Markets Higher")
- **5 morning brief bullets** with asset-specific context
- **Per-asset insights** - educational, spicy, Grok-generated
- **6 Trading Ideas** with detailed rationales
- **6 Week Ahead events** with dates/times

### Email Teaser Structure
- Show 2-3 charts with full data (Gold, BTC visible)
- BLUR remaining charts and Trading Ideas
- Prominent "View Full Report" CTA button

---

## Mandatory Capabilities to Use

### Skills (MUST invoke)
```
/frontend         - For all design work (white theme, toggle, responsive)
/enforce-capabilities - Before executing ANY plan
/multi-model-debate   - For major UX decisions (theme colors, layout)
```

### MCP Tools (MUST use)
```
grok_brand_content    - Dynamic headlines, spicy copy
grok_search           - Real-time market intelligence
gemini-analyze-image  - Visual validation of both themes
playwright            - Browser testing, screenshots
```

### Agents (MUST invoke via Task tool)
```
Design Specialist     - Frontend design, premium effects
Grok Brand Writer     - Human-like, witty content
Gemini Specialist     - Vision analysis, design feedback
```

---

## Workflow

1. **Phase 1: Design Planning**
   - Use `/frontend` skill in design mode
   - Invoke `/multi-model-debate` for theme color decisions
   - Create mockup specs before coding

2. **Phase 2: White Theme Implementation**
   - Create `market_overview_v10.html` template
   - CSS variables for theme switching
   - Toggle button component

3. **Phase 3: Grok Content Integration**
   - Activity for dynamic headlines
   - Per-asset insight generation
   - Educational snippets

4. **Phase 4: 6-Chart System**
   - 4 permanent asset cards
   - 2 dynamic (FMP most changed)
   - ApexCharts light/dark theme support

5. **Phase 5: Email Teaser**
   - 2-3 visible charts
   - Blur overlay on remaining
   - "View Full Report" CTA

6. **Phase 6: Visual Validation**
   - Playwright screenshots (light + dark)
   - Gemini Vision analysis
   - Mobile responsive check

---

## Anti-Patterns (DO NOT DO)

- Don't skip `/enforce-capabilities` before planning
- Don't use dark-only theme
- Don't hardcode colors (use CSS variables)
- Don't skip Grok for content generation
- Don't show less than 6 charts on landing page
- Don't forget blur effect in email teaser

---

## Reference Files

```
.claude/handover-20260125-email-v10.md           # Full handover
.claude/status.json                               # Current state
.claude/ARCHITECTURE_EMAIL_REBUILD.md             # Architecture
templates/email/market_overview_v9.html           # Current template
templates/landing-pages/market_overview_full.html # Current landing
activities/grok_activities.py                     # Grok integration
activities/email_overview_activities.py           # Email pipeline
```

---

## Success Criteria

| Metric | Target |
|--------|--------|
| Light theme quality | 95/100 (Gemini) |
| Dark theme quality | 95/100 (Gemini) |
| Chart count | 6 (4 perm + 2 dynamic) |
| Email teaser blur | Working |
| Grok headlines | Dynamic, contextual |
| Mobile responsive | Yes |
| Theme toggle | Instant, no reload |

---

**START BY:** Running `/enforce-capabilities` and viewing the reference landing page.
