# Diagramming Rules

## Tool Selection

| Condition | Tool | Command |
|-----------|------|---------|
| **Presentation/demo, click-to-explore** | **React Flow (interactive)** | `/create-diagram --interactive` |
| 15+ nodes, subgraphs, complex flow | D2 + ELK | `d2 --layout=elk input.d2 output.svg` |
| < 15 nodes, existing Mermaid code | Beautiful Mermaid | `node ~/.claude/scripts/render-mermaid.js` |
| Quick GitHub README inline | Mermaid (raw) | Embed in markdown |
| Hand-drawn/sketch style needed | D2 sketch mode | `d2 --sketch input.d2 output.svg` |

## D2 Generation Rules (MANDATORY)

1. **Always use classes pattern** — AI generates topology with named classes, never inline styles
2. **Always use ELK layout** — `--layout=elk` for orthogonal edge routing (professional)
3. **Quote multi-word labels** — `"Parse Input"` not `Parse Input`
4. **Use containers for subgraphs** — nested blocks with labels
5. **Direction**: `direction: down` for flowcharts, `direction: right` for pipelines
6. **Dashed edges** for shadow/optional flows: `A -- B` (double dash)
7. **Edge labels**: `A -> B: "label text"`

## D2 Shape Reference

| Shape | D2 Keyword | Use For |
|-------|-----------|---------|
| Rectangle | `rectangle` (default) | Process steps |
| Diamond | `diamond` | Decision points |
| Oval | `oval` | Start/End terminals |
| Cylinder | `cylinder` | Databases, storage |
| Cloud | `cloud` | External services |
| Hexagon | `hexagon` | Preparation steps |
| Queue | `queue` | Message queues |
| Package | `package` | Modules/packages |

## Theme Reference

| Project | Theme | D2 Base Theme |
|---------|-------|---------------|
| Sentimark | `~/.claude/themes/sentimark.d2` | 200 (Dark Mauve) |
| Default dark | — | 200 |
| Default light | — | 100 (Origami) |
| Terminal | — | 300 |

## File Conventions

| Type | Location | Naming |
|------|----------|--------|
| D2 source | `<project>/docs/diagrams/*.d2` | kebab-case |
| SVG output | `<project>/docs/diagrams/*.svg` | Same name as .d2 |
| PNG output | `<project>/docs/diagrams/*.png` | Same name as .d2 |
| Themes | `~/.claude/themes/*.d2` | project-name.d2 |

## Mermaid Limitations (When NOT to Use)

- 15+ nodes: layout degrades, edges cross through nodes
- Nested subgraphs: poor padding and spacing
- Complex edge routing: no collision detection
- Publication quality needed: use D2 instead

## Beautiful Mermaid Themes

tokyo-night | dracula | nord | catppuccin-mocha | github-dark | one-dark-pro | gruvbox-dark | rose-pine | synthwave-84 | solarized-dark | ayu-dark | material | night-owl | poimandres | vitesse-dark

## Interactive Diagrams (React Flow)

### When to Use Interactive vs Static

| Scenario | Use |
|----------|-----|
| Documentation, README | Static (D2 → SVG) |
| Presentation, demo | **Interactive** (React Flow → HTML) |
| Stakeholder walkthrough | **Interactive** + `--guided` |
| Quick sketch | Static (D2 --sketch) |
| Print/PDF | Static (D2 → PNG/PDF) |

### Interactive Diagram Rules

1. Keep node count under 50 (React Flow handles it, but UX degrades)
2. Always include `stepIndex` for guided tour — presentations need a narrative
3. Pull real code snippets from source — never fake/placeholder code (Rule 1)
4. Category colors must match D2 theme (blue=data, orange=gate, green=trade, red=notrade)
5. Test in browser before delivering — `wslview <file>.html`
6. File path: `<project>/docs/diagrams/<name>-interactive.html`
7. JSON data file alongside: `<project>/docs/diagrams/<name>-interactive.json`

### Interactive File Conventions

| Type | Location | Naming |
|------|----------|--------|
| JSON data | `<project>/docs/diagrams/*.json` | `<name>-interactive.json` |
| HTML output | `<project>/docs/diagrams/*.html` | `<name>-interactive.html` |
| Template | `~/.claude/templates/interactive-diagram.html` | Single global template |
| Generator | `~/.claude/scripts/generate-interactive-diagram.sh` | Takes JSON → HTML |

## Rendering Checklist

Before delivering a diagram:
1. All node labels are legible (not truncated)
2. No edge crossings through nodes
3. Subgraphs have clear boundaries
4. Decision diamonds have labeled yes/no edges
5. Color coding is consistent and meaningful
6. SVG opens correctly in browser
7. **Interactive**: click nodes shows details, guided tour works, zoom/pan smooth
