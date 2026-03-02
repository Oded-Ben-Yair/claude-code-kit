# ML Production Rules

On-demand: Load when working with ML models, predictions, training, evaluation, data visualization.

## ML Production Deployment (MANDATORY)

- NEVER use `os.path.exists()` on cloud URIs (`azure://`, `s3://`, `gs://`) — silently returns False. Detect prefix, use SDK.
- ALWAYS normalize dict key names at module boundaries — `'llm'` vs `'llm_name'` caused silent train-serve skew in Smart Gate v1.
- ALWAYS run `code-judge` hostile review on ML code BEFORE merge — caught 2 critical bugs in Smart Gate v1.
- Walk-forward CV params MUST adapt to actual data date range — hardcoded `test_days=7` on 4-day data produces zero folds.
- ML gates MUST fail open (PASS_THROUGH) on any error — never block primary pipeline.
- Shadow mode for 24h minimum before enforcing ML gate decisions in production.
- Freeze feature schema in a separate module — all consumers import from schema, never define features inline.

## Prediction System Evaluation (MANDATORY for <500 samples)

- Use **permutation tests** and **bootstrap confidence intervals** for significance — NOT t-tests
- Standard parametric tests assume normality and are unreliable at small sample sizes

## Multi-Layer Bias Detection (Prediction Systems)

When investigating prediction system bias (e.g., bullish-only, always-neutral):
1. **Check each processing layer independently**: prompt → parser → consensus → abstention → output
2. **Each layer may look reasonable alone** but compound silently (e.g., LLM positivity + parser `>=` default + aggressive k_threshold = 0% bearish)
3. **Trace one input end-to-end** through all layers before concluding root cause
4. **Use asset_profile JOIN** for category lookups instead of hardcoded symbol CASE statements

## Config/Schema Version Change Verification (MANDATORY)

After changing ANY config version, schema version, or dict key format:
1. Grep ALL downstream consumers for the old key names
2. Verify every consumer reads the new format
3. Test with real data end-to-end (unit tests won't catch key mismatches)

Origin: Sentimark V3 — `p_up`/`raw_confidence` vs `score`/`confidence` key mismatch persisted for 8,475 decisions undetected.

## LLM Evaluator Variance (MANDATORY for scored outputs)

- Accept +/-2-5 points between models as **structural noise** — do NOT chase perfect scores
- Require **2+ model consensus** for GO/NO-GO decisions, never single-model
- Ship when score plateau detected (3+ consecutive versions within noise range)
- Gemini vision scores measure TECHNICAL quality, not design originality

Origin: LinkedIn CV — 12 consecutive versions (V44-V55) within noise range. Sentimark — 92/100 Gemini score rejected for lacking originality.

## Data-Aware Visualization Code

When implementing size/importance tiers, category buckets, or visual hierarchy in data visualizations:
- **NEVER** use value-based thresholds when real data may cluster in narrow ranges
- **ALWAYS** use index-based assignment: sort, then assign tier by array position
- **ALWAYS** test with actual API data, not assumed distributions
- Dynamic range normalization: map actual min-max to full visual range (e.g., scores 37-64 → pixels 50-500)

## Feature Snapshot as First ML Diagnostic (MANDATORY)

When an ML gate/model shows unexpected behavior (probability collapse, rubber-stamping, low accuracy), query `features_snapshot` BEFORE any model performance analysis:

1. Query avg/stddev of ALL features over recent window
2. Flag any feature with stddev=0.0 (constant = broken)
3. Flag any feature at known default value (0.0, 0.5, 1.0)
4. Calculate % of model importance from broken features
5. Only THEN analyze model accuracy (features explain most failures)

Origin: Sentimark Feb 2026 — 14 features constant, 43.4% importance lost. Feature snapshot was the fastest diagnostic.

## Simple Rule Baseline Before ML Evaluation (MANDATORY)

Before evaluating ML model performance, compute what a simple rule-based filter achieves. If the rule wins, the ML model adds no value.

1. Analyze accuracy by category x direction (all pocket combinations)
2. Find pockets where TRADE accuracy > baseline
3. Construct rule: TRADE for high-accuracy pockets, NO_TRADE for others
4. Compare: ML accuracy at ML coverage vs rule accuracy at rule coverage

Origin: Sentimark Feb 2026 — forex+crypto-bearish rule achieved 55.5% accuracy at 23% coverage vs ML gate 45.1% at 8.5%. Rule beat ML on BOTH accuracy (+10.4pp) AND coverage (2.7x).

## Global Calibration Harms Low-Accuracy Categories (MANDATORY)

When applying a global calibration factor (e.g., dampening one LLM's bullish bias), check per-category impact:

1. **Run pre/post accuracy by category** — not just overall
2. **Check neutral rate by category** — global dampening pushes ALL categories more neutral
3. **Low-accuracy categories suffer most** — if a category is already 80%+ neutral, pushing to 93%+ neutral while the market is volatile collapses accuracy
4. **Compare actual vs predicted direction** — if market was only 21% actually neutral but system predicted 93% neutral, the calibration is too aggressive for that category
5. **Consider category-specific calibration** — exempt volatile categories or use per-category factors

```sql
-- Diagnostic: pre vs post calibration neutral rate and accuracy by category
WITH pre AS (SELECT ap.category, ... WHERE created_at < deploy_time),
     post AS (SELECT ap.category, ... WHERE created_at > deploy_time)
SELECT category, pre_neutral_pct, post_neutral_pct, pre_accuracy, post_accuracy;
```

Origin: Sentimark Feb 2026 — Grok calibration factor 0.7 pushed commodities to 93.4% neutral (from 79.1%), but market was only 21.4% actually neutral. Accuracy dropped 38.3%→23.2% (-15.1pp). Energy commodities (BRENT, WTI, OIL) worst hit.
