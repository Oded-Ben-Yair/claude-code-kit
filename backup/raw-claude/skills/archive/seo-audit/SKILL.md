---
name: seo-audit
description: Comprehensive technical SEO audit for 2026 including AI crawler optimization, Core Web Vitals, and AEO readiness
triggers:
  - seo audit
  - technical seo
  - site audit
  - crawlability check
  - seo analysis
---

# SEO Audit Skill

**Purpose**: Perform comprehensive technical SEO audits including modern AI-era requirements (llms.txt, AEO readiness, AI crawler access).

---

## Audit Checklist

### Phase 1: Crawlability & Indexation

#### robots.txt Analysis
- [ ] File exists at /robots.txt
- [ ] No critical pages blocked
- [ ] AI crawler directives reviewed:
  - [ ] GPTBot (OpenAI training)
  - [ ] OAI-SearchBot (OpenAI real-time)
  - [ ] Claude-Web (Anthropic)
  - [ ] PerplexityBot
  - [ ] Google-Extended (Gemini)
  - [ ] CCBot (Common Crawl)
- [ ] Crawl-delay appropriate
- [ ] Sitemap referenced

#### XML Sitemap
- [ ] Exists at /sitemap.xml
- [ ] All canonical URLs included
- [ ] No noindex pages included
- [ ] No 404/redirect URLs
- [ ] Image sitemap exists (if applicable)
- [ ] Video sitemap exists (if applicable)
- [ ] Submitted to Search Console

#### llms.txt (AI Discovery)
- [ ] File exists at /llms.txt
- [ ] Markdown format correct
- [ ] Priority content listed
- [ ] UTF-8 encoding
- [ ] Descriptions provided for URLs

### Phase 2: Site Architecture

#### URL Structure
- [ ] Clean, descriptive URLs
- [ ] Lowercase with hyphens
- [ ] Max 3 levels deep
- [ ] No duplicate content
- [ ] Proper canonicalization

#### Internal Linking
- [ ] Breadcrumb navigation
- [ ] Logical hierarchy
- [ ] No orphan pages
- [ ] Contextual links with descriptive anchors
- [ ] Authority flows to priority pages

### Phase 3: Core Web Vitals

| Metric | Target | Check |
|--------|--------|-------|
| LCP (Largest Contentful Paint) | < 2.5s | [ ] |
| INP (Interaction to Next Paint) | < 200ms | [ ] |
| CLS (Cumulative Layout Shift) | < 0.1 | [ ] |

#### Performance Factors
- [ ] Server response < 600ms
- [ ] Critical CSS inlined
- [ ] Non-critical JS deferred
- [ ] Images optimized (WebP/AVIF)
- [ ] Images have explicit dimensions
- [ ] Font-display: swap used

### Phase 4: Mobile Optimization

- [ ] Responsive design implemented
- [ ] Mobile-friendly test passes
- [ ] Touch targets 48px+
- [ ] Text readable without zoom
- [ ] No horizontal scroll
- [ ] Viewport meta tag correct

### Phase 5: Schema Markup

#### Priority Schema Types
- [ ] Organization
- [ ] WebSite (with search action)
- [ ] BreadcrumbList
- [ ] FAQPage (for AEO)
- [ ] HowTo (for AEO)
- [ ] Product (if applicable)
- [ ] LocalBusiness (if applicable)
- [ ] Article (for blog content)

#### Implementation
- [ ] JSON-LD format used
- [ ] Validates in Rich Results Test
- [ ] No errors in Schema Validator
- [ ] Self-referencing canonical

### Phase 6: Security & Technical

- [ ] HTTPS on all pages
- [ ] Valid SSL certificate
- [ ] No mixed content
- [ ] Security headers present
- [ ] 301 redirects (not 302) for permanent moves
- [ ] Custom 404 page

### Phase 7: AEO Readiness

#### Content Structure
- [ ] Answer-first formatting (40-60 word summaries)
- [ ] FAQ sections with FAQ schema
- [ ] Direct question-answer patterns
- [ ] Entity consistency across pages

#### AI Crawler Access
- [ ] Key content accessible to AI bots
- [ ] No critical JS rendering requirements
- [ ] Content in semantic HTML

### Phase 8: Geo-SEO (if multi-region)

- [ ] hreflang tags implemented
- [ ] Language/region URL structure clear
- [ ] Local business schema per location
- [ ] NAP consistency across directories
- [ ] Local content exists per market

---

## Output Format

```markdown
# SEO Audit Report: [Domain]
**Date**: [Date]
**Auditor**: Claude Code SEO Audit

## Executive Summary
- Overall Score: [X]/100
- Critical Issues: [N]
- Warnings: [N]
- Passed: [N]

## Critical Issues (Fix Immediately)
| Issue | Impact | Page(s) | Recommendation |
|-------|--------|---------|----------------|
| [Issue] | High | [URLs] | [Fix] |

## Warnings (Address Soon)
| Issue | Impact | Page(s) | Recommendation |
|-------|--------|---------|----------------|
| [Issue] | Medium | [URLs] | [Fix] |

## Passed Checks
- [x] [Check 1]
- [x] [Check 2]

## AI Crawler Status
| Bot | Access | Recommendation |
|-----|--------|----------------|
| GPTBot | Allowed/Blocked | [Rec] |
| PerplexityBot | Allowed/Blocked | [Rec] |

## AEO Readiness Score: [X]/10
[Analysis]

## Priority Action Items
1. [ ] [Highest priority]
2. [ ] [Second priority]
3. [ ] [Third priority]

## Tools Used
- Google Search Console
- PageSpeed Insights
- Rich Results Test
- robots.txt Tester
```

---

## Tool Integration

| Check Type | Use This |
|------------|----------|
| Live site crawl | `mcp__playwright__browser_navigate` + snapshot |
| robots.txt fetch | `WebFetch` |
| Page speed | `WebFetch` PageSpeed Insights API |
| Schema validation | `WebFetch` Schema.org validator |
| Search Console data | Requires user-provided export |
| Competitor analysis | `mcp__grok__grok_competitive_intel` |
| Research best practices | `mcp__perplexity__perplexity_research` |

---

## Invocation

```
/seo-audit [domain]
/seo-audit https://www.seekapa.com
```

The skill will:
1. Fetch robots.txt and analyze
2. Check for llms.txt
3. Crawl key pages for schema
4. Generate comprehensive report
