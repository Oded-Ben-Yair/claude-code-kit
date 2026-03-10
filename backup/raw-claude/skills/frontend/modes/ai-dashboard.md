# AI Dashboard Mode

**For building AI-integrated analytics dashboards with trust-building patterns.**

This mode applies when users need:
- AI chatbots integrated into data dashboards
- Provenance visualization (tether lines connecting AI answers to data)
- Bidirectional highlighting (hover evidence → highlight chart)
- Contextual AI interactions (widget-specific Q&A)

---

## Core Principle

> "Every AI claim must visually connect to its evidence source."

This builds trust and creates natural interaction patterns.

---

## Pattern 1: Provenance Tethers

Visual lines connecting AI responses to their data sources.

### Implementation (React + SVG)

```tsx
// ProvenanceTether.tsx
interface TetherProps {
  start: { x: number; y: number }
  end: { x: number; y: number }
  isHovered?: boolean
  animated?: boolean
}

export function ProvenanceTether({ start, end, isHovered, animated }: TetherProps) {
  // Quadratic Bezier curve
  const midX = (start.x + end.x) / 2
  const curveOffset = Math.abs(end.y - start.y) * 0.3
  const controlY = Math.min(start.y, end.y) - curveOffset

  const pathD = `M ${start.x} ${start.y} Q ${midX} ${controlY} ${end.x} ${end.y}`

  return (
    <svg className="fixed inset-0 pointer-events-none z-40">
      <defs>
        <linearGradient id="tether-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor={isHovered ? '#818cf8' : '#94a3b8'} />
          <stop offset="100%" stopColor={isHovered ? '#6366f1' : '#64748b'} />
        </linearGradient>
      </defs>

      {/* Main path */}
      <path
        d={pathD}
        fill="none"
        stroke="url(#tether-gradient)"
        strokeWidth={isHovered ? 2.5 : 1.5}
        strokeLinecap="round"
        className="transition-all duration-300"
        style={animated ? {
          strokeDasharray: 1000,
          strokeDashoffset: 1000,
          animation: 'draw 0.8s ease-out forwards'
        } : undefined}
      />

      {/* Endpoints */}
      <circle cx={start.x} cy={start.y} r={isHovered ? 5 : 4}
        fill={isHovered ? '#6366f1' : '#94a3b8'} />
      <circle cx={end.x} cy={end.y} r={isHovered ? 5 : 4}
        fill={isHovered ? '#6366f1' : '#94a3b8'} />

      {/* Pulse animation on hover */}
      {isHovered && (
        <circle cx={end.x} cy={end.y} r={8} fill="#6366f1" opacity={0.3}>
          <animate attributeName="r" from="5" to="15" dur="1s" repeatCount="indefinite" />
          <animate attributeName="opacity" from="0.5" to="0" dur="1s" repeatCount="indefinite" />
        </circle>
      )}
    </svg>
  )
}
```

### CSS Animation

```css
@keyframes draw {
  to {
    stroke-dashoffset: 0;
  }
}
```

### Key Rules

| Rule | Why |
|------|-----|
| Use Bezier curves, not straight lines | More organic, easier to follow |
| Animate on appearance | Draws attention, shows connection |
| Hover state changes color | Confirms which tether is active |
| Pulse at endpoint | Shows exact data point connected |
| `pointer-events-none` on SVG | Allows clicking through to elements |

---

## Pattern 2: InsightCard

Floating card showing AI insights with evidence items.

### Structure

```tsx
interface InsightCardProps {
  headline: string           // Main claim (bold)
  body: string              // Explanation
  evidence: EvidenceItem[]  // Supporting data points
  timeframe: string         // "Last 7 days"
  confidence: 'high' | 'medium' | 'low'
  onEvidenceHover: (index: number | null) => void
  onClose: () => void
}

interface EvidenceItem {
  label: string    // "Sentiment Share"
  detail: string   // "35% of total conversation"
}
```

### Implementation Pattern

```tsx
export function InsightCard({
  headline, body, evidence, timeframe, confidence, onEvidenceHover, onClose
}: InsightCardProps) {
  return (
    <div className="bg-white rounded-xl shadow-xl border border-gray-200 p-4 w-80">
      {/* Header */}
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          <Sparkles className="w-5 h-5 text-violet-500" />
          <h3 className="font-semibold text-gray-900">{headline}</h3>
        </div>
        <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
          <X className="w-4 h-4" />
        </button>
      </div>

      {/* Body */}
      <p className="text-sm text-gray-600 mb-4">{body}</p>

      {/* Evidence Items - these trigger tether highlights */}
      <div className="space-y-2">
        <p className="text-xs font-medium text-gray-500">Evidence ({evidence.length})</p>
        {evidence.map((ev, i) => (
          <div
            key={i}
            className="flex items-center justify-between p-2 bg-gray-50 rounded-lg
                       cursor-pointer hover:bg-violet-50 transition-colors"
            onMouseEnter={() => onEvidenceHover(i)}
            onMouseLeave={() => onEvidenceHover(null)}
          >
            <div>
              <span className="font-medium text-gray-900">{ev.label}</span>
              <span className="text-gray-500 ml-2">{ev.detail}</span>
            </div>
            <ChevronRight className="w-4 h-4 text-gray-400" />
          </div>
        ))}
      </div>

      {/* Metadata */}
      <div className="flex items-center gap-4 mt-4 text-xs text-gray-500">
        <span className="flex items-center gap-1">
          <Clock className="w-3 h-3" /> {timeframe}
        </span>
        <span className="flex items-center gap-1">
          <Shield className="w-3 h-3" /> {confidence} confidence
        </span>
      </div>
    </div>
  )
}
```

### Positioning

```tsx
// Position near clicked element, but keep on screen
const handleChartClick = (event: ChartClickEvent) => {
  setInsightPosition({
    x: Math.min(event.position.x + 20, window.innerWidth - 350),
    y: Math.max(event.position.y - 100, 100)
  })
}
```

---

## Pattern 3: Bidirectional Highlighting

Hover on evidence → highlight chart element (and vice versa).

### State Management

```tsx
// Parent component state
const [hoveredSource, setHoveredSource] = useState<number | null>(null)

// Derive highlighted element from hovered source
const highlightedElement = useMemo(() => {
  if (hoveredSource !== null && selectedAnomaly) {
    return selectedAnomaly.evidence[hoveredSource]?.label ?? null
  }
  return null
}, [hoveredSource, selectedAnomaly])
```

### Chart Integration

Add these props to ALL chart widgets:

```tsx
interface ChartWidgetProps {
  // ... existing props
  highlightedElement?: string | null  // Name of element to highlight
  dimOthers?: boolean                 // Dim non-highlighted to 30%
}

// In chart rendering
const getOpacity = (name: string) => {
  if (!highlightedElement) return 1
  return name === highlightedElement ? 1 : 0.3
}
```

### Recharts Example

```tsx
<Bar dataKey="value">
  {data.map((entry, index) => (
    <Cell
      key={index}
      fill={entry.color}
      opacity={highlightedElement
        ? entry.name === highlightedElement ? 1 : 0.3
        : 1}
      stroke={entry.name === highlightedElement ? '#7C3AED' : 'none'}
      strokeWidth={entry.name === highlightedElement ? 2 : 0}
    />
  ))}
</Bar>
```

---

## Pattern 4: Widget-Specific Contextual Chat

Chatbot that understands which widget user clicked.

### Data Structure

```tsx
// Pre-compute questions and answers per widget
interface WidgetChatData {
  widgetId: string
  title: string
  subtitle: string
  questions: {
    id: string
    text: string
    answer: {
      headline: string
      body: string
      evidence: EvidenceItem[]
      timeframe: string
      confidence: 'high' | 'medium' | 'low'
    }
  }[]
}

export const widgetChatData: Record<string, WidgetChatData> = {
  'teamSentiment': {
    title: 'Team Sentiment Analysis',
    subtitle: 'Ask about team sentiment',
    questions: [
      {
        id: 'ts-1',
        text: 'Why are Chiefs leading sentiment at 35%?',
        answer: {
          headline: 'Chiefs lead with 35% sentiment share',
          body: 'Kansas City Chiefs dominate social sentiment...',
          evidence: [
            { label: 'Sentiment Share', detail: '35% of total' },
            { label: '49ers Gap', detail: '10 points behind' },
          ],
          timeframe: 'Last 7 days',
          confidence: 'high'
        }
      },
      // ... more questions
    ]
  },
  // ... more widgets
}
```

### Context Pattern

```tsx
// ChatbotContext.tsx
interface ChatbotState {
  isOpen: boolean
  activeWidgetId: string | null
  currentQuestion: string | null
  currentAnswer: WidgetAnswer | null
}

const ChatbotContext = createContext<{
  state: ChatbotState
  openForWidget: (widgetId: string) => void
  selectQuestion: (questionId: string) => void
  close: () => void
}>()
```

### Make Widgets Clickable

```tsx
// Every widget container
<div
  className={cn(
    "bg-white rounded-lg border p-4 transition-all",
    "cursor-pointer hover:border-violet-300 hover:shadow-md",
    chatActive && "border-violet-500 shadow-md"
  )}
  onClick={() => onChatClick?.(widgetId)}
>
  {/* Chart content */}
</div>
```

---

## Integration Checklist

When building an AI-integrated dashboard:

- [ ] Every AI response has visible evidence items
- [ ] Evidence items trigger tether lines on hover
- [ ] Tether lines connect to actual chart data points
- [ ] Charts support `highlightedElement` prop
- [ ] Non-highlighted elements dim to 30% opacity
- [ ] Clicking widget opens contextual chat (not generic)
- [ ] Chat shows widget-specific suggested questions
- [ ] ESC key closes any open cards/panels
- [ ] Click outside closes cards

---

## Tools

| Tool | Purpose |
|------|---------|
| `mcp__playwright__browser_take_screenshot` | Capture current state |
| `mcp__gemini__gemini-analyze-image` | Verify visual implementation |
| Framer Motion | Sidebar slide animations |
| Recharts | Charts with Cell-level opacity control |

---

## Related References

- `references/ai-integration.md` - Trust principles and anti-patterns
- `references/typography.md` - Font pairing for AI interfaces
- `modes/effects.md` - Animation patterns for tethers
