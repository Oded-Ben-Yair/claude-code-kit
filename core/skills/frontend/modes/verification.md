# Verification Mode

Mandatory visual proof pipeline. No design is "done" without passing this.

## The Rule

**Never say "renders correctly" / "looks good" / "visual is complete" without:**
1. Playwright screenshot taken
2. gemini-analyze-image analysis confirming all visual elements
3. Taste check passed (originality, not just technical score)

---

## Verification Pipeline

### Step 1: Pre-Screenshot Checklist

Before taking any screenshot:

```
[ ] Console errors are BLOCKING — any 404, CSS fail, JS error = fix first
[ ] Correct localhost port verified
[ ] For Next.js: `rm -rf .next` if CSS issues persist
[ ] Dev server is the only running instance (kill duplicates)
[ ] CDN/library audit passed (see below)
```

### Step 2: CDN/Library Audit

**Before debugging any interaction issue:**

1. Grep for actual usage of the CDN library's features (CSS classes, API calls, components)
2. **If zero usage → REMOVE the library** (don't work around it)
3. **If used → THEN debug** the specific interaction
4. **Max 2 workaround attempts** before questioning if the dependency is needed

> Origin: Tech4All 2026-02-01 — 5 failed attempts working around Tailwind CDN before discovering zero utility classes were used.

### Step 3: Screenshot Capture

```yaml
Tool: mcp__playwright__browser_take_screenshot
Settings:
  - browser_resize(1440, 900) BEFORE desktop screenshots
  - Use RELATIVE filenames only (saves to .playwright-mcp/)
  - Take from deployed URL for final deliverables (not localhost)
```

**Viewports to test:**
| Viewport | Width | When |
|----------|-------|------|
| Mobile | 375px | Always |
| Tablet | 768px | If responsive layout |
| Desktop | 1440px | Always |

### Step 4: Gemini Visual Analysis

```yaml
Tool: gemini-analyze-image
Settings:
  - mediaResolution: HIGH (1120 tokens)
  - detectObjects: true
  - thinkingLevel: high
Query template: |
  Analyze this UI screenshot. Score 0-100 on:
  1. Visual completeness (all elements rendered?)
  2. Color accuracy (matches brand hex values?)
  3. Typography hierarchy (clear visual levels?)
  4. Layout correctness (alignment, spacing, grid?)
  5. No broken elements (missing images, overflow, clipping?)
  Report any issues found.
```

### Step 5: Taste Check (CRITICAL — Gemini Score != Done)

**Gemini measures TECHNICAL execution. It does NOT measure:**
- Design originality or uniqueness
- Whether it looks like every other SaaS dashboard
- User emotional response ("would I screenshot this?")

**After Gemini scores 90+, ask yourself:**

```
[ ] Does this look fundamentally different from a generic dashboard/page?
[ ] Would a design-aware reviewer say "this is unique"?
[ ] If user asked for "wow factor" — does this actually wow?
```

If NO to any: the design needs a different visual metaphor, not more CSS polish. Go to Iteration Mode.

> Origin: Sentimark 2026-02-03 — Round 2 scored 92/100 on Gemini but user rejected as "same style". The score measured execution quality, not design originality.

---

## Red Flags (STOP and Fix)

| Symptom | Cause | Action |
|---------|-------|--------|
| White/blank background | CSS not loaded | Check console for 404s |
| Content invisible, DOM exists | Animation stuck at initial state | Force opacity:1, transform:none |
| Layout completely wrong | Wrong viewport or URL | Verify navigation target |
| Elements overlap | Stacking context issue | Check parent transform/filter/opacity |

### Framer Motion Animation Fix

```javascript
// Force-reveal stuck animations
await page.evaluate(() => {
  document.querySelectorAll('*').forEach(el => {
    const style = window.getComputedStyle(el);
    if (style.opacity === '0') {
      el.style.opacity = '1';
      el.style.transform = 'none';
    }
  });
});
```

---

## Platform-Specific Rules

### Email Templates (CRITICAL)
- **NEVER** validate via local HTML renders
- **MUST** test in real inbox (Gmail, Outlook, Apple Mail)
- `localhost:*` or `file://` screenshots are INVALID
- Unsupported CSS: blur(), backdrop-filter, Grid, Flexbox (partial), SVG

### PDF/Print
- A4 = 794x1123px at 96 DPI; set explicit min/max height
- No page >20% empty white space unless intentional
- Validate colors match brand hex values exactly
- Use actual logo files — never recreate from description

### Deployment Screenshots
- Vercel: Always `npx vercel --prod --yes` (without --yes, hangs with zero output)
- Final deliverables: Screenshot from **deployed URL**, not localhost
- Absolute paths outside output dir are rejected by Playwright

---

## Verification Report Template

```markdown
## Visual Verification Report

**URL**: [tested URL]
**Viewport**: [width x height]
**Timestamp**: [date/time]

### Gemini Score: XX/100
- Completeness: X/20
- Color accuracy: X/20
- Typography: X/20
- Layout: X/20
- No broken elements: X/20

### Taste Check
- [ ] Looks fundamentally different from generic template
- [ ] Matches requested brand feel
- [ ] "Wow factor" present (if requested)

### Issues Found
1. [issue] — [severity: critical/major/minor]

### Screenshots
- Desktop: [filename]
- Mobile: [filename]

### Verdict: PASS / FAIL / NEEDS ITERATION
```
