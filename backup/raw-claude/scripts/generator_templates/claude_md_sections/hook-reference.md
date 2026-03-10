| Hook | Event | Enforces |
|------|-------|----------|
| auto-router.py | UserPromptSubmit | Intent detection -> routing suggestions |
| session-start-enhanced.sh | SessionStart | Git context + previous session + project status |
| post-compact-recover.sh | SessionStart (compact) | Re-inject critical state after compaction |
| pre-compact-save.sh | PreCompact | Save critical state before compaction |
| quality-validation.sh | PreToolUse (Bash, Write, Edit) | Security pattern validation |
| pre-tool-file-guard.sh | PreToolUse (Bash, Write, Edit) | Block writes to .env, .pem, .key, cross-project |
| cloud-build-gate.sh | PreToolUse (Bash) | Rule 6: Block premature verification after Cloud Build |
| gcp-adc-check.sh | PreToolUse (Bash) | Verify GCP ADC credentials before gcloud commands |
| dead-code-check.sh | PreToolUse (Bash) | Rule 4: No committing files without import path |
| debug-first.sh | PreToolUse (Bash) | Rule 5: Read logs before rewriting on test failure |
| test-result-tracker.sh | PostToolUse (Bash) | Track test pass/fail, set verification flags |
| post-tool-autoformat.sh | PostToolUse (Edit, Write) | Auto-format on save |
| periodic-commit-check.sh | Stop | Auto-save to GitHub |
| stop-verify.sh | Stop | Rule 2: Must show proof before "done" |
| notification.sh | Notification | Desktop notify-send |
| teammate-idle-verify.sh | TeammateIdle | Agent Teams: verify work before idle (role-aware) |
| task-completed-verify.sh | TaskCompleted | Agent Teams: quality gate on task completion |
| subagent-stop-tracker.sh | SubagentStop | Log subagent duration and metadata to telemetry |
| tool-failure-tracker.sh | PostToolUseFailure | Log tool failures for debugging patterns |
| config-change-audit.sh | ConfigChange | Log settings changes, warn on security-relevant edits |
| worktree-audit.sh | WorktreeCreate | Log worktree creation for audit trail |
| worktree-audit.sh | WorktreeRemove | Log worktree removal for audit trail |
