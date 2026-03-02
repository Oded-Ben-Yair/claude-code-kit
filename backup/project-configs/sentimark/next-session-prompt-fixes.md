# Next Session Prompt - Sentimark V2 Fix Implementation

**Copy-paste this entire prompt to start the next session:**

---

## SESSION CONTEXT

I'm continuing work on Sentimark V2. The frontend audit was completed in the previous session with 34 production screenshots. Here are the critical findings that need to be fixed:

### Previous Session Reference
- **Session ID**: `sentimark-session-20260119-104a9f`
- **Memory MCP**: Search for `sentimark-session-20260119` to load full context
- **Handover**: `.claude/handover-20260119-104a9f.md`
- **Audit Checklist**: `.claude/audit-validation-checklist.md`
- **Priority List**: `.claude/sentimark-priority-list.md`
- **Feature Matrix**: `.claude/sentimark-feature-audit.md`
- **Screenshots**: `.playwright-mcp/prod-*.png` (34 files)

---

## ISSUES TO FIX (In Priority Order)

### P0 #1 - CRITICAL: Pro Analysis Tabs Return 500 Errors

**Problem**: ALL Pro Analysis tabs (Fundamentals, ESG, Insider) return HTTP 500 errors from the backend for ALL asset types.

**Evidence**:
- BTC: Screenshots prod-15, prod-16, prod-17 show 500 errors
- AAPL: Screenshots prod-20, prod-21, prod-22 show 500 errors
- GOLD: Screenshots prod-25, prod-26, prod-27 show 500 errors

**Backend**: `polymarket-analyzer.azurewebsites.net`

**Task**: Debug the polymarket-analyzer Azure Functions backend to find why the Pro Analysis endpoints are returning 500 errors.

**Agent to Use**: `Azure DevOps Specialist` agent for Azure Functions debugging
- Check Application Insights logs
- Review function_app.py for Pro Analysis endpoints
- Check if API keys or external services are failing

### P0 #2 - NextAuth Security Configuration

**Problem**: Console shows security warnings on all pages:
- `[next-auth][warn][NO_SECRET]`
- `[next-auth][warn][NEXTAUTH_URL]`

**Task**: Set environment variables in Azure Static Web App:
- `NEXTAUTH_SECRET` - Generate secure random string
- `NEXTAUTH_URL` - Set to `https://sentimark-v2-frontend.azurewebsites.net`

**Agent to Use**: `Azure DevOps Specialist` agent
- Use `az staticwebapp appsettings set` to configure env vars

### P1 #1 - Signal Alignment vs ML Pipeline Contradiction

**Problem**: For GOLD asset:
- Signal Alignment shows "Bulls leading (3 vs 0)"
- ML Pipeline shows "BEARISH (52%)"
- This contradicts and confuses users

**Evidence**: Screenshot prod-24-gold-ml-pipeline.png

**Task**: Investigate why these signals contradict:
1. Check how Signal Alignment calculates direction
2. Check how ML Pipeline calculates direction
3. Determine which is authoritative
4. Either fix calculation OR add explanation to UI

**Agent to Use**: `Explore` agent to understand the signal calculation code, then `code-worker` to implement fix

### P1 #2 - Signals Display UX

**Problem**: User feedback "signals not clear" - most signals show NEUTRAL (50), message "Signals in conflict - no clear direction" is not actionable.

**Task**: Improve UX:
1. Review current signals calculation in backend
2. Either fix backend to produce more decisive signals
3. OR redesign UI to make NEUTRAL state more informative

---

## AGENT ROUTING GUIDE

Use these specialized agents for optimal results:

| Task | Agent | Why |
|------|-------|-----|
| Azure Functions debugging | `Azure DevOps Specialist` | Has Azure CLI, Functions, AI Foundry tools |
| Check Application Insights | `Azure DevOps Specialist` | Can query Azure logs |
| Code exploration | `Explore` agent | Fast codebase navigation |
| Architecture planning | `architect-planner` agent | Design before implementing |
| Code implementation | `code-worker` agent | Focused code writing |
| Code review | `code-judge` agent | Hostile review to find issues |
| Visual verification | `Design Specialist` agent | Playwright + Gemini Vision |

### MCP Tools to Use

| Task | MCP Tool |
|------|----------|
| Research Azure Functions errors | `mcp__perplexity__perplexity_search` |
| Deep reasoning on signal logic | `mcp__gemini__gemini-query` with thinkingLevel="high" |
| Code review | `mcp__azure-ai-foundry__azure_code_review` |
| Quick code generation | `mcp__grok__grok_code` |

---

## WORKFLOW RECOMMENDATION

1. **Enter Plan Mode** (`EnterPlanMode` tool) to design fix approach
2. **Run `/enforce-capabilities`** to enrich plan with proper agents
3. **Execute fixes** in P0 → P1 priority order
4. **Visual verify** each fix with Playwright + Gemini Vision
5. **Update priority list** as issues are resolved

---

## SUCCESS CRITERIA

- [ ] Pro Analysis tabs return data (not 500 errors) for BTC, AAPL, GOLD
- [ ] No NextAuth warnings in browser console
- [ ] Signal Alignment and ML Pipeline show consistent or explained signals
- [ ] At least one visual verification screenshot per fixed issue

---

## START COMMAND

Begin by reading the priority list and handover file:

```
Read: .claude/sentimark-priority-list.md
Read: .claude/handover-20260119-104a9f.md
```

Then enter plan mode to design the fix approach for P0 #1 (Pro Analysis 500 errors).

