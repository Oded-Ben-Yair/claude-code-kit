# Browser Control Setup & Architecture

## Architecture (WSL2 + WSLg)

```
+-------------------------------------------------------------+
|                    Claude Code (WSL2)                        |
|                           |                                  |
|                           v                                  |
|               Playwright MCP Server                          |
|                           |                                  |
|                           v                                  |
|    +----------------------------------------------------+   |
|    |  Edge Browser (Linux native via WSLg)              |   |
|    |  - Executable: /opt/microsoft/msedge/microsoft-edge|   |
|    |  - Profile: ~/.config/microsoft-edge-playwright    |   |
|    |  - Display: :0 (WSLg)                              |   |
|    +----------------------------------------------------+   |
+-------------------------------------------------------------+
```

**Key insight**: We use Linux Edge (installed in WSL) with WSLg for display, NOT Windows Edge with CDP. This is simpler and more reliable.

---

## Configuration

The Playwright MCP is configured in `~/.claude/settings.json`:

```json
"playwright": {
  "command": "npx",
  "args": [
    "@playwright/mcp@latest",
    "--browser", "msedge",
    "--executable-path", "/opt/microsoft/msedge/microsoft-edge",
    "--user-data-dir", "/home/odedbe/.config/microsoft-edge-playwright"
  ],
  "env": {
    "PLAYWRIGHT_BROWSERS_PATH": "/home/odedbe/.cache/ms-playwright",
    "DISPLAY": ":0"
  }
}
```

**Critical settings:**
- `--executable-path`: Points to system Edge (bypasses Playwright's bundled Chromium)
- `--user-data-dir`: Persistent profile for login sessions across restarts
- `DISPLAY=:0`: Required for WSLg GUI rendering

---

## Prerequisites

1. **Edge installed in WSL**:
   ```bash
   sudo apt install microsoft-edge-stable
   ```

2. **WSLg working** (automatic on Windows 11 with WSL2):
   ```bash
   ls /mnt/wslg/.X11-unix/  # Should exist
   ```

3. **Claude Code restart** after config changes

---

## Troubleshooting

### "Uses Chromium instead of Edge"

**Cause**: Old MCP config or missing `--executable-path`

**Fix**:
1. Verify settings.json has `--executable-path` pointing to Edge
2. Restart Claude Code (MCP config is read at startup)
3. Verify: run browser_run_code to check userAgent contains "Edg/"

### "No browser window appears"

**Cause**: WSLg display not configured

**Fix**:
1. Check WSLg exists: `ls /mnt/wslg/.X11-unix/`
2. Verify DISPLAY in settings.json env: `"DISPLAY": ":0"`
3. Test manually: `DISPLAY=:0 /opt/microsoft/msedge/microsoft-edge`

### "Sessions not persisted (need to login every time)"

**Cause**: Using temporary or wrong user-data-dir

**Fix**:
1. Ensure `--user-data-dir` points to persistent location
2. Don't use `/tmp` for user data
3. Verify directory exists: `ls ~/.config/microsoft-edge-playwright`

### "Playwright MCP tools not available"

**Cause**: MCP server not started or crashed

**Fix**:
1. Check Claude Code MCP status
2. Restart Claude Code
3. Verify npx can run: `npx @playwright/mcp@latest --help`

---

## Failed Approaches (Historical -- DO NOT REPEAT)

| Approach | Why It Failed |
|----------|---------------|
| `--browser msedge` alone | Falls back to bundled Chromium |
| CDP to Windows Edge | WSL2 network isolation, netsh complexity |
| `--remote-debugging-address=0.0.0.0` | Edge ignores this flag |
| Temporary user-data-dir | Loses sessions between restarts |
| Missing DISPLAY env var | GUI browser can't render in WSL |
| Windows Edge executable path | Cross-OS executable doesn't work |

**Working approach**: Linux Edge + WSLg + persistent user-data-dir
