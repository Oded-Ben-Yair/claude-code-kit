# Tech4All Showcase - Project Instructions

**Project Type:** Marketing showcase website for Tech4All AI-powered fintech platform
**Status:** Implementation COMPLETE, deployment PENDING
**Brand:** "The Prism of Intelligence" — Void Black + neon phase beams

---

## Quick Context

Tech4All is a showcase website presenting 8 AI-powered products across 3 phases:
- **Phase 1 - Insight:** Sentimark, MarketPulse AI (Electric Cyan #00F0FF)
- **Phase 2 - Engagement:** TradeCoach AI, Compliance Exam, QC Call Analyzer, CS Agents (Laser Magenta #FF00AA)
- **Phase 3 - Security:** FraudShield AI, Phone Spam Checker (Toxic Lime #CCFF00)

---

## Brand Identity

| Element | Value |
|---------|-------|
| Background | `#050505` Void Black |
| Surfaces | `#1A1A1A` Graphite |
| Text | `#F2F2F2` Photonic White |
| Insight accent | `#00F0FF` Electric Cyan |
| Engagement accent | `#FF00AA` Laser Magenta |
| Security accent | `#CCFF00` Toxic Lime |
| Heading font | **Space Grotesk** (Google Font) |
| Body font | **DM Mono** (Google Font) |
| Logo | Glass prism refracting light into 3 phase beams |

---

## Architecture Decisions

| Decision | Rationale |
|----------|-----------|
| Hybrid navigation (Lifecycle + Audience) | Multi-model debate consensus |
| Next.js 14 App Router | Static export, optimized builds |
| Tailwind CSS + Framer Motion | Phase colors, engaging animations |
| Phase color-coding | Visual hierarchy for product lifecycle |
| "Prism of Intelligence" brand | Dual-model brainstorm consensus (Feb 2026) |

---

## Key Patterns

### Phase Colors
```css
[data-phase="insight"] { --phase-accent: #00F0FF; }    /* Electric Cyan */
[data-phase="engagement"] { --phase-accent: #FF00AA; } /* Laser Magenta */
[data-phase="security"] { --phase-accent: #CCFF00; }   /* Toxic Lime */
```

### Framer Motion Testing
When taking screenshots, force animation visibility:
```javascript
document.querySelectorAll('*').forEach(el => {
  if (getComputedStyle(el).opacity === '0') el.style.opacity = '1';
  if (getComputedStyle(el).transform !== 'none') el.style.transform = 'none';
});
```

---

## File Structure

```
app/
├── page.tsx              # Homepage with product grid
├── about/page.tsx        # About Tech4All
├── contact/page.tsx      # Contact form
└── insight/[product]/    # Dynamic product detail pages

components/
├── navigation.tsx        # Main nav with lifecycle tabs
├── product-card.tsx      # Product showcase card
├── hero-section.tsx      # Homepage hero
└── phase-section.tsx     # Phase color-coded section

lib/products/             # Product data and types
```

---

## Commands

```bash
npm run dev      # Start dev server (localhost:3000)
npm run build    # Build for production
npm run export   # Static export to /out
```

---

## Live Product URLs

These are the REAL products that Tech4All showcases:

| Product | Live URL |
|---------|----------|
| Sentimark | https://sentimark-v2-frontend.azurewebsites.net/v2 |
| QC Call Analyzer | https://icy-coast-0265d5310.3.azurestaticapps.net/ |
| Compliance Exam | https://yellow-hill-0a3781903.3.azurestaticapps.net |

---

## Current State (2026-01-28)

- **Implementation:** COMPLETE (all 7 steps done)
- **Visual Tests:** PASSED (Gemini Vision 8.6-9.6/10)
- **Git:** NOT INITIALIZED
- **Deployment:** PENDING

### Next Steps
1. **P0:** Create interactive live app captures for product demos
2. **P1:** Initialize git, push to Azure DevOps
3. **P2:** Deploy to Azure Static Web Apps

---

## Session History

| Date | Session ID | Summary |
|------|------------|---------|
| 2026-01-27 | 9192 | Architecture design, multi-model debate |
| 2026-01-28 | tech4all-showcase-session-20260128-2dde7c | Full implementation, visual tests |

---

## Memory MCP References

```
mcp__memory__open_nodes with:
- "tech4all-showcase-decisions" (architecture)
- "tech4all-showcase-session-20260128-2dde7c" (last session)
```

---

## Constraints

- **No mock data** - Use real product information
- **Phase consistency** - Always use correct phase colors
- **Mobile-first** - Test at 375px viewport
- **Azure DevOps only** - No GitHub
