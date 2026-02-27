---
name: chatgpt-research
description: Access ChatGPT web-only features - Deep Research, Agent Mode, Canvas, GPT-5.2 models
parent-skill: browser-control
requires: Playwright MCP, ChatGPT Plus/Pro subscription
---

# ChatGPT Deep Research Browser Sub-Skill

## Purpose
Access ChatGPT web-only features unavailable via API:
- **Deep Research** (multi-step research with code execution)
- **Agent Mode** (autonomous browsing for UX audits on our live apps)
- **Canvas** (collaborative code editing)
- **GPT-5.2** models before API availability

## When to Use
- Need multi-step autonomous research with web browsing
- Want UX audit of our deployed apps via Agent Mode
- Collaborative code editing in Canvas
- Complement to Perplexity for different perspective

## Workflow

### 1. Auth Check
```
mcp__playwright__browser_navigate url="https://chat.openai.com"
mcp__playwright__browser_snapshot  # Check for logged-in state
```
If not logged in: "Please log in to ChatGPT in the visible browser window"

### 2. Start Deep Research
```
# Navigate to ChatGPT
mcp__playwright__browser_navigate url="https://chat.openai.com"
# Select model/mode (Deep Research)
mcp__playwright__browser_snapshot
mcp__playwright__browser_click ref="<model-selector>"
# Select Deep Research mode
mcp__playwright__browser_click ref="<deep-research-option>"
# Submit query
mcp__playwright__browser_fill_form ref="<prompt-textarea>" value="<research query>"
mcp__playwright__browser_click ref="<submit-button>"
# Wait for completion (5-30 minutes for Deep Research)
# Poll with periodic snapshots
```

### 3. Extract Results
- Wait for "Research complete" indicator
- Snapshot full report
- Extract structured content and sources
- Return to Claude context

## Time Expectations
- Deep Research: 5-30 minutes (varies by complexity)
- Agent Mode: 1-10 minutes per task
- Standard chat: immediate

## Security
- NEVER export ChatGPT session tokens
- NEVER share conversation URLs externally
- User must manually log in via visible browser
