---
name: llmstxt-generator
description: Generate optimized llms.txt files for AI crawler discovery based on site analysis
triggers:
  - create llms.txt
  - generate llms.txt
  - llms txt
  - ai crawler file
  - llm discovery
---

# llms.txt Generator Skill

**Purpose**: Create properly formatted llms.txt files that guide AI systems (ChatGPT, Claude, Perplexity) to prioritize high-value content.

---

## What is llms.txt?

llms.txt is a plain text file (Markdown format) placed at the root of a website that:
- Guides AI systems during **inference time** (when generating answers)
- Prioritizes **high-value, authoritative content**
- Uses hierarchical URL structure with descriptions
- Is distinct from robots.txt (which controls crawling/indexing)

---

## File Format Specification

```markdown
# [Project/Company Name]

> [Brief description of the site/company - 1-2 sentences]

## [Section 1 - Most Important]

- [Title](URL): Description of what this page contains
- [Title](URL): Description of what this page contains

## [Section 2 - Important]

- [Title](URL): Description of what this page contains

## Optional

- [Title](URL): Description (lower priority, can be skipped)
```

---

## Generation Workflow

### Step 1: Site Analysis

Gather information about:
1. **Homepage** - Core value proposition
2. **Product/Service pages** - Main offerings
3. **Documentation/Guides** - Technical content
4. **About/Company** - Entity information
5. **Blog/Resources** - Thought leadership
6. **FAQ/Support** - Common questions

Use sitemap.xml or crawl to discover pages.

### Step 2: Content Prioritization

Rank content by:

| Priority | Content Type | Reasoning |
|----------|--------------|-----------|
| 1 (Highest) | Core products/services | What you want AI to cite |
| 2 | Key differentiators | Unique value props |
| 3 | Documentation/How-tos | Practical value |
| 4 | Company info | Entity establishment |
| 5 | Blog posts (evergreen) | Thought leadership |
| 6 (Optional) | Dated content | May become stale |

### Step 3: Write Descriptions

For each URL, write a description that:
- Explains what the page contains
- Uses specific terminology (not marketing fluff)
- Helps AI understand when to cite this page
- Is 10-30 words

**Good**: "Step-by-step guide to configuring SSO with Azure AD for enterprise customers"
**Bad**: "Learn about our amazing single sign-on capabilities"

### Step 4: Validate & Test

- [ ] UTF-8 encoding
- [ ] Markdown syntax correct
- [ ] All URLs resolve (no 404s)
- [ ] No duplicate URLs
- [ ] Logical section hierarchy
- [ ] Descriptions are specific

---

## Template Generator

### For B2B SaaS

```markdown
# [Company Name]

> [Company] provides [core offering] for [target audience]. [Key differentiator in one sentence.]

## Core Product

- [Product Name](URL): [What it does, who it's for]
- [Feature A](URL): [Specific capability description]
- [Feature B](URL): [Specific capability description]

## Documentation

- [Getting Started Guide](URL): Step-by-step setup instructions for new users
- [API Reference](URL): Complete API documentation with endpoints and examples
- [Integration Guide](URL): How to integrate with [common systems]

## Use Cases

- [Use Case 1](URL): How [customer type] uses [product] for [outcome]
- [Use Case 2](URL): [Specific scenario] implementation guide

## Company

- [About Us](URL): Company background, mission, and team
- [Pricing](URL): Plans, features comparison, and enterprise options
- [Contact](URL): Support channels and office locations

## Resources

- [Blog](URL): Industry insights and product updates
- [Case Studies](URL): Customer success stories with measurable outcomes

## Optional

- [Press](URL): Media coverage and press releases
- [Careers](URL): Open positions and company culture
```

### For E-commerce

```markdown
# [Store Name]

> [Store] sells [product category] specializing in [niche/differentiator].

## Product Categories

- [Category A](URL): [What products, price range, who they're for]
- [Category B](URL): [Description]

## Shopping Help

- [Size Guide](URL): Measurement charts and fitting advice
- [Shipping Info](URL): Delivery times, costs, international shipping
- [Returns Policy](URL): Return window, process, and conditions

## Top Products

- [Best Seller 1](URL): [Product name] - [key features]
- [Best Seller 2](URL): [Product name] - [key features]

## Company

- [About Us](URL): Brand story and values
- [Contact](URL): Customer service hours and channels
```

### For Documentation Sites

```markdown
# [Project Name] Documentation

> [Project] is [description]. This documentation covers installation, configuration, and API usage.

## Getting Started

- [Quick Start](URL): Install and run [project] in 5 minutes
- [Installation Guide](URL): Detailed installation for all platforms
- [Configuration](URL): All configuration options explained

## Core Concepts

- [Concept A](URL): Understanding [fundamental concept]
- [Concept B](URL): How [feature] works

## API Reference

- [API Overview](URL): Authentication, rate limits, response formats
- [Endpoints](URL): Complete endpoint documentation
- [SDK Reference](URL): Client libraries for Python, Node, Go

## Guides

- [Tutorial 1](URL): Build [specific thing] step by step
- [Tutorial 2](URL): Advanced [topic] implementation

## Troubleshooting

- [Common Issues](URL): Solutions to frequent problems
- [FAQ](URL): Answers to common questions
```

---

## Output Files

Generate two files:

### 1. llms.txt (Curated)
- 10-30 most important URLs
- High-quality, authoritative content only
- What you want AI to cite

### 2. llms-full.txt (Complete)
- All indexable pages
- Organized by section
- For comprehensive AI access

---

## Validation Checklist

Before deployment:

- [ ] File is at root: `https://domain.com/llms.txt`
- [ ] UTF-8 encoded (no BOM)
- [ ] Valid Markdown syntax
- [ ] All URLs return 200
- [ ] No URLs blocked in robots.txt
- [ ] Descriptions are specific, not marketing
- [ ] Sections ordered by priority
- [ ] No more than 30 URLs in main file
- [ ] File is publicly accessible (no auth)

---

## Testing

```bash
# Verify file is accessible
curl -I https://domain.com/llms.txt

# Check encoding
file llms.txt  # Should show UTF-8

# Validate URLs
grep -oP 'https?://[^\)]+' llms.txt | xargs -I {} curl -sI {} | grep "HTTP/"
```

---

## Integration with Other Files

```
/robots.txt       - Controls crawler access (what to index)
/sitemap.xml      - Lists all pages for indexing
/llms.txt         - Prioritizes content for AI answers
/llms-full.txt    - Complete page listing for AI
```

These files work together:
1. robots.txt allows AI crawler access
2. sitemap.xml lists discoverable pages
3. llms.txt tells AI what's most important

---

## Invocation

```
/llmstxt-generator [domain]
/llmstxt-generator https://www.seekapa.com
```

The skill will:
1. Analyze site structure (sitemap/crawl)
2. Categorize content by type
3. Prioritize by authority signals
4. Generate llms.txt and llms-full.txt
5. Provide validation report
