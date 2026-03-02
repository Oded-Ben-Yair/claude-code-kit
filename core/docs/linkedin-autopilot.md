# LinkedIn Autopilot Rules (On-Demand Module)

Load when: autopilot, automate LinkedIn, browser control LinkedIn, autonomous LinkedIn

## Autopilot Stage Model

### Stage 1: Human-Guided (Sessions 1-5)
- AI suggests post/comment/interaction
- User reviews, edits, provides explicit feedback
- Feedback tracked in `tracking/interaction-feedback.md`
- NO autonomous actions

### Stage 2: Semi-Autonomous (Sessions 5-15)
- AI drafts content following learned preferences
- User approves with minimal edits (target: <20% edit rate)
- AI manages reactions/likes autonomously (lowest risk)
- Comments still require approval
- Applications still require approval

### Stage 3: Full Autopilot (Sessions 15+)
- AI manages daily LinkedIn operations via `/browser-control`
- User reviews weekly summary with metrics
- Emergency stop on any suspicious activity

## Hard Guardrails (NEVER Override)

1. **NEVER** comment on political, religious, or controversial posts
2. **NEVER** engage with content outside AI/tech/career topics
3. **NEVER** send DMs to more than 5 new people per day
4. **NEVER** post more than 1x per day
5. **NEVER** apply to jobs not matching criteria in `research/companies/priority-targets.md`
6. **NEVER** use external automation tools (Chrome extensions, third-party bots)
7. **NEVER** send connection requests without personalization
8. **NEVER** comment with fewer than 15 words
9. **NEVER** use engagement bait patterns ("Comment YES", "Tag 5 people")
10. **NEVER** exceed safe operating limits (15 requests/day, 10 comments/day, 5 DMs/day)

## Session Loop Structure (4-Hour Engagement Session)

Repeat this cycle every ~30 minutes:
1. **5 min**: Scroll feed + check notifications + strategic likes
2. **5 min**: Identify comment opportunities (target company, niche, off-topic mix). Check if anything useful to share/repost.
3. **10 min**: Draft interactions, run each through 12-gate system (MANDATORY, no exceptions)
4. **5 min**: Publish approved interactions via Playwright
5. **5 min**: Verify posted correctly, check for immediate replies

Between cycles: monitor active Post for new comments (reply within golden window).

At session end: final notification sweep (MANDATORY), update tracking files.

Origin: LinkedIn Day 17 (2026-02-23) — user requested structured 4-hour session workflow.

## Behavioral Randomization (Anti-Detection)

### Timing Randomization
- Add random delay: normal distribution, mean=baseline, std=20% of mean
- Never act at exact clock intervals (e.g., every 30 minutes)
- Vary session start times by ±15 minutes daily
- Skip random days (1-2 per month) to break patterns

### Interaction Randomization
- Vary engagement types daily (don't always like + comment in same pattern)
- Mix activity order: some days comment-first, some days browse-first
- Random dwell time before actions (5-30 seconds of reading)
- Don't visit profiles in alphabetical or list order

### Content Randomization
- Never post same structure twice in a row
- Rotate: technical/career/insight/contrarian/behind-scenes
- Vary hashtag sets (rotate through 3-4 predetermined sets)
- Alternate post lengths (sometimes short 800 chars, sometimes long 1500)

### Language & Topic Diversification (Added 2026-02-14, Day 4 Audit)
- **Minimum 1 Hebrew comment per session** — 23 English in a row = bot signal
- **Minimum 1 off-topic comment per session** — all AI/LLM = optimized engagement bot
- **Track niche vs influencer per comment** — enforce 80/20 split
- Running 100% English + 100% AI-topic is a detection pattern even if each comment passes 8-gate individually
- The BATCH pattern matters as much as individual comment quality

## Safe Automation Boundaries

### SAFE to Automate
- Scheduled post publishing (pre-approved content)
- Profile analytics extraction
- Personal feed reading/research
- Job listing monitoring and alerts
- Draft content generation (for human review)

### MANUAL ONLY (Never Automate)
- Sending messages/DMs
- Connection requests
- Comments on posts
- Job applications
- Endorsements
- Any interaction visible to other users

## Emergency Protocols

### If LinkedIn Shows Warning/Restriction
1. **FULL STOP** — cease ALL activity immediately
2. Do NOT attempt to continue or work around
3. Wait 48-72 hours minimum
4. Resume with manual-only activity for 2-3 weeks
5. Notify user immediately

### If Shadow Restriction Suspected
Signs: impressions suddenly drop >50%, connection requests pending indefinitely, profile views declining
1. Stop all automated activity
2. Switch to manual engagement only
3. Post high-quality content 2x/week for 2 weeks
4. Monitor metrics weekly
5. If no recovery in 4 weeks, contact LinkedIn support

### If Account Compromised
1. Change password immediately
2. Revoke all app permissions
3. Enable 2FA
4. Check active sessions
5. Report to LinkedIn

## Weekly Metrics Dashboard

Track every week:
| Metric | Target | Actual | Trend |
|--------|--------|--------|-------|
| Profile views | >50/week | — | — |
| Post impressions (avg) | >500/post | — | — |
| Engagement rate | >4% | — | — |
| SSI score | >60 | — | — |
| Connection acceptance rate | >40% | — | — |
| InMail response rate | >15% | — | — |
| Applications sent | 2-4/week | — | — |
| Interviews scheduled | Track | — | — |
| Recruiter InMails received | Track | — | — |

## Escalation Rules

| Situation | Action |
|-----------|--------|
| SSI drops below 50 | Increase engagement, check profile completeness |
| Acceptance rate below 30% | Stop requests, review personalization, withdraw old invites |
| 0 profile views in a week | Check for shadow restriction, post high-quality content |
| LinkedIn warning received | FULL STOP, manual only for 3 weeks |
| Negative feedback on AI content | Revert to Stage 1 (human-guided), retrain preferences |
| Recruiter InMail received | Respond within 24 hours, use DM templates |

## Browser Control Integration

When using `/browser-control` for LinkedIn:
- Use residential IP only (never VPN/data center)
- Use persistent browser profile (same cookies, history)
- Simulate human reading time (5-30 sec per page)
- Use Bezier curve mouse movements, not direct clicks
- Never run LinkedIn manually during automated session
- Limit automated sessions to 30 minutes max
- Minimum 4-hour gap between automated sessions

## Autonomous Loop Architecture (Day 12 Proven Pattern)

### Cycle Structure (20-minute cycles)
1. Navigate to LinkedIn feed
2. Scan top 3-5 posts (file snapshot for token management)
3. Engage: comment OR like (budget-dependent)
4. Check notifications for replies/DMs
5. Log all actions to interaction-feedback.md
6. Random delay (60-180 sec between actions)

### Budget Management
- Comments: 10/day hard cap, front-load in first 4 cycles
- Likes: Unlimited but max 3 per cycle (anti-detection)
- Thread replies: Free — don't count against comment budget
- DMs: Budget separately, 1 per cycle max

### Token Management
- LinkedIn pages exceed 500K characters — NEVER pass raw snapshots to context
- Use `browser_snapshot filename=` to save to file
- Use Grep/Read on saved files for targeted extraction

### Feed Navigation: Always Use Direct Post URLs

**NEVER use `?highlightedUpdateUrn=` parameter** on the feed URL to view a specific post. SDUI does not reliably render the highlighted post (only sidebar loads). Always navigate to the direct post detail URL: `https://www.linkedin.com/feed/update/urn:li:activity:{id}`

Origin: LinkedIn Day 17 afternoon (2026-02-23) — `highlightedUpdateUrn` parameter failed to render Hila Milshtein post. Direct URL worked immediately.

### SDUI Search Results: Snapshot Fails, Use evaluate()

LinkedIn search results pages render via SDUI. Playwright `browser_snapshot` returns empty listitems. `a[href*="feed/update"]` selectors also return empty because links are SDUI-rendered.

**Workaround**: Use `page.evaluate()` with `document.querySelectorAll('.feed-shared-update-v2, .update-components-text, [data-urn]')` and extract `.innerText`. This returns post text content even when snapshots show nothing. For post links, try `[data-urn]` attribute extraction instead of `a[href]`.

**Company page URLs**: Never guess LinkedIn company page slugs. Use search to find company pages. Gong, Monday.com, Check Point slugs are not predictable patterns.

Origin: LinkedIn Day 21 (2026-02-25) — 3 wrong Gong URL guesses, search snapshot returned empty listitems, but `page.evaluate()` with `.innerText` extracted 4 Gong posts successfully.

### DOM Injection for LinkedIn Editors

**CRITICAL: Use post detail pages or search results for commenting, NOT feed editors.** SDUI feed editors are NOT inside `[data-view-name="feed-full-update"]` containers. `.closest()` returns null. Editor-to-post matching by DOM proximity FAILS. This led to a comment posting on the wrong post (Feb 22, 2026).

**Feed inline comments (SDUI)**: TipTap/ProseMirror editors (class: `tiptap ProseMirror`)
- Content injection: `editorElement.editor.chain().clearContent().insertContent(text).run()` (TipTap API)
- DO NOT use innerHTML — it bypasses TipTap's internal model
- Submit button ONLY renders after real keyboard input. After API injection: focus editor, type space, press backspace. Then search for "Comment" button within `editorRect.bottom + 200px`, viewport only, `width > 50`
- Click submit via JS `.click()` inside `page.evaluate()` — NOT `page.mouse.click()` (SDUI coordinates mismatch)
- Ctrl+Enter does NOT work for comment submission on LinkedIn

**Search results / Post detail page comments**: Quill.js editors (class: `ql-editor`)
- Content injection: `editor.focus()` + `document.execCommand('insertText', false, text)` — works for all languages including Hebrew/Arabic
- Submit button renders immediately with content (no keyboard trigger needed)
- Find by text "Comment" or "Reply" within editorRect range, `width > 30`
- PREFERRED for commenting: single editor, unambiguous post context

**DM compose overlay**: contenteditable DIV (`.msg-form__contenteditable[role="textbox"]`)
- Activation trick: `fill('')` -> `click()` -> type Space -> `Ctrl+A` -> `Backspace` -> `keyboard.insertText(text)`
- `pressSequentially` times out on >200 chars — use DOM injection or keyboard.insertText instead

**Comment delete flow**: Three-dot menu (`page.mouse.click` at exact coords) -> `[role="menuitem"]` with text "Delete" (JS `.click()`) -> Confirmation "Delete" button (JS `.click()`)

**Editor detection**: Check class names first — `tiptap`/`ProseMirror` = TipTap pattern, `ql-editor` = Quill pattern

**NEVER use `page.waitForTimeout()` for waits longer than 60 seconds.** Long waits crash the Playwright MCP connection. Return to user and let them trigger the next check.

Origin: LinkedIn Feb 22, 2026 — TipTap API discovery, submit button trigger, wrong-post comment, 15-min wait crash.

### LinkedIn Selector Reference (Feb 24, 2026 — Post Detail Pages)

| Element | Selector | Notes |
|---------|----------|-------|
| Comment submit | `.comments-comment-box__submit-button--cr` | Use `.last()` for reply boxes |
| Like button (unliked) | `button[aria-label="Reaction button state: no reaction"]` | NOT `aria-label*="React Like"` |
| DM send | `button:has-text("Send")` | Enter key adds newline, doesn't send |
| Connection accept | Iterate `button` by index + text content | `aria-label` selectors timeout on responsive layout |
| Company pages | Use search (`/search/results/content/?keywords=`) | Never guess company URL slugs |
| Reply textbox (thread) | `getByRole('textbox', {name: /Text editor/}).last()` | `.last()` gets deepest reply box |

Origin: LinkedIn Day 19 (2026-02-24) — multiple selector failures during engagement session. All resolved by trial.

### Diminishing Returns Warning
- For extended loops (6+ hours): 80% of value comes in first 2 hours
- After comment budget exhausts, switch to observe-only (likes + metric checks)
- Consider 3-hour loops with afternoon spot-checks instead of continuous 6-hour loops

## File References
- Operations rules: `~/.claude/rules/linkedin-operations.md`
- Feedback tracker: `tracking/interaction-feedback.md`
- Target companies: `research/companies/priority-targets.md`
- Templates: `content/templates/`
- Weekly playbook: `content/weekly-playbook.md`
