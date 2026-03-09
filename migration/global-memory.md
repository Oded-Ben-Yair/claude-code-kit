# Claude Code Memory

## Browser Control (WSL + Windows Edge)

**Critical lesson (2026-02-05):** Edge ignores `--remote-debugging-address=0.0.0.0`. Must use `netsh portproxy` on Windows to bridge WSL to Edge CDP.

### Working Setup
1. Windows Admin: `netsh interface portproxy add v4tov4 listenport=9222 listenaddress=0.0.0.0 connectport=9222 connectaddress=127.0.0.1`
2. Firewall: Allow TCP 9222
3. Launch Edge: `--remote-debugging-port=9222 --user-data-dir=C:\Temp\EdgeCDP`
4. Verify: `curl http://$(ip route show | grep default | awk '{print $3}'):9222/json/version`

### Never Repeat
- `--remote-debugging-address=0.0.0.0` on Edge (ignored)
- Playwright MCP without `--cdp-endpoint` (launches Chromium)
- Default `--browser` flag (uses Chromium not Edge)

See: `~/.claude/mcp-servers/playwright-cdp/` for scripts
