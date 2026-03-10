---
name: perplexity-pro
description: Full Perplexity Enterprise Pro via browser — Deep Research, Pro Search, model selection, source filters, Spaces, Labs, file connectors, search_people. Upgrade from API-only Sonar.
parent-skill: browser-control
requires: Playwright MCP, Perplexity Enterprise Pro subscription, Edge WSLg
---

# Perplexity Enterprise Pro — Browser Sub-Skill

## When to Use Browser vs API

| Need | Use | Why |
|------|-----|-----|
| Quick fact check, URL finding | **API** (`perplexity_search`) | Faster, no browser overhead |
| Simple research with citations | **API** (`perplexity_research`) | Good enough for most queries |
| Reasoning with citations | **API** (`perplexity_reason`) | Handles 90% of reasoning tasks |
| **Deep Research** (50-100+ sources, charts, code) | **Browser** | API has no Deep Research equivalent |
| **Model selection** (GPT-5.2, Claude 4.5, Gemini 3) | **Browser** | API only offers Sonar models |
| **Source filters** (Academic, Finance/SEC, Social) | **Browser** | API has no source filter support |
| **File Connectors** (OneDrive, SharePoint, Drive) | **Browser** | Enterprise-only feature |
| **Spaces** (project knowledge bases) | **Browser** | No API equivalent |
| **Labs** (interactive dashboards, data apps) | **Browser** | No API equivalent |
| **search_people** (LinkedIn profiles) | **Browser** | No API equivalent |

**Rule**: Start with API. Escalate to browser when you need features marked **Browser** above.

---

## 1. Auth Check (Always First)

```
mcp__playwright__browser_navigate url="https://perplexity.ai"
mcp__playwright__browser_snapshot
```

Look for: user avatar/profile icon, "Enterprise Pro" badge, or account menu.
If not logged in: "Please log in to Perplexity Enterprise Pro in the visible browser window."

---

## 2. Search Modes

### Quick Search
Default mode. Fast, concise answers with web sources.
```
mcp__playwright__browser_navigate url="https://perplexity.ai"
mcp__playwright__browser_snapshot
# Type in search box (usually a textarea or input near center)
mcp__playwright__browser_fill_form ref="<search-input>" value="<query>"
mcp__playwright__browser_click ref="<submit-button>"
mcp__playwright__browser_snapshot  # Extract answer + citations
```

### Pro Search
Multi-step reasoning with advanced models. 40+ citations. Best for nuanced questions.
```
# After navigating to perplexity.ai:
mcp__playwright__browser_snapshot  # Find the mode toggle/dropdown
# Look for "Pro" toggle or mode selector near the search box
mcp__playwright__browser_click ref="<pro-toggle>"
mcp__playwright__browser_fill_form ref="<search-input>" value="<query>"
mcp__playwright__browser_click ref="<submit-button>"
# Pro Search takes 15-60 seconds
mcp__playwright__browser_wait_for state="networkidle" timeout=120000
mcp__playwright__browser_snapshot
```

### Deep Research
Autonomous multi-step investigation. Browses 50-100+ sources. Produces structured reports with tables, charts, code. Takes 2-10 minutes.
```
# Look for "Deep Research" option in the mode selector
mcp__playwright__browser_snapshot  # Find mode dropdown
mcp__playwright__browser_click ref="<deep-research-option>"
mcp__playwright__browser_fill_form ref="<search-input>" value="<research query>"
mcp__playwright__browser_click ref="<submit-button>"
# Deep Research takes 2-10 minutes — be patient
# Poll with snapshots every 30-60 seconds to monitor progress
mcp__playwright__browser_wait_for state="networkidle" timeout=600000
mcp__playwright__browser_snapshot  # Extract full report
```

**Deep Research has internal tools** that run automatically:
- `search_web` — live internet search (up to 3 queries per call)
- `get_url_content` — reads full page content from specific URLs
- `execute_code` — Python in Jupyter (data science libraries available)
- `load_chart_skill` — creates Plotly charts as PNG
- `generate_image` — AI image generation
- `search_images` — web image search
- `search_people` — LinkedIn profile search
- `bash` — sandboxed shell commands
- `file_write/read/edit` — file operations during research

---

## 3. Source Filters

Select before submitting a query. Look for "Choose Sources" or filter icons near search box.

| Filter | When to Use | Playwright Action |
|--------|-------------|-------------------|
| **Web** | Default internet search | Usually default, no action needed |
| **Academic Papers** | Peer-reviewed research, scientific data | Click Academic/Papers filter |
| **Social / Discussions** | Reddit, forums, sentiment analysis | Click Social filter |
| **Finance / SEC Filings** | Company filings, financial data | Click Finance filter |
| **Org Files** | Internal company documents | Click Org Files filter |
| **Web + Org Files** | Blended internal + external | Select both sources |

```
mcp__playwright__browser_snapshot  # Find source filter controls
# Look for filter chips, dropdowns, or icons near the search bar
mcp__playwright__browser_click ref="<source-filter-button>"
mcp__playwright__browser_snapshot  # See available filter options
mcp__playwright__browser_click ref="<academic-filter>"  # or finance, social, etc.
# Then submit your query as normal
```

---

## 4. Model Selection

Choose which AI model powers the response. Available in Pro Search mode.

| Model | Best For |
|-------|---------|
| **Best (Auto)** | Let Perplexity choose optimal model |
| **Sonar** | Optimized for search-retrieval (default) |
| **Gemini 3 Flash** | Fast, lightweight queries |
| **Gemini 3 Pro** | Broad knowledge, large context |
| **GPT-5.2** | General-purpose, strong reasoning (has Thinking toggle) |
| **Claude Sonnet 4.5** | Detailed analysis, nuanced writing |
| **Claude Opus 4.6 Max** | Maximum reasoning capability |
| **Grok 4.1** | Alternative reasoning, real-time data |
| **Kimi K2.5** | New — hosted in the US |

```
# In Pro Search mode, look for model selector (usually a dropdown or chip)
mcp__playwright__browser_snapshot
mcp__playwright__browser_click ref="<model-selector>"
mcp__playwright__browser_snapshot  # See model options
mcp__playwright__browser_click ref="<desired-model>"
# Now submit query — it uses the selected model
```

---

## 5. Spaces (Project Knowledge Bases)

Spaces let you organize research by project with uploaded files, custom instructions, and model selection.

### Create a Space
```
mcp__playwright__browser_navigate url="https://perplexity.ai/spaces"
mcp__playwright__browser_snapshot
mcp__playwright__browser_click ref="<create-space-button>"
# Fill in space name, description, custom instructions
mcp__playwright__browser_fill_form ref="<space-name>" value="<project-name>"
mcp__playwright__browser_fill_form ref="<instructions>" value="<custom AI instructions>"
mcp__playwright__browser_click ref="<create-button>"
```

### Upload Files to Space
```
# Navigate to the space
mcp__playwright__browser_snapshot
mcp__playwright__browser_click ref="<upload-button>"
mcp__playwright__browser_file_upload ref="<file-input>" paths=["<local-file-path>"]
```

### Search Within a Space
```
# Navigate to the space first, then query — the Space's files become context
mcp__playwright__browser_fill_form ref="<search-input>" value="<query about uploaded docs>"
mcp__playwright__browser_click ref="<submit-button>"
```

**File limits**: 500 files per Space, max 50 MB each.
**Supported types**: PDF, DOCX, XLSX, PPTX, CSV, Markdown, audio, video.

---

## 6. File Connectors (Enterprise Pro)

Connect cloud storage for AI-searchable internal docs.

| Connector | Notes |
|-----------|-------|
| **Google Drive** | Syncs Docs, Sheets, Slides, PDFs |
| **Microsoft OneDrive** | OAuth via Entra; auto-syncs changes |
| **Microsoft SharePoint** | Connect specific sites; admin-controlled |
| **Dropbox** | Enterprise cloud storage |
| **Box** | Enterprise-grade integration |

```
# Navigate to connector settings
mcp__playwright__browser_navigate url="https://perplexity.ai/settings/connectors"
mcp__playwright__browser_snapshot
# Connect desired service (user completes OAuth manually)
mcp__playwright__browser_click ref="<connector-button>"
```

After connecting, use **Org Files** or **Web + Org Files** source filter to include connected files in search.

---

## 7. Labs (Interactive Dashboards & Data Apps)

Labs creates interactive web apps, dashboards, spreadsheets, and reports. Takes 5-10 minutes.

```
# Look for Labs option in navigation or mode selector
mcp__playwright__browser_navigate url="https://perplexity.ai/labs"
mcp__playwright__browser_snapshot
mcp__playwright__browser_fill_form ref="<labs-input>" value="Create a dashboard comparing..."
mcp__playwright__browser_click ref="<submit-button>"
# Labs takes 5-10 minutes — poll with snapshots
mcp__playwright__browser_wait_for state="networkidle" timeout=600000
mcp__playwright__browser_snapshot  # Extract or screenshot the result
```

**Use Labs for**: Competitive comparison dashboards, data analysis tools, interactive reports, spreadsheets from research.

---

## 8. Data Integrations

| Integration | What It Provides | How to Access |
|-------------|-----------------|---------------|
| **Crunchbase** | Startup funding, investors, rounds | Available in Deep Research automatically |
| **FactSet** | Financial data, market analytics | Available in Deep Research automatically |

These are used automatically during Deep Research when relevant queries are detected.

---

## 9. Content Export

### Pages (Publish Research)
Turn any research thread into a shareable web page with citations.
```
# After completing research, look for "Share as Page" or export option
mcp__playwright__browser_snapshot
mcp__playwright__browser_click ref="<share-page-button>"
mcp__playwright__browser_snapshot  # Get the public URL
```

### Canvas (Collaborative Editing)
Iterate on documents directly within Perplexity.
```
mcp__playwright__browser_snapshot
mcp__playwright__browser_click ref="<canvas-button>"
# Edit content in the collaborative editor
```

---

## 10. Result Extraction Pattern

After any search completes, extract results systematically:

```
# Step 1: Snapshot the full response
mcp__playwright__browser_snapshot

# Step 2: If response is long, scroll to get all content
mcp__playwright__browser_evaluate expression="window.scrollTo(0, document.body.scrollHeight)"
mcp__playwright__browser_snapshot  # Get remaining content

# Step 3: For Deep Research reports with charts/tables
mcp__playwright__browser_take_screenshot  # Visual capture of charts
mcp__playwright__browser_snapshot  # Text extraction of data

# Step 4: Extract citations (usually numbered inline)
# Parse [1], [2], etc. from snapshot text + source URLs
```

---

## Rate Limits (Enterprise Pro)

| Feature | Limit |
|---------|-------|
| Deep Research | 500/day |
| Pro Search | Unlimited |
| Labs | 50/month |
| Quick Search | Unlimited |
| File uploads | 50 MB each, 500 per Space |

---

## Decision Guide — Complete Research Workflow

```
Research task received
  │
  ├─ Quick fact check? → API: perplexity_search
  │
  ├─ Need citations + reasoning? → API: perplexity_reason
  │
  ├─ Need 10+ sources, tables, charts?
  │   └─ Browser: Deep Research
  │
  ├─ Need specific model (GPT-5.2, Claude 4.5)?
  │   └─ Browser: Pro Search + model selector
  │
  ├─ Need academic papers only?
  │   └─ Browser: Pro Search + Academic filter
  │
  ├─ Need SEC/financial data?
  │   └─ Browser: Pro Search + Finance filter
  │       (Crunchbase/FactSet auto-enrich in Deep Research)
  │
  ├─ Need to search internal company docs?
  │   └─ Browser: Org Files filter (requires file connectors)
  │
  ├─ Need interactive dashboard/tool?
  │   └─ Browser: Labs
  │
  ├─ Need to find a person (LinkedIn)?
  │   └─ Browser: Deep Research (search_people tool)
  │
  └─ Need project-organized research?
      └─ Browser: Create/use a Space
```

---

## Security

- **NEVER** export or share session tokens
- **NEVER** automate login — user logs in manually via visible browser
- **NEVER** access other users' Spaces or Org Files without authorization
- **ALWAYS** verify auth state before queries
- **ALWAYS** respect rate limits (especially Deep Research and Labs)
- File connectors are personal — teammates can't query YOUR connected files
