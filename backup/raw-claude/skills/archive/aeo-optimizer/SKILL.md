---
name: aeo-optimizer
description: Answer Engine Optimization - optimize content to appear in AI-generated answers (ChatGPT, Perplexity, Claude, Google AI Overviews)
triggers:
  - aeo optimization
  - answer engine
  - optimize for ai
  - ai search optimization
  - chatgpt optimization
  - perplexity optimization
---

# AEO Optimizer Skill

**Purpose**: Optimize website content to maximize visibility in AI-generated answers across ChatGPT, Perplexity, Claude, Google AI Overviews, and other AI search interfaces.

---

## The RAISE Framework

AEO success depends on five pillars:

### R - Relevance Signals
Content must directly answer specific questions, not make abstract claims.

| Bad (Invisible to AI) | Good (AI-Extractable) |
|----------------------|----------------------|
| "We empower businesses with next-gen solutions" | "How to reduce customer churn by 25% using predictive analytics" |
| "Industry-leading platform" | "Automated invoice processing that handles 10,000+ documents/month" |
| "Transform your workflow" | "5-step process to migrate from Excel to automated reporting" |

### A - Access Verification
Ensure AI crawlers can actually reach your content.

**68% of enterprise sites accidentally block AI crawlers.**

Check robots.txt for:
```
User-agent: GPTBot
User-agent: Claude-Web
User-agent: PerplexityBot
User-agent: Google-Extended
```

### I - Information Density
Embed related concepts throughout content for semantic richness.

**Example**: A page about "financial forecasting" should naturally include:
- Scenario planning
- Variance analysis
- Cash flow modeling
- Budget vs. actual
- Rolling forecasts

This semantic web helps AI understand topical authority.

### S - Social/Engagement Feedback
AI systems learn from interaction patterns.

**Strategy**: Have team members regularly use AI tools with your content:
- Search for your topics in ChatGPT
- Ask Perplexity about your domain
- Reference your content in AI conversations

This creates feedback loops that influence future AI citations.

### E - Entity Clarity
Consistent entity definitions across all pages.

**Requirements**:
- Same company name everywhere
- Consistent product names
- Schema markup establishing entity types
- Wikipedia/Wikidata presence (if applicable)

---

## Content Optimization Checklist

### Answer-First Formatting

Every key page should have:

```markdown
# [H1 - Contains target question/topic]

[40-60 word direct answer that stands alone when extracted]

## [Supporting Section 1]
[Detailed explanation]

## [Supporting Section 2]
[Examples, data, proof points]

## FAQ
[Question-answer pairs with FAQ schema]
```

**Example**:

```markdown
# How to Calculate Customer Lifetime Value (CLV)

Customer Lifetime Value is calculated by multiplying average purchase value
by purchase frequency, then multiplying by average customer lifespan.
The formula is: CLV = (Average Purchase Value x Purchase Frequency) x
Average Customer Lifespan. For subscription businesses, use monthly
recurring revenue divided by churn rate.

## The CLV Formula Explained
...
```

### FAQ Section Requirements

Every page should have FAQ section answering:
- What is [topic]?
- How does [topic] work?
- Why is [topic] important?
- How much does [topic] cost?
- How long does [topic] take?
- What are alternatives to [topic]?

### Schema Markup for AEO

#### FAQPage Schema (Critical)
```json
{
  "@context": "https://schema.org",
  "@type": "FAQPage",
  "mainEntity": [{
    "@type": "Question",
    "name": "What is customer lifetime value?",
    "acceptedAnswer": {
      "@type": "Answer",
      "text": "Customer lifetime value (CLV) is..."
    }
  }]
}
```

#### HowTo Schema
```json
{
  "@context": "https://schema.org",
  "@type": "HowTo",
  "name": "How to Calculate CLV",
  "step": [{
    "@type": "HowToStep",
    "name": "Calculate average purchase value",
    "text": "Sum all revenue and divide by number of purchases..."
  }]
}
```

#### Article Schema
```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "headline": "Complete Guide to Customer Lifetime Value",
  "author": {"@type": "Organization", "name": "Company"},
  "datePublished": "2026-01-15",
  "dateModified": "2026-01-20"
}
```

---

## Page-Level Optimization

### Title Tags
- Include the question users ask
- Front-load with target topic
- Keep under 60 characters

**Example**: "What is CLV? Customer Lifetime Value Formula & Calculator"

### Meta Descriptions
- Write as a mini-answer
- Include key data points
- 150-160 characters

**Example**: "CLV = Average Purchase Value x Frequency x Lifespan. Calculate your customer lifetime value with our free template. Average CLV is $1,800 for SaaS."

### Headers (H2, H3)
- Use question format when appropriate
- Create clear content hierarchy
- Enable AI to extract sections

```markdown
## What is Customer Lifetime Value?
## How to Calculate CLV (3 Methods)
### Method 1: Simple CLV Formula
### Method 2: Cohort-Based CLV
### Method 3: Predictive CLV
## CLV Benchmarks by Industry
## How to Improve Your CLV
```

---

## Content Types to Create

### 1. Definitional Content
"What is [X]?" pages that establish entity understanding.

### 2. Comparison Content
"[X] vs [Y]" pages that AI loves to cite for comparisons.

### 3. How-To Guides
Step-by-step processes with HowTo schema.

### 4. Statistics Pages
Data-rich pages AI cites for facts ("X statistics 2026").

### 5. FAQ Hubs
Comprehensive Q&A pages covering topic breadth.

---

## AEO Audit Scorecard

| Criterion | Weight | Score (1-10) |
|-----------|--------|--------------|
| Answer-first formatting | 20% | |
| FAQ schema implemented | 15% | |
| AI crawler access | 15% | |
| Entity consistency | 15% | |
| Information density | 10% | |
| Question-based headers | 10% | |
| Direct answer quality | 10% | |
| llms.txt present | 5% | |
| **Total** | 100% | |

**Scoring**:
- 80-100: AEO Ready
- 60-79: Needs Improvement
- Below 60: Significant Work Required

---

## Monitoring AEO Performance

### Metrics to Track

| Metric | Tool | Target |
|--------|------|--------|
| Brand mentions in AI | Manual testing / Allmo.ai | Increasing |
| Citation rate | Monitor AI responses | Present in top 3 |
| Link inclusion | Check for URLs in responses | 50%+ |
| Sentiment in AI mentions | Qualitative review | Positive/Neutral |
| AI Overview presence | Google Search Console | Appearing |

### Testing Protocol

Weekly:
1. Search 10 key queries in ChatGPT
2. Search same queries in Perplexity
3. Search in Google (check AI Overviews)
4. Document: Cited? Position? Accurate?

---

## Quick Wins

### Immediate Actions (1-2 hours)

1. **Add FAQ schema** to top 5 pages
2. **Write answer summaries** (40-60 words) for key pages
3. **Check robots.txt** for AI bot access
4. **Create llms.txt** with priority content

### Short-term (1 week)

1. **Optimize 10 pages** with answer-first format
2. **Add HowTo schema** to process pages
3. **Create FAQ hub** for main product
4. **Test in AI tools** and document baseline

### Medium-term (1 month)

1. **Build definitional content** for all key terms
2. **Create comparison pages** (you vs competitors)
3. **Develop statistics content** for your domain
4. **Establish engagement feedback** loop with team

---

## Tool Integration

| Task | Capability |
|------|------------|
| Research questions users ask | `mcp__perplexity__perplexity_search` |
| Analyze competitor AEO | `mcp__grok__grok_competitive_intel` |
| Generate FAQ content | `mcp__azure-ai-foundry__azure_brainstorm` |
| Validate schema | `WebFetch` + Rich Results Test |
| Test AI visibility | Manual ChatGPT/Perplexity testing |

---

## Invocation

```
/aeo-optimizer [domain or page URL]
/aeo-optimizer https://www.seekapa.com/product
```

The skill will:
1. Analyze current AEO readiness
2. Score using RAISE framework
3. Identify optimization opportunities
4. Generate specific recommendations
5. Provide implementation priorities
