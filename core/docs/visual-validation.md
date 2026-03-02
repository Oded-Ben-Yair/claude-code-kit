# Visual Validation Rules

## Screenshot Validation Protocol (MANDATORY)

1. Take screenshot with **Playwright**
2. Analyze with **gemini-analyze-image** (NEVER trust accessibility snapshot alone)
3. Confirm: background color, text visibility, layout correctness, no broken elements
4. Only then say "renders correctly"

## Red Flags (STOP and fix)

| Symptom | Cause | Action |
|---------|-------|--------|
| White/blank background | CSS not loaded | Check console for 404s |
| Content invisible, DOM exists | Animation stuck at initial state | Force opacity:1, transform:none |
| Layout completely wrong | Wrong viewport or URL | Verify navigation target |

## CDN/Library Audit (Before Debugging Interactions)

When a third-party CDN script causes mysterious re-renders, state destruction, or MutationObserver cascades:
1. **Grep for actual usage** of the library's features (CSS classes, API calls, components)
2. **If zero usage → REMOVE the library** — don't work around it
3. **If used → THEN debug** the specific interaction
4. **Max 2 workaround attempts** before questioning if the dependency is needed

Origin: V10 Landing Page 2026-02-01 — 5 failed attempts working around Tailwind CDN before discovering zero utility classes were used.

## Deployment & Screenshot Logistics

- Vercel CLI: Always `npx vercel --prod --yes` (without --yes, hangs in background with zero output)
- Playwright screenshots: Use RELATIVE filenames only (saves to `.playwright-mcp/`). Absolute paths outside output dir are rejected.
- Final deliverable screenshots: Take from deployed URL, not localhost — proves production build works and matches reviewer experience

Origin: WalkMe 2026-02-03 — `--yes` flag cost 2min debugging; absolute path cost a retry.

## Pre-Screenshot Checklist

- Console errors are BLOCKING - any 404, CSS fail, JS error = fix first
- Verify correct localhost port
- For Next.js CSS issues: `rm -rf .next` before testing

## Framer Motion Fix

```javascript
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

## Email Validation (CRITICAL)

- **NEVER** validate email templates via local HTML renders
- **MUST** test in real inbox (Gmail, Outlook, Apple Mail)
- `localhost:*` or `file://` screenshots are INVALID
- Many CSS features unsupported: blur(), backdrop-filter, Grid, Flexbox (partial), SVG
- Request actual inbox screenshot before claiming PASS

## PDF/Print Validation

1. **Brand assets first**: Extract exact specs with gemini-analyze-image on brand book
2. **Use actual logo files** - never recreate from description
3. **Commercial fonts**: Ask user for files or propose Google Font alternative
4. **Per-page validation**: Screenshot each page during dev, not just final PDF
5. **Page dimensions**: A4 = 794x1123px at 96 DPI; set explicit min/max height
6. **No page >20% empty white space** unless intentional
7. **Validate colors** match brand hex values exactly

## B2B SaaS Design Standards (From Reviewer Feedback)

When creating UX/UI design deliverables, apply these reviewer-validated patterns:

### Card Separation
- Use: `bg-white rounded-lg border border-gray-100/80 shadow-[0_1px_3px_rgba(0,0,0,0.04)] mb-3`
- NEVER: heavy borders (border-2, border-gray-300), strong drop shadows

### Typography Hierarchy (3-Tier)
- Section titles: `text-base font-semibold tracking-[-0.01em]`
- Item titles: `text-[13px] font-normal text-text-primary/85`
- Metadata: `text-[11px] text-text-secondary/60`
- SAME font family + weight scale across ALL screens (including AI creation)

### Icon System
- Size: 15px, stroke-width: 1.5 — consistent for ALL icons
- Color: neutral base (#9CA3AF) with soft per-type hints (#A3B8CC, #9CB5A8, #B5A8CC)
- NEVER saturated primary colors, NEVER all-gray monotone

### AI Content Placement
- AI explanations/insights: inline under the content they reference
- NEVER at page bottom or in a separate section
- Use smaller text (text-[11px]) to not compete with primary content
- When AI explanation accompanies an action bar (summary + buttons), keep BOTH in the same card separated by a thin divider + uppercase label (e.g., "AI INSIGHT"). Do NOT split into separate cards — it fragments the UI.

### Selection UX
- Always include "Select all (N/N)" checkbox for bulk actions
- Pick ONE default: all selected OR none — NEVER mixed states
- Show dynamic count, disable action button when count = 0

### Visual Indicators
- Colored borders/badges: ONLY on items with added/deleted semantic state
- **Modified items: LABEL ONLY** (no border, no outline) — card should look identical to unchanged cards
- Remove ALL decorative indicators from unchanged/default items
- Rule: if you can't explain the indicator in one word, remove it

Origin: WalkMe 2026-02-03 — purple border-2 on modified cards was #1 feedback item. Modified is a softer semantic (same item tweaked), not structural like added/deleted.

### Scrollbar Hygiene
- Use `overflow-y-auto` with `scrollbar-gutter: auto`
- NEVER force-show scrollbar when content fits

### Soft Illustration
- Calm, abstract, matching color palette
- Size: `h-[100px] w-auto object-contain opacity-70`, centered
- Position: top of content area, before title

### Design Deliverable Pipeline
1. Build React/TS prototype (not static mockups)
2. Map reviewer feedback to specific file:line changes
3. Implement via parallel code-worker agents
4. Screenshot all screens via Playwright at 1440x900
5. Validate with gemini-analyze-image (target: 90+ score)
6. Export PNGs to deliverables/, rebuild dist/, deploy to Vercel

## Hero Image Blending (Dark Mode)

When blending luminous/glow images on dark backgrounds:

1. **Position**: `position: absolute` at section root — NEVER inside grid/flex cells or Framer Motion containers
2. **Blend**: `mix-blend-mode: screen` (not lighten — lighten preserves JPEG halos)
3. **Filter**: `brightness(0.85) contrast(1.2) saturate(1.1)` to crush near-black JPEG artifacts
4. **Mask**: `radial-gradient(ellipse 55% 55%, black 15%, transparent 65%)` — soft edge fadeout
5. **Debug**: Hot-pink body background to verify blend reaches page level

### 2-Round Stop Rule
If filter/mask/blend tweaks fail twice, STOP adjusting CSS properties.
Check DOM stacking context instead:
- Does parent have transform? (Framer Motion)
- Does parent have opacity < 1?
- Does parent have filter or will-change?
- Is element inside a grid/flex item with z-index?

### AI Image Generation Spec
When generating hero images: "transparent background, no vignette, beams fade to nothing before edges, 3000px+ wide"

Origin: Tech4All 2026-02-03 — 5+ iterations wasted tweaking CSS properties when root cause was stacking context trapping mix-blend-mode.

## React Component Rules

- ALL React hooks (useState, useMemo, useEffect) BEFORE any early returns — hooks after `if (x) return` breaks Rules of Hooks
- Kill dev server before `npm run build` — concurrent access corrupts `.next` cache
- Always `browser_resize(1440, 900)` before desktop screenshots
- SVG opacity must be 0.35+ for elements under 100px (gauges, sparklines) — lower is invisible at card scale

---

## Design Research Phase (MANDATORY for "WOW factor" requests)

When user wants "breathtaking", "unique", "premium", or "not generic" design:
1. **Research first**: Use Grok/Gemini/Perplexity to study 5+ award-winning examples in the target domain
2. **Synthesize 3+ FUNDAMENTALLY DIFFERENT visual metaphors** (not grid/table/card variations)
3. Each concept must have a **unique visual language** — skyline silhouette, starfield scatter, editorial mosaic — not just different styling on the same layout
4. Present metaphors to user before implementing

Origin: Sentimark 2026-02-03 — Rounds 1-2 rejected ("same style") despite 92/100 Gemini scores. Round 3 with research phase produced 3 genuinely different concepts.

## Gemini Score Limitations

Gemini vision scores measure **TECHNICAL execution** (contrast, density, typography, color system). They do NOT measure:
- Design originality or uniqueness
- User emotional response ("would I screenshot this?")
- Whether it looks like every other fintech/SaaS dashboard

A polished generic dashboard can score 90+. Always pair Gemini scoring with a taste check: "Does this look fundamentally different from a standard dashboard?" If not, it will be rejected regardless of score.

Origin: Sentimark 2026-02-03 — Round 2 scored 92/100 on Gemini but user rejected as "same style". The score measured execution quality, not design originality.

## Data-Aware Visualization Sizing

When implementing size/importance tiers for visual hierarchy:
- **NEVER** use score VALUE thresholds when real data may cluster in narrow ranges
- **ALWAYS** use INDEX-based assignment: sort descending, assign tier by array position
- Example: Top 15% = Tier 1 (large), next 40% = Tier 2 (medium), bottom 45% = Tier 3 (compact)
- Test with actual API data, not assumed score distributions

Origin: Sentimark 2026-02-03 — sis_scores clustered 37-64, threshold-based `>= tier1Threshold` made ALL 111 assets qualify for Tier 1 (large tile).

---

## Restructure vs Redesign (CRITICAL DISTINCTION)

When a user says "redesign page X to match page Y's design language", they mean BOTH:
1. **Information Architecture** (IA): layout, section order, what information goes where, sidebar vs grid, progressive disclosure
2. **Visual Style**: gradients, typography scale, card depth/shadows, border treatments, spacing rhythm, background atmospheric effects, color contrast

Changing ONLY the IA (moving sections, adding new components, reordering content) is a **restructure**, not a redesign. The user will say "it looks the same" because the CSS visual tokens are unchanged.

### Checklist: Extract Visual Tokens from Reference Page

Before claiming a "redesign" is complete, verify these visual properties CHANGED (not just structure):

| Token | Check |
|-------|-------|
| **Hero gradient** | Does new page use gradient overlays matching reference? |
| **Typography scale** | Are heading sizes, weights, letter-spacing different from default? |
| **Card depth** | Are shadows deeper, borders more contrasty than before? |
| **Background effects** | Are there atmospheric glows, gradient meshes, or texture overlays? |
| **Spacing rhythm** | Has padding/gap scale changed to match reference? |
| **Color contrast** | Are accent colors more saturated, backgrounds more varied? |
| **Motion/animation** | Do cards or sections have entrance animations, hover states? |

### Anti-Pattern: "I restructured 770 lines of code, it must look different"

Line count and component count do NOT equal visual change. A 770-line rewrite that uses the same `bg-bg-surface`, `border-white/5`, `text-text-primary` classes as before looks IDENTICAL to the user. Extract and apply the reference page's actual CSS values.

Origin: Sentimark 2026-02-16 — Market Radar page fully restructured (hero, sidebar, CategorySnapshot, TRADE-only view, implications) but user said "all design is same as before" because visual CSS tokens were unchanged. Anti-pattern anti-075 in failure_patterns.json.

---

## Forbidden Without Proof

Never say "renders correctly" / "looks good" / "visual is complete" without:
- Playwright screenshot taken
- gemini-analyze-image analysis confirming all visual elements
