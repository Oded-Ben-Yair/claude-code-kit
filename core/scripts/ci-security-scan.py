#!${CLAUDE_HOME:-$HOME/.claude}/sdk-venv/bin/python
"""
CI Security Scan Agent
Automated security analysis using Claude Agent SDK for GitHub pipelines.

Usage:
    python ci-security-scan.py --files file1.py file2.ts --output scan.json
    python ci-security-scan.py --directory ./src --output scan.json

Environment:
    ANTHROPIC_API_KEY - Required for authentication
"""

import argparse
import json
import sys
import os
from pathlib import Path
from typing import List, Optional

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

SYSTEM_PROMPT = """You are an expert security analyst specializing in application security.

Analyze the provided code for security vulnerabilities and output a JSON report:
{
    "summary": "Overall security assessment",
    "risk_level": "critical|high|medium|low|none",
    "vulnerabilities": [
        {
            "id": "VULN-001",
            "severity": "critical|high|medium|low",
            "category": "injection|auth|crypto|exposure|config|other",
            "title": "Brief title",
            "file": "path/to/file",
            "line": <line_number or null>,
            "description": "Detailed description",
            "impact": "What could go wrong",
            "remediation": "How to fix",
            "cwe": "CWE-XXX if applicable",
            "owasp": "OWASP category if applicable"
        }
    ],
    "secrets_detected": [
        {
            "file": "path",
            "line": <number>,
            "type": "api_key|password|token|certificate",
            "pattern": "What was detected (redacted)"
        }
    ],
    "recommendations": ["General security improvements"],
    "compliant": true|false
}

Focus on OWASP Top 10:
1. Injection (SQL, Command, XSS)
2. Broken Authentication
3. Sensitive Data Exposure
4. XML External Entities (XXE)
5. Broken Access Control
6. Security Misconfiguration
7. Cross-Site Scripting (XSS)
8. Insecure Deserialization
9. Using Components with Known Vulnerabilities
10. Insufficient Logging & Monitoring

Azure-Specific Concerns:
- Hardcoded connection strings
- Missing Secret Manager references
- Exposed storage account keys
- Insecure CORS configurations
- Missing authentication on endpoints

Be thorough but avoid false positives. Only flag real security issues.
"""


def read_files(file_paths: List[str]) -> dict:
    """Read content from multiple files."""
    contents = {}
    for path in file_paths:
        try:
            if os.path.isfile(path):
                with open(path, 'r', encoding='utf-8', errors='ignore') as f:
                    contents[path] = f.read()
        except Exception as e:
            contents[path] = f"Error reading file: {e}"
    return contents


def find_files(directory: str, extensions: List[str] = None) -> List[str]:
    """Find files in directory matching extensions."""
    if extensions is None:
        extensions = ['.py', '.ts', '.tsx', '.js', '.jsx', '.json', '.yaml', '.yml', '.sh', '.sql']

    files = []
    for root, _, filenames in os.walk(directory):
        # Skip common non-code directories
        if any(skip in root for skip in ['node_modules', '__pycache__', '.git', '.venv', 'venv']):
            continue
        for filename in filenames:
            if any(filename.endswith(ext) for ext in extensions):
                files.append(os.path.join(root, filename))
    return files


def run_security_scan(file_contents: dict, output_file: str, verbose: bool = False) -> dict:
    """Run security scan on file contents."""

    if not SDK_AVAILABLE:
        return {
            "error": "claude-agent-sdk not installed",
            "summary": "SDK not available - install with: pip install claude-agent-sdk",
            "risk_level": "unknown",
            "vulnerabilities": [],
            "secrets_detected": [],
            "compliant": False
        }

    # Build prompt with file contents
    files_section = "\n\n".join([
        f"### {path}\n```\n{content[:10000]}\n```"  # Truncate large files
        for path, content in file_contents.items()
        if not content.startswith("Error")
    ])

    prompt = f"""Perform a security analysis on the following files:

{files_section}

Provide your security assessment as a JSON object following the specified structure.
Be thorough in identifying vulnerabilities, especially:
- Hardcoded secrets or credentials
- SQL/Command injection points
- Missing input validation
- Insecure configurations
- Azure-specific security issues
"""

    try:
        options = ClaudeAgentOptions(
            system_prompt=SYSTEM_PROMPT,
            allowed_tools=ALLOWED_TOOLS,
            max_turns=5,
            model="sonnet"
        )

        result = query(
            prompt=prompt,
            options=options,
            output_format="json"
        )

        scan = result.content if isinstance(result.content, dict) else json.loads(result.content)

    except json.JSONDecodeError:
        scan = {
            "summary": "Scan completed but output was not valid JSON",
            "raw_response": str(result.content) if 'result' in dir() else "No response",
            "risk_level": "unknown",
            "vulnerabilities": [],
            "secrets_detected": [],
            "compliant": False
        }
    except Exception as e:
        scan = {
            "error": str(e),
            "summary": f"Scan failed: {e}",
            "risk_level": "unknown",
            "vulnerabilities": [],
            "secrets_detected": [],
            "compliant": False
        }

    # Write output
    if output_file:
        with open(output_file, 'w') as f:
            json.dump(scan, f, indent=2)
        if verbose:
            print(f"Scan results written to: {output_file}")

    return scan


def main():
    parser = argparse.ArgumentParser(description='AI-powered security scan for CI/CD')
    parser.add_argument('--files', nargs='+', help='Files to scan')
    parser.add_argument('--directory', '-d', type=str, help='Directory to scan')
    parser.add_argument('--output', '-o', type=str, default='security-scan.json',
                        help='Output file for scan results')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    parser.add_argument('--fail-on-critical', action='store_true',
                        help='Exit with code 1 if critical vulnerabilities found')
    parser.add_argument('--fail-on-high', action='store_true',
                        help='Exit with code 1 if high or critical vulnerabilities found')
    parser.add_argument('--fail-on-secrets', action='store_true',
                        help='Exit with code 1 if secrets detected')
    parser.add_argument('--severity', type=str, default='low',
                        choices=['critical', 'high', 'medium', 'low'],
                        help='Minimum severity to report')

    args = parser.parse_args()

    # Collect files to scan
    files_to_scan = []
    if args.files:
        files_to_scan.extend(args.files)
    if args.directory:
        files_to_scan.extend(find_files(args.directory))

    if not files_to_scan:
        # Default: scan current directory
        files_to_scan = find_files('.')

    if not files_to_scan:
        print("No files to scan")
        sys.exit(0)

    if args.verbose:
        print(f"Scanning {len(files_to_scan)} files...")

    # Read file contents
    file_contents = read_files(files_to_scan)

    # Run scan
    scan = run_security_scan(file_contents, args.output, args.verbose)

    # Print summary
    print(f"\n=== Security Scan Results ===")
    print(f"Risk Level: {scan.get('risk_level', 'N/A').upper()}")
    print(f"Compliant: {'Yes' if scan.get('compliant', False) else 'No'}")
    print(f"Summary: {scan.get('summary', 'N/A')}")

    vulnerabilities = scan.get('vulnerabilities', [])
    secrets = scan.get('secrets_detected', [])

    if vulnerabilities:
        print(f"\nVulnerabilities Found ({len(vulnerabilities)}):")
        for vuln in vulnerabilities:
            print(f"  [{vuln.get('severity', 'unknown').upper()}] {vuln.get('title', 'Unknown')}")
            print(f"    File: {vuln.get('file', 'N/A')}, Line: {vuln.get('line', 'N/A')}")
            print(f"    {vuln.get('description', '')[:100]}...")

    if secrets:
        print(f"\nSecrets Detected ({len(secrets)}):")
        for secret in secrets:
            print(f"  [{secret.get('type', 'unknown')}] {secret.get('file', 'N/A')}:{secret.get('line', '?')}")

    # Check failure conditions
    if args.fail_on_secrets and secrets:
        print(f"\n! Found {len(secrets)} secret(s). Failing pipeline.")
        sys.exit(1)

    if args.fail_on_critical:
        critical = [v for v in vulnerabilities if v.get('severity') == 'critical']
        if critical:
            print(f"\n! Found {len(critical)} critical vulnerability(ies). Failing pipeline.")
            sys.exit(1)

    if args.fail_on_high:
        high_plus = [v for v in vulnerabilities if v.get('severity') in ['critical', 'high']]
        if high_plus:
            print(f"\n! Found {len(high_plus)} high+ severity vulnerability(ies). Failing pipeline.")
            sys.exit(1)

    print("\n Security scan completed.")
    sys.exit(0)


if __name__ == '__main__':
    main()
