# 3D Scenes - Background & Atmospheric Effects

Full, copy-paste React Three Fiber scenes for premium backgrounds.

## 1. Floating Shapes Scene

Minimal floating geometric shapes. Clean and modern.

### The Scene

```tsx
// components/3d/FloatingShapesScene.tsx
'use client';

import { Canvas, useFrame } from '@react-three/fiber';
import { Float, MeshDistortMaterial } from '@react-three/drei';
import { Suspense, useRef } from 'react';
import * as THREE from 'three';

function FloatingShape({
  position,
  color,
  size = 1,
  speed = 1,
}: {
  position: [number, number, number];
  color: string;
  size?: number;
  speed?: number;
}) {
  return (
    <Float speed={speed} rotationIntensity={0.5} floatIntensity={0.5}>
      <mesh position={position}>
        <icosahedronGeometry args={[size, 1]} />
        <MeshDistortMaterial
          color={color}
          speed={2}
          distort={0.3}
          radius={1}
        />
      </mesh>
    </Float>
  );
}

function Scene() {
  return (
    <>
      <ambientLight intensity={0.5} />
      <directionalLight position={[10, 10, 5]} intensity={1} />

      <FloatingShape position={[-2, 1, -2]} color="#3B82F6" size={0.8} />
      <FloatingShape position={[2, -1, -1]} color="#8B5CF6" size={0.6} />
      <FloatingShape position={[0, 2, -3]} color="#EC4899" size={0.5} />
      <FloatingShape position={[-1, -2, -2]} color="#3B82F6" size={0.4} speed={1.5} />
    </>
  );
}

export function FloatingShapesScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas camera={{ position: [0, 0, 5], fov: 50 }}>
        <Suspense fallback={null}>
          <Scene />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

### Usage

```tsx
<div className="relative min-h-screen bg-gray-900">
  <FloatingShapesScene className="absolute inset-0 opacity-60" />
  <div className="relative z-10">
    {/* Content */}
  </div>
</div>
```

---

## 2. Particle Field Scene

Floating particles with mouse interaction.

### The Scene

```tsx
// components/3d/ParticleFieldScene.tsx
'use client';

import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { Suspense, useMemo, useRef } from 'react';
import * as THREE from 'three';

function Particles({ count = 500 }: { count?: number }) {
  const meshRef = useRef<THREE.Points>(null);
  const { mouse, viewport } = useThree();

  const positions = useMemo(() => {
    const pos = new Float32Array(count * 3);
    for (let i = 0; i < count; i++) {
      pos[i * 3] = (Math.random() - 0.5) * 10;
      pos[i * 3 + 1] = (Math.random() - 0.5) * 10;
      pos[i * 3 + 2] = (Math.random() - 0.5) * 10;
    }
    return pos;
  }, [count]);

  useFrame((state) => {
    if (!meshRef.current) return;
    meshRef.current.rotation.x = state.clock.elapsedTime * 0.05;
    meshRef.current.rotation.y = state.clock.elapsedTime * 0.08;

    // Subtle mouse influence
    meshRef.current.position.x = THREE.MathUtils.lerp(
      meshRef.current.position.x,
      mouse.x * 0.5,
      0.02
    );
    meshRef.current.position.y = THREE.MathUtils.lerp(
      meshRef.current.position.y,
      mouse.y * 0.5,
      0.02
    );
  });

  return (
    <points ref={meshRef}>
      <bufferGeometry>
        <bufferAttribute
          attach="attributes-position"
          count={count}
          array={positions}
          itemSize={3}
        />
      </bufferGeometry>
      <pointsMaterial
        size={0.02}
        color="#3B82F6"
        transparent
        opacity={0.6}
        sizeAttenuation
      />
    </points>
  );
}

export function ParticleFieldScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas camera={{ position: [0, 0, 3], fov: 60 }}>
        <Suspense fallback={null}>
          <Particles count={800} />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## 3. Gradient Orbs Scene

Large, blurred gradient spheres for atmosphere.

### The Scene

```tsx
// components/3d/GradientOrbsScene.tsx
'use client';

import { Canvas, useFrame } from '@react-three/fiber';
import { Suspense, useRef } from 'react';
import * as THREE from 'three';

function GradientOrb({
  position,
  color,
  size,
  speed = 0.5,
}: {
  position: [number, number, number];
  color: string;
  size: number;
  speed?: number;
}) {
  const meshRef = useRef<THREE.Mesh>(null);
  const initialY = position[1];

  useFrame((state) => {
    if (!meshRef.current) return;
    meshRef.current.position.y =
      initialY + Math.sin(state.clock.elapsedTime * speed) * 0.3;
  });

  return (
    <mesh ref={meshRef} position={position}>
      <sphereGeometry args={[size, 32, 32]} />
      <meshBasicMaterial color={color} transparent opacity={0.3} />
    </mesh>
  );
}

function Scene() {
  return (
    <>
      <GradientOrb position={[-3, 1, -5]} color="#3B82F6" size={2} speed={0.3} />
      <GradientOrb position={[3, -1, -4]} color="#8B5CF6" size={1.5} speed={0.5} />
      <GradientOrb position={[0, 2, -6]} color="#EC4899" size={2.5} speed={0.4} />
    </>
  );
}

export function GradientOrbsScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas
        camera={{ position: [0, 0, 5], fov: 60 }}
        gl={{ antialias: true, alpha: true }}
      >
        <Suspense fallback={null}>
          <Scene />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## 4. Grid Floor Scene

Infinite grid with glow effect. Cyberpunk/futuristic.

### The Scene

```tsx
// components/3d/GridFloorScene.tsx
'use client';

import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { Grid, Environment } from '@react-three/drei';
import { Suspense, useRef } from 'react';
import * as THREE from 'three';

function AnimatedGrid() {
  const gridRef = useRef<THREE.Group>(null);

  useFrame((state) => {
    if (!gridRef.current) return;
    gridRef.current.position.z = (state.clock.elapsedTime * 0.5) % 1;
  });

  return (
    <group ref={gridRef}>
      <Grid
        position={[0, -1, 0]}
        args={[20, 20]}
        cellSize={0.5}
        cellThickness={0.5}
        cellColor="#3B82F6"
        sectionSize={2}
        sectionThickness={1}
        sectionColor="#8B5CF6"
        fadeDistance={25}
        fadeStrength={1}
        followCamera={false}
        infiniteGrid
      />
    </group>
  );
}

function Scene() {
  return (
    <>
      <fog attach="fog" args={['#0F172A', 5, 20]} />
      <AnimatedGrid />
      <Environment preset="night" />
    </>
  );
}

export function GridFloorScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas
        camera={{ position: [0, 2, 8], fov: 60, rotation: [-0.2, 0, 0] }}
        gl={{ antialias: true }}
      >
        <color attach="background" args={['#0F172A']} />
        <Suspense fallback={null}>
          <Scene />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## 5. Waveform Scene

Animated wave mesh. Good for audio/data visualization.

### The Scene

```tsx
// components/3d/WaveformScene.tsx
'use client';

import { Canvas, useFrame } from '@react-three/fiber';
import { Suspense, useMemo, useRef } from 'react';
import * as THREE from 'three';

function Wave() {
  const meshRef = useRef<THREE.Mesh>(null);

  const geometry = useMemo(() => {
    const geo = new THREE.PlaneGeometry(10, 10, 64, 64);
    geo.rotateX(-Math.PI / 2);
    return geo;
  }, []);

  useFrame((state) => {
    if (!meshRef.current) return;
    const positions = meshRef.current.geometry.attributes.position;

    for (let i = 0; i < positions.count; i++) {
      const x = positions.getX(i);
      const z = positions.getZ(i);

      const y =
        Math.sin(x * 0.5 + state.clock.elapsedTime) * 0.3 +
        Math.sin(z * 0.5 + state.clock.elapsedTime * 0.8) * 0.2;

      positions.setY(i, y);
    }

    positions.needsUpdate = true;
  });

  return (
    <mesh ref={meshRef} geometry={geometry}>
      <meshStandardMaterial
        color="#3B82F6"
        wireframe
        transparent
        opacity={0.3}
      />
    </mesh>
  );
}

function Scene() {
  return (
    <>
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} intensity={1} />
      <Wave />
    </>
  );
}

export function WaveformScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas
        camera={{ position: [0, 5, 8], fov: 50 }}
        gl={{ antialias: true, alpha: true }}
      >
        <Suspense fallback={null}>
          <Scene />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## 6. Starfield Scene

Animated stars. Classic space effect.

### The Scene

```tsx
// components/3d/StarfieldScene.tsx
'use client';

import { Canvas, useFrame } from '@react-three/fiber';
import { Stars } from '@react-three/drei';
import { Suspense, useRef } from 'react';
import * as THREE from 'three';

function RotatingStars() {
  const starsRef = useRef<THREE.Points>(null);

  useFrame((state) => {
    if (!starsRef.current) return;
    starsRef.current.rotation.x = state.clock.elapsedTime * 0.02;
    starsRef.current.rotation.y = state.clock.elapsedTime * 0.01;
  });

  return (
    <Stars
      ref={starsRef}
      radius={100}
      depth={50}
      count={5000}
      factor={4}
      saturation={0}
      fade
      speed={1}
    />
  );
}

export function StarfieldScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas camera={{ position: [0, 0, 1] }}>
        <color attach="background" args={['#000']} />
        <Suspense fallback={null}>
          <RotatingStars />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## 7. Abstract Blob Scene

Morphing blob/sphere. Organic and modern.

### The Scene

```tsx
// components/3d/BlobScene.tsx
'use client';

import { Canvas, useFrame } from '@react-three/fiber';
import { MeshDistortMaterial, Environment } from '@react-three/drei';
import { Suspense, useRef } from 'react';
import * as THREE from 'three';

function Blob() {
  const meshRef = useRef<THREE.Mesh>(null);

  useFrame((state) => {
    if (!meshRef.current) return;
    meshRef.current.rotation.x = state.clock.elapsedTime * 0.1;
    meshRef.current.rotation.y = state.clock.elapsedTime * 0.15;
  });

  return (
    <mesh ref={meshRef} scale={2}>
      <sphereGeometry args={[1, 64, 64]} />
      <MeshDistortMaterial
        color="#3B82F6"
        speed={2}
        distort={0.4}
        radius={1}
        roughness={0.2}
        metalness={0.8}
      />
    </mesh>
  );
}

function Scene() {
  return (
    <>
      <Environment preset="studio" />
      <Blob />
    </>
  );
}

export function BlobScene({ className }: { className?: string }) {
  return (
    <div className={className}>
      <Canvas
        camera={{ position: [0, 0, 5], fov: 50 }}
        gl={{ antialias: true, alpha: true }}
      >
        <Suspense fallback={null}>
          <Scene />
        </Suspense>
      </Canvas>
    </div>
  );
}
```

---

## Integration Patterns

### Hero with 3D Background

```tsx
function HeroSection() {
  return (
    <section className="relative min-h-screen bg-gray-900">
      {/* 3D Background */}
      <ParticleFieldScene className="absolute inset-0" />

      {/* Gradient overlay for readability */}
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-gray-900/50 to-gray-900" />

      {/* Content */}
      <div className="relative z-10 container mx-auto px-6 py-24 flex flex-col items-center justify-center min-h-screen text-center">
        <h1 className="text-6xl font-bold text-white">
          Your Headline
        </h1>
        <p className="text-xl text-gray-300 mt-6">
          Your subheadline
        </p>
      </div>
    </section>
  );
}
```

### Side-by-Side with 3D

```tsx
function FeatureSection() {
  return (
    <section className="grid grid-cols-2 gap-12 py-24">
      <div className="flex flex-col justify-center">
        <h2 className="text-4xl font-bold">Feature Title</h2>
        <p className="text-gray-600 mt-4">Description...</p>
      </div>

      <div className="aspect-square">
        <BlobScene className="w-full h-full" />
      </div>
    </section>
  );
}
```

---

## Mobile Fallbacks

```tsx
function ResponsiveHero() {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    setIsMobile(window.innerWidth < 768);
  }, []);

  return (
    <section className="relative min-h-screen">
      {isMobile ? (
        // Static gradient for mobile
        <div className="absolute inset-0 bg-gradient-to-br from-blue-600/20 via-purple-600/20 to-pink-600/20" />
      ) : (
        // 3D scene for desktop
        <ParticleFieldScene className="absolute inset-0" />
      )}
      {/* Content */}
    </section>
  );
}
```
