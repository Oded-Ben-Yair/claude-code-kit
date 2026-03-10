---
name: premium-effects
deprecated: true
replacement: frontend
description: |
  DEPRECATED as standalone skill - Use /frontend skill with effects mode instead.

  This library is now loaded as a sub-resource of the unified /frontend skill.
  Do not invoke directly - use /frontend for the smart router to load appropriate effect files.
allowed-tools: Read
---

# Premium Effects Library

> **DEPRECATED as standalone skill**: Use `/frontend` instead.
> This library is now a sub-resource of the unified frontend skill at `~/.claude/skills/frontend/modes/effects.md`

**Purpose**: Full, copy-paste components for distinctive frontend effects.

## Library Index

### Animations (`animations/`)

| File | Techniques | Best For |
|------|------------|----------|
| `scroll-triggered.md` | Parallax, scroll-linked transforms, reveal on scroll | Content sections, storytelling |
| `entrance-exits.md` | Fade, slide, scale, stagger sequences | Page loads, route transitions |
| `text-animations.md` | Decrypt, shiny, gradient, typewriter, blur reveal | Headlines, hero text |

### Micro-Interactions (`micro-interactions/`)

| File | Techniques | Best For |
|------|------------|----------|
| `hover-effects.md` | Direction-aware, magnetic, wobble, tilt | Cards, grids, interactive elements |
| `cursor-effects.md` | Custom cursor, follower, trails | Portfolio, creative sites |
| `button-effects.md` | Magnetic, glow, ripple, shine | CTAs, primary actions |

### Visual Effects (`visual-effects/`)

| File | Techniques | Best For |
|------|------------|----------|
| `backgrounds.md` | Aurora, blob, particles, grid, beams | Hero sections, features |
| `glassmorphism.md` | Frosted glass, blur layers, noise | Cards, modals, overlays |
| `gradients.md` | Animated, mesh, radial, text gradients | Backgrounds, accents |

### 3D Effects (`3d-effects/`)

| File | Techniques | Best For |
|------|------------|----------|
| `OVERVIEW.md` | R3F setup, performance, best practices | Reference |
| `scenes.md` | Background scenes, environments | Hero, showcase |
| `objects.md` | Floating elements, product showcases | Features, products |
| `particles.md` | 3D particle systems | Backgrounds, transitions |

### Components (`components/`)

| File | Techniques | Best For |
|------|------------|----------|
| `heroes.md` | Full hero compositions | Landing pages |
| `cards.md` | Card systems, grids | Features, team, portfolio |
| `navigation.md` | Nav patterns, mobile menus | Site-wide |

## Quick Start

### 1. Install Dependencies

```bash
npm install framer-motion clsx tailwind-merge
# For 3D effects:
npm install @react-three/fiber @react-three/drei three
```

### 2. Add Utility Functions

```tsx
// lib/utils.ts
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

### 3. Configure Tailwind (if using animations)

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      animation: {
        'aurora': 'aurora 60s linear infinite',
        'shimmer': 'shimmer 2s linear infinite',
      },
      keyframes: {
        aurora: {
          from: { backgroundPosition: '50% 50%, 50% 50%' },
          to: { backgroundPosition: '350% 50%, 350% 50%' },
        },
        shimmer: {
          from: { backgroundPosition: '0 0' },
          to: { backgroundPosition: '-200% 0' },
        },
      },
    },
  },
};
```

## Component Standards

Every component in this library follows these standards:

### Props Interface
```tsx
interface ComponentProps {
  children?: React.ReactNode;
  className?: string;
  // Component-specific props with sensible defaults
}
```

### Accessibility
```tsx
// Always respect reduced motion
const prefersReducedMotion = useReducedMotion();

// Provide static fallback
{prefersReducedMotion ? (
  <StaticVersion />
) : (
  <AnimatedVersion />
)}
```

### Performance
```tsx
// Use transform/opacity only
animate={{ opacity: 1, x: 0 }}  // Good
animate={{ width: '100%' }}     // Avoid

// Debounce mouse events
const handleMouseMove = useMemo(
  () => debounce((e) => setPosition(e), 16),
  []
);
```

## ROI Rankings

Techniques ranked by visual impact vs implementation effort:

| Rank | Technique | Impact | Effort | ROI |
|------|-----------|--------|--------|-----|
| 1 | Direction-aware hover | High | Medium | Very High |
| 2 | Magnetic button | High | Low | Very High |
| 3 | Staggered text reveal | High | Low | Very High |
| 4 | Aurora background | High | Medium | High |
| 5 | Custom cursor | Medium | Low | High |
| 6 | Tracing beam | High | High | Medium |
| 7 | 3D floating objects | Very High | High | Medium |
| 8 | Particle systems | High | High | Medium |

## Usage with Hub Skill

This library is designed to be used with `premium-frontend/SKILL.md`:

1. Hub determines composition based on brand/context
2. Hub identifies which technique files to load
3. You load specific technique files as needed
4. Generate integrated component combining techniques

## File Loading Strategy

Don't load all files at once. Load based on need:

```
User wants: "Futuristic hero section"
           ↓
Load: premium-frontend/SKILL.md (for composition guidance)
      animations/text-animations.md (for headline)
      visual-effects/backgrounds.md (for aurora)
      micro-interactions/button-effects.md (for CTA)
```

## Common Imports

```tsx
// Animation
import { motion, useScroll, useTransform, useSpring } from 'framer-motion';
import { useReducedMotion } from 'framer-motion';

// 3D
import { Canvas } from '@react-three/fiber';
import { Float, Environment, PerspectiveCamera } from '@react-three/drei';

// Utilities
import { cn } from '@/lib/utils';

// Hooks
import { useRef, useState, useEffect, useMemo } from 'react';
```
