# R102 Implementation Plan — Profiling Through Conversation

Based on: R101 Phase 0 findings + Oded's gate review (2026-03-07)

## The Core Shift

FROM: Agent answers questions about the property
TO: Agent builds relationships, gathers intel, customizes through curiosity

## Priority Order

### 1. Infrastructure Fixes (30 min, no behavioral change)
- [ ] Timeout 60s → 90s in eval config
- [ ] Fix canned "Glad I could help. Wolf Den..." closer → context-aware farewell
- [ ] Fix crisis exit (recovery signal + topic change = transition)
- [ ] Fix Spanish crisis responses (use detected_language)

### 2. Rewrite Agent Purpose (2 hours, CORE CHANGE)

**System prompt rewrite for ALL specialists:**

Current purpose (implicit):
> "You are a knowledgeable concierge for Mohegan Sun. Answer guest questions."

New purpose:
> "You are a casino host building a relationship with this guest. Your THREE jobs every turn:
> 1. Address their immediate need (answer, recommend, act)
> 2. Learn something new about them (weave in ONE natural question)
> 3. Use what you know to make everything more personal
>
> Every piece of info you gather helps the human host team serve them better.
> You are not an information kiosk. You are the guest's advocate inside the casino."

**Profiling question bank (by context):**
- First contact: "Where are you visiting from?" / "Is this your first time?" / "What brought you out tonight?"
- Group: "What's the occasion?" / "What are we celebrating?" / "Big group! Birthday, bachelor party?"
- Dining: "What kind of food are you in the mood for?" / "Any dietary needs?" / "Casual or dress-up?"
- After loss: "That's tough. You been at the tables all night or mixing it up?" (don't profile-dump on upset guests)
- Returning: "Great to have you back! What did you love last time?" / "Same room preference?"
- Confirmation: Use gathered info — "Since you mentioned Italian, Tuscany's waterfall table at 7 would be perfect for your anniversary"

**Human host bridge phrases:**
- "Want me to have someone from my team come meet you at the entrance?"
- "I'll make sure your host knows about the anniversary — they'll take great care of you"
- "Let me flag this for your host so they can follow up in person"

### 3. Update Gold Traces (1 hour)

Rewrite gold traces to include profiling questions:

Conv 1 (frustrated guest) — ADD: "You been at the tables all night?" (learns play pattern without being clinical)
Conv 2 (anniversary) — ADD: "Which anniversary is it? Let me check what I can set up" (learns occasion detail)
Conv 3 (first-timer) — ADD: "Are you here solo or with a group?" (customizes every subsequent recommendation)

### 4. Update Few-Shot Examples (1 hour)

Current 27 few-shots focus on TONE. Need to add RELATIONSHIP examples:
- Show the profiling question woven naturally into the response
- Show customization based on previously gathered info
- Show human host bridge offer

### 5. Extend Eval Scenarios (1 hour)

Current scenarios are 3 turns. Oded says this may mask profiling quality.
- Create 10 new 5-7 turn scenarios that test:
  - Does agent ask a profiling question?
  - Does agent USE gathered info in subsequent turns?
  - Does agent offer human host bridge?
  - Does the conversation feel like a RELATIONSHIP forming, not a Q&A?

### 6. Re-eval (1 hour)

- Run 30 targeted scenarios (10 new + 20 weakest from R100)
- Timeout 90s
- Score with GPT-5.2
- Compare against R100 baseline (clean scenario avg: 5.42)
- Target: B-avg 7.0+ on clean scenarios

## Success Metrics (Product Outcomes, not just scores)

- [ ] 80%+ of turns include a natural profiling question
- [ ] 50%+ of turn-2+ responses reference info from previous turns
- [ ] 20%+ of conversations include human host bridge offer
- [ ] B-avg 7.0+ on clean (non-timeout) scenarios
- [ ] Oded reads 5 new transcripts and says "host" for 3+

## What NOT to Do

- Don't add 15 profiling rules to the system prompt (complexity budget)
- Don't force a question every turn (sometimes the guest wants you to just DO)
- Don't ask multiple questions in one turn (one question, naturally woven)
- Don't sacrifice urgency for profiling (crisis = act first, profile never)
- Don't over-profile on short interactions ("Thanks, bye" doesn't need "Where are you from?")
