# AI Integration Design Reference

Principles for building trustworthy AI-integrated interfaces.

---

## Core Principles

### 1. Visual Source Attribution

**Every AI claim must link to visible evidence.**

| Principle | Implementation |
|-----------|----------------|
| No floating claims | Every insight connects to data via tether lines |
| Source on demand | "Receipts toggle" to show/hide provenance |
| Confidence visible | High/medium/low badges on AI responses |
| Timeframe clear | "Last 7 days", "Since Jan 1" on all insights |

**Why**: Users don't trust AI that can't show its work. Visual attribution transforms "trust me" into "see for yourself."

### 2. Contextual Over Generic

**AI should know what the user is looking at.**

| Generic (Bad) | Contextual (Good) |
|---------------|-------------------|
| "Ask me anything" | "Ask about Chiefs sentiment" |
| Blank chat input | Suggested questions based on current widget |
| Same responses everywhere | Answers reference visible data points |
| Modal popup | Sidebar that preserves dashboard context |

**Why**: Generic chatbots feel disconnected. Contextual AI feels like a knowledgeable colleague looking at the same screen.

### 3. Bidirectional Feedback

**Interaction flows both ways: AI ↔ Data.**

```
User hovers evidence item
    → Tether line highlights
    → Chart element highlights
    → Other elements dim

User hovers chart element
    → Related evidence highlights
    → Tether pulses
```

**Why**: Creates mental model of connections. User understands "this insight came from that data."

### 4. Progressive Disclosure

**Start simple, reveal depth on demand.**

```
Level 1: Headline claim ("Chiefs lead at 35%")
Level 2: Supporting explanation (click to expand)
Level 3: Evidence items with tethers (hover to highlight)
Level 4: Raw data source (click evidence to drill down)
```

**Why**: Avoids overwhelming while allowing deep investigation.

---

## Anti-Patterns (Never Do)

### Blank Chat Box

```
❌ "Ask me anything..."
   [empty input field]

✓  "Team Sentiment Analysis"
   [Why are Chiefs at 35%?]
   [Compare to last week?]
   [What's driving this?]
```

**Why bad**: Intimidating, no guidance, users don't know what to ask.

### Disconnected Responses

```
❌ AI answers about data not visible on screen
❌ References "the chart" without specifying which
❌ Uses different terminology than the UI

✓  "The Team Sentiment chart shows Chiefs at 35%..."
✓  Tether line connects answer to specific pie slice
```

**Why bad**: User can't verify, feels like hallucination risk.

### Modal Trap

```
❌ Full-screen modal that hides the dashboard
❌ Chat that covers the data being discussed

✓  Slide-in sidebar that preserves context
✓  Floating card positioned near relevant data
```

**Why bad**: User loses context they're asking about.

### Generic Questions

```
❌ "Tell me more"
❌ "What does this mean?"
❌ "Analyze this"

✓  "Why did Chiefs sentiment spike on Jan 15?"
✓  "How does 35% compare to historical average?"
✓  "What content drove the 49ers' 25% share?"
```

**Why bad**: Vague questions get vague answers. Specific questions show AI understands the data.

### Hallucination Without Warning

```
❌ Confident answer with no source
❌ Made-up statistics
❌ Extrapolation presented as fact

✓  "Based on data from Jan 1-15..." (explicit timeframe)
✓  "High confidence" / "Medium confidence" badge
✓  "I don't have data for that period" when uncertain
```

**Why bad**: Destroys trust instantly if caught.

---

## Trust Signals

Visual elements that build user confidence:

| Signal | Implementation |
|--------|----------------|
| **Tether lines** | SVG Bezier curves from answer to data |
| **Evidence chips** | Clickable items that highlight sources |
| **Confidence badge** | High/Medium/Low with icon |
| **Timeframe label** | "Last 7 days" always visible |
| **Source count** | "Evidence (3)" shows backing |
| **Highlight sync** | Hover evidence = highlight chart |

---

## Color Language for AI

| State | Color | Usage |
|-------|-------|-------|
| AI accent | Violet/Purple (#7C3AED) | AI icons, active states, tethers |
| Confidence high | Green (#10B981) | High confidence badge |
| Confidence medium | Amber (#F59E0B) | Medium confidence badge |
| Confidence low | Gray (#6B7280) | Low confidence badge |
| Hover highlight | Indigo (#6366F1) | Tether hover, evidence hover |
| Dimmed | 30% opacity | Non-highlighted chart elements |

---

## Animation Guidelines

### Tether Lines

```css
/* Draw animation */
stroke-dasharray: 1000;
stroke-dashoffset: 1000;
animation: draw 0.8s ease-out forwards;

/* Hover transition */
transition: stroke 0.3s, stroke-width 0.3s;
```

### Sidebar

```tsx
// Framer Motion
<motion.div
  initial={{ x: '100%' }}
  animate={{ x: 0 }}
  exit={{ x: '100%' }}
  transition={{ type: 'spring', damping: 25, stiffness: 200 }}
>
```

### Highlighting

```css
/* Chart element highlight */
transition: opacity 0.3s ease, stroke 0.3s ease;

/* Evidence item hover */
transition: background-color 0.2s ease;
```

---

## Accessibility

### Keyboard Navigation

- `Tab` through evidence items
- `Enter` to select/expand
- `Escape` to close cards/sidebars
- Arrow keys within chat

### Screen Readers

```tsx
<div role="complementary" aria-label="AI Insights Panel">
  <h2 id="insight-heading">{headline}</h2>
  <div aria-describedby="insight-heading">
    {/* evidence items */}
  </div>
</div>
```

### Focus Management

- Focus trap in open sidebars
- Return focus to trigger element on close
- Visible focus rings on all interactive elements

---

## Testing Checklist

### Visual Verification

```bash
# Take screenshot
mcp__playwright__browser_take_screenshot

# Verify with Gemini
mcp__gemini__gemini-analyze-image
# Prompt: "Check that tether lines connect AI evidence to chart data points correctly"
```

### Interaction Testing

- [ ] Click widget → sidebar opens with correct questions
- [ ] Click question → answer appears with evidence
- [ ] Hover evidence → tether highlights + chart highlights
- [ ] Hover chart element → related evidence highlights
- [ ] Click outside → card/sidebar closes
- [ ] Press Escape → card/sidebar closes
- [ ] Tab through evidence items works
- [ ] Mobile: tap interactions work

---

## Research Sources

These patterns were validated through:

1. **Brand analysis**: dig.ai existing product patterns
2. **Competitive analysis**: Tableau Ask Data, Power BI Copilot, ThoughtSpot Sage
3. **Multi-model debate**: 5-model consensus on placement and interaction patterns
4. **User mental models**: "Point and ask" natural interaction pattern

Key finding: **Contextual AI integrated with visual attribution outperforms generic chatbots by building trust through transparency.**
