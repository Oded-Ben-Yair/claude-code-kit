# T4: Fine-Tune Data Prep + B8 Cultural Sensitivity Scenarios

## Context
You are Terminal 4 in a 4-terminal parallel implementation of R106. Your job is fully independent — no blockers from other terminals. You're preparing the foundation for Gemini fine-tuning and filling a scenario gap.

**Read `.claude/teams/r106-multi-terminal/status.md` for file ownership rules. You ONLY modify files assigned to T4.**

## Your Files (EXCLUSIVE)
- `scripts/export_gold_traces.py` — CREATE
- `data/training/` — CREATE (directory + JSONL files)
- `tests/scenarios/cultural_sensitivity.yaml` — MODIFY (add more scenarios if it exists, or CREATE)

## DO NOT TOUCH (owned by other terminals)
- Anything in `src/` (T1 and T2)
- `tests/test_*.py` (T1 and T2)
- `tests/evaluation/*.py` (T3)

## Task 1: Research Gemini Fine-Tuning API

Use Perplexity MCP to research:
```
perplexity_research: "Google Gemini fine-tuning API 2026 — supported models, JSONL format, pricing, context window, how to fine-tune gemini-2.0-flash or gemini-3-flash, required dataset size, training parameters"
```

Key questions to answer:
1. Can we fine-tune Gemini 3 Flash (preview)? If not, which Gemini model supports tuning?
2. What JSONL format does Gemini tuning require? (messages format vs completion format)
3. Minimum dataset size? (Google usually requires 10-500 examples)
4. Cost per 1000 training examples?
5. How long does training take?
6. What's the API endpoint for starting a tuning job?

Write findings to `.claude/teams/r106-multi-terminal/t4-gemini-tuning-research.md`.

## Task 2: Export Gold Traces to Training JSONL

Create `scripts/export_gold_traces.py` that:

1. Reads eval result files from `tests/evaluation/results/` and `tests/evaluation/`:
   - `r104-ht-pro-responses.json`
   - `r105-ht-pro-responses.json`
   - `r105-prof-pro-responses.json`
   - Any `v2-results/` directory JSON files
   - Any `r106-p9-reeval-streaming/` files (if T3 has produced them)

2. For each scenario result, check if it has judge scores. If judge scores exist AND the scenario scored > 7.0 on B-avg or H-avg, include it.

3. Export format — adapt based on research findings, but start with this structure:
```jsonl
{"messages": [{"role": "system", "content": "<system prompt>"}, {"role": "user", "content": "<turn 1>"}, {"role": "assistant", "content": "<agent response 1>"}, {"role": "user", "content": "<turn 2>"}, {"role": "assistant", "content": "<agent response 2>"}]}
```

4. Also export gold traces from `~/.claude/teams/r101-paradigm-shift/gold-traces.md` (manually crafted exemplar conversations scored 9.2/10).

5. Output to:
   - `data/training/gold-traces-r106.jsonl` — high-scored eval conversations
   - `data/training/gold-traces-manual.jsonl` — manually crafted conversations
   - `data/training/README.md` — metadata (count, source, format, date)

### Script structure:
```python
#!/usr/bin/env python3
"""Export gold traces for Gemini fine-tuning.

Reads eval results, filters top-scored conversations (judge score > 7.0),
and exports as JSONL for Gemini tuning API.

Usage:
    python scripts/export_gold_traces.py --min-score 7.0 --output data/training/
"""

import argparse
import json
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent

def load_eval_results(results_dir: Path) -> list[dict]:
    ...

def filter_high_scored(results: list[dict], min_score: float) -> list[dict]:
    ...

def export_to_jsonl(conversations: list[dict], output_path: Path) -> int:
    ...

def load_manual_gold_traces(traces_path: Path) -> list[dict]:
    ...
```

6. Run the script and report:
   - Total conversations exported
   - Score distribution of exported conversations
   - Any format issues

## Task 3: Write B8 Cultural Sensitivity Scenarios

Check if `tests/scenarios/cultural_sensitivity.yaml` already exists. If it does, read it and add more scenarios. If not, create it.

Write 10 scenarios testing B8 (Cultural Sensitivity). Each scenario should have 3-5 turns.

Scenario types:
1. **International guest** — speaks English as second language, asks about Lunar New Year celebrations
2. **Religious dietary needs** — kosher/halal dining options, handled with respect not awkwardness
3. **Accessibility needs** — wheelchair access, hearing assistance, visual impairments
4. **LGBTQ+ couple** — anniversary celebration, test for inclusive language
5. **Elderly guest** — slower communication pace, technology assistance needed
6. **Indigenous cultural event** — Mohegan Sun is tribal — test knowledge of Mohegan heritage
7. **Hispanic guest** — switches between English and Spanish mid-conversation
8. **Asian high-roller** — cultural norms around luck, numbers, gift-giving
9. **Veterans/military** — military discount inquiry, Memorial Day events
10. **Family with special needs child** — activity recommendations, quiet spaces

YAML format (match existing scenario files):
```yaml
scenarios:
  - id: "cultural-01"
    name: "International Guest — Lunar New Year"
    category: "cultural_sensitivity"
    behavioral_dimension: "B8_cultural"
    expected_behavioral_quality: "Agent shows cultural awareness and knowledge of Lunar New Year celebrations at the property"
    turns:
      - role: "user"
        content: "Hi, my family and I are visiting from Shanghai for the Lunar New Year celebration. We heard Mohegan Sun has special events?"
      - role: "user"
        content: "We need a restaurant that serves authentic Chinese food — not Americanized. And my grandmother doesn't speak English."
      - role: "user"
        content: "Also, the number 8 is very lucky for us. Can we get a room on the 8th floor?"
```

After writing, validate the YAML parses correctly:
```bash
python3 -c "import yaml; data = yaml.safe_load(open('tests/scenarios/cultural_sensitivity.yaml')); print(f'Loaded {len(data[\"scenarios\"])} scenarios')"
```

## Task 4: Write Completion Status

Update `.claude/teams/r106-multi-terminal/status.md` — change T4 status to COMPLETED with:
- Research findings summary (1-3 lines)
- Gold trace count exported
- B8 scenario count
- Any issues encountered

Also write detailed findings to `.claude/teams/r106-multi-terminal/t4-research.md`.

## Success Criteria
- [ ] Gemini tuning API research documented with actionable findings
- [ ] `scripts/export_gold_traces.py` created and runs without errors
- [ ] `data/training/` directory with JSONL files + README
- [ ] 10 B8 cultural sensitivity scenarios in valid YAML
- [ ] Completion status written to status.md
- [ ] No changes to files outside T4 ownership
