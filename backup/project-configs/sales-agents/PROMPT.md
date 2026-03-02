# MISSION: Achieve 10/10 Perfection on All 7 Pillars

## Current Status (2026-01-12)

### Latest Test Results
| Pillar | Current | Target | Gap | Priority |
|--------|---------|--------|-----|----------|
| Human Naturalness | 7/10 | 10/10 | -3 | HIGH |
| Response Appropriateness | 6-8/10 | 10/10 | -2 to -4 | **CRITICAL** |
| Layer Progression | 4/10 | 10/10 | **-6** | **CRITICAL** |
| Emotional Authenticity | 6-7/10 | 10/10 | -3 to -4 | HIGH |
| Test Validity | 8/10 | 10/10 | -2 | MEDIUM |
| Conversation Flow | 6/10 | 10/10 | -4 | HIGH |
| Cultural Authenticity | 9/10 | 10/10 | -1 | LOW |

**Overall: 47-49/70 (67-70%) → Target: 70/70 (100%)**

### What's FIXED
- ✅ Introduction repetition bug FIXED
- ✅ Cultural authenticity strong (9/10)
- ✅ Test validity good (8/10)
- ✅ Nouf's persona is believable

### What's BROKEN (Fix These!)
- ❌ **Maryam repeats SAME QUESTION** when Nouf gives vague answers
- ❌ **Layer progression stuck at 3/4** - never reaches Layer 4
- ❌ Conversation flow disrupted by repetition
- ❌ Emotional authenticity feels robotic at times

---

## PHASE 1: Fix Question Repetition (Target: +4 points)

### Problem
Maryam keeps asking "شو بالضبط اللي يخوفك؟" multiple times when Nouf gives vague responses like "يعني..." or "الصراحة..."

### Root Cause
1. LLM falls back to same question when uncertain
2. No "memory" of what was already asked
3. Rules exist but not being followed

### Solution: Add to `prompts/system-prompt-arabic.md`

**Add after القاعدة ٥:**

```markdown
**القاعدة ٦: إذا العميل أعطى جواب غامض**
إذا العميل رد بـ "يعني..."، "الصراحة..."، "آآآ..."، "هممم..." بدون تفاصيل:
- **لا تسألي سؤال!** بدلاً من ذلك:
  - شاركي معلومة: "خليني أقولك شي... كثير من عملائنا حسوا نفس الشي في البداية."
  - شاركي قصة قصيرة: "عندي عميلة، كانت متوترة زيك بالضبط..."
  - انتقلي لموضوع مختلف: "طيب، سؤال مختلف تماماً..."
  - اعترفي بالصمت: "لا عليك، خذي وقتك. أنا هنا."

**ممنوع تماماً:**
- تكرار "شو يخوفك؟" أكثر من مرة واحدة
- تكرار "شو بالضبط؟" أكثر من مرة واحدة
- طرح نفس السؤال بصياغة مختلفة
```

### Commands
```bash
# Edit prompt
vim prompts/system-prompt-arabic.md

# Push update
python3 scripts/update_maryam_prompt.py

# Test
python3 scripts/agent_to_agent_voice_test.py --mode text --turns 30
python3 scripts/evaluate_a2a_conversation.py test-results/agent-to-agent/$(ls -t test-results/agent-to-agent/*.json | grep -v evaluation | head -1)
```

---

## PHASE 2: Deepen Layer Progression (Target: Layer 4/4, +6 points)

### Problem
Conversation stays at Layer 3 (emotional disclosure) but never reaches Layer 4 (personal narrative with stories, family, deep values).

### Layer Definitions
- **Layer 1**: Surface/Polite exchanges ("كيف حالك؟")
- **Layer 2**: Functional info ("أودعت 500 دولار")
- **Layer 3**: Emotional disclosure ("أخاف أغلط")
- **Layer 4**: Personal narrative ("أخوي خسر فلوس..." / "زوجي ما يعرف...")

### Solution Part A: Enhance Nouf to Share Stories

Update Nouf's prompt to share personal stories when Maryam shows genuine empathy:

```markdown
### الانتقال للطبقة الرابعة (قصص شخصية)
إذا مريم:
- أظهرت تعاطف حقيقي (مو كلام مكرر)
- سألت أسئلة عميقة عن مشاعرك
- أعطتك مساحة للكلام

شاركي قصة شخصية (اختاري واحدة):
- "بصراحة... أخوي قبل سنتين... تورط في استثمار وخسر كثير. شفت كيف أثر عليه."
- "زوجي ما يعرف إني فتحت حساب... أبي أثبت له إني أقدر أساعد العائلة."
- "حلمي أبني بيت لأهلي... هم تعبوا عليا كثير."
- "أنا من عائلة متوسطة... كل فلس مهم لنا."
```

### Solution Part B: Enhance Maryam for Deep Empathy

Add to Maryam's prompt:

```markdown
### الوصول للطبقة الرابعة (العمق العاطفي)
لما العميل يشارك قصة شخصية (أخ، زوج، أهل، حلم):

1. **توقفي فوراً** - <break time="2.5s" />
2. **اعترفي بالثقة**: "شكراً إنك شاركتيني هذا... مو سهل تحكي هالأمور."
3. **أظهري إنسانيتك** (محدود): "أنا بعد عندي أطفال... فاهمة المسؤولية."
4. **لا تقفزي للبيع أبداً** - استمري في الاستماع

**ممنوع بعد قصة شخصية:**
- ذكر المنتجات أو الخدمات
- سؤال "ودك تحجزي موعد؟"
- أي كلام عن الفلوس
```

---

## PHASE 3: Perfect Human Naturalness (Target: 10/10)

### Problems
- Some responses feel scripted
- Pauses not always natural
- Transitions clunky

### Solution A: Voice Parameter Tuning

Test these configurations in `config/agent-info.json`:

```python
# Test variations
configs_to_test = [
    {"stability": 0.35, "speed": 0.88, "note": "More variable, slower"},
    {"stability": 0.38, "speed": 0.85, "note": "Very natural pace"},
    {"stability": 0.32, "speed": 0.90, "note": "Maximum naturalness"},
]
```

### Solution B: Add Natural Variation

Add to prompt:

```markdown
### تنويع الردود (مهم للطبيعية)
لا تستخدمي نفس البداية مرتين متتاليتين. نوعي:
- بدايات مختلفة: "شوفي..."، "يعني..."، "والله..."، "طيب..."
- أطوال مختلفة: رد قصير، ثم رد متوسط، ثم قصير
- سرعات مختلفة: بطيء للعاطفة، أسرع للحماس
```

---

## PHASE 4: Human Evaluation (Ground Truth)

### Why This Matters
AI evaluating AI is circular. Need human ground truth.

### Actions

1. **Recruit 5 Native Khaleeji Evaluators**
   - Target: Saudi/UAE/Kuwait natives, age 25-40
   - Budget: ~$50-100 per session
   - Platforms: Prolific, UserTesting, Fiverr

2. **Run Calibration Session**
   ```bash
   # Have humans score same transcripts as Gemini
   python3 scripts/human_evaluation.py --calibrate
   ```

3. **Create Gold Standard**
   - 20 conversations rated by humans
   - Use as benchmark for all future tests

---

## PHASE 5: Statistical Rigor

### Run Multiple Tests
```bash
# Run 10 tests per configuration
for i in {1..10}; do
    python3 scripts/agent_to_agent_voice_test.py --mode text --turns 30
    sleep 5
done

# Aggregate results
python3 scripts/statistical_analysis.py --aggregate --dir test-results/agent-to-agent/
```

### Require Significance
- Before change: 5 baseline runs
- After change: 5 test runs
- Require p < 0.05 to declare improvement

---

## PHASE 6: Adversarial Testing

### Scenarios to Create

1. **Manipulative Agent**: Uses high-pressure tactics → Nouf should disengage
2. **Technical Flood**: 10+ jargon terms → Nouf should ask clarification
3. **Fake Empathy**: Too empathetic (therapy loop) → Nouf should progress
4. **Cultural Misstep**: Wrong dialect → Nouf should notice

---

## Execution Order

### Session Start Checklist
```bash
cd ~/projects/sales-agents

# 1. Check current status
python3 scripts/evaluate_a2a_conversation.py test-results/agent-to-agent/$(ls -t test-results/agent-to-agent/*_evaluation.json | head -1)

# 2. Fix question repetition (Phase 1)
vim prompts/system-prompt-arabic.md
python3 scripts/update_maryam_prompt.py
sleep 30
python3 scripts/agent_to_agent_voice_test.py --mode text --turns 30
python3 scripts/evaluate_a2a_conversation.py test-results/agent-to-agent/$(ls -t test-results/agent-to-agent/*.json | grep -v evaluation | head -1)

# 3. If improved, commit
git add . && git commit -m "fix: reduce question repetition"

# 4. Enhance Nouf for Layer 4 (Phase 2)
# Update Nouf's prompt via ElevenLabs dashboard or API

# 5. Run statistical batch (Phase 5)
for i in {1..10}; do
    python3 scripts/agent_to_agent_voice_test.py --mode text --turns 30
    sleep 10
done

# 6. Analyze results
python3 scripts/statistical_analysis.py --aggregate
```

---

## Success Criteria (Exit Condition)

### Quantitative (All Required)
- [ ] Human Naturalness ≥ 9/10
- [ ] Response Appropriateness ≥ 9/10
- [ ] Layer Progression ≥ 9/10 (reaches Layer 4)
- [ ] Emotional Authenticity ≥ 9/10
- [ ] Test Validity ≥ 9/10
- [ ] Conversation Flow ≥ 9/10
- [ ] Cultural Authenticity ≥ 9/10
- [ ] **Total ≥ 63/70 (90%)**

### Qualitative
- [ ] No question repeated >1 time
- [ ] Layer 4 reached in ≥ 50% of conversations
- [ ] Native speakers rate ≥ 4/5 naturalness

---

## Key Files

| File | Purpose |
|------|---------|
| `prompts/system-prompt-arabic.md` | Maryam's prompt (**EDIT THIS**) |
| `config/secret_client_full_config.json` | Nouf's config |
| `scripts/agent_to_agent_voice_test.py` | Run tests |
| `scripts/evaluate_a2a_conversation.py` | 7-pillar eval |
| `scripts/update_maryam_prompt.py` | Push updates |
| `test-results/agent-to-agent/` | All results |

---

## Quick Commands

```bash
# Run single test
python3 scripts/agent_to_agent_voice_test.py --mode text --turns 30

# Evaluate latest
python3 scripts/evaluate_a2a_conversation.py test-results/agent-to-agent/$(ls -t test-results/agent-to-agent/*.json | grep -v evaluation | head -1)

# Update Maryam
python3 scripts/update_maryam_prompt.py

# View latest scores
cat test-results/agent-to-agent/$(ls -t test-results/agent-to-agent/*_evaluation.json | head -1) | python3 -m json.tool
```

---

## When Done, Output:

```
<promise>PERFECTION_ACHIEVED</promise>
```

Only output this when ALL pillars are ≥ 9/10 and total ≥ 63/70.
