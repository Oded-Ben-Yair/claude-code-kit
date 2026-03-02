# Figma Mode

Convert Figma designs to code with deep understanding of Figma-specific concepts.

## Figma-to-Code Mapping

### Auto-Layout → CSS Flexbox/Grid

| Figma Property | CSS/Tailwind |
|----------------|--------------|
| Direction: Horizontal | `flex` / `flex-row` |
| Direction: Vertical | `flex flex-col` |
| Gap: 16 | `gap-4` |
| Padding: 24 | `p-6` |
| Alignment: Center | `items-center` |
| Distribution: Space Between | `justify-between` |
| Wrap | `flex-wrap` |
| Fill Container | `flex-1` / `w-full` |
| Hug Contents | `w-fit` |
| Fixed: 200px | `w-[200px]` |

### Component Variants → Props

When Figma has variants (Size: sm/md/lg, State: default/hover/active):

```tsx
interface ButtonProps {
  size?: 'sm' | 'md' | 'lg';
  variant?: 'primary' | 'secondary' | 'ghost';
  state?: 'default' | 'hover' | 'active' | 'disabled';
  children: React.ReactNode;
}

const sizeClasses = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
};

const variantClasses = {
  primary: 'bg-blue-600 text-white hover:bg-blue-700',
  secondary: 'bg-slate-100 text-slate-900 hover:bg-slate-200',
  ghost: 'bg-transparent text-slate-600 hover:bg-slate-100',
};

export function Button({
  size = 'md',
  variant = 'primary',
  children
}: ButtonProps) {
  return (
    <button className={cn(
      'inline-flex items-center justify-center rounded-lg font-medium transition-colors',
      sizeClasses[size],
      variantClasses[variant],
    )}>
      {children}
    </button>
  );
}
```

### Design Tokens Extraction

From Figma styles, generate:

```typescript
// design-tokens.ts

export const colors = {
  primary: {
    50: '#eff6ff',
    100: '#dbeafe',
    500: '#3b82f6',
    600: '#2563eb',
    900: '#1e3a8a',
  },
  neutral: {
    50: '#f8fafc',
    100: '#f1f5f9',
    500: '#64748b',
    900: '#0f172a',
  },
  // Extract from Figma color styles
};

export const typography = {
  display: {
    fontFamily: "'Space Grotesk', sans-serif",
    fontWeight: 700,
    letterSpacing: '-0.02em',
  },
  heading: {
    fontFamily: "'Space Grotesk', sans-serif",
    fontWeight: 600,
  },
  body: {
    fontFamily: "'Inter', sans-serif",
    fontWeight: 400,
    lineHeight: 1.6,
  },
};

export const spacing = {
  xs: '4px',
  sm: '8px',
  md: '16px',
  lg: '24px',
  xl: '32px',
  '2xl': '48px',
  '3xl': '64px',
};

export const shadows = {
  sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
  md: '0 4px 6px -1px rgb(0 0 0 / 0.1)',
  lg: '0 10px 15px -3px rgb(0 0 0 / 0.1)',
  xl: '0 20px 25px -5px rgb(0 0 0 / 0.1)',
};

export const radii = {
  sm: '4px',
  md: '8px',
  lg: '12px',
  xl: '16px',
  full: '9999px',
};
```

### Figma Effects → CSS

| Figma Effect | CSS/Tailwind |
|--------------|--------------|
| Drop Shadow (0, 4, 6, 0.1) | `shadow-md` or `shadow-[0_4px_6px_rgba(0,0,0,0.1)]` |
| Inner Shadow | `shadow-inner` or `box-shadow: inset ...` |
| Layer Blur: 8px | `backdrop-blur-sm` or `blur-sm` |
| Background Blur: 16px | `backdrop-blur-md` |
| Corner Radius: 12px | `rounded-xl` or `rounded-[12px]` |

---

## Workflow

### 1. Analyze Figma Export

From screenshot or export, identify:

```yaml
Component Hierarchy:
  - Root container (frame/auto-layout direction)
  - Sections and their layouts
  - Repeated patterns (lists, grids)
  - Nested components

Visual Properties:
  - Background colors
  - Border colors and widths
  - Typography (font, size, weight, color)
  - Spacing (padding, gaps)
  - Corner radius
  - Shadows and effects

Interactive States:
  - Hover variants
  - Active/pressed states
  - Focus states
  - Disabled states
  - Loading states
```

### 2. Prioritize Dev Mode Annotations

If Figma Dev Mode annotations exist, **use those exact values**:
- Exact spacing in pixels
- Exact colors in hex
- Exact font sizes and weights
- Exact corner radii

Dev Mode values override visual estimation.

### 3. Generate Component Structure

```
ComponentName/
├── index.ts           # Re-export
├── ComponentName.tsx  # Main component
├── types.ts           # TypeScript interfaces
└── variants.ts        # Variant mappings (if complex)
```

### 4. Implement with Composition

Break complex Figma components into composable pieces:

```tsx
// Card.tsx - Composable card system
export function Card({ className, children }: CardProps) {
  return (
    <div className={cn("rounded-xl border bg-white shadow-sm", className)}>
      {children}
    </div>
  );
}

Card.Header = function CardHeader({ children, className }: CardPartProps) {
  return (
    <div className={cn("border-b px-6 py-4", className)}>
      {children}
    </div>
  );
};

Card.Body = function CardBody({ children, className }: CardPartProps) {
  return (
    <div className={cn("px-6 py-4", className)}>
      {children}
    </div>
  );
};

Card.Footer = function CardFooter({ children, className }: CardPartProps) {
  return (
    <div className={cn("border-t px-6 py-4", className)}>
      {children}
    </div>
  );
};

// Usage matches Figma structure
<Card>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Actions</Card.Footer>
</Card>
```

---

## Common Figma Patterns

### Figma Frame with Constraints → Responsive

```tsx
// Figma: Frame with "Fill Container" horizontal, "Hug" vertical
<div className="w-full h-fit">

// Figma: Frame with min/max width constraints
<div className="w-full min-w-[320px] max-w-[600px]">

// Figma: Centered with max-width
<div className="mx-auto w-full max-w-4xl">
```

### Figma Auto-Layout Stack → Flexbox

```tsx
// Figma: Vertical stack, gap 16, center aligned
<div className="flex flex-col items-center gap-4">

// Figma: Horizontal stack, gap 8, space between
<div className="flex items-center justify-between gap-2">

// Figma: Wrap on overflow
<div className="flex flex-wrap gap-4">
```

### Figma Grid → CSS Grid

```tsx
// Figma: 3 column grid, equal columns, gap 24
<div className="grid grid-cols-3 gap-6">

// Figma: Responsive grid (1 → 2 → 3 columns)
<div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">

// Figma: Masonry-like varied heights
<div className="columns-1 gap-6 sm:columns-2 lg:columns-3">
```

---

## Best Practices

1. **Match Figma structure** - Component hierarchy should mirror Figma layers
2. **Use exact values** - Don't round 12px to 16px, use `rounded-[12px]`
3. **Preserve variant logic** - If Figma has variants, implement as props
4. **Extract tokens** - Create design tokens file from Figma styles
5. **Responsive by default** - Even if Figma only shows desktop
6. **Accessibility always** - Add ARIA labels, roles, keyboard support

---

## Checklist

- [ ] Component structure matches Figma hierarchy
- [ ] All Figma variants implemented as props
- [ ] Colors match exactly (hex codes)
- [ ] Typography matches (font, size, weight, line-height)
- [ ] Spacing matches (use exact pixel values if needed)
- [ ] Corner radius matches
- [ ] Shadows/effects match
- [ ] Interactive states implemented (hover, focus, active)
- [ ] Responsive breakpoints added
- [ ] Accessibility attributes included
