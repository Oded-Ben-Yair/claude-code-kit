# [Brand Name] Brand Preset

## Brand Identity

- **Industry**: [Industry/sector]
- **Feel**: [3-4 adjectives: Modern, Professional, Playful, etc.]
- **Target**: [Target audience]

## Colors

```typescript
export const brandColors = {
  primary: {
    main: '#000000',
    light: '#333333',
    dark: '#000000',
  },
  secondary: {
    main: '#666666',
    light: '#999999',
  },
  neutral: {
    white: '#FFFFFF',
    offWhite: '#F8FAFC',
    lightGray: '#E2E8F0',
    gray: '#64748B',
    darkGray: '#334155',
    black: '#0F172A',
  },
  semantic: {
    success: '#22C55E',
    warning: '#F59E0B',
    error: '#EF4444',
    info: '#3B82F6',
  },
};
```

## Typography

```typescript
export const brandTypography = {
  fontFamily: {
    display: "'Font Name', sans-serif",
    body: "'Font Name', sans-serif",
  },
  weights: {
    regular: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },
};
```

**Font Import:**
```html
<link href="https://fonts.googleapis.com/css2?family=..." rel="stylesheet">
```

## Design System

### Spacing
```typescript
export const brandSpacing = {
  xs: '4px',
  sm: '8px',
  md: '16px',
  lg: '24px',
  xl: '32px',
  '2xl': '48px',
  '3xl': '64px',
};
```

### Border Radius
```typescript
export const brandRadii = {
  sm: '4px',
  md: '8px',
  lg: '12px',
  xl: '16px',
  full: '9999px',
};
```

### Shadows
```typescript
export const brandShadows = {
  sm: '0 1px 2px rgba(0, 0, 0, 0.05)',
  md: '0 4px 6px rgba(0, 0, 0, 0.1)',
  lg: '0 10px 15px rgba(0, 0, 0, 0.1)',
};
```

## Tailwind Configuration

```javascript
// tailwind.config.js extension
module.exports = {
  theme: {
    extend: {
      colors: {
        brand: {
          primary: '#000000',
          secondary: '#666666',
        },
      },
      fontFamily: {
        display: ['Font Name', 'sans-serif'],
        body: ['Font Name', 'sans-serif'],
      },
    },
  },
};
```

## Component Patterns

### Primary Button
```tsx
<button className="bg-brand-primary text-white px-6 py-3 rounded-lg font-semibold hover:opacity-90 transition-opacity">
  Button Text
</button>
```

### Card
```tsx
<div className="bg-white border border-gray-200 rounded-xl p-6 shadow-sm">
  <h3 className="text-gray-900 font-semibold text-lg">Card Title</h3>
  <p className="text-gray-600 mt-2">Card content here.</p>
</div>
```

## Effects Recommendations

Based on brand feel, select appropriate effects:

| Brand Feel | Recommended Effects | Avoid |
|------------|--------------------| ------|
| Minimal | Subtle fades, clean hovers | Heavy animations, 3D |
| Futuristic | Aurora, particles, glitch text | Bouncy, playful |
| Playful | Magnetic buttons, wobble, bouncy | Serious, corporate |
| Corporate | Precise micro-interactions, clean | Experimental, flashy |
| Editorial | Scroll reveals, typography focus | Heavy effects |

## Notes

[Any special considerations, accessibility requirements, cultural considerations, etc.]
