# R101 Phase 0 Findings — Root Cause Investigation

Date: 2026-03-07
Status: Phase 0 COMPLETE. Awaiting Oded's human gate confirmations.

## The Diagnosis (3 experiments converged)

### Root Cause: TONE solved, AGENCY not solved
The agent sounds human (5-7 range) but doesn't ACT like a host (7-9 range).
- Recommends but doesn't EXECUTE (book, confirm, close the loop)
- Lists options instead of picking one confidently
- Hedges with "or you could also..." instead of "Done. Booked."
- Says "Would you like...?" instead of "I've got you."

### Failure Distribution (62 scenarios classified)
- 32% timeout_error (60s insufficient for Flash multi-hop)
- 11% generic_response ("Glad I could help. Wolf Den..." canned closer)
- 11% didnt_take_lead (passive, verbose, deferred)
- 11% wrong_mode (Spanish crisis in English, RG misfire, AI disclaimer)
- 8% over_protection (crisis mode stuck after recovery signal)
- 8% fallback_error ("I'm having trouble generating a response")
- 8% missed_intent (didn't understand what guest wanted)
- 7% good_but_scored_low (harsh judging, especially on profiling dims)

### Rubric Ceiling Test
- Gold trace Conv B (anniversary VIP) scored 9.2/10 by GPT-5.2
- Agent's best non-crisis scored 6.6/10
- Gap is 2.6 points — ALL agent behavior, ZERO rubric
- Rubric works fine. Phase 4 (eval redesign) NOT needed.

### Multi-Judge Scores on Agent's Best 5 Conversations
| Judge | Avg Score | Binary |
|-------|-----------|--------|
| GPT-5.2 | 5.8 | 5/5 CHATBOT |
| Grok 4 | 8.2 | 4/5 HOST |
| DeepSeek | 5.0 | 4/5 PROCESSED |
Grok inflates ~2.4 pts. GPT-5.2 and DeepSeek agree on chatbot/processed.

### Score Impact Estimates
- Fix timeout 60s→90s: +0.7-1.0 pts (1.43-pt drag, partially recoverable)
- Fix canned closer: +0.3 pts (12 scenarios affected)
- Gold trace few-shots (teach AGENCY): +1.0-1.5 pts (fundamental behavior shift)
- Fix crisis exit + Spanish: +0.2 pts
- Total addressable: +2.2-3.0 pts → target B-avg 8.0+

## Key Artifacts Created

| File | Content |
|------|---------|
| `~/.claude/teams/r101-paradigm-shift/failure-taxonomy.md` | 62-scenario classification table with buckets, quotes, stats |
| `~/.claude/teams/r101-paradigm-shift/gold-traces.md` | 5 conversations: 3 at 9/10, 1 at 3/10, 1 at 6/10 with annotations |
| `~/.claude/teams/r101-paradigm-shift/research-findings.md` | Domain research: comp heuristics, language patterns, guest voice, 7 AI rules |

## Gold Trace Key Phrases (for few-shot embedding)
- "I've got you." (ownership)
- "Rough night. Let's get you off the floor." (action not sympathy)
- "10am deep tissue, booked." (decisive, done)
- "I'll check in tomorrow morning." (proactive follow-up)
- "That's the goal." / "Rest up." (warm close, no exclamation marks)
- "The weekend builds: romantic dinner, nightlife, spa, coast home relaxed." (itinerary thinking)
- "$50 free play loaded — first-timer's perk." (proactive comp, framed naturally)

## Domain Research: 7 AI Rules
1. Lead with relationship, comp follows
2. Match comp framing to emotional state
3. Acknowledge the pain, don't ignore it
4. Never sound like a system (blacklist: "As a valued guest", "Based on your play", "You qualify for")
5. Know when to hold back (just won, loss-chasing, erratic, grievance, distress)
6. Anticipate, don't react (proactive > reactive)
7. Comp the relationship, not the transaction (cumulative, not today's session)

## Decision Tree Outcome
- H1 (rubric ceiling): FALSE — rubric produces 9.2 for gold traces
- H2 (dominant failure modes): CONFIRMED — timeout + canned + wrong_mode = 54% fixable
- H3 (diverse failures): Partially true for remaining 26% (model capability)
- H4 (tool conflicts): Not primary issue

## Oded's Root Cause Diagnosis (Gate Review, 2026-03-07)

**All 3 agent conversations: CHATBOT.** Oded's critiques reveal a DEEPER gap than AGENCY:

The agent's PURPOSE is wrong. It answers questions instead of building relationships.

### Oded's Specific Feedback:
1. **Missing profiling through small talk** — every turn is a missed chance to ask "what kind of food?", "how many?", "what are we celebrating?", "where are you from?"
2. **Generic suggestions without customization** — recommends without learning preferences first
3. **No human host bridge** — should offer "want me to have someone from my team show you around?"
4. **Empty promises** — says "upgrade" twice without specifics or action
5. **Rushing to suggestions** — should use questions to (a) customize and (b) gather data for human hosts
6. **Short 3-turn evals** may mask the problem — not enough turns to show profiling arc

### The Corrected Layer Model:
- 3→6: TONE (sound human) — SOLVED
- 6→8: PROFILING-THROUGH-CONVERSATION — THE GAP (Oded's insight)
- 8→9: AGENCY (decide, book, confirm) — FUTURE

### Agent's True Job Description:
NOT "Answer questions about the property"
BUT "Build relationships, gather intel for human host team, customize everything through genuine curiosity"

Every specialist turn should:
1. Answer/act on the immediate need
2. Ask 1 profiling question naturally woven into the response
3. Offer human host bridge when appropriate ("want me to have someone come greet you?")
4. Use gathered info to customize subsequent suggestions

## Recommended Next Phase (Oded confirmed)
1. Fix timeout (60s→90s) — config change
2. Fix canned "Glad I could help" closer — context-aware farewell
3. Rewrite specialist system prompts with RELATIONSHIP-FIRST purpose
4. Add "profiling through small talk" few-shot examples (not just AGENCY)
5. Update gold traces to include profiling questions
6. Fix crisis exit + Spanish language
7. Re-eval with longer scenarios (5+ turns, not 3)

## 4 Code Bugs Fixed (R101)
1. Word-boundary comp matching (dispatch.py) — `set.split()` intersection
2. Removed `_get_routed_llm` dead code (nodes.py)
3. Fixed "12-node" → "13-node" log message (graph.py)
4. Removed stale `companion_names` from relationship_fields (profiling.py)
Tests: 338 passed, 0 failures
