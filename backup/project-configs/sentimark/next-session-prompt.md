# Next Session Prompt: Sentimark Comprehensive Frontend Audit

Copy and paste this prompt to start the next session:

---

## PROMPT START

I need a **comprehensive frontend audit** of the Sentimark v2 application. The backend was just recovered (all APIs working), but the frontend has many incomplete areas that need to be documented before we can decide what to fix, keep, change, or remove.

**Previous Session**: `sentimark-session-20260119-7556`
**Handover File**: `.claude/handover-20260119-frontend-audit.md`

### Your Task

**Phase 1: Full Page Inventory** (Use Playwright + Gemini Vision for EVERY page)

Test and screenshot these pages:
1. `/v2` - Homepage
2. `/v2/assets` - Assets list (ALL TABS: All, Crypto, Stocks, Commodities, Indices, Forex)
3. `/v2/assets/BTC` - Bitcoin detail page (test "Pro Analyze" if exists)
4. `/v2/assets/NVDA` - Stock detail page
5. `/v2/assets/GOLD` - Commodity detail page
6. `/v2/portfolios` - Portfolios page (full UX review)
7. `/v2/pricing` - Pricing page
8. `/v2/docs` - Documentation
9. `/v2/login` and `/v2/signup` - Auth flows

For EACH page document:
- Does it load?
- Does it show real data?
- Any broken elements?
- Any placeholder content?
- Any 404 console errors?

**Phase 2: Feature Audit**

Test these specific features:
1. **AI Chatbot** - Click the chat button, try a conversation
2. **Search** - Search for "Bitcoin", "NVDA", etc.
3. **Watchlist** - Try adding/removing assets
4. **"Pro Analyze"** - What is this? Does it work? Should it be removed?
5. **Signals display** - Are they clear? What do they mean?
6. **Category filters** - Do all tabs work on assets page?

**Phase 3: Create Decision Matrix**

Create a document at `.claude/sentimark-feature-audit.md` with:

| Feature/Page | Status | Issue | Recommendation |
|--------------|--------|-------|----------------|
| Homepage | Working/Broken/Partial | Description | Keep/Fix/Remove |
| ... | ... | ... | ... |

Categories for Recommendation:
- **Keep**: Working well, no changes needed
- **Polish**: Working but needs UX improvement
- **Fix**: Broken, needs repair
- **Remove**: Not working, remove entirely
- **Defer**: Move to future version

**Phase 4: Prioritization**

After the audit, create a prioritized list:
1. P0 (Critical) - Things that must be fixed before showing to users
2. P1 (Important) - Things that should be fixed soon
3. P2 (Nice-to-have) - Polish items
4. Remove - Things to delete

### Key User Concerns to Address

1. "Pro Analyze" - should be fixed or removed
2. AI Chatbot - needs verification
3. Portfolios page - needs full QA
4. "Signals" section - "not clear and shown"
5. General feeling - "feels half work"

### Output Expected

1. Screenshots of every page (saved to `.playwright-mcp/`)
2. `.claude/sentimark-feature-audit.md` - Complete feature matrix
3. `.claude/sentimark-priority-list.md` - Prioritized fix list
4. Recommendations for brainstorming session

**DO NOT skip any page or feature. This is a COMPREHENSIVE audit.**

---

## PROMPT END
