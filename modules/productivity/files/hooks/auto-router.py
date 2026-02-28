#!/usr/bin/env python3
"""
Auto-Router Hook for Claude Code
UserPromptSubmit hook that detects user intent and injects routing instructions
BEFORE Claude starts processing.

This reads step_intent_patterns from capabilities-registry.json and matches
the user's prompt to automatically suggest the right MCP/agent/tool.
"""

import json
import sys
import re
import os
from pathlib import Path
from datetime import datetime

# Paths — use CLAUDE_HOME env var if set, otherwise ~/.claude
CLAUDE_HOME = Path(os.environ.get("CLAUDE_HOME", Path.home() / ".claude"))
REGISTRY_PATH = CLAUDE_HOME / "capabilities-registry.json"
TELEMETRY_DIR = CLAUDE_HOME / "telemetry"
CHECKLISTS_DIR = CLAUDE_HOME / "checklists"

# Checklist trigger patterns: (keywords, checklist_file, description)
CHECKLIST_TRIGGERS = [
    (["deploy", "push to prod", "git push", "pipeline run"], "before-deploy.md", "Deployment"),
    (["refactor", "restructure", "reorganize", "delete files", "move code"], "before-refactor.md", "Refactoring"),
    (["new file", "new module", "create module", "add file", "create file"], "before-new-file.md", "New file creation"),
    (["pipeline", "transcription", "processing", "audio", "diarization"], "before-pipeline-change.md", "Pipeline change"),
    (["ml", "prediction", "training", "evaluation"], "before-ml-change.md", "ML change"),
    (["fix", "bug", "error", "broken", "failing", "crash"], "before-bugfix.md", "Bug fix"),
]

def log_routing_decision(intent: str, confidence: float, keywords: list, prompt_preview: str):
    """Log routing decision for calibration feedback loop."""
    TELEMETRY_DIR.mkdir(parents=True, exist_ok=True)
    log_file = TELEMETRY_DIR / f"routing-{datetime.now().strftime('%Y-%m-%d')}.jsonl"

    entry = {
        "timestamp": datetime.now().isoformat(),
        "event": "routing_suggestion",
        "intent_classification": {
            "detected_intent": intent,
            "confidence": round(confidence, 2),
            "keywords_matched": keywords
        },
        "prompt_preview": prompt_preview[:100] + "..." if len(prompt_preview) > 100 else prompt_preview
    }

    try:
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")
    except Exception:
        pass  # Don't fail the hook if logging fails

def load_registry():
    """Load capabilities registry with intent patterns."""
    try:
        with open(REGISTRY_PATH, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Warning: Could not load registry: {e}", file=sys.stderr)
        return None

def match_intent(prompt: str, patterns: dict) -> list[tuple[str, float]]:
    """
    Match prompt against intent patterns.
    Returns list of (intent_name, confidence) tuples, sorted by confidence.

    Scoring:
    - Single word match = 0.5 base
    - Multi-word keyword match = 0.6 base (slightly more specific)
    - Each additional match adds 0.2 (strong bonus for multiple signals)
    - Cap at 1.0

    This prioritizes multiple matches over single multi-word matches.
    """
    prompt_lower = prompt.lower()
    matches = []

    for intent, keywords in patterns.items():
        base_score = 0
        matched_keywords = []

        for keyword in keywords:
            keyword_lower = keyword.lower()
            is_multi_word = ' ' in keyword_lower

            # Exact word/phrase boundary match
            if re.search(rf'\b{re.escape(keyword_lower)}\b', prompt_lower):
                if is_multi_word:
                    # Multi-word matches are slightly more specific
                    base_score = max(base_score, 0.6)
                else:
                    base_score = max(base_score, 0.5)
                matched_keywords.append(keyword)
            # Partial match for single words only
            elif not is_multi_word and keyword_lower in prompt_lower:
                base_score = max(base_score, 0.3)
                matched_keywords.append(keyword)

        if matched_keywords:
            # Strong bonus for multiple matches - this is the key signal
            bonus = min((len(matched_keywords) - 1) * 0.2, 0.4)
            confidence = min(base_score + bonus, 1.0)
            matches.append((intent, confidence, matched_keywords))

    # Sort by confidence descending, then by number of keywords matched
    matches.sort(key=lambda x: (x[1], len(x[2])), reverse=True)
    return matches

def match_checklist(prompt: str) -> str:
    """Match prompt against checklist triggers and return suggestion text."""
    prompt_lower = prompt.lower()
    matched = []
    for keywords, filename, description in CHECKLIST_TRIGGERS:
        for kw in keywords:
            if re.search(rf'\b{re.escape(kw)}\b', prompt_lower):
                checklist_path = CHECKLISTS_DIR / filename
                if checklist_path.exists():
                    matched.append((description, str(checklist_path)))
                break
    if not matched:
        return ""
    parts = ["**CHECKLIST REMINDER**: Read before proceeding:"]
    for desc, path in matched:
        parts.append(f"  - {desc}: `{path}`")
    return "\n".join(parts)


def get_routing_instruction(intent: str, capability_map: dict, agents: list, skills: list, mcps: list) -> str:
    """Generate routing instruction text for the matched intent."""
    if intent not in capability_map:
        return ""

    cap = capability_map[intent]
    parts = []

    # Build the instruction
    parts.append(f"**AUTO-ROUTING DETECTED**: Intent `{intent}` matched.")

    if "agent" in cap:
        agent_id = cap["agent"]
        agent_info = next((a for a in agents if a["id"] == agent_id), None)
        if agent_info:
            parts.append(f"-> **Use Agent**: `{agent_info['name']}` (subagent_type: `{agent_id}`)")
            if agent_info.get("mcp"):
                parts.append(f"   MCP: `{agent_info['mcp']}`")

    if "skill" in cap:
        skill_id = cap["skill"]
        skill_info = next((s for s in skills if s["id"] == skill_id), None)
        if skill_info:
            parts.append(f"-> **Use Skill**: `/{skill_id}` - {skill_info['name']}")

    if "mcp" in cap and "tool" in cap:
        parts.append(f"-> **Direct MCP Tool**: `mcp__{cap['mcp']}__{cap['tool']}`")
        if "config" in cap:
            config_str = ", ".join(f"{k}={v}" for k, v in cap["config"].items())
            parts.append(f"   Config: {config_str}")

    if "model" in cap:
        parts.append(f"-> **Model**: `{cap['model']}`")

    if "workflow" in cap:
        parts.append(f"-> **Workflow**: `{cap['workflow']}`")

    return "\n".join(parts)

def main():
    # Read input from stdin
    try:
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: Invalid JSON input: {e}", file=sys.stderr)
        sys.exit(1)

    prompt = input_data.get("prompt", "")

    if not prompt:
        # No prompt, allow through
        sys.exit(0)

    # Load registry
    registry = load_registry()
    if not registry:
        # Can't load registry, allow through without routing
        sys.exit(0)

    # Get patterns and capability map
    patterns = registry.get("step_intent_patterns", {})
    capability_map = registry.get("intent_to_capability", {})
    agents = registry.get("capabilities", {}).get("agents", [])
    skills = registry.get("capabilities", {}).get("skills", [])
    mcps = registry.get("capabilities", {}).get("mcps", [])

    # Match intent from registry
    matches = match_intent(prompt, patterns)

    # Check for checklist triggers (independent of registry routing)
    checklist_suggestion = match_checklist(prompt)

    routing = ""
    confidence = 0
    keywords = []

    if matches:
        threshold = registry.get("matching_rules", {}).get("confidence_threshold", 0.4)
        top_intent, confidence, keywords = matches[0]

        if confidence >= threshold:
            routing = get_routing_instruction(top_intent, capability_map, agents, skills, mcps)
            log_routing_decision(top_intent, confidence, keywords, prompt)

    if not routing and not checklist_suggestion:
        # No routing or checklist available
        sys.exit(0)

    # Build additional context to inject
    context_parts = ["", "---"]

    if routing:
        context_parts.append(routing)
        context_parts.append(f"*Matched keywords: {', '.join(keywords)} (confidence: {confidence:.0%})*")
        context_parts.append("")
        context_parts.append("**IMPORTANT**: Follow the routing above. Do NOT use generic Claude tools when a specialized MCP/agent is indicated.")

    if checklist_suggestion:
        context_parts.append("")
        context_parts.append(checklist_suggestion)

    context_parts.extend(["---", ""])

    # Output as JSON with additionalContext
    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": "\n".join(context_parts)
        }
    }

    print(json.dumps(output))
    sys.exit(0)

if __name__ == "__main__":
    main()
