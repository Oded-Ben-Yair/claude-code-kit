---
name: frontend
description: |
  Unified frontend skill with smart routing. Single entry point for ALL frontend/design work:
  - Design-to-code (screenshots, mockups, Figma)
  - Premium UI components and effects
  - Typography-first design (anti-AI-slop)
  - Accessibility auditing
  - Visual verification

  This skill automatically routes to the right mode based on your task.

  Keywords: frontend, design, ui, ux, css, tailwind, react, component, figma, typography, animations, effects, premium, accessibility
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, mcp__gemini__*, mcp__playwright__*
metadata:
  version: "1.0.0"
  author: odedbe
---

# Frontend Skill

**Single entry point for all frontend/design work.** This skill unifies and routes to:
- Design-to-code conversions
- Premium effects and animations
- Typography-first design
- Figma-specific workflows
- Accessibility auditing
- Visual verification

## Smart Router

The skill automatically detects your task and loads the appropriate mode:

```
User Request                              Route To
─────────────────────────────────────────────────────────────────
"convert this design to code"          → Design-to-Code Mode
"build from this Figma"                → Figma Mode
"create a premium hero section"        → Effects Mode + Design
"add hover animations"                 → Effects Mode
"check accessibility"                  → Audit Mode
"take screenshot and compare"          → Verification Mode
"verify the design looks right"        → Verification Mode
"build a component with good fonts"    → Design-to-Code Mode
"add AI chatbot to dashboard"          → AI Dashboard Mode
"create tether lines for provenance"   → AI Dashboard Mode
"build insight card with evidence"     → AI Dashboard Mode
"this looks generic, make it unique"   → Iteration Mode (Research Phase)
"improve based on feedback"            → Iteration Mode
"create something breathtaking"        → Research Phase → Design-to-Code
"make a dashboard with charts"         → Design-to-Code + Data Viz ref
```

### Route Detection Keywords

| Mode | Trigger Keywords |
|------|------------------|
| **design-to-code** | screenshot, mockup, implement design, build component, convert design |
| **figma** | figma, auto-layout, design tokens, figma export, variants |
| **effects** | animation, hover, premium, effects, parallax, magnetic, aurora, 3d |
| **audit** | accessibility, a11y, WCAG, audit, contrast, screen reader |
| **verify** | screenshot, compare, visual test, verify, check UI, proof, validate |
| **iteration** | feedback, improve, iterate, refine, generic, same style, not right, change direction |
| **ai-dashboard** | AI dashboard, chatbot integration, provenance, tether lines, insight card, contextual AI, widget chat, bidirectional highlight |

### Research Phase Auto-Trigger

When these words appear, **automatically enter Research Phase** (via Iteration Mode) before any implementation:
- "breathtaking", "wow", "unique", "not generic", "premium feel", "award-winning"
- This means: study 5+ references → 3+ different visual metaphors → user picks → then implement

---

## Core Principles (Always Apply)

### 1. Typography First (Anti-AI-Slop)

Typography is THE primary differentiator. Every component starts here:

| Technique | Impact | How |
|-----------|--------|-----|
| **Distinctive Fonts** | Instant identity | Never Inter/Roboto/Arial. Use Bricolage Grotesque, Space Grotesk, DM Serif |
| **Font Pairing** | Visual hierarchy | Serif display + Sans body (or inverse) |
| **Fluid Typography** | Modern responsive | Always `clamp()` for sizing |
| **Variable Weights** | Brand precision | Exact weights (385, 465, 685) not bold/normal |
| **OpenType Features** | Polish | ss01, liga, onum on display text |

### 2. Performance Non-Negotiable

- 60fps animations or nothing
- Transform/opacity only (no layout animations)
- Respect `prefers-reduced-motion`

### 3. Accessibility First

- WCAG AA minimum (4.5:1 contrast)
- 44x44px touch targets
- Keyboard navigation
- Focus states visible
- Semantic HTML

### 4. Restraint Over Spectacle

**One Per Viewport Rule** - Only one of each:
- Magnetic button
- Custom cursor
- Aurora/blob background
- Parallax effect
- 3D floating element
- Tracing beam

---

## Quick Reference: Brand Feels

When determining composition, first identify brand feel:

| Feel | Typography | Animations | Effects |
|------|------------|------------|---------|
| **Minimal** | DM Serif + DM Sans | Subtle fades (300ms) | None - let type speak |
| **Futuristic** | Space Grotesk + Source Sans | Text decrypt, glitch | Aurora, particles, grids |
| **Playful** | Bricolage + Newsreader | Bouncy, staggered | Blobs, cursor trails |
| **Corporate** | IBM Plex Sans + Serif | Precise micro-interactions | Progress indicators |
| **Editorial** | Playfair + IBM Plex | Scroll reveals | Parallax images |

---

## Modes Reference

### Design-to-Code Mode
**File**: `modes/design-to-code.md`

For converting designs to code:
1. Analyze design with Gemini 3 Pro (HIGH resolution)
2. Extract colors, typography, spacing, components
3. Implement with React + Tailwind
4. Apply typography-first principles
5. Verify with screenshot comparison

### Figma Mode
**File**: `modes/figma.md`

For Figma-specific workflows:
- Auto-layout → flexbox/grid
- Design tokens extraction
- Component variants → parameterized props
- Dev Mode annotations priority

### Effects Mode
**File**: `modes/effects.md`

For animations and premium effects:
- Scroll-triggered animations
- Micro-interactions (hover, cursor)
- Visual effects (backgrounds, glassmorphism)
- 3D effects (React Three Fiber)

**ROI Rankings** (Impact vs Effort):
1. Direction-aware hover - Very High
2. Magnetic button - Very High
3. Staggered text reveal - Very High
4. Aurora background - High
5. Custom cursor - High

### Audit Mode
**File**: `modes/audit.md`

For accessibility and quality:
- WCAG 2.1 AA/AAA compliance
- Color contrast analysis
- Focus order verification
- Touch target sizing
- Playwright test generation

### Verification Mode (MANDATORY)
**File**: `modes/verification.md`

The proof pipeline — no design is "done" without this:
1. Pre-screenshot checklist (console errors = blocking)
2. CDN/library audit (grep usage before debugging interactions)
3. Screenshot capture at multiple viewports (375px, 768px, 1440px)
4. Gemini visual analysis (HIGH resolution, target 90+)
5. **Taste check**: Gemini score ≠ originality. A generic dashboard scores 90+.
6. Platform-specific rules (email, PDF, deployment)

### Iteration Mode
**File**: `modes/iteration.md`

Structured feedback loop that prevents endless CSS tweaking:
- **Classify feedback**: CSS/polish issue vs concept/direction issue
- **CSS issues**: Map to file:line, implement, verify. Max 3 rounds.
- **Concept issues**: Enter Research Phase (study references, generate 3+ different visual metaphors). Max 2 rounds.
- **Stagnation test**: If no improvement after a round, stop CSS and change direction
- **Parallel agents**: For 5+ independent components with feedback

### AI Dashboard Mode
**File**: `modes/ai-dashboard.md`

For AI-integrated analytics dashboards:
- **Provenance tethers**: SVG Bezier curves connecting AI answers to data sources
- **InsightCard**: Floating cards with evidence items and confidence badges
- **Bidirectional highlighting**: Hover evidence → highlight chart (and vice versa)
- **Widget-specific chat**: Contextual Q&A tied to each dashboard widget

**Key Patterns**:
1. Every AI claim links to visible evidence
2. Tether lines animate on appear, highlight on hover
3. Non-highlighted chart elements dim to 30%
4. Suggested questions > blank chat input

**Reference**: `references/ai-integration.md` for trust principles and anti-patterns

---

## Tools Available

### Playwright MCP (Browser)
```yaml
browser_navigate      # Open URLs
browser_take_screenshot  # Capture screenshots
browser_snapshot      # Accessibility tree
browser_click        # Interact with elements
```

### Gemini MCP (Vision + Generation)
```yaml
gemini-query         # Design analysis (thinking_level: high, media_resolution: HIGH)
gemini-analyze-code  # Code review
gemini-generate-image  # Mockup generation (1K/2K/4K)
gemini-url-context   # Analyze live URLs
```

**Critical**: Gemini temperature must stay at 1.0 (default). Never change.

---

## Workflow

### Standard Component Build

```
1. RESEARCH PHASE (if "wow/unique/breathtaking" requested)
   → Study 5+ award-winning examples via Grok/Gemini/Perplexity
   → Synthesize 3+ fundamentally different visual metaphors
   → Present concepts to user BEFORE implementing
   → Skip this step for routine/incremental work

2. IDENTIFY BRAND
   → Check brand-presets/ for existing guidelines
   → Or determine feel: minimal/futuristic/playful/corporate/editorial

3. LOAD MODE
   → Based on task, load appropriate mode file
   → For complex work, may combine modes

4. APPLY TYPOGRAPHY
   → Load references/typography.md
   → Select font pairing
   → Implement fluid sizing

5. ADD EFFECTS (if needed)
   → Load modes/effects.md
   → Select techniques based on ROI
   → Apply restraint (one per viewport)

6. VERIFY (MANDATORY — modes/verification.md)
   → Pre-screenshot checklist (console errors = blocking)
   → CDN/library audit (grep usage before debugging)
   → Screenshot with Playwright at 1440x900
   → Analyze with Gemini (HIGH resolution, target 90+)
   → TASTE CHECK: "Does this look fundamentally different?"
   → If Gemini 90+ but tastes generic → go to step 7

7. ITERATE (if needed — modes/iteration.md)
   → Classify feedback: CSS issue vs concept issue
   → CSS: map to file:line, max 3 rounds
   → Concept: enter Research Phase, max 2 rounds
   → Stagnation test: if no improvement after round, escalate
```

---

## Brand Presets

Pre-configured brand guidelines in `brand-presets/`:

| Brand | Primary | Secondary | Feel |
|-------|---------|-----------|------|
| Seekapa | Deep Blue #1E3A5F | Gold #D4AF37 | Corporate/Trustworthy |
| Sentimark | Market Green | Data Blue | Analytical |
| QC App | Navy | Accent Cyan | Professional |
| Training | Educational Blue | Warm Orange | Approachable |

Load with: `~/.claude/skills/frontend/brand-presets/<brand>.md`

---

## Anti-Patterns (Never Do)

### Typography
- Inter, Roboto, Arial (signals AI)
- Single font layouts
- `font-weight: bold` (use exact weights)
- Fixed breakpoint text sizes

### Animation
- Bounce easing everywhere
- Linear easing
- >500ms duration
- Simultaneous animations

### Effects
- Rainbow gradients
- Parallax on everything
- Glowing everything
- Purposeless particles

### Interactions
- Same hover on everything
- Instant state changes
- Cursor effects everywhere
- Ripples on non-buttons

---

## Dependencies (Standard Stack)

```json
{
  "framer-motion": "^11.x",
  "@react-three/fiber": "^8.x",
  "@react-three/drei": "^9.x",
  "tailwind-merge": "^2.x",
  "clsx": "^2.x"
}
```

**Utility function** (always include):
```tsx
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

---

## Quick Start Examples

### "Build a hero section for a tech startup"
```
Route: Effects Mode + Design-to-Code
Brand: Futuristic
Load: modes/effects.md (aurora, text-reveal)
      references/typography.md (Space Grotesk pairing)
```

### "Convert this Figma design to React"
```
Route: Figma Mode
Load: modes/figma.md
      References from Figma Dev Mode annotations
```

### "Add hover effects to these cards"
```
Route: Effects Mode
Load: modes/effects.md (direction-aware hover)
Apply: Single technique, test performance
```

### "Check if this page is accessible"
```
Route: Audit Mode
Load: modes/audit.md
Use: Playwright snapshot + Gemini analysis
Output: WCAG compliance report + fixes
```

### "Add AI chatbot to my analytics dashboard"
```
Route: AI Dashboard Mode
Load: modes/ai-dashboard.md
      references/ai-integration.md
Apply: Contextual chat, provenance tethers, bidirectional highlighting
Output: Widget-specific Q&A with visual source attribution
```

### "Create a breathtaking data dashboard"
```
Route: Research Phase → Design-to-Code + Data Viz
Load: modes/iteration.md (Research Phase)
      references/design-patterns.md (Data Visualization Patterns)
      modes/design-to-code.md
Process:
  1. Study 5+ award-winning dashboards
  2. Present 3 different visual metaphors
  3. User picks direction
  4. Implement with data-viz patterns (index-based sizing, chart selection guide)
  5. Verify with taste check
```

---

## Integration

This skill consolidates:
- `premium-frontend` (now deprecated)
- `design-to-code` (now deprecated)
- `figma` (now deprecated)
- `premium-effects` (kept as sub-library, not directly invokable)
- `superdesign-enhanced` (archived — capabilities folded into modes)
- `design-specialist` (archived — capabilities folded into modes)
- `gemini-design-coder` (archived — pipeline folded into verification/iteration)

**Agents that work with this skill:**
- `gemini-specialist` - For visual analysis, image generation, document parsing
- `code-worker` - For implementing designs from plans
- `code-judge` - For reviewing generated code quality

---

## Production Design Patterns

**File**: `references/design-patterns.md`

Proven UX/UI patterns validated in production (WalkMe, Sentimark, Tech4All, dig.ai):
- Card separation, typography hierarchy, icon system
- AI content placement, selection UX, visual indicators
- Hero image blending recipe (dark mode)
- Dual-model brainstorm workflow for creative work
- Iterative Gemini vision scoring loop (target 90+)
- Parallel code-worker agents for 5+ independent components
- **Data visualization**: Chart selection guide, index-based sizing, dynamic range normalization
- **Project patterns**: Phase color-coding, Glass-Box demos, trading chart palettes, ESLint color enforcement, SWA config, modified-item semantics

**Load this reference for any design/UX task.**
