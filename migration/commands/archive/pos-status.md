# /pos-status - Current Context Status

Show current active project, open tasks, and recent activity.

## Usage
```
/pos-status
/pos-status --all  (show all projects)
```

## Implementation

```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import get_active_project, get_tasks, get_recent_logs, list_projects

show_all = '''$ALL''' == 'true'
active = get_active_project()

print(f'\\nActive Project: {active}')
print('-' * 40)

if show_all:
    projects = list_projects()
    print(f'\\nAll Projects:')
    for p in projects:
        tasks = get_tasks(project_slug=p['slug'], status='todo')
        icon = 'PROD' if p['status'] == 'production' else ''
        active_marker = ' <- ACTIVE' if p['slug'] == active else ''
        print(f\"  {p['slug']}: {len(tasks)} tasks {icon}{active_marker}\")
else:
    tasks = get_tasks(project_slug=active, status='todo')
    print(f'\\nOpen Tasks ({len(tasks)}):')
    for t in tasks[:5]:
        priority_tag = {'critical': 'CRIT', 'high': 'HIGH', 'medium': 'MED', 'low': 'LOW'}[t['priority']]
        print(f\"  #{t['id']} {priority_tag} {t['title']}\")
    if len(tasks) > 5:
        print(f'  ... and {len(tasks) - 5} more')

    logs = get_recent_logs(limit=3)
    if logs:
        print(f'\\nRecent Notes:')
        for l in logs:
            icon = {'note': 'NOTE', 'decision': 'DECISION', 'blocker': 'BLOCKER', 'idea': 'IDEA'}[l['log_type']]
            print(f\"  [{icon}] {l['content'][:50]}...\")

print()
"
```
