# Hover Effects - Premium Micro-Interactions

Full, copy-paste components for distinctive hover interactions.

## 1. Direction-Aware Hover

Reveals content from the direction the cursor enters. High impact for grids.

### When to Use
- Team member cards
- Portfolio grids
- Feature showcases
- Image galleries

### When NOT to Use
- Mobile-only experiences (no hover)
- Dense data tables
- Forms or inputs

### Dependencies
```bash
npm install framer-motion clsx tailwind-merge
```

### The Component

```tsx
// components/DirectionAwareCard.tsx
'use client';

import { useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

type Direction = 'top' | 'bottom' | 'left' | 'right';

interface DirectionAwareCardProps {
  children: React.ReactNode;
  overlay?: React.ReactNode;
  className?: string;
  overlayClassName?: string;
  imageUrl?: string;
}

export function DirectionAwareCard({
  children,
  overlay,
  className,
  overlayClassName,
  imageUrl,
}: DirectionAwareCardProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [direction, setDirection] = useState<Direction>('top');
  const [isHovered, setIsHovered] = useState(false);

  const getDirection = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!ref.current) return 'top';

    const { width, height, left, top } = ref.current.getBoundingClientRect();
    const x = e.clientX - left - width / 2;
    const y = e.clientY - top - height / 2;

    // Determine which edge is closest
    const absX = Math.abs(x);
    const absY = Math.abs(y);

    if (absX > absY) {
      return x > 0 ? 'right' : 'left';
    }
    return y > 0 ? 'bottom' : 'top';
  };

  const handleMouseEnter = (e: React.MouseEvent<HTMLDivElement>) => {
    setDirection(getDirection(e));
    setIsHovered(true);
  };

  const handleMouseLeave = (e: React.MouseEvent<HTMLDivElement>) => {
    setDirection(getDirection(e));
    setIsHovered(false);
  };

  const variants = {
    hidden: (direction: Direction) => ({
      x: direction === 'left' ? '-100%' : direction === 'right' ? '100%' : 0,
      y: direction === 'top' ? '-100%' : direction === 'bottom' ? '100%' : 0,
      opacity: 0,
    }),
    visible: {
      x: 0,
      y: 0,
      opacity: 1,
    },
  };

  return (
    <div
      ref={ref}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      className={cn(
        'relative overflow-hidden rounded-lg group cursor-pointer',
        className
      )}
    >
      {/* Background image or content */}
      {imageUrl && (
        <img
          src={imageUrl}
          alt=""
          className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
      )}

      {/* Main content (visible by default) */}
      <div className="relative z-10">{children}</div>

      {/* Overlay (slides in on hover) */}
      <motion.div
        custom={direction}
        variants={variants}
        initial="hidden"
        animate={isHovered ? 'visible' : 'hidden'}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
        className={cn(
          'absolute inset-0 z-20 flex items-center justify-center',
          'bg-black/80 backdrop-blur-sm',
          overlayClassName
        )}
      >
        {overlay}
      </motion.div>
    </div>
  );
}
```

### Usage Example

```tsx
<div className="grid grid-cols-3 gap-4">
  {team.map((member) => (
    <DirectionAwareCard
      key={member.id}
      imageUrl={member.photo}
      className="aspect-square"
      overlay={
        <div className="text-center text-white p-4">
          <h3 className="text-xl font-semibold">{member.name}</h3>
          <p className="text-white/70">{member.role}</p>
          <div className="flex gap-2 mt-4 justify-center">
            {/* Social links */}
          </div>
        </div>
      }
    >
      {/* Empty or minimal content when not hovered */}
    </DirectionAwareCard>
  ))}
</div>
```

---

## 2. Magnetic Button/Element

Element subtly pulls toward cursor. Use sparingly - one per viewport max.

### When to Use
- Primary CTA buttons
- Key interactive icons
- Navigation items (carefully)

### When NOT to Use
- Multiple buttons in view
- Forms
- Mobile (disable on touch)

### The Component

```tsx
// components/MagneticButton.tsx
'use client';

import { useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface MagneticButtonProps {
  children: React.ReactNode;
  className?: string;
  strength?: number;
  disabled?: boolean;
}

export function MagneticButton({
  children,
  className,
  strength = 0.3,
  disabled = false,
}: MagneticButtonProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [position, setPosition] = useState({ x: 0, y: 0 });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (disabled || !ref.current) return;

    const { left, top, width, height } = ref.current.getBoundingClientRect();
    const centerX = left + width / 2;
    const centerY = top + height / 2;

    const x = (e.clientX - centerX) * strength;
    const y = (e.clientY - centerY) * strength;

    setPosition({ x, y });
  };

  const handleMouseLeave = () => {
    setPosition({ x: 0, y: 0 });
  };

  return (
    <motion.div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      animate={{ x: position.x, y: position.y }}
      transition={{ type: 'spring', stiffness: 150, damping: 15, mass: 0.1 }}
      className={cn('inline-block', className)}
    >
      {children}
    </motion.div>
  );
}
```

### Usage with Button

```tsx
<MagneticButton strength={0.4}>
  <button className="px-8 py-4 bg-primary text-white rounded-full font-semibold
                     hover:bg-primary/90 transition-colors">
    Get Started
  </button>
</MagneticButton>
```

---

## 3. Wobble Card

Subtle 3D tilt effect based on cursor position. Good for feature cards.

### When to Use
- Feature cards
- Pricing cards
- Product showcases

### The Component

```tsx
// components/WobbleCard.tsx
'use client';

import { useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface WobbleCardProps {
  children: React.ReactNode;
  className?: string;
  intensity?: number;
}

export function WobbleCard({
  children,
  className,
  intensity = 10,
}: WobbleCardProps) {
  const ref = useRef<HTMLDivElement>(null);
  const [rotateX, setRotateX] = useState(0);
  const [rotateY, setRotateY] = useState(0);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!ref.current) return;

    const { left, top, width, height } = ref.current.getBoundingClientRect();
    const x = (e.clientX - left) / width;
    const y = (e.clientY - top) / height;

    setRotateX((y - 0.5) * -intensity);
    setRotateY((x - 0.5) * intensity);
  };

  const handleMouseLeave = () => {
    setRotateX(0);
    setRotateY(0);
  };

  return (
    <motion.div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      animate={{ rotateX, rotateY }}
      transition={{ type: 'spring', stiffness: 300, damping: 30 }}
      style={{ transformStyle: 'preserve-3d', perspective: 1000 }}
      className={cn('cursor-pointer', className)}
    >
      <div style={{ transform: 'translateZ(20px)' }}>{children}</div>
    </motion.div>
  );
}
```

---

## 4. Scale Lift Hover

Simple but effective - subtle scale + shadow on hover. The safest premium option.

### When to Use
- Any card that needs subtle interactivity
- Grid items
- Navigation cards

### The Component (CSS-only, no JS needed)

```tsx
// Pure Tailwind, no additional component needed
<div className="
  group
  transition-all duration-300 ease-out
  hover:scale-[1.02] hover:-translate-y-1
  hover:shadow-lg hover:shadow-black/5
  rounded-lg bg-white p-6
">
  <h3 className="font-semibold group-hover:text-primary transition-colors">
    Card Title
  </h3>
  <p className="text-muted-foreground mt-2">
    Card description goes here.
  </p>
</div>
```

### With Framer Motion (more control)

```tsx
<motion.div
  whileHover={{
    scale: 1.02,
    y: -4,
    transition: { duration: 0.3, ease: [0.16, 1, 0.3, 1] }
  }}
  className="rounded-lg bg-white p-6 shadow-md hover:shadow-lg"
>
  {/* Content */}
</motion.div>
```

---

## 5. Border Gradient Hover

Animated gradient border on hover. Works well for cards and buttons.

### The Component

```tsx
// components/GradientBorderCard.tsx
'use client';

import { cn } from '@/lib/utils';

interface GradientBorderCardProps {
  children: React.ReactNode;
  className?: string;
  gradientFrom?: string;
  gradientTo?: string;
}

export function GradientBorderCard({
  children,
  className,
  gradientFrom = 'from-primary',
  gradientTo = 'to-accent',
}: GradientBorderCardProps) {
  return (
    <div className={cn('group relative p-[1px] rounded-lg', className)}>
      {/* Gradient border - visible on hover */}
      <div className={cn(
        'absolute inset-0 rounded-lg opacity-0 group-hover:opacity-100',
        'transition-opacity duration-300',
        'bg-gradient-to-r', gradientFrom, gradientTo
      )} />

      {/* Animated gradient position on hover */}
      <div className={cn(
        'absolute inset-0 rounded-lg opacity-0 group-hover:opacity-100',
        'transition-opacity duration-300 blur-xl',
        'bg-gradient-to-r', gradientFrom, gradientTo
      )} />

      {/* Content */}
      <div className="relative bg-background rounded-lg p-6">
        {children}
      </div>
    </div>
  );
}
```

---

## Mobile Considerations

All hover effects should be disabled or simplified on mobile:

```tsx
// hooks/useIsMobile.ts
import { useEffect, useState } from 'react';

export function useIsMobile() {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768);
    check();
    window.addEventListener('resize', check);
    return () => window.removeEventListener('resize', check);
  }, []);

  return isMobile;
}

// Usage in components
const isMobile = useIsMobile();

// Disable hover effects on mobile
{!isMobile && <DirectionAwareCard ... />}
{isMobile && <SimpleCard ... />}
```

## Accessibility

Always respect reduced motion preferences:

```tsx
import { useReducedMotion } from 'framer-motion';

function Component() {
  const prefersReducedMotion = useReducedMotion();

  if (prefersReducedMotion) {
    return <StaticVersion />;
  }

  return <AnimatedVersion />;
}
```
