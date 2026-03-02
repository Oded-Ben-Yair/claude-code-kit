# Session Handover: V10 Earnings Intelligence Gap Fix

**Date**: 2026-02-01
**Project**: automation-fabric
**Branch**: main
**Session**: Earnings data flow gap analysis + QA email fixes

---

## Status Summary

| Item | Status |
|------|--------|
| Arabic RTL email fix | DONE - confirmed 10/10 by Gemini Vision |
| Arabic content enforcement | DONE - full Arabic in all sections |
| Earnings intelligence activity | DONE - `activities/earnings_intelligence_activity.py` |
| QA emails sent (4 languages) | DONE - via `send_v10_qa.py` |
| Earnings data in email/landing page | **GAP FOUND - NOT FIXED** |

---

## THE GAP: Earnings Data Never Reaches Templates

### What Was Built (Working)

`fetch_earnings_intelligence_activity` in `activities/earnings_intelligence_activity.py` generates:

```python
{
    "success": True,
    "upcoming_earnings": [...],        # Stocks reporting in next N days
    "recent_earnings": [...],          # Stocks that just reported
    "morning_brief_bullets": [...],    # Pre-formatted earnings bullets
    "week_ahead_events": [...],        # Formatted events for calendar
    "earnings_context": str,           # Summary for Grok enrichment
}
```

The orchestrator calls it in Phase 1 (line 163-166 of `email_overview_orchestrator.py`).

### Where It Breaks: 3 Handoff Failures

#### Handoff 1: Orchestrator merges PARTIALLY (lines 181-195)

| Field | What Happens | Status |
|-------|-------------|--------|
| `earnings_context` | Merged into `intelligence_result["context"]` for Grok | WORKS |
| `week_ahead_events` | Merged into `calendar_result["events"]` | WORKS |
| `upcoming_earnings` | **NOT passed anywhere** | LOST |
| `recent_earnings` | **NOT passed anywhere** | LOST |
| `morning_brief_bullets` | **NOT passed anywhere** | LOST |

#### Handoff 2: Orchestrator → Email Activity (lines 458-483)

The `generate_email_html_v10_activity` call does NOT include:
- `upcoming_earnings`
- `recent_earnings`
- `morning_brief_bullets` (overwritten by generic morning brief)

#### Handoff 3: Email Activity → Template Context

`generate_email_html_v10_activity` (line ~2140) builds template context without any earnings fields.

#### Handoff 4: Templates have NO earnings sections

Neither `templates/email/market_overview_v10.html` nor `templates/landing-pages/market_overview_v10.html` contain any `earnings` sections or variables.

---

## FIX PLAN (4 Steps)

### Step 1: Orchestrator — Pass earnings data forward

**File**: `orchestrators/email_overview_orchestrator.py` (lines 181-195)

```python
# After existing earnings_context and week_ahead_events merges, ADD:
# Store earnings data for email/landing page
earnings_data = {
    "upcoming_earnings": earnings_result.get("upcoming_earnings", []),
    "recent_earnings": earnings_result.get("recent_earnings", []),
    "morning_brief_bullets": earnings_result.get("morning_brief_bullets", []),
}
```

Then in Phase 5 email generation call (lines 458-483), add:
```python
"upcoming_earnings": earnings_data.get("upcoming_earnings", []),
"recent_earnings": earnings_data.get("recent_earnings", []),
"earnings_bullets": earnings_data.get("morning_brief_bullets", []),
```

Same for Phase 5.5 landing page generation.

### Step 2: Email Activity — Add to template context

**File**: `activities/email_overview_activities.py` (around line 2130)

In `generate_email_html_v10_activity`, add to context dict:
```python
"upcoming_earnings": input.get("upcoming_earnings", []),
"recent_earnings": input.get("recent_earnings", []),
"earnings_bullets": input.get("earnings_bullets", []),
```

### Step 3: Email Template — Add earnings section

**File**: `templates/email/market_overview_v10.html`

Add an "Earnings Calendar" section (suggested placement: after Morning Brief, before Trading Ideas). Example:

```html
{% if upcoming_earnings or recent_earnings %}
<!-- Earnings Intelligence Section -->
<tr>
  <td style="padding: 20px 24px;">
    <h2>Earnings Watch</h2>
    {% for bullet in earnings_bullets %}
      <p>{{ bullet }}</p>
    {% endfor %}
  </td>
</tr>
{% endif %}
```

### Step 4: Landing Page Template — Add earnings section

**File**: `templates/landing-pages/market_overview_v10.html`

Similar section with full upcoming/recent earnings data and interactive formatting.

### Step 5: QA Script — Add sample earnings data

**File**: `send_v10_qa.py`

Add sample `upcoming_earnings`, `recent_earnings`, and `earnings_bullets` to `get_sample_context()`.

---

## Files to Modify

| File | Change | Lines |
|------|--------|-------|
| `orchestrators/email_overview_orchestrator.py` | Pass earnings data to Phase 5/5.5 | ~181-195, ~458-483, ~520+ |
| `activities/email_overview_activities.py` | Add earnings to template context | ~2130-2150 |
| `activities/landing_page_activities.py` | Add earnings to landing page context | ~650+ |
| `templates/email/market_overview_v10.html` | Add Earnings Watch section | After morning brief |
| `templates/landing-pages/market_overview_v10.html` | Add Earnings section | After morning brief |
| `send_v10_qa.py` | Add sample earnings data | get_sample_context() |

---

## What NOT to Change

- `activities/earnings_intelligence_activity.py` — works correctly, generates good data
- RTL fixes in email template — confirmed working
- `send_v10_qa.py` chart URLs — all 6 charts verified (XAUUSD, CLUSD, XAGUSD, BTCUSD, NDX, USDJPY)

---

## Testing Checklist

After implementing the fix:

1. [ ] Run orchestrator locally or trigger via API
2. [ ] Verify earnings data appears in email HTML (all 4 languages)
3. [ ] Verify earnings data appears in landing page (all 4 languages)
4. [ ] Run `send_v10_qa.py` — check earnings section in inbox
5. [ ] Arabic earnings section must be RTL
6. [ ] Earnings bullets must be in correct language (not English fallback)

---

## Context References

- **Earnings Activity**: `src/runtime/activities/earnings_intelligence_activity.py` (full file)
- **Orchestrator**: `src/runtime/orchestrators/email_overview_orchestrator.py` (lines 163-195 for Phase 1, lines 458-520 for Phase 5/5.5)
- **Email Activity**: `src/runtime/activities/email_overview_activities.py` (line 1626+ for V10 activity)
- **Email Template**: `src/runtime/templates/email/market_overview_v10.html`
- **Landing Page Template**: `src/runtime/templates/landing-pages/market_overview_v10.html`
- **Landing Page Activity**: `src/runtime/activities/landing_page_activities.py` (line 460+ for V10)
- **QA Script**: `src/runtime/send_v10_qa.py`

---

## Memory MCP Entities (up to date)

- `automation-fabric-v10-email` — Full feature context with gap analysis
- `automation-fabric-v10-template-map` — All file paths and architecture
- `automation-fabric-session-20260201-learning` — Today's learnings including gap
- `automation-fabric-v10-critical-failure-2026-01-29` — Historical failure context

---

## Session Learnings Applied

- **fail-037**: Template confusion (email vs landing page) — added to failure_patterns.json
- **fail-038**: Creating new scripts vs using existing — added
- **fail-039**: Chart PNG verification — added
- **Lessons learned**: Updated `~/.claude/rules/archive/lessons-learned.md` with full postmortem
- **Memory MCP**: All entities updated with gap analysis
