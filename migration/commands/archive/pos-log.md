# /pos-log - Quick Capture Notes and Decisions

Capture notes, decisions, blockers, and ideas for the active project.

## Usage
```
/pos-log "Your note here"
/pos-log --decision "We chose Redis for caching"
/pos-log --blocker "Waiting on API access"
/pos-log --idea "Could automate deployment"
```

## Log Types
- **note** (default) - General observation
- **decision** - Key decision made
- **blocker** - Something blocking progress
- **idea** - Future improvement idea

## Implementation

```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import add_log, get_active_project

content = '''$CONTENT'''
log_type = '''$TYPE''' or 'note'

log_id = add_log(content, log_type=log_type)
project = get_active_project()

icons = {'note': 'NOTE', 'decision': 'DECISION', 'blocker': 'BLOCKER', 'idea': 'IDEA'}
print(f\"[{icons[log_type]}] Logged to {project}: {content[:50]}...\")
"
```

## Why Capture Logs?

1. **Context preservation** - Remember why decisions were made
2. **Session continuity** - Pick up where you left off
3. **Searchable history** - Query past decisions
4. **Handoff documentation** - Others can understand context
