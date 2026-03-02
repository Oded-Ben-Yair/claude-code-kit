---
name: pptx-portfolio
description: UX/UI design portfolio and assignment presentation strategy. Covers narrative structure, slide architecture, typography, visual hierarchy, and anti-patterns for design case study decks. Supplements the /pptx skill (html2pptx technical workflow).
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
auto-trigger: false
manual-invoke: true
metadata:
  version: "1.0.0"
  author: odedbe
---

# Skill: pptx-portfolio

**Triggers**: portfolio, assignment, case study, deck, presentation design, UX deck

**Supplements**: The `/pptx` skill (html2pptx technical workflow). This skill covers DESIGN and CONTENT strategy only.

---

## 1. UX Portfolio Deck Structure (12-15 Slides Optimal)

### Slide Template

| # | Slide Type | Purpose | Layout |
|---|------------|---------|--------|
| 1 | Title / Cover | Hook with impact title, not generic project name | Gradient bg, centered |
| 2 | The Challenge | Frame problem in human terms, quote brief | 2-col: text + illustration |
| 3 | User Assumptions | Show empathy + user understanding | 3-card row |
| 4 | Design Approach | Bridge problem to solution | 2-col: text + accent bars |
| 5 | Cognitive Load / Strategy | Show systematic thinking | Numbered list |
| 6 | Flow Overview | Big picture before detail | Horizontal step flow |
| 7-12 | Wireframes + Annotations | Alternate: dark showcase, then white annotated | Dark/light pairs |
| 13 | Hi-Fi Screen | The hero moment | Gradient bg, large image |
| 14 | Design Decisions | Explicit rationale table | Table layout |
| 15 | Thank You / Contact | Professional close | Gradient bg, centered |

### The Dark/Light Wireframe Pattern

This creates visual rhythm and prevents monotony:

- **Odd slides (7, 9, 11)**: Dark background (`#2D3748`), wireframe image centered, large number + title only
- **Even slides (8, 10, 12)**: White background, image left at 45% width, annotations right at 50% width
- Dark slides are for **appreciation** (let the viewer absorb the design)
- Light slides are for **understanding** (explain the decisions)

---

## 2. Storytelling Framework

### Narrative Arc

```
Challenge --> Thinking --> Solution --> Evidence
```

- Open with the HUMAN problem, not the brief text
- Show causality: "Research showed X, so I designed Y"
- Side-by-side iterations (v1 to v2 to v3 with rationale for each change)
- Close with impact (metrics, user quotes, or before/after)

### The 10-Second Test

Hiring managers decide in 10 seconds:

| Time | What Happens | Pass Criteria |
|------|-------------|---------------|
| 0-3 sec | Scan title + first visual | Impact visible? Keep going. |
| 3-10 sec | Skim for metrics, outcomes, thinking | No numbers? Move on. |
| 10+ sec | Now reading | Prove you are not a "pixel pusher" |

### Opening Hook Formula

| Quality | Example |
|---------|---------|
| BAD | "Project X -- Checkout Redesign" |
| GOOD | "23% of customers abandoned at the final step -- costing thousands daily" |

Lead with the human cost, then the design response.

---

## 3. Typography Rules

### 2-Font System (MANDATORY)

| Role | PPTX-Safe Fonts | Web Fonts |
|------|----------------|-----------|
| Headlines | Arial Black, Georgia, Impact | Montserrat, Poppins |
| Body | Arial, Calibri, Calibri Light | Inter, Open Sans |

NEVER more than 2-3 font families in a single deck.

### Size Hierarchy (5-Tier)

| Element | Size | Weight |
|---------|------|--------|
| Slide title | 36-44pt | Bold |
| Section header | 20-24pt | Bold |
| Body text | 14-16pt | Regular |
| Annotations / callouts | 12-14pt | Regular |
| Small labels / numbers | 10-12pt | Regular, muted color |

### Spacing

| Rule | Value |
|------|-------|
| Margins from slide edges | 0.5" minimum |
| Between content blocks | 0.3-0.5" |
| Line-height | 1.4-1.5x font size |
| Whitespace target | 40-60% of slide area |

Whitespace is NOT wasted space. It signals confidence and clarity.

### Accessibility

- Minimum 4.5:1 contrast ratio for normal text
- Minimum 3:1 contrast ratio for large text (24pt+ or 18pt+ bold)
- Sans-serif for body text readability
- Test in grayscale to verify hierarchy works without color

---

## 4. Color System

### Sandwich Structure

```
[Dark] Title slide (gradient background)
[Light] Content slides (white/light gray)
[Light] Content slides
[Light] Content slides
[Dark] Closing slide (gradient background)
```

This creates a premium "bookend" feel.

### Palette Formula

| Role | Weight | Example |
|------|--------|---------|
| Dominant | 60-70% | Brand primary or deep neutral |
| Supporting | 20-30% | 1-2 complementary tones |
| Accent | 5-10% | Sharp, high-contrast highlight |

NEVER give all colors equal visual weight.

### For Design Assignments

- Use the **company's brand colors** as primary
- Add neutral supporting: charcoal `#2D3748`, light gray `#F8F9FA`, white `#FFFFFF`
- Semantic colors for data: green (added), amber (modified), red (removed)

---

## 5. Visual Hierarchy Rules

### One Message Per Slide

If you cannot articulate the slide's core idea in ONE sentence, restructure it. Dense text blocks are a rejection signal.

### The Annotation Pattern (for Wireframes/Mockups)

**Step 1 -- Dark showcase slide:**
- Full-width wireframe on dark background
- Minimal text: large number + title only
- Purpose: let the viewer appreciate the design

**Step 2 -- White annotation slide:**
- Image at 45% left
- 3-4 numbered callouts on the right at 50%
- Each callout: Bold label + 1-line explanation
- Purpose: explain the reasoning

### Image Presentation

| Image Type | Background | Treatment |
|------------|------------|-----------|
| Wireframes | Dark (`#2D3748`) | High contrast, centered |
| Mockups | White | Shadow treatment (white padding + subtle shadow) |
| Hi-fi screens | Gradient or dark | 80-90% slide width, show detail |

ALWAYS use explicit width/height attributes. Never let images stretch or distort.

---

## 6. Wireframe Annotation Technique

### The 2-Column Layout

```
+-------------------------+------------------------+
|                         |                        |
|   [Wireframe Image]     |  (1) Bold Label        |
|   at 45% width          |      1-line explain    |
|                         |                        |
|                         |  (2) Bold Label        |
|                         |      1-line explain    |
|                         |                        |
|                         |  (3) Bold Label        |
|                         |      1-line explain    |
|                         |                        |
+-------------------------+------------------------+
```

### Callout Rules

| Rule | Value |
|------|-------|
| Max callouts per slide | 4 |
| Title font size | 14pt, Bold |
| Description font size | 12pt, muted color |
| Accent | Indigo left-border on each callout div |
| Text length | One line per callout explanation |

---

## 7. Anti-Patterns (NEVER DO)

### Slide Design Anti-Patterns

| Anti-Pattern | Why It Fails |
|-------------|-------------|
| Accent lines under titles | Hallmark of AI-generated slides |
| Text walls (>5 lines) | Unreadable, signals lazy thinking |
| All-caps body text | Reduces readability by 30% |
| Generic stock photos | Use actual project artifacts |
| Same layout repeated every slide | Monotonous, loses attention |
| Centered body text | Left-align paragraphs; center only titles |
| Low-contrast elements | Light on light or dark on dark = invisible |
| Cramped spacing | Always leave breathing room |

### Portfolio Content Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Describing UI instead of showing it | Screenshot or mockup |
| "We did research" without findings | Show what you FOUND |
| Vague impact ("improved UX") | Say "reduced abandonment 23% to 18%" |
| Unclear role attribution | Say "I designed X; Sarah did Y" |
| Chronological process log | Narrative arc: Challenge to Solution |
| Generic language ("leveraged synergistic...") | Plain, specific language |
| Cookie-cutter templates | Customize to reflect your aesthetic |

### Technical Anti-Patterns

| Anti-Pattern | Fix |
|-------------|-----|
| Pixelated/blurry images | Resize with quality preservation |
| Broken links or placeholder text | Remove or replace before export |
| Inconsistent fonts/colors | Audit every slide against style guide |
| Progressive reveals for async review | Show full slide (reviewer is not in the room) |

---

## 8. 2026 Design Trends for Presentations

### Bold Minimalism

- 40-60% whitespace
- High-contrast color palettes
- One key message per slide
- Strategic simplicity with confident elements

### Glassmorphism and Depth

- Semi-transparent layers (20-40% opacity)
- Subtle shadows for dimension
- Replaces flat design fatigue

### Atmospheric Gradients

- Restrained color transitions (not neon)
- Warm gradients = approachability; Cool gradients = trust/stability
- Strategic deployment: title/closing slides only, not every slide

### Authenticity Over Polish

- "AI fatigue" drives demand for human-crafted feel
- Mixed media, texture, intentional imperfection
- Must read as deliberate, not accidental

---

## 9. Hiring Manager Evaluation Criteria

### What They Judge

| Element | What They Want | Red Flags |
|---------|---------------|-----------|
| Ownership | "I led ideation and iterations" | Unclear role |
| Reasoning | "Chose X for accessibility + speed" | "I liked it" |
| Impact | Metrics with context | No quantification |
| Craft | Consistency, production awareness | Generic templates |
| Process | Research to decision causality | Activity list without insights |

### For Design Assignments Specifically

1. Follow provided guidelines EXACTLY (if they say 3 slides, do 3)
2. Show full cycle thinking (research to design to validation)
3. Demonstrate passion through quality and thoughtfulness
4. Include usability testing results when available
5. Acknowledge constraints honestly (budget, timeline, trade-offs)

---

## 10. Format and Delivery

### PPTX Specifics (via html2pptx workflow)

- Use the `/pptx` skill for technical implementation details
- Web-safe fonts only (Arial, Georgia, Verdana)
- Pre-render gradients as PNG backgrounds (no CSS gradients in PPTX)
- All text must be in proper HTML tags (`<p>`, `<h1>`, `<table>`, etc.)
- Test with thumbnail validation before declaring done

### Slide Count by Context

| Context | Slide Count |
|---------|-------------|
| Live presentation (30-45 min) | 30-45 slides |
| Design assignment submission | 12-15 slides |
| Recorded walkthrough (5 min) | 5-7 slides |
| Portfolio case study | 8-12 slides |

Always follow provided guidelines over these defaults.

### Pre-Export Checklist

```
[ ] Every slide has ONE clear message
[ ] Typography uses max 2 font families
[ ] Color palette has clear dominant/supporting/accent hierarchy
[ ] Dark/light rhythm in wireframe section
[ ] No text walls (max 3-5 lines per content block)
[ ] All images are high-resolution with explicit dimensions
[ ] Annotations use the 2-column pattern
[ ] Opening slide has impact hook (not generic title)
[ ] Closing slide has contact info
[ ] Tested in grayscale for hierarchy
[ ] Checked for consistent spacing and alignment
[ ] No accent lines under titles
```

---

## 11. Quick Reference: Slide-by-Slide Checklist

Use this when building each slide:

```
TITLE SLIDE
  - Impact hook, not project name
  - Gradient or dark background
  - Centered layout
  - Brand colors present

CHALLENGE SLIDE
  - Human problem framing
  - Quote from brief or user
  - 2-column layout

WIREFRAME SHOWCASE (dark)
  - Background: #2D3748
  - Image centered, large
  - Large number + short title only
  - No annotations on this slide

WIREFRAME ANNOTATIONS (light)
  - White background
  - Image at 45% left
  - 3-4 callouts at 50% right
  - Indigo left-border accent
  - Bold label + 1-line description each

HI-FI HERO SLIDE
  - Gradient background
  - Image at 80-90% width
  - Minimal surrounding text
  - Shadow treatment on mockup

DECISIONS SLIDE
  - Table format
  - Columns: Decision | Rationale | Alternative Considered
  - Clean grid lines

CLOSING SLIDE
  - Gradient background matching title slide
  - Name, contact, thank you
  - Centered layout
```
