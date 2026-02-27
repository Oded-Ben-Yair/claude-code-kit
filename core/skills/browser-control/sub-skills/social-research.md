---
name: social-research
description: Multi-platform social intelligence - Meta Ad Library (free), Reddit, TikTok Creative Center
parent-skill: browser-control
requires: Playwright MCP
---

# Social Research Browser Sub-Skill

## Purpose
Multi-platform social intelligence beyond X/Twitter (which is covered by Grok MCP).

## Platforms

### Meta Ad Library (NO AUTH REQUIRED - FREE)
Best for: Competitor ad creative analysis, spend patterns, A/B test insights

```
mcp__playwright__browser_navigate url="https://www.facebook.com/ads/library"
mcp__playwright__browser_snapshot
# Search for advertiser
mcp__playwright__browser_fill_form ref="<search-input>" value="<brand name>"
mcp__playwright__browser_click ref="<search-button>"
mcp__playwright__browser_snapshot  # Extract ad data
```

**Data available:**
- Active ads and their creative
- Ad spend ranges
- Target demographics (some)
- Ad duration (how long running)
- Geographic targeting

### Reddit (Auth preferred, browser fallback)
Best for: Product sentiment, market research, competitor complaints

```
mcp__playwright__browser_navigate url="https://reddit.com/search/?q=<query>&sort=new"
mcp__playwright__browser_snapshot  # Extract posts and sentiment
```

**RULES:**
- READ-ONLY: no posting, voting, or commenting
- Respect rate limits
- Focus on public subreddits

### TikTok Creative Center (Auth for full access)
Best for: Trending content patterns, regional trends, creative inspiration

```
mcp__playwright__browser_navigate url="https://ads.tiktok.com/business/creativecenter/inspiration/topads/pc/en"
mcp__playwright__browser_snapshot  # Trending ads
```

## When to Use
- Competitor ad analysis --> Meta Ad Library
- Product/brand sentiment --> Reddit
- Content trend analysis --> TikTok Creative Center
- Multi-platform brand monitoring --> combine all three

## Security
- Meta Ad Library: no auth needed, free to browse
- Reddit: prefer logged-out browsing for anonymity
- TikTok: read-only, no account interactions
- NEVER post, comment, or interact on any platform
