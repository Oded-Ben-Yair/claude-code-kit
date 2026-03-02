# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LinkedIn career acceleration project for Oded Ben-Yair. Contains CV (HTML→PDF pipeline), LinkedIn profile content, job application tracking, and research materials. **Status**: Profile deliverables COMPLETE and live. Current phase: job applications + LinkedIn operations.

## Commands

```bash
# Generate CV PDF from HTML template (requires WeasyPrint)
cd cv-pdf && python generate-pdf.py

# Install dependency
pip install weasyprint
```

The generator reads `cv-pdf/cv-template-v55.html` and outputs `cv-pdf/Oded_Ben_Yair_Resume.pdf`. Note: `generate-pdf.py` references `cv-template.html` (not v55) — update the TEMPLATE path if switching versions.

## Architecture

This is a content project, not a software application. Key structure:

- **`cv-pdf/`** — HTML→PDF pipeline. `cv-template-v55.html` is the source of truth for the CV. WeasyPrint generates the PDF. Typography: Inter font, 9.5pt body, 1.40 line-height, dual-color system (#334155 body / #0f172a bold).
- **`profile/`** — LinkedIn content (`copy-paste-content.md`) and ATS-format resume (`ats-cv.md`). These are copy-paste ready for LinkedIn and job application text fields.
- **`research/`** — Company targeting + LinkedIn mastery research. `companies/priority-targets.md` for targets. `linkedin-algorithm-guide.md`, `content-strategy.md`, `engagement-rules.md`, `job-application-strategy.md`, `human-like-ai-guide.md` for operational playbook. `cross-validation-matrix.md` for 6-source research synthesis.
- **`content/`** — LinkedIn post drafts, templates, and weekly playbook. `post-ideas.md` (25 ideas), `weekly-playbook.md`, `templates/` (8 post templates, comment, DM, cover letter frameworks).
- **`tracking/`** — Job application tracker + `interaction-feedback.md` (content performance + learning loop).
- **`.claude/`** — Session state (`status.json`), decision history (`decisions.log`), handover files.

## Critical Rules

- **Never modify CV content without 4-model debate first** — use debate-first workflow (GPT-5.2, Grok 4, Gemini 3 Pro, Perplexity consensus before any rewrite)
- **Score the final PDF, not markdown** — visual design is part of the score. Use Gemini Vision (pro, thinkingLevel=high, mediaResolution=high) with triple evaluation (3x same eval, average)
- **Single-column CV layout only** — sidebar/multi-column breaks ATS parsers (V50 scored 6.9, worst ever)
- **No keyword stuffing** — modern ATS (Greenhouse, Lever) penalizes it; integrate keywords naturally
- **Append decisions to `.claude/decisions.log`** — never overwrite, always append with `[YYYY-MM-DD] DECISION:` format

## Project Tree

```
linkedin/
├── CLAUDE.md                          # This file — project instructions + knowledge base
├── FINAL-STATUS.md                    # Completion report — all phases A-D, 1, 2A-2C, 3
│
├── cv-pdf/                            # CV HTML→PDF Pipeline
│   ├── cv-template-v55.html           # HTML source (FINAL, editable)
│   ├── generate-pdf.py                # WeasyPrint generator
│   └── Oded_Ben_Yair_Resume.pdf       # Production CV (V55, 2-page A4)
│
├── profile/                           # LinkedIn Profile Content (LIVE)
│   ├── copy-paste-content.md          # LinkedIn sections — copy-paste ready
│   └── ats-cv.md                      # Plain text ATS resume
│
├── content/                           # Content Creation Arsenal
│   ├── post-ideas.md                  # 25 post drafts (research-backed)
│   ├── weekly-playbook.md             # Day-by-day schedule (Sun-Thu, ~210 min/week)
│   └── templates/
│       ├── post-templates.md          # 9 post templates (incl. Quick Hit)
│       ├── comment-templates.md       # Comment frameworks for 7+ scenarios
│       ├── dm-templates.md            # DM templates (cold, warm, follow-up, InMail)
│       └── cover-letter-framework.md  # Modular cover letters (Gong, Monday, CheckPoint, CyberArk)
│
├── research/                          # Research & Intelligence
│   ├── linkedin-algorithm-guide.md    # Algorithm mechanics, 360Brew, signal hierarchy
│   ├── content-strategy.md            # Post formats, timing, hashtags, content types
│   ├── engagement-rules.md            # Comment strategy, connection limits, quotas
│   ├── job-application-strategy.md    # Apply vs save, timing, referral strategy
│   ├── human-like-ai-guide.md         # AI detection avoidance + screenshot-backed patterns
│   ├── ai-formatting-bans.md          # 3-tier AI word ban list (380+ lines)
│   ├── cross-validation-matrix.md     # 6-source research synthesis (500+ citations)
│   ├── gemini-google-grounded-research.md  # Gemini grounded research raw findings
│   ├── companies/
│   │   └── priority-targets.md        # Target companies with action plans
│   ├── reference-library/
│   │   ├── target-profiles.md         # 15 creator profiles (10 Israeli + 5 global)
│   │   └── analysis/
│   │       ├── israeli-creators-analysis.md   # 10 Israeli AI creator patterns (screenshot-backed)
│   │       ├── global-creators-analysis.md    # 5 global AI creator patterns (screenshot-backed)
│   │       └── cross-person-synthesis.md      # 7 universal patterns + Oded's formula
│   └── influencer-deep-dive/          # Phase 3: Playwright Screenshot Deep-Dive
│       ├── {creator}/analysis.md      # 12 creators × structured analysis
│       ├── {creator}/posts/           # 25 post screenshots each
│       ├── {creator}/comments/        # 10 comment screenshots each
│       ├── {creator}/screenshots/     # 3 profile screenshots each
│       ├── _dropped/                  # 3 dropped creators (Karpathy, Goldberg, Ivri)
│       └── _browser-session-artifacts/  # Debug/search screenshots (archived)
│
├── tracking/                          # Activity Tracking
│   ├── job-tracker.md                 # Application tracker (ready for use)
│   ├── interaction-feedback.md        # Content performance + learning loop
│   └── recruiter-inmail-log.md        # Recruiter InMail tracking + response templates
│
└── .claude/                           # Session State
    ├── status.json                    # Current project state
    ├── decisions.log                  # 123+ decisions (append-only)
    ├── research-raw/                  # Phase 1 raw research outputs (5 files)
    └── handover-archive/              # Previous session handovers
```

### Key File Counts
- **12** individual creator analysis files (Gemini Vision on 472 screenshots)
- **25** post ideas (research-backed, ready to draft)
- **9** post templates + **7** comment scenarios + **5** DM templates
- **6** research guides (algorithm, content, engagement, jobs, human-likeness, bans)
- **123+** architectural decisions logged

---

## What's Live

**LinkedIn**: linkedin.com/in/oded-ben-yair-ai/
- **Headline**: Founding AI Engineer | Multi-LLM Routing & Evaluation in Production | Voice AI . RAG | Azure + Python
- **About**: 2,524 chars — debate-fixed, CTO/compliance context, stealth mode (no "open to work" language)
- **Experience**: 4 positions (Be Z Online, Outlier, Ever Lab, IAF)
- **Featured**: Both GitHub repos linked
- **Skills**: Python, LLMs, Azure as top 3 (top 3 get 10x LinkedIn algorithm weight)
- **Education**: Infinity Labs + Coursera/DeepLearning.ai (non-tech education removed)

**GitHub**:
- claude-code-orchestra: github.com/Oded-Ben-Yair/claude-code-orchestra (Motivation + Skills sections added)
- llm-conversational-router: github.com/Oded-Ben-Yair/llm-conversational-router (Motivation + Skills sections added)

**CV PDF**: V55 — content 8.80/10, visual 7.9/10 stable avg, uploaded to LinkedIn

---

## Knowledge Base: ATS & Recruiter Psychology

**ATS rules**:
- Keyword stuffing is PENALIZED by modern ATS (Greenhouse, Lever) — integrate keywords naturally into bullets
- Single-column layout mandatory — multi-column/sidebar breaks ATS parsers
- Standard fonts only (Arial, Inter, Calibri) — decorative fonts cause parsing failures
- No graphics, charts, icons, colored backgrounds — ATS ignores or misparses them
- Top 3 LinkedIn skills get 10x algorithmic weight in recruiter search results

**Recruiter behavior**:
- 78% of recruiters check GitHub profiles (Perplexity research, Feb 2026)
- Israeli CTOs specifically ask about Claude Code usage in interviews (Grok social intel)
- "Open to Work" badge replaced with passive stealth paragraph: "Passionate about production AI systems..." — keeps keywords without job-seeking language
- Recruiter visibility set to "Recruiters only" for Open to Work setting

**Red flags ceiling**:
- Red Flags dimension capped at 7.6-8.0 max across all models — 9-month tenure + career switch is structural
- Cannot be fixed by text alone — requires interview explanation
- Prepare: "concentrated production impact, not tenure" framing

**Education decisions**:
- Non-tech education (Naturopathy, Reiki) removed per 6-model consensus: "credibility noise"
- Natural Therapy = verbal interview asset, NOT CV entry (3/4 models agree)
- Interview bridge: "After army I explored different paths. In 2020 found tech, went all-in."

**About section de-duplication**:
- REJECTED by 4/4 models — anti-correlation data from 6 iterations shows metrics in About improve scores
- CS agents/marketing metrics moved to Experience only; key metrics (Thompson Sampling, WER, tests) stay in About

---

## Knowledge Base: Phrasing & Human-Likeness

**Human-likeness baseline**: 5.5/10 Grok (MEDIUM-HIGH AI detection risk), 7.5/10 Gemini
- This is a discovered ceiling, not a failure — Grok is the harshest evaluator
- About section: 5/10 (templated structure), Experience bullets: 6/10 (rigid parallelism), Headline: 7/10

**Phrasing rules applied**:
- Break parallelism — mix bullet structures, don't use X-Y-Z formula on every bullet
- Add narrative voice — personal "why", varied sentence openers, reflection paragraphs
- No formulaic patterns — mix plain English with metric-driven bullets

**Cross-artifact metric variation** (3-model consensus):
- CV gets scale/reliability numbers (300+ tests, 15 Azure Function Apps)
- About gets WER/neutral rate narrative (Thompson Sampling story, voice AI challenge)
- Experience gets 174K executions/111 assets detail

**Specific phrasing wins**:
- "Iterated on AI customer service agents" replaces robotic "AI customer service agents pass 91.9%"
- "Conservative baseline target was 65%, tightened through retrieval tuning and guardrails" — explains the 91.9% vs 65% gap
- "Weekly design reviews with CTO and compliance stakeholders" — counters solo-operator signal
- Ever Lab bridge: "Recognized that feedback systems I was building manually could be automated with ML"
- "Prepared to deep-dive on evaluation methodology" REMOVED — all models flagged as cover letter line, not CV

---

## Knowledge Base: CV Design & PDF

**Typography**: Inter font, 9.5pt body, 1.40 line-height
**Colors**: #334155 body text / #0f172a bold contrast (dual-color system)
**Layout elements**:
- Left-accent section headers with subtle border
- 2-column skills grid (`column-count: 2`) — biggest structural win from V44+
- Job separators (0.4pt HR between positions)
- Metrics highlight bar (4 key numbers at top)
- Bottom anchor line
- Inline compact skills (pipe-separated)

**Design lessons**:
- Sidebar layout = CATASTROPHIC — V50 scored 6.9 (worst ever), page 2 layout discontinuity
- Micro-compression = diminishing returns after V40+ (plateau proven across 12 versions V44-V55)
- WhiteSpace ceiling accepted — content fills 1.8 of 2 pages, structurally impossible to hit 9 without cutting content
- V55 = V52 structure + V54 typography merge (best-of-both: job separators from V52, larger name/metrics from V54)

**Tooling**:
- WeasyPrint for HTML-to-PDF generation (`python generate-pdf.py`)
- Gemini Vision (model=pro, thinkingLevel=high, mediaResolution=high) for PDF visual scoring
- Triple evaluation for stability: run same eval 3x, average the scores

---

## Knowledge Base: Scoring & Methodology

**11-dimension rubric**:
1. Technical Credibility
2. ATS Compatibility
3. Keyword Optimization
4. Narrative Coherence
5. Business Impact
6. Grammar & Formatting
7. Red Flags / Credibility Risks
8. Israel Market Fit
9. Quantification Quality
10. Interview Readiness
11. Human-Likeness

**Validation rules**:
- 4-model validation MANDATORY: GPT-5.2, Grok 4, Gemini 3 Pro, Perplexity
- Single LLM is unreliable — evaluator variance is +/-1.5 points between models
- Triple evaluation for stability — run same eval 3 times, average (catches noise)
- Score the FINAL PDF, not the markdown source — visual design is part of the score

**Proven strategies**:
- Tree-of-Thought paired variant optimization = top iteration strategy for CV content
- Debate-first workflow mandatory for any rewrite (user directive: consensus before changes)
- Score plateau proven across 12 consecutive versions (V44-V55) — ship when plateau detected
- Evaluator variance means 7.9 and 8.1 are statistically identical

**Final scores** (Feb 2026):
- Content: 8.80/10 (7 rounds of text optimization)
- Visual: 7.9/10 (stable average, triple evaluated)
- 4-LLM: Gemini 8.6, GPT-5.2 8.5, Grok B- (would interview), Perplexity 8.5 (top 15-20%)
- Full package: GPT-5.2 7.3, Grok 6.7, Gemini 9.3, Perplexity 8.45 (avg 7.94)

---

## Company Targeting & Salary

**Full detail**: `research/companies/priority-targets.md`

**Quick reference**:
- Gong.io: SHIP (4/4 model consensus) — apply immediately
- Monday.com: SHIP (3/4 consensus) — apply immediately
- Microsoft Israel: CONDITIONAL (2 SHIP, 2 CONDITIONAL) — needs warm intro to bypass tenure screen
- Wiz: HOLD (2/4 reject) — security domain depth gap, apply after building security project/cert
- Tier 2: Check Point, CyberArk, Taboola, Wix

**Positioning**: Target product-focused applied AI roles, not research labs
- NVIDIA, AI21, Deep Instinct moved to Tier 3 (stretch) — core ML/GPU/research not a match

**Salary**:
- Target: NIS 38,000-45,000/month
- With AI premium: NIS 50,000-58,000/month (justified by production shipping + multi-system design)
- Floor: NIS 35,000/month
- USD equivalent: $135K-$180K bracket (Perplexity market analysis)

---

## Success & Failure Patterns

### Success Patterns
| Pattern | Detail |
|---------|--------|
| Tree-of-Thought paired variants | Generate 2 variants, score both, merge best elements |
| Triple evaluation | Run same eval 3x to filter noise — stable avg is real score |
| Multi-model validation | Never trust single LLM; 4-model consensus catches individual bias |
| Debate-first workflow | Get 4-model consensus on exact text BEFORE rewriting |
| Ship at plateau | 12 versions without movement = real ceiling, stop iterating |
| WeasyPrint + Gemini Vision loop | Generate PDF, screenshot, Gemini score, iterate CSS — fast feedback cycle |

### Failure Patterns
| Pattern | Detail |
|---------|--------|
| Sidebar CV layout | V50 scored 6.9 — worst ever; page 2 discontinuity is fatal |
| Micro-compression after V40+ | Diminishing returns; 0.1pt gains don't justify risk of regression |
| Single LLM as ground truth | +/-1.5pt variance between models; Gemini 9.3 vs Grok 6.7 on same package |
| Keyword stuffing | Modern ATS (Greenhouse/Lever) penalizes — integrate naturally |
| Fancy PDF templates | Graphics, columns, icons all break ATS parsers |
| Ralph Wiggum 9.5/10 target | Abandoned — plateau at 7.9 is the real ceiling for visual; content peaked at 8.8 |

---

## LinkedIn Operations (Research-Backed Playbook)

**Status**: COMPLETE — 6-source parallel research (Perplexity MCP, Grok X/Twitter, Gemini, GPT-5.2, DeepSeek Game Theory, Perplexity Pro Deep Research with Enterprise Connectors). 500+ citations synthesized into actionable files.

**On-demand rules**: `~/.claude/rules/linkedin-operations.md` (loaded when doing LinkedIn work), `~/.claude/rules/linkedin-autopilot.md` (loaded for autonomous mode)

### Quick Reference: What Works
- **Post timing**: Tue/Thu 10:15 AM IST (DeepSeek Nash equilibrium, cross-validated, 4+ sources)
- **Best format**: Carousels (6.6% engagement, 45.85% above text)
- **Comment weight**: 5-7x reactions; 15+ words = 2.5x short comments
- **Referrals**: 3.6-7x hiring likelihood — network first, apply second
- **Direct apply**: 11.2% conversion vs Easy Apply 4% — direct for priority targets
- **Safe limits**: 15 connections/day, 10 comments/day, 5 DMs/day
- **Golden hour**: First 60 min engagement velocity = make-or-break
- **Links**: ALWAYS in first comment (40-60% reach penalty in post body)
- **360Brew**: Takes 90 days to categorize creator — start posting NOW
- **DMs**: Highest ROI activity (55% of job search impact)

### Autopilot Path
- Stage 1 (sessions 1-5): Human reviews all content
- Stage 2 (sessions 5-15): AI drafts, human approves (<20% edit rate target)
- Stage 3 (sessions 15+): Full autopilot via `/browser-control` with weekly review

### Company Strategy (Research-Validated)
| Company | Action | Timeline |
|---------|--------|----------|
| Monday.com | APPLY NOW when role posted | Within 48h |
| Gong.io | Engage 1 week → warm intro → apply | 2 weeks prep |
| Microsoft Israel | Build connections → referral → apply | 2-4 weeks prep |
| Wiz | HOLD (security gap) | After security project/cert |

---

## Next Phase: Job Applications

**P0**: Execute LinkedIn operations playbook — start with engagement warm-up (3-4 weeks gradual ramp)
- Follow target company pages, comment on 2-3 posts/day from Gong/Monday employees
- Enable Open to Work (recruiter-only) with all 5 title slots

**P0.5**: Review `research/companies/priority-targets.md`, begin applications
- Monday.com: apply immediately when relevant role posted (direct apply, not Easy Apply)
- Gong.io: 1 week engagement first, seek warm intro, then apply
- Microsoft Israel needs 2-4 week warm intro strategy

**P1**: LinkedIn engagement
- `content/post-ideas.md` has 15 research-backed draft topics
- Best posting times: Tue/Thu 8-11AM IST
- Post 2+ before applying (builds 360Brew credibility signal)

**P2**: Interview prep talking points
| Topic | Preparation |
|-------|-------------|
| Short AI tenure (~8mo) | "Concentrated production impact: 6 microservices, 174K monthly executions, not tenure" |
| WER claim defensibility | "12-15% Semitic baseline is published; measured against Whisper on manual annotations" |
| Solo contributor signal | "Weekly design reviews with CTO and compliance stakeholders" |
| Career switch | "After army explored paths, found tech in 2020, intensive retraining through Infinity Labs" |
| Natural Therapy gap | Verbal bridge story only — never put on CV (3/4 model consensus) |

**P3**: Cover letter templates (not yet created)

**Tracking**: `tracking/job-tracker.md` (empty, ready for use)
