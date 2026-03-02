# Session Handover: sentimark-session-20260211-gonogo3

**Date**: 2026-02-11
**Duration**: ~3 hours (evening evaluation session)
**Health**: 70/100 (Acceptable — 3 uncommitted files)
**Memory MCP Entity**: `sentimark-session-20260211-gonogo3`

---

## Session Summary

Executed GO/NO-GO #3 Evening Evaluation per `docs/EVENING_EVAL_ARCHITECTURE.md` v3.0. Result: **DEFINITIVE NO-GO**. Found 2 critical root causes explaining why the Edge Gate has NEVER worked with real features. Documented 5 ranked golden pieces for the fix session. Ran learning loop, updated 4 success patterns + 4 anti-patterns.

---

## Goals & Achievement

| Goal | Status | % |
|------|--------|---|
| Run GO/NO-GO #3 Evening Evaluation | COMPLETE | 100% |
| Execute learning loop | COMPLETE | 100% |
| Generate end-of-session handover | COMPLETE | 100% |

---

## Technical State

| Item | Value |
|------|-------|
| Branch | `master` |
| Last commit | `338e7ae docs: add EVENING_EVAL_ARCHITECTURE.md v3.0` |
| Uncommitted | 3 files (CLAUDE.md modified, 2 new docs) |
| Push status | NOT PUSHED — uncommitted changes pending |
| Tests | Not run this session (evaluation-only) |
| Build | Last pipeline #10408 succeeded (2026-02-10) |
| Shadow mode | `EDGE_GATE_SHADOW=true` (DO NOT CHANGE) |

### Uncommitted Files
```
M  CLAUDE.md              — Updated with GO/NO-GO #3 results, Prevention Rule #22
?? docs/GOLDEN_PIECES.md  — 5 ranked golden pieces with code fixes
?? docs/GONOGO3_VERDICT.md — Full GO/NO-GO #3 verdict document
```

---

## Key Findings (Root Causes)

### Root Cause #1: V3 Consensus Key Mismatch (CRITICAL)
**Location**: `shared/rotation/asset_rotation.py:975-981`

Production runs `CONSENSUS_VERSION=v3` which produces breakdown dicts with keys `p_up` and `raw_confidence`. The gate feature extractor reads `score` and `confidence` — these keys don't exist in V3, so all LLM features default to 0.0/0.5.

**Impact**: 6 LLM features always at defaults (llm_disagreement=0.0, score_spread=0.0, mean_raw_confidence=0.5, etc.)

### Root Cause #2: Intelligence Scores Not Passed (CRITICAL)
**Location**: `shared/rotation/asset_rotation.py:990-997`

The `pred` dict passed to the gate never contains intelligence scores (technical_score, social_score, etc.). These exist in `asset_profile` but are not threaded through the prediction pipeline.

**Impact**: 6 intelligence features always at 0.5 defaults.

### Combined Impact
- **14/27 features constant** across all predictions
- **43.4% of model importance** lost
- Only **14 distinct probability values** (should be 100+)
- Pocket thresholds completely determine decisions — **model probability is irrelevant**
- **8,475 gate decisions** in entire history have zero real LLM disagreement

---

## Key Documents Created

| File | Purpose |
|------|---------|
| `docs/GONOGO3_VERDICT.md` | Full verdict with decision matrix, root cause analysis, hypothesis results, baselines |
| `docs/GOLDEN_PIECES.md` | 5 ranked golden pieces with exact code fixes, verification SQL, implementation order |
| `docs/EVENING_EVAL_ARCHITECTURE.md` | Evaluation methodology blueprint (committed earlier) |

---

## Key Files for Next Session

| File | What's There | What Needs Changing |
|------|-------------|-------------------|
| `shared/rotation/asset_rotation.py` | Lines 975-981: gate feature extraction | **GP1 Fix A**: Add `p_up`/`raw_confidence` fallbacks |
| `shared/rotation/asset_rotation.py` | Lines 990-997: intelligence scores | **GP1 Fix B**: Thread scores from `asset_profile`/`market_context` |
| `shared/ml/gate_features.py` | Training data loader (CORRECT) | No change needed — training reads real values from DB |
| `shared/rotation/llm_prediction.py` | Lines 784-823: `_features_to_legacy_result()` | Reference: has correct `p_up` fallback pattern |
| `shared/rotation/llm_prediction.py` | Line 1153: `_store_llm_raw_outputs()` | Reference: has correct `p_up` fallback pattern to replicate |
| `shared/ml/pocket_thresholds.py` | Pocket threshold logic | **GP4**: Update to block stocks + commodities |

---

## Golden Pieces (Implementation Plan for Next Session)

### GP1: Fix V3 Key Mismatch + Intelligence Score Passthrough (P0 CRITICAL, 1-2h)

**Fix A** — Add p_up/raw_confidence fallbacks at `asset_rotation.py:975-981`:
```python
normalized_llm_outputs = [
    {
        'llm_name': d.get('llm', d.get('llm_name', '')),
        'score': d.get('score', d.get('p_up', 0.0)),
        'confidence': d.get('confidence', d.get('raw_confidence', 0.5)),
    }
    for d in raw_breakdown
]
```

**Fix B** — Pass intelligence scores at `asset_rotation.py:990-997`:
```python
# Load from asset_profile / market_context (already available in the function scope)
pred['intelligence_scores'] = {
    'technical_score': asset_data.get('technical_score', 0.5),
    'social_score': asset_data.get('social_score', 0.5),
    'geopolitical_score': asset_data.get('geopolitical_score', 0.5),
    'political_score': asset_data.get('political_score', 0.5),
    'financial_score': asset_data.get('financial_score', 0.5),
    'fear_greed_score': asset_data.get('fear_greed_score', 0.5),
}
```

**Verification** (run after deploy):
```sql
SELECT features_snapshot->'features_used'->>'n_llms_responding',
       features_snapshot->'features_used'->>'score_spread',
       features_snapshot->'features_used'->>'llm_disagreement'
FROM gate_monitoring_log
WHERE created_at > NOW() - INTERVAL '1 hour'
ORDER BY created_at DESC LIMIT 5;
-- n_llms_responding should be 3.0 or 4.0 (not 1.0)
-- score_spread should be > 0.1 (not 0.0)
-- llm_disagreement should be > 0.0
```

**Risk**: Model was trained on DB-format scores (`sentiment_score` from `llm_raw_outputs` table). V3 breakdown has `p_up` which may be on a different scale. Verify `sentiment_score` in DB equals `p_up` from V3 breakdown. If they differ, the model may need retraining after the fix.

### GP2: Rule-Based Gate (P0, 2-4h)

**Design**: Create `shared/ml/gate_rules.py`:
```python
def rule_based_gate(category: str, direction: str) -> tuple[str, str]:
    """Simple rule-based gate. Returns (decision, reason)."""
    if category == 'forex':
        return ('TRADE', 'forex_category')  # 54.4% acc (n=1,110)
    if category == 'crypto' and direction == 'bearish':
        return ('TRADE', 'crypto_bearish_rule')  # 64.2% acc (n=137)
    return ('NO_TRADE', f'{category}_{direction}_blocked')
```

**Integration**: Wire into `asset_rotation.py` alongside ML gate. Run both in shadow mode and log both decisions to `gate_monitoring_log` for comparison.

**Evidence**: TRADE accuracy 55.5% at 23% coverage (n=1,247) vs ML gate 45.1% at 8.5% (n=122). Permutation test p<0.0001.

### GP4: Block Stocks + Commodities (P1, 1h)

Update `pocket_thresholds.py` or rule-based gate to always return NO_TRADE for stocks and commodities categories:
- Stocks accuracy: 37.5% (n=1,921) — trading REDUCES accuracy by 2.8pp vs no-gate baseline
- Commodities accuracy: 37.1% (n=561) — trading REDUCES accuracy by 3.2pp vs no-gate baseline

### GP3: Retrain After Key Fix (P1, 4-8h incl wait)

**Prerequisites**: GP1 deployed + 48h of shadow data with real features flowing.

**Process**:
1. Verify `n_llms_responding > 3` in features_snapshot
2. Run `python3 scripts/train_gate_v1.py --min-samples 4000`
3. Run `python3 scripts/evaluation_harness.py`
4. Check distinct probabilities > 50
5. Compare retrained ML gate vs rule-based gate vs hybrid

### GP5: Indices Conditional (P2, 1h)

Needs more per-direction data (200+ per direction) before deciding. Park for now.

---

## Implementation Order (Next Session Plan)

```
Session N (next):
  Step 1: Commit uncommitted files (CLAUDE.md, GOLDEN_PIECES.md, GONOGO3_VERDICT.md)
  Step 2: GP1 Fix A — V3 key mismatch in asset_rotation.py:975-981 (30 min)
  Step 3: GP1 Fix B — Intelligence scores passthrough in asset_rotation.py:990-997 (30 min)
  Step 4: GP2 — Implement rule-based gate in shared/ml/gate_rules.py (1h)
  Step 5: GP2 — Wire rule-based gate into asset_rotation.py alongside ML gate (1h)
  Step 6: GP4 — Update pocket thresholds to block stocks + commodities (30 min)
  Step 7: Run tests (existing 80 gate tests + new tests for rule gate)
  Step 8: Deploy to Azure (pipeline push)
  Step 9: Verify features flowing (SQL check within 1h of deploy)
  Step 10: Document results

Session N+1 (48h later):
  Step 1: Verify real features flowing (n_llms_responding > 3)
  Step 2: GP3 — Retrain model with real features
  Step 3: Run evaluation harness
  Step 4: Compare: ML gate vs rule-based gate vs hybrid

Session N+2 (GO/NO-GO #4):
  Step 1: 48h data with retrained model
  Step 2: Full statistical analysis per EVENING_EVAL_ARCHITECTURE.md
  Step 3: Decision: If stratified lift > 5pp AND TRADE acc > 50% → CONDITIONAL GO
  Step 4: If not → ML gate retirement, keep rule-based
```

---

## Team Composition Suggestion (Next Session)

For GP1+GP2+GP4 implementation, a **2-worker team** is optimal:

| Teammate | Role | Owns | Tasks |
|----------|------|------|-------|
| gate-fixer | Fix asset_rotation.py + pocket_thresholds.py | `shared/rotation/asset_rotation.py`, `shared/ml/pocket_thresholds.py` | GP1 (Fix A + Fix B) + GP4 |
| rule-builder | Create rule-based gate + tests | `shared/ml/gate_rules.py`, `tests/unit/test_gate_rules.py` | GP2 |

No file overlap. Both can work in parallel. Lead verifies after both complete.

---

## Blockers & Risks

| Risk | Mitigation |
|------|-----------|
| `p_up` scale != `sentiment_score` scale | Verify with SQL: compare `llm_raw_outputs.sentiment_score` vs V3 breakdown `p_up` values |
| Model retraining may not improve with real features | Rule-based gate as fallback (already beats ML) |
| Azure consumption plan warm instances persist 12+ hours | Wait 24h before verifying feature fix |
| New features may change pocket threshold behavior | Re-run pocket mining after 48h of real data |

---

## Prevention Rules Active

| # | Rule | Status |
|---|------|--------|
| 21 | Verify gate_schema version between train and serve | Active |
| 22 | After CONSENSUS_VERSION change, verify all downstream consumers | **NEW — added this session** |

---

## Files Modified This Session

| File | Change |
|------|--------|
| `CLAUDE.md` | Updated edge gate status, accuracy timeline, Prevention Rule #22, completed items |
| `docs/GONOGO3_VERDICT.md` | NEW — Full GO/NO-GO #3 verdict |
| `docs/GOLDEN_PIECES.md` | NEW — 5 ranked golden pieces with code fixes |
| `.claude/status.json` | Rewritten with golden pieces, updated next steps |
| `.claude/decisions.log` | Appended 12 entries for GO/NO-GO #3 findings |
| `~/.claude/patterns/success_patterns.json` | Added patterns 046-049 |
| `~/.claude/patterns/failure_patterns.json` | Added anti-patterns 040-043 |

---

## Memory MCP Entities

| Entity | Type | Contents |
|--------|------|----------|
| `sentimark-session-20260211-gonogo3` | SessionSummary | Full session state, findings, patterns |
| `sentimark-decisions` | Decisions | 4 new observations (GO/NO-GO #3, golden pieces, rule gate, Prevention Rule #22) |
| `sentimark-learnings` | Learnings | 7 new observations (4 successes, 3 failures) |

---

## Next Session Prompt (Copy-Paste Ready)

```
/go

I'm continuing the Sentimark Edge Gate fix session. Previous session (sentimark-session-20260211-gonogo3) ran GO/NO-GO #3 which was DEFINITIVE NO-GO.

The root causes are documented in docs/GOLDEN_PIECES.md:
1. V3 consensus key mismatch at asset_rotation.py:975-981 (p_up/raw_confidence vs score/confidence)
2. Intelligence scores not passed at asset_rotation.py:990-997

Priority for this session:
- First: Commit the 3 uncommitted files (CLAUDE.md, GOLDEN_PIECES.md, GONOGO3_VERDICT.md)
- GP1: Fix V3 key mismatch + intelligence score passthrough
- GP2: Implement rule-based gate (forex + crypto-bearish = TRADE)
- GP4: Block stocks + commodities in pocket thresholds
- Deploy all to shadow mode, verify features flowing

Reference docs:
- docs/GOLDEN_PIECES.md (exact code fixes)
- docs/GONOGO3_VERDICT.md (full analysis)
- .claude/handover-20260211-gonogo3.md (this handover)
```

---

*Generated by end-of-session v2, 2026-02-11*
*Session ID: sentimark-session-20260211-gonogo3*
