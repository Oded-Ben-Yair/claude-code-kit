# Gradient Effects - Premium Color Transitions

Full, copy-paste components for animated and static gradient effects.

## 1. Animated Gradient Border

Rotating gradient border effect. Eye-catching for cards.

### The Component

```tsx
// components/AnimatedGradientBorder.tsx
import { cn } from '@/lib/utils';

interface AnimatedGradientBorderProps {
  children: React.ReactNode;
  className?: string;
  containerClassName?: string;
  borderRadius?: string;
  gradientColors?: string[];
}

export function AnimatedGradientBorder({
  children,
  className,
  containerClassName,
  borderRadius = 'rounded-lg',
  gradientColors = ['#ff0080', '#7928ca', '#ff0080'],
}: AnimatedGradientBorderProps) {
  return (
    <div className={cn('relative p-[2px] group', containerClassName)}>
      {/* Animated gradient border */}
      <div
        className={cn(
          'absolute inset-0 opacity-75 group-hover:opacity-100 transition-opacity',
          borderRadius
        )}
        style={{
          background: `linear-gradient(90deg, ${gradientColors.join(', ')})`,
          backgroundSize: '200% 200%',
          animation: 'gradient-rotate 3s linear infinite',
        }}
      />

      {/* Blur glow effect */}
      <div
        className={cn(
          'absolute inset-0 opacity-50 blur-xl group-hover:opacity-75 transition-opacity',
          borderRadius
        )}
        style={{
          background: `linear-gradient(90deg, ${gradientColors.join(', ')})`,
          backgroundSize: '200% 200%',
          animation: 'gradient-rotate 3s linear infinite',
        }}
      />

      {/* Content container */}
      <div className={cn('relative bg-background', borderRadius, className)}>
        {children}
      </div>

      <style jsx global>{`
        @keyframes gradient-rotate {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
      `}</style>
    </div>
  );
}
```

### Usage

```tsx
<AnimatedGradientBorder className="p-6">
  <h3 className="font-semibold">Premium Card</h3>
  <p className="text-muted-foreground">With animated border</p>
</AnimatedGradientBorder>
```

---

## 2. Gradient Button

Button with animated gradient background.

### The Component

```tsx
// components/GradientButton.tsx
import { cn } from '@/lib/utils';

interface GradientButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  children: React.ReactNode;
  variant?: 'default' | 'outline';
}

export function GradientButton({
  children,
  className,
  variant = 'default',
  ...props
}: GradientButtonProps) {
  if (variant === 'outline') {
    return (
      <button
        className={cn(
          'relative px-6 py-3 rounded-lg font-medium',
          'bg-gradient-to-r from-primary via-purple-500 to-pink-500',
          'p-[2px]',
          className
        )}
        {...props}
      >
        <span className="block bg-background rounded-[6px] px-6 py-3 hover:bg-background/90 transition-colors">
          {children}
        </span>
      </button>
    );
  }

  return (
    <button
      className={cn(
        'relative px-8 py-3 rounded-lg font-medium text-white overflow-hidden',
        'bg-gradient-to-r from-primary via-purple-500 to-pink-500',
        'bg-[length:200%_100%] hover:bg-[length:100%_100%]',
        'transition-all duration-500',
        'shadow-lg hover:shadow-xl',
        className
      )}
      style={{
        animation: 'gradient-shift 3s ease infinite',
      }}
      {...props}
    >
      {children}

      <style jsx>{`
        @keyframes gradient-shift {
          0%, 100% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
        }
      `}</style>
    </button>
  );
}
```

---

## 3. Gradient Text (Static & Animated)

### Static Gradient Text

```tsx
// components/GradientText.tsx
import { cn } from '@/lib/utils';

interface GradientTextProps {
  children: React.ReactNode;
  className?: string;
  from?: string;
  via?: string;
  to?: string;
}

export function GradientText({
  children,
  className,
  from = 'from-primary',
  via,
  to = 'to-purple-600',
}: GradientTextProps) {
  return (
    <span
      className={cn(
        'bg-gradient-to-r bg-clip-text text-transparent',
        from,
        via,
        to,
        className
      )}
    >
      {children}
    </span>
  );
}
```

### Animated Gradient Text

```tsx
// components/AnimatedGradientText.tsx
import { cn } from '@/lib/utils';

interface AnimatedGradientTextProps {
  children: React.ReactNode;
  className?: string;
}

export function AnimatedGradientText({
  children,
  className,
}: AnimatedGradientTextProps) {
  return (
    <span
      className={cn(
        'inline-block bg-clip-text text-transparent',
        'bg-gradient-to-r from-primary via-purple-500 to-pink-500',
        'bg-[length:200%_auto]',
        className
      )}
      style={{
        animation: 'gradient-text 3s linear infinite',
      }}
    >
      {children}

      <style jsx>{`
        @keyframes gradient-text {
          0% { background-position: 0% center; }
          100% { background-position: 200% center; }
        }
      `}</style>
    </span>
  );
}
```

---

## 4. Gradient Divider

Animated gradient line divider.

### The Component

```tsx
// components/GradientDivider.tsx
import { cn } from '@/lib/utils';

interface GradientDividerProps {
  className?: string;
  animated?: boolean;
}

export function GradientDivider({
  className,
  animated = true,
}: GradientDividerProps) {
  return (
    <div
      className={cn(
        'h-px w-full',
        'bg-gradient-to-r from-transparent via-primary to-transparent',
        animated && 'bg-[length:200%_100%]',
        className
      )}
      style={animated ? {
        animation: 'gradient-slide 3s linear infinite',
      } : undefined}
    >
      {animated && (
        <style jsx>{`
          @keyframes gradient-slide {
            0% { background-position: -200% 0; }
            100% { background-position: 200% 0; }
          }
        `}</style>
      )}
    </div>
  );
}
```

---

## 5. Gradient Orb

Floating gradient orb for backgrounds.

### The Component

```tsx
// components/GradientOrb.tsx
import { cn } from '@/lib/utils';

interface GradientOrbProps {
  className?: string;
  size?: 'sm' | 'md' | 'lg' | 'xl';
  color?: 'primary' | 'purple' | 'pink' | 'blue';
  blur?: 'sm' | 'md' | 'lg' | 'xl';
  animate?: boolean;
}

export function GradientOrb({
  className,
  size = 'md',
  color = 'primary',
  blur = 'lg',
  animate = true,
}: GradientOrbProps) {
  const sizes = {
    sm: 'w-32 h-32',
    md: 'w-64 h-64',
    lg: 'w-96 h-96',
    xl: 'w-[32rem] h-[32rem]',
  };

  const colors = {
    primary: 'from-primary/40 to-primary/10',
    purple: 'from-purple-500/40 to-purple-500/10',
    pink: 'from-pink-500/40 to-pink-500/10',
    blue: 'from-blue-500/40 to-blue-500/10',
  };

  const blurs = {
    sm: 'blur-xl',
    md: 'blur-2xl',
    lg: 'blur-3xl',
    xl: 'blur-[100px]',
  };

  return (
    <div
      className={cn(
        'absolute rounded-full bg-gradient-to-br',
        sizes[size],
        colors[color],
        blurs[blur],
        animate && 'animate-pulse',
        className
      )}
    />
  );
}
```

### Usage in Background

```tsx
<div className="relative min-h-screen overflow-hidden">
  <GradientOrb
    size="xl"
    color="primary"
    className="top-0 -left-48"
  />
  <GradientOrb
    size="lg"
    color="purple"
    className="bottom-0 -right-32"
  />
  <div className="relative z-10">
    {/* Content */}
  </div>
</div>
```

---

## 6. Gradient Spotlight

Follows cursor or fixed position spotlight effect.

### The Component

```tsx
// components/GradientSpotlight.tsx
'use client';

import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

interface GradientSpotlightProps {
  children: React.ReactNode;
  className?: string;
  followCursor?: boolean;
}

export function GradientSpotlight({
  children,
  className,
  followCursor = true,
}: GradientSpotlightProps) {
  const [position, setPosition] = useState({ x: 50, y: 50 });

  useEffect(() => {
    if (!followCursor) return;

    const handleMouseMove = (e: MouseEvent) => {
      setPosition({
        x: (e.clientX / window.innerWidth) * 100,
        y: (e.clientY / window.innerHeight) * 100,
      });
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, [followCursor]);

  return (
    <div className={cn('relative overflow-hidden', className)}>
      {/* Spotlight */}
      <div
        className="pointer-events-none absolute inset-0 transition-opacity duration-300"
        style={{
          background: `radial-gradient(600px circle at ${position.x}% ${position.y}%, rgba(var(--primary-rgb), 0.15), transparent 40%)`,
        }}
      />

      {/* Content */}
      <div className="relative">{children}</div>
    </div>
  );
}
```

---

## 7. Gradient Card Hover

Card with gradient reveal on hover.

### The Component

```tsx
// components/GradientHoverCard.tsx
import { cn } from '@/lib/utils';

interface GradientHoverCardProps {
  children: React.ReactNode;
  className?: string;
}

export function GradientHoverCard({
  children,
  className,
}: GradientHoverCardProps) {
  return (
    <div
      className={cn(
        'group relative overflow-hidden rounded-xl p-[1px]',
        'bg-gradient-to-br from-transparent via-transparent to-transparent',
        'hover:from-primary hover:via-purple-500 hover:to-pink-500',
        'transition-all duration-500',
        className
      )}
    >
      {/* Inner glow on hover */}
      <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500 blur-xl bg-gradient-to-br from-primary via-purple-500 to-pink-500" />

      {/* Content */}
      <div className="relative bg-card rounded-xl p-6">
        {children}
      </div>
    </div>
  );
}
```

---

## Brand-Specific Gradients

### Seekapa (Professional/Finance)
```tsx
// Deep blue to gold - sophisticated
<GradientText from="from-[#1E3A5F]" to="to-[#D4AF37]">
  Premium Trading
</GradientText>
```

### Futuristic/Tech
```tsx
// Cyan to purple - cutting edge
<GradientText from="from-cyan-400" via="via-blue-500" to="to-purple-600">
  Innovation
</GradientText>
```

### Playful/Creative
```tsx
// Pink to orange - energetic
<GradientText from="from-pink-500" via="via-red-500" to="to-orange-500">
  Create
</GradientText>
```

## Tailwind Config for Gradients

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      animation: {
        'gradient-x': 'gradient-x 3s ease infinite',
        'gradient-y': 'gradient-y 3s ease infinite',
        'gradient-xy': 'gradient-xy 3s ease infinite',
      },
      keyframes: {
        'gradient-x': {
          '0%, 100%': { 'background-position': '0% 50%' },
          '50%': { 'background-position': '100% 50%' },
        },
        'gradient-y': {
          '0%, 100%': { 'background-position': '50% 0%' },
          '50%': { 'background-position': '50% 100%' },
        },
        'gradient-xy': {
          '0%, 100%': { 'background-position': '0% 0%' },
          '25%': { 'background-position': '100% 0%' },
          '50%': { 'background-position': '100% 100%' },
          '75%': { 'background-position': '0% 100%' },
        },
      },
    },
  },
};
```

## Performance Notes

- CSS gradients are GPU-accelerated
- Avoid animating gradient colors directly (animate position instead)
- Use `will-change: background-position` for smoother animations
- Test on mobile - simplify complex gradients if needed
