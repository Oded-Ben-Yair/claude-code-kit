#!/bin/bash
# build-migration-archive.sh — Build personal migration archive for environment transfer
#
# Copies memory MCP data, project memories, team memories, commands, schemas,
# and other personal artifacts into a migration/ directory inside the kit.
#
# Usage: bash ~/.claude/scripts/build-migration-archive.sh [OUTPUT_DIR]
# Default: ~/claude-code-kit/migration/

set -euo pipefail

OUTPUT_DIR="${1:-$HOME/claude-code-kit/migration}"
CLAUDE_DIR="$HOME/.claude"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${GREEN}Building Migration Archive${NC}"
echo "=========================="
echo "Output: $OUTPUT_DIR"
echo ""

# --- Create directory structure ---
mkdir -p "$OUTPUT_DIR"/{memory-mcp,project-memories,teams,commands,schemas}

COPIED=0
SKIPPED=0
SANITIZED=0

copy_if_exists() {
    local src="$1"
    local dst="$2"
    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp -r "$src" "$dst"
        COPIED=$((COPIED + 1))
        echo -e "  ${GREEN}+${NC} $(basename "$src") -> $(echo "$dst" | sed "s|$OUTPUT_DIR/||")"
    else
        SKIPPED=$((SKIPPED + 1))
        echo -e "  ${YELLOW}-${NC} $(basename "$src") not found, skipping"
    fi
}

# --- Memory MCP (cross-session knowledge graph) ---
echo ""
echo "Memory MCP:"
copy_if_exists "$HOME/.claude-memory/memory.json" "$OUTPUT_DIR/memory-mcp/memory.json"

# --- Global memory ---
echo ""
echo "Global Memory:"
copy_if_exists "$CLAUDE_DIR/MEMORY.md" "$OUTPUT_DIR/global-memory.md"

# --- Project memories ---
echo ""
echo "Project Memories:"
if [ -d "$CLAUDE_DIR/projects" ]; then
    find "$CLAUDE_DIR/projects" -path "*/memory/MEMORY.md" -type f 2>/dev/null | while IFS= read -r memfile; do
        # Extract project name from path
        proj_dir=$(echo "$memfile" | sed "s|$CLAUDE_DIR/projects/||" | cut -d'/' -f1)
        copy_if_exists "$memfile" "$OUTPUT_DIR/project-memories/$proj_dir/MEMORY.md"
        # Also copy any other .md files in the memory dir
        mem_dir=$(dirname "$memfile")
        find "$mem_dir" -name "*.md" -not -name "MEMORY.md" -type f 2>/dev/null | while IFS= read -r extra; do
            copy_if_exists "$extra" "$OUTPUT_DIR/project-memories/$proj_dir/$(basename "$extra")"
        done
    done
else
    echo -e "  ${YELLOW}-${NC} No projects directory found"
fi

# --- Team memories ---
echo ""
echo "Team Memories:"
if [ -d "$CLAUDE_DIR/teams" ]; then
    for team_dir in "$CLAUDE_DIR/teams"/*/; do
        team_name=$(basename "$team_dir")
        if [ -f "$team_dir/team-memory.md" ]; then
            copy_if_exists "$team_dir/team-memory.md" "$OUTPUT_DIR/teams/$team_name/team-memory.md"
        fi
        if [ -f "$team_dir/team-context.md" ]; then
            copy_if_exists "$team_dir/team-context.md" "$OUTPUT_DIR/teams/$team_name/team-context.md"
        fi
        # Copy gold traces if they exist
        if [ -f "$team_dir/gold-traces.md" ]; then
            copy_if_exists "$team_dir/gold-traces.md" "$OUTPUT_DIR/teams/$team_name/gold-traces.md"
        fi
    done
else
    echo -e "  ${YELLOW}-${NC} No teams directory found"
fi

# --- Commands (custom slash commands) ---
echo ""
echo "Commands:"
if [ -d "$CLAUDE_DIR/commands" ]; then
    cp -r "$CLAUDE_DIR/commands/"* "$OUTPUT_DIR/commands/" 2>/dev/null && {
        CMD_COUNT=$(find "$OUTPUT_DIR/commands" -type f | wc -l)
        COPIED=$((COPIED + CMD_COUNT))
        echo -e "  ${GREEN}+${NC} $CMD_COUNT command files"
    } || echo -e "  ${YELLOW}-${NC} Commands directory empty"
else
    echo -e "  ${YELLOW}-${NC} No commands directory found"
fi

# --- Schemas ---
echo ""
echo "Schemas:"
if [ -d "$CLAUDE_DIR/schemas" ]; then
    cp -r "$CLAUDE_DIR/schemas/"* "$OUTPUT_DIR/schemas/" 2>/dev/null && {
        SCHEMA_COUNT=$(find "$OUTPUT_DIR/schemas" -type f | wc -l)
        COPIED=$((COPIED + SCHEMA_COUNT))
        echo -e "  ${GREEN}+${NC} $SCHEMA_COUNT schema files"
    } || echo -e "  ${YELLOW}-${NC} Schemas directory empty"
else
    echo -e "  ${YELLOW}-${NC} No schemas directory found"
fi

# --- Model allocation ---
echo ""
echo "Config Files:"
copy_if_exists "$CLAUDE_DIR/model-allocation.yml" "$OUTPUT_DIR/model-allocation.yml"
copy_if_exists "$CLAUDE_DIR/capabilities-registry.json" "$OUTPUT_DIR/capabilities-registry.json"

# --- Hard Exclude verification ---
echo ""
echo "Verifying exclusions:"
EXCLUDED_PATTERNS=(".env.secrets" ".credentials.json" "node_modules" ".jsonl" "plugins" "debug" "telemetry" "mutable-giggling-sketch")
for pattern in "${EXCLUDED_PATTERNS[@]}"; do
    FOUND=$(find "$OUTPUT_DIR" -name "*$pattern*" -o -path "*$pattern*" 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
        echo -e "  ${RED}!${NC} EXCLUDED pattern found: $FOUND — removing"
        find "$OUTPUT_DIR" -name "*$pattern*" -o -path "*$pattern*" 2>/dev/null -exec rm -rf {} + 2>/dev/null || true
    fi
done
echo -e "  ${GREEN}+${NC} All exclusions verified"

# --- Sanitize paths ---
echo ""
echo "Sanitizing hardcoded paths:"
REAL_HOME=$(eval echo ~)
find "$OUTPUT_DIR" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | while IFS= read -r file; do
    if grep -q "$REAL_HOME" "$file" 2>/dev/null; then
        sed -i "s|$REAL_HOME|\$HOME|g" "$file"
        SANITIZED=$((SANITIZED + 1))
        echo -e "  ${GREEN}+${NC} Sanitized: $(basename "$file")"
    fi
done

# --- Secret scan ---
echo ""
echo "Secret scan on migration/:"
SECRET_FOUND=0
SECRET_PATTERNS=('xai-[a-zA-Z0-9]{60,}' '8wgztq4trtvxwymgx3fw7vgkejmj5laxx4b1nqqee' 'AccountKey=' 'SharedAccessSignature' '-----BEGIN (RSA|EC|PRIVATE)')
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -rqE "$pattern" "$OUTPUT_DIR" 2>/dev/null; then
        echo -e "  ${RED}!${NC} SECRET DETECTED: pattern '$pattern'"
        SECRET_FOUND=1
    fi
done

if [ "$SECRET_FOUND" -eq 0 ]; then
    echo -e "  ${GREEN}+${NC} No secrets detected"
else
    echo -e "  ${RED}!${NC} SECRETS FOUND — review migration/ before committing!"
fi

# --- Summary ---
echo ""
echo "=========================="
echo -e "${GREEN}Migration archive built${NC}"
echo "  Files copied: $COPIED"
echo "  Files skipped: $SKIPPED"
echo "  Files sanitized: $SANITIZED"
echo "  Output: $OUTPUT_DIR"
echo ""
TOTAL_SIZE=$(du -sh "$OUTPUT_DIR" 2>/dev/null | cut -f1)
echo "  Total size: $TOTAL_SIZE"
echo ""
