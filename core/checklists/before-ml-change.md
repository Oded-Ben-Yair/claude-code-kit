# Before ML Change Checklist

Surface when: modifying ML models, predictions, training, evaluation, ML gates.

## Feature Schema

- [ ] Freeze feature schema in a separate module (all consumers import from schema)
- [ ] After changing any config/schema version: grep ALL downstream consumers for old key names
- [ ] Verify every consumer reads the new format
- [ ] Test with real data end-to-end (unit tests won't catch key mismatches)

## First Diagnostic: Feature Snapshot

- [ ] Query avg/stddev of ALL features over recent window
- [ ] Flag features with stddev=0.0 (constant = broken)
- [ ] Flag features at known default values (0.0, 0.5, 1.0)
- [ ] Calculate % of model importance from broken features

## Evaluation

- [ ] Compute simple rule baseline BEFORE evaluating ML model
- [ ] Use permutation tests and bootstrap CIs for significance (NOT t-tests) when <500 samples
- [ ] Accept +/-2-5 points between models as structural noise
- [ ] Require 2+ model consensus for GO/NO-GO decisions

## Production Deployment

- [ ] ML gates MUST fail open (PASS_THROUGH) on any error
- [ ] Shadow mode for 24h minimum before enforcing gate decisions
- [ ] Normalize dict key names at module boundaries
- [ ] NEVER use `os.path.exists()` on cloud URIs — use SDK
- [ ] Run code-judge hostile review on ML code BEFORE merge

## Calibration / Threshold Changes

- [ ] Run pre/post accuracy BY CATEGORY (not just overall)
- [ ] Check neutral rate by category — global dampening pushes ALL categories more neutral
- [ ] Compare actual vs predicted direction distribution per category
- [ ] Identify categories where calibration makes things WORSE (low-accuracy + high-neutral)
- [ ] Consider category-specific exemptions if one category is harmed

## Bias Detection

- [ ] Check each processing layer independently (prompt → parser → consensus → output)
- [ ] Trace one input end-to-end through all layers
- [ ] Each layer may look reasonable alone but compound silently

## References

- `rules/ml-production.md`: All ML rules
