# Anti-Patterns Reference

What NOT to do. These patterns signal "AI slop" or amateur design.

## Typography Anti-Patterns

| Pattern | Why It's Bad | Instead |
|---------|--------------|---------|
| Inter, Roboto, Arial | Overused, signals AI/template | Bricolage Grotesque, Space Grotesk |
| Single font layouts | No visual hierarchy | Pair serif + sans |
| `font-weight: bold` | Imprecise, generic | Exact weights (685, 535) |
| Fixed breakpoint text | Rigid, jumpy | Fluid `clamp()` scaling |
| Default letter-spacing | Unrefined | Negative for large, positive for caps |
| Default line-height | Poor readability | 1.1-1.2 headings, 1.5-1.6 body |

---

## Animation Anti-Patterns

| Pattern | Why It's Bad | Instead |
|---------|--------------|---------|
| Bounce easing everywhere | Childish, unprofessional | cubic-bezier(0.16, 1, 0.3, 1) |
| Linear easing | Mechanical, unnatural | Ease-out for most |
| Generic fade-in | Boring, expected | Directional reveal, stagger |
| >500ms duration | Frustrating, slow | 200-400ms for most |
| Simultaneous animations | Chaotic, overwhelming | Stagger with 50-100ms delays |
| Layout animations | Janky, 30fps | Transform/opacity only |
| Auto-playing loops | Distracting, annoying | User-triggered or subtle |

---

## Visual Effects Anti-Patterns

| Pattern | Why It's Bad | Instead |
|---------|--------------|---------|
| Rainbow gradients | Dated, 2015 aesthetic | 2-3 color subtle gradients |
| Parallax on everything | Nauseating, overused | One parallax element max |
| Stock glassmorphism | Generic, everywhere | Custom blur with brand colors |
| Purposeless particles | Slow, distracting | Particles with purpose or none |
| Glowing everything | Cheap, gaming aesthetic | Strategic accent glows only |
| Neon colors on white | Eye strain | Neon on dark backgrounds only |
| Drop shadow on everything | Heavy, dated | Subtle shadows, sparingly |

---

## Interaction Anti-Patterns

| Pattern | Why It's Bad | Instead |
|---------|--------------|---------|
| Hover effect on everything | Noisy, meaningless | Only on interactive elements |
| Same hover pattern everywhere | Boring, lazy | Vary by element type |
| Instant state changes | Jarring, unpolished | 150-200ms transitions |
| Cursor effects everywhere | Distracting, slow | Creative sites only, one effect |
| Ripples on non-buttons | Confusing, wrong pattern | Material ripple on buttons only |
| Tooltip on everything | Cluttered | Only when needed for clarity |

---

## Layout Anti-Patterns

| Pattern | Why It's Bad | Instead |
|---------|--------------|---------|
| Equal spacing everywhere | Monotonous | Varied spacing for hierarchy |
| Centered everything | Boring, hard to scan | Left-align text, strategic center |
| Standard 12-col grid | Template look | Custom grids, asymmetry |
| Hero image overlay text (again) | Overused | Split layout, integrated text |
| Card grid, card grid, card grid | Lazy repetition | Vary content presentation |
| Full-width everything | No breathing room | Max-width containers |

---

## The "One Per Viewport" Rule

These effects are powerful but must be used sparingly. Only ONE of each per visible screen:

- [ ] Magnetic button (one CTA)
- [ ] Custom cursor (one style)
- [ ] Aurora/blob/particle background (pick one)
- [ ] Tracing beam (one)
- [ ] 3D floating element (one)
- [ ] Parallax effect (one)
- [ ] Auto-playing animation loop (one or zero)

---

## The Restraint Checklist

Before adding ANY effect, ask:

1. **Does it serve a purpose?** (guide, inform, or genuinely delight)
2. **Would removing it hurt the UX?** If not, remove it
3. **Is there already a similar effect nearby?** Don't stack
4. **Will it perform on mobile?** Test 60fps
5. **Does it respect `prefers-reduced-motion`?** Provide fallback

---

## "Looks AI-Generated" Red Flags

If your design has 3+ of these, it probably looks AI-generated:

- [ ] Blue/purple gradient hero
- [ ] Inter or Roboto font
- [ ] Generic card grid with shadows
- [ ] "Get Started" CTA with gradient
- [ ] Abstract blob in corner
- [ ] Stock 3D illustrations
- [ ] Centered everything
- [ ] Feature icons in circles
- [ ] Generic testimonial carousel
- [ ] "Trusted by" logo bar

---

## How to Fix AI-Looking Designs

1. **Typography first** - Change fonts immediately
2. **Remove, don't add** - Strip effects down to essentials
3. **Add asymmetry** - Break the grid intentionally
4. **Custom imagery** - Replace stock/generated images
5. **Brand colors** - Use real brand palette, not gradients
6. **Micro-details** - Custom icons, unique hover states
7. **Negative space** - Let elements breathe
8. **One hero effect** - Pick ONE interesting thing

---

## Quick Self-Check

Run through this before shipping:

```
[ ] Fonts are distinctive (not Inter/Roboto/Arial)
[ ] Typography has clear hierarchy (serif + sans or weight variation)
[ ] Only transform/opacity animations
[ ] No more than one "hero" effect per viewport
[ ] Effects have purpose (not just decoration)
[ ] Mobile performance is 60fps
[ ] Reduced motion fallback exists
[ ] It doesn't look like every other AI-generated landing page
```
