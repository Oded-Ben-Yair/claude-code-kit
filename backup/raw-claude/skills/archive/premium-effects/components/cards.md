# Card Components - Premium Card Systems

Full, ready-to-use card components with premium effects.

## 1. Glass Card

Glassmorphism card with backdrop blur.

### The Component

```tsx
// components/cards/GlassCard.tsx
import { cn } from '@/lib/utils';

interface GlassCardProps {
  children: React.ReactNode;
  className?: string;
  hover?: boolean;
}

export function GlassCard({ children, className, hover = true }: GlassCardProps) {
  return (
    <div
      className={cn(
        'relative bg-white/5 backdrop-blur-xl border border-white/10 rounded-xl p-6',
        hover && 'transition-all duration-300 hover:bg-white/10 hover:border-white/20',
        className
      )}
    >
      {children}
    </div>
  );
}
```

### With Gradient Border

```tsx
// components/cards/GlassCardGlow.tsx
import { cn } from '@/lib/utils';

export function GlassCardGlow({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('relative group', className)}>
      {/* Glow effect */}
      <div className="absolute -inset-px bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500 rounded-xl opacity-0 group-hover:opacity-50 blur-sm transition-opacity" />

      {/* Card */}
      <div className="relative bg-gray-900/80 backdrop-blur-xl border border-white/10 rounded-xl p-6 transition-colors group-hover:border-white/20">
        {children}
      </div>
    </div>
  );
}
```

---

## 2. Direction-Aware Card Grid

Cards with direction-aware hover reveal.

### The Component

```tsx
// components/cards/DirectionAwareGrid.tsx
'use client';

import { useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

type Direction = 'top' | 'bottom' | 'left' | 'right';

interface CardItem {
  id: string | number;
  image: string;
  title: string;
  description: string;
  link?: string;
}

interface DirectionAwareGridProps {
  items: CardItem[];
  columns?: 2 | 3 | 4;
  className?: string;
}

export function DirectionAwareGrid({
  items,
  columns = 3,
  className,
}: DirectionAwareGridProps) {
  const gridCols = {
    2: 'md:grid-cols-2',
    3: 'md:grid-cols-3',
    4: 'md:grid-cols-2 lg:grid-cols-4',
  };

  return (
    <div className={cn('grid gap-6', gridCols[columns], className)}>
      {items.map((item) => (
        <DirectionAwareCard key={item.id} item={item} />
      ))}
    </div>
  );
}

function DirectionAwareCard({ item }: { item: CardItem }) {
  const ref = useRef<HTMLDivElement>(null);
  const [direction, setDirection] = useState<Direction>('top');
  const [isHovered, setIsHovered] = useState(false);

  const getDirection = (e: React.MouseEvent<HTMLDivElement>): Direction => {
    if (!ref.current) return 'top';
    const { width, height, left, top } = ref.current.getBoundingClientRect();
    const x = e.clientX - left - width / 2;
    const y = e.clientY - top - height / 2;
    return Math.abs(x) > Math.abs(y) ? (x > 0 ? 'right' : 'left') : y > 0 ? 'bottom' : 'top';
  };

  const variants = {
    hidden: (d: Direction) => ({
      x: d === 'left' ? '-100%' : d === 'right' ? '100%' : 0,
      y: d === 'top' ? '-100%' : d === 'bottom' ? '100%' : 0,
    }),
    visible: { x: 0, y: 0 },
  };

  const Wrapper = item.link ? 'a' : 'div';

  return (
    <Wrapper
      href={item.link}
      ref={ref as any}
      onMouseEnter={(e) => {
        setDirection(getDirection(e));
        setIsHovered(true);
      }}
      onMouseLeave={(e) => {
        setDirection(getDirection(e));
        setIsHovered(false);
      }}
      className="relative aspect-[4/3] rounded-xl overflow-hidden cursor-pointer group"
    >
      {/* Image */}
      <img
        src={item.image}
        alt={item.title}
        className="absolute inset-0 w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
      />

      {/* Gradient overlay for text visibility */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent" />

      {/* Title (always visible) */}
      <div className="absolute bottom-0 left-0 right-0 p-4 z-10">
        <h3 className="text-lg font-semibold text-white">{item.title}</h3>
      </div>

      {/* Overlay (slides in on hover) */}
      <motion.div
        custom={direction}
        variants={variants}
        initial="hidden"
        animate={isHovered ? 'visible' : 'hidden'}
        transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
        className="absolute inset-0 z-20 flex flex-col items-center justify-center bg-black/90 p-6 text-center"
      >
        <h3 className="text-xl font-semibold text-white">{item.title}</h3>
        <p className="text-gray-300 mt-2">{item.description}</p>
        {item.link && (
          <span className="mt-4 text-sm text-primary">View Details →</span>
        )}
      </motion.div>
    </Wrapper>
  );
}
```

---

## 3. Feature Card

Clean feature card with icon and hover effect.

### The Component

```tsx
// components/cards/FeatureCard.tsx
'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface FeatureCardProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  className?: string;
}

export function FeatureCard({
  icon,
  title,
  description,
  className,
}: FeatureCardProps) {
  return (
    <motion.div
      whileHover={{
        y: -4,
        boxShadow: '0 20px 40px rgba(0, 0, 0, 0.1)',
      }}
      transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
      className={cn(
        'bg-white rounded-xl border border-gray-200 p-6 cursor-pointer',
        'transition-colors hover:border-gray-300',
        className
      )}
    >
      {/* Icon */}
      <div className="w-12 h-12 rounded-lg bg-primary/10 flex items-center justify-center text-primary mb-4">
        {icon}
      </div>

      {/* Content */}
      <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
      <p className="text-gray-600 mt-2">{description}</p>
    </motion.div>
  );
}
```

### Dark Variant

```tsx
// components/cards/FeatureCardDark.tsx
export function FeatureCardDark({
  icon,
  title,
  description,
  className,
}: FeatureCardProps) {
  return (
    <motion.div
      whileHover={{
        borderColor: 'rgba(59, 130, 246, 0.5)',
        boxShadow: '0 0 30px rgba(59, 130, 246, 0.1)',
      }}
      transition={{ duration: 0.3 }}
      className={cn(
        'bg-gray-900/50 backdrop-blur-xl rounded-xl border border-white/10 p-6',
        className
      )}
    >
      <div className="w-12 h-12 rounded-lg bg-blue-500/10 flex items-center justify-center text-blue-400 mb-4">
        {icon}
      </div>
      <h3 className="text-lg font-semibold text-white">{title}</h3>
      <p className="text-gray-400 mt-2">{description}</p>
    </motion.div>
  );
}
```

---

## 4. Bento Grid

Modern bento-style grid layout.

### The Component

```tsx
// components/cards/BentoGrid.tsx
import { cn } from '@/lib/utils';

interface BentoItem {
  title: string;
  description: string;
  icon?: React.ReactNode;
  image?: string;
  className?: string;
}

interface BentoGridProps {
  items: BentoItem[];
  className?: string;
}

export function BentoGrid({ items, className }: BentoGridProps) {
  return (
    <div className={cn('grid gap-4 md:grid-cols-3', className)}>
      {items.map((item, i) => (
        <BentoCard
          key={i}
          {...item}
          className={cn(
            // First item spans 2 columns
            i === 0 && 'md:col-span-2',
            // Second item is tall
            i === 1 && 'md:row-span-2',
            item.className
          )}
        />
      ))}
    </div>
  );
}

function BentoCard({
  title,
  description,
  icon,
  image,
  className,
}: BentoItem) {
  return (
    <div
      className={cn(
        'relative overflow-hidden rounded-xl bg-gray-100 p-6',
        'transition-all duration-300 hover:shadow-lg',
        className
      )}
    >
      {image && (
        <img
          src={image}
          alt=""
          className="absolute inset-0 w-full h-full object-cover"
        />
      )}

      <div className={cn('relative z-10', image && 'text-white')}>
        {icon && (
          <div className="w-10 h-10 rounded-lg bg-white/10 flex items-center justify-center mb-4">
            {icon}
          </div>
        )}
        <h3 className="text-lg font-semibold">{title}</h3>
        <p className={cn('mt-2', image ? 'text-white/80' : 'text-gray-600')}>
          {description}
        </p>
      </div>

      {image && <div className="absolute inset-0 bg-black/40" />}
    </div>
  );
}
```

---

## 5. Stat Card

Dashboard-style stat card with trend indicator.

### The Component

```tsx
// components/cards/StatCard.tsx
import { cn } from '@/lib/utils';

interface StatCardProps {
  label: string;
  value: string;
  change?: {
    value: string;
    trend: 'up' | 'down' | 'neutral';
  };
  icon?: React.ReactNode;
  className?: string;
}

export function StatCard({
  label,
  value,
  change,
  icon,
  className,
}: StatCardProps) {
  const trendColors = {
    up: 'text-green-500 bg-green-500/10',
    down: 'text-red-500 bg-red-500/10',
    neutral: 'text-gray-500 bg-gray-500/10',
  };

  return (
    <div
      className={cn(
        'bg-white rounded-xl border border-gray-200 p-6',
        className
      )}
    >
      <div className="flex justify-between items-start">
        <div>
          <p className="text-sm text-gray-500">{label}</p>
          <p className="text-3xl font-bold text-gray-900 mt-1 font-mono">
            {value}
          </p>
        </div>
        {icon && (
          <div className="w-10 h-10 rounded-lg bg-gray-100 flex items-center justify-center text-gray-600">
            {icon}
          </div>
        )}
      </div>

      {change && (
        <div className="mt-4 flex items-center gap-2">
          <span
            className={cn(
              'px-2 py-1 rounded-full text-xs font-medium',
              trendColors[change.trend]
            )}
          >
            {change.trend === 'up' && '↑'}
            {change.trend === 'down' && '↓'}
            {change.value}
          </span>
          <span className="text-sm text-gray-500">vs last period</span>
        </div>
      )}
    </div>
  );
}
```

### Dark Variant (Sentimark Style)

```tsx
// components/cards/StatCardDark.tsx
export function StatCardDark({
  label,
  value,
  change,
  className,
}: StatCardProps) {
  return (
    <div
      className={cn(
        'bg-gray-900/50 backdrop-blur-xl border border-white/10 rounded-xl p-6',
        className
      )}
    >
      <p className="text-sm text-gray-400">{label}</p>
      <p className="text-3xl font-bold text-white mt-1 font-mono">{value}</p>

      {change && (
        <p
          className={cn(
            'text-sm mt-3',
            change.trend === 'up' && 'text-green-400',
            change.trend === 'down' && 'text-red-400',
            change.trend === 'neutral' && 'text-gray-400'
          )}
        >
          {change.trend === 'up' && '↑ '}
          {change.trend === 'down' && '↓ '}
          {change.value}
        </p>
      )}
    </div>
  );
}
```

---

## 6. Testimonial Card

Quote card with author info.

### The Component

```tsx
// components/cards/TestimonialCard.tsx
import { cn } from '@/lib/utils';

interface TestimonialCardProps {
  quote: string;
  author: {
    name: string;
    role: string;
    avatar?: string;
    company?: string;
  };
  className?: string;
}

export function TestimonialCard({
  quote,
  author,
  className,
}: TestimonialCardProps) {
  return (
    <div
      className={cn(
        'bg-white rounded-xl border border-gray-200 p-6',
        className
      )}
    >
      {/* Quote */}
      <blockquote className="text-gray-700 leading-relaxed">
        "{quote}"
      </blockquote>

      {/* Author */}
      <div className="flex items-center gap-3 mt-6">
        {author.avatar ? (
          <img
            src={author.avatar}
            alt={author.name}
            className="w-10 h-10 rounded-full object-cover"
          />
        ) : (
          <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-600 font-medium">
            {author.name[0]}
          </div>
        )}
        <div>
          <p className="font-medium text-gray-900">{author.name}</p>
          <p className="text-sm text-gray-500">
            {author.role}
            {author.company && `, ${author.company}`}
          </p>
        </div>
      </div>
    </div>
  );
}
```

---

## 7. Pricing Card

Clean pricing card with highlight option.

### The Component

```tsx
// components/cards/PricingCard.tsx
import { cn } from '@/lib/utils';

interface PricingCardProps {
  name: string;
  price: string;
  period?: string;
  description: string;
  features: string[];
  cta: { text: string; href: string };
  highlighted?: boolean;
  className?: string;
}

export function PricingCard({
  name,
  price,
  period = '/month',
  description,
  features,
  cta,
  highlighted = false,
  className,
}: PricingCardProps) {
  return (
    <div
      className={cn(
        'rounded-xl p-6 flex flex-col',
        highlighted
          ? 'bg-gray-900 text-white ring-2 ring-primary'
          : 'bg-white border border-gray-200',
        className
      )}
    >
      {/* Header */}
      <div>
        {highlighted && (
          <span className="px-3 py-1 bg-primary text-white text-xs font-medium rounded-full mb-4 inline-block">
            Most Popular
          </span>
        )}
        <h3 className="text-lg font-semibold">{name}</h3>
        <div className="mt-4 flex items-baseline">
          <span className="text-4xl font-bold">{price}</span>
          <span className={cn('ml-1', highlighted ? 'text-gray-400' : 'text-gray-500')}>
            {period}
          </span>
        </div>
        <p className={cn('mt-2', highlighted ? 'text-gray-400' : 'text-gray-600')}>
          {description}
        </p>
      </div>

      {/* Features */}
      <ul className="mt-6 space-y-3 flex-1">
        {features.map((feature, i) => (
          <li key={i} className="flex items-center gap-2">
            <svg className="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
            <span className={highlighted ? 'text-gray-300' : 'text-gray-600'}>
              {feature}
            </span>
          </li>
        ))}
      </ul>

      {/* CTA */}
      <a
        href={cta.href}
        className={cn(
          'mt-8 block text-center py-3 px-6 rounded-lg font-medium transition-colors',
          highlighted
            ? 'bg-white text-gray-900 hover:bg-gray-100'
            : 'bg-gray-900 text-white hover:bg-gray-800'
        )}
      >
        {cta.text}
      </a>
    </div>
  );
}
```

---

## Usage Examples

### Feature Grid

```tsx
<div className="grid md:grid-cols-3 gap-6">
  <FeatureCard
    icon={<IconBolt />}
    title="Lightning Fast"
    description="Optimized for speed and performance."
  />
  <FeatureCard
    icon={<IconShield />}
    title="Secure"
    description="Enterprise-grade security built-in."
  />
  <FeatureCard
    icon={<IconChart />}
    title="Analytics"
    description="Powerful insights at your fingertips."
  />
</div>
```

### Dashboard Stats

```tsx
<div className="grid md:grid-cols-4 gap-4">
  <StatCard
    label="Total Revenue"
    value="$45,231"
    change={{ value: '+12.5%', trend: 'up' }}
  />
  <StatCard
    label="Active Users"
    value="2,345"
    change={{ value: '+5.2%', trend: 'up' }}
  />
  <StatCard
    label="Conversion Rate"
    value="3.24%"
    change={{ value: '-0.3%', trend: 'down' }}
  />
  <StatCard
    label="Avg. Order"
    value="$127"
    change={{ value: '0%', trend: 'neutral' }}
  />
</div>
```
