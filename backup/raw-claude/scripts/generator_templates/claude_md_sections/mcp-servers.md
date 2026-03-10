| MCP | Type | Launcher |
|-----|------|----------|
| memory | Always active | Built-in |
| vertex-ai | Always active | ADC auth (`start-with-adc.sh`) -- Gemini Pro, Claude via Vertex |
| grok | Always active | Env file (`start-with-env.sh`) -- Grok 4 flagship (default) + 4.1 fast models |
| perplexity | Lazy-loaded | Built-in |
| gemini | Lazy-loaded | Built-in |
| context7 | Lazy-loaded | Built-in |
| playwright | Lazy-loaded | Chrome (`start-chrome-mcp.sh`) |
| claude-mermaid | Lazy-loaded | npx (`claude-mermaid`) -- Live-reload Mermaid preview in browser |
