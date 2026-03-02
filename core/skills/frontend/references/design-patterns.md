# Proven UX/UI Design Patterns

> Production-validated patterns from WalkMe, Sentimark, Tech4All, dig.ai projects.
> Loaded by /frontend skill when invoked. NOT in main session context.

## Card & Container Patterns

| Pattern | Implementation | Anti-Pattern |
|---------|---------------|--------------|
| Card separation | `bg-white rounded-lg border border-gray-100/80 shadow-[0_1px_3px_rgba(0,0,0,0.04)] mb-3` | Heavy borders (border-2, border-gray-300), strong shadows |
| Scrollbar hygiene | `overflow-y-auto` + `scrollbar-gutter: auto` | Force-show scrollbar when content fits |
| Soft illustration | `h-[100px] w-auto object-contain opacity-70`, centered, top of content | Large hero images competing with content |

## Typography Hierarchy (3-Tier)

| Tier | Style | Use |
|------|-------|-----|
| Section titles | `text-base font-semibold tracking-[-0.01em]` | Main headings |
| Item titles | `text-[13px] font-normal text-text-primary/85` | List items |
| Metadata | `text-[11px] text-text-secondary/60` | Timestamps, counts |

**Rule**: Same font family + weight scale across ALL screens (including AI-generated screens).

## Icon System

- Size: 15px, stroke-width: 1.5 — consistent for ALL icons
- Color: neutral base (#9CA3AF) with soft per-type hints (#A3B8CC, #9CB5A8, #B5A8CC)
- NEVER saturated primary colors, NEVER all-gray monotone

## AI Content Placement

- AI explanations/insights: **inline under the content they reference**
- NEVER at page bottom or in a separate section
- Use smaller text (`text-[11px]`) to not compete with primary content
- Enterprise AI: data-first, AI-second. Anomalies trigger AI, not users.

## Selection UX

- Always include "Select all (N/N)" checkbox for bulk actions
- Pick ONE default: all selected OR none — NEVER mixed states
- Show dynamic count, disable action button when count = 0

## Visual Indicators

- Colored borders/badges: ONLY on items with semantic state (added/modified/deleted)
- Remove ALL decorative indicators from unchanged/default items
- Rule: if you can't explain the indicator in one word, remove it

## SVG Visualization

- Gradient fill sparklines: areaPath + vertical gradient (0.4→0.02 opacity)
- SVG opacity 0.35+ for components under 100px (gauges, sparklines)
- Radial gauges: purple outer ring, turquoise inner for dual-metric display

## Hero Image Blending (Dark Mode)

```css
.hero-blend-wrapper {
  position: absolute; /* MUST be outside grid/flex/Framer Motion containers */
  pointer-events: none;
  mix-blend-mode: screen; /* NOT lighten — lighten preserves JPEG halos */
  filter: brightness(0.85) contrast(1.2) saturate(1.1); /* crush near-black artifacts */
  mask-image: radial-gradient(ellipse 55% 55% at 50% 50%, black 15%, transparent 65%);
}
```

**Stacking context traps** (things that break mix-blend-mode):
- `transform` (Framer Motion), `opacity < 1`, `filter` on parent, `will-change`, grid/flex + z-index

**2-round stop rule**: If 2 CSS property tweaks fail, check DOM stacking context instead.

## Design Workflow Patterns

### Dual-Model Brainstorm
Use GPT-5 Pro + Gemini 3 Pro in parallel for creative work. Produces genuinely different directions, not variations.

### Iterative Gemini Vision Scoring
1. Screenshot with Playwright at 1440x900
2. Analyze with gemini-analyze-image
3. Fix top 3 gaps identified
4. Repeat until score >= 90/100

### Parallel Code-Worker Agents
For 5+ independent components, split into 3 groups and launch parallel code-worker agents. Zero merge conflicts when components are independent files.

### Mix-and-Match Selection
Generate 3 pure concept directions + 3 hybrid mixes (6 total). Users prefer hybrids over any single pure concept.

## Brand Exploration Pattern

1. Dual-model brainstorm for 3 divergent directions (safe/bold/breaking)
2. Complete brandbook per option: hex codes, Google Fonts, logo concept, 5 design keywords
3. Generate logo + homepage mockup per direction (visual-first)
4. Comparison table for fast executive decision
5. Name concepts memorably, not "Option 1/2/3"

---

## Data Visualization Patterns

### Chart Type Selection Guide

| Data Relationship | Chart Type | When |
|-------------------|-----------|------|
| Part-to-whole | Pie, Donut, Treemap | Showing composition (< 7 segments) |
| Comparison | Bar (vertical/horizontal) | Comparing discrete categories |
| Trend over time | Line, Area | Time-series data |
| Correlation | Scatter, Bubble | Two+ variable relationship |
| Distribution | Histogram, Box plot | Data spread and outliers |
| Ranking | Horizontal bar | Ordered comparison |
| Flow/Process | Sankey, Funnel | Conversion or flow data |
| Geographic | Choropleth, Bubble map | Location-based data |

### Data-Aware Sizing (Index-Based Assignment)

**NEVER use value-based thresholds when real data may cluster in narrow ranges.**
**ALWAYS use index-based assignment: sort descending, assign tier by position.**

```typescript
// BAD: Value thresholds — all items may qualify for same tier
const tier = score >= 80 ? 'large' : score >= 50 ? 'medium' : 'small';

// GOOD: Index-based — guarantees exact percentile splits
const sorted = items.sort((a, b) => b.score - a.score);
const tier1Count = Math.ceil(sorted.length * 0.15); // Top 15%
const tier2Count = Math.ceil(sorted.length * 0.40); // Next 40%

sorted.forEach((item, index) => {
  if (index < tier1Count) item.tier = 'large';
  else if (index < tier1Count + tier2Count) item.tier = 'medium';
  else item.tier = 'compact';
});
```

> Origin: Sentimark 2026-02-03 — sis_scores clustered 37-64. Value threshold `>= tier1Threshold` made ALL 111 assets qualify for Tier 1 (large tile).

### Dynamic Range Normalization

Map actual min-max to full visual range:
```typescript
const normalize = (value: number, min: number, max: number, targetMin: number, targetMax: number) =>
  targetMin + ((value - min) / (max - min)) * (targetMax - targetMin);

// Example: scores 37-64 → pixel sizes 50-500
const size = normalize(score, actualMin, actualMax, 50, 500);
```

### Visualization Style Presets

| Preset | Background | Text | Accent | Use |
|--------|-----------|------|--------|-----|
| Business/Corporate | White | #1F2937 | #3B82F6 | Reports, dashboards |
| Modern/Tech | #0F172A | #F8FAFC | #6366F1 | Tech products |
| Financial | White | #111827 | #059669 | Trading, fintech |
| Dark Analytics | #0E1118 | #E2E8F0 | #2CE7E3 | Data platforms |

### Resolution & Aspect Ratios

| Context | Resolution | Aspect |
|---------|-----------|--------|
| Social media | 1K | 1:1 |
| Web/dashboard | 2K | 16:9 or 4:3 |
| Presentations | 2K | 16:9 |
| Print/report | 4K | Custom |
| Mobile | 1K | 9:16 |

---

## Project-Specific Patterns (Production-Validated)

### Phase Color-Coding (Tech4All)

Use CSS custom properties for phase-based visual hierarchy:

```css
[data-phase='insight'] { --phase-color: #00F0FF; }   /* Cyan */
[data-phase='engagement'] { --phase-color: #FF00AA; } /* Magenta */
[data-phase='security'] { --phase-color: #CCFF00; }   /* Lime */
```

Consistent across all UI elements: borders, badges, icons, backgrounds.

### Glass-Box Simulation (Tech4All)

For product demos, use state-machine approach:
```
idle → processing → success
```
- Provides immediate user feedback (users think demo is broken without it)
- 90% impact with 10% effort
- Show actual AI processing animation, not static screenshots

### Trading Chart Palette (Automation-Fabric)

| Element | Color | Note |
|---------|-------|------|
| Bullish candle | White/hollow, #1976D2 stroke | NOT green — Trading Central standard |
| Bearish candle | Black/filled | Classic |
| Bollinger Bands | #FFEBEE shading (30-50% opacity) | Pink, not gray |
| Bollinger lines | #E57373 (red) | |
| MA50 | #1976D2 (blue) | |
| RSI | #1976D2 (blue) | |
| Targets | #4CAF50 (green) | |
| Stops | #F44336 (red) | |

### ESLint Color Enforcement (Sentimark)

For projects with strict brand colors, enforce via ESLint:
```javascript
// eslint rule: sentimark/no-hardcoded-colors
// Blocks builds with inline hex violations
// All colors must come from lib/chart-colors.ts
import { chartColors } from '@/lib/chart-colors';
```

### SWA Configuration (Tech4All)

```json
// staticwebapp.config.json
{
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/assets/*", "/*.js", "/*.css", "/*.ico"]
  }
}
// NEVER use route: /* (intercepts static assets causing CSP errors)
```

### Modified Item Visual Semantics (WalkMe)

| Semantic State | Visual Treatment |
|----------------|-----------------|
| Added | Green border + "Added" badge |
| Deleted | Red border + "Deleted" badge |
| Modified | **Label only** — no border, no outline, card identical to unchanged |

> Origin: WalkMe 2026-02-03 — purple border-2 on modified cards was #1 feedback item. Modified is a softer semantic (same item tweaked), not structural like added/deleted.
