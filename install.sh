#!/usr/bin/env bash
# Claude Code Kit Installer
# Copies kit files to ~/.claude/ with path resolution

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

echo "Installing Claude Code Kit to $CLAUDE_HOME"

# Create directory structure
mkdir -p "$CLAUDE_HOME"/{rules,hooks,docs,checklists,scripts,skills,configs,agents,themes,templates,mcp-servers}

# Copy core files
cp "$SCRIPT_DIR/core/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# Process settings template - replace {CLAUDE_HOME} with actual path
sed "s|{CLAUDE_HOME}|$CLAUDE_HOME|g" "$SCRIPT_DIR/core/settings.json.template" > "$CLAUDE_HOME/settings.json"

# Copy directories
for dir in rules hooks docs checklists scripts skills configs agents themes templates; do
  if [ -d "$SCRIPT_DIR/core/$dir" ]; then
    cp -r "$SCRIPT_DIR/core/$dir/"* "$CLAUDE_HOME/$dir/" 2>/dev/null || true
  fi
done

# Copy MCP servers
if [ -d "$SCRIPT_DIR/mcp-servers" ]; then
  cp -r "$SCRIPT_DIR/mcp-servers/"* "$CLAUDE_HOME/mcp-servers/" 2>/dev/null || true
fi

# Make scripts executable
find "$CLAUDE_HOME/hooks" -name "*.sh" -exec chmod +x {} \;
find "$CLAUDE_HOME/scripts" -name "*.sh" -exec chmod +x {} \;
find "$CLAUDE_HOME/mcp-servers" -name "*.sh" -exec chmod +x {} \;

echo "Done! Restart Claude Code to load the new configuration."
echo ""
echo "Next steps:"
echo "  1. Review $CLAUDE_HOME/settings.json"
echo "  2. Update $CLAUDE_HOME/CLAUDE.md with your projects"
echo "  3. Configure MCP server API keys"
