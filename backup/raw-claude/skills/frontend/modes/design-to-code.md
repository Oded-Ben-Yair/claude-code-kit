# Design-to-Code Mode

Convert designs (screenshots, mockups, descriptions) to production-ready React + Tailwind code.

## Workflow

### Step 1: Analyze Design

Use Gemini 3 Pro with HIGH resolution for pixel-level detail:

```yaml
gemini-query:
  thinking_level: "high"
  media_resolution: "HIGH"  # 1120 tokens - best for design detail
  prompt: |
    Analyze this design for:
    1. Component hierarchy (container → sections → elements)
    2. Color palette (extract exact hex codes)
    3. Typography (fonts, sizes, weights, line-heights)
    4. Spacing system (padding, margins, gaps)
    5. Interactive states (hover, active, focus)
    6. Responsive breakpoints implied by layout
    7. Accessibility considerations
```

### Step 2: Apply Typography-First Principles

**Before writing any component code, determine typography:**

| Element | Question | Example |
|---------|----------|---------|
| Display Font | What sets the tone? | Bricolage Grotesque, Space Grotesk, Playfair |
| Body Font | What pairs well? | Newsreader, Source Sans 3, IBM Plex |
| Size System | Fluid or fixed? | Always fluid: `clamp(min, preferred, max)` |
| Weight System | Exact brand weights? | 385, 465, 685 (not 400, 500, 700) |
| Features | Polish needed? | ss01, liga, onum for headings |

**Tailwind Configuration:**
```javascript
// tailwind.config.js
fontFamily: {
  display: ['Bricolage Grotesque', 'sans-serif'],
  body: ['Newsreader', 'serif'],
},
fontSize: {
  'fluid-h1': 'clamp(2.5rem, 5vw + 1rem, 5rem)',
  'fluid-h2': 'clamp(1.875rem, 3vw + 1rem, 3rem)',
  'fluid-body': 'clamp(1rem, 0.25vw + 0.9rem, 1.125rem)',
},
fontWeight: {
  'display': '685',
  'heading': '565',
  'body': '465',
}
```

### Step 3: Generate Component

**Standard component structure:**

```tsx
import { cn } from '@/lib/utils';

interface ComponentNameProps {
  // Required props first
  title: string;
  // Optional props with defaults
  variant?: 'primary' | 'secondary';
  className?: string;
  children?: React.ReactNode;
}

export function ComponentName({
  title,
  variant = 'primary',
  className,
  children,
}: ComponentNameProps) {
  return (
    <section
      className={cn(
        // Base styles
        "relative overflow-hidden",
        // Responsive padding
        "px-4 py-12 sm:px-6 sm:py-16 lg:px-8 lg:py-24",
        // Variant styles
        variant === 'primary' && "bg-slate-900 text-white",
        variant === 'secondary' && "bg-white text-slate-900",
        className
      )}
    >
      <div className="mx-auto max-w-7xl">
        <h2 className="font-display text-fluid-h2 font-display tracking-tight">
          {title}
        </h2>
        {children}
      </div>
    </section>
  );
}
```

### Step 4: Implement Patterns

**Responsive Container:**
```tsx
<div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
```

**Responsive Grid:**
```tsx
<div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
```

**Card Pattern:**
```tsx
<div className="group relative rounded-xl border border-slate-200 bg-white p-6 shadow-sm transition-shadow hover:shadow-md">
```

**Button Pattern:**
```tsx
<button className="inline-flex items-center justify-center rounded-lg bg-slate-900 px-4 py-2.5 text-sm font-medium text-white transition-colors hover:bg-slate-800 focus:outline-none focus:ring-2 focus:ring-slate-900 focus:ring-offset-2">
```

### Step 5: Add States

Every interactive component needs:

```tsx
// Loading State
{isLoading && (
  <div className="animate-pulse">
    <div className="h-4 w-3/4 rounded bg-slate-200" />
    <div className="mt-2 h-4 w-1/2 rounded bg-slate-200" />
  </div>
)}

// Error State
{error && (
  <div className="rounded-lg bg-red-50 p-4">
    <p className="text-sm text-red-700">{error.message}</p>
  </div>
)}

// Empty State
{items.length === 0 && (
  <div className="py-12 text-center">
    <p className="text-sm text-slate-500">No items yet</p>
  </div>
)}
```

### Step 6: Verify

Use Playwright + Gemini for visual verification:

```yaml
# 1. Navigate and screenshot
mcp__playwright__browser_navigate: { url: "http://localhost:3000" }
mcp__playwright__browser_take_screenshot: { fullPage: true }

# 2. Compare with original design
gemini-query:
  thinking_level: "high"
  media_resolution: "HIGH"
  prompt: |
    Compare this implementation against the original design.
    Check for differences in:
    - Spacing (padding, margins, gaps)
    - Colors (exact hex match)
    - Typography (font, size, weight)
    - Alignment and layout
    - Responsive behavior

    List specific issues with exact values to fix.
```

---

## Responsive Breakpoints

| Breakpoint | Width | Device | Use Case |
|------------|-------|--------|----------|
| Default | 0+ | Mobile first | Base styles |
| `sm:` | 640px+ | Large phones | Tablet-ish layouts |
| `md:` | 768px+ | Tablets | 2-column grids |
| `lg:` | 1024px+ | Laptops | 3-column grids |
| `xl:` | 1280px+ | Desktops | Full layouts |
| `2xl:` | 1536px+ | Large screens | Max-width containers |

**Always test at:** 375px, 768px, 1024px, 1440px

---

## Checklist Before Shipping

- [ ] Typography uses distinctive fonts (not Inter/Roboto)
- [ ] Font sizes use `clamp()` for fluid scaling
- [ ] Mobile responsive (tested at 375px)
- [ ] Loading state implemented
- [ ] Error state implemented
- [ ] Empty state designed
- [ ] Keyboard navigation works
- [ ] Focus states visible
- [ ] Color contrast meets WCAG AA (4.5:1)
- [ ] Touch targets 44x44px minimum
- [ ] Semantic HTML (proper heading hierarchy)
- [ ] `prefers-reduced-motion` respected (if animated)
