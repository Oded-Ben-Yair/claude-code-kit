# Session Handover: heygen-scripter-session-20260203-f2bff9

**Date**: 2026-02-03 | **Duration**: ~75 min | **Health**: 90/100 (Excellent)
**Memory MCP Entity**: `heygen-scripter-session-20260203-f2bff9`

---

## What Was Done

- Analyzed Video #3 (Dividend Stocks) v1 output — extracted 7 issues from 47-second video
- Updated HEYGEN_VIDEO_AGENT_GUIDE.md: commandments 15-17, Video #3 postmortem, avatar section rewritten, template avatar/edits upgraded
- Wrote follow-up prompt v2 (`video-03-dividend-stocks-v2.txt`)
- Processed v2 results: "much better" — all fixes worked EXCEPT avatar (still identical every scene)
- **CRITICAL DISCOVERY**: Avatar camera variation = HeyGen platform limitation (tested generic terms + explicit crop descriptions — both ignored)
- Updated guide to document limitation with mitigation strategies
- Learning loop: +6 success patterns (181-186), +4 failure patterns (070-073), Memory MCP updated
- Video #3 WRAPPED

## Key Discovery This Session

**HeyGen Video Agent does NOT support different camera angles/framing for avatar scenes.** All avatar scenes render as identical medium shot regardless of prompt. This is a platform constraint, not a prompt problem.

**Mitigation**: Minimize avatar to 2-3 appearances, keep each under 2s, vary on-screen overlays/text per scene instead of camera. For true variation: post-production editing.

## Current Template Status (v3.0 FINAL)

17 commandments. Validated on 3 videos (9 total iterations). Works well for:
- Asset quality (AI-generated cinematic video for concept scenes)
- Transitions (smooth morphs, no hard cuts)
- Duration control (silence trimming, explicit cap)
- Color consistency (brand-only, even for negative concepts)
- CTA (5-6s dedicated scene, clean ending)

Does NOT work for:
- Avatar camera variation (platform limitation)

## Files Modified

| File | Changes |
|------|---------|
| `HEYGEN_VIDEO_AGENT_GUIDE.md` | Commandments 15-17, Video #3 postmortem (v1+v2), avatar section rewritten as limitation, template avatar/edits sections updated |
| `prompts/video-03-dividend-stocks-v2.txt` | Follow-up prompt with 5 PROBLEM fixes |
| `prompts/video-03-dividend-stocks.md` | v1 results table, v2 status |
| `.claude/status.json` | Summary, patterns, toAvoid updated |

## Videos Completed

| # | Topic | Iterations | Status |
|---|-------|-----------|--------|
| 1 | Why Invest | 5 (v1-v4) | Done |
| 2 | CFD Trading | 2 (v1-v2) | Done |
| 3 | Dividend Stocks | 2 (v1-v2) | Done (wrapped) |
| 4-72 | Remaining | 0 | Not started |

## P0 Next Step

Pick Video #4 from `videos.pdf` and build prompt using the final v3.0 template. Apply all 17 commandments. Avatar = 2-3 scenes max with varied overlays.

## P1 Next Step

If Video #4 needs 0-1 iterations, consider batch-producing remaining 69 videos.

---

## Next Session Prompt (copy-paste ready)

```
Continuing heygen-scripter project. We're building HeyGen Video Agent prompts for 72 Arabic finance videos.

CONTEXT:
- Guide v3.0 FINAL at HEYGEN_VIDEO_AGENT_GUIDE.md (17 commandments)
- 3 videos done (9 total iterations): Video #1 (Why Invest), #2 (CFD), #3 (Dividends)
- Template validated: works for asset quality, transitions, duration, color, CTA
- CRITICAL: Avatar camera variation = PLATFORM LIMITATION (documented in guide section 6)
- Avatar mitigation: minimize to 2-3 appearances, vary overlays not camera, keep under 2s each

Memory MCP entity: heygen-scripter-session-20260203-f2bff9
Status file: .claude/status.json

TASK: Pick Video #4 from videos.pdf. Build the prompt using v3.0 template with all 17 commandments applied. Save as prompts/video-04-[topic].txt (copy-paste ready) and prompts/video-04-[topic].md (internal reference).
```
