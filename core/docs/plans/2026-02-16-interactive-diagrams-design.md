# Interactive Diagrams — Design Document

**Date**: 2026-02-16
**Status**: APPROVED
**Scope**: Global Claude Code capability (all projects)
**First deliverable**: Sentimark prediction pipeline

---

## Problem

Current `/create-diagram` skill generates static SVGs/PNGs via D2+ELK. While layout quality is excellent, the output is non-interactive — users can't click nodes for details, walk through flows step-by-step, or zoom into subgroups. For presentations and demos, static images fall short.

## Solution

Add `--interactive` flag to `/create-diagram` that generates a **self-contained HTML file** (~400-500KB) with React Flow 12 bundled inline. No CDN, no server, no build step. Works offline.

## Research Basis

6-LLM research (Perplexity, Grok, DeepSeek, Gemini, GPT-5.2, Context7):

| Tool | Click Details | Guided Flow | Zoom/Collapse | AI-Friendly | Verdict |
|---|---|---|---|---|---|
| **React Flow 12** (v12.10) | Native | Buildable | Native | JSON nodes/edges | **Selected** |
| D2 (v0.7.1) | Tooltips only | Auto-play only | SVG zoom | Text | Static only |
| Mermaid | Basic click | No | No | Text | Breaks 30+ nodes |
| Excalidraw | No details | No | Zoom only | JSON (complex) | Hand-drawn only |

React Flow is the only tool that natively supports all three requested features.

## Architecture

```
/create-diagram --interactive "description"
        │
        ▼
┌─ Claude generates JSON ──────────────────┐
│  { nodes: [...], edges: [...] }          │
│  Each node: id, label, position,         │
│    data: { details, codeSnippet,         │
│            filePath, stepIndex }         │
└──────────────────────────────────────────┘
        │
        ▼
┌─ HTML Template (~400KB) ─────────────────┐
│  ~/.claude/templates/                     │
│    interactive-diagram.html               │
│                                           │
│  Contains (all inlined, no CDN):          │
│  - React 19 production build              │
│  - React Flow 12 production build         │
│  - InteractiveNode component              │
│  - DetailPanel component                  │
│  - GuidedTour component                   │
│  - Dark theme CSS                         │
│  - Placeholder: window.__DIAGRAM_DATA__   │
└───────────────────────────────────────────┘
        │
        ▼
┌─ Output ─────────────────────────────────┐
│  <project>/docs/diagrams/                │
│    <name>-interactive.html               │
│  Opens in browser via wslview            │
└──────────────────────────────────────────┘
```

## Interactive Features

### 1. Click Node -> Detail Panel

Right-side panel shows on node click:
- Node title and description
- Code snippet (syntax highlighted)
- File path (clickable format: `file:line`)
- Category badge (data, gate, trade, etc.)
- Close button to dismiss

### 2. Guided Tour (Next/Prev)

Bottom toolbar with step controls:
- Step counter: "Step 3 of 12"
- Next/Prev/Reset buttons
- Current step: node gets orange glow, auto-zooms to center
- Other nodes dim to 30% opacity
- Step description shown in overlay card
- Keyboard: Arrow keys for next/prev, Escape to exit tour

### 3. Zoom/Pan/Collapse

- Scroll to zoom, drag to pan (React Flow default)
- Click subgroup header to collapse/expand
- Mini-map in bottom-right corner
- Fit-to-view button (top-right)
- Keyboard: +/- for zoom, Home for fit-to-view

### 4. Visual Design

- Dark theme (#0d1117 background, matching GitHub dark)
- Color-coded nodes by category:
  - Blue (#3498db): Data/processing
  - Orange (#f39c12): Gate/decision
  - Green (#2ecc71): Trade/positive
  - Red (#e74c3c): No-trade/negative
  - Gray (#95a5a6): Shadow/disabled
  - Purple (#9b59b6): Storage
- Animated edges: dots flowing along paths
- Selected node: orange glow border + scale up
- Subgroups: darker background with rounded border

## Skill Integration

```
# Static (existing, unchanged)
/create-diagram "Show the auth flow"
→ D2 + ELK → static SVG/PNG

# Interactive (new)
/create-diagram --interactive "Sentimark pipeline"
→ React Flow → self-contained HTML

# Interactive with guided tour
/create-diagram --interactive --guided "Edge gate step by step"
→ React Flow + auto-generated step sequence
```

## Node Data Schema

```typescript
interface DiagramNode {
  id: string;
  type: 'interactive';
  position: { x: number; y: number };
  data: {
    label: string;
    category: 'trigger' | 'data' | 'process' | 'gate' | 'decision' | 'trade' | 'notrade' | 'shadow' | 'storage';
    details: string;           // Markdown description
    codeSnippet?: string;      // Relevant code
    filePath?: string;         // file.py:42 format
    stepIndex?: number;        // For guided tour ordering
    stepDescription?: string;  // Tour narration for this step
    isGroup?: boolean;         // Collapsible subgroup
    children?: string[];       // Child node IDs if group
  };
}

interface DiagramEdge {
  id: string;
  source: string;
  target: string;
  label?: string;
  animated?: boolean;          // Dots flowing along edge
  style?: { strokeDasharray?: string }; // Dashed for shadow
}
```

## Files to Create

| File | Purpose |
|---|---|
| `~/.claude/templates/interactive-diagram.html` | Base HTML template with inlined React + React Flow |
| `~/.claude/skills/create-diagram.md` | EDIT: Add --interactive flag docs |
| `~/.claude/rules/diagramming.md` | EDIT: Add interactive diagram rules |

## Files Generated Per Diagram

| File | Purpose |
|---|---|
| `<project>/docs/diagrams/<name>-interactive.html` | Self-contained interactive diagram |

## First Deliverable: Sentimark Pipeline

Convert the existing `pipeline-overview.d2` into an interactive HTML with:
- All nodes from the D2 source
- Details for each node pulled from CLAUDE.md
- Code snippets from actual source files
- 12-step guided tour through the full prediction flow
- Collapsible subgroups for LLM Ensemble, Intelligence, Edge Gate

## Constraints

- No external dependencies (fully offline)
- Single HTML file (no multi-file bundles)
- Works in Chrome, Firefox, Edge (modern browsers)
- File size target: < 500KB
- No build tools required (no webpack, no vite)
- React Flow MIT license (free for all use)

## What This Does NOT Include

- Real-time data from APIs (diagrams are snapshots)
- Collaborative editing (use Excalidraw MCP for that)
- Diagram editing in browser (read-only presentation)
- Server-side rendering (client-side only)
