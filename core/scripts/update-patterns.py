#!/usr/bin/env python3
"""
Pattern Update Script
Updates success_patterns.json or failure_patterns.json with new patterns.
Part of Silent Kernel Architecture v7.0

Usage:
  python update-patterns.py success --name "Pattern Name" --category "category" --description "desc"
  python update-patterns.py failure --name "Anti-Pattern" --category "category" --description "desc"
  python update-patterns.py increment --type success --id pattern-001
  python update-patterns.py list --type success
"""

import json
import sys
import argparse
from pathlib import Path
from datetime import datetime

PATTERNS_DIR = Path.home() / ".claude" / "patterns"
SUCCESS_FILE = PATTERNS_DIR / "success_patterns.json"
FAILURE_FILE = PATTERNS_DIR / "failure_patterns.json"


def load_patterns(file_path: Path) -> dict:
    """Load patterns from JSON file."""
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {file_path}: {e}", file=sys.stderr)
        return None


def save_patterns(file_path: Path, data: dict):
    """Save patterns to JSON file."""
    try:
        with open(file_path, 'w') as f:
            json.dump(data, f, indent=2)
        print(f"Updated {file_path}")
    except Exception as e:
        print(f"Error saving {file_path}: {e}", file=sys.stderr)


def get_next_id(patterns: list, prefix: str) -> str:
    """Get next available ID."""
    existing_ids = [p.get('id', '') for p in patterns]
    max_num = 0
    for id in existing_ids:
        if id.startswith(prefix):
            try:
                num = int(id.split('-')[1])
                max_num = max(max_num, num)
            except:
                pass
    return f"{prefix}-{str(max_num + 1).zfill(3)}"


def add_success_pattern(args):
    """Add a new success pattern."""
    data = load_patterns(SUCCESS_FILE)
    if not data:
        return

    new_pattern = {
        "id": get_next_id(data.get("patterns", []), "pattern"),
        "category": args.category,
        "name": args.name,
        "description": args.description,
        "context": args.context or "General use",
        "approach": args.approach.split(";") if args.approach else ["Step 1", "Step 2"],
        "why_it_works": args.why or "Proven effective",
        "dateAdded": datetime.now().strftime("%Y-%m-%d"),
        "usageCount": 0,
        "successRate": None
    }

    data["patterns"].append(new_pattern)
    data["lastUpdated"] = datetime.now().strftime("%Y-%m-%d")
    save_patterns(SUCCESS_FILE, data)
    print(f"Added success pattern: {new_pattern['id']} - {new_pattern['name']}")


def add_failure_pattern(args):
    """Add a new failure pattern."""
    data = load_patterns(FAILURE_FILE)
    if not data:
        return

    new_pattern = {
        "id": get_next_id(data.get("antiPatterns", []), "anti"),
        "category": args.category,
        "name": args.name,
        "description": args.description,
        "symptoms": args.symptoms.split(";") if args.symptoms else ["Symptom 1"],
        "consequence": args.consequence or "Negative outcome",
        "correct_approach": args.correct or "Do this instead",
        "severity": args.severity or "medium",
        "dateAdded": datetime.now().strftime("%Y-%m-%d"),
        "occurrenceCount": 0
    }

    data["antiPatterns"].append(new_pattern)
    data["lastUpdated"] = datetime.now().strftime("%Y-%m-%d")
    save_patterns(FAILURE_FILE, data)
    print(f"Added failure pattern: {new_pattern['id']} - {new_pattern['name']}")


def increment_usage(args):
    """Increment usage count for a pattern."""
    if args.type == "success":
        data = load_patterns(SUCCESS_FILE)
        patterns_key = "patterns"
    else:
        data = load_patterns(FAILURE_FILE)
        patterns_key = "antiPatterns"

    if not data:
        return

    for pattern in data.get(patterns_key, []):
        if pattern.get("id") == args.id:
            if args.type == "success":
                pattern["usageCount"] = pattern.get("usageCount", 0) + 1
            else:
                pattern["occurrenceCount"] = pattern.get("occurrenceCount", 0) + 1

            data["lastUpdated"] = datetime.now().strftime("%Y-%m-%d")
            save_patterns(SUCCESS_FILE if args.type == "success" else FAILURE_FILE, data)
            print(f"Incremented {args.id}")
            return

    print(f"Pattern {args.id} not found", file=sys.stderr)


def list_patterns(args):
    """List all patterns."""
    if args.type == "success":
        data = load_patterns(SUCCESS_FILE)
        patterns = data.get("patterns", []) if data else []
        print("\n=== Success Patterns ===")
        for p in patterns:
            usage = p.get("usageCount", 0)
            print(f"  {p['id']}: {p['name']} (usage: {usage})")
    else:
        data = load_patterns(FAILURE_FILE)
        patterns = data.get("antiPatterns", []) if data else []
        print("\n=== Failure Patterns ===")
        for p in patterns:
            count = p.get("occurrenceCount", 0)
            severity = p.get("severity", "?")
            print(f"  {p['id']}: {p['name']} [{severity}] (occurrences: {count})")


def main():
    parser = argparse.ArgumentParser(description="Pattern management for Silent Kernel")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Success pattern
    success_parser = subparsers.add_parser("success", help="Add success pattern")
    success_parser.add_argument("--name", required=True, help="Pattern name")
    success_parser.add_argument("--category", required=True, help="Category")
    success_parser.add_argument("--description", required=True, help="Description")
    success_parser.add_argument("--context", help="When to use")
    success_parser.add_argument("--approach", help="Steps separated by ;")
    success_parser.add_argument("--why", help="Why it works")

    # Failure pattern
    failure_parser = subparsers.add_parser("failure", help="Add failure pattern")
    failure_parser.add_argument("--name", required=True, help="Anti-pattern name")
    failure_parser.add_argument("--category", required=True, help="Category")
    failure_parser.add_argument("--description", required=True, help="Description")
    failure_parser.add_argument("--symptoms", help="Symptoms separated by ;")
    failure_parser.add_argument("--consequence", help="What goes wrong")
    failure_parser.add_argument("--correct", help="Correct approach")
    failure_parser.add_argument("--severity", choices=["critical", "high", "medium", "low"])

    # Increment
    inc_parser = subparsers.add_parser("increment", help="Increment usage count")
    inc_parser.add_argument("--type", required=True, choices=["success", "failure"])
    inc_parser.add_argument("--id", required=True, help="Pattern ID")

    # List
    list_parser = subparsers.add_parser("list", help="List patterns")
    list_parser.add_argument("--type", required=True, choices=["success", "failure"])

    args = parser.parse_args()

    if args.command == "success":
        add_success_pattern(args)
    elif args.command == "failure":
        add_failure_pattern(args)
    elif args.command == "increment":
        increment_usage(args)
    elif args.command == "list":
        list_patterns(args)


if __name__ == "__main__":
    main()
