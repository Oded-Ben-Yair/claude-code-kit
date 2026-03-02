# Handover: heygen-scripter-session-20260203-caba99

## Session Identity
- **Session ID**: heygen-scripter-session-20260203-caba99
- **Date**: 2026-02-03
- **Duration**: ~20 minutes
- **Health Score**: 95/100 (Excellent)
- **Memory MCP Entity**: `heygen-scripter-session-20260203-caba99`

## Goals & Achievement
| # | Goal | Status | % |
|---|------|--------|---|
| 1 | Categorize v4.1 HeyGen test feedback (6 issues) | COMPLETE | 100% |
| 2 | Update learning loop: failure + success patterns | COMPLETE | 100% |
| 3 | Upgrade guide v4.1 to v4.2 (25 commandments) | COMPLETE | 100% |
| 4 | Create decisions.log for heygen-scripter | COMPLETE | 100% |

## What Changed This Session

### Guide (v4.1 -> v4.2)
- `HEYGEN_VIDEO_AGENT_GUIDE.md` — now 25 commandments (was 24)
- New **#25**: 2-PASS WORKFLOW mandatory — initial prompt for structure, follow-up for quality
- Updated #2: Avatar 40-50% screen time, 4+ scenes. NEVER say "minimize"
- Updated #8: 50/50 avatar/B-roll (was 60/40)
- Updated #12: Per-scene Arabic enforcement + translation table
- Updated #15: Camera limitation ≠ frequency limitation
- Updated #22: Simple "FAST HIGH-ENERGY" replaces BPM/genre specs
- Updated #23: Voice Mirroring now MANDATORY (was optional)
- Updated #24: Single-sentence boom ending (was 5-step sequence)
- Added full v4.1 test learnings section with 6-row failure table

### Pattern Files
- `~/.claude/patterns/failure_patterns.json` — +6 new (fail-080 to fail-085)
  - HeyGen ignores BPM/genre, Voice Director metaphors, minimize taken literally, boom sequence too complex, asset quality default, English text persists
- `~/.claude/patterns/success_patterns.json` — +5 new (pattern-196 to pattern-200)
  - 2-pass follow-up, avatar 40-50%, per-scene Arabic, simple boom, quality benchmark

### New Files
- `.claude/decisions.log` — 10 decisions from v4.0→v4.2

### Decisions Made
1. **2-PASS WORKFLOW** mandatory — HeyGen agent ignores complex specs in initial prompt
2. **Avatar 40-50%** screen time (was 25% max) — agent took "minimize" literally
3. **Voice Mirroring MANDATORY** for hook+CTA — Voice Director metaphors ignored
4. **Simple music demand** "FAST HIGH-ENERGY" replaces detailed BPM/genre specs
5. **Single-sentence boom ending** replaces multi-step sequence
6. **Per-scene Arabic enforcement** + translation table for English defaults
7. **Audio replacement workflow** as fallback if music still slow after 2-pass

## Key Learnings (from v4.1 test feedback)
| Problem | Root Cause | Fix in v4.2 |
|---------|-----------|-------------|
| Slow rhythm | Agent ignores BPM/genre specs | Simple "FAST HIGH-ENERGY" + ban list |
| Monotone voice | Voice Director metaphors ignored | Voice Mirroring mandatory + follow-up correction |
| Avatar barely visible | "MINIMIZE to 2 appearances" taken literally | 40-50% screen time, 4+ scenes, never say minimize |
| No boom ending | Multi-step sequence too complex | Single sentence demand |
| Low-quality assets | Generic keywords produce generic output | Reference quality benchmark (Sora-level) + negative prompt |
| English text persists | Single global instruction insufficient | Per-scene enforcement + translation table |

**Meta-learning**: HeyGen Video Agent treats complex specs as suggestions and defaults to safe/generic. The 2-pass workflow is the fundamental fix.

## Technical State
- **Git**: NOT a git repo (no version control)
- **Tests**: N/A (prompt engineering project)
- **Build**: N/A

## File Map
```
heygen-scripter/
  HEYGEN_VIDEO_AGENT_GUIDE.md          # v4.2, 25 commandments, 2-pass workflow
  videos.pdf                            # Source: 72 video scripts
  .claude/
    decisions.log                       # NEW - 10 decisions
    handover-20260203-969ea2.md         # Previous session handover
    handover-20260203-caba99.md         # THIS handover
  prompts/
    video-01-why-invest-v2.txt          # v4.1 template (TESTED - needs v4.2 rewrite)
    video-01-why-invest.md              # OLD - v1 era
    video-02-what-is-cfd-v3.txt         # v4.1 template (TESTED - needs v4.2 rewrite)
    video-02-what-is-cfd-v2.txt         # OLD - v4.0 era
    video-02-what-is-cfd.md             # OLD
    video-02-what-is-cfd.txt            # OLD
    video-03-dividend-stocks-v2.txt     # v4.0 era
    video-03-dividend-stocks.md         # OLD
    video-03-dividend-stocks.txt        # OLD
    video-04-buy-bitcoin.md             # v4.0 (original feedback source)
    video-04-buy-bitcoin.txt            # v4.0
```

## Blockers & Risks
- **None active**
- Risk: Even with 2-pass workflow, music may still be slow — audio replacement workflow needed as Plan B
- Risk: Voice Mirroring requires user to record reference audio clips

## Next Steps

### P0: Write v4.2 Prompts
Rewrite Video #1 and Video #2 prompts using v4.2 template:
1. Initial prompt: structure + script + avatar in 4+ scenes (40-50% screen time)
2. Follow-up correction prompt: 6 FIX items (music, voice, avatar, ending, assets, Arabic)
3. Test both passes in HeyGen

### P1: Audio Replacement Fallback
If music is STILL slow after 2-pass:
1. Research audio replacement workflow (strip HeyGen music, overlay custom track)
2. Source royalty-free trap/future bass tracks at 150+ BPM
3. Build ffmpeg pipeline for audio swap

### P2: Scale to Remaining Videos
Apply v4.2 template to videos 3-72 from PDF

### P3: Future
- Consider git init for version control
- Build prompt template generator (automate PDF -> v4.2 prompt)

---

## Next Session Prompt (copy-paste ready)

```
Continuing heygen-scripter project. Previous session: heygen-scripter-session-20260203-caba99

CONTEXT: We upgraded the HeyGen Video Agent Guide from v4.1 to v4.2 (25 commandments). Key discovery: HeyGen agent ignores complex specs — requires 2-PASS WORKFLOW (initial prompt for structure, follow-up correction for quality). Updated avatar to 40-50% screen time (was 25% — agent took "minimize" literally). Voice Mirroring now mandatory. Simple music demands beat detailed BPM specs.

STATUS: Guide v4.2 complete. Pattern files updated. Need to rewrite Video #1 and #2 prompts on v4.2 template.

Read handover: /home/odedbe/projects/heygen-scripter/.claude/handover-20260203-caba99.md
Read guide: /home/odedbe/projects/heygen-scripter/HEYGEN_VIDEO_AGENT_GUIDE.md

TASK: Write v4.2 prompts for Video #1 and #2 (initial prompt + follow-up correction prompt pair)
```
