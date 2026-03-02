# FINAL HANDOVER: Seekapa Daily Email System - Complete Rebuild Required

**Date**: January 22, 2026
**Priority**: P0 - BLOCKING
**Status**: ALL FIXES FAILED - Requires Multi-Agent Workflow
**Session Result**: UNSUCCESSFUL - Superficial changes did not fix rendering

---

## EXECUTIVE SUMMARY

**CRITICAL**: All attempted fixes in this session FAILED. The emails still look identical to before. The user explicitly stated:

> "something off - all broken, all same as before, u didnt change the html didnt fixed the email, all same"

**DO NOT** attempt quick fixes. This requires a systematic multi-agent approach.

---

## WHAT WAS ATTEMPTED (AND FAILED)

| Change | File | Result |
|--------|------|--------|
| Logo URL fix | all 4 templates | **NO EFFECT** |
| Chart generator creation | `utils/chart_generator.py` | Charts generated but **NOT RENDERING** |
| Morning brief icon_url | `activities/daily_email_activities.py` | **UNKNOWN** |
| Upload charts to Blob | `send_daily_briefing_test.py` | Charts uploaded but **NOT VISIBLE** |
| Hex color fix #50517→#505175 | ES/PT templates | **UNKNOWN** |
| box-shadow→border | ES/PT templates | **UNKNOWN** |

**Key Insight**: Changes were made but EMAIL LOOKS IDENTICAL. This indicates:
1. Template changes may not have been applied correctly
2. Renderer may not be using updated templates
3. Root cause is deeper than URL/CSS fixes
4. May need complete template rebuild

---

## REQUIRED WORKFLOW: Judge → Architect → Coder

### Phase 1: JUDGE AGENT

**Purpose**: Hostile code review to find TRUE root causes

**Tasks**:
1. Compare actual rendered email HTML (from ACS) vs template source
2. Check if `email_renderer.py` is caching templates
3. Verify template paths are correct in renderer
4. Analyze Outlook rendering vs Gmail rendering
5. Check if images are being blocked by ACS itself
6. Verify Azure Blob URLs are publicly accessible
7. Check CORS headers on blob storage

**Questions to Answer**:
- Are the templates actually being used?
- Is the renderer loading the correct files?
- Are the Handlebars variables being replaced?
- What does the ACTUAL sent HTML look like?

**Command to Get Actual HTML**:
```python
# In send_daily_briefing_test.py, add before sending:
with open(f'/tmp/email_{lang}.html', 'w') as f:
    f.write(html)
print(f"Saved HTML to /tmp/email_{lang}.html")
```

### Phase 2: ARCHITECT AGENT

**Purpose**: Design proper solution based on Judge findings

**Expected Design Decisions**:

1. **Template Structure**
   - Complete rebuild vs. targeted fixes?
   - Single template with lang switching vs. 4 separate templates?
   - Inline CSS vs. embedded `<style>` block?

2. **Image Strategy**
   - CID embedding for logo/icons (guaranteed display)?
   - Base64 inline images (larger but reliable)?
   - Public URLs with proper cache headers?
   - VML fallbacks for Outlook?

3. **Data Flow**
   - Real FMP data integration
   - Chart generation timing (pre-generate vs. on-demand)
   - Blob upload strategy (permanent URLs vs. daily folders)

4. **Testing Protocol**
   - Which email clients to test?
   - Automated visual testing?
   - Regression prevention?

### Phase 3: CODER AGENT

**Purpose**: Implement architect's design with TDD approach

**Implementation Order**:
1. Fix renderer to ensure templates load correctly
2. Implement image strategy (CID/base64/URL)
3. Add MSO conditionals for Outlook
4. Integrate real FMP data
5. Test incrementally with ONE email per change

---

## FILES TO EXAMINE

### Primary Suspects:

```
src/runtime/templates/email/email_renderer.py
  - Does it cache templates?
  - Does it use correct file paths?
  - Does it properly replace Handlebars variables?

src/runtime/templates/email/daily_briefing_en.html
  - Line-by-line audit needed
  - Check all image URLs
  - Check all MSO conditionals

src/runtime/send_daily_briefing_test.py
  - Check what HTML is actually generated
  - Save HTML to file for inspection
  - Compare template vs. rendered output
```

### Supporting Files:

```
src/runtime/utils/chart_generator.py  # NEW - may have issues
src/runtime/activities/daily_email_activities.py  # Chart integration
```

---

## CORRECT BRAND REFERENCE

From landing page (the WORKING reference):

| Element | Value |
|---------|-------|
| Logo | SEEKAPA with gradient K (purple to pink) |
| Background | Dark navy (#1E3A5F or similar) |
| Accent | Gold (#D4AF37) |
| Real prices | XAU $4827, CL $60.58, etc. |

**Landing Page URL** (WORKS correctly):
```
https://stmarketingnewsletter.blob.core.windows.net/landing-pages/market-overview/latest/ar.html
```

---

## BLOB STORAGE STRUCTURE

```
stmarketingnewsletter.blob.core.windows.net/
├── brand-assets/
│   ├── seekapa-logo.png          # Logo file (verify exists)
│   └── email-assets/
│       └── seekapa-logo.png      # Old path (may be wrong)
├── brand-assets/email-icons/
│   ├── icon-gold.png
│   ├── icon-oil.png
│   ├── icon-silver.png
│   ├── icon-forex.png
│   └── icon-event.png
├── charts/
│   └── email-assets/
│       └── daily-2026-01-22/     # Today's generated charts
│           ├── gold_chart.png
│           ├── oil_chart.png
│           └── blurred-teaser.png
└── landing-pages/
    └── market-overview/latest/   # WORKING reference
```

---

## TEST RECIPIENT

**ONLY SEND TO**: `oded.be@i-sdd.com`

**DO NOT** send to any other addresses during testing.

---

## SUCCESS CRITERIA

The email is fixed when:
- [ ] Logo displays correctly in Outlook (with images blocked = alt text, enabled = image)
- [ ] Charts show real market data (not sample)
- [ ] Morning brief has real market intelligence
- [ ] All icons visible or have proper fallback
- [ ] Arabic RTL renders correctly
- [ ] Matches landing page quality visually

---

## ANTI-PATTERNS (What NOT to do)

1. **DO NOT** make blind CSS fixes without testing
2. **DO NOT** assume browser preview matches Outlook
3. **DO NOT** trust that file changes are being picked up
4. **DO NOT** send multiple test emails - ONE at a time
5. **DO NOT** skip the Judge phase

---

## MEMORY ENTITIES TO CREATE

```
Entity: seekapa-email-system-failure
Type: incident_report
Observations:
- Session 2026-01-22: All fixes failed, email unchanged
- Root cause: Unknown - needs Judge Agent investigation
- Files modified but no visible effect
- User explicitly requested multi-agent workflow
- Next session: Judge → Architect → Coder pattern

Entity: seekapa-email-next-steps
Type: action_plan
Observations:
- Phase 1: Judge Agent to find TRUE root cause
- Phase 2: Architect Agent to design proper solution
- Phase 3: Coder Agent to implement with TDD
- Test protocol: ONE email at a time to oded.be@i-sdd.com
- Success: Match landing page quality
```

---

## ESTIMATED EFFORT

| Phase | Agent | Time | Focus |
|-------|-------|------|-------|
| 1 | Judge | 1-2h | Find actual root cause |
| 2 | Architect | 1h | Design proper solution |
| 3 | Coder | 3-4h | Implement and test |
| Total | - | 5-7h | Complete rebuild |

---

*This handover created after session failure. Previous session made cosmetic changes that had no effect. Next session MUST use multi-agent workflow.*
