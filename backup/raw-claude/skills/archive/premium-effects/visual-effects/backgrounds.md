# Background Effects - Premium Visual Atmosphere

Full, copy-paste components for distinctive background effects.

## 1. Aurora Background

Animated northern lights effect. Signature premium look.

### When to Use
- Hero sections
- Feature highlights
- Landing pages

### When NOT to Use
- Content-heavy pages (distracting)
- Multiple per page
- Over complex imagery

### Dependencies
```bash
npm install clsx tailwind-merge
```

### Required Tailwind Config

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      animation: {
        aurora: 'aurora 60s linear infinite',
      },
      keyframes: {
        aurora: {
          from: { backgroundPosition: '50% 50%, 50% 50%' },
          to: { backgroundPosition: '350% 50%, 350% 50%' },
        },
      },
    },
  },
};
```

### The Component

```tsx
// components/AuroraBackground.tsx
import { cn } from '@/lib/utils';

interface AuroraBackgroundProps {
  children?: React.ReactNode;
  className?: string;
  showRadialGradient?: boolean;
}

export function AuroraBackground({
  children,
  className,
  showRadialGradient = true,
}: AuroraBackgroundProps) {
  return (
    <div
      className={cn(
        'relative flex flex-col min-h-screen overflow-hidden',
        'bg-zinc-50 dark:bg-zinc-900',
        className
      )}
    >
      {/* Aurora layers */}
      <div className="absolute inset-0 overflow-hidden">
        <div
          className={cn(
            'pointer-events-none absolute -inset-[10px] opacity-50',
            '[--aurora:repeating-linear-gradient(100deg,var(--primary)_10%,var(--accent)_15%,var(--primary)_20%,var(--accent)_25%,var(--primary)_30%)]',
            '[background-image:var(--aurora)]',
            '[background-size:300%]',
            '[background-position:50%_50%]',
            'filter blur-[10px]',
            'after:content-[""] after:absolute after:inset-0',
            'after:[background-image:var(--aurora)]',
            'after:[background-size:200%]',
            'after:animate-aurora after:mix-blend-difference',
            'after:[background-attachment:fixed]'
          )}
          style={{
            '--primary': 'rgba(59, 130, 246, 0.3)',
            '--accent': 'rgba(147, 51, 234, 0.3)',
          } as React.CSSProperties}
        />
      </div>

      {/* Radial gradient overlay */}
      {showRadialGradient && (
        <div className="absolute inset-0 bg-zinc-50 dark:bg-zinc-900 [mask-image:radial-gradient(ellipse_at_center,transparent_20%,black)]" />
      )}

      {/* Content */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

### Simpler CSS-Only Version

```tsx
// components/AuroraBackgroundSimple.tsx
import { cn } from '@/lib/utils';

export function AuroraBackgroundSimple({
  children,
  className,
}: {
  children?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('relative min-h-screen overflow-hidden', className)}>
      {/* Gradient blobs */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-1/2 -left-1/2 w-full h-full bg-gradient-to-br from-primary/30 to-transparent rounded-full blur-3xl animate-pulse" />
        <div className="absolute -bottom-1/2 -right-1/2 w-full h-full bg-gradient-to-tl from-accent/30 to-transparent rounded-full blur-3xl animate-pulse [animation-delay:2s]" />
        <div className="absolute top-1/4 right-1/4 w-1/2 h-1/2 bg-gradient-to-bl from-purple-500/20 to-transparent rounded-full blur-3xl animate-pulse [animation-delay:4s]" />
      </div>

      {/* Content */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

---

## 2. Blob Background

Organic, morphing shapes. Playful and modern.

### The Component

```tsx
// components/BlobBackground.tsx
'use client';

import { cn } from '@/lib/utils';

interface BlobBackgroundProps {
  children?: React.ReactNode;
  className?: string;
  blobColors?: string[];
}

export function BlobBackground({
  children,
  className,
  blobColors = ['bg-primary/30', 'bg-purple-500/30', 'bg-pink-500/30'],
}: BlobBackgroundProps) {
  return (
    <div className={cn('relative min-h-screen overflow-hidden', className)}>
      {/* Animated blobs */}
      <div className="absolute inset-0">
        {blobColors.map((color, i) => (
          <div
            key={i}
            className={cn(
              'absolute rounded-full blur-3xl',
              color,
              // Size variations
              i === 0 && 'w-96 h-96 top-0 -left-48',
              i === 1 && 'w-72 h-72 top-1/2 right-0',
              i === 2 && 'w-80 h-80 bottom-0 left-1/3'
            )}
            style={{
              animation: `blob ${15 + i * 5}s infinite alternate`,
              animationDelay: `${i * 2}s`,
            }}
          />
        ))}
      </div>

      {/* Content */}
      <div className="relative z-10">{children}</div>

      {/* Required keyframes - add to global CSS */}
      <style jsx global>{`
        @keyframes blob {
          0% {
            transform: translate(0, 0) scale(1);
          }
          33% {
            transform: translate(30px, -50px) scale(1.1);
          }
          66% {
            transform: translate(-20px, 20px) scale(0.9);
          }
          100% {
            transform: translate(0, 0) scale(1);
          }
        }
      `}</style>
    </div>
  );
}
```

---

## 3. Grid Background

Subtle grid pattern. Technical/futuristic feel.

### The Component

```tsx
// components/GridBackground.tsx
import { cn } from '@/lib/utils';

interface GridBackgroundProps {
  children?: React.ReactNode;
  className?: string;
  gridSize?: number;
  gridColor?: string;
  fadeFromTop?: boolean;
}

export function GridBackground({
  children,
  className,
  gridSize = 40,
  gridColor = 'rgba(255,255,255,0.03)',
  fadeFromTop = true,
}: GridBackgroundProps) {
  return (
    <div
      className={cn('relative min-h-screen', className)}
      style={{
        backgroundImage: `
          linear-gradient(${gridColor} 1px, transparent 1px),
          linear-gradient(90deg, ${gridColor} 1px, transparent 1px)
        `,
        backgroundSize: `${gridSize}px ${gridSize}px`,
      }}
    >
      {/* Fade gradient */}
      {fadeFromTop && (
        <div className="absolute inset-0 bg-gradient-to-b from-background via-transparent to-background" />
      )}

      {/* Content */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

### Grid with Glow Effect

```tsx
// components/GridBackgroundGlow.tsx
import { cn } from '@/lib/utils';

export function GridBackgroundGlow({
  children,
  className,
}: {
  children?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('relative min-h-screen bg-black', className)}>
      {/* Grid */}
      <div
        className="absolute inset-0 opacity-20"
        style={{
          backgroundImage: `
            linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px),
            linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)
          `,
          backgroundSize: '50px 50px',
        }}
      />

      {/* Central glow */}
      <div className="absolute inset-0 bg-gradient-radial from-primary/20 via-transparent to-transparent" />

      {/* Content */}
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

---

## 4. Dot Pattern Background

Subtle dots. Minimal and clean.

### The Component

```tsx
// components/DotBackground.tsx
import { cn } from '@/lib/utils';

interface DotBackgroundProps {
  children?: React.ReactNode;
  className?: string;
  dotSize?: number;
  dotSpacing?: number;
  dotColor?: string;
}

export function DotBackground({
  children,
  className,
  dotSize = 1,
  dotSpacing = 20,
  dotColor = 'rgba(0,0,0,0.1)',
}: DotBackgroundProps) {
  return (
    <div
      className={cn('relative min-h-screen', className)}
      style={{
        backgroundImage: `radial-gradient(${dotColor} ${dotSize}px, transparent ${dotSize}px)`,
        backgroundSize: `${dotSpacing}px ${dotSpacing}px`,
      }}
    >
      {children}
    </div>
  );
}
```

---

## 5. Gradient Mesh Background

Modern mesh gradient. Very premium.

### The Component

```tsx
// components/MeshGradientBackground.tsx
import { cn } from '@/lib/utils';

interface MeshGradientBackgroundProps {
  children?: React.ReactNode;
  className?: string;
}

export function MeshGradientBackground({
  children,
  className,
}: MeshGradientBackgroundProps) {
  return (
    <div
      className={cn('relative min-h-screen', className)}
      style={{
        background: `
          radial-gradient(at 40% 20%, hsla(228, 80%, 60%, 0.3) 0px, transparent 50%),
          radial-gradient(at 80% 0%, hsla(189, 100%, 56%, 0.2) 0px, transparent 50%),
          radial-gradient(at 0% 50%, hsla(355, 85%, 63%, 0.2) 0px, transparent 50%),
          radial-gradient(at 80% 50%, hsla(340, 65%, 58%, 0.2) 0px, transparent 50%),
          radial-gradient(at 0% 100%, hsla(269, 79%, 59%, 0.2) 0px, transparent 50%),
          radial-gradient(at 80% 100%, hsla(196, 100%, 50%, 0.2) 0px, transparent 50%),
          radial-gradient(at 0% 0%, hsla(200, 100%, 50%, 0.2) 0px, transparent 50%)
        `,
        backgroundColor: 'hsl(var(--background))',
      }}
    >
      {children}
    </div>
  );
}
```

---

## 6. Particle Background (Canvas-based)

Floating particles. Interactive option available.

### The Component

```tsx
// components/ParticleBackground.tsx
'use client';

import { useEffect, useRef } from 'react';
import { cn } from '@/lib/utils';

interface ParticleBackgroundProps {
  children?: React.ReactNode;
  className?: string;
  particleCount?: number;
  particleColor?: string;
  interactive?: boolean;
}

export function ParticleBackground({
  children,
  className,
  particleCount = 50,
  particleColor = 'rgba(255,255,255,0.5)',
  interactive = false,
}: ParticleBackgroundProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationId: number;
    let mouseX = 0;
    let mouseY = 0;

    // Set canvas size
    const resize = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };
    resize();
    window.addEventListener('resize', resize);

    // Particle class
    class Particle {
      x: number;
      y: number;
      size: number;
      speedX: number;
      speedY: number;

      constructor() {
        this.x = Math.random() * canvas!.width;
        this.y = Math.random() * canvas!.height;
        this.size = Math.random() * 2 + 1;
        this.speedX = Math.random() * 0.5 - 0.25;
        this.speedY = Math.random() * 0.5 - 0.25;
      }

      update() {
        this.x += this.speedX;
        this.y += this.speedY;

        if (interactive) {
          const dx = mouseX - this.x;
          const dy = mouseY - this.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          if (distance < 100) {
            this.x -= dx * 0.01;
            this.y -= dy * 0.01;
          }
        }

        // Wrap around
        if (this.x > canvas!.width) this.x = 0;
        if (this.x < 0) this.x = canvas!.width;
        if (this.y > canvas!.height) this.y = 0;
        if (this.y < 0) this.y = canvas!.height;
      }

      draw() {
        ctx!.fillStyle = particleColor;
        ctx!.beginPath();
        ctx!.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx!.fill();
      }
    }

    // Create particles
    const particles = Array.from({ length: particleCount }, () => new Particle());

    // Animation loop
    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      particles.forEach((p) => {
        p.update();
        p.draw();
      });
      animationId = requestAnimationFrame(animate);
    };
    animate();

    // Mouse tracking for interactive mode
    const handleMouseMove = (e: MouseEvent) => {
      mouseX = e.clientX;
      mouseY = e.clientY;
    };
    if (interactive) {
      window.addEventListener('mousemove', handleMouseMove);
    }

    return () => {
      cancelAnimationFrame(animationId);
      window.removeEventListener('resize', resize);
      window.removeEventListener('mousemove', handleMouseMove);
    };
  }, [particleCount, particleColor, interactive]);

  return (
    <div className={cn('relative min-h-screen', className)}>
      <canvas
        ref={canvasRef}
        className="absolute inset-0 pointer-events-none"
      />
      <div className="relative z-10">{children}</div>
    </div>
  );
}
```

---

## 7. Beams Background

Animated light beams. Dramatic effect.

### The Component

```tsx
// components/BeamsBackground.tsx
import { cn } from '@/lib/utils';

export function BeamsBackground({
  children,
  className,
}: {
  children?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('relative min-h-screen overflow-hidden bg-black', className)}>
      {/* Beams */}
      <div className="absolute inset-0">
        {[...Array(5)].map((_, i) => (
          <div
            key={i}
            className="absolute h-[200%] w-px bg-gradient-to-b from-transparent via-primary/50 to-transparent"
            style={{
              left: `${20 + i * 15}%`,
              top: '-50%',
              animation: `beam ${3 + i}s ease-in-out infinite`,
              animationDelay: `${i * 0.5}s`,
              transform: 'rotate(15deg)',
            }}
          />
        ))}
      </div>

      {/* Content */}
      <div className="relative z-10">{children}</div>

      <style jsx global>{`
        @keyframes beam {
          0%, 100% {
            opacity: 0.3;
            transform: rotate(15deg) translateY(0);
          }
          50% {
            opacity: 0.8;
            transform: rotate(15deg) translateY(-10%);
          }
        }
      `}</style>
    </div>
  );
}
```

---

## Usage Examples

### Hero with Aurora

```tsx
<AuroraBackground>
  <div className="flex flex-col items-center justify-center min-h-screen text-center px-4">
    <h1 className="text-6xl font-bold">Welcome</h1>
    <p className="text-xl text-muted-foreground mt-4">
      Subtitle goes here
    </p>
  </div>
</AuroraBackground>
```

### Feature Section with Grid

```tsx
<GridBackground className="py-20">
  <div className="container mx-auto">
    <h2>Features</h2>
    <div className="grid grid-cols-3 gap-6">
      {/* Feature cards */}
    </div>
  </div>
</GridBackground>
```

## Performance Notes

- Canvas-based particles: More performant for many particles
- CSS-based blobs: Better for simple animations
- Always test on mobile - disable complex backgrounds if needed

```tsx
const isMobile = useIsMobile();

{isMobile ? (
  <SimpleGradient>{children}</SimpleGradient>
) : (
  <ParticleBackground>{children}</ParticleBackground>
)}
```

## Accessibility

Ensure sufficient contrast for content over backgrounds:

```tsx
<AuroraBackground>
  {/* Add overlay for text contrast */}
  <div className="bg-background/80 backdrop-blur-sm rounded-lg p-8">
    <h1>Readable text</h1>
  </div>
</AuroraBackground>
```
