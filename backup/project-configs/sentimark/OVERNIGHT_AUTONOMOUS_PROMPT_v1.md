# SENTIMARK OVERNIGHT AUTONOMOUS SESSION - CEO DEMO READINESS

**Mission**: By morning, deliver a flawless Sentimark app for CEO presentation. Zero tolerance for broken flows, ugly UI, or confusing UX.

**Mode**: EXECUTE (not plan mode - autonomous overnight operation)

**Expected Duration**: 6-8 hours of autonomous iteration

---

## PHASE 0: CONTEXT RECOVERY (DO FIRST - 5 min)

### Mandatory Recovery Steps
```
1. Search Memory MCP: "sentimark-session-20260119"
2. Search Memory MCP: "sentimark-prod-readiness"
3. Read: /home/odedbe/projects/sentimark/CLAUDE.md
4. Read: /home/odedbe/projects/sentimark/.claude/handover-20260119-prod-readiness.md
5. Read: /home/odedbe/projects/sentimark/.claude/NEXT_SESSION_PROMPT.md
```

### Current Known State (from session 11800)
- Backend: HEALTHY (4 LLMs active)
- E2E Tests: 26/29 passing (3 minor failures)
- Commit: 8e2a865 on master
- CORS: Fixed and deployed
- CSS Animation: Fixed (cascade opacity issue)

### Open Issues from Previous Session
1. Timestamps not visible on price cards
2. Time horizons (24h/7d/30d) not shown on signals
3. 6 console errors (expected <3)

---

## PHASE 1: PDF FEEDBACK ANALYSIS (15 min)

### Objective
Extract ALL actionable feedback from the UX audit PDF.

### Execution
```
1. Use Gemini Document Parser agent:
   Task tool → subagent_type: "Gemini Document Parser"
   Prompt: "Parse /home/odedbe/projects/sentimark/UX Audit Financial App.pdf
            Extract ALL feedback items, categorize by:
            - Critical (blocking CEO demo)
            - High (noticeable but not blocking)
            - Medium (polish items)
            - Low (nice to have)
            Return structured list with page references."

2. Create memory entity: "sentimark-ux-audit-feedback"
   Store all extracted items
```

---

## PHASE 2: HIDDEN TRUTH AUDIT (30 min)

### Objective
Reveal what's ACTUALLY broken vs what we THINK is working.

### Execution - Invoke /hidden-truth skill

For EACH user journey, apply the hidden-truth framework:

#### Journey 1: First-Time Visitor
```
URL: http://localhost:3000/v2
Questions:
- What does the page actually communicate to a first visitor?
- What's CONCEALED that should be revealed?
- What assumptions are we making about user understanding?
- Is the value proposition crystal clear within 5 seconds?
```

#### Journey 2: Asset Deep Dive
```
URL: http://localhost:3000/v2/assets/BTC
Questions:
- Does the user understand what Market Pulse means?
- Are the 8 intelligence sources clearly explained?
- Is the data trustworthy-looking or confusing?
- What's hidden that might cause distrust?
```

#### Journey 3: Portfolio Exploration
```
URL: http://localhost:3000/v2/portfolios
Questions:
- Does the user understand the risk profiles?
- Is the AI portfolio concept clear?
- What's concealed about how portfolios work?
```

#### Journey 4: Mobile Experience
```
Viewport: 375x667
URLs: /v2, /v2/assets/BTC, /v2/portfolios
Questions:
- Is touch navigation intuitive?
- Is content readable without zooming?
- What's broken on mobile that works on desktop?
```

### Visual Validation for Each Journey
```
For EACH journey:
1. playwright → browser_navigate
2. playwright → browser_take_screenshot (full page)
3. gemini → gemini-analyze-image (HIGH resolution)
4. Document findings in TodoWrite
```

---

## PHASE 3: ISSUE SYNTHESIS & PRIORITIZATION (15 min)

### Combine All Sources
```
Sources to synthesize:
1. PDF UX Audit feedback (Phase 1)
2. Hidden Truth findings (Phase 2)
3. E2E test failures (3 remaining)
4. Console errors
5. Previous session issues
```

### Create Master Issue List
```
Use TodoWrite to create prioritized list:

[P0-CRITICAL] - Blocks CEO demo
- Examples: Broken navigation, white screens, data not loading

[P1-HIGH] - CEO will notice and be unimpressed
- Examples: Confusing labels, ugly styling, slow loading

[P2-MEDIUM] - Polish for professional look
- Examples: Minor spacing, color tweaks, hover states

[P3-LOW] - Nice to have
- Examples: Micro-interactions, subtle animations
```

### Persist to Memory
```
Create entity: "sentimark-ceo-demo-issues-{timestamp}"
Type: issue_tracker
Observations: Full prioritized list
```

---

## PHASE 4: TDD LOOP EXECUTION (Main overnight loop)

### The Autonomous Loop
```
WHILE (issues remain AND time < 6:00 AM):

    1. GET next P0/P1 issue from TodoWrite

    2. IF issue is UI/visual:
       → Use /frontend skill
       → Use Design Specialist agent for validation

    3. IF issue is logic/data:
       → Use code-worker agent
       → Write test FIRST (tdd-loop pattern)

    4. IMPLEMENT minimal fix

    5. VALIDATE:
       a. Run relevant E2E tests
       b. Take screenshot
       c. Analyze with gemini-analyze-image
       d. Check console for errors

    6. IF validation PASSES:
       → Mark todo as completed
       → Commit with descriptive message
       → git push azure master
       → Update Memory MCP with progress

    7. IF validation FAILS:
       → Log failure reason
       → Try alternative approach (max 3 attempts)
       → IF still failing after 3 attempts:
          → Mark as "BLOCKED" in TodoWrite
          → Move to next issue
          → Persist blocker to Memory MCP

    8. CHECKPOINT every 5 issues:
       → Update Memory MCP with full progress
       → Run full E2E suite
       → Take screenshots of all major pages
       → Compare with previous checkpoint
```

### Loop Control Rules
```
- NEVER spend more than 30 min on single P1 issue
- NEVER spend more than 15 min on single P2 issue
- ALWAYS commit working changes before moving on
- ALWAYS persist progress to Memory MCP every hour
- IF context fills up:
  → Run /compact
  → Persist critical state to Memory first
  → Continue from last checkpoint
```

---

## PHASE 5: VISUAL VALIDATION CHECKPOINTS

### Checkpoint Structure (Run every 2 hours)
```
Pages to validate:
1. Home: http://localhost:3000/v2
2. Asset (BTC): http://localhost:3000/v2/assets/BTC
3. Asset (AAPL): http://localhost:3000/v2/assets/AAPL
4. Portfolios: http://localhost:3000/v2/portfolios
5. Chat: http://localhost:3000/v2/chat
6. Pricing: http://localhost:3000/v2/pricing

For EACH page:
1. Desktop screenshot (1920x1080)
2. Mobile screenshot (375x667)
3. Gemini Vision analysis for each
4. Console error check
```

### Pass Criteria for Each Page
```
✅ Dark theme (#0E1118 background)
✅ All content visible (no opacity:0 stuck)
✅ No "Loading..." stuck states
✅ No error messages visible
✅ No broken images
✅ No layout overflow
✅ Console errors < 3
```

---

## PHASE 6: CEO READINESS CHECKLIST (Final validation)

### Must-Pass Criteria
```
□ Homepage hero clearly explains value prop
□ "Market Pulse" explained somewhere visible
□ AI intelligence sources listed and explained
□ BTC asset page loads with real data
□ AAPL asset page loads with real data
□ Portfolios show meaningful risk breakdown
□ Mobile navigation works smoothly
□ No console errors on any critical page
□ All buttons/links work
□ Loading states don't persist
□ Dark theme consistent throughout
□ Typography readable and professional
□ Color contrast passes WCAG AA
□ No broken images or 404s
```

### Demo Flow Test (Final)
```
Simulate CEO walkthrough:
1. Land on homepage → explain in 10 seconds what this does
2. Click "Explore Assets" → navigate smoothly
3. Select BTC → see comprehensive signal data
4. Check Market Pulse → understand the score
5. View AI Portfolios → understand risk options
6. Mobile: repeat flow → everything works
```

---

## AGENT & MCP ROUTING

### Primary Agents to Use
| Task | Agent | How |
|------|-------|-----|
| PDF parsing | Gemini Document Parser | `Task tool → subagent_type: "Gemini Document Parser"` |
| Visual validation | Design Specialist | `Task tool → subagent_type: "Design Specialist"` |
| Code fixes | code-worker | `Task tool → subagent_type: "code-worker"` |
| Codebase exploration | Explore | `Task tool → subagent_type: "Explore"` |

### MCPs to Use
| MCP | Purpose | Tools |
|-----|---------|-------|
| `playwright` | Screenshots, browser automation | `browser_navigate`, `browser_take_screenshot`, `browser_snapshot` |
| `gemini` | Vision analysis | `gemini-analyze-image` with HIGH resolution |
| `memory` | Persist progress | `create_entities`, `add_observations`, `search_nodes` |

### Skills to Invoke
| Skill | When |
|-------|------|
| `/hidden-truth` | Phase 2 audit |
| `/frontend` | Any UI fixes |
| `/tdd` | Any logic fixes |
| `/enforce-capabilities` | Before major implementations |

---

## PERSISTENCE STRATEGY

### Memory MCP Entities to Maintain
```
1. sentimark-overnight-session-{date}
   - Session start time
   - Issues found
   - Issues fixed
   - Issues blocked
   - Commits made

2. sentimark-ceo-demo-issues-{date}
   - Full prioritized list
   - Status of each

3. sentimark-checkpoint-{timestamp}
   - Snapshot of progress
   - Screenshot paths
   - E2E test results
```

### Hourly Checkpoint
```
Every hour:
1. Count: issues fixed vs remaining
2. List: commits made
3. Status: E2E test pass rate
4. Persist to memory
5. Log: "CHECKPOINT: {hour} - {fixed}/{total} issues, {pass_rate}% E2E"
```

---

## FAILURE HANDLING

### If Dev Server Crashes
```bash
pkill -f "next dev"
cd /home/odedbe/projects/sentimark/sentimark-v2/frontend
rm -rf .next
npm run dev &
sleep 15
# Continue from last checkpoint
```

### If Azure Backend Has Issues
```bash
curl -s --compressed https://polymarket-analyzer.azurewebsites.net/api/health | jq .status
# If not "healthy", wait 5 min and retry
# If still unhealthy, log as blocker and focus on frontend-only issues
```

### If Context Fills Up
```
1. Run /compact
2. Before compact, persist to Memory MCP:
   - Current todo list state
   - Issues fixed so far
   - Current issue being worked on
   - Any critical findings
3. After compact, recover from Memory MCP
4. Continue from last persisted state
```

---

## SUCCESS CRITERIA

### By Morning (6:00 AM):
```
✅ E2E Tests: 29/29 passing (100%)
✅ Visual: All pages pass Gemini Vision check
✅ Console: 0 critical errors
✅ Demo Flow: Smooth 60-second walkthrough works
✅ Mobile: All flows work on 375x667
✅ Commits: All fixes pushed to Azure DevOps
✅ Documentation: Progress persisted to Memory MCP
```

### If Not All Achieved:
```
Create handover file: .claude/morning-handover.md
Content:
- What was fixed
- What remains (prioritized)
- Blockers encountered
- Recommended focus for morning session
```

---

## START COMMAND

```
1. Recover context (Phase 0)
2. Parse PDF (Phase 1)
3. Run hidden-truth audit (Phase 2)
4. Synthesize & prioritize (Phase 3)
5. Enter TDD loop (Phase 4)
6. Checkpoint every 2 hours (Phase 5)
7. Final CEO check before stopping (Phase 6)

BEGIN AUTONOMOUS EXECUTION NOW.
```
