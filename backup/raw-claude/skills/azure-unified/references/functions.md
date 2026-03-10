# Azure Functions Deployment & Troubleshooting

## Deployment

### Azure Functions (Python)
```bash
# Deploy from project root
func azure functionapp publish <app-name>

# Deploy with zip
az functionapp deployment source config-zip -g AZAI_group -n <app-name> --src ./deploy.zip

# Check status
az functionapp show -g AZAI_group -n <app-name>

# List functions
az functionapp function list -g AZAI_group -n <app-name>

# View settings
az functionapp config appsettings list -g AZAI_group -n <app-name>
```

### Deployment Scripts (per project)
Each project should have:
- `deploy-all.sh` - Full deployment
- `deploy-frontend.sh` - Frontend only
- `deploy-backend.sh` - Backend only

---

## Logs & Troubleshooting

### Streaming Logs
```bash
az webapp log tail -g AZAI_group -n <app-name>
```

### Application Insights Queries
```bash
# Recent errors
az monitor app-insights query --app <insights-name> \
  --analytics-query "exceptions | where timestamp > ago(1h) | order by timestamp desc | take 20"

# Performance issues
az monitor app-insights query --app <insights-name> \
  --analytics-query "requests | where duration > 1000 | summarize count() by name"
```

### Kusto Queries (Application Insights)

**Recent Errors:**
```kusto
exceptions
| where timestamp > ago(1h)
| order by timestamp desc
| project timestamp, type, outerMessage, innermostMessage
| take 20
```

**Performance Issues:**
```kusto
requests
| where timestamp > ago(1h)
| where duration > 1000
| summarize count(), avg(duration) by name
| order by avg_duration desc
```

**Trace Logs:**
```kusto
traces
| where timestamp > ago(30m)
| where severityLevel >= 2
| order by timestamp desc
| take 100
```

### Troubleshooting Checklist

| Issue | Likely Cause | Solution |
|-------|--------------|----------|
| 500 Internal Server Error | Unhandled exception | Check Application Insights |
| 404 Not Found | Route mismatch | Verify function.json bindings |
| Connection timeout | Firewall/networking | Whitelist Function App IPs |
| Cold start delays | Consumption plan | Use Premium plan or warmup |
