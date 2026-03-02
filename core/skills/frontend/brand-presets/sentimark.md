# Sentimark Brand Preset

## Brand Identity

- **Industry**: Market Intelligence & Prediction Analytics
- **Feel**: Futuristic, Data-Driven, Premium Tech, Analytical
- **Target**: Crypto/financial market analysts, traders, prediction enthusiasts

## Colors

```typescript
export const sentimarkColors = {
  primary: {
    deepPurple: '#642C95',
    purple: '#7C3AAD',
    purpleLight: '#9747FF',
  },
  secondary: {
    turquoise: '#2CE7E3',
    turquoiseLight: '#5EECEA',
    turquoiseDark: '#20B2AE',
  },
  background: {
    primary: '#0E1118',
    surface: '#1A1D26',
    card: '#242833',
    elevated: '#2D3140',
  },
  neutral: {
    white: '#FFFFFF',
    offWhite: '#F8FAFC',
    lightGray: '#E2E8F0',
    gray: '#64748B',
    textMuted: '#94A3B8',
    darkGray: '#334155',
  },
  semantic: {
    bullish: '#22C55E',
    bearish: '#EF4444',
    neutral: '#94A3B8',
    warning: '#F59E0B',
    info: '#3B82F6',
  },
};
```

## Typography

```typescript
export const sentimarkTypography = {
  fontFamily: {
    display: "'Sulphur Point', sans-serif",
    heading: "'Space Grotesk', sans-serif",
    body: "'Inter', sans-serif",
    data: "'JetBrains Mono', monospace",
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
<link href="https://fonts.googleapis.com/css2?family=Sulphur+Point:wght@400;700&family=Space+Grotesk:wght@400;500;600;700&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
```

## Design System

### Spacing
```typescript
export const sentimarkSpacing = {
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
export const sentimarkRadii = {
  sm: '6px',
  md: '10px',
  lg: '14px',
  xl: '20px',
  full: '9999px',
};
```

### Shadows
```typescript
export const sentimarkShadows = {
  sm: '0 1px 2px rgba(100, 44, 149, 0.1)',
  md: '0 4px 6px rgba(100, 44, 149, 0.15)',
  lg: '0 10px 25px rgba(100, 44, 149, 0.2)',
  glow: '0 0 20px rgba(44, 231, 227, 0.3)',
  cardHover: '0 0 30px rgba(44, 231, 227, 0.15)',
};
```

## Tailwind Configuration

```javascript
// tailwind.config.js extension
module.exports = {
  theme: {
    extend: {
      colors: {
        sentimark: {
          'primary': '#642C95',
          'primary-light': '#7C3AAD',
          'secondary': '#2CE7E3',
          'secondary-light': '#5EECEA',
          'bg-primary': '#0E1118',
          'bg-surface': '#1A1D26',
          'bg-card': '#242833',
          'bullish': '#22C55E',
          'bearish': '#EF4444',
          'neutral': '#94A3B8',
          'text-muted': '#94A3B8',
        },
      },
      fontFamily: {
        display: ['Sulphur Point', 'sans-serif'],
        heading: ['Space Grotesk', 'sans-serif'],
        body: ['Inter', 'sans-serif'],
        data: ['JetBrains Mono', 'monospace'],
      },
      animation: {
        'aurora': 'aurora 60s linear infinite',
        'pulse-glow': 'pulse-glow 2s ease-in-out infinite',
      },
      keyframes: {
        aurora: {
          from: { backgroundPosition: '50% 50%, 50% 50%' },
          to: { backgroundPosition: '350% 50%, 350% 50%' },
        },
        'pulse-glow': {
          '0%, 100%': { boxShadow: '0 0 20px rgba(44, 231, 227, 0.3)' },
          '50%': { boxShadow: '0 0 40px rgba(44, 231, 227, 0.5)' },
        },
      },
    },
  },
};
```

## Component Patterns

### Primary Button
```tsx
<button className="bg-sentimark-primary text-white px-6 py-3 rounded-lg font-heading font-semibold hover:bg-sentimark-primary-light transition-colors">
  Get Started
</button>
```

### Secondary Button (Turquoise Accent)
```tsx
<button className="bg-sentimark-secondary text-sentimark-bg-primary px-6 py-3 rounded-lg font-heading font-semibold hover:bg-sentimark-secondary-light transition-colors">
  View Analysis
</button>
```

### Glassmorphism Card
```tsx
<div className="relative bg-white/5 backdrop-blur-xl border border-white/10 rounded-xl p-6 shadow-lg">
  {/* Subtle glow on hover */}
  <div className="absolute inset-0 rounded-xl opacity-0 hover:opacity-100 transition-opacity duration-300 bg-gradient-to-r from-sentimark-primary/10 to-sentimark-secondary/10" />

  <div className="relative">
    <h3 className="text-white font-heading font-semibold text-lg">Card Title</h3>
    <p className="text-sentimark-text-muted mt-2">Card content here.</p>
  </div>
</div>
```

### Data Display Card
```tsx
<div className="bg-sentimark-bg-card border border-white/5 rounded-xl p-4">
  <span className="text-sentimark-text-muted text-sm font-body">Signal</span>
  <p className="text-2xl font-data font-medium text-white">75</p>
  <span className="text-sentimark-bullish text-sm font-data">+5</span>
</div>
```

### Bullish/Bearish Indicators
```tsx
// Bullish
<span className="text-sentimark-bullish font-data">+12.5%</span>

// Bearish
<span className="text-sentimark-bearish font-data">-8.3%</span>

// Neutral
<span className="text-sentimark-neutral font-data">0.0%</span>
```

## Effects Recommendations

Based on Sentimark's futuristic, data-driven brand:

| Effect | Use | Avoid |
|--------|-----|-------|
| **Animations** | Staggered reveals, fade-ins, data transitions (300-400ms) | Bouncy, playful, > 500ms |
| **Backgrounds** | Aurora gradients (purple/turquoise), glassmorphism | Heavy particles (too busy for data focus) |
| **Hovers** | Glow borders (turquoise), subtle scale (1.02), shadow lift | Magnetic buttons, wobble (too playful) |
| **Cards** | Glassmorphism with turquoise accents, backdrop-blur-xl | Heavy drop shadows |
| **Text** | Clean reveals, data animation (number counting) | Decrypt, glitch (distracting) |
| **Transitions** | ease-out, 300-400ms | Linear, bounce |

### Aurora Background Pattern
```tsx
<div className="absolute inset-0 overflow-hidden">
  <div
    className="absolute -inset-[10%] animate-aurora opacity-30"
    style={{
      background: `
        radial-gradient(circle at 20% 50%, rgba(100, 44, 149, 0.4) 0%, transparent 50%),
        radial-gradient(circle at 80% 20%, rgba(44, 231, 227, 0.3) 0%, transparent 40%),
        radial-gradient(circle at 40% 80%, rgba(100, 44, 149, 0.3) 0%, transparent 40%)
      `,
    }}
  />
</div>
```

### Glassmorphism Tooltip
```tsx
<div className="absolute z-50 bg-white/5 backdrop-blur-xl border border-white/10 rounded-xl p-4 shadow-lg">
  <p className="text-sm text-white">{description}</p>
  <p className="text-xs text-sentimark-text-muted mt-2">
    Sources: {sources.join(', ')}
  </p>
</div>
```

## Notes

- **Data Hierarchy**: Always use `font-data` (JetBrains Mono) for numerical values
- **Color Coding**: Bullish = green, Bearish = red, Neutral = muted gray
- **Animation Timing**: 300-400ms for micro-interactions, 400-500ms for page transitions
- **Glassmorphism**: Use `backdrop-blur-xl` + `bg-white/5` + `border-white/10`
- **Hover States**: Prefer turquoise glow borders over scale transforms for data cards
- **Accessibility**: Ensure contrast ratios meet WCAG AA (4.5:1) for text on dark backgrounds
