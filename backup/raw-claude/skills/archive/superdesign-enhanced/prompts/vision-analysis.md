# Gemini Vision Analysis Prompt

Use with `mcp__gemini__gemini-query` at HIGH resolution.

## Standard UI Analysis

```
Analyze this UI screenshot in detail. Return a comprehensive JSON specification following this structure:

{
  "layout": {
    "type": "flex|grid",
    "direction": "row|column",
    "gaps": "spacing values observed",
    "structure": "hierarchical description of the layout"
  },
  "components": [
    {
      "type": "component type (button, input, card, nav, header, etc.)",
      "content": "text content or description",
      "styling": {
        "background": "#hexcolor",
        "text": "#hexcolor",
        "border": "border style if any",
        "rounded": "border-radius value",
        "shadow": "shadow if present",
        "padding": "padding values",
        "margin": "margin values"
      },
      "position": "location in the layout (e.g., 'top-left header area')",
      "children": []
    }
  ],
  "colors": {
    "primary": "#hexcolor - main brand/action color",
    "secondary": "#hexcolor - secondary accent",
    "accent": "#hexcolor - highlight color",
    "background": "#hexcolor - page background",
    "surface": "#hexcolor - card/container background",
    "text": "#hexcolor - primary text color",
    "textMuted": "#hexcolor - secondary/muted text"
  },
  "typography": {
    "fontFamily": "detected or 'sans-serif'",
    "headings": { "size": "px", "weight": 600-700 },
    "body": { "size": "px", "weight": 400 },
    "small": { "size": "px", "weight": 400 }
  },
  "spacing": {
    "xs": "4px",
    "sm": "8px",
    "md": "16px",
    "lg": "24px",
    "xl": "32px"
  },
  "interactions": {
    "hoverStates": ["describe any visible hover states"],
    "animations": ["describe any animations"],
    "transitions": ["describe any transitions"]
  }
}

Be thorough and accurate. Extract exact colors using a color picker approach.
Identify all visible components and their hierarchical relationships.
```

## Design System Extraction

```
Analyze these UI screenshots and extract a comprehensive design system.

Return a structured markdown document with:

## Colors

### Primary Palette
- Primary: #hex (describe usage)
- Primary Light: #hex
- Primary Dark: #hex

### Secondary Palette
- Secondary: #hex
- etc.

### Semantic Colors
- Success: #hex
- Warning: #hex
- Error: #hex
- Info: #hex

### Neutrals
- Gray 50: #hex
- Gray 100: #hex
- ... through Gray 900

## Typography

### Font Families
- Headings: [font name]
- Body: [font name]

### Scale
| Name | Size | Weight | Line Height |
|------|------|--------|-------------|
| xs   | 12px | 400    | 1.5         |
| sm   | 14px | 400    | 1.5         |
| base | 16px | 400    | 1.5         |
| lg   | 18px | 500    | 1.4         |
| xl   | 20px | 600    | 1.3         |
| 2xl  | 24px | 600    | 1.2         |
| 3xl  | 30px | 700    | 1.2         |

## Spacing

Base unit: 4px

| Token | Value |
|-------|-------|
| 1     | 4px   |
| 2     | 8px   |
| 3     | 12px  |
| 4     | 16px  |
| 6     | 24px  |
| 8     | 32px  |
| 12    | 48px  |
| 16    | 64px  |

## Border Radius

| Token    | Value |
|----------|-------|
| sm       | 4px   |
| default  | 8px   |
| md       | 12px  |
| lg       | 16px  |
| xl       | 24px  |
| full     | 9999px |

## Shadows

| Token | Value |
|-------|-------|
| sm    | [shadow] |
| default | [shadow] |
| lg    | [shadow] |

## Component Patterns

### Buttons
- Primary: [describe styling]
- Secondary: [describe styling]
- Ghost: [describe styling]

### Cards
- [describe card styling patterns]

### Inputs
- [describe input styling patterns]
```

## Quick Component Analysis

```
Analyze this UI component screenshot. Return:

1. Component type (button, card, input, etc.)
2. Exact dimensions if discernible
3. Colors used (hex values)
4. Typography (size, weight)
5. Spacing (padding, margin)
6. Border radius
7. Shadow values
8. Hover/focus states if visible
9. Tailwind CSS classes that would recreate this
```
