# Team Context: R101 Paradigm Shift

Created: 2026-03-07T10:00:00Z
Goal: Execute Phase 0 of R101 — investigate root cause of behavioral score plateau (5.5-7.0 for 25 rounds) through hypothesis testing, failure taxonomy, domain research, and gold trace creation.

## Current State
- Branch: main (commit 7ac23be)
- Tests: 3674 (1 pre-existing timing failure)
- Scores: Tech 9.63/10, B-avg 5.9, P-avg 3.8, H-avg 5.28
- 250 eval scenarios, 109 judged, 22.7% timeout rate
- 13-node LangGraph StateGraph, 72 source modules, 0 scaffolded

## Key Files
- Eval results: `tests/evaluation/r100-flash-full-responses.json` (250 scenarios)
- Streaming results: `tests/evaluation/r100-flash-streaming/` (250 individual JSON files)
- Judge scores: `tests/evaluation/streaming-behavioral-judge-scores.json` (109 scored)
- Pro HT results: `tests/evaluation/r99-pro-ht-v2-responses.json` (30 scenarios)
- Judge prompt: `tests/evaluation/batch-judge-prompt.txt`
- Scenarios: `tests/scenarios/` (34 YAML files)
- Source: `src/agent/` (core agent code)
- Knowledge base: `knowledge-base/` (RAG data)

## Experiment Freeze
NO code changes to behavioral logic during Phase 0. The policy engine is LOCKED.
Only the code-cleaner teammate may edit source files, and ONLY the 4 verified bugs.

## Constraints
- All teammates use Opus 4.6 (Rule 13)
- File ownership: no two teammates edit the same file
- No mock data (Rule 1)
- Output goes to files, not parent context (Sub-Agent Output Contract)
