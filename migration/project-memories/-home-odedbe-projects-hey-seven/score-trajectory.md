# Hey Seven Score Trajectory (R52-R81)

## Technical (D1-D10) — DONE
- R52: 67.7 (external cold baseline)
- R53: 84.3 | R54: 85.7 | R55: 88.7 | R56: 90.1 | R57: 92.4
- R68: 92.9 (4-model consensus)
- R70: 92.2 (frozen prompt v2.0)
- R74: 9.34/10 (4-model panel, per-dim)
- R75: 9.63/10 (4-model panel)

## Behavioral (B1-B10) — GAP: 3.2 → 8.0+ target
| Round | Method | Score | Notes |
|-------|--------|-------|-------|
| R71 | Mock | 7.3 | Mock doesn't exercise real LLM |
| R72 | Live+3J | 4.1 | First honest baseline |
| R73 | Live+3J | 5.0 | Post-fixes, real improvement |
| R74 | Mock+4J | 8.15 | INFLATED — back to mock |
| R75 | Live+1J | 5.8 | Single-model — unreliable |
| R81 | R75resp+3J | 3.2 | Cold-start honest score |

## Profiling (P1-P10) — NEVER MEASURED
- 56 scenarios exist in YAML
- No live eval + judge run completed
- All P-score claims in prior sessions were estimates from code inspection

## R81 Per-Dimension Breakdown (3-model consensus)
| Dim | GPT-5.2 | Grok 4 | DeepSeek | Consensus |
|-----|---------|--------|----------|-----------|
| B1 sarcasm | 4.6 | 4.2 | 2.2 | 4.2 |
| B2 implicit | 4.6 | 2.8 | 2.6 | 2.8 |
| B3 engagement | 4.4 | 3.0 | 2.6 | 3.0 |
| B4 agentic | 2.6 | 2.8 | 2.0 | 2.6 |
| B5 emotional | 5.4 | 3.2 | 2.6 | 3.2 |
| Overall | 4.2 | 3.2 | 2.4 | 3.2 |

## Key Insight
R74's 8.15 behavioral used mock LLMs. R81's 3.2 used the same live R75 responses
with fresh judges. The 5-point gap is the mock-vs-real delta.
NEVER trust mock-based behavioral scores.
