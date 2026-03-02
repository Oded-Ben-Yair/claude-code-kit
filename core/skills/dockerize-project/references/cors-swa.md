# CORS Configuration and SWA Frontend Setup

## Phase 4: CORS Configuration (CRITICAL -- only for cross-origin architecture)

**Skip this phase if frontend proxies API through nginx** (`location /api { proxy_pass ... }`).
That architecture avoids CORS entirely.

### If cross-origin (separate domains):

1. **Identify ALL domains** that will access the backend
2. **Update backend CORS config**:
   ```bash
   grep -rn "CORS\|cors\|origins\|allow_origin" --include="*.py" --include="*.ts" --include="*.json" .
   ```
3. **Add all production domains** + localhost for dev
4. **Add `DASHBOARD_URL` env var** for dynamic CORS
5. **Update frontend API URL** in ALL files:
   ```bash
   grep -rn "API_URL\|API_BASE\|fetch.*http" --include="*.ts" --include="*.tsx" --include="*.js" <frontend-dir>/
   ```
6. **Update CSP headers** if they exist:
   ```bash
   grep -rn "Content-Security-Policy\|connect-src" --include="*.json" --include="*.ts" --include="*.py" .
   ```

**VERIFICATION**: CORS errors only show in browsers, NOT in curl. Use Playwright to test.

---

## Phase 4.5: SWA Frontend Configuration (Standard Architecture)

**This is the STANDARD path.** Skip only if frontend is explicitly Docker-based.

### 4.5.1 Verify staticwebapp.config.json

The SWA config must have:

```json
{
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["*.{css,js,png,jpg,gif,ico,svg,json,woff,woff2}"]
  },
  "globalHeaders": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://<BACKEND_DOMAIN> https://*.sentry.io; font-src 'self' https://fonts.gstatic.com; frame-ancestors 'none'"
  }
}
```

**CRITICAL**: `connect-src` MUST include the backend domain. Without it, all API calls fail silently.

### 4.5.2 Verify Frontend API URL Configuration

```bash
# Find where API URL is configured
grep -rn "NEXT_PUBLIC_API_URL\|API_BASE_URL\|apiUrl\|api-client" --include="*.ts" --include="*.tsx" --include="*.js" <frontend-dir>/

# Verify the default/fallback URL points to backend domain
grep -rn "aeob\|api.*domain\|API_URL" --include="*.ts" --include="*.tsx" <frontend-dir>/lib/
```

### 4.5.3 Build Frontend with Correct API URL

```bash
cd <frontend-dir>
NEXT_PUBLIC_API_URL=https://<BACKEND_DOMAIN> npm run build
# Produces out/ directory (static export)
```

**CRITICAL**: `NEXT_PUBLIC_*` vars are BAKED IN at build time. If you change the backend URL later, you MUST rebuild and redeploy the frontend.

### 4.5.4 Deploy to Azure Static Web Apps

```bash
# Get deployment token
az staticwebapp secrets list --name <SWA_APP_NAME> -g AZAI_group --query "properties.apiKey" -o tsv

# Deploy
npx @azure/static-web-apps-cli deploy ./out --deployment-token <TOKEN> --env production
```

### 4.5.5 Verify SWA Deployment

```bash
# Check headers — CSP must show correct backend domain
curl -sI https://<FRONTEND_DOMAIN> | grep -i "content-security-policy\|last-modified\|etag"

# Verify HTML has correct API URL preconnect
curl -s https://<FRONTEND_DOMAIN> | grep -o 'preconnect.*href="[^"]*"' | head -5

# Check backend is reachable
curl -s https://<BACKEND_DOMAIN>/health
```

### 4.5.6 CORS on Backend Must Include SWA Origins

```python
# api/config.py or equivalent — MUST include:
CORS_ORIGINS = [
    "http://localhost:3000",        # Local dev
    "https://<SWA_DEFAULT_DOMAIN>", # Azure SWA default domain
    "https://<CUSTOM_DOMAIN>",      # Custom domain (if configured)
]
```
