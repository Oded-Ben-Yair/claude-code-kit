---
name: browser-control
description: Browser automation using Edge with persistent sessions via WSLg. Enables authenticated access to Perplexity Pro, ChatGPT, LinkedIn, HeyGen, and more.
argument-hint: Navigate to [url] or interact with authenticated services
allowed-tools: Read, Write, Bash, mcp__playwright__*
context: fork
requires: Edge installed in WSL, WSLg enabled (Windows 11)
metadata:
  version: "1.0.0"
  author: odedbe
---

# Browser Control System

**Purpose**: Use Edge browser with persistent user data for authenticated sessions via Playwright MCP.

---

## Architecture & Setup

See `references/setup.md` for Edge WSLg setup, architecture details, configuration, and prerequisites.

---

## Usage

### Direct Playwright MCP tools now use Edge

After Claude Code restart, all `mcp__playwright__*` tools automatically use Edge:

```
mcp__playwright__browser_navigate url="https://perplexity.ai"
mcp__playwright__browser_snapshot
mcp__playwright__browser_take_screenshot
mcp__playwright__browser_click ref="e5"
```

### Verify Edge is being used

```javascript
// Run this to confirm:
mcp__playwright__browser_run_code code="async (page) => {
  return await page.evaluate(() => navigator.userAgent);
}"
// Should contain "Edg/" in the user agent string
```

---

## Authenticated Sessions

### First-time login flow

1. Navigate to site: `mcp__playwright__browser_navigate url="https://perplexity.ai"`
2. You'll see Edge window appear via WSLg
3. Log in manually in the visible browser window
4. Continue automation - session is now active
5. Session persists in `~/.config/microsoft-edge-playwright` across restarts

### Supported services

| Service | URL | Auth Required |
|---------|-----|---------------|
| Perplexity Pro | perplexity.ai | Yes (Pro features) |
| ChatGPT | chat.openai.com | Yes |
| LinkedIn | linkedin.com | Yes |
| HeyGen | heygen.com | Yes |
| Google AI Studio | aistudio.google.com | Yes |
| Canva | canva.com | Yes |
| Any website | * | Depends |

---

## Common Operations

### Research with Perplexity Pro

```
1. mcp__playwright__browser_navigate url="https://perplexity.ai"
2. (User logs in if needed)
3. mcp__playwright__browser_snapshot  # Get page structure
4. mcp__playwright__browser_fill_form ref="search-input" value="your query"
5. mcp__playwright__browser_click ref="search-button"
6. mcp__playwright__browser_snapshot  # Get results
```

### Screenshot a page

```
mcp__playwright__browser_navigate url="https://example.com"
mcp__playwright__browser_take_screenshot type="png"
```

### Extract page content

```
mcp__playwright__browser_navigate url="https://example.com"
mcp__playwright__browser_snapshot  # Returns accessible tree
```

---

## Sub-Skills (Specialized Browser Workflows)

Route to the appropriate sub-skill based on user intent:

| Intent | Sub-Skill | Auth Required |
|--------|-----------|---------------|
| Deep Research, Pro Search, model selection, source filters, Spaces, Labs, file connectors | `sub-skills/perplexity-pro.md` | Perplexity Enterprise Pro |
| ChatGPT Deep Research / Agent Mode | `sub-skills/chatgpt-research.md` | ChatGPT Plus/Pro |
| Company/market intelligence | `sub-skills/linkedin-intel.md` | LinkedIn (READ-ONLY) |
| Competitor ads, Reddit, TikTok | `sub-skills/social-research.md` | Varies |

### Routing Logic

1. **"deep research"** + 10+ sources / charts / tables --> Perplexity Pro (Deep Research)
2. **"academic papers"** / **"SEC filings"** / **"social sentiment"** --> Perplexity Pro (Source Filters)
3. **"use GPT-5.2"** / **"use Claude"** / **"use Gemini"** for search --> Perplexity Pro (Model Selection)
4. **"search internal docs"** / **"org files"** --> Perplexity Pro (File Connectors)
5. **"create a dashboard"** / **"interactive report"** --> Perplexity Pro (Labs)
6. **"find person"** / **"who works at"** --> Perplexity Pro (search_people via Deep Research)
7. **"deep research"** + autonomous browsing --> ChatGPT Research
8. **"company research"** / **"hiring"** / **"competitor team"** --> LinkedIn Intel
9. **"competitor ads"** / **"ad creative"** --> Social Research (Meta Ad Library)
10. **"reddit"** / **"product sentiment"** --> Social Research (Reddit)
11. **"trending content"** / **"tiktok"** --> Social Research (TikTok)

### Free API Registration Workflow

When we need a new API key, Claude guides the user through registration via browser:
1. Navigate to signup page
2. User fills credentials manually (NEVER automate password entry)
3. Claude extracts API key from dashboard after user logs in
4. Store in Secret Manager: `az keyvault secret set --vault-name ${SECRET_STORE:-secret-manager} --name <SecretName> --value <key>`

**Priority free APIs:**
- Google Gemini API (free, 15 RPM) -- backup for Gemini MCP
- Alpha Vantage (free, 25/day) -- financial data for Sentimark
- Groq (free, fast inference) -- potential ultra-fast code gen

---

## Troubleshooting

See `references/setup.md` for troubleshooting Edge, WSLg, session persistence, and failed approaches.

---

## Security

**NEVER:**
- Export cookies or session tokens
- Automate password entry
- Access banking/financial sites via automation
- Share or log session data

**ALWAYS:**
- Let user manually log in via visible browser
- Use humanized delays on rate-limited sites
- Get user confirmation for destructive actions
- Keep profile data local

---

*Part of Silent Kernel Architecture v8.0*
