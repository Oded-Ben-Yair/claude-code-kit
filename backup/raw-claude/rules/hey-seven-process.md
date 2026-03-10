# Hey Seven Process Rules (R101+)

Origin: R101 Phase 0 (2026-03-07) — 25 rounds of score oscillation (5.5-7.0) broken by hypothesis-first approach. 3 experiments in 1 session found root cause vs 25 rounds of fix-code-re-eval.

## Research Before Code (MANDATORY for behavioral changes)

Before ANY behavioral code change (prompts, guardrails, routing, agent logic):
1. State the hypothesis: "I believe [X] causes [Y] because [evidence]"
2. Run at least 1 MCP research query (perplexity, grok, gemini) for domain grounding
3. Read at least 5 actual eval transcripts to verify the hypothesis
4. If hypothesis has <60% evidence support, TEST it before coding

Skip for: infrastructure changes, config updates, test fixes, documentation.

## Hypothesis Testing Before Assuming Root Cause

When behavioral scores plateau (< +0.5 for 3+ rounds):
1. Run failure taxonomy: classify 50+ transcripts into buckets
2. If one bucket >30%, that's the target (not the score that dropped)
3. If all buckets <15%, the problem is model capability (fine-tuning path)
4. Never assume "model needs to be better" without testing with gold traces

## Human Judgment Required

Every evaluation loop must include:
1. Human reads at least 5 transcripts and gives binary "host/chatbot" verdict
2. Gold trace calibration: judge must score 3/6/9 anchors before scoring agent
3. Product outcomes (task completion, safety) alongside dimension scores

## The TONE → RELATIONSHIP → AGENCY Framework (Oded, R101)

| Score Range | What's Solved | What's Missing | Fix With |
|-------------|--------------|----------------|----------|
| 1-3 | Nothing | Everything | Basic prompts + guardrails |
| 3-6 | -- | TONE (sounds robotic) | Few-shot examples, slop patterns, persona tuning |
| 5-7 | TONE | RELATIONSHIP (doesn't ask, learn, customize) | Profiling-through-small-talk, "what are we celebrating?", human host bridge |
| 7-8 | TONE + RELATIONSHIP | AGENCY (suggests, doesn't decide) | Decisive language, "Booked", "I've got you" |
| 8-9 | All above | ANTICIPATION + MEMORY | Profile-driven proactive service, past visit callbacks |
| 9-10 | All above | Human touch | Fine-tuning with graded conversations |

Current agent: 5.9 (TONE solved, RELATIONSHIP gap). Next target: teach profiling through conversation.

## Agent's True Purpose (Oded, R101 — MANDATORY)

The agent is NOT a question-answering kiosk. It is a RELATIONSHIP BUILDER.

Every specialist turn MUST:
1. Address the immediate need (answer/recommend)
2. Ask 1 profiling question woven naturally ("What are we celebrating?" "What kind of food do you like?")
3. Customize suggestions using gathered info
4. Offer human host bridge when appropriate ("Want me to have someone show you around?")

The data gathered flows to the HUMAN HOST TEAM — that is the product's value.

### Anti-Patterns (Oded-flagged)
- Rushing to suggestions without asking preferences first
- Empty promises ("I'll look into an upgrade") without specifics
- Treating every turn as "answer the question" instead of "learn about the guest"
- Missing obvious profiling moments (party size, occasion, food preference, hometown)

## Anti-Reversion Locks

1. No code changes to behavioral logic without failure taxonomy (min 30 transcripts read)
2. No new prompt sections without removing an old one (total complexity budget)
3. No claiming "root cause is model capability" without Pro vs Flash comparison data
4. No running 250-scenario eval before fixing infrastructure issues (timeouts, canned closers)
5. Every policy engine change gets a version tag for one-command rollback

## Minimum MCP Utilization (per behavioral session)

Use at least 4 different MCP tools. Common pattern:
- `perplexity_research` or `grok_x_search`: domain grounding
- `azure_chat` (GPT-5.2): judge scoring
- `grok_reason` or `azure_deepseek_reason`: alternative perspective
- `azure_brainstorm` or `grok_chat`: gold trace design

## Gold Traces as Acceptance Tests

Gold traces live in `~/.claude/teams/r101-paradigm-shift/gold-traces.md`.
- Use as few-shot examples in specialist prompts
- Use as judge calibration anchors (3/6/9 before scoring)
- Use as acceptance criteria: agent must score within 1 point of gold trace on same scenario
- Update when behavior targets change

## Do-Not-Optimize List

1. Do NOT optimize "host vibe" at cost of factual correctness
2. Do NOT force tool usage to meet a quota
3. Do NOT add new policy rules unless they REPLACE old rules
4. Do NOT optimize binary "host/chatbot?" without measuring task completion
5. Do NOT patch every failure with another rule (max 20 active rules, then simplify)
6. Do NOT add prompt sections without removing old ones (R102: consolidated 3→1, net complexity down)
7. Do NOT run evals before fixing infrastructure issues (R102: timeout fix alone = +1.43 pts from clean scenarios)
