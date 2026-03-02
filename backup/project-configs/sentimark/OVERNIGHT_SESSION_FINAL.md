# SENTIMARK OVERNIGHT AUTONOMOUS SESSION
## CEO Demo Readiness - Run Overnight, Perfect by Morning

**Mission**: Fix ALL issues so Sentimark is CEO-presentation-ready by 6:00 AM.

**Mode**: EXECUTE (autonomous overnight operation - NO waiting for approval)

---

## CRITICAL RULES (READ FIRST)

### DO:
- Use TodoWrite for ALL task tracking
- Persist progress to Memory MCP every hour
- Commit working fixes immediately (don't batch)
- Take screenshots after EVERY visual change
- Move on if stuck for >20 minutes on any issue

### DO NOT:
- Enter plan mode (you're in EXECUTE mode)
- Wait for human approval
- Spend >30 min on any single issue
- Make changes without visual validation
- Forget to push commits to Azure DevOps

---

## PHASE 0: CONTEXT RECOVERY (5 min)

```
1. Memory MCP search: "sentimark-session-20260119"
2. Memory MCP search: "sentimark-prod-readiness-issues"
3. Read: ~/projects/sentimark/CLAUDE.md
4. Read: ~/projects/sentimark/.claude/handover-20260119-prod-readiness.md
```

**Known State** (commit 8e2a865):
- Backend: HEALTHY
- E2E Tests: 26/29 pass
- Open issues: timestamps, time horizons, 6 console errors

---

## PHASE 1: PDF FEEDBACK EXTRACTION (10 min)

**File**: `/home/odedbe/projects/sentimark/UX Audit Financial App.pdf`

**Agent**: `Gemini Document Parser`
```
Task tool → subagent_type: "Gemini Document Parser"
Prompt: "Extract ALL UX feedback from this PDF. Return as prioritized list:
         P0-Critical, P1-High, P2-Medium, P3-Low. Include page references."
```

**Output**: Add findings to TodoWrite as tasks

---

## PHASE 2: APP AUDIT (30 min)

### Invoke `/hidden-truth` skill, then audit these pages:

| Page | URL | Check For |
|------|-----|-----------|
| Home | /v2 | Value prop clear in 5 seconds? |
| Asset | /v2/assets/BTC | Data trustworthy? Signals explained? |
| Portfolios | /v2/portfolios | Risk profiles clear? |
| Mobile | All above @375x667 | Touch works? Readable? |

### For EACH page:
```
1. playwright → browser_navigate(url)
2. playwright → browser_take_screenshot(fullPage: true)
3. gemini → gemini-analyze-image with mediaResolution: HIGH
4. Add issues found to TodoWrite
```

---

## PHASE 3: PRIORITIZE ISSUES (10 min)

### Combine all sources into ONE TodoWrite list:
1. PDF feedback (Phase 1)
2. App audit findings (Phase 2)
3. Known E2E failures (3 tests)
4. Console errors

### Priority Order:
```
P0: Blocks demo (broken nav, white screens, data not loading)
P1: CEO will notice (confusing UX, ugly styling)
P2: Polish (spacing, colors, hover states)
P3: Nice-to-have (micro-interactions)
```

### Persist to Memory:
```
Entity: "sentimark-overnight-issues-20260120"
Observations: [full prioritized list]
```

---

## PHASE 4: FIX LOOP (Main overnight work)

### The Loop:
```
WHILE (P0 or P1 issues remain) AND (time < 5:30 AM):

  1. GET next issue from TodoWrite (P0 first, then P1)

  2. IMPLEMENT fix:
     - UI issues → Use /frontend skill
     - Logic issues → Use code-worker agent

  3. VALIDATE fix:
     a. playwright → take screenshot
     b. gemini → analyze screenshot (expect correct rendering)
     c. Run: npx playwright test --grep="relevant test"
     d. Check browser console errors

  4. IF PASS:
     - Mark todo COMPLETED
     - git add && git commit && git push azure master
     - Log: "FIXED: [issue description]"

  5. IF FAIL (after 2 attempts):
     - Mark todo as BLOCKED
     - Add observation to Memory: "BLOCKED: [reason]"
     - MOVE TO NEXT ISSUE

  6. EVERY 5 ISSUES:
     - Full E2E run: npx playwright test --project=desktop-chrome
     - Update Memory with checkpoint
```

### Time Limits:
| Priority | Max Time Per Issue |
|----------|-------------------|
| P0 | 30 minutes |
| P1 | 20 minutes |
| P2 | 10 minutes |

---

## PHASE 5: HOURLY CHECKPOINT

Every hour, run this checkpoint:

```
1. Count issues: fixed vs remaining
2. E2E status: X/29 passing
3. Screenshots of: /v2, /v2/assets/BTC, /v2/portfolios (desktop + mobile)
4. Console error count
5. Persist ALL to Memory MCP:
   Entity: "sentimark-checkpoint-{hour}"
   Observations: [stats, screenshot paths, blockers]
6. Log: "CHECKPOINT {hour}: {fixed}/{total} fixed, {X}/29 E2E"
```

---

## PHASE 6: FINAL CEO CHECK (30 min before stopping)

### Required Screenshots (all must PASS):
| Page | Desktop | Mobile | Pass Criteria |
|------|---------|--------|---------------|
| Home | 1920x1080 | 375x667 | Hero visible, dark theme |
| BTC Asset | 1920x1080 | 375x667 | Data loaded, signals visible |
| AAPL Asset | 1920x1080 | 375x667 | Data loaded, signals visible |
| Portfolios | 1920x1080 | 375x667 | Cards visible, risks shown |

### Demo Flow Test:
```
1. Home → "Explore Assets" button works
2. Asset list → Click BTC → Data loads
3. BTC page → Market Pulse visible and explained
4. Back to Home → Portfolios section → Cards work
5. Mobile: Same flow on 375x667
```

### Final E2E Run:
```
npx playwright test --project=desktop-chrome --reporter=list
Expected: 29/29 PASS
```

---

## AGENT & MCP REFERENCE

### Agents (via Task tool):
| Agent | subagent_type | When |
|-------|---------------|------|
| PDF Parser | `Gemini Document Parser` | Phase 1 |
| Visual Check | `Design Specialist` | All visual validation |
| Code Fix | `code-worker` | Implementing fixes |
| Explore | `Explore` | Finding patterns |

### MCPs:
| MCP | Tools | When |
|-----|-------|------|
| playwright | `browser_navigate`, `browser_take_screenshot` | All visual work |
| gemini | `gemini-analyze-image` | Screenshot analysis |
| memory | `create_entities`, `add_observations` | Progress persistence |

### Skills:
| Skill | When |
|-------|------|
| `/hidden-truth` | Phase 2 audit |
| `/frontend` | UI fixes |
| `/tdd` | Logic fixes (test first) |

---

## FAILURE HANDLING

### Dev Server Crashes:
```bash
pkill -f "next dev"; sleep 2
cd ~/projects/sentimark/sentimark-v2/frontend
rm -rf .next && npm run dev &
sleep 15
```

### MCP Not Responding:
- playwright fails → Use Bash curl + manual checks
- gemini fails → Skip vision validation, rely on E2E tests
- memory fails → Write to `.claude/overnight-log.md` instead

### Context Fills Up:
```
1. BEFORE /compact: Persist to Memory MCP
   - Current TodoWrite state
   - Issues fixed so far
   - Current issue in progress
2. AFTER /compact: Recover from Memory MCP
3. Continue from last checkpoint
```

---

## SUCCESS OUTPUT

### By 6:00 AM, produce:
```
1. E2E Results: 29/29 passing
2. Screenshot Gallery: All pages, both viewports
3. Memory Entity: "sentimark-overnight-complete-20260120"
   - Issues fixed (list)
   - Issues blocked (list with reasons)
   - Commits made (list)
   - Final E2E pass rate
4. If issues remain: .claude/morning-handover.md
```

---

## START NOW

```
Execute in order:
1. Phase 0: Context recovery
2. Phase 1: PDF extraction
3. Phase 2: App audit
4. Phase 3: Prioritize
5. Phase 4: Fix loop (main work)
6. Phase 5: Hourly checkpoints
7. Phase 6: Final CEO check

BEGIN AUTONOMOUS EXECUTION. DO NOT WAIT FOR HUMAN INPUT.
```
