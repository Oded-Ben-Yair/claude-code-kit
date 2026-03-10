# Perplexity Enterprise Pro — Complete Capabilities Reference

> **Purpose:** Quick-reference for your coding agent. Use this to decide *which* Perplexity tool/feature to invoke and *when*.

---

## 1. SEARCH MODES

| Mode | What It Does | When to Use |
|---|---|---|
| **Quick Search** | Fast, concise answer from web sources | Simple factual lookups, definitions, quick checks |
| **Pro Search** | Multi-step reasoning with advanced models (GPT-5.2, Claude Sonnet 4.5, Gemini 3 Pro) | Nuanced questions, deeper synthesis, multi-source answers |
| **Deep Research** | Autonomous multi-step investigation; browses 50–100+ sources over several minutes; produces structured cited reports with tables, charts, and code | Comprehensive analysis, comparisons, planning, literature reviews, competitive research |

### Source Filters (Choose Sources)
- **Web** — Internet sources only
- **Org Files** — Organization's internal file repository only
- **Web + Org Files** — Blended answers from both (recommended default for enterprise work)
- **None** — LLM responds without external sources (brainstorming, drafting)

### Filtered Search Categories
- **Academic Papers** — Peer-reviewed research
- **Social / Discussions** — Reddit, forums, social media sentiment
- **Finance / SEC Filings** — Company filings, financial data
- **Shopping** — Product pricing, reviews
- **Travel** — Destinations, flights, logistics

---

## 2. FILE CONNECTORS (Enterprise Pro)

| Connector | Status | Notes |
|---|---|---|
| **Google Drive** | ✅ Available | Sync Google Docs, Sheets, Slides, PDFs |
| **Microsoft OneDrive** | ✅ Available | OAuth via Microsoft Entra; auto-syncs changes |
| **Microsoft SharePoint** | ✅ Available | Connect specific SharePoint sites; admin-controlled |
| **Dropbox** | ✅ Available | Sync files for AI search |
| **Box** | ✅ Available | Enterprise-grade cloud storage integration |

**Key behaviors:**
- Connections are personal — teammates can't query *your* Drive unless you sync files to a shared Space.
- Admins can enable/disable each connector organization-wide.
- **Supported file types:** PDF, DOCX, XLSX, PPTX, CSV, Markdown, Google Docs/Sheets/Slides, audio, video.
- **File limits:** Up to 500 files per Space, 500 in org repository, 5,000 in user repository; max 50 MB each.

---

## 3. DATA INTEGRATIONS

| Integration | What It Provides |
|---|---|
| **Crunchbase** | Startup/company funding data, investors, rounds |
| **FactSet** | Financial data, market analytics, company fundamentals |

> Use these when you need verified financial or startup ecosystem data enriched into your research.

---

## 4. INTERNAL KNOWLEDGE SEARCH

- **Org File Repository** — Admins upload files centrally; all team members can search them. Select "Org Files" as source.
- **Spaces** — Project-specific knowledge bases. Upload files, set custom AI instructions, choose models, invite collaborators.
- **Blended Search** — Combine org files + web for comprehensive answers with inline citations back to your internal docs.

---

## 5. DEEP RESEARCH TOOLS (Used Automatically During Research)

When Deep Research runs, it has access to these internal tools:

| Tool | What It Does | Typical Use |
|---|---|---|
| **search_web** | Searches the live internet with keyword queries (up to 3 per call) | Fact-finding, current events, data gathering |
| **get_url_content** | Navigates to specific URLs and reads full page content | Reading articles, tables, PDFs, documentation |
| **execute_code (Python)** | Runs Python in a persistent Jupyter environment; has data science libraries | Data analysis, calculations, CSV processing, algorithm work |
| **load_chart_skill + execute_code** | Creates Plotly charts saved as PNG | Data visualization, trend charts, comparisons |
| **generate_image** | Creates images using AI models (GPT Image 1, FLUX.1, Seedream 4.5, Nano Banana) | Illustrations, mockups, designs, thumbnails, text rendering |
| **search_images** | Finds existing photographs, diagrams, illustrations from the web | Visual references for people, places, products, art |
| **search_people** | Searches LinkedIn for professional profiles | Finding people by name, role, company, or location |
| **search_user_memories** | Retrieves stored user preferences, past interactions, personal context | Personalized recommendations, recalling past decisions |
| **bash** | Executes shell commands in sandboxed Linux | File operations, downloading, text processing |
| **file_write / file_read / file_edit** | Read/write/edit files during research | Saving notes, building reports iteratively |
| **create_text_file** | Creates downloadable .md or .tex files | Delivering formatted documents to the user |

---

## 6. AI MODELS AVAILABLE

| Model | Best For |
|---|---|
| **Best (Auto)** | Let Perplexity pick the optimal model per query |
| **Sonar** (Perplexity in-house) | Optimized for search-retrieval tasks |
| **Gemini 3 Flash** (Google) | Fast, lightweight queries |
| **Gemini 3 Pro** (Google) | Broad knowledge, large context |
| **GPT-5.2** (OpenAI) | General-purpose, strong reasoning (has Thinking toggle) |
| **Claude Sonnet 4.5** (Anthropic) | Detailed, nuanced analysis with extensive sources |
| **Claude Opus 4.6 Max** (Anthropic) | Maximum reasoning capability |
| **Grok 4.1** (xAI) | Alternative reasoning model |
| **Kimi K2.5** (Moonshot AI) | New — hosted in the US |

---

## 7. CONTENT CREATION FEATURES

| Feature | Description | When to Use |
|---|---|---|
| **Labs** | Builds interactive web apps, dashboards, spreadsheets, and reports using web search + code execution + charts. Takes 5–10 min. | Complex deliverables: dashboards, interactive tools, data apps |
| **Image Generation** | Generates/edits images via GPT Image 1, FLUX.1, Seedream 4.5, Nano Banana. Supports reference images for consistency. | Marketing visuals, mockups, thumbnails, concept art |
| **Video Generation** | 5 videos/month (no audio on Enterprise Pro). | Short demo/explainer clips |
| **Pages** | Turns any research thread into a shareable, public web page with citations. | Publishing research externally, sharing reports |
| **Canvas** | Collaborative document editing within Perplexity. | Iterating on documents, reports, proposals |

---

## 8. SPACES (Collaboration & Organization)

- **Create topic-specific Spaces** for projects, clients, or departments.
- **Upload files** to a Space → they become searchable context for all threads in that Space.
- **Custom instructions** → Set persona, tone, output format per Space.
- **Model selection** → Choose which AI model powers the Space.
- **Invite teammates** → Only org members; shared files and threads.
- **Unlimited collaborators** on Enterprise Pro.

---

## 9. MEMORY

- Perplexity stores user preferences, past experiences, and shared details across sessions.
- Enterprise admins can control memory settings (enable/disable, data retention).
- **Use it for:** Personalized recommendations, recalling past project context, maintaining continuity across sessions.

---

## 10. ENTERPRISE ADMIN & SECURITY

- **SSO / SCIM** — Single sign-on and automated user provisioning
- **SOC 2 Type II** compliant
- **No model training** on your data
- **Admin dashboard** — Usage analytics, seat management, audit logs
- **Data retention controls** — Configurable per organization
- **Permission settings** — Enable/disable connectors, memory, features per org
- **Org description** — Admins set org context to improve answer relevance

---

## 11. QUICK DECISION GUIDE — WHAT TO USE WHEN

| Your Task | Use This |
|---|---|
| Quick fact check | Quick Search or Pro Search |
| Deep competitive analysis | Deep Research |
| Analyze an internal PDF | Upload file → Pro Search (or Org Files source) |
| Search across all company docs | Internal Knowledge Search (Web + Org Files) |
| Build a dashboard or spreadsheet | Labs |
| Create a marketing image | Image Generation |
| Find a person's background | search_people (LinkedIn) |
| Crunch numbers or process data | Code Execution (Python) |
| Visualize data trends | Chart creation (Plotly via code) |
| Collaborate on a client project | Create a Space → upload files → set instructions |
| Publish findings publicly | Pages |
| Get personalized suggestions | Memory-aware search |
| Pull financial/startup data | Crunchbase / FactSet integrations |
| Download files from the web for analysis | bash (curl/wget) + code execution |

---

*Enterprise Pro: $40/seat/month · 500 research queries/day · 50 Labs queries/month · Unlimited Pro searches*
