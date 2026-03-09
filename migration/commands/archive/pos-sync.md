# /pos-sync - Sync External Sources

Sync tasks from Azure DevOps and other external sources into Personal OS.

## Usage
```
/pos-sync ado           # Sync ADO work items assigned to me
/pos-sync ado --all     # Sync all ADO work items in project
/pos-sync calendar      # Show today's Outlook calendar
/pos-sync market        # Fetch current forex rates (via Perplexity)
```

## Implementation

### For `ado`:
```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import sync_ado_to_pos

result = sync_ado_to_pos()
print(f\"\\nADO Sync Complete:\")
print(f\"  Synced: {result['synced']} new items\")
print(f\"  Skipped: {result['skipped']} (already exists)\")
print(f\"  Total ADO items: {result['total']}\")
"
```

### For `calendar`:
```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import format_calendar_for_briefing

print('\\nToday\\'s Calendar:')
print(format_calendar_for_briefing())
"
```

### For `market`:
Use Perplexity MCP to fetch:
- Query: "Current forex rates EUR/USD, GBP/USD, USD/JPY, XAU/USD with brief market sentiment"
- Format and display the results

## Notes

- ADO sync requires Azure CLI login: `az login`
- Calendar requires Azure AD access: `az login`
- Market data uses Perplexity MCP (Claude will fetch automatically)
