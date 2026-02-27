---
name: create-diagram
description: Generate professional diagrams using D2+ELK (complex) or Beautiful Mermaid (simple). Interactive mode produces React Flow HTML with guided tour + auto-generated macro overview. Invoke with /create-diagram.
trigger: diagram, flowchart, architecture diagram, create diagram, visualize
metadata:
  version: "1.0.0"
  author: odedbe
---

# /create-diagram Skill

Generate publication-quality diagrams from natural language descriptions or existing Mermaid code.

## Arguments

- `--style clean` (default) or `--style sketch` (hand-drawn)
- `--theme sentimark|dark|light|tokyo-night|dracula|nord` (default: 200 = dark mauve)
- `--format svg` (default) or `--format png`
- `--layout elk` (default) or `--layout dagre`
- `--output <path>` (default: `/tmp/diagram.*`)
- `--interactive` — Generate React Flow HTML instead of static SVG/PNG (RECOMMENDED for 10+ nodes)
- `--guided` — Include step-by-step guided tour (requires --interactive)

## Routing Logic

1. **Check for `--interactive` flag first** — if present, skip D2/Mermaid routing entirely and go to Interactive Mode below.

2. **Count nodes** in the description/diagram:
   - **< 15 nodes** AND existing Mermaid code provided → **Beautiful Mermaid** (fastest, drop-in upgrade)
   - **15+ nodes** OR complex subgraphs/containers → **D2 + ELK** (professional layout)
   - **Existing Mermaid code** with no quality complaints → **Beautiful Mermaid** (preserve syntax)
   - **New diagram request** → **D2 + ELK** (best quality)

3. **If D2 + ELK selected**:
   ```bash
   ~/.local/bin/d2 --layout=elk --theme=<theme_id> <input>.d2 <output>.svg
   # Sketch mode:
   ~/.local/bin/d2 --layout=elk --sketch --theme=<theme_id> <input>.d2 <output>.svg
   ```

4. **If Beautiful Mermaid selected**:
   ```bash
   node ~/.claude/scripts/render-mermaid.js <input>.mmd --theme <theme> --output <output>.svg
   ```

## D2 Theme IDs

| ID | Name | Best For |
|----|------|----------|
| 0 | Default | General |
| 100 | Origami | Light, clean |
| 200 | Dark Mauve | Dark backgrounds |
| 300 | Terminal | CLI/hacker aesthetic |

## D2 Classes Pattern (MANDATORY for AI generation)

```d2
direction: down
classes: {
  process: { shape: rectangle; style: { fill: "#e8f4f8"; border-radius: 5 } }
  decision: { shape: diamond; style: { fill: "#fff2f2"; stroke: "#e94560" } }
  terminal: { shape: oval; style: { fill: "#16213e"; font-color: "#ffffff" } }
  data: { shape: cylinder; style: { fill: "#f0f7ff"; stroke: "#3498db" } }
}
Start.class: terminal
Start -> "Parse Input".class: process
```

## Static Workflow

1. User describes diagram OR provides Mermaid code
2. Route to D2 or Beautiful Mermaid based on complexity
3. Generate diagram source code → write to file → render via CLI
4. Report output path to user
5. If WSLg available, open in browser: `wslview <output>.svg`

---

## Interactive Mode (--interactive) — PRIMARY MODE

When `--interactive` is passed, generates a self-contained HTML file with React Flow. This is the **recommended mode for any diagram with 10+ nodes** because it provides:
- Clickable nodes with rich detail panels (42vw wide, scrollable)
- Guided step-by-step tour with keyboard navigation
- Auto-zoom, minimap, zoom controls
- **Auto-generated macro (overview) diagram** when nodes have `group` fields

### Data-Gathering Process (MANDATORY)

Before generating the JSON, you MUST gather real data from the project:

1. **Read the codebase** — grep for entry points, key functions, data flow
2. **Read existing docs** — CLAUDE.md, architecture docs, status.json, decision logs
3. **Read config files** — understand what services, APIs, models are actually used
4. **Trace the data flow** — follow the code path from trigger to output
5. **Extract real code snippets** — actual function signatures, config values, not placeholder code
6. **Get real numbers** — accuracy stats, weights, timing, costs from the project

### Description Quality Bar (MANDATORY)

Every node's `details` field must tell a **story**, not just state a fact:

**BAD** (too dry):
```
"details": "Fetches market data from FMP and Yahoo Finance APIs."
```

**GOOD** (tells the story):
```
"details": "The foundation of every prediction starts with hard market data. Two providers ensure we always have prices and technical indicators:\n\n| Provider | Data | Rate Limit |\n|----------|------|------------|\n| **FMP** | 6 technical indicators (RSI, ADX, etc.) | 300/min |\n| **Yahoo Finance** | Real-time prices, volume, OHLCV | Unlimited |\n\nWhy two providers? Redundancy. If FMP goes down, Yahoo still gives us prices. If Yahoo lags, FMP has the technical signals."
```

Use markdown in details: **bold** for emphasis, `code` for technical terms, tables for structured data, bullet lists for enumerations. The detail panel renders all of this.

### Node Group Field (MANDATORY for 15+ nodes)

Every node MUST have a `group` field that assigns it to a logical family. This enables **automatic macro diagram generation**.

```json
{
  "id": "market-data",
  "data": {
    "label": "Market Data",
    "category": "data",
    "group": "data-sources",
    "details": "..."
  }
}
```

Grouping rules:
- Nodes that work together at the same pipeline stage share a group
- Group names are kebab-case: `data-sources`, `llm-ensemble`, `context-builder`
- Aim for 8-15 groups for a 20-40 node diagram
- Single-node groups are fine for unique pipeline stages (e.g., `trigger`, `storage`)

### Compact Multi-Column Layout (MANDATORY)

NEVER create a single vertical column. Use the full screen width:

- **Parallel nodes** (same group, same pipeline stage): place side-by-side in rows
- **Row spacing**: 130-150px between rows (not 200+)
- **Horizontal spread**: 200-250px between nodes in same row
- **Center single nodes**: x = center of the widest row
- **Zigzag paired items**: data-sources/intelligence side-by-side, gate/outcomes side-by-side

Example layout pattern for 29 nodes:
```
Row 1 (y=50):   trigger (center)
Row 2 (y=180):  selection (center)
Row 3 (y=320):  data-source-1  data-source-2  data-source-3  data-source-4
Row 4 (y=450):  data-source-5  data-source-6  data-source-7
Row 5 (y=590):  intel-1  intel-2  intel-3  intel-4  intel-5
Row 6 (y=740):  context-builder (center)
Row 7 (y=880):  llm-1  llm-2  llm-3  llm-4
Row 8 (y=1020): consensus-1  consensus-2
Row 9 (y=1150): gate-1  gate-2
Row 10(y=1280): outcome-1  outcome-2  outcome-3
Row 11(y=1410): storage (center)
Row 12(y=1540): feedback-1  feedback-2
```

For **macro diagrams** (auto-generated), same principle:
```
Row 1 (y=50):   trigger (center)
Row 2 (y=200):  selection (center)
Row 3 (y=370):  data-sources (left)    intelligence (right)   <- side by side
Row 4 (y=550):  context-builder (center)
Row 5 (y=710):  llm-ensemble (center)
Row 6 (y=870):  consensus (center)
Row 7 (y=1040): gate (left)            outcomes (right)       <- side by side
Row 8 (y=1210): storage (center)
Row 9 (y=1370): feedback (center)
```

### JSON Data Format

```json
{
  "nodes": [
    {
      "id": "unique-id",
      "type": "interactive",
      "position": {"x": 400, "y": 50},
      "data": {
        "label": "Node Name",
        "category": "trigger|data|process|gate|decision|trade|notrade|shadow|storage",
        "group": "family-name",
        "details": "Rich markdown description telling the story",
        "codeSnippet": "actual_code_from_project()",
        "filePath": "shared/module/file.py",
        "stepIndex": 1,
        "stepDescription": "Tour narration for this step"
      }
    }
  ],
  "edges": [
    {"id": "e1", "source": "a", "target": "b", "label": "optional label", "animated": true}
  ],
  "meta": {"title": "Diagram Title", "description": "...", "totalSteps": 15}
}
```

### Category Colors (built into template)

| Category | Color | Use For |
|----------|-------|---------|
| `trigger` | Dark blue | Timers, webhooks, entry points |
| `data` | Teal | Data sources, APIs, feeds |
| `process` | Teal | Processing, computation, models |
| `gate` | Amber | Decision points, quality gates |
| `trade` | Green | Positive outcomes |
| `notrade` | Red | Negative/blocked outcomes |
| `shadow` | Gray | Shadow mode, logging-only |
| `storage` | Purple | Databases, persistence |

### Generation & Auto-Macro

```bash
# Single command produces BOTH detailed + macro HTML:
~/.claude/scripts/generate-interactive-diagram.sh <data.json> <output.html> [title]
```

This automatically:
1. Generates the detailed interactive HTML from the JSON
2. Detects `group` fields in nodes
3. If 4+ groups found: auto-generates `<name>-macro.json` and `<name>-macro.html`
4. Macro collapses each group into a single family node showing child count and children list
5. Cross-group edges are derived and deduplicated

**Output**: Two HTML files:
- `<name>.html` — Detailed diagram with all nodes (deep dive)
- `<name>-macro.html` — Macro overview with family nodes (quick iteration)

### Interactive Workflow

1. **Gather data** from the project (read code, docs, configs — see Data-Gathering Process above)
2. **Design node/group structure** — list all nodes, assign groups, plan layout
3. **Write JSON** with rich details, real code snippets, accurate file paths
4. **Use compact multi-column positions** (see layout guidance above)
5. **Run generator** — produces both detailed + macro HTML automatically
6. **Test in browser** — serve via `python3 -m http.server` or open directly
7. **Verify**: click nodes (detail panel readable?), run tour (auto-zoom works?), check macro (families correct?)

### Examples

```
/create-diagram --interactive --guided "Full prediction pipeline for Sentimark"
/create-diagram --interactive --guided --details "QC call processing pipeline"
/create-diagram --interactive "Hey Seven RAG + LangGraph agent architecture"
/create-diagram --interactive --guided "Authentication flow with OAuth, JWT, session management"
```

---

## Error Handling

- If D2 not found: `curl -fsSL https://d2lang.com/install.sh | sh -s --`
- If Beautiful Mermaid not found: `npm install beautiful-mermaid --prefix ~/.local/share/npm-global`
- If render fails: check D2 syntax (common: missing quotes on multi-word labels)
- If interactive diagram shows blank: check browser console for React errors
- If macro not generated: verify nodes have `group` fields and there are 4+ distinct groups

## Reference Files

| File | Purpose |
|------|---------|
| `~/.claude/templates/interactive-diagram.html` | React Flow HTML template (dark theme, 42vw detail panel) |
| `~/.claude/scripts/generate-interactive-diagram.sh` | Generator: JSON → HTML + auto-macro |
| `~/.claude/scripts/generate-macro-diagram.py` | Standalone macro generator (optional) |
| `~/.claude/rules/diagramming.md` | Diagramming rules (tool selection, shapes, themes) |
| `~/.claude/themes/sentimark.d2` | Sentimark brand theme for D2 |
