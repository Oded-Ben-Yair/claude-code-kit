| Task | Tool |
|------|------|
| Deep thinking | `g3-deep-think` (returns reasoning chain + token counts) |
| Complex reasoning | `g3-think` / `gemini-query` (thinking=high) |
| Math/algorithms | `vertex_reason` |
| Chat (Vertex AI) | `vertex_chat` (Gemini Pro, Claude via Vertex) |
| Code review (Vertex AI) | `vertex_code_review` |
| Research (API) | `perplexity_research` (Sonar -- fast, most queries) |
| Research (Browser) | `/browser-control` -> perplexity-pro (Deep Research, model selection, source filters, Spaces, Labs) |
| Quick code | `grok_code` (via code-worker) |
| Chat (Grok) | `grok_chat` (default: grok-4, flagship) |
| X/Twitter | `grok_social_pulse` |
| Memory/persist | `mcp__memory__*` (cross-session decisions) |
| Major decisions | `/multi-model-debate` |
| Design | `/frontend` skill |
| Library docs | `context7` |
| Resume session | `/go` skill (context recovery + auto-plan) |
| Fix pipeline | `/fix-pipeline` skill |
| Destructive recovery | `/scrap-reimplement` skill |
| Risk assessment | `/pre-mortem` skill |
| Anti-perfectionism | `/ship-it` skill |
| Code simplification | `code-simplifier` agent (plugin, after major changes) |
| Browser automation | `/browser-control` skill |
| Browser deep research | `/browser-control` -> perplexity-pro / chatgpt-research sub-skills |
| Gemini advanced | Built-in `gemini` MCP (url-context, image edit, search, video, deep-research) |
| Diagrams (complex) | D2 CLI + ELK layout (`~/.local/bin/d2 --layout=elk`) |
| Diagrams (simple) | Beautiful Mermaid (`node ~/.claude/scripts/render-mermaid.js`) |
| Diagrams (skill) | `/create-diagram` skill (auto-routes D2 vs Mermaid) |
| Team deployment | `/team-deploy` skill |
| Compliance audit | `/gcp-compliance` skill (audit, validate) |
| Skill standards audit | `skill-audit.sh` |
| Cloud Run management | `gcloud` CLI |
