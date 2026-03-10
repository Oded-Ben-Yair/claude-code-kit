# Browser Control Windows Setup Script
# Run this ONCE in elevated PowerShell on Windows

Write-Host "=== Browser Control Setup for WSL ===" -ForegroundColor Cyan

# 1. Add firewall rule
Write-Host "`n[1/3] Creating firewall rule for CDP port 9222..." -ForegroundColor Yellow
$existingRule = Get-NetFirewallRule -DisplayName "Edge CDP for WSL" -ErrorAction SilentlyContinue
if ($existingRule) {
    Write-Host "  Firewall rule already exists" -ForegroundColor Green
} else {
    New-NetFirewallRule -DisplayName "Edge CDP for WSL" -Direction Inbound -Protocol TCP -LocalPort 9222 -Action Allow -Profile Private | Out-Null
    Write-Host "  Firewall rule created" -ForegroundColor Green
}

# 2. Add port proxy (CRITICAL - Edge ignores --remote-debugging-address=0.0.0.0)
Write-Host "`n[2/3] Setting up port proxy (required because Edge ignores --remote-debugging-address)..." -ForegroundColor Yellow
$existing = netsh interface portproxy show v4tov4 | Select-String "9222"
if ($existing) {
    Write-Host "  Port proxy already configured" -ForegroundColor Green
} else {
    netsh interface portproxy add v4tov4 listenport=9222 listenaddress=0.0.0.0 connectport=9222 connectaddress=127.0.0.1
    Write-Host "  Port proxy added" -ForegroundColor Green
}

# 3. Create Edge CDP launcher shortcut
Write-Host "`n[3/3] Creating Edge CDP launcher..." -ForegroundColor Yellow
$launcherPath = "$env:USERPROFILE\Desktop\Edge-CDP.bat"
$launcherContent = @"
@echo off
echo Stopping existing Edge processes...
taskkill /F /IM msedge.exe 2>nul
timeout /t 2 /nobreak >nul

echo Starting Edge with CDP on port 9222...
start "" "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --remote-debugging-port=9222 --user-data-dir="%LOCALAPPDATA%\EdgeCDP"

echo Edge CDP started. Keep this window open.
echo.
echo Test from WSL with:
echo   WIN_HOST=$(ip route show ^| grep -i default ^| awk '{print $3}')
echo   curl "http://${WIN_HOST}:9222/json/version"
pause
"@
$launcherContent | Out-File -FilePath $launcherPath -Encoding ASCII
Write-Host "  Created launcher at: $launcherPath" -ForegroundColor Green

Write-Host "`n=== Setup Complete ===" -ForegroundColor Cyan
Write-Host @"

NEXT STEPS:
1. Double-click 'Edge-CDP.bat' on your Desktop to start Edge with CDP
2. Log into any sites you need (HeyGen, Perplexity, etc.)
3. Test from WSL:
   WIN_HOST=`$(ip route show | grep -i default | awk '{print `$3}')
   curl "http://`${WIN_HOST}:9222/json/version"

To remove this setup later:
   netsh interface portproxy delete v4tov4 listenport=9222 listenaddress=0.0.0.0
   Remove-NetFirewallRule -DisplayName "Edge CDP for WSL"
"@ -ForegroundColor White
