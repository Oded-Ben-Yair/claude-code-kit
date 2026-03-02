# Typography System Reference

Typography is the #1 differentiator between "AI slop" and distinctive design. This reference contains everything needed for professional typography.

## The 5 Core Techniques

### 1. Distinctive Fonts

**Never use**: Inter, Roboto, Arial, Helvetica (overused = signals AI)

**Recommended Sans-Serif:**
| Font | Character | Best For |
|------|-----------|----------|
| Bricolage Grotesque | Playful, modern | Creative brands, startups |
| Space Grotesk | Tech, futuristic | SaaS, developer tools |
| DM Sans | Clean, geometric | Minimal, corporate |
| Satoshi | Contemporary | Modern brands |
| General Sans | Versatile | General use |

**Recommended Serif:**
| Font | Character | Best For |
|------|-----------|----------|
| Newsreader | Readable, warm | Body text, articles |
| Playfair Display | Elegant, editorial | Headlines, luxury |
| DM Serif Display | Modern classic | Display text |
| Source Serif 4 | Professional | Long-form content |

**Recommended Display:**
| Font | Character | Best For |
|------|-----------|----------|
| Instrument Serif | Dramatic | Hero headlines |
| Cabinet Grotesk | Bold, impactful | Large text |
| Clash Display | Geometric | Tech headlines |

---

### 2. Font Pairing

**Rule**: Pair serif + sans for hierarchy, or two sans from different families.

| Pairing | Feel | Use Case |
|---------|------|----------|
| Playfair Display + Source Sans 3 | Elegant | Luxury, editorial |
| Space Grotesk + Source Sans 3 | Tech | SaaS, developer |
| Bricolage Grotesque + Newsreader | Playful | Creative, startup |
| DM Serif Display + DM Sans | Cohesive | Modern minimal |
| IBM Plex Sans + IBM Plex Serif | Corporate | Enterprise, B2B |
| Instrument Serif + General Sans | Editorial | Magazine, content |

**Implementation:**
```css
/* Headings */
font-family: 'Bricolage Grotesque', sans-serif;

/* Body */
font-family: 'Newsreader', serif;
```

---

### 3. Fluid Typography

**Never**: Fixed breakpoints (text-4xl → text-6xl)
**Always**: CSS `clamp()` for smooth scaling

**Formula**: `clamp(min, preferred, max)`

| Element | Clamp Value | Rendered |
|---------|-------------|----------|
| h1 | `clamp(2.5rem, 5vw + 1rem, 5rem)` | 40px → 80px |
| h2 | `clamp(1.875rem, 3vw + 1rem, 3rem)` | 30px → 48px |
| h3 | `clamp(1.5rem, 2vw + 0.75rem, 2rem)` | 24px → 32px |
| body | `clamp(1rem, 0.25vw + 0.9rem, 1.125rem)` | 16px → 18px |
| small | `clamp(0.875rem, 0.5vw + 0.75rem, 1rem)` | 14px → 16px |

**Tailwind config:**
```javascript
fontSize: {
  'fluid-h1': 'clamp(2.5rem, 5vw + 1rem, 5rem)',
  'fluid-h2': 'clamp(1.875rem, 3vw + 1rem, 3rem)',
  'fluid-h3': 'clamp(1.5rem, 2vw + 0.75rem, 2rem)',
  'fluid-body': 'clamp(1rem, 0.25vw + 0.9rem, 1.125rem)',
  'fluid-small': 'clamp(0.875rem, 0.5vw + 0.75rem, 1rem)',
}
```

---

### 4. Variable Font Weights

**Never**: `font-weight: bold` (imprecise)
**Always**: Exact numeric weights

| Intent | Generic | Better |
|--------|---------|--------|
| Light | 300 | 385 |
| Normal | 400 | 465 |
| Medium | 500 | 535 |
| Semibold | 600 | 615 |
| Bold | 700 | 685 |
| Heavy | 800 | 765 |

**Tailwind config:**
```javascript
fontWeight: {
  'thin': '285',
  'light': '385',
  'normal': '465',
  'medium': '535',
  'semibold': '615',
  'bold': '685',
  'extrabold': '765',
}
```

---

### 5. OpenType Features

Activate typographic polish for display text:

| Feature | Code | Effect |
|---------|------|--------|
| Stylistic Set 1 | `ss01` | Alternative letterforms |
| Ligatures | `liga` | Connected letter pairs |
| Old-style Numerals | `onum` | Text-appropriate numbers |
| Tabular Numerals | `tnum` | Aligned numbers (tables) |
| Small Caps | `smcp` | Small capital letters |
| Fractions | `frac` | Proper fractions |

**CSS Implementation:**
```css
.heading {
  font-feature-settings: 'ss01' on, 'liga' on;
}

.numbers-text {
  font-feature-settings: 'onum' on;
}

.numbers-table {
  font-feature-settings: 'tnum' on;
}
```

**Tailwind (custom classes):**
```javascript
// tailwind.config.js
plugins: [
  function({ addUtilities }) {
    addUtilities({
      '.font-feature-ss01': { 'font-feature-settings': '"ss01" on' },
      '.font-feature-liga': { 'font-feature-settings': '"liga" on' },
      '.font-feature-onum': { 'font-feature-settings': '"onum" on' },
      '.font-feature-tnum': { 'font-feature-settings': '"tnum" on' },
    })
  }
]
```

---

## Complete Tailwind Configuration

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      fontFamily: {
        display: ['Bricolage Grotesque', 'sans-serif'],
        body: ['Newsreader', 'serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        'fluid-h1': ['clamp(2.5rem, 5vw + 1rem, 5rem)', { lineHeight: '1.1' }],
        'fluid-h2': ['clamp(1.875rem, 3vw + 1rem, 3rem)', { lineHeight: '1.2' }],
        'fluid-h3': ['clamp(1.5rem, 2vw + 0.75rem, 2rem)', { lineHeight: '1.3' }],
        'fluid-body': ['clamp(1rem, 0.25vw + 0.9rem, 1.125rem)', { lineHeight: '1.6' }],
        'fluid-small': ['clamp(0.875rem, 0.5vw + 0.75rem, 1rem)', { lineHeight: '1.5' }],
      },
      fontWeight: {
        'thin': '285',
        'light': '385',
        'normal': '465',
        'medium': '535',
        'semibold': '615',
        'bold': '685',
        'extrabold': '765',
      },
      letterSpacing: {
        'tighter': '-0.03em',
        'tight': '-0.02em',
        'normal': '0',
        'wide': '0.02em',
        'wider': '0.04em',
      },
    },
  },
}
```

---

## Google Fonts Import

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@300..800&family=Newsreader:opsz,wght@6..72,300..800&display=swap" rel="stylesheet">
```

Or in CSS:
```css
@import url('https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:wght@300..800&family=Newsreader:opsz,wght@6..72,300..800&display=swap');
```

---

## Typography Checklist

- [ ] Using distinctive fonts (not Inter/Roboto/Arial)
- [ ] Proper serif/sans pairing for hierarchy
- [ ] Fluid typography with `clamp()`
- [ ] Exact font weights (not just bold/normal)
- [ ] OpenType features on display text
- [ ] Line height appropriate (1.1-1.2 headings, 1.5-1.6 body)
- [ ] Letter spacing adjusted for large text (negative) and small caps (positive)
