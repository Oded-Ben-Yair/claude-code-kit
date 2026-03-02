# Deliverable Quality Rules (On-Demand Module)

Load when: workbook, strategy, playbook, plan, deliverable, launch plan, content plan

## Origin

Root cause analysis of 15 fixes needed after 3-LLM evaluation of the LinkedIn Launch Workbook (2026-02-11).

**Failure breakdown**:
- Category A (didn't have the knowledge): 3 fixes (20%) — genuinely new insights from evaluators
- Category B (had knowledge but didn't transfer it): 9 fixes (60%) — **dominant failure mode**
- Category C (had knowledge but applied it incorrectly): 3 fixes (20%) — distortion, retroactive violations

**Core problem**: Research files contained the answers. The deliverable didn't use them. This module prevents that.

---

## Mandatory Quality Gates (In Order)

### Gate 1: Parameter Extraction Table (Before Writing)

Before creating any multi-section deliverable, extract ALL numerical parameters from source research into a single table. This prevents the #1 failure mode: research says X, deliverable says Y.

```markdown
## Parameter Extraction (from research files)

| Parameter | Value | Source File | Line/Section |
|-----------|-------|-------------|-------------|
| Hashtags per post | 0-2 | content-strategy.md:371 | "0-2 hashtags at post end" |
| Week 1 posts | 0-1 | engagement-rules.md | Warm-up schedule |
| DM impact share | 55% | weekly-playbook.md:93 | DeepSeek allocation |
| ... | ... | ... | ... |
```

**Rule**: Every number in the deliverable MUST trace to this table. If a number appears in the deliverable without a row in this table, it's unverified.

### Gate 2: Constraint Extraction (Before Writing)

Extract ALL constraints (bans, limits, never-do items) from research files into a separate table. This prevents retroactive violations — writing content that breaks rules discovered in research.

```markdown
## Constraints (from research files)

| Constraint | Rule | Source File | Applies To |
|-----------|------|-------------|-----------|
| No career-switching content during 90-day niche | NC State study | content-strategy.md | All posts |
| Max 1 post/day | Algorithm penalty | engagement-rules.md | Posting schedule |
| No external links in post body | 40-60% reach penalty | linkedin-algorithm-guide.md | All posts |
| ... | ... | ... | ... |
```

**Rule**: After writing each section, scan it against the constraint table. If ANY section introduces content that violates a constraint, flag and fix before proceeding.

### Gate 3: Traceability Matrix (During Writing)

Every claim, number, or recommendation in the deliverable must have a source annotation. Use inline citations: `(source: filename.md, section X)`.

**Minimum coverage**: 80% of factual claims must have explicit source references. Pure judgment calls (e.g., "this hook sounds better") are exempt.

### Gate 4: Technique Instantiation Pass (After Writing)

After writing the deliverable, check: does the deliverable APPLY the techniques from research, or just REFERENCE them?

**Bad**: "Use human-likeness techniques from human-like-ai-guide.md"
**Good**: "Include 1 parenthetical aside per post (e.g., 'which was working fine the entire time, thank you very much'). Start 1 in 5 posts lowercase. Use edit marks: ~~Redis~~ Azure Table Storage."

**Rule**: For every technique referenced, the deliverable must contain at least one concrete instantiation (example, specific text, or applied instance).

### Gate 5: Feasibility Gate (After Writing)

For every action item in the deliverable, verify:
1. **Does the tool/pipeline exist?** If not, flag as "requires building" with a deadline.
2. **Has it been tested?** If not, add a quality gate with fallback.
3. **Is the timeline realistic?** Cross-check against warm-up schedules, ramp rates, etc.

**Example of what this catches**: "Post a carousel on Day 1" when no carousel creation pipeline exists → Flag as infeasible, swap to text-only with carousel as backup.

### Gate 6: Backward Constraint Validator (After Writing)

Re-read the deliverable end-to-end and check:
- Does any section contradict another section within the deliverable?
- Does any section contradict a source research file?
- Are all numerical values consistent across sections (e.g., "6-8 DMs/week" in one place and "2-3 DMs" in another)?

**Process**: Search for each number/parameter. If it appears in multiple places, verify consistency.

### Gate 7: Cross-File Consistency Check (After Writing)

If the deliverable references or depends on other files, verify those files are aligned:
- Check that source files don't contain contradictory guidance (e.g., file A says "3-5 hashtags", deliverable says "0-2")
- If contradictions found: update the source file AND note the correction in the deliverable
- Use the Single Source of Truth principle: one authoritative file per parameter, all others reference it

---

## Numerical Provenance Rule

**Every number in a deliverable must have provenance.** There are only 3 valid sources:

1. **Research citation**: "0-2 hashtags (screenshot evidence, cross-person-synthesis.md)"
2. **Calculation**: "10:15 AM IST (Nash equilibrium, DeepSeek game theory analysis)"
3. **User input**: "Budget: 180 min/week (user directive)"

If a number has no provenance, it is an assumption. Mark it explicitly: `(ASSUMED — no research backing)`. This forces conscious acknowledgment rather than silent drift.

---

## Hook Quality Rubric (For Content Deliverables)

When a deliverable includes post hooks or headlines, evaluate each against:

| Dimension | Score 1 (Weak) | Score 3 (Good) |
|-----------|---------------|----------------|
| Specificity | "Here's what I learned" | "67% of our Arabic calls showed 1 speaker" |
| Tension | Statement of fact | Implies a surprise, contradiction, or problem |
| Brevity | >140 chars (mobile truncation) | <100 chars |
| AI detection | Sounds like GPT wrote it | Sounds like a person telling a story |

**Minimum**: Every hook must score 2+ on Specificity and Tension. If it scores 1 on either, rework before including.

---

## Deliverable Definition of Done (DoD)

A deliverable is NOT complete until:

- [ ] Parameter Extraction Table exists and is complete
- [ ] Constraint Extraction Table exists and is complete
- [ ] 80%+ of factual claims have source citations
- [ ] Every technique reference has at least 1 concrete instantiation
- [ ] Every action item passes feasibility gate (tool exists, tested, timeline realistic)
- [ ] Backward constraint check found 0 internal contradictions
- [ ] Cross-file consistency check found 0 contradictions with source files
- [ ] All hooks score 2+ on Specificity and Tension
- [ ] Numbers without provenance are explicitly marked as ASSUMED

---

## When NOT To Use This Module

- Quick edits to existing deliverables (single-section changes)
- Pure research output (research summaries don't need feasibility gates)
- Code-focused deliverables (use code-quality.md instead)
- Session handovers (use end-of-session skill instead)

This module is for **strategic deliverables** — workbooks, playbooks, strategies, launch plans — where knowledge transfer from research to action plan is the critical step.

---

## Anti-Pattern: Category B Failure ("Had It, Didn't Use It")

The most common failure mode (60% of all fixes in the LinkedIn workbook) follows this pattern:

1. Research file contains the correct answer (e.g., "Week 1 = 0-1 posts")
2. Deliverable author knows the research exists
3. Deliverable is written from memory / general knowledge instead of re-reading the research
4. Result: deliverable contradicts its own research base

**Prevention**: The Parameter Extraction Table (Gate 1) forces re-reading research files BEFORE writing. The Backward Constraint Validator (Gate 6) catches anything that slips through.

**If you catch yourself writing a number without checking the source file, STOP. Look it up. This is the single highest-ROI habit for deliverable quality.**

---

*Created 2026-02-11 based on root cause analysis of 15 workbook fixes. See decisions.log for full context.*
