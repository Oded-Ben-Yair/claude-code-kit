# Hero Components - Full Compositions

Complete, ready-to-use hero sections combining multiple premium effects.

## 1. Futuristic Tech Hero

Aurora background + gradient text + magnetic button.

### The Component

```tsx
// components/heroes/FuturisticHero.tsx
'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface FuturisticHeroProps {
  title: string;
  highlight?: string;
  subtitle: string;
  ctaText: string;
  ctaHref: string;
  className?: string;
}

export function FuturisticHero({
  title,
  highlight,
  subtitle,
  ctaText,
  ctaHref,
  className,
}: FuturisticHeroProps) {
  return (
    <section className={cn('relative min-h-screen overflow-hidden bg-gray-950', className)}>
      {/* Aurora Background */}
      <div className="absolute inset-0">
        <div className="absolute inset-0 bg-gradient-to-br from-blue-600/20 via-purple-600/10 to-pink-600/20" />
        <div
          className="absolute inset-0 opacity-30"
          style={{
            backgroundImage: `
              radial-gradient(ellipse at 20% 30%, rgba(59, 130, 246, 0.3) 0%, transparent 50%),
              radial-gradient(ellipse at 80% 70%, rgba(139, 92, 246, 0.3) 0%, transparent 50%),
              radial-gradient(ellipse at 40% 80%, rgba(236, 72, 153, 0.2) 0%, transparent 50%)
            `,
          }}
        />
      </div>

      {/* Grid Overlay */}
      <div
        className="absolute inset-0 opacity-20"
        style={{
          backgroundImage: `
            linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px',
        }}
      />

      {/* Content */}
      <div className="relative z-10 container mx-auto px-6 flex flex-col items-center justify-center min-h-screen text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="mb-8"
        >
          <span className="px-4 py-2 rounded-full bg-white/10 backdrop-blur-sm border border-white/20 text-sm text-white/80">
            ✨ Introducing the future
          </span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 30, filter: 'blur(10px)' }}
          animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="text-5xl md:text-7xl font-bold tracking-tight"
        >
          <span className="text-white">{title}</span>
          {highlight && (
            <>
              <br />
              <span className="bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400">
                {highlight}
              </span>
            </>
          )}
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="text-xl text-gray-400 mt-6 max-w-2xl"
        >
          {subtitle}
        </motion.p>

        {/* CTA */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          className="mt-10"
        >
          <MagneticButton href={ctaHref}>{ctaText}</MagneticButton>
        </motion.div>
      </div>

      {/* Bottom fade */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-gray-950 to-transparent" />
    </section>
  );
}

// Magnetic button component
function MagneticButton({
  children,
  href,
}: {
  children: React.ReactNode;
  href: string;
}) {
  const ref = React.useRef<HTMLAnchorElement>(null);
  const [position, setPosition] = React.useState({ x: 0, y: 0 });

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!ref.current) return;
    const { left, top, width, height } = ref.current.getBoundingClientRect();
    const x = (e.clientX - left - width / 2) * 0.3;
    const y = (e.clientY - top - height / 2) * 0.3;
    setPosition({ x, y });
  };

  const handleMouseLeave = () => setPosition({ x: 0, y: 0 });

  return (
    <motion.a
      ref={ref}
      href={href}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      animate={{ x: position.x, y: position.y }}
      transition={{ type: 'spring', stiffness: 150, damping: 15 }}
      className="relative inline-flex px-8 py-4 rounded-xl font-semibold text-white overflow-hidden group"
    >
      <span className="absolute inset-0 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500" />
      <span className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 blur-xl" />
      <span className="relative">{children}</span>
    </motion.a>
  );
}
```

### Usage

```tsx
<FuturisticHero
  title="Build the"
  highlight="impossible"
  subtitle="Create stunning experiences that captivate users and elevate your brand."
  ctaText="Get Started"
  ctaHref="/signup"
/>
```

---

## 2. Minimal Corporate Hero

Clean gradient + subtle animation + professional feel.

### The Component

```tsx
// components/heroes/MinimalHero.tsx
'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface MinimalHeroProps {
  eyebrow?: string;
  title: string;
  subtitle: string;
  primaryCta: { text: string; href: string };
  secondaryCta?: { text: string; href: string };
  className?: string;
}

export function MinimalHero({
  eyebrow,
  title,
  subtitle,
  primaryCta,
  secondaryCta,
  className,
}: MinimalHeroProps) {
  return (
    <section className={cn('relative min-h-[80vh] bg-white', className)}>
      {/* Subtle gradient */}
      <div className="absolute inset-0 bg-gradient-to-b from-gray-50 to-white" />

      {/* Content */}
      <div className="relative z-10 container mx-auto px-6 flex flex-col items-center justify-center min-h-[80vh] text-center">
        {/* Eyebrow */}
        {eyebrow && (
          <motion.p
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4 }}
            className="text-sm font-medium text-gray-500 uppercase tracking-wider mb-4"
          >
            {eyebrow}
          </motion.p>
        )}

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.1 }}
          className="text-4xl md:text-6xl font-semibold text-gray-900 tracking-tight max-w-4xl"
        >
          {title}
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.2 }}
          className="text-lg md:text-xl text-gray-600 mt-6 max-w-2xl"
        >
          {subtitle}
        </motion.p>

        {/* CTAs */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="flex flex-col sm:flex-row gap-4 mt-10"
        >
          <a
            href={primaryCta.href}
            className="px-8 py-4 bg-gray-900 text-white font-medium rounded-lg hover:bg-gray-800 transition-colors"
          >
            {primaryCta.text}
          </a>
          {secondaryCta && (
            <a
              href={secondaryCta.href}
              className="px-8 py-4 border border-gray-300 text-gray-700 font-medium rounded-lg hover:bg-gray-50 transition-colors"
            >
              {secondaryCta.text}
            </a>
          )}
        </motion.div>
      </div>
    </section>
  );
}
```

---

## 3. Split Hero with Image

Content on left, image/3D on right.

### The Component

```tsx
// components/heroes/SplitHero.tsx
'use client';

import { motion } from 'framer-motion';
import { cn } from '@/lib/utils';

interface SplitHeroProps {
  title: string;
  subtitle: string;
  cta: { text: string; href: string };
  image?: string;
  children?: React.ReactNode; // For 3D scenes
  className?: string;
  reversed?: boolean;
}

export function SplitHero({
  title,
  subtitle,
  cta,
  image,
  children,
  className,
  reversed = false,
}: SplitHeroProps) {
  return (
    <section className={cn('relative min-h-screen bg-gray-950', className)}>
      <div className={cn(
        'container mx-auto px-6 grid lg:grid-cols-2 gap-12 items-center min-h-screen py-24',
        reversed && 'lg:grid-flow-col-dense'
      )}>
        {/* Content */}
        <div className={cn('max-w-xl', reversed && 'lg:col-start-2')}>
          <motion.h1
            initial={{ opacity: 0, x: reversed ? 30 : -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6 }}
            className="text-4xl md:text-6xl font-bold text-white tracking-tight"
          >
            {title}
          </motion.h1>

          <motion.p
            initial={{ opacity: 0, x: reversed ? 30 : -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
            className="text-lg text-gray-400 mt-6"
          >
            {subtitle}
          </motion.p>

          <motion.a
            initial={{ opacity: 0, x: reversed ? 30 : -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            href={cta.href}
            className="inline-flex mt-8 px-8 py-4 bg-white text-gray-900 font-semibold rounded-lg hover:bg-gray-100 transition-colors"
          >
            {cta.text}
          </motion.a>
        </div>

        {/* Visual */}
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className={cn(
            'relative aspect-square lg:aspect-auto lg:h-[80vh]',
            reversed && 'lg:col-start-1'
          )}
        >
          {image ? (
            <img
              src={image}
              alt=""
              className="w-full h-full object-cover rounded-2xl"
            />
          ) : (
            children
          )}
        </motion.div>
      </div>
    </section>
  );
}
```

---

## 4. Seekapa Finance Hero

Professional, trust-focused hero for finance brands.

### The Component

```tsx
// components/heroes/SeekpaHero.tsx
'use client';

import { motion } from 'framer-motion';

interface SeekapaHeroProps {
  title: string;
  subtitle: string;
  ctaText: string;
  ctaHref: string;
  stats?: Array<{ value: string; label: string }>;
}

export function SeekapaHero({
  title,
  subtitle,
  ctaText,
  ctaHref,
  stats,
}: SeekapaHeroProps) {
  return (
    <section className="relative min-h-[85vh] bg-gradient-to-b from-[#1E3A5F] to-[#152942] overflow-hidden">
      {/* Subtle grid */}
      <div
        className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: `
            linear-gradient(rgba(255,255,255,0.05) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255,255,255,0.05) 1px, transparent 1px)
          `,
          backgroundSize: '40px 40px',
        }}
      />

      {/* Content */}
      <div className="relative z-10 container mx-auto px-6 py-24 flex flex-col justify-center min-h-[85vh]">
        <div className="max-w-3xl">
          {/* Title */}
          <motion.h1
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="text-4xl md:text-6xl font-semibold text-white tracking-tight leading-tight"
          >
            {title}
          </motion.h1>

          {/* Subtitle */}
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="text-xl text-white/70 mt-6 max-w-xl"
          >
            {subtitle}
          </motion.p>

          {/* CTA */}
          <motion.a
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            href={ctaHref}
            className="inline-flex mt-8 px-8 py-4 bg-[#D4AF37] text-[#1E3A5F] font-semibold rounded-lg hover:bg-[#E5C65C] transition-colors shadow-lg"
          >
            {ctaText}
          </motion.a>
        </div>

        {/* Stats */}
        {stats && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.3 }}
            className="grid grid-cols-2 md:grid-cols-4 gap-8 mt-16 pt-8 border-t border-white/10"
          >
            {stats.map((stat, i) => (
              <div key={i}>
                <p className="text-3xl md:text-4xl font-bold text-[#D4AF37]">
                  {stat.value}
                </p>
                <p className="text-white/60 mt-1">{stat.label}</p>
              </div>
            ))}
          </motion.div>
        )}
      </div>

      {/* Gradient fade */}
      <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-[#152942] to-transparent" />
    </section>
  );
}
```

---

## 5. Sentimark Dashboard Hero

Dark, data-focused hero for analytics products.

### The Component

```tsx
// components/heroes/SentimarkHero.tsx
'use client';

import { motion } from 'framer-motion';

interface SentimarkHeroProps {
  title: string;
  highlight: string;
  subtitle: string;
  ctaText: string;
  ctaHref: string;
}

export function SentimarkHero({
  title,
  highlight,
  subtitle,
  ctaText,
  ctaHref,
}: SentimarkHeroProps) {
  return (
    <section className="relative min-h-screen bg-[#0F172A] overflow-hidden">
      {/* Aurora effect */}
      <div className="absolute inset-0">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-blue-500/20 rounded-full blur-[100px]" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-purple-500/20 rounded-full blur-[100px]" />
        <div className="absolute top-1/2 left-1/2 w-64 h-64 bg-pink-500/10 rounded-full blur-[80px]" />
      </div>

      {/* Dot grid */}
      <div
        className="absolute inset-0 opacity-30"
        style={{
          backgroundImage: 'radial-gradient(circle, rgba(59,130,246,0.3) 1px, transparent 1px)',
          backgroundSize: '30px 30px',
        }}
      />

      {/* Content */}
      <div className="relative z-10 container mx-auto px-6 flex flex-col items-center justify-center min-h-screen text-center">
        {/* Badge */}
        <motion.div
          initial={{ opacity: 0, y: 20, scale: 0.9 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ duration: 0.5 }}
          className="mb-8"
        >
          <span className="px-4 py-2 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 text-sm font-medium">
            🚀 Powered by AI
          </span>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 30, filter: 'blur(10px)' }}
          animate={{ opacity: 1, y: 0, filter: 'blur(0px)' }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="text-5xl md:text-7xl font-bold tracking-tight"
        >
          <span className="text-white">{title}</span>
          <br />
          <span className="bg-clip-text text-transparent bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400">
            {highlight}
          </span>
        </motion.h1>

        {/* Subtitle */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.3 }}
          className="text-xl text-gray-400 mt-6 max-w-2xl"
        >
          {subtitle}
        </motion.p>

        {/* CTA */}
        <motion.a
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.4 }}
          href={ctaHref}
          className="relative mt-10 px-8 py-4 rounded-xl font-semibold text-white overflow-hidden group"
        >
          <span className="absolute inset-0 bg-gradient-to-r from-blue-500 via-purple-500 to-pink-500" />
          <span className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity bg-gradient-to-r from-blue-400 via-purple-400 to-pink-400 blur-lg" />
          <span className="relative">{ctaText}</span>
        </motion.a>

        {/* Live indicator */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
          className="flex items-center gap-2 mt-12 text-gray-500"
        >
          <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
          Live sentiment tracking
        </motion.div>
      </div>
    </section>
  );
}
```

---

## Usage Tips

### Choosing a Hero

| Hero Type | Best For |
|-----------|----------|
| Futuristic | Tech products, AI, startups |
| Minimal | Corporate, professional services |
| Split | Product showcases, features |
| Seekapa | Finance, trading, trust-focused |
| Sentimark | Data products, dashboards, analytics |

### Performance

- All heroes use Framer Motion for smooth animations
- CSS-based backgrounds are preferred over canvas
- Mobile: Consider simplifying or removing complex effects

### Customization

Each hero exposes key props:
- `title`, `subtitle` - Core content
- `ctaText`, `ctaHref` - Call to action
- `className` - Additional styling
- Brand-specific colors via CSS variables
