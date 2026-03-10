# Effects Mode

Premium animations, micro-interactions, and visual effects library.

## Quick Reference: ROI Rankings

Effects ranked by visual impact vs implementation effort:

| Rank | Technique | Impact | Effort | When to Use |
|------|-----------|--------|--------|-------------|
| 1 | Direction-aware hover | High | Medium | Cards, grids, portfolios |
| 2 | Magnetic button | High | Low | Primary CTAs |
| 3 | Staggered text reveal | High | Low | Headlines, hero text |
| 4 | Aurora background | High | Medium | Hero sections, dark themes |
| 5 | Custom cursor | Medium | Low | Creative/portfolio sites |
| 6 | Tracing beam | High | High | Tech/futuristic themes |
| 7 | 3D floating objects | Very High | High | Product showcases |
| 8 | Particle systems | High | High | Backgrounds, transitions |

---

## Restraint Rules

### One Per Viewport
Only ONE of each effect type per visible screen:
- 1 magnetic button
- 1 custom cursor effect
- 1 background effect (aurora OR blob OR particles)
- 1 parallax element
- 1 3D element
- 1 tracing beam

### Duration Guidelines
| Duration | Feels | Use For |
|----------|-------|---------|
| < 200ms | Jarring | Never |
| 200-400ms | Responsive | Micro-interactions, hovers |
| 400-500ms | Deliberate | Reveals, entrances |
| > 500ms | Slow | Avoid (except sequences) |

---

## Animation Techniques

### Staggered Reveal (Hero Text)

```tsx
import { motion } from 'framer-motion';

const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
};

const item = {
  hidden: { opacity: 0, y: 20 },
  show: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5, ease: [0.16, 1, 0.3, 1] }
  }
};

export function StaggeredText({ words }: { words: string[] }) {
  return (
    <motion.h1
      variants={container}
      initial="hidden"
      animate="show"
      className="font-display text-fluid-h1"
    >
      {words.map((word, i) => (
        <motion.span key={i} variants={item} className="inline-block mr-3">
          {word}
        </motion.span>
      ))}
    </motion.h1>
  );
}
```

### Scroll-Triggered Fade

```tsx
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';

export function FadeInOnScroll({ children }: { children: React.ReactNode }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 40 }}
      animate={isInView ? { opacity: 1, y: 0 } : { opacity: 0, y: 40 }}
      transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
    >
      {children}
    </motion.div>
  );
}
```

---

## Micro-Interactions

### Magnetic Button

```tsx
import { motion, useMotionValue, useSpring, useTransform } from 'framer-motion';

export function MagneticButton({ children }: { children: React.ReactNode }) {
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const springX = useSpring(x, { stiffness: 300, damping: 20 });
  const springY = useSpring(y, { stiffness: 300, damping: 20 });

  const handleMouseMove = (e: React.MouseEvent<HTMLButtonElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;

    x.set((e.clientX - centerX) * 0.2);
    y.set((e.clientY - centerY) * 0.2);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.button
      style={{ x: springX, y: springY }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      className="relative rounded-full bg-slate-900 px-8 py-4 text-white"
    >
      {children}
    </motion.button>
  );
}
```

### Direction-Aware Hover

```tsx
import { motion } from 'framer-motion';
import { useState } from 'react';

export function DirectionAwareCard({ children }: { children: React.ReactNode }) {
  const [direction, setDirection] = useState({ x: 0, y: 0 });

  const handleMouseEnter = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left - rect.width / 2;
    const y = e.clientY - rect.top - rect.height / 2;

    // Determine entry direction
    setDirection({
      x: x > 0 ? 1 : -1,
      y: Math.abs(x) > Math.abs(y) ? 0 : y > 0 ? 1 : -1,
    });
  };

  return (
    <motion.div
      className="group relative overflow-hidden rounded-xl"
      onMouseEnter={handleMouseEnter}
    >
      {children}
      <motion.div
        initial={{ x: direction.x * 100 + '%', y: direction.y * 100 + '%' }}
        whileHover={{ x: 0, y: 0 }}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
        className="absolute inset-0 bg-slate-900/80"
      />
    </motion.div>
  );
}
```

---

## Visual Effects

### Aurora Background

```tsx
export function AuroraBackground({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative overflow-hidden bg-slate-950">
      {/* Aurora gradient layers */}
      <div className="absolute inset-0 overflow-hidden">
        <div
          className="absolute -inset-[10%] animate-aurora opacity-50"
          style={{
            background: `
              radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.3) 0%, transparent 50%),
              radial-gradient(circle at 80% 20%, rgba(74, 222, 128, 0.2) 0%, transparent 40%),
              radial-gradient(circle at 40% 80%, rgba(56, 189, 248, 0.2) 0%, transparent 40%)
            `,
          }}
        />
      </div>

      {/* Content */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}

// Add to tailwind.config.js
// animation: { 'aurora': 'aurora 60s linear infinite' }
// keyframes: { aurora: { from: { transform: 'rotate(0deg)' }, to: { transform: 'rotate(360deg)' } } }
```

### Glassmorphism Card

```tsx
export function GlassCard({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative rounded-2xl border border-white/10 bg-white/5 p-6 backdrop-blur-xl">
      {/* Subtle glow */}
      <div className="absolute -inset-px rounded-2xl bg-gradient-to-r from-white/10 to-transparent opacity-0 transition-opacity group-hover:opacity-100" />

      {/* Content */}
      <div className="relative">{children}</div>
    </div>
  );
}
```

---

## 3D Effects (React Three Fiber)

### Floating Element

```tsx
import { Canvas } from '@react-three/fiber';
import { Float, Environment } from '@react-three/drei';

function FloatingShape() {
  return (
    <Float speed={2} rotationIntensity={0.5} floatIntensity={1}>
      <mesh>
        <torusKnotGeometry args={[1, 0.3, 128, 16]} />
        <meshStandardMaterial color="#6366f1" metalness={0.8} roughness={0.2} />
      </mesh>
    </Float>
  );
}

export function FloatingHero() {
  return (
    <div className="h-[600px] w-full">
      <Canvas camera={{ position: [0, 0, 5] }}>
        <Environment preset="city" />
        <ambientLight intensity={0.5} />
        <FloatingShape />
      </Canvas>
    </div>
  );
}
```

---

## Accessibility

### Always Respect Reduced Motion

```tsx
import { useReducedMotion } from 'framer-motion';

export function AccessibleAnimation({ children }: { children: React.ReactNode }) {
  const prefersReducedMotion = useReducedMotion();

  if (prefersReducedMotion) {
    return <div>{children}</div>;
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
    >
      {children}
    </motion.div>
  );
}
```

---

## Stacking Context Debug (2-Round Stop Rule)

**If a CSS property tweak fails twice, STOP adjusting CSS. Check DOM stacking context instead.**

### Common Stacking Context Traps

These parent properties **silently break** `mix-blend-mode`, `z-index`, and `position: fixed`:

| Parent Property | Breaks | Why |
|----------------|--------|-----|
| `transform` (Framer Motion) | mix-blend-mode, z-index | Creates new stacking context |
| `opacity < 1` | mix-blend-mode | Isolates blending |
| `filter` | mix-blend-mode, z-index | Creates new stacking context |
| `will-change` | z-index | Creates new stacking context |
| grid/flex + `z-index` | Layering order | Implicit stacking context |
| `isolation: isolate` | Everything | Explicit isolation |

### Debug Checklist

When effect doesn't render as expected:

```
Round 1: Adjust the CSS property directly
Round 2: Try alternative CSS approach
Round 3 (if both fail): CHECK STACKING CONTEXT:
  [ ] Does any parent have transform? (check Framer Motion)
  [ ] Does any parent have opacity < 1?
  [ ] Does any parent have filter or will-change?
  [ ] Is the element inside a grid/flex item with z-index?
  [ ] Use hot-pink body background to verify blend reaches page level
```

### Hero Image Blending Recipe (Dark Mode)

```css
.hero-blend-wrapper {
  position: absolute; /* MUST be at section root, NOT inside grid/flex/Framer Motion */
  pointer-events: none;
  mix-blend-mode: screen; /* NOT lighten — lighten preserves JPEG halos */
  filter: brightness(0.85) contrast(1.2) saturate(1.1); /* crush near-black artifacts */
  mask-image: radial-gradient(ellipse 55% 55% at 50% 50%, black 15%, transparent 65%);
}
```

> Origin: Tech4All 2026-02-03 — 5+ iterations wasted tweaking CSS properties when root cause was stacking context trapping mix-blend-mode.

### AI Image Generation Spec (for hero images)

When generating hero images for dark mode blending:
- Prompt: "transparent background, no vignette, beams fade to nothing before edges, 3000px+ wide"
- This prevents edge artifacts that no amount of CSS can fix.

---

## Performance Checklist

- [ ] Only animate transform and opacity (no width/height)
- [ ] Use `will-change: transform` sparingly
- [ ] Debounce mouse events (16ms minimum)
- [ ] Test at 60fps on mid-range devices
- [ ] Use `useReducedMotion` hook
- [ ] Lazy load 3D/heavy effects
- [ ] Consider `loading="lazy"` for below-fold effects

---

## Easing Functions

```css
/* Standard - most interactions */
--ease-out: cubic-bezier(0.16, 1, 0.3, 1);

/* Entrance - elements appearing */
--ease-out-expo: cubic-bezier(0.19, 1, 0.22, 1);

/* Bounce - playful brands only */
--ease-bounce: cubic-bezier(0.34, 1.56, 0.64, 1);

/* Smooth - continuous motion */
--ease-smooth: cubic-bezier(0.4, 0, 0.2, 1);
```

In Framer Motion:
```tsx
transition={{ ease: [0.16, 1, 0.3, 1] }}
```

---

## Dependencies

```bash
npm install framer-motion clsx tailwind-merge

# For 3D effects:
npm install @react-three/fiber @react-three/drei three
```
