# Tech4All v2 - Capability Map

**Created**: 2026-01-29
**Purpose**: Quick reference for routing ChatGPT audit feedback to correct tools

---

## Quick Router

| Feedback Type | Use This | How |
|---------------|----------|-----|
| **Copy needs rewriting** | `/b2b-copy-writer` skill | PAS framework, anti-slop |
| **UI looks wrong** | `/frontend` skill | Design-to-code mode |
| **Animation/effects needed** | `/frontend` (effects mode) | Premium effects library |
| **Logo/icon issues** | `/image-asset-studio` skill | Gemini image generation |
| **Need to verify fix** | `gemini-specialist` agent | Screenshot + vision analysis |
| **Major UX decision** | `/multi-model-debate` skill | 6-model council |
| **Brainstorm solutions** | `azure_brainstorm` MCP | GPT-5 Pro ideation |
| **Technical component** | `code-worker` agent | Implementation |
| **Accessibility issue** | `/frontend` (audit mode) | WCAG compliance |

---

## Capability Categories

### 1. CONTENT / COPY WRITING

| Tool | Use For | Strengths |
|------|---------|-----------|
| **`/b2b-copy-writer` skill** (NEW) | Headlines, features, CTAs | PAS framework, anti-AI-slop |
| **`grok_brand_content` MCP** | Social media, tweets | Human tone, witty personality |
| **`azure_chat` (GPT-5.2)** | Long-form content | Extended context, coherent |

**Workflow for Copy Changes**:
```
1. Identify problem area from audit
2. Load /b2b-copy-writer skill for templates
3. Draft using PAS framework
4. Check against anti-slop rules
5. Generate 2-3 variants for A/B
```

### 2. UI / FRONTEND DESIGN

| Tool | Use For | Strengths |
|------|---------|-----------|
| **`/frontend` skill** | All frontend work | Smart routing to correct mode |
| **`gemini-analyze-image`** | Visual validation | Screenshot comparison |
| **`playwright` MCP** | Browser automation | Screenshots, interaction |

**Frontend Modes Available**:
- `design-to-code` - Convert mockups to React
- `effects` - Animations, hover, backgrounds
- `audit` - Accessibility, WCAG
- `figma` - Figma-specific workflows
- `verify` - Visual regression testing

**Workflow for UI Changes**:
```
1. Identify visual issue from audit
2. Take screenshot: mcp__playwright__browser_take_screenshot
3. Analyze: mcp__gemini__gemini-analyze-image
4. Load /frontend skill in appropriate mode
5. Implement fix
6. Re-screenshot and verify
```

### 3. UX / DECISION MAKING

| Tool | Use For | Strengths |
|------|---------|-----------|
| **`/multi-model-debate` skill** | Major decisions | 6-model consensus |
| **`azure_brainstorm` MCP** | Generate options | GPT-5 Pro creativity |
| **`reasoning-specialist` agent** | Analyze trade-offs | Decision matrix |
| **`gemini-query` (high)** | Complex reasoning | 37.5% HLE benchmark |

**Workflow for UX Decisions**:
```
1. Identify UX issue from audit
2. If minor: brainstorm with azure_brainstorm
3. If major: use /multi-model-debate
4. Document decision in Memory MCP
5. Implement chosen approach
```

### 4. IMAGE / ASSET CREATION

| Tool | Use For | Strengths |
|------|---------|-----------|
| **`/image-asset-studio` skill** | Full asset workflow | Comprehensive |
| **`gemini-generate-image`** | New images | 1K/2K/4K quality |
| **`gemini-edit-image`** | Modify existing | Inpaint, outpaint |

**Workflow for Asset Changes**:
```
1. Identify asset issue from audit
2. If new asset: gemini-generate-image
3. If edit existing: gemini-edit-image
4. Iterate with gemini-session-edit
5. Final at 4K resolution
```

### 5. VERIFICATION / QA

| Tool | Use For | Strengths |
|------|---------|-----------|
| **`gemini-specialist` agent** | Visual verification | Screenshot analysis |
| **`/frontend` (audit mode)** | Accessibility | WCAG compliance |
| **`playwright` MCP** | Browser testing | Automation |

**Visual Validation Protocol**:
```
1. Navigate: mcp__playwright__browser_navigate
2. Screenshot: mcp__playwright__browser_take_screenshot
3. Analyze: mcp__gemini__gemini-analyze-image
   Query: "Check: background color, text visible, layout correct, no broken elements"
4. Fix issues
5. Re-verify until PASS
```

---

## Audit Feedback Categories → Routes

### Copy/Content Issues
```
"Value prop unclear" → /b2b-copy-writer (hero templates)
"Too much jargon" → /b2b-copy-writer (anti-slop rules)
"CTA weak" → /b2b-copy-writer (CTA hierarchy)
"Feature description vague" → /b2b-copy-writer (PAS micro-format)
"Sounds like AI" → /b2b-copy-writer (banned phrases check)
```

### Visual/UI Issues
```
"Layout broken" → /frontend (design-to-code)
"Colors inconsistent" → /frontend (brand presets)
"Animation janky" → /frontend (effects mode)
"Not responsive" → /frontend (breakpoint testing)
"Phase colors wrong" → Check tailwind config
```

### UX/Flow Issues
```
"Can't find product" → Navigation restructure (brainstorm first)
"Demo not working" → Debug demo component
"User journey confusing" → /multi-model-debate for major rethink
"CTA placement poor" → /frontend + /b2b-copy-writer
```

### Trust/Credibility Issues
```
"No social proof" → Add testimonials section
"Missing credentials" → Add trust badges
"Vague claims" → /b2b-copy-writer (evidence-backed templates)
```

### Technical Issues
```
"Slow loading" → Performance audit
"Mobile broken" → /frontend (responsive testing)
"Demo crashes" → Debug with code-worker
```

---

## Phase-Specific Styling

Remember Tech4All's phase colors:

```css
/* Phase 1 - Insight */
--insight: #00D4FF;  /* Cyan */

/* Phase 2 - Engagement */
--engagement: #FF00FF;  /* Magenta */

/* Phase 3 - Security */
--security: #00FF8C;  /* Lime */
```

When making changes, ensure phase color consistency.

---

## Priority Framework

When receiving audit feedback, categorize:

| Priority | Definition | Action |
|----------|------------|--------|
| **P0** | Conversion blocker | Fix this week |
| **P1** | Major UX issue | Fix this sprint |
| **P2** | Nice-to-have improvement | Backlog |
| **P3** | Polish/minor | Future |

---

## Commands Quick Reference

```bash
# Skills
/b2b-copy-writer      # Website copy
/frontend             # UI/design work
/image-asset-studio   # Image assets
/multi-model-debate   # Major decisions

# MCP Tools
mcp__grok__grok_brand_content     # Social content
mcp__azure-ai-foundry__azure_brainstorm  # Ideation
mcp__gemini__gemini-analyze-image  # Visual validation
mcp__playwright__browser_take_screenshot  # Screenshots

# Agents (via Task tool)
gemini-specialist     # Vision + images
reasoning-specialist  # Complex analysis
code-worker          # Implementation
```

---

## Ready State Checklist

Before processing audit feedback:

- [x] `/b2b-copy-writer` skill created and loaded
- [x] `/frontend` skill available with all modes
- [x] `gemini-specialist` agent ready for visual validation
- [x] `reasoning-specialist` agent ready for decisions
- [x] `grok_brand_content` MCP for social tone
- [x] `azure_brainstorm` MCP for ideation
- [x] Phase colors documented
- [x] Capability routing table ready

**Status: READY FOR AUDIT FEEDBACK**
