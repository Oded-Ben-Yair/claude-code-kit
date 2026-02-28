## Productivity Tools

### Skills

| Skill | When | What |
|-------|------|------|
| `/ship-it` | Scope creep, perfectionism loop, 3rd+ iteration | Declare "good enough", cut scope, deliver |
| `/learning-loop` | Session end, new pattern discovered, failure teaches lesson | Extract learnings, update rules, persist decisions |
| `/morning-update` | First session of day, "what's new" | Daily briefing: research findings, pattern health, focus recommendation |
| `/create-diagram` | Need architecture/flow visualization | D2+ELK for 15+ nodes, Mermaid for simple, `--interactive` for React Flow |

### Agents

| Agent | Triggers | Role |
|-------|----------|------|
| code-simplifier | simplify, refine, clean up code | Simplify recently modified code without changing functionality |

### Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| auto-router.py | UserPromptSubmit | Detects intent from prompt, suggests correct MCP/agent/skill routing |

### Diagramming Rules

- **D2 + ELK**: 15+ nodes, subgraphs, complex flows. Always use classes pattern, ELK layout.
- **Beautiful Mermaid**: < 15 nodes, existing Mermaid code. Themes: tokyo-night, dracula, nord, etc.
- **Interactive (React Flow)**: Presentations, demos, stakeholder walkthroughs. `--interactive --guided`.
- See `rules/diagramming.md` for full shape reference, theme IDs, and rendering checklist.
