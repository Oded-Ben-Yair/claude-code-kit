#!/home/odedbe/.claude/sdk-venv/bin/python
"""
CI Code Review Agent
Automated code review using Claude Agent SDK for Azure DevOps pipelines.

Usage:
    python ci-code-review.py --diff <diff_content> --output review.json
    python ci-code-review.py --pr <pr_number> --output review.json

Environment:
    ANTHROPIC_API_KEY - Required for authentication
"""

import argparse
import json
import sys
import os
from pathlib import Path

# SDK import (graceful fallback if not installed)
try:
    from claude_agent_sdk import query, ClaudeAgentOptions
    SDK_AVAILABLE = True
except ImportError:
    SDK_AVAILABLE = False
    print("Warning: claude-agent-sdk not installed. Run: pip install claude-agent-sdk")


# Read-only tools only - safe for CI
ALLOWED_TOOLS = [
    "Read",
    "Glob",
    "Grep",
]

SYSTEM_PROMPT = """You are an expert code reviewer for a production Azure environment.

Review the provided code changes and output a JSON report with this structure:
{
    "summary": "Brief overall assessment",
    "score": <1-10>,
    "issues": [
        {
            "severity": "critical|high|medium|low",
            "file": "path/to/file",
            "line": <line_number or null>,
            "type": "security|bug|performance|style|maintainability",
            "description": "Issue description",
            "suggestion": "How to fix"
        }
    ],
    "highlights": ["Positive aspects of the code"],
    "recommendation": "approve|request_changes|needs_discussion"
}

Focus on:
1. Security vulnerabilities (SQL injection, XSS, credential exposure)
2. Azure-specific concerns (Key Vault usage, connection strings)
3. Database isolation (cross-project access violations)
4. Error handling and edge cases
5. Performance implications
6. Code quality and maintainability

Be constructive and specific. Only flag actual issues, not style preferences unless egregious.
"""


def run_code_review(diff_content: str, output_file: str, verbose: bool = False) -> dict:
    """Run code review on diff content."""

    if not SDK_AVAILABLE:
        return {
            "error": "claude-agent-sdk not installed",
            "summary": "SDK not available - install with: pip install claude-agent-sdk",
            "score": 0,
            "issues": [],
            "recommendation": "needs_discussion"
        }

    prompt = f"""Review the following code changes:

```diff
{diff_content}
```

Provide your review as a JSON object following the specified structure.
"""

    try:
        options = ClaudeAgentOptions(
            system_prompt=SYSTEM_PROMPT,
            allowed_tools=ALLOWED_TOOLS,
            max_turns=5,
            model="sonnet"  # Fast and capable for reviews
        )

        result = query(
            prompt=prompt,
            options=options,
            output_format="json"
        )

        review = result.content if isinstance(result.content, dict) else json.loads(result.content)

    except json.JSONDecodeError:
        # If response isn't valid JSON, wrap it
        review = {
            "summary": "Review completed but output was not valid JSON",
            "raw_response": str(result.content) if 'result' in dir() else "No response",
            "score": 5,
            "issues": [],
            "recommendation": "needs_discussion"
        }
    except Exception as e:
        review = {
            "error": str(e),
            "summary": f"Review failed: {e}",
            "score": 0,
            "issues": [],
            "recommendation": "needs_discussion"
        }

    # Write output
    if output_file:
        with open(output_file, 'w') as f:
            json.dump(review, f, indent=2)
        if verbose:
            print(f"Review written to: {output_file}")

    return review


def get_diff_from_git() -> str:
    """Get diff from current git state."""
    import subprocess

    try:
        # Try to get diff against main/master
        for base in ['origin/main', 'origin/master', 'main', 'master']:
            try:
                result = subprocess.run(
                    ['git', 'diff', f'{base}...HEAD'],
                    capture_output=True,
                    text=True,
                    check=True
                )
                if result.stdout.strip():
                    return result.stdout
            except subprocess.CalledProcessError:
                continue

        # Fallback to staged changes
        result = subprocess.run(
            ['git', 'diff', '--cached'],
            capture_output=True,
            text=True
        )
        return result.stdout or "No changes found"

    except Exception as e:
        return f"Error getting diff: {e}"


def main():
    parser = argparse.ArgumentParser(description='AI-powered code review for CI/CD')
    parser.add_argument('--diff', type=str, help='Diff content to review')
    parser.add_argument('--diff-file', type=str, help='Path to file containing diff')
    parser.add_argument('--auto-diff', action='store_true', help='Auto-detect diff from git')
    parser.add_argument('--output', '-o', type=str, default='review-results.json',
                        help='Output file for review results')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    parser.add_argument('--fail-on-critical', action='store_true',
                        help='Exit with code 1 if critical issues found')
    parser.add_argument('--fail-threshold', type=int, default=5,
                        help='Fail if score below this threshold (1-10)')

    args = parser.parse_args()

    # Get diff content
    if args.diff:
        diff_content = args.diff
    elif args.diff_file:
        with open(args.diff_file) as f:
            diff_content = f.read()
    elif args.auto_diff:
        diff_content = get_diff_from_git()
    else:
        # Default: try auto-diff
        diff_content = get_diff_from_git()

    if not diff_content or diff_content.startswith("No changes") or diff_content.startswith("Error"):
        print(f"No diff to review: {diff_content}")
        sys.exit(0)

    if args.verbose:
        print(f"Reviewing {len(diff_content)} characters of diff...")

    # Run review
    review = run_code_review(diff_content, args.output, args.verbose)

    # Print summary
    print(f"\n=== Code Review Results ===")
    print(f"Score: {review.get('score', 'N/A')}/10")
    print(f"Recommendation: {review.get('recommendation', 'N/A')}")
    print(f"Summary: {review.get('summary', 'N/A')}")

    issues = review.get('issues', [])
    if issues:
        print(f"\nIssues Found ({len(issues)}):")
        for issue in issues:
            print(f"  [{issue.get('severity', 'unknown').upper()}] {issue.get('type', '')}: {issue.get('description', '')}")

    # Check failure conditions
    if args.fail_on_critical:
        critical_issues = [i for i in issues if i.get('severity') == 'critical']
        if critical_issues:
            print(f"\n! Found {len(critical_issues)} critical issue(s). Failing pipeline.")
            sys.exit(1)

    score = review.get('score', 10)
    if score < args.fail_threshold:
        print(f"\n! Score {score} below threshold {args.fail_threshold}. Failing pipeline.")
        sys.exit(1)

    print("\n Review completed successfully.")
    sys.exit(0)


if __name__ == '__main__':
    main()
