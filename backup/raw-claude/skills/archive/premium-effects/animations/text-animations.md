# Text Animations - Premium Typography Effects

Full, copy-paste components for distinctive text animations.

## 1. Staggered Text Reveal

Characters or words animate in sequence. Classic, always impressive.

### When to Use
- Hero headlines
- Section titles
- Key statements

### When NOT to Use
- Body text
- Frequently updating content
- Below the fold (user may miss it)

### Dependencies
```bash
npm install framer-motion
```

### The Component

```tsx
// components/StaggeredText.tsx
'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface StaggeredTextProps {
  text: string;
  className?: string;
  staggerBy?: 'letter' | 'word';
  delay?: number;
  duration?: number;
}

export function StaggeredText({
  text,
  className,
  staggerBy = 'word',
  delay = 0,
  duration = 0.5,
}: StaggeredTextProps) {
  const items = staggerBy === 'letter' ? text.split('') : text.split(' ');

  const container = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        delayChildren: delay,
        staggerChildren: staggerBy === 'letter' ? 0.02 : 0.08,
      },
    },
  };

  const item = {
    hidden: { opacity: 0, y: 20, filter: 'blur(4px)' },
    visible: {
      opacity: 1,
      y: 0,
      filter: 'blur(0px)',
      transition: { duration, ease: [0.16, 1, 0.3, 1] },
    },
  };

  return (
    <motion.span
      variants={container}
      initial="hidden"
      animate="visible"
      className={cn('inline-block', className)}
    >
      {items.map((char, index) => (
        <motion.span
          key={index}
          variants={item}
          className="inline-block"
          style={{ whiteSpace: staggerBy === 'word' ? 'pre' : undefined }}
        >
          {char}
          {staggerBy === 'word' && index < items.length - 1 ? ' ' : ''}
        </motion.span>
      ))}
    </motion.span>
  );
}
```

### Usage

```tsx
<h1 className="text-5xl font-bold">
  <StaggeredText
    text="Welcome to the future"
    staggerBy="word"
    delay={0.2}
  />
</h1>
```

---

## 2. Text Decrypt / Scramble Effect

Text appears to decode from random characters. Perfect for "futuristic" brands.

### When to Use
- Tech/futuristic brands
- Dramatic reveals
- Loading states

### The Component

```tsx
// components/DecryptText.tsx
'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface DecryptTextProps {
  text: string;
  className?: string;
  duration?: number;
  delay?: number;
  characters?: string;
}

export function DecryptText({
  text,
  className,
  duration = 1500,
  delay = 0,
  characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*',
}: DecryptTextProps) {
  const [displayText, setDisplayText] = useState('');
  const [isAnimating, setIsAnimating] = useState(false);

  useEffect(() => {
    const timeout = setTimeout(() => {
      setIsAnimating(true);
      let iteration = 0;
      const interval = setInterval(() => {
        setDisplayText(
          text
            .split('')
            .map((char, index) => {
              if (char === ' ') return ' ';
              if (index < iteration) return text[index];
              return characters[Math.floor(Math.random() * characters.length)];
            })
            .join('')
        );

        iteration += 1 / 3;
        if (iteration >= text.length) {
          clearInterval(interval);
          setDisplayText(text);
        }
      }, duration / (text.length * 3));

      return () => clearInterval(interval);
    }, delay);

    return () => clearTimeout(timeout);
  }, [text, duration, delay, characters]);

  return (
    <motion.span
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.3 }}
      className={cn('font-mono', className)}
    >
      {displayText || text.replace(/./g, ' ')}
    </motion.span>
  );
}
```

### Usage

```tsx
<h1 className="text-4xl">
  <DecryptText text="SYSTEM ONLINE" duration={2000} />
</h1>
```

---

## 3. Shiny Text Effect

Light shimmer passes through text. Subtle but eye-catching.

### When to Use
- Important headlines
- Product names
- CTAs

### The Component (CSS-based)

```tsx
// components/ShinyText.tsx
import { cn } from '@/lib/utils';

interface ShinyTextProps {
  children: React.ReactNode;
  className?: string;
}

export function ShinyText({ children, className }: ShinyTextProps) {
  return (
    <span
      className={cn(
        'relative inline-block bg-clip-text text-transparent',
        'bg-[length:200%_100%] animate-shimmer',
        'bg-gradient-to-r from-foreground via-foreground/50 to-foreground',
        className
      )}
    >
      {children}
    </span>
  );
}
```

### Required Tailwind Config

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      animation: {
        shimmer: 'shimmer 3s linear infinite',
      },
      keyframes: {
        shimmer: {
          '0%': { backgroundPosition: '200% 0' },
          '100%': { backgroundPosition: '-200% 0' },
        },
      },
    },
  },
};
```

### Usage

```tsx
<h1 className="text-5xl font-bold">
  <ShinyText>Premium Quality</ShinyText>
</h1>
```

---

## 4. Gradient Text Animation

Animated gradient that flows through text.

### The Component

```tsx
// components/GradientText.tsx
import { cn } from '@/lib/utils';

interface GradientTextProps {
  children: React.ReactNode;
  className?: string;
  from?: string;
  via?: string;
  to?: string;
  animate?: boolean;
}

export function GradientText({
  children,
  className,
  from = 'from-primary',
  via = 'via-purple-500',
  to = 'to-pink-500',
  animate = true,
}: GradientTextProps) {
  return (
    <span
      className={cn(
        'inline-block bg-clip-text text-transparent bg-gradient-to-r',
        from, via, to,
        animate && 'bg-[length:200%_auto] animate-gradient',
        className
      )}
    >
      {children}
    </span>
  );
}
```

### Required Tailwind Config

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      animation: {
        gradient: 'gradient 8s linear infinite',
      },
      keyframes: {
        gradient: {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
      },
    },
  },
};
```

---

## 5. Typewriter Effect

Classic typewriter with blinking cursor.

### When to Use
- Code-related products
- Terminal aesthetics
- Sequential messages

### The Component

```tsx
// components/TypewriterText.tsx
'use client';

import { useEffect, useState } from 'react';
import { cn } from '@/lib/utils';

interface TypewriterTextProps {
  text: string | string[];
  className?: string;
  speed?: number;
  delay?: number;
  loop?: boolean;
  cursor?: boolean;
}

export function TypewriterText({
  text,
  className,
  speed = 50,
  delay = 1000,
  loop = false,
  cursor = true,
}: TypewriterTextProps) {
  const [displayText, setDisplayText] = useState('');
  const [textIndex, setTextIndex] = useState(0);
  const [charIndex, setCharIndex] = useState(0);
  const [isDeleting, setIsDeleting] = useState(false);

  const texts = Array.isArray(text) ? text : [text];
  const currentText = texts[textIndex];

  useEffect(() => {
    const timeout = setTimeout(
      () => {
        if (!isDeleting) {
          if (charIndex < currentText.length) {
            setDisplayText(currentText.slice(0, charIndex + 1));
            setCharIndex(charIndex + 1);
          } else if (loop && texts.length > 1) {
            setTimeout(() => setIsDeleting(true), delay);
          }
        } else {
          if (charIndex > 0) {
            setDisplayText(currentText.slice(0, charIndex - 1));
            setCharIndex(charIndex - 1);
          } else {
            setIsDeleting(false);
            setTextIndex((textIndex + 1) % texts.length);
          }
        }
      },
      isDeleting ? speed / 2 : speed
    );

    return () => clearTimeout(timeout);
  }, [charIndex, isDeleting, currentText, texts, textIndex, speed, delay, loop]);

  return (
    <span className={cn('font-mono', className)}>
      {displayText}
      {cursor && (
        <span className="animate-pulse ml-0.5 inline-block w-[2px] h-[1em] bg-current" />
      )}
    </span>
  );
}
```

### Usage

```tsx
{/* Single text */}
<TypewriterText text="Hello, World!" />

{/* Multiple texts (loops) */}
<TypewriterText
  text={['Developer', 'Designer', 'Creator']}
  loop
  speed={80}
/>
```

---

## 6. Blur Reveal

Text fades in from blurred to clear. Elegant and modern.

### The Component

```tsx
// components/BlurReveal.tsx
'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface BlurRevealProps {
  children: React.ReactNode;
  className?: string;
  delay?: number;
}

export function BlurReveal({
  children,
  className,
  delay = 0,
}: BlurRevealProps) {
  return (
    <motion.div
      initial={{ opacity: 0, filter: 'blur(10px)' }}
      animate={{ opacity: 1, filter: 'blur(0px)' }}
      transition={{
        duration: 0.8,
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

---

## 7. Scroll-Triggered Text Reveal

Text animates as it enters viewport. Great for content sections.

### The Component

```tsx
// components/ScrollRevealText.tsx
'use client';

import { useRef } from 'react';
import { motion, useInView } from 'framer-motion';
import { cn } from '@/lib/utils';

interface ScrollRevealTextProps {
  children: React.ReactNode;
  className?: string;
  direction?: 'up' | 'down' | 'left' | 'right';
  delay?: number;
}

export function ScrollRevealText({
  children,
  className,
  direction = 'up',
  delay = 0,
}: ScrollRevealTextProps) {
  const ref = useRef<HTMLDivElement>(null);
  const isInView = useInView(ref, { once: true, margin: '-100px' });

  const directions = {
    up: { y: 40 },
    down: { y: -40 },
    left: { x: 40 },
    right: { x: -40 },
  };

  return (
    <motion.div
      ref={ref}
      initial={{
        opacity: 0,
        filter: 'blur(4px)',
        ...directions[direction],
      }}
      animate={isInView ? {
        opacity: 1,
        filter: 'blur(0px)',
        x: 0,
        y: 0,
      } : {}}
      transition={{
        duration: 0.6,
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
<section className="py-20">
  <ScrollRevealText>
    <h2 className="text-4xl font-bold">Section Title</h2>
  </ScrollRevealText>
  <ScrollRevealText delay={0.1}>
    <p className="text-lg text-muted-foreground mt-4">
      Section description goes here.
    </p>
  </ScrollRevealText>
</section>
```

---

## Combination Example: Premium Hero Text

Combining multiple effects for maximum impact:

```tsx
function HeroText() {
  return (
    <div className="space-y-4">
      {/* Main headline with stagger */}
      <h1 className="text-6xl font-bold tracking-tight">
        <StaggeredText text="Build the" staggerBy="word" />
        <br />
        <GradientText animate>
          <StaggeredText text="impossible" staggerBy="letter" delay={0.5} />
        </GradientText>
      </h1>

      {/* Subheadline with blur reveal */}
      <BlurReveal delay={1}>
        <p className="text-xl text-muted-foreground max-w-lg">
          Create stunning experiences that captivate users
          and elevate your brand.
        </p>
      </BlurReveal>
    </div>
  );
}
```

## Accessibility

All text animations should respect `prefers-reduced-motion`:

```tsx
import { useReducedMotion } from 'framer-motion';

function TextEffect({ text }: { text: string }) {
  const prefersReducedMotion = useReducedMotion();

  if (prefersReducedMotion) {
    return <span>{text}</span>;
  }

  return <AnimatedText text={text} />;
}
```
