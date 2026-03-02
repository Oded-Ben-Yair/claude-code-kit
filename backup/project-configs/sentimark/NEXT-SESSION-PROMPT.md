# SENTIMARK - NEXT SESSION: Comprehensive Evaluation Framework

## Context
Previous: sentimark-session-20260201-08f7a3 (Memory MCP)
Handover: /home/odedbe/projects/sentimark/.claude/handover-20260201-08f7a3.md

Deployed **Grok-first 2-LLM architecture** on Jan 31 (commit `050f31f`):
- grok-4-1-fast-reasoning (80%) + GPT-5.2 (20%)
- Removed Perplexity and Gemini from LLM ensemble
- 10 intelligence sources (added grok_social_pulse + grok_news)
- Kelly criterion sizing, regime detection, auto-rebalancing all wired

## Early Results (107 evaluated at session close — MORE DATA NOW)

| Engine | Evaluated | Accuracy |
|--------|-----------|----------|
| **GROK-FIRST** | 107 | **69.16%** |
| Old Ensemble | 5,870 | 45.67% |

**Caveats at time of measurement:**
- Only 1.7% of predictions evaluated — by next session, should be 1000+
- Crypto at 0% accuracy on 14 predictions — needs investigation
- 87.9% neutral predictions — possible neutral bias inflating numbers
- Only 24h horizon evaluable — 7d due Feb 7, 30d due Mar 2

## RERUN THESE QUERIES FIRST (data will have grown significantly)

```sql
-- Head-to-head (should have 500+ Grok-first by now)
SELECT
  CASE WHEN created_at >= '2026-01-31 06:00:00+00' THEN 'A_GROK_FIRST' ELSE 'B_OLD_ENSEMBLE' END as engine,
  COUNT(*) as evaluated,
  COUNT(DISTINCT symbol) as assets,
  ROUND(AVG(CASE WHEN direction_correct THEN 1.0 ELSE 0.0 END) * 100, 2) as accuracy_pct,
  SUM(CASE WHEN direction = 'bullish' THEN 1 ELSE 0 END) as bullish,
  SUM(CASE WHEN direction = 'bearish' THEN 1 ELSE 0 END) as bearish,
  SUM(CASE WHEN direction = 'neutral' THEN 1 ELSE 0 END) as neutral
FROM prediction_history
WHERE horizon = '24h' AND direction_correct IS NOT NULL
  AND created_at >= NOW() - INTERVAL '4 days'
GROUP BY 1 ORDER BY 1;

-- Category breakdown (Grok-first)
SELECT
  CASE
    WHEN symbol IN ('BTC','ETH','SOL','ADA','DOT','AVAX','LINK','MATIC','UNI','AAVE','XRP','BNB','DOGE','SHIB','LTC','ATOM','NEAR','APT','SUI','ARB','OP','FIL','ICP','HBAR','CRV','PEPE','WIF','INJ','TIA','BONK','FET','RENDER') THEN 'crypto'
    WHEN symbol LIKE '%USD%' OR symbol LIKE '%JPY%' OR symbol LIKE '%GBP%' OR symbol LIKE '%EUR%' OR symbol LIKE '%CHF%' OR symbol LIKE '%AUD%' OR symbol LIKE '%CAD%' OR symbol LIKE '%NZD%' THEN 'forex'
    WHEN symbol IN ('GOLD','SILVER','PLATINUM','PALLADIUM','BRENT','OIL','NATGAS','COPPER','SUGAR','COCOA','COFFEE','COTTON','LUMBER','WHEAT') THEN 'commodities'
    WHEN symbol LIKE '^%' OR symbol IN ('SPX','DJI','NASDAQ','RUT','FTSE','DAX','CAC','STOXX','N225','HSI','KOSPI','ASX','BVSP','SENSEX','VIX','NIFTY','HANG_SENG','SHANGHAI','TSX','IBEX','AEX') THEN 'indices'
    ELSE 'stocks'
  END as category,
  COUNT(*) as evaluated,
  ROUND(AVG(CASE WHEN direction_correct THEN 1.0 ELSE 0.0 END) * 100, 2) as accuracy_pct
FROM prediction_history
WHERE horizon = '24h' AND direction_correct IS NOT NULL
  AND created_at >= '2026-01-31 06:00:00+00'
GROUP BY 1 ORDER BY accuracy_pct DESC;
```

---

## TASK: Plan & Build Comprehensive Evaluation Framework

User wants to "think smarter, wider" — not just rerun accuracy queries. Build an **automated, background-running evaluation system** that covers:

### 7 Evaluation Dimensions

1. **Prediction Accuracy** — direction_correct by horizon (24h/7d/30d), category, symbol, time-of-day
2. **LLM-Level Performance** — Extract individual Grok vs GPT-5.2 accuracy from `weights_snapshot` jsonb column
3. **Confidence Calibration** — Do higher confidence predictions correlate with correctness? Calibration curve analysis
4. **Intelligence Source Quality** — Are the 10 sources producing better signals? Compare `is_fallback` rates, score distributions
5. **Portfolio Performance Impact** — Are 3 portfolios (Conservative/Moderate/Aggressive) performing better? Track NAV, Sharpe, drawdown
6. **Direction Distribution Analysis** — 87.9% neutral. Is conservative prediction better or hiding poor directional ability?
7. **Crypto Investigation** — Why 0% crypto accuracy? Data issue? Grok weakness? Model bias?

### Deliverable
An automated background monitoring system that:
- Runs continuously or on schedule (e.g., every hour)
- Writes results to a report file
- Produces end-of-day comprehensive summary
- Compares Grok-first vs old ensemble on all 7 dimensions
- Highlights anomalies and regressions

### Key Schema for Evaluation

| Column | Table | Purpose |
|--------|-------|---------|
| `direction_correct` | prediction_history | Was direction prediction correct? |
| `weights_snapshot` | prediction_history | jsonb with LLM weights per prediction |
| `confidence` | prediction_history | Model confidence score |
| `consensus_score` | prediction_history | Signal consensus |
| `direction` | prediction_history | bullish/bearish/neutral |
| `actual_direction` | prediction_history | What actually happened |
| `actual_change_pct` | prediction_history | Actual price change |
| `*_is_fallback` | asset_profile | Per-source fallback tracking |
| `*_score` | asset_profile | Intelligence source scores |
| virtual_portfolios | - | Portfolio NAV, positions |

### Architecture Reference

| File | Purpose |
|------|---------|
| `shared/rotation/llm_prediction.py` | LLM ensemble (Grok 80%/GPT 20%) |
| `shared/signals/aggregator.py` | 10-source signal aggregation |
| `shared/portfolios/generator.py` | Portfolio generation |
| `tests/backtest/backtest_v3.py` | Existing backtest harness |
| `function_app.py` | Entry point |

---

## REMAINING BACKLOG (Lower Priority)

| Priority | Task |
|----------|------|
| P2 | Add CRV to MANIFOLD_SEARCH_TERMS in crowd_wisdom.py |
| P2 | Consider per-category LLM weights if accuracy varies by category |
| P3 | Address 7% cold-start prediction failures on rapid requests |
