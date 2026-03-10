---
name: linkedin-intel
description: Company research, market intelligence, hiring patterns from LinkedIn - STRICTLY READ-ONLY
parent-skill: browser-control
requires: Playwright MCP, LinkedIn account (logged in)
---

# LinkedIn Intelligence Browser Sub-Skill

## Purpose
Company research, market intelligence, hiring patterns - READ-ONLY

## SECURITY RULES (HARD - NON-NEGOTIABLE)
- **NEVER** interact: no likes, comments, connections, messages, endorsements
- **NEVER** send InMails or connection requests
- **NEVER** follow or unfollow anyone
- **ONLY** navigate and read public/connected data
- **Rate limit**: max 30 page views per session
- **User MUST confirm** before each research session starts

## When to Use
- Company employee count, growth trends, hiring activity
- Job market data: role trends, salary signals
- Competitor team structure analysis
- Technology stack signals from job postings
- Industry hiring patterns

## Workflow

### 1. User Confirmation Gate
ALWAYS ask: "I need to access LinkedIn for company research. This will be READ-ONLY (no interactions). Proceed?"

### 2. Auth Check
```
mcp__playwright__browser_navigate url="https://linkedin.com"
mcp__playwright__browser_snapshot  # Verify logged in
```

### 3. Company Research
```
# Navigate to company page
mcp__playwright__browser_navigate url="https://linkedin.com/company/<company-name>"
mcp__playwright__browser_snapshot  # Extract company info
# Check jobs tab
mcp__playwright__browser_navigate url="https://linkedin.com/company/<company-name>/jobs"
mcp__playwright__browser_snapshot
# Check people tab for team structure
mcp__playwright__browser_navigate url="https://linkedin.com/company/<company-name>/people"
mcp__playwright__browser_snapshot
```

### 4. Job Market Analysis
```
mcp__playwright__browser_navigate url="https://linkedin.com/jobs/search/?keywords=<role>&location=<location>"
mcp__playwright__browser_snapshot
```

## Rate Limiting
- Track page views (max 30 per session)
- Add 3-5 second delays between navigations
- If rate-limited, STOP immediately and inform user

## Output
- Company overview: size, growth, headquarters
- Hiring activity: open roles, departments hiring
- Technology signals: tech stack from job posts
- Team structure: department sizes (from People tab)
