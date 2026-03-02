# Multi-Provider AI MCP Server

FastMCP server providing Vertex AI tools for Claude Code.

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Configure GCP credentials:
```bash
gcloud auth application-default login
```

3. Set environment variables (copy `.env.example` to `.env`):
```bash
cp .env.example .env
# Edit .env with your GCP project ID
```

## Usage

Start the server:
```bash
bash start-with-adc.sh
```

Or run directly:
```bash
GCP_PROJECT=your-project python3 server.py
```

## Tools Available

| Tool | Description |
|------|-------------|
| `vertex_chat` | Chat with Vertex AI models (Gemini, Claude via Vertex) |
| `vertex_code_review` | Code review using Vertex AI |
| `vertex_brainstorm` | Brainstorm ideas |
| `vertex_reason` | Deep reasoning with thinking models |

## Testing

```bash
python3 -m pytest test_server.py -v
```

## Adding to Claude Code

Add to `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "vertex-ai": {
      "command": "bash",
      "args": ["~/.claude/mcp-servers/vertex-ai/start-with-adc.sh"]
    }
  }
}
```
