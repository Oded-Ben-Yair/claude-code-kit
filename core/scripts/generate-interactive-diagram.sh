#!/bin/bash
# Usage: generate-interactive-diagram.sh <data.json> <output.html> [title]
# Injects JSON data into the interactive diagram template

TEMPLATE="$HOME/.claude/templates/interactive-diagram.html"
DATA_FILE="$1"
OUTPUT="$2"
TITLE="${3:-Interactive Diagram}"

if [ ! -f "$TEMPLATE" ]; then
  echo "ERROR: Template not found at $TEMPLATE" >&2
  exit 1
fi

if [ ! -f "$DATA_FILE" ]; then
  echo "ERROR: Data file not found: $DATA_FILE" >&2
  exit 1
fi

# Use Python for safe JSON injection (sed breaks on multi-line values)
python3 -c "
import json, sys
with open('$TEMPLATE', 'r') as f:
    html = f.read()
with open('$DATA_FILE', 'r') as f:
    data = f.read().strip()
# Validate JSON
json.loads(data)
# Replace placeholder
html = html.replace(
    'window.__DIAGRAM_DATA__ = { nodes: [], edges: [], meta: {} };',
    'window.__DIAGRAM_DATA__ = ' + data + ';'
)
# Replace title
html = html.replace('<title>Interactive Diagram</title>', '<title>$TITLE</title>')
with open('$OUTPUT', 'w') as f:
    f.write(html)
print(f'Generated: $OUTPUT')
" 2>&1

if [ $? -ne 0 ]; then
  echo "ERROR: Generation failed" >&2
  exit 1
fi

echo "Size: $(du -h "$OUTPUT" | cut -f1)"

# ── Auto-generate macro (overview) diagram if nodes have 'group' fields ──
HAS_GROUPS=$(python3 -c "
import json
with open('$DATA_FILE') as f:
    d = json.load(f)
groups = {n['data'].get('group') for n in d['nodes'] if n['data'].get('group')}
print(len(groups))
" 2>/dev/null)

if [ "$HAS_GROUPS" -gt 3 ] 2>/dev/null; then
    MACRO_JSON="${DATA_FILE%.json}-macro.json"
    MACRO_HTML="${OUTPUT%.html}-macro.html"
    MACRO_TITLE="${TITLE} (Overview)"

    # Generate macro JSON
    python3 -c "
import json, re
from collections import defaultdict

with open('$DATA_FILE') as f:
    data = json.load(f)
nodes, edges, meta = data['nodes'], data['edges'], data.get('meta', {})

node_to_group, group_to_nodes, group_order, seen_groups = {}, defaultdict(list), [], set()
for n in nodes:
    g = n['data'].get('group', n['id'])
    node_to_group[n['id']] = g
    group_to_nodes[g].append(n)
    if g not in seen_groups:
        group_order.append(g)
        seen_groups.add(g)

def first_line(text):
    for line in text.split(chr(10)):
        line = line.strip()
        if line and not line.startswith('|') and not line.startswith('**') and len(line) > 10:
            clean = re.sub(r'\*\*([^*]+)\*\*', r'\1', line)
            return clean[:120] + '...' if len(clean) > 120 else clean
    return text[:100]

macro_nodes, step = [], 1
# Smart layout: pair adjacent same-size groups side-by-side
y_pos, cx = 50, 400
row_gap, pair_offset = 170, 220
# Collect group info first, then assign positions
group_infos = []
for g in group_order:
    gnodes = group_to_nodes[g]
    count = len(gnodes)
    label = g.replace('-', ' ').title()
    if count > 1: label = f'{label} ({count})'
    children = [n['data']['label'] for n in gnodes]
    cat = gnodes[0]['data'].get('category', 'process')
    if count == 1:
        desc = gnodes[0]['data'].get('details', '')
        sdesc = gnodes[0]['data'].get('stepDescription', '')
    else:
        lines = [f'**{count} components** working together:\n']
        for n in gnodes:
            lines.append(f'- **{n[\"data\"][\"label\"]}**: {first_line(n[\"data\"].get(\"details\", \"\"))}')
        desc = chr(10).join(lines)
        sdesc = f'{count} components: {chr(44).join(chr(32)+c for c in children[:4]).strip()}' + (f', and {count-4} more' if count>4 else '') + '.'
    snippet = next((n['data'].get('codeSnippet') for n in gnodes if n['data'].get('codeSnippet')), None)
    fpath = next((n['data'].get('filePath') for n in gnodes if n['data'].get('filePath')), None)
    nd = {'label': label, 'category': cat, 'group': g, 'details': desc, 'childCount': count, 'children': children, 'stepIndex': step, 'stepDescription': sdesc}
    if snippet: nd['codeSnippet'] = snippet
    if fpath: nd['filePath'] = fpath
    group_infos.append((g, nd))
    step += 1
# Assign positions: try to pair consecutive groups side-by-side when both have >1 child
i = 0
while i < len(group_infos):
    gid, nd = group_infos[i]
    if i + 1 < len(group_infos):
        gid2, nd2 = group_infos[i + 1]
        c1, c2 = nd.get('childCount', 1), nd2.get('childCount', 1)
        # Pair side-by-side if both multi-child OR similar role (both gates, both outcomes, etc.)
        if (c1 > 1 and c2 > 1) or (nd['category'] == nd2['category'] and c1 + c2 > 2):
            macro_nodes.append({'id': gid, 'type': 'interactive', 'position': {'x': cx - pair_offset, 'y': y_pos}, 'data': nd})
            macro_nodes.append({'id': gid2, 'type': 'interactive', 'position': {'x': cx + pair_offset, 'y': y_pos}, 'data': nd2})
            y_pos += row_gap
            i += 2
            continue
    macro_nodes.append({'id': gid, 'type': 'interactive', 'position': {'x': cx, 'y': y_pos}, 'data': nd})
    y_pos += row_gap
    i += 1

seen_e, macro_edges = set(), []
for e in edges:
    sg, tg = node_to_group.get(e['source']), node_to_group.get(e['target'])
    if not sg or not tg or sg == tg: continue
    key = (sg, tg)
    if key in seen_e: continue
    seen_e.add(key)
    if e.get('style', {}).get('strokeDasharray'):
        macro_edges.append({'id': f'e-{sg}-{tg}', 'source': sg, 'target': tg, 'style': {'strokeDasharray': '5,5'}})
    else:
        me = {'id': f'e-{sg}-{tg}', 'source': sg, 'target': tg, 'animated': True, 'type': 'animated'}
        if e.get('label'): me['label'] = e['label']
        macro_edges.append(me)

result = {'nodes': macro_nodes, 'edges': macro_edges, 'meta': {'title': meta.get('title','Diagram')+' (Overview)', 'description': f'High-level overview: {len(macro_nodes)} families from {len(nodes)} nodes.', 'totalSteps': len(macro_nodes)}}
with open('$MACRO_JSON', 'w') as f:
    json.dump(result, f, indent=2)
print(f'Macro JSON: {len(macro_nodes)} nodes, {len(macro_edges)} edges')
" 2>&1

    if [ $? -eq 0 ] && [ -f "$MACRO_JSON" ]; then
        # Generate macro HTML using same template
        python3 -c "
import json
with open('$TEMPLATE', 'r') as f:
    html = f.read()
with open('$MACRO_JSON', 'r') as f:
    data = f.read().strip()
json.loads(data)
html = html.replace('window.__DIAGRAM_DATA__ = { nodes: [], edges: [], meta: {} };', 'window.__DIAGRAM_DATA__ = ' + data + ';')
html = html.replace('<title>Interactive Diagram</title>', '<title>$MACRO_TITLE</title>')
with open('$MACRO_HTML', 'w') as f:
    f.write(html)
print(f'Macro HTML: $MACRO_HTML ($(du -h \"$MACRO_HTML\" 2>/dev/null | cut -f1))')
" 2>&1
        echo "Macro: $(du -h "$MACRO_HTML" | cut -f1)"
    fi
fi
