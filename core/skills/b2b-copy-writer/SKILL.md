---
name: b2b-copy-writer
description: |
  B2B SaaS website copy generation using PAS framework.
  Use when writing:
  - Product headlines and taglines
  - Feature descriptions
  - Landing page copy
  - CTAs and microcopy
  - About/Contact page content

  Produces human-sounding, conversion-focused copy that avoids AI-slop.

  Keywords: copy, headline, tagline, description, CTA, landing page, website copy, marketing
allowed-tools: Read, Write, Edit, mcp__grok__grok_brand_content, mcp__vertex-ai__vertex_chat
metadata:
  version: "1.0.0"
  author: odedbe
---

# B2B SaaS Copy Writer

**Purpose**: Generate professional, human-sounding website copy for fintech/B2B SaaS products.

---

## Core Framework: PAS (Problem → Agitate → Solve)

Every piece of copy follows this pattern:

```
PROBLEM: Name the pain in the buyer's own words
AGITATE: Show the cost of inaction (time, money, risk, frustration)
SOLVE:   Present outcome + credible proof
```

---

## Copy Types & Templates

### 1. Hero Headlines (6-12 words max)

**Formula**: [Outcome] + [Differentiator] or [Pain] → [Solution]

**Good Examples**:
- "Cut compliance prep from weeks to hours"
- "Spot market shifts before your competitors"
- "Stop losing deals to poor call quality"

**Bad Examples (AI-Slop)**:
- "Revolutionizing the future of AI-powered compliance" ❌
- "Unlock unprecedented insights with cutting-edge technology" ❌
- "Your one-stop solution for seamless integration" ❌

### 2. Subheadlines (15-25 words)

**Formula**: Expand on HOW + add proof/credibility

**Template**:
```
[Product] [does X] by [method], helping [persona] [achieve outcome].
Already used by [proof point].
```

**Example**:
```
Sentimark aggregates 8 intelligence sources into actionable signals,
helping portfolio managers make confident decisions. Processing 50k+ assets daily.
```

### 3. Feature Descriptions (PAS Micro-Format)

**Template**:
```
[Feature Name]
Pain: [One-line problem]
Agitate: [Cost/consequence in metrics or emotion]
Solve: [Benefit + proof]
```

**Example**:
```
Real-Time Sentiment Analysis

Manually tracking market mood? You're always a step behind.
Missing a sentiment shift cost one fund $2M in a single day.
Get alerts when crowd sentiment flips—backed by 8 data sources,
updated every 2 minutes.
```

### 4. CTAs (Clear, Low-Friction)

**Hierarchy**:
| Intent Level | CTA Text | Context |
|--------------|----------|---------|
| High | "Book a Demo" | Above fold, ready buyers |
| Medium | "See It Work" | Mid-page, need proof |
| Low | "Explore Features" | Early research phase |

**Power CTAs**:
- "See a live analysis—no signup needed"
- "Book 15 min with our team"
- "Try with your own data"

**Banned CTAs**:
- "Learn More" (too vague)
- "Get Started" (means nothing)
- "Contact Us" (passive)

### 5. Product One-Liners (Under 10 words)

**Formula**: [What it does] + [For whom] in plain English

| Product | One-Liner |
|---------|-----------|
| Sentimark | Market sentiment intelligence for confident trading decisions |
| QC Call Analyzer | AI that grades your calls so you don't have to |
| Compliance Exam | Regulatory training that actually sticks |
| CS Agents | AI support that sounds like your best rep |
| FraudShield AI | Catch fraud patterns before they cost you |
| Phone Spam Checker | Know if that number is legit—instantly |

---

## Anti-Slop Rules (MANDATORY)

### Banned Phrases
```
❌ "Revolutionary" / "Revolutionize"
❌ "Cutting-edge" / "State-of-the-art"
❌ "Leverage AI to..."
❌ "Unlock insights"
❌ "Seamless integration"
❌ "One-stop solution"
❌ "In today's fast-paced world"
❌ "At the end of the day"
❌ "Next-level"
❌ "Game-changing"
❌ "Best-in-class"
❌ "Synergy"
❌ "Empower" (without specifics)
```

### Banned Patterns
```
❌ AI as the hero ("Our AI does X" → "You get X")
❌ Feature-first ("We have X" → "X means you can Y")
❌ Vague metrics ("Significant improvement" → "40% faster")
❌ Rhetorical questions to start every section
❌ Multi-adjective stacks ("intuitive, powerful, modern, seamless")
❌ Passive voice for outcomes
```

### Quality Checks
Before any copy is final:

1. **Read aloud test**: Does it sound like a human conversation?
2. **Specificity check**: Are there concrete numbers, names, or examples?
3. **Outcome clarity**: Does every feature end with a business impact?
4. **Proof presence**: Is there evidence backing the claim?
5. **5-second test**: Would a busy CTO understand the value immediately?

---

## Persona-Specific Angles

### For CTOs / IT
- Lead with: Security, integration, data control
- Proof: SOC 2, API docs, deployment options
- CTA: "Review the architecture"

### For Compliance Officers
- Lead with: Audit trails, regulatory readiness
- Proof: Certifications, report samples
- CTA: "See a compliance report"

### For Operations / QA Managers
- Lead with: Time savings, error reduction
- Proof: Before/after metrics, ROI calculator
- CTA: "Calculate your savings"

### For C-Suite / Executives
- Lead with: Business outcomes, competitive edge
- Proof: Customer logos, revenue impact
- CTA: "See the business case"

---

## Workflow

### Step 1: Gather Inputs
```
- Product name
- Target persona (primary)
- Key problem solved
- Top 3 features
- Available proof points (metrics, quotes, logos)
- Competitive differentiator
```

### Step 2: Draft with PAS
Write each section using the templates above.

### Step 3: Anti-Slop Lint
Check against banned phrases and patterns.

### Step 4: Human Polish
Read aloud, adjust for flow, inject personality.

### Step 5: A/B Variants (Optional)
Generate 2-3 headline variants for testing.

---

## Integration with Other Skills

| Need | Use |
|------|-----|
| Social media version | `grok_brand_content` (witty, human tone) |
| Visual design | `/frontend` skill |
| Technical accuracy | Review with domain expert |
| SEO optimization | Research keywords first |

---

## Example: Full Product Page Copy

### Sentimark - Full Copy Set

**Hero Headline**:
"Know where the market's headed—before it moves"

**Subheadline**:
"Sentimark synthesizes crowd wisdom, social signals, and AI analysis into one clear signal. Stop guessing. Start knowing."

**Problem Statement**:
"You're drowning in data but starving for insight. By the time you've parsed the news, checked social sentiment, and reviewed analyst reports, the opportunity has passed."

**Solution**:
"Sentimark watches 8 intelligence sources simultaneously—crowd predictions, social buzz, technical indicators, geopolitical shifts—and distills them into a single, actionable signal. Updated every 2 minutes."

**Feature 1 - Unified Signal**:
- Pain: Checking 6+ dashboards to form a view
- Agitate: That's 2+ hours daily you'll never get back
- Solve: One score, one direction, one decision

**Feature 2 - Crowd Wisdom**:
- Pain: Prediction markets have alpha, but who has time to track them?
- Agitate: Missing Polymarket shifts means trading on yesterday's consensus
- Solve: Real-time crowd sentiment baked into every signal

**CTA Primary**: "See a live market analysis"
**CTA Secondary**: "Explore the methodology"

---

## Quick Reference Card

```yaml
Headline:     6-12 words, outcome-first, no buzzwords
Subhead:      15-25 words, expand with proof
Features:     PAS micro-format, end with business impact
CTAs:         Action verb + clear outcome, no "Learn More"
Voice:        Confident, specific, human
Avoid:        AI-slop, vague claims, feature-first thinking
Proof:        Numbers > adjectives, quotes > claims
```
