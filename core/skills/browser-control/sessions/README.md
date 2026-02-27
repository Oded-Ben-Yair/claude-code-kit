# Browser Session Management

## How Sessions Work

Browser sessions persist via Edge's `--user-data-dir` parameter. The profile directory (`~/.config/microsoft-edge-playwright`) stores:
- Cookies and login tokens
- Local storage data
- IndexedDB databases
- Cached credentials

This means once you log in to a service, the session persists across Claude Code restarts.

## Checking Auth State

Before any authenticated operation, verify the session is active:

```
mcp__playwright__browser_navigate url="https://<service-url>"
mcp__playwright__browser_snapshot  # Look for logged-in indicators
```

**Logged-in indicators by service:**

| Service | Logged In | Not Logged In |
|---------|-----------|---------------|
| Perplexity | User avatar, "Pro" badge | "Sign In" button |
| ChatGPT | Chat input visible, model selector | Login/signup page |
| LinkedIn | Feed content, profile icon | "Join now" / "Sign in" |
| HeyGen | Dashboard, project list | Landing page with "Get Started" |
| Google AI Studio | API key visible, model list | Google sign-in prompt |

## First-Time Login Flow

1. Navigate to the service URL via Playwright
2. The Edge window appears via WSLg on the user's display
3. Inform user: "Please log in to [service] in the visible browser window"
4. Wait for user confirmation
5. Verify login: `mcp__playwright__browser_snapshot` and check for logged-in indicators
6. Session is now stored in the persistent profile

## Session Expiry

Sessions expire based on the service's token lifetime:

| Service | Typical Session Duration |
|---------|--------------------------|
| Perplexity | ~30 days |
| ChatGPT | ~14 days |
| LinkedIn | ~90 days |
| Google | ~30 days |
| HeyGen | ~7 days |

When a session expires, repeat the first-time login flow.

## Profile Directory

```
~/.config/microsoft-edge-playwright/
  Default/
    Cookies          # Encrypted session cookies
    Local Storage/   # Service-specific data
    IndexedDB/       # Complex client-side data
```

**NEVER:**
- Delete the profile directory (destroys all sessions)
- Copy the profile directory (security risk)
- Share profile contents (contains auth tokens)

## Multiple Profiles

If needed for separate contexts (e.g., different LinkedIn accounts), create additional profiles:

```json
"--user-data-dir", "$HOME/.config/microsoft-edge-playwright-alt"
```

This requires modifying `settings.json` and restarting Claude Code. Only one profile can be active per session.

## Troubleshooting

### Session lost after WSL restart
Edge profile should survive WSL restarts. If sessions are lost:
1. Check profile dir exists: `ls ~/.config/microsoft-edge-playwright/Default/Cookies`
2. If missing, the profile was corrupted — re-login required

### "Profile in use" error
Another Edge instance is using the profile. Close all Edge windows or kill the process:
```bash
pkill -f microsoft-edge
```
Wait 5 seconds, then retry.
