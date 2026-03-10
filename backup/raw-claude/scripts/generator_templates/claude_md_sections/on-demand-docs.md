| Trigger | Action |
|---------|--------|
| screenshot, UI, visual, design | Read `~/.claude/docs/visual-validation.md` before any frontend/visual work |
| voice agent, ElevenLabs, TTS | Read `~/.claude/docs/voice-agent-tuning.md` before voice agent work |
| workbook, strategy, playbook | Read `~/.claude/docs/deliverable-quality.md` before strategic deliverables |
| LinkedIn, post, comment, engage | Read `~/.claude/docs/linkedin-operations.md` before LinkedIn work |
| autopilot, automate LinkedIn | Read `~/.claude/docs/linkedin-autopilot.md` before LinkedIn automation |
| review round, hostile review, architecture review | Read `~/.claude/docs/iterative-review-protocol.md` before review work |
| diagram, flowchart, architecture, visualization | Use `/create-diagram` skill. D2+ELK for 15+ nodes, Beautiful Mermaid for simple. See `~/.claude/rules/diagramming.md` |
| screenshot + MCP vision analysis | Resize to 200px wide JPEG q50 (<5K base64) before passing to gemini-analyze-image or grok_vision. Full-res screenshots silently fail. |
| deep research, academic papers, SEC filings, model selection, Spaces, Labs | Escalate from API to `/browser-control` -> perplexity-pro sub-skill. See decision guide in sub-skill. |
| compliance, naming convention, gcp audit, resource rename | Use `/gcp-compliance` skill. Config: `~/.claude/configs/gcp-compliance-rules.json` |

### On-Demand Domain Rules (loaded by trigger words)
| Trigger | Rule File |
|---------|-----------|
| cloud run, cloud function, cloud build | `~/.claude/docs/cloud-run.md` |
| ML, prediction, model, training, evaluation | `~/.claude/docs/ml-production.md` |
| pipeline, transcription, processing, audio | `~/.claude/docs/pipeline-safety.md` |
| SSE, streaming, FastAPI, middleware | `~/.claude/docs/fastapi-streaming.md` |

### Action Checklists (surfaced by auto-router hook)
| Trigger | Checklist |
|---------|-----------|
| deploy, push to prod, pipeline | `~/.claude/checklists/before-deploy.md` |
| refactor, restructure, delete files | `~/.claude/checklists/before-refactor.md` |
| new file creation | `~/.claude/checklists/before-new-file.md` |
| pipeline, transcription, processing | `~/.claude/checklists/before-pipeline-change.md` |
| ML, model, prediction, training | `~/.claude/checklists/before-ml-change.md` |
| fix, bug, error, broken | `~/.claude/checklists/before-bugfix.md` |
