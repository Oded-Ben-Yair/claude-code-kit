# Sentimark V2 - Overnight Execution Plan
## Generated: January 22, 2026

### Branch: `feature/ux-audit-fixes-jan2026`

---

## SPRINT 1: TRUST & DATA FIXES (P0)

### Task 1.1: Fix "9 vs 8" source count
**Files to change:**
- `sentimark-v2/frontend/components/home/Hero.tsx` - "9 intelligence sources" → "8 intelligence sources"
- `sentimark-v2/frontend/components/home/IntelligenceSourcesGrid.tsx` - verify count
- `sentimark-v2/frontend/app/v2/docs/page.tsx` - "nine intelligence sources" → "eight"
- `sentimark-v2/frontend/app/v2/pricing/page.tsx` - source count references
- `sentimark-v2/frontend/app/v2/settings/page.tsx` - upgrade card references

**Search pattern:** `grep -ri "9 intelligence\|nine intelligence\|9 sources" sentimark-v2/frontend/`

### Task 1.2: Remove 12.5% weight display
**Files to change:**
- `sentimark-v2/frontend/components/signals/SignalCard.tsx` - remove weight prop display
- `sentimark-v2/frontend/components/pulse/SignalCard.tsx` - remove weight display

**Action:** Find and remove/hide the `12.5%` or weight percentage display from signal cards

### Task 1.3: Add fallback indicator for score=50
**Files to change:**
- `sentimark-v2/frontend/components/signals/SignalCard.tsx`

**Add:**
```tsx
// When isFallback is true or score === 50 and no real data
{isFallback && (
  <div className="text-xs text-text-tertiary opacity-60">
    <span className="inline-flex items-center gap-1">
      <InfoIcon className="w-3 h-3" />
      Insufficient data
    </span>
  </div>
)}
```

### Task 1.4: Fix "+N more signals" bug
**Files to change:**
- `sentimark-v2/frontend/components/signals/UnifiedSignalCard.tsx`

**Action:** Either make "+N more signals" clickable to expand, OR remove it entirely

### Task 1.5: Add absolute timestamps
**Files to change:**
- `sentimark-v2/frontend/components/signals/SignalCard.tsx`
- `sentimark-v2/frontend/components/pulse/SignalCard.tsx`

**Change:** "28m ago" → "Updated: Jan 22, 08:39 GMT+2" (absolute with timezone)

### Task 1.6: ESG/Insider data investigation
**Files to check:**
- `sentimark-v2/frontend/components/fmp/FmpEsgCard.tsx`
- `sentimark-v2/frontend/components/fmp/FmpInsiderTable.tsx`
- `sentimark-v2/frontend/lib/api/v2-client.ts` (getFmpEsg, getFmpInsider)

**Action:** If data truly unavailable, show "ESG data coming soon for [TICKER]" instead of error

---

## SPRINT 2: SIGNAL REDESIGN (4-CATEGORY GROUPING)

### Task 2.1: Create signal-groups.ts
**New file:** `sentimark-v2/frontend/lib/config/signal-groups.ts`

```typescript
export const SIGNAL_GROUPS = {
  herdFlow: {
    id: 'herd_flow',
    name: 'Herd Flow',
    description: 'What the crowd is doing',
    signals: ['crowd_wisdom', 'social_sentiment'],
    icon: 'Users',
    color: 'primary'
  },
  momentum: {
    id: 'momentum',
    name: 'Momentum',
    description: 'Price trends and velocity',
    signals: ['technical'],
    icon: 'TrendingUp',
    color: 'success'
  },
  macroRisk: {
    id: 'macro_risk',
    name: 'Macro Risk',
    description: 'Economic and geopolitical factors',
    signals: ['geopolitical', 'political', 'financial'],
    icon: 'Globe',
    color: 'warning'
  },
  aiEdge: {
    id: 'ai_edge',
    name: 'AI Edge',
    description: 'AI consensus and risk appetite',
    signals: ['ai_consensus', 'fear_greed'],
    icon: 'Cpu',
    color: 'secondary'
  }
};

export type SignalGroupId = keyof typeof SIGNAL_GROUPS;
```

### Task 2.2: Create signal-glossary.ts
**New file:** `sentimark-v2/frontend/lib/config/signal-glossary.ts`

```typescript
export const SIGNAL_GLOSSARY = {
  crowd_wisdom: {
    oldName: 'Crowd Wisdom',
    newName: 'Herd Flow',
    description: 'Aggregates prediction market sentiment and retail positioning',
    tooltip: 'What the crowd is betting on'
  },
  social_sentiment: {
    oldName: 'Social Buzz',
    newName: 'Social Pulse',
    description: 'Real-time sentiment from Twitter, Reddit, and news',
    tooltip: 'Social media mood'
  },
  technical: {
    oldName: 'Price Momentum',
    newName: 'Momentum',
    description: 'Technical indicators: RSI, MACD, moving averages',
    tooltip: 'Price trend strength'
  },
  geopolitical: {
    oldName: 'Geo Events',
    newName: 'Global Shocks',
    description: 'Geopolitical risk from news and events',
    tooltip: 'Wars, sanctions, disasters'
  },
  political: {
    oldName: 'Policy Climate',
    newName: 'Fed & Reg Watch',
    description: 'Central bank policy and regulatory risk',
    tooltip: 'Fed, SEC, regulations'
  },
  financial: {
    oldName: 'Macro Health',
    newName: 'Macro Health',
    description: 'Economic indicators and market breadth',
    tooltip: 'GDP, employment, inflation'
  },
  ai_consensus: {
    oldName: 'AI Outlook',
    newName: 'AI Edge',
    description: 'Consensus from 4 LLMs analyzing all data',
    tooltip: 'What AI models think'
  },
  fear_greed: {
    oldName: 'Risk Appetite',
    newName: 'Risk Gauge',
    description: 'Fear & Greed Index and VIX-based risk',
    tooltip: 'Market fear or greed'
  }
};
```

### Task 2.3: Update UnifiedSignalCard to use groups
**File:** `sentimark-v2/frontend/components/signals/UnifiedSignalCard.tsx`

**Changes:**
- Import SIGNAL_GROUPS
- Calculate group scores by averaging member signals
- Display 4 groups instead of 8 individual signals
- Keep expandable section for detailed view

### Task 2.4: Update SmartSignalGrid for groups
**File:** `sentimark-v2/frontend/components/signals/SmartSignalGrid.tsx`

**Changes:**
- Add grouped view mode
- Use signal-groups.ts config
- Add tooltips from signal-glossary.ts

---

## SPRINT 3: CONVICTION SCORE HERO METRIC

### Task 3.1: Create ConvictionScore.tsx
**New file:** `sentimark-v2/frontend/components/pulse/ConvictionScore.tsx`

Key features:
- Circular gauge with score (0-100)
- Color: green (>60 bullish), red (<40 bearish), yellow (40-60 neutral)
- Probability bar: % upside | % downside | % sideways
- Explanation text: "Momentum strong, watch Fed Thursday"
- Expandable: "See all signals" button
- "Ask AI" button linking to chat

### Task 3.2: Create probability.ts
**New file:** `sentimark-v2/frontend/lib/pulse/probability.ts`

```typescript
export function calculateDirectionalProbability(groupedScores: GroupedScores): {
  upside: number;
  downside: number;
  sideways: number;
} {
  // Based on conviction score and signal agreement
  const conviction = calculateConviction(groupedScores);
  const agreement = calculateAgreement(groupedScores);

  if (conviction > 60) {
    return { upside: 55 + agreement * 15, downside: 25 - agreement * 10, sideways: 20 - agreement * 5 };
  } else if (conviction < 40) {
    return { upside: 25 - agreement * 10, downside: 55 + agreement * 15, sideways: 20 - agreement * 5 };
  }
  return { upside: 35, downside: 35, sideways: 30 };
}
```

### Task 3.3: Create score-explainer.ts
**New file:** `sentimark-v2/frontend/lib/pulse/score-explainer.ts`

Generates human-readable explanations like:
- "Momentum strong (81), but watch Fed on Thursday. Macro risks elevated."
- "Herd Flow and AI Edge agree bullish. Consider scaling in."
- "Signals split: Momentum bullish, Macro bearish. Size small or wait."

### Task 3.4: Replace MIXED badge with scenario guidance
**File:** `sentimark-v2/frontend/lib/pulse/unified-consensus.ts`

Replace:
```typescript
if (direction === 'mixed') return 'MIXED';
```

With:
```typescript
if (direction === 'mixed') {
  return {
    label: 'Signals Split',
    guidance: generateMixedGuidance(scores),
    scenarios: [
      { probability: 55, direction: 'up', action: 'Scale in cautiously' },
      { probability: 35, direction: 'down', action: 'Set stops, hedge' },
      { probability: 10, direction: 'sideways', action: 'Wait for clarity' }
    ]
  };
}
```

---

## SPRINT 4: COPY & HOOK REFRESH

### Task 4.1: Update Hero.tsx
**File:** `sentimark-v2/frontend/components/home/Hero.tsx`

Changes:
- Headline: "Beat the market..." → "One score. Real reasons. Your edge."
- Subhead: "We analyze 9 intelligence..." → "Multi-source intelligence. One clear signal."

### Task 4.2: Update ProcessSteps.tsx
**File:** `sentimark-v2/frontend/components/home/ProcessSteps.tsx`

Changes:
- Step 1: "Catch Market Regime" → "Know the Market's Mood"
- Step 2: "Find Top Assets" → "Discover Opportunities"
- Step 3: "Act Confidently" → "Make Informed Decisions"

### Task 4.3: Add chat disclaimer
**Files:**
- `sentimark-v2/frontend/components/chat/ChatWidget.tsx`
- `sentimark-v2/frontend/components/chat/MiniChatWidget.tsx`

Add below input:
```tsx
<p className="text-xs text-text-tertiary mt-2">
  AI-generated for informational purposes. Not financial advice.
</p>
```

---

## SPRINT 5: ACCESSIBILITY & POLISH

### Task 5.1: Fix contrast issues
**File:** `sentimark-v2/frontend/app/globals.css`

Audit and fix:
- Badge text on dark backgrounds
- Sparkline colors for up/down
- Small text legibility

### Task 5.2: Add keyboard navigation
**Files:** All interactive components

Add:
- `tabIndex={0}` to clickable cards
- `onKeyDown` handlers for Enter/Space
- Focus ring styles

### Task 5.3: Watchlist star feedback
**File:** `sentimark-v2/frontend/components/assets/WatchlistButton.tsx`

Add:
- Fill animation on click
- Toast notification: "Added to watchlist"
- If not logged in: "Saved locally - login to sync"

### Task 5.4: Settings login gate
**File:** `sentimark-v2/frontend/app/v2/settings/page.tsx`

Add:
- Disable toggles when not logged in
- Tooltip: "Login to save preferences"
- Visual dimming of disabled controls

---

## COMMIT STRATEGY

After each sprint:
```bash
git add -A
git commit -m "feat(ux): Sprint N - [description]

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

## VERIFICATION

After all sprints:
1. `npm run build` - ensure no build errors
2. `npm run lint` - check for issues
3. Screenshots of key pages for morning review

## OUTPUT FILE

All logs written to: `.claude/overnight-execution-log.md`

