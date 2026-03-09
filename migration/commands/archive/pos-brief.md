# /pos-brief - Daily Briefing (Phase 2)

Generate a comprehensive daily briefing with calendar, tasks, health checks, and context.

## Usage
```
/pos-brief           # Standard briefing (calendar + tasks + health)
/pos-brief --full    # Full briefing (adds ADO work items + market data)
```

## What It Shows

### Standard Briefing
1. **Outlook Calendar** - Today's meetings from MS365
2. **Priority Tasks** - Overdue, due today, high priority
3. **Production Health** - Status of QC Analyzer, Compliance Exam, Sentimark
4. **Tasks by Project** - Distribution of open tasks
5. **Recent Notes** - Last decisions/notes from active project

### Full Briefing (--full)
All of the above, plus:
6. **Azure DevOps Work Items** - Active items assigned to you
7. **Market Data** - Forex rates via Perplexity

## Implementation

### Standard:
```bash
python3 ~/projects/personal-os/scripts/daily-brief.py
```

### Full:
```bash
python3 ~/projects/personal-os/scripts/daily-brief.py --full
```

After running the script, Claude should:
1. If --full was used, fetch live market data using Perplexity MCP
2. Query: "Current EUR/USD, GBP/USD, USD/JPY, XAU/USD rates. One sentence on forex sentiment."
3. Append to the output

## Requirements

- **Calendar**: Azure CLI logged in (`az login`)
- **ADO**: Azure CLI with DevOps access
- **Market**: Perplexity MCP (Claude fetches automatically)

## Related Commands

- `/pos-sync ado` - Sync ADO work items to POS tasks
- `/pos-sync calendar` - Show just calendar
- `/pos-task list` - Full task list
