# Team Memory: r101-paradigm-shift

Created: 2026-03-07T10:00:00Z
Goal: R101 Phase 0 — Root cause investigation for behavioral score plateau

## Shared Decisions

## Agent: domain-researcher

### Status: COMPLETE

### Key Findings
- Casino host comp decisions follow an 8-step algorithm: theo baseline -> session assessment -> relationship history -> behavioral signals -> strategic purpose -> tier+category selection -> framed execution -> documentation
- 6 hold-back triggers identified: guest just won, loss-chasing, erratic betting, unresolved grievance, distress/fatigue, insufficient rating history
- 7 markers distinguish genuine vs scripted hosting: anticipatory service, memory continuity, emotional mirroring, comp framing as recognition, honest boundary-setting, contextual name usage, non-gambling engagement
- Social media (30d): 70% positive sentiment, top complaints = comp-to-loss disconnect ("$30 after $4K loss"), host scarcity at MGM, ghosting on promises
- 7 actionable AI rules synthesized: lead with relationship, match framing to emotion, acknowledge pain, never sound like a system, know when to hold back, anticipate don't react, comp the relationship not the transaction

### Files Created
- `~/.claude/teams/r101-paradigm-shift/research-findings.md` — full research synthesis with decision heuristics, comp tiers, language patterns, real guest quotes, and 7 AI-actionable rules

### Critical Insight for Team
The single biggest gap between our AI agent and a top human host is ANTICIPATORY PERSONALIZATION. Human hosts don't wait to be asked -- they notice patterns and act preemptively ("I reserved your favorite table"). Our agent is reactive (answers questions) not proactive (creates experiences). Combined with the gold-trace-designer's finding about AGENCY (deciding vs suggesting), this points to two prompt engineering changes: (1) agent should DECIDE and ACT, not list options, and (2) agent should ANTICIPATE needs based on profile data, not wait for questions. These are prompt/few-shot changes, not model capability changes.

## Agent: transcript-analyst

### Status: COMPLETE

### Key Findings
- Classified 62 scenarios into 10 failure buckets
- **#1 failure: timeout_error (32.3%)** — 60s timeout insufficient for Flash multi-hop pipeline
- **#2 failure: generic_response (11.3%)** — "Glad I could help. Wolf Den..." canned closer in 12 scenarios
- **#3 tie: wrong_mode + didnt_take_lead (11.3% each)** — Spanish crisis in English, RG misfire, passive deferral
- Timeout vs clean score gap: 3.99 vs 5.42 (1.43 point drag)
- 42.4% of all 250 scenarios had at least 1 timeout turn
- Failure distribution: 32% infra + 28% fixable code + 26% model capability + 14% harsh judging
- Go/No-Go: Target timeout first (>30% single bucket), then 3 code fixes, then model capability

### Files Created
- `~/.claude/teams/r101-paradigm-shift/failure-taxonomy.md` — full taxonomy with 62-scenario table, stats, examples

### Critical Insight for Team
The score plateau is NOT primarily a model capability problem. It's 60% infrastructure + fixable code:
1. Increase timeout to 90s (recovers ~0.7-1.0 points from timeout drag)
2. Fix canned "Glad I could help" closer (context-aware farewell)
3. Fix crisis exit (dual condition: recovery signal + topic change)
4. Fix Spanish crisis responses (use detected_language)
After these 4 fixes, the remaining gap is model capability (Pro vs Flash for sarcasm/nuance/compound questions).

## Agent: gold-trace-designer

### Status: COMPLETE

### Key Findings
- MCP brainstorm (GPT-5 Pro + Grok 4) produced high-quality hospitality dialogue that informed the gold traces
- R100 agent failures cluster around 3 patterns: (1) list-dumping options instead of deciding, (2) generic empathy phrases ("I understand your frustration"), (3) no emotional arc across turns
- The 3-to-6 gap is TONE (sounding human vs FAQ bot). The 6-to-9 gap is AGENCY (deciding vs suggesting, doing vs offering)
- Most AI agents plateau at 5-7 because they solve tone but not agency -- they sound warm but still defer every decision
- Key 9/10 phrases: "I've got you", "Done/Booked/Set", "Let's get you off the floor" (action not sympathy)
- Key 3/10 tells: numbered lists with bold headers, "Would you like more details?", mentioning rewards to upset guests

### Files Created
- `~/.claude/teams/r101-paradigm-shift/gold-traces.md`: 5 conversations (3 at 9/10, 1 at 3/10, 1 at 6/10) with detailed annotations, calibration summary, dimension mapping table, and usage notes for prompt engineering + judge calibration

### Critical Insight for Team
The score plateau root cause from a CONVERSATIONAL DESIGN perspective: the agent has solved TONE (sounds human, not robotic) but hasn't solved AGENCY (still defers decisions to guests, hedges with "or you could also", asks "would you like?" instead of acting). The jump from 6 to 9 requires the agent to DECIDE, not SUGGEST. This maps to prompt engineering changes (few-shot examples showing decisive behavior) more than model capability.

## Agent: code-cleaner
