# Memory

## Hey Seven External Review Sprint (2026-02-24/25)
- 5 rounds of 4-model hostile review (R47-R51), consensus 67→80/100
- Key learnings saved to: `rules/code-quality.md` (5 new anti-patterns), `rules/langgraph-patterns.md` (query_type wiring checklist), `rules/hostile-review-protocol.md` (external review cadence), `checklists/before-bugfix.md` (4 fix validation checks)
- Memory MCP entities: `hey-seven-r47-r51-sprint`, `hey-seven-external-review-protocol`, `hey-seven-restricted-mode-pattern`
- Path to 98/100: re2 ReDoS, DI framework, Hypothesis property tests, Redis pipelining, load testing
- See `reviews/round-48-multimodel/synthesis.md` for deep analysis of blind spots

## Browser Control / Playwright MCP (2026-02-05)
- Claude Code loads MCP configs from **3 locations** (in priority order):
  1. `~/.claude.json` → `mcpServers` section (HIGHEST priority)
  2. `~/.config/claude-code/mcp-config.json`
  3. `~/.claude/settings.json`
- All three must be updated or the highest-priority one wins
- Playwright MCP `--browser msedge` alone does NOT use Edge - it falls back to bundled Chromium
- Playwright MCP `--executable-path` flag is ignored by MCP (Playwright core respects it, MCP doesn't)
- **Working solution**: Launch Edge with `--remote-debugging-port=9222`, then connect Playwright MCP via `--cdp-endpoint`
- Launcher script: `~/.claude/mcp-servers/playwright-cdp/start-edge-mcp.sh`
- User data dir: `~/.config/microsoft-edge-playwright` (persistent sessions)
- WSLg display: `DISPLAY=:0`

## Google Cloud Project — hey-seven (2026-03-06)
- **Project ID**: `hey-seven` | **Project Number**: `180574405300`
- **Developer Knowledge API**: Enabled + MCP access enabled
- **MCP server**: `google-developer-knowledge` in `~/.claude.json` (user scope, HTTP transport)
- **Endpoint**: `https://developerknowledge.googleapis.com/mcp`
- **Auth**: API key via env var `GOOGLE_DEVELOPER_KNOWLEDGE_API_KEY` (in `.bashrc`)
- **Client ID**: `180574405300-6lsom3n6nrt0lh73jpv0ip2ihuh3a79p.apps.googleusercontent.com` (OAuth — for future use if needed)
- **Tools**: `search_documents` (query Google docs), `get_document` (full doc), `batch_get_documents` (up to 20 docs)
- **Coverage**: Android, Chrome, Firebase, Google AI, Google Cloud, TensorFlow, web.dev, Apigee, Fuchsia, Google Home
- **Lazy-loaded**: Yes (HTTP type, available via ToolSearch when needed)