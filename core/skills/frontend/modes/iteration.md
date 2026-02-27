# Iteration Mode

Structured design feedback loop. Prevents the "endless CSS tweaking" trap.

## When to Use

- After verification mode flags issues
- When user provides design feedback
- When Gemini scores high but taste check fails
- When "wow factor" is requested but design feels generic

---

## The Iteration Loop

```
                    ┌─────────────────────┐
                    │  FEEDBACK RECEIVED   │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │  CLASSIFY FEEDBACK   │
                    │  (CSS vs Concept?)   │
                    └──────────┬──────────┘
                          ┌────┴────┐
                     CSS Issue    Concept Issue
                          │            │
                    ┌─────▼─────┐  ┌──▼──────────┐
                    │ Map to     │  │ Research     │
                    │ file:line  │  │ Phase        │
                    │ changes    │  │ (new visual  │
                    └─────┬─────┘  │  metaphor)   │
                          │        └──────┬───────┘
                    ┌─────▼───────────────▼──────┐
                    │     IMPLEMENT CHANGES       │
                    └──────────┬──────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │  VERIFY (screenshot  │
                    │  + Gemini + taste)   │
                    └──────────┬──────────┘
                          ┌────┴────┐
                       PASS       FAIL
                          │         │
                     ┌────▼───┐  ┌──▼──────────┐
                     │ DONE   │  │ Max rounds?  │
                     └────────┘  │ (3 CSS or    │
                                 │  2 concept)  │
                                 └──────┬───────┘
                                   ┌────┴────┐
                                 No         Yes
                                   │         │
                              Loop back   ESCALATE
                                        (ask user for
                                         direction)
```

---

## Step 1: Classify Feedback

Every piece of feedback falls into one of two categories:

### CSS/Polish Issues (Quick Fix)
- "Make the spacing bigger"
- "Wrong shade of blue"
- "Button needs to be rounder"
- "Text is too small"
- "Alignment is off"

**Action**: Map directly to file:line changes. Max 3 rounds.

### Concept/Direction Issues (Requires Research)
- "This looks generic"
- "Not what I had in mind"
- "Same style as before"
- "I want something more unique/breathtaking"
- "This doesn't feel [adjective]"

**Action**: Stop tweaking CSS. Enter Research Phase. Max 2 rounds.

---

## Step 2: Research Phase (For Concept Issues)

**Trigger**: User wants "breathtaking", "unique", "premium", "not generic", or taste check fails.

### Process

1. **Study references** (use Grok/Gemini/Perplexity):
   - Find 5+ award-winning examples in the target domain
   - Analyze what makes them distinctive (not just "clean" or "modern")

2. **Synthesize 3+ FUNDAMENTALLY DIFFERENT visual metaphors**:
   - Each must have a unique visual language
   - Examples: skyline silhouette, starfield scatter, editorial mosaic, topographic map
   - NOT variations on the same grid/card/table layout

3. **Present concepts before implementing**:
   - Name each concept memorably (not "Option 1")
   - Include: color palette, typography pairing, key visual element, mood
   - Let user choose direction

4. **Implement chosen direction**

> Origin: Sentimark 2026-02-03 — Rounds 1-2 rejected ("same style") despite 92/100 Gemini scores. Round 3 with research phase produced 3 genuinely different concepts.

---

## Step 3: Map Feedback to Changes

For CSS/polish issues, create a structured change map:

```markdown
## Feedback → Changes Map

| Feedback | File | Line | Change |
|----------|------|------|--------|
| "Too much spacing" | Hero.tsx | 42 | py-24 → py-16 |
| "Wrong blue" | tailwind.config.js | 15 | #3B82F6 → #1E40AF |
| "Button too small" | Button.tsx | 8 | px-4 py-2 → px-6 py-3 |
```

**Rules:**
- Change ONLY what feedback specifies
- Don't "improve" unmentioned parts
- Don't refactor surrounding code
- One change per feedback item

---

## Step 4: Implement and Verify

After changes:
1. Run Verification Mode (screenshot → Gemini → taste check)
2. Compare before/after explicitly
3. Note which feedback items are addressed

---

## Iteration Limits (Hard Rules)

| Type | Max Rounds | Escalation |
|------|-----------|------------|
| CSS/polish | 3 rounds | Ask user: "Should we try a different visual direction?" |
| Concept/direction | 2 rounds | Ask user: "Which of these references is closest to what you want?" |
| Mixed | 4 rounds total | Escalate to /multi-model-debate for direction |

**Why limits matter**: Without them, you loop endlessly tweaking CSS values that don't address the actual problem (generic design concept).

---

## The Stagnation Test

After each iteration round, ask:

```
1. Did the Gemini score improve by 5+ points?
2. Did the feedback address a NEW issue (not the same one rephrased)?
3. Is the user's reaction more positive than last round?
```

If NO to all three: **you are in a styling loop**. Stop CSS changes. Enter Research Phase.

---

## Parallel Agent Strategy

For 5+ independent components with feedback:

1. Group feedback by component
2. Launch parallel code-worker agents (one per component group)
3. Each agent implements its feedback independently
4. Verify all together after all complete

```
Agent 1: Hero section feedback → implement → screenshot
Agent 2: Card grid feedback → implement → screenshot
Agent 3: Footer feedback → implement → screenshot
(all in parallel, zero merge conflicts)
```

---

## Anti-Patterns

- Tweaking the same CSS property 3+ times (sign of wrong approach)
- Changing effects/animations when feedback is about layout
- Adding MORE visual elements when feedback is "looks generic" (usually means simplify + differentiate)
- Ignoring the taste check and only optimizing Gemini score
- Not showing before/after comparison to user
