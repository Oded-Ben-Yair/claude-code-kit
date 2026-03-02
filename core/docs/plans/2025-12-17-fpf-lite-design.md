# FPF-Lite Integration Design

**Date**: 2025-12-17
**Status**: Approved
**Decision**: Implement Lightweight ADI with ambient integration

---

## Overview

Integrate quint-code's First Principles Framework (FPF) into Claude Code as ambient, automatic reasoning without slash commands.

## Design Decisions

### 1. Integration Approach: Modified A (Embedded in CLAUDE.md)
- Lightweight ADI principles embedded in global `~/.claude/CLAUDE.md`
- Deep mode via natural language triggers (not slash commands)
- No separate skill file (multi-model-debate covers complex cases)

### 2. Complexity Detection Triggers
Automatic hypothesis generation when:
- Task touches 3+ files
- Involves architectural patterns (API design, database schema, auth flows)
- User asks "how should I...", "what's the best way...", "design", "architect"
- **Semantic triggers**: auth, secrets, crypto, infra (Bicep/Terraform), database schema, PII

### 3. WLNK (Weakest Link) Application
- **Silent mode**: Apply internally without showing unless:
  - User asks "how confident are you?"
  - Confidence drops below 0.5
  - Sources significantly contradict
- **Calculation**: confidence = min(evidence levels), never average
- **Congruence penalties**: Same tech/scale = 0, different = -0.15 to -0.35

### 4. Memory Persistence
- **Auto-persist** architectural decisions to Memory MCP
- **Namespaced**: `[project-name]` prefix on all decisions
- **Content**: decision, alternatives rejected, WLNK score, context
- **No cross-project bleed**: Query by project namespace

### 5. Trigger Modes

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Normal** | Complexity detected | Generate 2-3 hypotheses, recommend one |
| **Production** | Working in QC Analyzer or Compliance Exam | Auto-deep, require confirmation |
| **Quick Fix** | "just fix it", "#urgent", "quick fix" | Skip hypothesis generation |
| **Deep** | "let's think deeper", "full FPF analysis" | Full ADI cycle with explicit evidence |

### 6. Precedence Rules
- Per-project CLAUDE.md **extends** global rules
- Per-project **cannot disable** core safety or FPF reasoning
- Conflicts: per-project wins for domain-specific rules, global wins for safety

### 7. Transformer Mandate (Human Decides)
- Always present choice: "Which approach do you prefer?" before implementing
- Never auto-proceed with recommendation for architectural decisions
- Quick fixes exempt (user already chose speed over deliberation)

### 8. Falsifiability (from quint-code)
Each hypothesis includes: "This approach fails if..."

---

## Implementation Files

1. **~/.claude/CLAUDE.md** - Add FPF-Lite section
2. **~/.claude/rules/fpf-reasoning.md** - Detailed rules (keeps CLAUDE.md clean)
3. **Per-project CLAUDE.md** - Add production mode where applicable

---

## Out of Scope

- Full .fpf directory structure (using Memory MCP instead)
- Design Rationale Records as files (stored in Memory)
- Validity windows / decision TTLs (nice-to-have for future)
