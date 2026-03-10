# 3D Effects Overview - React Three Fiber

Setup, best practices, and performance guidelines for 3D web experiences.

## When to Use 3D

### Good Use Cases
- Product showcases (rotate, zoom)
- Hero section backgrounds
- Interactive data visualizations
- Landing page "wow" moments
- Portfolio pieces

### Avoid 3D When
- Mobile is primary target (performance)
- Content-heavy pages (distraction)
- Fast load times critical
- Accessibility is paramount
- Budget/time constraints

---

## Setup

### Installation

```bash
npm install three @react-three/fiber @react-three/drei
```

### TypeScript Types

```bash
npm install -D @types/three
```

### Basic Canvas Setup

```tsx
// components/Scene.tsx
'use client';

import { Canvas } from '@react-three/fiber';
import { Suspense } from 'react';

interface SceneProps {
  children: React.ReactNode;
  className?: string;
}

export function Scene({ children, className }: SceneProps) {
  return (
    <div className={className}>
      <Canvas
        camera={{ position: [0, 0, 5], fov: 50 }}
        dpr={[1, 2]}  // Device pixel ratio
        gl={{ antialias: true, alpha: true }}
      >
        <Suspense fallback={null}>
          {children}
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## Essential Drei Helpers

```tsx
import {
  // Camera controls
  OrbitControls,
  PerspectiveCamera,

  // Lighting
  Environment,
  Lightformer,

  // Effects
  Float,
  MeshDistortMaterial,
  MeshWobbleMaterial,
  Sparkles,

  // Utilities
  useTexture,
  useGLTF,
  Html,
  Text,
  Text3D,

  // Performance
  Preload,
  PerformanceMonitor,
  AdaptiveDpr,
} from '@react-three/drei';
```

---

## Performance Best Practices

### 1. Limit Draw Calls

```tsx
// BAD: Many separate meshes
{items.map((item) => (
  <mesh key={item.id}>
    <boxGeometry />
    <meshStandardMaterial />
  </mesh>
))}

// GOOD: Instanced mesh for many similar objects
<instancedMesh args={[undefined, undefined, items.length]}>
  <boxGeometry />
  <meshStandardMaterial />
</instancedMesh>
```

### 2. Optimize Geometry

```tsx
// Use low poly counts
<sphereGeometry args={[1, 16, 16]} />  // Good for background
<sphereGeometry args={[1, 64, 64]} />  // Only if close-up needed
```

### 3. Texture Optimization

```tsx
// Compress textures, use appropriate sizes
const texture = useTexture('/texture.webp');  // Use WebP
texture.minFilter = THREE.LinearFilter;       // Optimize filtering
```

### 4. Conditional Rendering

```tsx
import { useThree } from '@react-three/fiber';

function AdaptiveScene() {
  const { viewport } = useThree();
  const isMobile = viewport.width < 5;

  return isMobile ? <SimplifiedScene /> : <FullScene />;
}
```

### 5. Frame Rate Management

```tsx
<Canvas frameloop="demand">  {/* Only render when needed */}
  {/* or */}
</Canvas>

<Canvas frameloop="always">  {/* Continuous animation */}
  {/* Content */}
</Canvas>
```

### 6. Use PerformanceMonitor

```tsx
import { PerformanceMonitor, AdaptiveDpr } from '@react-three/drei';

<Canvas>
  <PerformanceMonitor
    onDecline={() => setDpr(1)}
    onIncline={() => setDpr(2)}
  >
    <AdaptiveDpr pixelated />
    {/* Scene content */}
  </PerformanceMonitor>
</Canvas>
```

---

## Common Patterns

### Floating Object

```tsx
import { Float } from '@react-three/drei';

function FloatingObject() {
  return (
    <Float
      speed={2}
      rotationIntensity={1}
      floatIntensity={2}
      floatingRange={[-0.1, 0.1]}
    >
      <mesh>
        <boxGeometry args={[1, 1, 1]} />
        <meshStandardMaterial color="#3B82F6" />
      </mesh>
    </Float>
  );
}
```

### Mouse-Following Object

```tsx
import { useFrame, useThree } from '@react-three/fiber';
import { useRef } from 'react';
import * as THREE from 'three';

function MouseFollower() {
  const meshRef = useRef<THREE.Mesh>(null);
  const { mouse, viewport } = useThree();

  useFrame(() => {
    if (!meshRef.current) return;
    meshRef.current.position.x = THREE.MathUtils.lerp(
      meshRef.current.position.x,
      (mouse.x * viewport.width) / 2,
      0.1
    );
    meshRef.current.position.y = THREE.MathUtils.lerp(
      meshRef.current.position.y,
      (mouse.y * viewport.height) / 2,
      0.1
    );
  });

  return (
    <mesh ref={meshRef}>
      <sphereGeometry args={[0.5, 32, 32]} />
      <meshStandardMaterial color="#8B5CF6" />
    </mesh>
  );
}
```

### Environment Lighting

```tsx
import { Environment } from '@react-three/drei';

function LitScene() {
  return (
    <>
      <Environment preset="city" />  {/* Or: studio, sunset, dawn, night, etc. */}
      {/* Your objects */}
    </>
  );
}
```

### Custom Environment

```tsx
import { Environment, Lightformer } from '@react-three/drei';

function CustomEnvironment() {
  return (
    <Environment resolution={256}>
      <Lightformer
        form="ring"
        intensity={2}
        position={[0, 5, -5]}
        scale={10}
      />
      <Lightformer
        form="rect"
        intensity={1}
        position={[-5, 0, 0]}
        scale={5}
        color="#3B82F6"
      />
    </Environment>
  );
}
```

---

## Loading 3D Models

### GLTF/GLB Files

```tsx
import { useGLTF } from '@react-three/drei';

function Model({ url }: { url: string }) {
  const { scene } = useGLTF(url);
  return <primitive object={scene} />;
}

// Preload for better UX
useGLTF.preload('/model.glb');
```

### With Loading State

```tsx
import { Suspense } from 'react';
import { Html, useProgress } from '@react-three/drei';

function Loader() {
  const { progress } = useProgress();
  return <Html center>{progress.toFixed(0)}%</Html>;
}

function Scene() {
  return (
    <Canvas>
      <Suspense fallback={<Loader />}>
        <Model url="/model.glb" />
      </Suspense>
    </Canvas>
  );
}
```

---

## Scroll-Linked 3D

```tsx
import { useScroll } from '@react-three/drei';
import { useFrame } from '@react-three/fiber';

function ScrollLinkedObject() {
  const meshRef = useRef<THREE.Mesh>(null);
  const scroll = useScroll();

  useFrame(() => {
    if (!meshRef.current) return;
    // Rotate based on scroll position
    meshRef.current.rotation.y = scroll.offset * Math.PI * 2;
    // Move based on scroll
    meshRef.current.position.y = scroll.offset * 5 - 2.5;
  });

  return (
    <mesh ref={meshRef}>
      <torusGeometry args={[1, 0.3, 16, 32]} />
      <meshStandardMaterial color="#EC4899" />
    </mesh>
  );
}
```

---

## Integration with React

### Full-Page Background

```tsx
function HeroWith3D() {
  return (
    <div className="relative min-h-screen">
      {/* 3D Background */}
      <div className="absolute inset-0">
        <Scene className="w-full h-full">
          <BackgroundScene />
        </Scene>
      </div>

      {/* HTML Content */}
      <div className="relative z-10 container mx-auto px-6 py-24">
        <h1>Your Content</h1>
      </div>
    </div>
  );
}
```

### Inline 3D Element

```tsx
function ProductShowcase() {
  return (
    <div className="grid grid-cols-2 gap-8">
      {/* 3D Product */}
      <div className="aspect-square">
        <Scene className="w-full h-full">
          <ProductModel />
          <OrbitControls enableZoom={false} />
        </Scene>
      </div>

      {/* Product Info */}
      <div>
        <h2>Product Name</h2>
        <p>Description...</p>
      </div>
    </div>
  );
}
```

---

## Mobile Fallbacks

Always provide fallbacks for mobile:

```tsx
'use client';

import { useEffect, useState } from 'react';

function ResponsiveScene() {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
    const handleResize = () => setIsMobile(window.innerWidth < 768);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  if (isMobile) {
    return <StaticImage src="/product-static.png" />;
  }

  return (
    <Scene>
      <ProductModel />
    </Scene>
  );
}
```

---

## Accessibility

```tsx
<div
  role="img"
  aria-label="3D visualization of product rotating"
  className="relative"
>
  <Canvas>
    {/* Scene */}
  </Canvas>

  {/* Screen reader description */}
  <span className="sr-only">
    Interactive 3D model of the product. Use mouse to rotate.
  </span>
</div>
```

---

## Reduced Motion Support

```tsx
import { useReducedMotion } from 'framer-motion';

function AdaptiveScene() {
  const prefersReducedMotion = useReducedMotion();

  return (
    <Canvas>
      <mesh>
        <Float
          speed={prefersReducedMotion ? 0 : 2}
          rotationIntensity={prefersReducedMotion ? 0 : 1}
        >
          <boxGeometry />
          <meshStandardMaterial />
        </Float>
      </mesh>
    </Canvas>
  );
}
```

---

## Debugging

```tsx
import { Stats } from '@react-three/drei';

<Canvas>
  <Stats />  {/* Shows FPS, render time */}
  {/* Scene */}
</Canvas>
```

---

## File Organization

```
components/
├── 3d/
│   ├── Scene.tsx           # Base canvas wrapper
│   ├── FloatingShape.tsx   # Reusable floating object
│   ├── ParticleField.tsx   # Particle system
│   └── ProductModel.tsx    # Specific product model
├── scenes/
│   ├── HeroScene.tsx       # Hero background scene
│   └── ShowcaseScene.tsx   # Product showcase
└── models/
    └── *.glb               # 3D model files
```
