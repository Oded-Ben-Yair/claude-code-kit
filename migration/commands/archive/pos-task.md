# /pos-task - Task Management

Manage tasks for the active project.

## Usage
```
/pos-task add <title> [--priority high|medium|low] [--due tomorrow|friday|YYYY-MM-DD]
/pos-task list [--all] [--project <slug>]
/pos-task done <task-id>
/pos-task today
```

## Examples
```
/pos-task add "Fix deployment script" --priority high --due friday
/pos-task add "Review PR from team"
/pos-task list
/pos-task done 42
/pos-task today
```

## Implementation

Parse the command and run appropriate Python:

### For `add`:
```bash
python3 -c "
import sys
from datetime import datetime, timedelta
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import add_task, get_active_project

# Parse: title, priority, due_date from args
title = '''$TITLE'''
priority = '''$PRIORITY''' or 'medium'
due_str = '''$DUE'''

due_date = None
if due_str:
    if due_str == 'today':
        due_date = datetime.now().date()
    elif due_str == 'tomorrow':
        due_date = (datetime.now() + timedelta(days=1)).date()
    elif due_str == 'friday':
        days_ahead = 4 - datetime.now().weekday()
        if days_ahead <= 0:
            days_ahead += 7
        due_date = (datetime.now() + timedelta(days=days_ahead)).date()
    else:
        due_date = datetime.strptime(due_str, '%Y-%m-%d').date()

task_id = add_task(title, priority=priority, due_date=due_date)
project = get_active_project()
print(f'Task #{task_id} added to {project}: {title}')
"
```

### For `list`:
```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import get_tasks, get_active_project

project = '''$PROJECT''' or get_active_project()
show_all = '''$ALL''' == 'true'

status = None if show_all else 'todo'
tasks = get_tasks(project_slug=project if project != 'all' else None, status=status)

print(f'\\nTasks ({len(tasks)}):')
for t in tasks:
    status_icon = {'todo': '[ ]', 'in_progress': '[~]', 'blocked': '[X]', 'done': '[v]'}[t['status']]
    priority_tag = {'critical': 'CRIT', 'high': 'HIGH', 'medium': 'MED', 'low': 'LOW'}[t['priority']]
    due = f\" (due {t['due_date']})\" if t['due_date'] else ''
    print(f\"  {status_icon} #{t['id']} [{t['project_slug']}] {priority_tag} {t['title']}{due}\")
"
```

### For `done`:
```bash
python3 -c "
import sys
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import complete_task

task_id = int('''$TASK_ID''')
if complete_task(task_id):
    print(f'Task #{task_id} marked as done!')
else:
    print(f'Task #{task_id} not found')
"
```

### For `today`:
```bash
python3 -c "
import sys
from datetime import datetime
sys.path.insert(0, '$HOME/projects/personal-os')
from lib import get_tasks

tasks = get_tasks(due_before=datetime.now().date())
overdue = [t for t in tasks if t['status'] != 'done']

print(f'\\nDue Today/Overdue ({len(overdue)}):')
for t in overdue:
    priority_tag = {'critical': 'CRIT', 'high': 'HIGH', 'medium': 'MED', 'low': 'LOW'}[t['priority']]
    print(f\"  {priority_tag} #{t['id']} [{t['project_slug']}] {t['title']}\")
"
```
