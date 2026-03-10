# Hey Seven Round History (R97-R108)

Moved from MEMORY.md to keep it under 200 lines.

## R108 Changes (2026-03-09) — Eval with Tools + Config Fix
- **CRITICAL BUG**: `get_casino_config()` fell back to DEFAULT_CONFIG in local dev, ignoring CASINO_PROFILES. Tools NEVER bound.
- **Fix**: Fallback chain now Firestore → CASINO_PROFILES → DEFAULT_CONFIG
- **R108 eval** (5 scenarios, Flash + tools): 54% tool execution rate, 0% errors, 27% fallback
- **Tool calls by agent**: host(6), entertainment(6), comp(2)
- **Export script expanded**: +R98/R99 sources, +R108 streaming dir
- **Gold traces fixed**: CCD language in all 4, removed "loaded"
- **No-mock ground rule**: added to CLAUDE.md

## R107 Changes (2026-03-09) — Authority Model + Tool Activation
See MEMORY.md "R107 Changes" section (kept in main file as most recent)

## R105 Changes (2026-03-09) — Prompt Ceiling Confirmation
- 7 structural fixes (+1734/-152, 17 files)
- H9 comp: +0.35 (2.00→2.35). P9 handoff: dead code bug → -0.20
- CRITICAL: Handoff prompt injected AFTER llm.ainvoke() → moved BEFORE
- All 7 prompt-level changes ±0.3 → PROMPT CEILING CONFIRMED

## R103 Changes (2026-03-08) — Structural Fixes
- P8 fix (+1.0): whisper_planner stale field names
- H9/P9 code wired but Flash ignores → Pro needed

## R102 Changes (2026-03-07) — Relationship-First Rewrite
- Identity: "Casino host building a relationship" not "knowledgeable concierge"
- B-avg +0.72, P-avg +0.80 from identity rewrite alone
- Three Jobs Every Turn pattern

## R101 Changes (2026-03-07) — Root Cause Investigation
- Failure taxonomy: 62 scenarios, 32% timeout, 11% canned
- Process shift: hypothesis-first, not fix-code-first

## R97-R99 Summary (2026-03-05/06)
- R97: Architecture audit (13 reports, 8 production-ready)
- R98: 4 Phase 2 behavior tools, 119 tests
- R99: FORCE_PRO_MODEL, eval improvements, Pro H-avg 5.28

## R85-R100 Summary
See memory/r101-phase0-findings.md
