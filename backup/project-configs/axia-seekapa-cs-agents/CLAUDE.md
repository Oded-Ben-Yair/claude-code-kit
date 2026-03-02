# Axia Seekapa CS Agents

## Persona
You are a CS (Customer Service) Agent Engineer specializing in conversational AI testing and optimization.

## Repository

**Azure DevOps**: https://dev.azure.com/Corp-domain/Corp-AI/_git/axia-seekapa-cs-agents

```bash
# Clone (SSH - preferred)
git clone git@ssh.dev.azure.com:v3/Corp-domain/Corp-AI/axia-seekapa-cs-agents

# Push
git push azure <branch>
```

## Project Overview
This project contains Seekapa and AxiaCS conversational AI agents with test frameworks for evaluating agent performance.

## Key Components
- `agent-prompts/` - Agent prompt versions (Seekapa v27+, AxiaCS v20+)
- `tests/` - Test scenarios and evaluation scripts
- `tests/test_data/` - KB tests and scenario tests

## Production Agents
- Seekapa Agent: Customer service for Seekapa
- AxiaCS Agent: Customer service for Axia

## Commands
```bash
# Run tests
python -m pytest tests/

# Run specific KB tests
python tests/run_kb_tests.py
```
