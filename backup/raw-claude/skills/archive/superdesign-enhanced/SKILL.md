---
name: superdesign-enhanced
description: Multi-model design-to-code workflow using Gemini vision + SuperDesign + Claude code generation
triggers:
  - "design to code"
  - "screenshot to code"
  - "create UI"
  - "generate component"
  - "extract design system"
  - "superdesign"
  - "/superdesign"
---

# SuperDesign Enhanced Skill

Multi-model design-to-code workflow that orchestrates:
1. **Gemini 3 Pro** - Vision analysis of screenshots/designs (HIGH resolution)
2. **SuperDesign MCP** - Design generation and iteration
3. **Claude** - Production code generation

## Available Modes

### Mode 1: Screenshot to Code

Convert any UI screenshot to production code.

**Workflow:**
1. User provides screenshot/image
2. Analyze with Gemini vision:
   ```
   Use mcp__gemini__gemini-query with prompt:
   "Analyze this UI screenshot. Return a JSON object with:
   - layout: flexbox/grid structure description
   - components: array of UI elements (type, content, styling)
   - colors: object with primary, secondary, background, text hex values
   - typography: font sizes, weights, line heights
   - spacing: padding, margin, gap values
   - interactions: hover states, animations observed"
   ```
3. Generate design spec from analysis
4. Use `mcp__superdesign__superdesign_generate` with the spec
5. Generate production code for detected/requested framework

### Mode 2: Prompt to Design to Code

Create new UI from natural language description.

**Workflow:**
1. User describes desired UI
2. Call `mcp__superdesign__superdesign_generate`:
   - `prompt`: User's description
   - `design_type`: "ui" | "wireframe" | "component"
   - `variations`: 3-5 (parallel generation)
   - `framework`: Detect from project or ask user
3. Present variations to user
4. User selects preferred variant
5. Generate production code

### Mode 3: Design System Extraction

Extract design tokens from existing designs/screenshots.

**Workflow:**
1. User provides screenshots/designs
2. Analyze each with Gemini vision (HIGH resolution)
3. Call `mcp__superdesign__superdesign_extract_system`
4. Generate `style.md` with:
   - Color palette (named tokens)
   - Typography scale
   - Spacing system
   - Component patterns

### Mode 4: Design Iteration

Refine existing designs based on feedback.

**Workflow:**
1. User provides design file path and feedback
2. Call `mcp__superdesign__superdesign_iterate`:
   - `design_file`: Path to existing design
   - `feedback`: User's improvement instructions
   - `variations`: Number of iterations
3. Present refined variations
4. Regenerate code if requested

## Framework Detection

Automatically detect target framework:

```javascript
// Check package.json for:
// React: "react", "next", "@remix-run"
// Vue: "vue", "nuxt"
// Svelte: "svelte", "@sveltejs/kit"
// Default: HTML + Tailwind CSS
```

## MCP Tools Used

| Tool | Purpose |
|------|---------|
| `mcp__gemini__gemini-query` | Vision analysis with HIGH resolution |
| `mcp__superdesign__superdesign_generate` | Generate design variations |
| `mcp__superdesign__superdesign_iterate` | Iterate on existing designs |
| `mcp__superdesign__superdesign_extract_system` | Extract design tokens |
| `mcp__superdesign__superdesign_list` | List all designs in workspace |
| `mcp__superdesign__superdesign_gallery` | Generate design gallery |

## Code Generation Standards

All generated code must:
- Use **Tailwind CSS** for styling
- Include **TypeScript types** (for React/Vue)
- Add **accessibility attributes** (aria-*, role, tabindex)
- Be **responsive** (mobile-first breakpoints)
- Include **hover/focus states**
- Follow project conventions if CLAUDE.md exists

## Output Structure

Designs saved to `superdesign/` directory:
```
superdesign/
├── design_iterations/     # Generated HTML/SVG files
│   ├── ui_dashboard_v1.html
│   ├── ui_dashboard_v2.html
│   └── component_button_v1.html
└── design_system/         # Extracted design systems
    └── style.md
```

## Example Prompts

**Screenshot to Code:**
```
/superdesign
[upload screenshot]
"Convert this to a React component with TypeScript"
```

**Prompt to Design:**
```
/superdesign
"Create a modern dashboard with sidebar navigation,
stats cards, and a data table. Dark theme with
purple accents."
```

**Design Iteration:**
```
/superdesign iterate
"Make the buttons larger and add more spacing
between sections"
```

**Extract Design System:**
```
/superdesign extract-system
[upload multiple screenshots]
"Extract the design system from these screens"
```

## Gemini Vision Prompts

### UI Analysis Prompt
```
Analyze this UI screenshot and return a detailed JSON specification:

{
  "layout": {
    "type": "flex|grid",
    "direction": "row|column",
    "gaps": "spacing values",
    "structure": "description of layout hierarchy"
  },
  "components": [
    {
      "type": "button|input|card|nav|header|footer|etc",
      "content": "text or placeholder",
      "styling": {
        "background": "#hex",
        "text": "#hex",
        "border": "style",
        "rounded": "value",
        "shadow": "value"
      },
      "position": "relative location in layout"
    }
  ],
  "colors": {
    "primary": "#hex",
    "secondary": "#hex",
    "accent": "#hex",
    "background": "#hex",
    "surface": "#hex",
    "text": "#hex",
    "textMuted": "#hex"
  },
  "typography": {
    "headings": { "size": "px", "weight": "number" },
    "body": { "size": "px", "weight": "number" },
    "small": { "size": "px", "weight": "number" }
  },
  "spacing": {
    "xs": "px", "sm": "px", "md": "px", "lg": "px", "xl": "px"
  }
}
```

### Design System Extraction Prompt
```
Analyze these UI screenshots and extract a comprehensive design system:

1. Color Palette:
   - Primary colors with variations (50-900)
   - Semantic colors (success, warning, error, info)
   - Neutral colors (gray scale)

2. Typography:
   - Font families detected
   - Size scale (xs to 4xl)
   - Weight variations
   - Line heights

3. Spacing:
   - Base unit
   - Scale multipliers

4. Components:
   - Common patterns observed
   - Consistent styling rules

Return as structured markdown suitable for style.md.
```

## Integration with Existing Skills

This skill works with:
- `design-to-code` - For Figma integration
- `premium-frontend` - For premium UI effects
- `premium-effects` - For animations
- `figma` - For Figma exports
