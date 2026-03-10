1. NO mock/fake/placeholder data — show real errors or "NOT CONNECTED"
2. NO claiming "done" without proof — tests, screenshots, real API responses (Hook: stop-verify)
3. NO SQL against assumed schema — query information_schema first (Hook: schema-verify)
4. NO committing files without import path from entry point (Hook: dead-code-check)
5. NO bypassing debug — if test fails, read logs before rewriting (Hook: debug-first)
6. NO verifying before pipeline completes (Hook: cloud-build-gate)
7. NO accessing another project's database — check pwd first
8. NO pushing outside org repository — GitHub only
9. NO hardcoded credentials — Secret Manager/env vars only
10. NO destructive queries without WHERE clause
11. Understand before changing — read status.json, search patterns, map dependencies
12. Generate options; human decides — present 2-3 approaches for architectural choices
13. ALL subagents AND teammates MUST use Opus 4.6. NEVER use "haiku" or "sonnet" in Task tool calls — the system default is OVERRIDDEN. Every Task tool invocation must include `"model": "opus"` explicitly. NEVER use subagent_type "Explore" — it is hardcoded to haiku at the platform level. Use "general-purpose" instead. When creating Agent Teams, specify: "Use Opus for each teammate."
