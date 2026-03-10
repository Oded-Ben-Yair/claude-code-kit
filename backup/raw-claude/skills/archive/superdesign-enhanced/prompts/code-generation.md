# Code Generation Templates

## React Component Template

```tsx
// {ComponentName}.tsx
import React from 'react';

interface {ComponentName}Props {
  // Define props based on design spec
}

export function {ComponentName}({ ...props }: {ComponentName}Props) {
  return (
    <div className="[tailwind classes]">
      {/* Component structure from design spec */}
    </div>
  );
}
```

## Vue Component Template

```vue
<script setup lang="ts">
// {ComponentName}.vue
interface Props {
  // Define props based on design spec
}

const props = defineProps<Props>();
</script>

<template>
  <div class="[tailwind classes]">
    <!-- Component structure from design spec -->
  </div>
</template>
```

## HTML + Tailwind Template

```html
<!-- {component-name}.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{Component Name}</title>
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="[base classes]">
  <div class="[tailwind classes]">
    <!-- Component structure from design spec -->
  </div>
</body>
</html>
```

## Code Generation Rules

### Tailwind CSS Usage
- Use utility classes exclusively
- Mobile-first responsive: `sm:`, `md:`, `lg:`, `xl:`
- Dark mode support: `dark:` prefix when applicable
- Hover states: `hover:`, `focus:`, `active:`
- Group hover: `group-hover:` for parent interactions

### Accessibility Requirements
- Semantic HTML elements (`<nav>`, `<main>`, `<article>`, etc.)
- ARIA labels for interactive elements
- Role attributes where appropriate
- Tab index for keyboard navigation
- Focus visible states

### Component Patterns

#### Button
```tsx
<button
  type="button"
  className="px-4 py-2 bg-primary text-white rounded-md
             hover:bg-primary/90 focus:outline-none focus:ring-2
             focus:ring-primary focus:ring-offset-2
             transition-colors duration-200"
  aria-label="Action description"
>
  Button Text
</button>
```

#### Input
```tsx
<div className="space-y-1">
  <label htmlFor="input-id" className="text-sm font-medium text-gray-700">
    Label
  </label>
  <input
    type="text"
    id="input-id"
    className="w-full px-3 py-2 border border-gray-300 rounded-md
               focus:outline-none focus:ring-2 focus:ring-primary
               focus:border-transparent"
    placeholder="Placeholder text"
  />
</div>
```

#### Card
```tsx
<div className="bg-white rounded-lg shadow-md p-6
                hover:shadow-lg transition-shadow duration-200">
  <h3 className="text-lg font-semibold text-gray-900">Title</h3>
  <p className="mt-2 text-gray-600">Description</p>
</div>
```

### Responsive Breakpoints
```
sm: 640px
md: 768px
lg: 1024px
xl: 1280px
2xl: 1536px
```

### Color Token Mapping
Map design spec colors to Tailwind:
- `primary` → `bg-blue-600`, `text-blue-600`, etc.
- `secondary` → `bg-gray-600`
- `accent` → `bg-purple-600`
- Or use CSS custom properties for exact values
