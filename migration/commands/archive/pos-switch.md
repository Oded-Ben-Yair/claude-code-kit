# /pos-switch - Project Context Switch

Switch to a different project context, loading all relevant state.

## Usage
```
/pos-switch <project-slug>
/pos-switch list
```

## Available Projects
- qc-call-analyzer (PRODUCTION)
- compliance-exam (PRODUCTION)
- sentimark (PRODUCTION)
- khaleeji-brand-video
- cs-agents
- phone-spam-checker
- training-platform
- personal-os

## Behavior

When switching projects:

1. **Update active project** in database
2. **Load project context** from CLAUDE.md at project path
3. **Show last session summary** from pos_sessions table
4. **List open tasks** for this project
5. **Show recent decisions/notes** from pos_logs

## Implementation

When user runs `/pos-switch <slug>`:

1. Run this Python to switch:
```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import set_active_project, get_project, get_tasks, get_recent_logs

slug = '$ARGS'
if slug == 'list':
    from lib import list_projects
    projects = list_projects()
    for p in projects:
        status = 'PROD' if p['status'] == 'production' else ''
        print(f\"{p['slug']}: {p['name']} {status}\")
else:
    set_active_project(slug)
    project = get_project(slug)
    tasks = get_tasks(project_slug=slug, status='todo')
    logs = get_recent_logs(project_slug=slug, limit=3)

    print(f\"\\nSwitched to: {project['name'] if project else slug}\")
    print(f\"\\nOpen tasks: {len(tasks)}\")
    for t in tasks[:5]:
        print(f\"  - [{t['priority']}] {t['title']}\")
    if logs:
        print(f\"\\nRecent notes:\")
        for l in logs:
            print(f\"  - {l['content'][:60]}...\")
"
```

2. Read the project's CLAUDE.md if it exists:
```bash
cat ~/projects/$ARGS/CLAUDE.md 2>/dev/null | head -50
```

3. Announce: "Switched to [project]. Context loaded. What would you like to work on?"
