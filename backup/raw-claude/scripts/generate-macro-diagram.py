#!/usr/bin/env python3
"""
Generate a macro (overview) diagram from a detailed interactive diagram JSON.

Reads the detailed JSON, groups nodes by their 'group' field, and produces
a collapsed macro JSON where each group becomes a single node.

Usage:
    python3 generate-macro-diagram.py <detailed.json> <macro-output.json>

The detailed JSON nodes must have a 'data.group' field like:
    { "id": "market-data", "data": { "group": "data-sources", ... } }

Nodes sharing the same group are collapsed into one macro node.
Cross-group edges are derived and deduplicated automatically.
"""

import json
import sys
from collections import defaultdict, OrderedDict


# ── Macro node metadata: display names, categories, positions, descriptions ──

MACRO_NODE_META = {
    "trigger": {
        "label": "Trigger",
        "category": "trigger",
        "position": {"x": 400, "y": 50},
    },
    "selection": {
        "label": "Asset Selection",
        "category": "process",
        "position": {"x": 400, "y": 200},
    },
    "data-sources": {
        "label": "Data Sources",
        "category": "data",
        "position": {"x": 400, "y": 400},
    },
    "intelligence": {
        "label": "Intelligence Layer",
        "category": "process",
        "position": {"x": 400, "y": 600},
    },
    "context-builder": {
        "label": "Context Builder",
        "category": "gate",
        "position": {"x": 400, "y": 800},
    },
    "llm-ensemble": {
        "label": "LLM Ensemble",
        "category": "process",
        "position": {"x": 400, "y": 1000},
    },
    "consensus": {
        "label": "Consensus",
        "category": "gate",
        "position": {"x": 300, "y": 1200},
    },
    "gate": {
        "label": "Quality Gate",
        "category": "gate",
        "position": {"x": 300, "y": 1400},
    },
    "outcomes": {
        "label": "Outcomes",
        "category": "trade",
        "position": {"x": 300, "y": 1600},
    },
    "storage": {
        "label": "Storage",
        "category": "storage",
        "position": {"x": 400, "y": 1800},
    },
    "feedback": {
        "label": "Feedback Loop",
        "category": "process",
        "position": {"x": 400, "y": 2000},
    },
}


def build_group_map(nodes):
    """Map node IDs to their group, and groups to their node lists."""
    node_to_group = {}
    group_to_nodes = defaultdict(list)

    for node in nodes:
        group = node.get("data", {}).get("group")
        if not group:
            # Use node ID as its own group (singleton)
            group = node["id"]
        node_to_group[node["id"]] = group
        group_to_nodes[group].append(node)

    return node_to_group, dict(group_to_nodes)


def derive_macro_edges(edges, node_to_group):
    """Derive cross-group edges, deduplicating and collecting labels."""
    seen = set()
    macro_edges = []

    for edge in edges:
        src_group = node_to_group.get(edge["source"])
        tgt_group = node_to_group.get(edge["target"])

        if not src_group or not tgt_group:
            continue
        if src_group == tgt_group:
            continue  # Intra-group edge, skip

        edge_key = (src_group, tgt_group)
        if edge_key in seen:
            continue
        seen.add(edge_key)

        macro_edge = {
            "id": f"e-{src_group}-{tgt_group}",
            "source": src_group,
            "target": tgt_group,
            "animated": True,
            "type": "animated",
        }

        # Carry over label if present
        if "label" in edge:
            macro_edge["label"] = edge["label"]

        # Carry over dashed style for shadow edges
        style = edge.get("style", {})
        if style.get("strokeDasharray"):
            macro_edge["style"] = {"strokeDasharray": "5,5"}
            macro_edge.pop("animated", None)
            macro_edge.pop("type", None)

        macro_edges.append(macro_edge)

    return macro_edges


def build_macro_description(group_name, group_nodes):
    """Build a macro node description from its child nodes."""
    child_labels = [n["data"]["label"] for n in group_nodes]
    count = len(child_labels)

    if count == 1:
        # Singleton — use the child's description directly
        return group_nodes[0]["data"].get("details", "")

    # Multi-node group — list children with brief descriptions
    lines = [f"**{count} components** working together:\n"]
    for node in group_nodes:
        label = node["data"]["label"]
        # Extract first sentence of details as summary
        details = node["data"].get("details", "")
        first_sentence = details.split(".")[0] + "." if details else ""
        lines.append(f"- **{label}**: {first_sentence}")

    return "\n".join(lines)


def build_macro_step_description(group_name, group_nodes):
    """Build a short tour step description for a macro node."""
    count = len(group_nodes)
    labels = [n["data"]["label"] for n in group_nodes]

    if count == 1:
        # Use the child's stepDescription if available
        step_desc = group_nodes[0]["data"].get("stepDescription", "")
        if step_desc:
            return step_desc
        # Fall back to first 2 sentences of details
        details = group_nodes[0]["data"].get("details", "")
        sentences = details.split(". ")
        return ". ".join(sentences[:2]) + "." if sentences else ""

    # For multi-node groups, combine key info
    child_names = ", ".join(labels[:4])
    if count > 4:
        child_names += f", and {count - 4} more"
    return f"{count} components: {child_names}."


def build_macro_code_snippet(group_nodes):
    """Pick the most representative code snippet from group children."""
    for node in group_nodes:
        snippet = node["data"].get("codeSnippet")
        if snippet:
            return snippet
    return None


def build_macro_file_path(group_nodes):
    """Pick the most representative file path from group children."""
    paths = [n["data"].get("filePath") for n in group_nodes if n["data"].get("filePath")]
    if len(paths) == 1:
        return paths[0]
    if paths:
        # Find common prefix
        common = paths[0]
        for p in paths[1:]:
            while not p.startswith(common):
                common = common.rsplit("/", 1)[0] + "/"
                if "/" not in common:
                    common = ""
                    break
        return common.rstrip("/") + "/" if common else paths[0]
    return None


def generate_macro_json(detailed_json):
    """Main function: generate macro diagram JSON from detailed JSON."""
    nodes = detailed_json["nodes"]
    edges = detailed_json["edges"]
    meta = detailed_json.get("meta", {})

    node_to_group, group_to_nodes = build_group_map(nodes)
    macro_edges = derive_macro_edges(edges, node_to_group)

    # Build ordered group list (preserve vertical flow order)
    group_order = []
    seen_groups = set()
    for node in nodes:
        group = node.get("data", {}).get("group", node["id"])
        if group not in seen_groups:
            group_order.append(group)
            seen_groups.add(group)

    # Build macro nodes
    macro_nodes = []
    step_index = 1

    for group_name in group_order:
        group_nodes = group_to_nodes.get(group_name, [])
        if not group_nodes:
            continue

        node_meta = MACRO_NODE_META.get(group_name, {})
        count = len(group_nodes)
        label = node_meta.get("label", group_name.replace("-", " ").title())
        if count > 1:
            label = f"{label} ({count})"

        node_data = {
            "label": label,
            "category": node_meta.get("category", "process"),
            "details": build_macro_description(group_name, group_nodes),
            "group": group_name,
            "childCount": count,
            "children": [n["data"]["label"] for n in group_nodes],
        }

        # Add code snippet and file path
        snippet = build_macro_code_snippet(group_nodes)
        if snippet:
            node_data["codeSnippet"] = snippet

        file_path = build_macro_file_path(group_nodes)
        if file_path:
            node_data["filePath"] = file_path

        # Add tour step
        node_data["stepIndex"] = step_index
        node_data["stepDescription"] = build_macro_step_description(group_name, group_nodes)
        step_index += 1

        macro_nodes.append({
            "id": group_name,
            "type": "interactive",
            "position": node_meta.get("position", {"x": 400, "y": step_index * 200}),
            "data": node_data,
        })

    # Build macro meta
    macro_meta = {
        "title": meta.get("title", "Diagram") + " (Overview)",
        "description": f"High-level overview: {len(macro_nodes)} families, collapsed from {len(nodes)} detailed nodes. Click any family to see its components.",
        "totalSteps": len(macro_nodes),
    }

    return {
        "nodes": macro_nodes,
        "edges": macro_edges,
        "meta": macro_meta,
    }


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <detailed.json> <macro-output.json>", file=sys.stderr)
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    with open(input_path, "r") as f:
        detailed = json.load(f)

    macro = generate_macro_json(detailed)

    with open(output_path, "w") as f:
        json.dump(macro, f, indent=2)

    node_count = len(macro["nodes"])
    edge_count = len(macro["edges"])
    step_count = macro["meta"]["totalSteps"]
    print(f"Generated macro diagram: {node_count} nodes, {edge_count} edges, {step_count} tour steps")
    print(f"Output: {output_path}")


if __name__ == "__main__":
    main()
