# Silent Kernel v7.0 - Usage Guide

**How to effectively use your new Claude Code environment**

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    TRIGGER WORDS                             │
├─────────────────────────────────────────────────────────────┤
│ "research..."        → Perplexity (deep research)           │
│ "what's trending..." → Grok (real-time social)              │
│ "analyze image..."   → Gemini (vision)                      │
│ "prove/theorem..."   → DeepSeek (gold-medal math)           │
│ "brainstorm..."      → GPT-5 Pro (creativity)               │
│ "quick fix..."       → Grok Code (92 tok/s fast)            │
│ "implement..."       → Code Worker → Judge flow             │
│ "plan/architect..."  → Architect Planner                    │
│ "review code..."     → Code Judge + Azure Code Review       │
│ "library docs..."    → Context7 (live docs)                 │
├─────────────────────────────────────────────────────────────┤
│ /end-of-session      → Save state, extract learnings        │
│ /morning-update      → Daily briefing, research updates     │
│ /orchestrator        → Full Planner→Worker→Judge flow       │
│ /architecture-doc    → Generate PDF-ready docs              │
└─────────────────────────────────────────────────────────────┘
```

---

## Workflow 1: Entering a Project (Status Audit)

### Step 1: Navigate to Project
```bash
cd ~/projects/sentimark
```

The session-start hook automatically:
- Loads `.claude/status.json` (if exists)
- Shows capability router
- Displays health alerts
- Reminds you of critical rules

### Step 2: Request Full Status Audit

**Best Prompt Format:**
```
Give me a full status audit of this project:
1. Read the project status and recent decisions
2. Check git status and recent commits
3. Identify any blockers or issues
4. Review the current architecture
5. List what's in progress and next steps
```

**Why this works:** Explicit numbered steps ensure thorough coverage.

### Step 3: Request E2E Review

**Best Prompt Format:**
```
Run an E2E review of the application:
1. Check if the app builds successfully
2. Run the test suite and report results
3. Take screenshots of key pages and analyze with Gemini
4. Check for console errors
5. Verify API endpoints are responding
6. Report any issues found with severity ratings
```

**Key phrases that trigger the right tools:**
- "take screenshots" → Playwright + Gemini Vision
- "analyze with Gemini" → gemini-analyze-image
- "run tests" → Bash test commands
- "check console errors" → Playwright console messages

---

## Workflow 2: Feature Implementation

### Option A: Simple Feature (Direct)
```
Quick fix: Add a loading spinner to the submit button
```
→ Routes to Grok Code (fast, 92 tok/s)

### Option B: Medium Feature (Worker + Judge)
```
Implement a logout button in the header that clears the session and redirects to login
```
→ Routes to Code Worker, then Code Judge validates

### Option C: Complex Feature (Full Orchestrator)
```
/orchestrator Add user authentication with JWT tokens, protected routes, and session management
```
→ Full Planner → Implementer → Verifier flow with iteration

**Or trigger naturally:**
```
Plan and implement a complete notification system with:
- Real-time WebSocket updates
- Notification preferences
- Email fallback
- Database storage
```
→ Complexity triggers orchestrator automatically

---

## Workflow 3: Research & Investigation

### Current Information
```
Research the latest best practices for React Server Components in 2026
```
→ Routes to Perplexity Research

### Library Documentation
```
How do I use the Prisma ORM for complex relations? Show me the current docs.
```
→ Routes to Context7 for live documentation

### Social/Trending
```
What's trending on X about the new OpenAI announcement today?
```
→ Routes to Grok Social Pulse

### Deep Analysis
```
Research and compare: PostgreSQL vs TimescaleDB for time-series financial data.
Include benchmarks, use cases, and migration considerations.
```
→ Routes to Perplexity Deep Research

---

## Workflow 4: Code Review

### Quick Review
```
Review this function for security issues: [paste code]
```
→ Routes to Code Judge + Azure Code Review

### Full PR Review
```
Review the changes in this PR for:
- Security vulnerabilities
- Performance issues
- Code quality
- Test coverage
- Pattern compliance with existing codebase
```
→ Routes to Code Judge with comprehensive checklist

### Architecture Review
```
Analyze the current architecture and identify:
- Potential bottlenecks
- Security concerns
- Scalability issues
- Technical debt
```
→ Routes to Architect Planner for analysis

---

## Workflow 5: Visual/Design Tasks

### Analyze Screenshot
```
Analyze this screenshot and identify UI/UX issues: [path to image]
```
→ Routes to Gemini Vision

### Design to Code
```
/frontend Convert this design screenshot to React components with Tailwind CSS
```
→ Routes to Frontend skill with Gemini

### Accessibility Audit
```
Run an accessibility audit on the dashboard page, check WCAG compliance
```
→ Routes to Gemini UI Auditor

---

## Workflow 6: Complex Decisions

### Multi-Model Debate
```
/multi-model-debate Should we migrate from REST to GraphQL for our API?
Consider: performance, complexity, team expertise, client needs
```
→ 6-model council debates and synthesizes recommendation

### Trade-off Analysis
```
Analyze the trade-offs between these approaches for real-time updates:
1. WebSockets
2. Server-Sent Events
3. Long polling
4. GraphQL subscriptions

Consider our specific constraints: [list constraints]
```
→ Routes to Reasoning Specialist for structured analysis

---

## Workflow 7: End of Session

### Standard Close
```
/end-of-session
```
→ Runs all 7 phases:
1. Session Identity
2. State Assessment
3. Achievement Analysis
4. **Learning Loop (Phase 3.5)** - Extracts patterns
5. Memory MCP Persistence
6. Git Operations
7. Handover Generation

### Quick Close
```
/end-of-session --mode=quick
```
→ Skips git push, minimal validation

---

## Prompt Patterns for Best Results

### Pattern 1: Explicit Tool Request
```
Use Gemini to analyze this image: [path]
Use Perplexity to research: [topic]
Use Context7 to get the latest docs for: [library]
```

### Pattern 2: Numbered Steps
```
Do this task in order:
1. First, [step 1]
2. Then, [step 2]
3. Finally, [step 3]
```

### Pattern 3: Constraint Specification
```
[Task description]

Constraints:
- Must follow existing patterns in the codebase
- Must include tests
- Must not break existing functionality
- Maximum 3 files changed
```

### Pattern 4: Verification Request
```
[Task description]

Verify by:
- Running the test suite
- Taking a screenshot of the result
- Showing the actual API response
```

### Pattern 5: Context Loading
```
Before making any changes:
1. Read the project status.json
2. Check recent git commits
3. Search for similar patterns in the codebase
Then: [your task]
```

---

## Anti-Patterns (What NOT to Do)

### ❌ Don't: Vague requests
```
Fix the bug
```

### ✅ Do: Specific requests
```
Fix the login timeout bug in src/auth/login.ts - users report
being logged out after 5 minutes instead of 30
```

### ❌ Don't: Skip verification
```
Add the feature (trust me it works)
```

### ✅ Do: Request proof
```
Add the feature and verify by running tests and showing a screenshot
```

### ❌ Don't: Bypass established patterns
```
Just push directly to main
```

### ✅ Do: Use proper workflow
```
Create a PR with these changes and run through the pipeline
```

---

## Example: Sentimark Full Audit

Here's exactly what to say for a full Sentimark audit:

```
I'm entering the Sentimark project for a full status audit and E2E review.

## Status Audit
1. Read .claude/status.json and summarize current state
2. Check git status - any uncommitted changes or pending PRs?
3. What were the recent decisions made? Check Memory MCP
4. List any blockers or issues

## E2E Application Review
5. Build the application and report any errors
6. Run the full test suite
7. Start the dev server and take screenshots of:
   - Dashboard page
   - Analytics page
   - Settings page
8. Analyze each screenshot with Gemini for visual issues
9. Check browser console for errors
10. Test the main API endpoints and verify responses

## Architecture Health
11. Are there any obvious code smells or technical debt?
12. Is the test coverage adequate?
13. Any security concerns?

Provide a summary report with:
- Overall health score (0-100)
- Critical issues (must fix)
- Warnings (should fix)
- Recommendations (nice to have)
```

This prompt will:
- Load project context (auto via hook)
- Use Playwright for screenshots
- Use Gemini for visual analysis
- Use Code Judge for code review
- Generate structured report

---

## Quick Command Reference

| Need | Say |
|------|-----|
| Research something | "Research [topic]" |
| Quick code fix | "Quick fix: [description]" |
| Full feature | "Implement [feature] with tests" |
| Code review | "Review [code/PR] for [concerns]" |
| Visual analysis | "Analyze this screenshot: [path]" |
| Architecture | "Plan the architecture for [feature]" |
| Complex decision | "/multi-model-debate [question]" |
| Library help | "How do I use [library] for [task]?" |
| Social trends | "What's trending on X about [topic]?" |
| End session | "/end-of-session" |
| Morning briefing | "/morning-update" |

---

*Part of Silent Kernel Architecture v7.0*
