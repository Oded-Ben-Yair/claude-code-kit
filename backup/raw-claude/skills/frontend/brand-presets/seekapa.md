# Seekapa Brand Preset

## Brand Identity

- **Industry**: Forex trading platform (GCC region)
- **Feel**: Professional, Trustworthy, Premium
- **Target**: GCC forex traders, Arabic-speaking professionals

## Colors

```typescript
export const seekapaColors = {
  primary: {
    deepBlue: '#1E3A5F',
    blue: '#2C4F7C',
  },
  secondary: {
    gold: '#D4AF37',
    lightGold: '#E5C76B',
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
export const seekapaTypography = {
  fontFamily: {
    display: "'IBM Plex Sans Arabic', 'IBM Plex Sans', sans-serif",
    body: "'IBM Plex Sans Arabic', 'IBM Plex Sans', sans-serif",
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
<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans+Arabic:wght@400;500;600;700&family=IBM+Plex+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
```

## Design System

### Spacing
```typescript
export const seekapaSpacing = {
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
export const seekapaRadii = {
  sm: '4px',
  md: '8px',
  lg: '12px',
  xl: '16px',
};
```

### Shadows
```typescript
export const seekapaShadows = {
  sm: '0 1px 2px rgba(30, 58, 95, 0.05)',
  md: '0 4px 6px rgba(30, 58, 95, 0.1)',
  lg: '0 10px 15px rgba(30, 58, 95, 0.1)',
  gold: '0 4px 12px rgba(212, 175, 55, 0.3)',
};
```

## Tailwind Configuration

```javascript
// tailwind.config.js - Seekapa extension
module.exports = {
  theme: {
    extend: {
      colors: {
        seekapa: {
          'deep-blue': '#1E3A5F',
          'blue': '#2C4F7C',
          'gold': '#D4AF37',
          'light-gold': '#E5C76B',
        },
      },
      fontFamily: {
        display: ['IBM Plex Sans Arabic', 'IBM Plex Sans', 'sans-serif'],
        body: ['IBM Plex Sans Arabic', 'IBM Plex Sans', 'sans-serif'],
      },
    },
  },
};
```

## Component Patterns

### Primary Button
```tsx
<button className="bg-seekapa-deep-blue text-white px-6 py-3 rounded-lg font-semibold hover:bg-seekapa-blue transition-colors">
  Get Started
</button>
```

### Gold Accent Button
```tsx
<button className="bg-seekapa-gold text-seekapa-deep-blue px-6 py-3 rounded-lg font-semibold hover:bg-seekapa-light-gold transition-colors">
  Premium Feature
</button>
```

### Card
```tsx
<div className="bg-white border border-seekapa-deep-blue/10 rounded-xl p-6 shadow-md">
  <h3 className="text-seekapa-deep-blue font-semibold text-lg">Card Title</h3>
  <p className="text-gray-600 mt-2">Card content here.</p>
</div>
```

## Effects Recommendations

| Effect | Use | Don't Use |
|--------|-----|-----------|
| Animations | Subtle fades, precise micro-interactions | Bouncy, playful |
| Backgrounds | Clean gradients, subtle patterns | Aurora, particles |
| Hovers | Scale 1.02, shadow increase | Magnetic, wobble |
| Text | Clean reveals | Decrypt, glitch |

## RTL Support

Seekapa requires RTL support for Arabic content:

```tsx
<div dir="rtl" className="text-right font-display">
  مرحبا بك
</div>
```

**Tailwind RTL:**
```javascript
// Using tailwindcss-rtl plugin
<div className="rtl:text-right rtl:ml-auto rtl:mr-0">
```
