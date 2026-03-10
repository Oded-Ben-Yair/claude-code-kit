# Button Effects

Premium button animations and micro-interactions. Copy-paste ready components.

## Dependencies

```bash
npm install framer-motion
```

---

## 1. Magnetic Button

Button that follows cursor within its bounds.

```tsx
// components/buttons/MagneticButton.tsx
'use client';

import { motion, useMotionValue, useSpring } from 'framer-motion';
import { useRef, ReactNode } from 'react';

interface MagneticButtonProps {
  children: ReactNode;
  className?: string;
  strength?: number;
  onClick?: () => void;
}

export function MagneticButton({
  children,
  className = '',
  strength = 0.3,
  onClick,
}: MagneticButtonProps) {
  const ref = useRef<HTMLButtonElement>(null);

  const x = useMotionValue(0);
  const y = useMotionValue(0);

  const springConfig = { damping: 15, stiffness: 150 };
  const springX = useSpring(x, springConfig);
  const springY = useSpring(y, springConfig);

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!ref.current) return;

    const rect = ref.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;

    x.set((e.clientX - centerX) * strength);
    y.set((e.clientY - centerY) * strength);
  };

  const handleMouseLeave = () => {
    x.set(0);
    y.set(0);
  };

  return (
    <motion.button
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      onClick={onClick}
      style={{ x: springX, y: springY }}
      className={className}
    >
      {children}
    </motion.button>
  );
}
```

### Styled Magnetic Button

```tsx
// components/buttons/MagneticGradientButton.tsx
'use client';

import { MagneticButton } from './MagneticButton';

interface MagneticGradientButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
}

export function MagneticGradientButton({
  children,
  onClick,
}: MagneticGradientButtonProps) {
  return (
    <MagneticButton
      onClick={onClick}
      className="relative px-8 py-4 rounded-xl font-semibold text-white overflow-hidden group"
    >
      {/* Gradient background */}
      <span className="absolute inset-0 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500" />

      {/* Glow effect on hover */}
      <span className="absolute inset-0 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 opacity-0 group-hover:opacity-100 blur-xl transition-opacity duration-300" />

      {/* Content */}
      <span className="relative">{children}</span>
    </MagneticButton>
  );
}
```

---

## 2. Ripple Button

Material-style ripple effect on click.

```tsx
// components/buttons/RippleButton.tsx
'use client';

import { useState, ReactNode, MouseEvent } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface Ripple {
  id: number;
  x: number;
  y: number;
}

interface RippleButtonProps {
  children: ReactNode;
  className?: string;
  rippleColor?: string;
  onClick?: () => void;
}

export function RippleButton({
  children,
  className = '',
  rippleColor = 'rgba(255, 255, 255, 0.4)',
  onClick,
}: RippleButtonProps) {
  const [ripples, setRipples] = useState<Ripple[]>([]);

  const handleClick = (e: MouseEvent<HTMLButtonElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const newRipple: Ripple = {
      id: Date.now(),
      x,
      y,
    };

    setRipples((prev) => [...prev, newRipple]);

    // Remove ripple after animation
    setTimeout(() => {
      setRipples((prev) => prev.filter((r) => r.id !== newRipple.id));
    }, 600);

    onClick?.();
  };

  return (
    <button
      onClick={handleClick}
      className={`relative overflow-hidden ${className}`}
    >
      {children}

      <AnimatePresence>
        {ripples.map((ripple) => (
          <motion.span
            key={ripple.id}
            initial={{ scale: 0, opacity: 1 }}
            animate={{ scale: 4, opacity: 0 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.6, ease: 'easeOut' }}
            className="absolute rounded-full pointer-events-none"
            style={{
              left: ripple.x,
              top: ripple.y,
              width: 100,
              height: 100,
              marginLeft: -50,
              marginTop: -50,
              backgroundColor: rippleColor,
            }}
          />
        ))}
      </AnimatePresence>
    </button>
  );
}
```

### Usage

```tsx
<RippleButton
  className="px-6 py-3 bg-blue-500 text-white rounded-lg font-medium"
  onClick={() => console.log('Clicked!')}
>
  Click Me
</RippleButton>
```

---

## 3. Shine Button

Animated shine/shimmer effect on hover.

```tsx
// components/buttons/ShineButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface ShineButtonProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function ShineButton({
  children,
  className = '',
  onClick,
}: ShineButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative overflow-hidden group ${className}`}
      whileHover="hover"
      whileTap={{ scale: 0.98 }}
    >
      {children}

      {/* Shine effect */}
      <motion.div
        className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full"
        variants={{
          hover: {
            translateX: '200%',
            transition: {
              duration: 0.6,
              ease: 'easeInOut',
            },
          },
        }}
      />
    </motion.button>
  );
}
```

### Usage

```tsx
<ShineButton className="px-8 py-4 bg-slate-800 text-white rounded-xl font-semibold">
  Hover for Shine
</ShineButton>
```

---

## 4. Border Glow Button

Glowing animated border on hover.

```tsx
// components/buttons/BorderGlowButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface BorderGlowButtonProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function BorderGlowButton({
  children,
  className = '',
  onClick,
}: BorderGlowButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative p-[2px] rounded-xl overflow-hidden group ${className}`}
      whileHover="hover"
      whileTap={{ scale: 0.98 }}
    >
      {/* Animated gradient border */}
      <motion.div
        className="absolute inset-0"
        style={{
          background: 'conic-gradient(from 0deg, #3B82F6, #8B5CF6, #EC4899, #3B82F6)',
        }}
        variants={{
          hover: {
            rotate: 360,
            transition: {
              duration: 2,
              repeat: Infinity,
              ease: 'linear',
            },
          },
        }}
      />

      {/* Glow effect */}
      <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 blur-md"
        style={{
          background: 'conic-gradient(from 0deg, #3B82F6, #8B5CF6, #EC4899, #3B82F6)',
        }}
      />

      {/* Inner content */}
      <div className="relative bg-slate-900 rounded-[10px] px-6 py-3 font-semibold text-white">
        {children}
      </div>
    </motion.button>
  );
}
```

---

## 5. Pulse Button

Pulsing glow effect for attention.

```tsx
// components/buttons/PulseButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface PulseButtonProps {
  children: ReactNode;
  className?: string;
  pulseColor?: string;
  onClick?: () => void;
}

export function PulseButton({
  children,
  className = '',
  pulseColor = '#3B82F6',
  onClick,
}: PulseButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative ${className}`}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
    >
      {/* Pulsing rings */}
      <span
        className="absolute inset-0 rounded-xl animate-ping opacity-20"
        style={{ backgroundColor: pulseColor }}
      />
      <span
        className="absolute inset-0 rounded-xl animate-pulse opacity-30"
        style={{ backgroundColor: pulseColor }}
      />

      {/* Button content */}
      <span
        className="relative block px-8 py-4 rounded-xl font-semibold text-white"
        style={{ backgroundColor: pulseColor }}
      >
        {children}
      </span>
    </motion.button>
  );
}
```

---

## 6. Expand Button

Expands with background fill on hover.

```tsx
// components/buttons/ExpandButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface ExpandButtonProps {
  children: ReactNode;
  className?: string;
  bgColor?: string;
  textColor?: string;
  hoverTextColor?: string;
  onClick?: () => void;
}

export function ExpandButton({
  children,
  className = '',
  bgColor = '#3B82F6',
  textColor = '#3B82F6',
  hoverTextColor = '#FFFFFF',
  onClick,
}: ExpandButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative px-8 py-4 rounded-xl font-semibold border-2 overflow-hidden group ${className}`}
      style={{ borderColor: bgColor, color: textColor }}
      whileHover={{ color: hoverTextColor }}
      whileTap={{ scale: 0.98 }}
    >
      {/* Expanding background */}
      <motion.span
        className="absolute inset-0 origin-left"
        style={{ backgroundColor: bgColor }}
        initial={{ scaleX: 0 }}
        whileHover={{ scaleX: 1 }}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
      />

      {/* Content */}
      <span className="relative z-10">{children}</span>
    </motion.button>
  );
}
```

---

## 7. Icon Slide Button

Icon slides in on hover.

```tsx
// components/buttons/IconSlideButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface IconSlideButtonProps {
  children: ReactNode;
  icon: ReactNode;
  className?: string;
  direction?: 'left' | 'right';
  onClick?: () => void;
}

export function IconSlideButton({
  children,
  icon,
  className = '',
  direction = 'right',
  onClick,
}: IconSlideButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative px-6 py-3 rounded-lg font-semibold overflow-hidden group ${className}`}
      whileHover="hover"
      whileTap={{ scale: 0.98 }}
    >
      <motion.span
        className="inline-flex items-center gap-2"
        variants={{
          hover: {
            x: direction === 'right' ? -8 : 8,
          },
        }}
        transition={{ duration: 0.2 }}
      >
        {direction === 'left' && (
          <motion.span
            variants={{
              hover: { opacity: 1, x: 0 },
            }}
            initial={{ opacity: 0, x: 10 }}
            transition={{ duration: 0.2 }}
          >
            {icon}
          </motion.span>
        )}

        {children}

        {direction === 'right' && (
          <motion.span
            variants={{
              hover: { opacity: 1, x: 0 },
            }}
            initial={{ opacity: 0, x: -10 }}
            transition={{ duration: 0.2 }}
          >
            {icon}
          </motion.span>
        )}
      </motion.span>
    </motion.button>
  );
}
```

### Usage

```tsx
import { ArrowRight } from 'lucide-react';

<IconSlideButton
  icon={<ArrowRight size={18} />}
  className="bg-blue-500 text-white"
>
  Get Started
</IconSlideButton>
```

---

## 8. Liquid Button

Organic, liquid-style morphing button.

```tsx
// components/buttons/LiquidButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface LiquidButtonProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function LiquidButton({
  children,
  className = '',
  onClick,
}: LiquidButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative px-8 py-4 font-semibold text-white overflow-hidden ${className}`}
      whileHover="hover"
      whileTap={{ scale: 0.95 }}
    >
      {/* Liquid blob background */}
      <motion.svg
        className="absolute inset-0 w-full h-full"
        viewBox="0 0 200 60"
        preserveAspectRatio="none"
      >
        <motion.path
          fill="#3B82F6"
          d="M0,30 Q50,0 100,30 T200,30 L200,60 L0,60 Z"
          variants={{
            hover: {
              d: [
                'M0,30 Q50,0 100,30 T200,30 L200,60 L0,60 Z',
                'M0,35 Q50,10 100,25 T200,35 L200,60 L0,60 Z',
                'M0,25 Q50,5 100,35 T200,25 L200,60 L0,60 Z',
                'M0,30 Q50,0 100,30 T200,30 L200,60 L0,60 Z',
              ],
              transition: {
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut',
              },
            },
          }}
        />
      </motion.svg>

      {/* Content */}
      <span className="relative z-10">{children}</span>
    </motion.button>
  );
}
```

---

## 9. 3D Press Button

3D button with press-down effect.

```tsx
// components/buttons/Press3DButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface Press3DButtonProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function Press3DButton({
  children,
  className = '',
  onClick,
}: Press3DButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative ${className}`}
      whileHover={{ y: -2 }}
      whileTap={{ y: 4 }}
      transition={{ type: 'spring', stiffness: 400, damping: 17 }}
    >
      {/* Shadow layer */}
      <span className="absolute inset-0 translate-y-2 bg-blue-700 rounded-xl" />

      {/* Button face */}
      <span className="relative block px-8 py-4 bg-blue-500 rounded-xl font-semibold text-white">
        {children}
      </span>
    </motion.button>
  );
}
```

---

## 10. Loading Button

Button with loading state.

```tsx
// components/buttons/LoadingButton.tsx
'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { ReactNode } from 'react';

interface LoadingButtonProps {
  children: ReactNode;
  isLoading?: boolean;
  loadingText?: string;
  className?: string;
  onClick?: () => void;
}

export function LoadingButton({
  children,
  isLoading = false,
  loadingText = 'Loading...',
  className = '',
  onClick,
}: LoadingButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      disabled={isLoading}
      className={`relative px-8 py-4 rounded-xl font-semibold text-white bg-blue-500 overflow-hidden disabled:opacity-80 ${className}`}
      whileHover={!isLoading ? { scale: 1.02 } : undefined}
      whileTap={!isLoading ? { scale: 0.98 } : undefined}
    >
      <AnimatePresence mode="wait">
        {isLoading ? (
          <motion.span
            key="loading"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="flex items-center justify-center gap-2"
          >
            {/* Spinner */}
            <svg
              className="animate-spin h-5 w-5"
              viewBox="0 0 24 24"
              fill="none"
            >
              <circle
                className="opacity-25"
                cx="12"
                cy="12"
                r="10"
                stroke="currentColor"
                strokeWidth="4"
              />
              <path
                className="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              />
            </svg>
            {loadingText}
          </motion.span>
        ) : (
          <motion.span
            key="content"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
          >
            {children}
          </motion.span>
        )}
      </AnimatePresence>
    </motion.button>
  );
}
```

### Usage

```tsx
const [isLoading, setIsLoading] = useState(false);

const handleClick = async () => {
  setIsLoading(true);
  await submitForm();
  setIsLoading(false);
};

<LoadingButton isLoading={isLoading} onClick={handleClick}>
  Submit
</LoadingButton>
```

---

## 11. Gradient Border Button

Animated gradient border (transparent center).

```tsx
// components/buttons/GradientBorderButton.tsx
'use client';

import { motion } from 'framer-motion';
import { ReactNode } from 'react';

interface GradientBorderButtonProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function GradientBorderButton({
  children,
  className = '',
  onClick,
}: GradientBorderButtonProps) {
  return (
    <motion.button
      onClick={onClick}
      className={`relative p-[2px] rounded-xl overflow-hidden ${className}`}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
    >
      {/* Animated gradient border */}
      <div
        className="absolute inset-0 animate-spin-slow"
        style={{
          background: 'conic-gradient(from 0deg, #3B82F6, #8B5CF6, #EC4899, #3B82F6)',
        }}
      />

      {/* Inner transparent background */}
      <div className="relative bg-white dark:bg-slate-900 rounded-[10px] px-6 py-3">
        <span className="bg-clip-text text-transparent bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 font-semibold">
          {children}
        </span>
      </div>
    </motion.button>
  );
}
```

Add to your CSS:

```css
@keyframes spin-slow {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

.animate-spin-slow {
  animation: spin-slow 3s linear infinite;
}
```

---

## 12. Copy Button

Button with copy-to-clipboard feedback.

```tsx
// components/buttons/CopyButton.tsx
'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState } from 'react';
import { Copy, Check } from 'lucide-react';

interface CopyButtonProps {
  text: string;
  className?: string;
}

export function CopyButton({ text, className = '' }: CopyButtonProps) {
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <motion.button
      onClick={handleCopy}
      className={`relative p-2 rounded-lg bg-slate-800 text-white ${className}`}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      <AnimatePresence mode="wait">
        {copied ? (
          <motion.span
            key="check"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            exit={{ scale: 0 }}
          >
            <Check size={18} className="text-green-400" />
          </motion.span>
        ) : (
          <motion.span
            key="copy"
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            exit={{ scale: 0 }}
          >
            <Copy size={18} />
          </motion.span>
        )}
      </AnimatePresence>
    </motion.button>
  );
}
```

---

## Button Composition Guide

### Primary CTA (High Attention)
Use: `MagneticGradientButton` or `PulseButton`
- One per viewport
- Main conversion action

### Secondary Actions
Use: `ExpandButton` or `ShineButton`
- Supporting actions
- Links to other sections

### Form Submissions
Use: `LoadingButton` with `RippleButton` base
- Clear feedback on submit
- Disabled during loading

### Icon Actions
Use: `IconSlideButton`
- Navigation links
- Feature discovery

### Utility Actions
Use: `CopyButton` or basic styled button
- Code snippets
- Share functionality

---

## Accessibility Notes

All buttons include:
- `whileTap` for click feedback
- Keyboard focus styles (add `focus:ring-2 focus:ring-blue-500`)
- Appropriate `aria-label` when icon-only
- `disabled` state handling

```tsx
// Add to all buttons
className="... focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
```
