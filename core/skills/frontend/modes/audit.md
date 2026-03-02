# Audit Mode

Accessibility auditing, WCAG compliance, and visual quality verification.

## WCAG 2.1 Quick Reference

### Level A (Minimum - Required)

| Criterion | Requirement | How to Check |
|-----------|-------------|--------------|
| 1.1.1 Non-text Content | Alt text for images | Check all `<img>` have `alt` |
| 1.3.1 Info & Relationships | Semantic HTML | Proper headings, lists, tables |
| 2.1.1 Keyboard | All interactive via keyboard | Tab through page |
| 2.4.1 Bypass Blocks | Skip link to main content | Check for skip link |
| 4.1.1 Parsing | Valid HTML | No duplicate IDs |

### Level AA (Target - Standard)

| Criterion | Requirement | How to Check |
|-----------|-------------|--------------|
| 1.4.3 Contrast (Minimum) | 4.5:1 text, 3:1 large | Use contrast checker |
| 1.4.4 Resize Text | 200% zoom without loss | Zoom to 200% |
| 2.4.6 Headings & Labels | Descriptive headings | Check heading hierarchy |
| 2.4.7 Focus Visible | Visible focus indicator | Tab and check focus |
| 3.2.3 Consistent Navigation | Same nav across pages | Check navigation |

### Level AAA (Enhanced - Ideal)

| Criterion | Requirement | How to Check |
|-----------|-------------|--------------|
| 1.4.6 Contrast (Enhanced) | 7:1 text, 4.5:1 large | Use contrast checker |
| 2.4.9 Link Purpose | Link text describes destination | Read links out of context |

---

## Audit Workflow

### Step 1: Capture Accessibility Snapshot

```yaml
# Get accessibility tree
mcp__playwright__browser_snapshot:
  # Returns structured accessibility tree
```

### Step 2: Visual Analysis with Gemini

```yaml
# Comprehensive accessibility review
gemini-query:
  thinking_level: "high"
  media_resolution: "HIGH"
  prompt: |
    Perform an accessibility audit on this UI screenshot:

    1. COLOR CONTRAST
       - Check text-to-background contrast ratios
       - Flag any that appear below 4.5:1 (normal text) or 3:1 (large text)
       - Check UI controls and icons (3:1 minimum)

    2. TYPOGRAPHY
       - Is text large enough? (16px minimum for body)
       - Is line-height adequate? (1.5 for body text)
       - Are headings properly sized for hierarchy?

    3. INTERACTIVE ELEMENTS
       - Are click/touch targets at least 44x44px?
       - Do buttons/links have clear visual distinction?
       - Are form labels visible and associated?

    4. VISUAL HIERARCHY
       - Is the heading structure clear?
       - Can you understand the page flow?
       - Is important content visually prominent?

    5. MOTION & ANIMATION
       - Are there any auto-playing animations?
       - Would reduced-motion users be affected?

    For each issue found, provide:
    - Severity: Critical/Major/Minor
    - WCAG criterion violated
    - Location in UI
    - Specific fix recommendation
```

### Step 3: Generate Test Code

Based on issues found, generate Playwright tests with axe-core:

```typescript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.describe('Accessibility', () => {
  test('should have no automatically detectable accessibility issues', async ({ page }) => {
    await page.goto('/');

    const accessibilityScanResults = await new AxeBuilder({ page })
      .withTags(['wcag2a', 'wcag2aa', 'wcag21aa'])
      .analyze();

    expect(accessibilityScanResults.violations).toEqual([]);
  });

  test('should have proper heading hierarchy', async ({ page }) => {
    await page.goto('/');

    // Check h1 exists and is unique
    const h1Count = await page.locator('h1').count();
    expect(h1Count).toBe(1);

    // Check headings don't skip levels
    const headings = await page.locator('h1, h2, h3, h4, h5, h6').all();
    let lastLevel = 0;
    for (const heading of headings) {
      const tagName = await heading.evaluate(el => el.tagName);
      const level = parseInt(tagName[1]);
      expect(level - lastLevel).toBeLessThanOrEqual(1);
      lastLevel = level;
    }
  });

  test('should have visible focus indicators', async ({ page }) => {
    await page.goto('/');

    // Tab through interactive elements
    const interactiveElements = await page.locator(
      'a, button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
    ).all();

    for (const element of interactiveElements.slice(0, 10)) {
      await element.focus();
      // Check element has visible focus
      const focusStyles = await element.evaluate(el => {
        const styles = window.getComputedStyle(el);
        return {
          outline: styles.outline,
          boxShadow: styles.boxShadow,
          border: styles.border,
        };
      });

      // At least one focus indicator should be present
      const hasFocusIndicator =
        focusStyles.outline !== 'none' ||
        focusStyles.boxShadow !== 'none' ||
        focusStyles.border !== 'none';

      expect(hasFocusIndicator).toBe(true);
    }
  });

  test('should have adequate touch targets', async ({ page }) => {
    await page.goto('/');

    const buttons = await page.locator('button, a, [role="button"]').all();

    for (const button of buttons) {
      const box = await button.boundingBox();
      if (box) {
        // Minimum 44x44px touch target
        expect(box.width).toBeGreaterThanOrEqual(44);
        expect(box.height).toBeGreaterThanOrEqual(44);
      }
    }
  });
});
```

---

## Common Issues & Fixes

### Low Contrast Text

**Issue**: Text contrast below 4.5:1

**Fix**:
```tsx
// Before (fails)
<p className="text-gray-400">Low contrast text</p>

// After (passes)
<p className="text-gray-600">Adequate contrast text</p>

// Or for dark backgrounds
<p className="text-gray-100">Light text on dark</p>
```

### Missing Focus States

**Issue**: No visible focus indicator

**Fix**:
```tsx
// Add focus-visible for keyboard users
<button className="focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
  Click me
</button>

// Or in CSS
button:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

### Small Touch Targets

**Issue**: Buttons/links smaller than 44x44px

**Fix**:
```tsx
// Before (too small)
<button className="px-2 py-1 text-sm">Small</button>

// After (adequate)
<button className="min-h-[44px] min-w-[44px] px-4 py-2">Adequate</button>

// For icon buttons
<button className="flex h-11 w-11 items-center justify-center">
  <Icon className="h-5 w-5" />
</button>
```

### Missing Labels

**Issue**: Form inputs without labels

**Fix**:
```tsx
// Before (no label)
<input type="email" placeholder="Email" />

// After (with label)
<div>
  <label htmlFor="email" className="block text-sm font-medium">
    Email address
  </label>
  <input
    id="email"
    type="email"
    aria-describedby="email-hint"
    className="mt-1 block w-full"
  />
  <p id="email-hint" className="mt-1 text-sm text-gray-500">
    We'll never share your email.
  </p>
</div>
```

### Skipped Heading Levels

**Issue**: h1 → h3 (skipping h2)

**Fix**:
```tsx
// Before (wrong)
<h1>Page Title</h1>
<h3>Section Title</h3>

// After (correct)
<h1>Page Title</h1>
<h2>Section Title</h2>
<h3>Subsection Title</h3>
```

---

## Severity Definitions

| Severity | Impact | Timeline |
|----------|--------|----------|
| **Critical** | Blocks users, legal risk | Immediate fix |
| **Major** | Significant UX degradation | Before release |
| **Minor** | Cosmetic, minor friction | Next sprint |
| **Suggestion** | Enhancement opportunity | Backlog |

---

## Automated Testing Tools

### axe-core (Recommended)

```bash
npm install @axe-core/playwright
```

### Lighthouse CI

```bash
npm install -g @lhci/cli
lhci autorun --collect.url=http://localhost:3000
```

### Manual Testing Checklist

- [ ] Tab through entire page (keyboard only)
- [ ] Use screen reader (VoiceOver, NVDA)
- [ ] Zoom to 200%
- [ ] Test with color filters (colorblindness)
- [ ] Test with motion reduced (`prefers-reduced-motion`)

---

## Audit Report Format

```markdown
# Accessibility Audit Report

## Summary
- **URL**: [page URL]
- **Date**: [date]
- **Overall Score**: [X/100]

## Issues Found

### Critical (X issues)

#### Issue 1: [Title]
- **WCAG**: 1.4.3 Contrast
- **Location**: Hero section heading
- **Current**: 2.5:1 contrast ratio
- **Required**: 4.5:1 minimum
- **Fix**: Change text color from #9ca3af to #4b5563

### Major (X issues)
...

### Minor (X issues)
...

## Passed Checks
- [x] All images have alt text
- [x] Heading hierarchy is correct
- [x] Skip link present

## Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```
