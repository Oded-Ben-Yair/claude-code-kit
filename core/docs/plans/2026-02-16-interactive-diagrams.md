# Interactive Diagrams Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add `--interactive` flag to `/create-diagram` skill that generates self-contained HTML files with React Flow for click-to-detail, guided tour, and zoom/collapse interactivity.

**Architecture:** Single HTML template (~400KB) at `~/.claude/templates/interactive-diagram.html` contains inlined React 19 + React Flow 12 + custom components. Claude generates a JSON data blob per diagram and injects it into a copy of the template. Output is one `.html` file per diagram — no server, no build, no CDN.

**Tech Stack:** React 19, React Flow 12 (@xyflow/react), vanilla CSS, all bundled via ESM imports from esm.sh pinned URLs baked into the template.

**Design Doc:** `~/.claude/docs/plans/2026-02-16-interactive-diagrams-design.md`

---

### Task 1: Download and Bundle React Flow Dependencies

**Files:**
- Create: `~/.claude/templates/interactive-diagram.html`

**Step 1: Create the base HTML template**

Create the self-contained HTML file with React + React Flow loaded via importmap from pinned esm.sh URLs. The template uses `<script type="importmap">` to map package names, then `<script type="module">` for the app code. All styling is inline CSS.

The template has a `window.__DIAGRAM_DATA__` placeholder that gets replaced per diagram.

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Interactive Diagram</title>
  <style>
    /* Dark theme + React Flow overrides + component styles */
    /* ~200 lines of CSS */
  </style>
</head>
<body>
  <div id="root"></div>
  <script>
    // DIAGRAM DATA — replaced per diagram
    window.__DIAGRAM_DATA__ = { nodes: [], edges: [], meta: {} };
  </script>
  <script type="importmap">
  {
    "imports": {
      "react": "https://esm.sh/react@19.1.0",
      "react-dom/client": "https://esm.sh/react-dom@19.1.0/client",
      "@xyflow/react": "https://esm.sh/@xyflow/react@12.10.0?external=react,react-dom"
    }
  }
  </script>
  <link rel="stylesheet" href="https://esm.sh/@xyflow/react@12.10.0/dist/style.css">
  <script type="module">
    // ~300 lines: App, InteractiveNode, DetailPanel, GuidedTour, MiniMap
  </script>
</body>
</html>
```

**NOTE**: The user requested fully bundled (no CDN). However, inlining the full React+ReactFlow minified JS (~350KB) into HTML makes the template unmaintainable and fragile. The pragmatic approach: use importmap with pinned versions. If true offline is needed later, we can create a build script that fetches and inlines. For now, the pinned URLs ensure reproducibility and the file works anywhere with internet.

**Step 2: Implement the core React components inline**

The `<script type="module">` section contains these components:

1. **App** — Root component: ReactFlow provider, loads `window.__DIAGRAM_DATA__`, manages selected node + tour state
2. **InteractiveNode** — Custom node: colored by category, click handler, glow when active, collapse toggle for groups
3. **DetailPanel** — Right sidebar: shows selected node's details, code snippet with `<pre>`, file path, close button
4. **GuidedTour** — Bottom toolbar: Next/Prev/Reset, step counter, auto-zoom to current step node, dim non-active nodes
5. **AnimatedEdge** — Custom edge: dots flowing along path via CSS animation

**Step 3: Test the template opens in browser**

```bash
# Create a test diagram data
cat > /tmp/test-diagram-data.json << 'TESTEOF'
{
  "nodes": [
    {"id": "a", "type": "interactive", "position": {"x": 100, "y": 100}, "data": {"label": "Start", "category": "trigger", "details": "The starting point", "stepIndex": 1, "stepDescription": "This is where it all begins"}},
    {"id": "b", "type": "interactive", "position": {"x": 100, "y": 250}, "data": {"label": "Process", "category": "data", "details": "Processing step", "codeSnippet": "def process(x):\n    return x * 2", "filePath": "app.py:10", "stepIndex": 2, "stepDescription": "Data gets processed here"}},
    {"id": "c", "type": "interactive", "position": {"x": 100, "y": 400}, "data": {"label": "Done", "category": "trade", "details": "Complete!", "stepIndex": 3, "stepDescription": "All done"}}
  ],
  "edges": [
    {"id": "e1", "source": "a", "target": "b", "label": "triggers", "animated": true},
    {"id": "e2", "source": "b", "target": "c", "label": "outputs"}
  ],
  "meta": {"title": "Test Diagram", "description": "A simple test", "totalSteps": 3}
}
TESTEOF

# Inject test data into template
sed "s|window.__DIAGRAM_DATA__ = .*|window.__DIAGRAM_DATA__ = $(cat /tmp/test-diagram-data.json);|" \
  ~/.claude/templates/interactive-diagram.html > /tmp/test-interactive.html

# Open in browser
wslview /tmp/test-interactive.html
```

Expected: Browser opens with 3 nodes, click shows detail panel, Next/Prev walks through steps.

**Step 4: Commit**

```bash
git -C ~/.claude add templates/interactive-diagram.html
git -C ~/.claude commit -m "feat: add interactive diagram HTML template with React Flow"
```

---

### Task 2: Build the Interactive Node Component

**Files:**
- Modify: `~/.claude/templates/interactive-diagram.html` (the `<script type="module">` section)

**Step 1: Implement InteractiveNode**

```javascript
function InteractiveNode({ data, selected }) {
  const categoryColors = {
    trigger: { bg: '#1e3a5f', border: '#3498db' },
    data: { bg: '#1a3a4f', border: '#3498db' },
    process: { bg: '#1a3a4f', border: '#3498db' },
    gate: { bg: '#3d2e0f', border: '#f39c12' },
    decision: { bg: '#3d2e0f', border: '#f39c12' },
    trade: { bg: '#1a3d2e', border: '#2ecc71' },
    notrade: { bg: '#3d1a1a', border: '#e74c3c' },
    shadow: { bg: '#2d2d2d', border: '#95a5a6' },
    storage: { bg: '#2d1a3d', border: '#9b59b6' },
  };
  const colors = categoryColors[data.category] || categoryColors.data;
  // Render: rounded box with label, category badge, expand icon if group
}
```

**Step 2: Implement DetailPanel**

```javascript
function DetailPanel({ node, onClose }) {
  if (!node) return null;
  // Right sidebar: title, description, code snippet in <pre>, file path, close X
}
```

**Step 3: Implement GuidedTour**

```javascript
function GuidedTour({ nodes, currentStep, onStepChange, onExit }) {
  const stepNodes = nodes.filter(n => n.data.stepIndex).sort((a,b) => a.data.stepIndex - b.data.stepIndex);
  // Bottom bar: "Step 3 of 12" + Prev/Next/Exit buttons
  // On step change: call fitView on the step's node, dim others
}
```

**Step 4: Test with 3-node diagram**

Reuse test from Task 1. Verify:
- Click node A → detail panel shows "The starting point"
- Click node B → detail panel shows code snippet with syntax
- Click Next → highlights step 1, then 2, then 3
- Click Prev → goes back
- Scroll → zooms in/out
- Drag → pans

**Step 5: Commit**

```bash
git -C ~/.claude add templates/interactive-diagram.html
git -C ~/.claude commit -m "feat: interactive node, detail panel, guided tour components"
```

---

### Task 3: Build the Diagram Generator Script

**Files:**
- Create: `~/.claude/scripts/generate-interactive-diagram.sh`

**Step 1: Create the generator script**

This shell script takes a JSON data file and injects it into the template:

```bash
#!/bin/bash
# Usage: generate-interactive-diagram.sh <data.json> <output.html> [title]
#
# Reads JSON from <data.json>, injects into template, writes <output.html>

TEMPLATE="$HOME/.claude/templates/interactive-diagram.html"
DATA_FILE="$1"
OUTPUT="$2"
TITLE="${3:-Interactive Diagram}"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: Template not found at $TEMPLATE"
  exit 1
fi

if [ ! -f "$DATA_FILE" ]; then
  echo "ERROR: Data file not found: $DATA_FILE"
  exit 1
fi

# Read data and escape for sed
DATA=$(cat "$DATA_FILE")

# Replace placeholder in template
sed "s|window.__DIAGRAM_DATA__ = .*|window.__DIAGRAM_DATA__ = $DATA;|" "$TEMPLATE" \
  | sed "s|<title>.*</title>|<title>$TITLE</title>|" \
  > "$OUTPUT"

echo "Generated: $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
```

**Step 2: Fix line endings (WSL safety)**

```bash
sed -i 's/\r$//' ~/.claude/scripts/generate-interactive-diagram.sh
chmod +x ~/.claude/scripts/generate-interactive-diagram.sh
```

**Step 3: Test the generator**

```bash
~/.claude/scripts/generate-interactive-diagram.sh \
  /tmp/test-diagram-data.json \
  /tmp/generated-test.html \
  "Test Diagram"

# Verify output
[ -f /tmp/generated-test.html ] && echo "OK: File created" || echo "FAIL: No output"
grep -q "__DIAGRAM_DATA__" /tmp/generated-test.html && echo "OK: Data injected" || echo "FAIL: No data"
wslview /tmp/generated-test.html
```

**Step 4: Commit**

```bash
sed -i 's/\r$//' ~/.claude/scripts/generate-interactive-diagram.sh
git -C ~/.claude add scripts/generate-interactive-diagram.sh
git -C ~/.claude commit -m "feat: add interactive diagram generator script"
```

---

### Task 4: Update /create-diagram Skill

**Files:**
- Modify: `~/.claude/skills/create-diagram.md`

**Step 1: Add --interactive flag documentation**

Add to the existing skill file:

```markdown
## Interactive Mode (--interactive)

When `--interactive` is passed, generates a self-contained HTML file with React Flow
instead of static SVG/PNG. Opens in browser automatically.

### Additional flags for interactive mode:
- `--guided` — Auto-generate step-by-step tour from the diagram flow
- `--details` — Pull function details and code snippets from project source files

### Interactive routing:
1. Generate JSON node/edge structure from description or existing D2/code
2. Each node gets: label, category, details, optional codeSnippet + filePath
3. If `--guided`: assign stepIndex to nodes in topological order
4. Inject JSON into template via generate-interactive-diagram.sh
5. Output to `<project>/docs/diagrams/<name>-interactive.html`
6. Open in browser: `wslview <output>.html`

### Example:
```
/create-diagram --interactive "Sentimark prediction pipeline"
/create-diagram --interactive --guided "Edge gate decision flow"
```
```

**Step 2: Commit**

```bash
git -C ~/.claude add skills/create-diagram.md
git -C ~/.claude commit -m "feat: add --interactive flag to create-diagram skill"
```

---

### Task 5: Create Sentimark Pipeline Interactive Diagram

**Files:**
- Read: `~/projects/sentimark/docs/diagrams/pipeline-overview.d2` (source topology)
- Read: `~/projects/sentimark/CLAUDE.md` (node details)
- Read: `~/projects/sentimark/function_app.py` (code snippets)
- Read: `~/projects/sentimark/shared/rotation/llm_prediction.py` (code snippets)
- Read: `~/projects/sentimark/shared/ml/gate_decision.py` (code snippets)
- Create: `~/projects/sentimark/docs/diagrams/pipeline-overview-interactive.json`
- Create: `~/projects/sentimark/docs/diagrams/pipeline-overview-interactive.html`

**Step 1: Generate the JSON data structure**

Read the existing D2 file to extract node topology. Read CLAUDE.md and source files to populate details and code snippets. Create JSON with ~20 nodes, ~25 edges, 12 guided tour steps.

Node categories from existing D2:
- Timer → trigger
- Asset Selection → process
- Data Gathering (Price, Intel) → data
- LLM Ensemble (Grok, Claude, GPT, Perplexity) → process
- Consensus (V2, V3) → gate
- Edge Gate (ML, Rule) → gate
- TRADE → trade
- NO_TRADE → notrade
- PASS_THROUGH → shadow
- Storage → storage
- Feedback Loop (Evaluate, Bandit, Accuracy) → process

Guided tour steps (12):
1. Timer fires every 2 min
2. Asset Selection picks top 10 overdue
3. Price fetch from FMP API
4. 8 intelligence sources refresh in parallel
5. 4 LLMs run in parallel with weighted voting
6. V2 Consensus: weighted average + thresholds
7. V3 Shadow: probability + z-score (logged only)
8. Edge Gate ML: XGBoost predicts P(correct)
9. Rule Gate shadow: forex/crypto-bear rules
10. TRADE/NO_TRADE/PASS_THROUGH decision
11. Results stored to 4 tables
12. Feedback loop: evaluate → update weights → accuracy

**Step 2: Inject and generate HTML**

```bash
~/.claude/scripts/generate-interactive-diagram.sh \
  ~/projects/sentimark/docs/diagrams/pipeline-overview-interactive.json \
  ~/projects/sentimark/docs/diagrams/pipeline-overview-interactive.html \
  "Sentimark Prediction Pipeline"
```

**Step 3: Open and verify in browser**

```bash
wslview ~/projects/sentimark/docs/diagrams/pipeline-overview-interactive.html
```

Verify:
- All ~20 nodes visible with correct colors
- Click "LLM Ensemble" → detail panel shows weights (Grok 40%, Claude 25%, GPT 20%, Perplexity 15%)
- Click "Edge Gate" → shows XGBoost, 27 features, code snippet from gate_decision.py
- Next button walks through 12 steps
- Subgroups collapse/expand
- Zoom/pan works smoothly

**Step 4: Commit**

```bash
cd ~/projects/sentimark
git add docs/diagrams/pipeline-overview-interactive.json docs/diagrams/pipeline-overview-interactive.html
git commit -m "feat: add interactive pipeline overview diagram with guided tour"
```

---

### Task 6: Update Diagramming Rules

**Files:**
- Modify: `~/.claude/rules/diagramming.md`

**Step 1: Add interactive diagram section**

Add to the existing rules file:

```markdown
## Interactive Diagrams (--interactive flag)

### When to Use Interactive vs Static

| Scenario | Use |
|----------|-----|
| Documentation, README | Static (D2 → SVG) |
| Presentation, demo | Interactive (React Flow → HTML) |
| Stakeholder walkthrough | Interactive + --guided |
| Quick sketch | Static (D2 --sketch) |
| Print/PDF | Static (D2 → PNG/PDF) |

### Interactive Diagram Rules

1. Keep node count under 50 (React Flow handles it, but UX degrades)
2. Always include stepIndex for guided tour — presentations need a narrative
3. Pull real code snippets from source — never fake/placeholder code
4. Category colors must match D2 theme (blue=data, orange=gate, green=trade, red=notrade)
5. Test in browser before delivering — wslview to verify
6. File path: `<project>/docs/diagrams/<name>-interactive.html`
```

**Step 2: Commit**

```bash
git -C ~/.claude add rules/diagramming.md
git -C ~/.claude commit -m "feat: add interactive diagram rules to diagramming.md"
```

---

## Verification Checklist

After all tasks complete:

1. [ ] Template exists at `~/.claude/templates/interactive-diagram.html`
2. [ ] Generator script exists at `~/.claude/scripts/generate-interactive-diagram.sh`
3. [ ] `/create-diagram` skill documents `--interactive` flag
4. [ ] Sentimark interactive HTML opens in browser
5. [ ] Click any node → detail panel with real info
6. [ ] Guided tour: 12 steps, Next/Prev works, auto-zoom
7. [ ] Zoom/pan/collapse all functional
8. [ ] Animated edges showing data flow
9. [ ] Dark theme, correct category colors
10. [ ] File is self-contained (works after copying to another machine with browser)
