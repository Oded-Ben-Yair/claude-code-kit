# Scroll-Triggered Animations

Premium scroll-based animations using Framer Motion's `useInView` and `useScroll` hooks.

## Dependencies

```bash
npm install framer-motion
```

---

## 1. Fade In On Scroll

Basic scroll reveal with customizable direction.

```tsx
// components/animations/FadeInOnScroll.tsx
'use client';

import { motion, useInView } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface FadeInOnScrollProps {
  children: ReactNode;
  direction?: 'up' | 'down' | 'left' | 'right' | 'none';
  delay?: number;
  duration?: number;
  distance?: number;
  once?: boolean;
  className?: string;
}

export function FadeInOnScroll({
  children,
  direction = 'up',
  delay = 0,
  duration = 0.6,
  distance = 40,
  once = true,
  className,
}: FadeInOnScrollProps) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once, margin: '-100px' });

  const directions = {
    up: { y: distance, x: 0 },
    down: { y: -distance, x: 0 },
    left: { x: distance, y: 0 },
    right: { x: -distance, y: 0 },
    none: { x: 0, y: 0 },
  };

  return (
    <motion.div
      ref={ref}
      initial={{
        opacity: 0,
        ...directions[direction],
      }}
      animate={{
        opacity: isInView ? 1 : 0,
        x: isInView ? 0 : directions[direction].x,
        y: isInView ? 0 : directions[direction].y,
      }}
      transition={{
        duration,
        delay,
        ease: [0.16, 1, 0.3, 1],
      }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
```

### Usage

```tsx
<FadeInOnScroll direction="up" delay={0.1}>
  <h2>Section Title</h2>
</FadeInOnScroll>

<FadeInOnScroll direction="left" delay={0.2}>
  <p>Content that slides in from the right</p>
</FadeInOnScroll>
```

---

## 2. Staggered Children On Scroll

Container that staggers its children as they enter view.

```tsx
// components/animations/StaggerOnScroll.tsx
'use client';

import { motion, useInView, Variants } from 'framer-motion';
import { useRef, ReactNode, Children } from 'react';

interface StaggerOnScrollProps {
  children: ReactNode;
  staggerDelay?: number;
  duration?: number;
  once?: boolean;
  className?: string;
}

const containerVariants: Variants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const itemVariants: Variants = {
  hidden: {
    opacity: 0,
    y: 30,
    filter: 'blur(10px)',
  },
  visible: {
    opacity: 1,
    y: 0,
    filter: 'blur(0px)',
    transition: {
      duration: 0.6,
      ease: [0.16, 1, 0.3, 1],
    },
  },
};

export function StaggerOnScroll({
  children,
  staggerDelay = 0.1,
  duration = 0.6,
  once = true,
  className,
}: StaggerOnScrollProps) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once, margin: '-50px' });

  const customContainerVariants: Variants = {
    hidden: {},
    visible: {
      transition: {
        staggerChildren: staggerDelay,
      },
    },
  };

  const customItemVariants: Variants = {
    hidden: {
      opacity: 0,
      y: 30,
      filter: 'blur(10px)',
    },
    visible: {
      opacity: 1,
      y: 0,
      filter: 'blur(0px)',
      transition: {
        duration,
        ease: [0.16, 1, 0.3, 1],
      },
    },
  };

  return (
    <motion.div
      ref={ref}
      variants={customContainerVariants}
      initial="hidden"
      animate={isInView ? 'visible' : 'hidden'}
      className={className}
    >
      {Children.map(children, (child) => (
        <motion.div variants={customItemVariants}>{child}</motion.div>
      ))}
    </motion.div>
  );
}
```

### Usage

```tsx
<StaggerOnScroll staggerDelay={0.15} className="grid grid-cols-3 gap-6">
  <FeatureCard title="Feature 1" />
  <FeatureCard title="Feature 2" />
  <FeatureCard title="Feature 3" />
</StaggerOnScroll>
```

---

## 3. Scroll Progress Bar

Shows reading progress at top of page.

```tsx
// components/animations/ScrollProgressBar.tsx
'use client';

import { motion, useScroll, useSpring } from 'framer-motion';

interface ScrollProgressBarProps {
  color?: string;
  height?: number;
  className?: string;
}

export function ScrollProgressBar({
  color = '#3B82F6',
  height = 3,
  className,
}: ScrollProgressBarProps) {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001,
  });

  return (
    <motion.div
      className={`fixed top-0 left-0 right-0 z-50 origin-left ${className}`}
      style={{
        scaleX,
        height,
        backgroundColor: color,
      }}
    />
  );
}
```

### Gradient Progress Bar

```tsx
// components/animations/GradientScrollProgress.tsx
'use client';

import { motion, useScroll, useSpring } from 'framer-motion';

export function GradientScrollProgress() {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001,
  });

  return (
    <motion.div
      className="fixed top-0 left-0 right-0 z-50 h-1 origin-left"
      style={{
        scaleX,
        background: 'linear-gradient(90deg, #3B82F6 0%, #8B5CF6 50%, #EC4899 100%)',
      }}
    />
  );
}
```

---

## 4. Parallax On Scroll

Elements that move at different speeds.

```tsx
// components/animations/ParallaxOnScroll.tsx
'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface ParallaxOnScrollProps {
  children: ReactNode;
  speed?: number; // Positive = moves up, negative = moves down
  className?: string;
}

export function ParallaxOnScroll({
  children,
  speed = 0.5,
  className,
}: ParallaxOnScrollProps) {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'],
  });

  const y = useTransform(scrollYProgress, [0, 1], [100 * speed, -100 * speed]);

  return (
    <div ref={ref} className={`overflow-hidden ${className}`}>
      <motion.div style={{ y }}>{children}</motion.div>
    </div>
  );
}
```

### Usage

```tsx
<section className="relative min-h-screen">
  <ParallaxOnScroll speed={0.3}>
    <img src="/bg-layer-1.png" className="absolute inset-0" />
  </ParallaxOnScroll>

  <ParallaxOnScroll speed={0.6}>
    <img src="/bg-layer-2.png" className="absolute inset-0" />
  </ParallaxOnScroll>

  <div className="relative z-10">
    <h1>Content stays fixed</h1>
  </div>
</section>
```

---

## 5. Scale On Scroll

Element scales based on scroll position.

```tsx
// components/animations/ScaleOnScroll.tsx
'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface ScaleOnScrollProps {
  children: ReactNode;
  scaleRange?: [number, number];
  className?: string;
}

export function ScaleOnScroll({
  children,
  scaleRange = [0.8, 1],
  className,
}: ScaleOnScrollProps) {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'center center'],
  });

  const scale = useTransform(scrollYProgress, [0, 1], scaleRange);
  const opacity = useTransform(scrollYProgress, [0, 0.5], [0, 1]);

  return (
    <motion.div
      ref={ref}
      style={{ scale, opacity }}
      className={className}
    >
      {children}
    </motion.div>
  );
}
```

---

## 6. Reveal On Scroll (Clip Path)

Reveals content with a clip-path animation.

```tsx
// components/animations/RevealOnScroll.tsx
'use client';

import { motion, useInView } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface RevealOnScrollProps {
  children: ReactNode;
  direction?: 'up' | 'down' | 'left' | 'right';
  duration?: number;
  delay?: number;
  once?: boolean;
  className?: string;
}

export function RevealOnScroll({
  children,
  direction = 'up',
  duration = 0.8,
  delay = 0,
  once = true,
  className,
}: RevealOnScrollProps) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once, margin: '-100px' });

  const clipPaths = {
    up: {
      hidden: 'inset(100% 0% 0% 0%)',
      visible: 'inset(0% 0% 0% 0%)',
    },
    down: {
      hidden: 'inset(0% 0% 100% 0%)',
      visible: 'inset(0% 0% 0% 0%)',
    },
    left: {
      hidden: 'inset(0% 100% 0% 0%)',
      visible: 'inset(0% 0% 0% 0%)',
    },
    right: {
      hidden: 'inset(0% 0% 0% 100%)',
      visible: 'inset(0% 0% 0% 0%)',
    },
  };

  return (
    <div ref={ref} className={`overflow-hidden ${className}`}>
      <motion.div
        initial={{ clipPath: clipPaths[direction].hidden }}
        animate={{
          clipPath: isInView
            ? clipPaths[direction].visible
            : clipPaths[direction].hidden,
        }}
        transition={{
          duration,
          delay,
          ease: [0.16, 1, 0.3, 1],
        }}
      >
        {children}
      </motion.div>
    </div>
  );
}
```

---

## 7. Counter On Scroll

Animated number counter when in view.

```tsx
// components/animations/CounterOnScroll.tsx
'use client';

import { motion, useInView, useMotionValue, useTransform, animate } from 'framer-motion';
import { useRef, useEffect } from 'react';

interface CounterOnScrollProps {
  from?: number;
  to: number;
  duration?: number;
  decimals?: number;
  prefix?: string;
  suffix?: string;
  once?: boolean;
  className?: string;
}

export function CounterOnScroll({
  from = 0,
  to,
  duration = 2,
  decimals = 0,
  prefix = '',
  suffix = '',
  once = true,
  className,
}: CounterOnScrollProps) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once, margin: '-100px' });
  const count = useMotionValue(from);
  const rounded = useTransform(count, (latest) =>
    latest.toFixed(decimals)
  );

  useEffect(() => {
    if (isInView) {
      const controls = animate(count, to, {
        duration,
        ease: 'easeOut',
      });
      return controls.stop;
    }
  }, [isInView, count, to, duration]);

  return (
    <span ref={ref} className={className}>
      {prefix}
      <motion.span>{rounded}</motion.span>
      {suffix}
    </span>
  );
}
```

### Usage

```tsx
<div className="grid grid-cols-3 gap-8">
  <div>
    <CounterOnScroll to={99.9} decimals={1} suffix="%" className="text-4xl font-bold" />
    <p>Accuracy</p>
  </div>
  <div>
    <CounterOnScroll to={10000} suffix="+" className="text-4xl font-bold" />
    <p>Users</p>
  </div>
  <div>
    <CounterOnScroll prefix="$" to={2.5} decimals={1} suffix="M" className="text-4xl font-bold" />
    <p>Revenue</p>
  </div>
</div>
```

---

## 8. Scroll-Linked Rotation

Elements rotate based on scroll position.

```tsx
// components/animations/RotateOnScroll.tsx
'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface RotateOnScrollProps {
  children: ReactNode;
  rotationRange?: [number, number];
  className?: string;
}

export function RotateOnScroll({
  children,
  rotationRange = [0, 360],
  className,
}: RotateOnScrollProps) {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'],
  });

  const rotate = useTransform(scrollYProgress, [0, 1], rotationRange);

  return (
    <motion.div ref={ref} style={{ rotate }} className={className}>
      {children}
    </motion.div>
  );
}
```

---

## 9. Horizontal Scroll Section

Full-width horizontal scrolling section.

```tsx
// components/animations/HorizontalScroll.tsx
'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface HorizontalScrollProps {
  children: ReactNode;
  className?: string;
}

export function HorizontalScroll({ children, className }: HorizontalScrollProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: containerRef,
  });

  const x = useTransform(scrollYProgress, [0, 1], ['0%', '-75%']);

  return (
    <section ref={containerRef} className="relative h-[300vh]">
      <div className="sticky top-0 h-screen flex items-center overflow-hidden">
        <motion.div style={{ x }} className={`flex gap-8 ${className}`}>
          {children}
        </motion.div>
      </div>
    </section>
  );
}
```

### Usage

```tsx
<HorizontalScroll>
  <div className="w-[80vw] h-[60vh] bg-blue-500 rounded-xl shrink-0" />
  <div className="w-[80vw] h-[60vh] bg-purple-500 rounded-xl shrink-0" />
  <div className="w-[80vw] h-[60vh] bg-pink-500 rounded-xl shrink-0" />
  <div className="w-[80vw] h-[60vh] bg-green-500 rounded-xl shrink-0" />
</HorizontalScroll>
```

---

## 10. Text Line Reveal

Reveals text line by line as user scrolls.

```tsx
// components/animations/TextLineReveal.tsx
'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef } from 'react';

interface TextLineRevealProps {
  text: string;
  className?: string;
}

export function TextLineReveal({ text, className }: TextLineRevealProps) {
  const ref = useRef(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start 0.9', 'start 0.25'],
  });

  const words = text.split(' ');

  return (
    <p ref={ref} className={`flex flex-wrap ${className}`}>
      {words.map((word, i) => {
        const start = i / words.length;
        const end = start + 1 / words.length;
        return (
          <Word key={i} progress={scrollYProgress} range={[start, end]}>
            {word}
          </Word>
        );
      })}
    </p>
  );
}

interface WordProps {
  children: string;
  progress: any;
  range: [number, number];
}

function Word({ children, progress, range }: WordProps) {
  const opacity = useTransform(progress, range, [0.2, 1]);

  return (
    <span className="relative mr-2 mt-2">
      <span className="absolute opacity-20">{children}</span>
      <motion.span style={{ opacity }}>{children}</motion.span>
    </span>
  );
}
```

---

## 11. Scroll Snap Sections

Full-page sections with scroll snapping.

```tsx
// components/animations/ScrollSnapContainer.tsx
'use client';

import { ReactNode } from 'react';

interface ScrollSnapContainerProps {
  children: ReactNode;
}

export function ScrollSnapContainer({ children }: ScrollSnapContainerProps) {
  return (
    <div className="h-screen overflow-y-auto snap-y snap-mandatory">
      {children}
    </div>
  );
}

interface ScrollSnapSectionProps {
  children: ReactNode;
  className?: string;
}

export function ScrollSnapSection({ children, className }: ScrollSnapSectionProps) {
  return (
    <section className={`h-screen snap-start snap-always ${className}`}>
      {children}
    </section>
  );
}
```

### Usage

```tsx
<ScrollSnapContainer>
  <ScrollSnapSection className="bg-blue-500 flex items-center justify-center">
    <h1 className="text-6xl text-white">Section 1</h1>
  </ScrollSnapSection>

  <ScrollSnapSection className="bg-purple-500 flex items-center justify-center">
    <h1 className="text-6xl text-white">Section 2</h1>
  </ScrollSnapSection>

  <ScrollSnapSection className="bg-pink-500 flex items-center justify-center">
    <h1 className="text-6xl text-white">Section 3</h1>
  </ScrollSnapSection>
</ScrollSnapContainer>
```

---

## 12. Tracing Beam

SVG line that traces as user scrolls.

```tsx
// components/animations/TracingBeam.tsx
'use client';

import { motion, useScroll, useTransform } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface TracingBeamProps {
  children: ReactNode;
  className?: string;
}

export function TracingBeam({ children, className }: TracingBeamProps) {
  const ref = useRef<HTMLDivElement>(null);
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start start', 'end end'],
  });

  const pathLength = useTransform(scrollYProgress, [0, 1], [0, 1]);
  const opacity = useTransform(scrollYProgress, [0, 0.05], [0, 1]);

  return (
    <div ref={ref} className={`relative ${className}`}>
      {/* Tracing line */}
      <div className="absolute left-8 top-0 bottom-0 w-px">
        {/* Background line */}
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-gray-300 to-transparent dark:via-gray-700" />

        {/* Animated line */}
        <motion.div
          className="absolute top-0 left-0 w-full bg-gradient-to-b from-blue-500 via-purple-500 to-pink-500"
          style={{
            height: '100%',
            scaleY: pathLength,
            opacity,
            transformOrigin: 'top',
          }}
        />

        {/* Glow dot */}
        <motion.div
          className="absolute left-1/2 -translate-x-1/2 w-4 h-4 bg-blue-500 rounded-full shadow-lg shadow-blue-500/50"
          style={{
            top: useTransform(scrollYProgress, [0, 1], ['0%', '100%']),
            opacity,
          }}
        />
      </div>

      {/* Content */}
      <div className="pl-20">{children}</div>
    </div>
  );
}
```

### Usage

```tsx
<TracingBeam>
  <div className="space-y-24">
    <section className="py-12">
      <h2 className="text-2xl font-bold">Step 1</h2>
      <p>Description of step 1...</p>
    </section>

    <section className="py-12">
      <h2 className="text-2xl font-bold">Step 2</h2>
      <p>Description of step 2...</p>
    </section>

    <section className="py-12">
      <h2 className="text-2xl font-bold">Step 3</h2>
      <p>Description of step 3...</p>
    </section>
  </div>
</TracingBeam>
```

---

## Accessibility

All scroll animations should respect `prefers-reduced-motion`:

```tsx
// hooks/useReducedMotion.ts
import { useEffect, useState } from 'react';

export function useReducedMotion() {
  const [prefersReducedMotion, setPrefersReducedMotion] = useState(false);

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    setPrefersReducedMotion(mediaQuery.matches);

    const handler = (e: MediaQueryListEvent) => {
      setPrefersReducedMotion(e.matches);
    };

    mediaQuery.addEventListener('change', handler);
    return () => mediaQuery.removeEventListener('change', handler);
  }, []);

  return prefersReducedMotion;
}

// Usage in components
function AccessibleFadeIn({ children }) {
  const prefersReducedMotion = useReducedMotion();

  if (prefersReducedMotion) {
    return <div>{children}</div>;
  }

  return <FadeInOnScroll>{children}</FadeInOnScroll>;
}
```

---

## Performance Tips

1. **Use `will-change` sparingly** - Only on elements about to animate
2. **Animate `transform` and `opacity` only** - These are GPU-accelerated
3. **Throttle scroll listeners** - Framer Motion handles this automatically
4. **Use `once: true`** - Prevents re-triggering animations
5. **Avoid animating layout properties** - `width`, `height`, `top`, `left` cause reflows
6. **Test on mobile** - Scroll animations can be janky on low-end devices
