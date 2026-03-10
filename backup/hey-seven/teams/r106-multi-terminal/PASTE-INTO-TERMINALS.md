# Copy-Paste Prompts for Each Terminal

## HOW TO USE
1. Open 3 new terminal windows, each in /home/odedbe/projects/hey-seven
2. Run `claude` in each
3. Paste the corresponding prompt below
4. All 3 can start simultaneously — no dependencies between T2/T3/T4 initially
5. When each finishes, they will update .claude/teams/r106-multi-terminal/status.md
6. Ping T1 (this session) when all are done for merge validation

## IMPORTANT: Do NOT use plan mode. Paste these directly.

---

## Terminal 2 — Paste This:

```
Read .claude/teams/r106-multi-terminal/T2-prompt.md and execute ALL steps. You are T2 — the integration dev for R106. Your job: add the LangGraph tool-call loop to src/agent/agents/_base.py. STRICT file ownership — only touch files listed as T2 in the status.md. Write tests first (test_tool_call_loop.py), then implement the integration. Run full test suite when done. Update status.md when complete.
```

---

## Terminal 3 — Paste This:

```
Read .claude/teams/r106-multi-terminal/T3-prompt.md and execute ALL steps. You are T3 — eval runner + judge panel upgrade for R106. Phase 1: Run P9 re-eval IMMEDIATELY (the R105 handoff bug fix is committed, we need fresh scores). Phase 2: Upgrade judge panel from single GPT-5.2 to 3-model consensus: GPT-5.4 + Grok 4 + DeepSeek Speciale. STRICT file ownership — only touch evaluation files listed as T3 in status.md. Update status.md when complete.
```

---

## Terminal 4 — Paste This:

```
Read .claude/teams/r106-multi-terminal/T4-prompt.md and execute ALL steps. You are T4 — fine-tune data prep + B8 scenarios for R106. Task 1: Research Gemini fine-tuning API via Perplexity MCP. Task 2: Create scripts/export_gold_traces.py to extract top-scored conversations. Task 3: Write 10 B8 cultural sensitivity scenarios. STRICT file ownership — only touch files listed as T4 in status.md. Update status.md when complete.
```
