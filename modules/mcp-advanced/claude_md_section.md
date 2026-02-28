## MCP Advanced: Specialist Agents

### Specialist Agents

| Agent | Role | Triggers |
|-------|------|----------|
| gemini-specialist | Vision, docs, images, reasoning | PDF, image, screenshot, video |
| research-specialist | Web research, academic, SEC filings | research, investigate, find out |
| realtime-specialist | Social media, X/Twitter monitoring | trending, social, tweet |
| reasoning-specialist | Math, algorithms, brainstorm, decisions | prove, theorem, brainstorm |

### MCP Server Reference

| Task | MCP Server | Key Tools |
|------|------------|-----------|
| Vision & docs | Gemini | gemini-analyze-image, gemini-analyze-document, gemini-query |
| Research | Perplexity | perplexity_search, perplexity_research, perplexity_reason |
| Social & content | Grok | grok_social_pulse, grok_x_search, grok_brand_content |
| Library docs | Context7 | resolve-library-id, get-library-docs |

### On-Demand Docs

| Trigger | Doc File |
|---------|----------|
| SSE, streaming, FastAPI, middleware | `fastapi-streaming.md` |
