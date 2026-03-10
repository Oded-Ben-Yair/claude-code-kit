---
name: claude-agent-sdk
description: |
  Claude Agent SDK for programmatic automation and CI/CD integration.
  Use when:
  - Building automated code review in pipelines
  - Creating security scan agents
  - Orchestrating multi-agent workflows
  - Integrating Claude into Azure DevOps pipelines

  Keywords: sdk, agent, automation, ci, cd, pipeline, devops, review, security
---

# Claude Agent SDK Guide

## Overview

The Claude Agent SDK enables programmatic control of Claude Code for automation, CI/CD integration, and custom workflows.

## Installation

```bash
pip install claude-agent-sdk
```

The SDK automatically bundles the Claude Code CLI - no separate installation needed.

## Quick Start

### Basic Query

```python
from claude_agent_sdk import query

# Simple one-off query
result = query(
    prompt="Review this code for security issues",
    system_prompt="You are a security expert. Be concise.",
    max_turns=1
)
print(result.content)
```

### Interactive Session

```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

# Create client with options
options = ClaudeAgentOptions(
    system_prompt="You are a code reviewer focused on Python best practices.",
    max_turns=10,
    allowed_tools=["Read", "Glob", "Grep"],  # Read-only tools
    working_directory="/path/to/repo"
)

client = ClaudeSDKClient(options)

# Multi-turn conversation
response1 = client.send("Find all Python files with TODO comments")
response2 = client.send("Summarize the findings")

client.close()
```

## CI/CD Integration Patterns

### Azure DevOps Pipeline Code Review

```yaml
# azure-pipelines.yml
trigger:
  - main

jobs:
  - job: AICodeReview
    pool:
      vmImage: 'ubuntu-latest'
    steps:
      - task: UsePythonVersion@0
        inputs:
          versionSpec: '3.11'

      - script: pip install claude-agent-sdk
        displayName: 'Install Claude SDK'

      - script: |
          python ~/.claude/scripts/ci-code-review.py \
            --diff "$(git diff origin/main...HEAD)" \
            --output review-results.json
        displayName: 'Run AI Code Review'
        env:
          ANTHROPIC_API_KEY: $(ANTHROPIC_API_KEY)

      - publish: review-results.json
        artifact: code-review-results
```

### PR Security Scan

```yaml
# In your PR pipeline
- script: |
    python ~/.claude/scripts/ci-security-scan.py \
      --files "$(git diff --name-only origin/main...HEAD)" \
      --severity high \
      --fail-on-issues
  displayName: 'Security Scan'
  env:
    ANTHROPIC_API_KEY: $(ANTHROPIC_API_KEY)
```

## SDK Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `system_prompt` | str | System instructions for the agent |
| `max_turns` | int | Maximum conversation turns (default: 10) |
| `allowed_tools` | list | Restrict to specific tools |
| `permission_mode` | str | `ask`, `auto-allow`, or `deny` |
| `working_directory` | str | Working directory for file operations |
| `model` | str | Model to use: `sonnet`, `opus`, `haiku` |

## Tool Restrictions for CI/CD

For safe CI/CD usage, restrict to read-only tools:

```python
# Safe tools for code review (no writes)
READ_ONLY_TOOLS = [
    "Read",
    "Glob",
    "Grep",
    "Bash(git:log)",
    "Bash(git:diff)",
    "Bash(git:show)"
]

options = ClaudeAgentOptions(
    allowed_tools=READ_ONLY_TOOLS,
    permission_mode="deny"  # Block permission prompts
)
```

## Custom Tool Creation

Create tools without full MCP infrastructure:

```python
from claude_agent_sdk import ClaudeSDKClient, tool

@tool
def check_dependencies(package_json_path: str) -> dict:
    """Check for outdated or vulnerable dependencies."""
    import json
    with open(package_json_path) as f:
        pkg = json.load(f)
    # Analysis logic here
    return {"vulnerabilities": [], "outdated": []}

client = ClaudeSDKClient(
    custom_tools=[check_dependencies]
)
```

## Output Formats

### JSON Output (for pipelines)

```python
from claude_agent_sdk import query

result = query(
    prompt="Review code and output JSON",
    output_format="json"
)

# result.content is parsed JSON
issues = result.content.get("issues", [])
```

### Streaming Output

```python
from claude_agent_sdk import query

for chunk in query(prompt="Analyze this codebase", stream=True):
    print(chunk, end="")
```

## Error Handling

```python
from claude_agent_sdk import query, SDKError, RateLimitError

try:
    result = query(prompt="Review code")
except RateLimitError:
    print("Rate limited - implement backoff")
except SDKError as e:
    print(f"SDK error: {e}")
```

## Best Practices for CI/CD

### 1. Read-Only Mode
Always restrict to read-only tools in automated pipelines.

### 2. Timeout Configuration
Set appropriate timeouts for pipeline contexts:
```python
options = ClaudeAgentOptions(
    timeout=300  # 5 minute timeout
)
```

### 3. Cost Control
Limit token usage per run:
```python
options = ClaudeAgentOptions(
    max_tokens=50000  # Cap token usage
)
```

### 4. Structured Output
Use JSON output for machine-readable results that can be parsed by subsequent pipeline steps.

### 5. Fail-Fast
Configure to fail pipeline on critical findings:
```python
if result.has_critical_issues:
    sys.exit(1)  # Fail pipeline
```

## Example Scripts

See the following scripts in `~/.claude/scripts/`:

- `ci-code-review.py` - Automated code review agent
- `ci-security-scan.py` - Security vulnerability scanner

## Environment Variables

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | API key for authentication |
| `CLAUDE_MODEL` | Override default model |
| `CLAUDE_MAX_TOKENS` | Maximum tokens per request |
| `CLAUDE_TIMEOUT` | Request timeout in seconds |

## Azure DevOps Setup

1. Add `ANTHROPIC_API_KEY` to pipeline variables (secret)
2. Install SDK in pipeline: `pip install claude-agent-sdk`
3. Call scripts with appropriate arguments
4. Parse JSON output for pipeline decisions

## Links

- [PyPI Package](https://pypi.org/project/claude-agent-sdk/)
- [Claude Code Documentation](https://claude.com/claude-code/docs)
- [Agent SDK Reference](https://claude.com/claude-code/docs/sdk)
