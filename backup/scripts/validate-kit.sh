#!/bin/bash
# validate-kit.sh -- Validate an exported Claude Code kit for correctness
# Checks for hardcoded paths, Azure leakage, file integrity, and structure
#
# Usage: bash ~/.claude/scripts/validate-kit.sh [KIT_DIR]
# Exit codes: 0 = all checks pass, 1 = failures found

set -euo pipefail

# --- Configuration ---
KIT_DIR="${1:-$HOME/claude-code-kit}"
ERRORS=0
WARNINGS=0
PASS=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# --- Helper Functions ---
check_pass() {
    echo -e "  ${GREEN}PASS${NC}: $1"
    PASS=$((PASS + 1))
}

check_fail() {
    echo -e "  ${RED}FAIL${NC}: $1"
    ERRORS=$((ERRORS + 1))
}

check_warn() {
    echo -e "  ${YELLOW}WARN${NC}: $1"
    WARNINGS=$((WARNINGS + 1))
}

# --- Pre-flight ---
echo ""
echo -e "${BOLD}${CYAN}Claude Code Kit Validator${NC}"
echo -e "${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo "================================================"
echo ""
echo "Kit directory: $KIT_DIR"
echo ""

if [ ! -d "$KIT_DIR" ]; then
    echo -e "${RED}ERROR: Kit directory does not exist: $KIT_DIR${NC}"
    exit 1
fi

# ============================================================
# CHECK 1: No hardcoded /home/odedbe paths (except Origin: lines)
# ============================================================
echo -e "${BOLD}[1/10] Hardcoded user paths${NC}"

HARDCODED=$(grep -rn "/home/odedbe" "$KIT_DIR" \
    --include="*.md" --include="*.sh" --include="*.json" --include="*.py" --include="*.yaml" --include="*.yml" \
    2>/dev/null | grep -v "^Binary" | grep -v "Origin:" | grep -v ".git/" || true)

if [ -z "$HARDCODED" ]; then
    check_pass "No hardcoded /home/odedbe paths found"
else
    HARDCODED_COUNT=$(echo "$HARDCODED" | wc -l)
    check_fail "Found $HARDCODED_COUNT hardcoded /home/odedbe references (excluding Origin: lines):"
    echo "$HARDCODED" | head -10 | while IFS= read -r line; do
        echo -e "    ${RED}>${NC} $line"
    done
    if [ "$HARDCODED_COUNT" -gt 10 ]; then
        echo -e "    ... and $((HARDCODED_COUNT - 10)) more"
    fi
fi

# ============================================================
# CHECK 2: No Azure MCP tool names in .md files
# ============================================================
echo -e "${BOLD}[2/10] Azure MCP tool references${NC}"

AZURE_TOOLS="azure_chat|azure_code_review|azure_deepseek_reason|azure_brainstorm|azure_research|azure_reason|azure_generate_image|azure-ai-foundry|start-with-keyvault"
AZURE_REFS=$(grep -rn -E "$AZURE_TOOLS" "$KIT_DIR" \
    --include="*.md" \
    2>/dev/null | grep -v "^Binary" | grep -v ".git/" | grep -v "Origin:" || true)

if [ -z "$AZURE_REFS" ]; then
    check_pass "No Azure/private MCP tool names in .md files"
else
    AZURE_COUNT=$(echo "$AZURE_REFS" | wc -l)
    check_fail "Found $AZURE_COUNT Azure MCP tool references in .md files:"
    echo "$AZURE_REFS" | head -10 | while IFS= read -r line; do
        echo -e "    ${RED}>${NC} $line"
    done
    if [ "$AZURE_COUNT" -gt 10 ]; then
        echo -e "    ... and $((AZURE_COUNT - 10)) more"
    fi
fi

# ============================================================
# CHECK 3: No dev.azure.com references
# ============================================================
echo -e "${BOLD}[3/10] Azure DevOps references${NC}"

DEVOPS_REFS=$(grep -rn "dev\.azure\.com\|azure\.devops\|Corp-domain\|Corp-AI\|kv-seekapa" "$KIT_DIR" \
    --include="*.md" --include="*.sh" --include="*.json" --include="*.py" --include="*.yaml" --include="*.yml" \
    2>/dev/null | grep -v "^Binary" | grep -v ".git/" | grep -v "Origin:" || true)

if [ -z "$DEVOPS_REFS" ]; then
    check_pass "No Azure DevOps / org-specific references found"
else
    DEVOPS_COUNT=$(echo "$DEVOPS_REFS" | wc -l)
    check_fail "Found $DEVOPS_COUNT Azure DevOps / org-specific references:"
    echo "$DEVOPS_REFS" | head -10 | while IFS= read -r line; do
        echo -e "    ${RED}>${NC} $line"
    done
    if [ "$DEVOPS_COUNT" -gt 10 ]; then
        echo -e "    ... and $((DEVOPS_COUNT - 10)) more"
    fi
fi

# ============================================================
# CHECK 4: Shell scripts are executable
# ============================================================
echo -e "${BOLD}[4/10] Shell script permissions${NC}"

NON_EXEC=0
NON_EXEC_FILES=""
while IFS= read -r -d '' script; do
    if [ ! -x "$script" ]; then
        NON_EXEC=$((NON_EXEC + 1))
        NON_EXEC_FILES="${NON_EXEC_FILES}\n    ${RED}>${NC} $script"
    fi
done < <(find "$KIT_DIR" -name "*.sh" -not -path "*/.git/*" -print0 2>/dev/null)

if [ "$NON_EXEC" -eq 0 ]; then
    TOTAL_SCRIPTS=$(find "$KIT_DIR" -name "*.sh" -not -path "*/.git/*" 2>/dev/null | wc -l)
    check_pass "All $TOTAL_SCRIPTS shell scripts are executable"
else
    check_fail "$NON_EXEC shell scripts are not executable:"
    echo -e "$NON_EXEC_FILES"
fi

# ============================================================
# CHECK 5: JSON files are valid
# ============================================================
echo -e "${BOLD}[5/10] JSON file validity${NC}"

INVALID_JSON=0
INVALID_JSON_FILES=""
TOTAL_JSON=0
while IFS= read -r -d '' jsonfile; do
    TOTAL_JSON=$((TOTAL_JSON + 1))
    if ! python3 -c "import json; json.load(open('$jsonfile'))" 2>/dev/null; then
        INVALID_JSON=$((INVALID_JSON + 1))
        INVALID_JSON_FILES="${INVALID_JSON_FILES}\n    ${RED}>${NC} $jsonfile"
    fi
done < <(find "$KIT_DIR" -name "*.json" -not -path "*/.git/*" -not -name "*.template" -print0 2>/dev/null)

if [ "$INVALID_JSON" -eq 0 ]; then
    check_pass "All $TOTAL_JSON JSON files are valid"
else
    check_fail "$INVALID_JSON JSON files have parse errors:"
    echo -e "$INVALID_JSON_FILES"
fi

# ============================================================
# CHECK 6: settings.json.template has {CLAUDE_HOME} placeholders
# ============================================================
echo -e "${BOLD}[6/10] Settings template placeholders${NC}"

SETTINGS_TEMPLATE="$KIT_DIR/core/settings.json.template"
if [ ! -f "$SETTINGS_TEMPLATE" ]; then
    check_fail "settings.json.template not found at $SETTINGS_TEMPLATE"
else
    if grep -q '{CLAUDE_HOME}' "$SETTINGS_TEMPLATE"; then
        PLACEHOLDER_COUNT=$(grep -c '{CLAUDE_HOME}' "$SETTINGS_TEMPLATE")
        check_pass "settings.json.template has $PLACEHOLDER_COUNT {CLAUDE_HOME} placeholders"
    else
        check_fail "settings.json.template has no {CLAUDE_HOME} placeholders"
    fi
fi

# ============================================================
# CHECK 7: CLAUDE.md has no azure-ai-foundry / Key Vault refs
# ============================================================
echo -e "${BOLD}[7/10] CLAUDE.md Azure cleanup${NC}"

KIT_CLAUDE="$KIT_DIR/core/CLAUDE.md"
if [ ! -f "$KIT_CLAUDE" ]; then
    check_fail "CLAUDE.md not found at $KIT_CLAUDE"
else
    AZURE_IN_CLAUDE=$(grep -n "azure-ai-foundry\|Key Vault\|kv-seekapa\|start-with-keyvault" "$KIT_CLAUDE" 2>/dev/null || true)
    if [ -z "$AZURE_IN_CLAUDE" ]; then
        check_pass "CLAUDE.md has no azure-ai-foundry / Key Vault references"
    else
        AZURE_CLAUDE_COUNT=$(echo "$AZURE_IN_CLAUDE" | wc -l)
        check_fail "Found $AZURE_CLAUDE_COUNT Azure infrastructure references in CLAUDE.md:"
        echo "$AZURE_IN_CLAUDE" | head -5 | while IFS= read -r line; do
            echo -e "    ${RED}>${NC} $line"
        done
    fi
fi

# ============================================================
# CHECK 8: Required directories exist
# ============================================================
echo -e "${BOLD}[8/10] Required directory structure${NC}"

REQUIRED_DIRS=(
    "core"
    "core/rules"
    "core/hooks"
    "core/scripts"
    "core/agents"
    "core/skills"
    "core/docs"
    "core/checklists"
    "mcp-servers"
)

MISSING_DIRS=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$KIT_DIR/$dir" ]; then
        MISSING_DIRS=$((MISSING_DIRS + 1))
        echo -e "    ${RED}>${NC} Missing: $dir/"
    fi
done

if [ "$MISSING_DIRS" -eq 0 ]; then
    check_pass "All ${#REQUIRED_DIRS[@]} required directories exist"
else
    check_fail "$MISSING_DIRS required directories missing"
fi

# ============================================================
# CHECK 9: install.sh exists and is executable
# ============================================================
echo -e "${BOLD}[9/10] install.sh${NC}"

INSTALL_SH="$KIT_DIR/install.sh"
if [ ! -f "$INSTALL_SH" ]; then
    check_fail "install.sh not found at kit root"
elif [ ! -x "$INSTALL_SH" ]; then
    check_fail "install.sh exists but is not executable"
else
    # Verify it has a shebang
    SHEBANG=$(head -1 "$INSTALL_SH")
    if echo "$SHEBANG" | grep -qE "^#!/"; then
        check_pass "install.sh exists, is executable, has shebang"
    else
        check_warn "install.sh exists and is executable but missing shebang line"
    fi
fi

# ============================================================
# CHECK 10: File count sanity (20-200 files expected)
# ============================================================
echo -e "${BOLD}[10/10] File count sanity${NC}"

FILE_COUNT=$(find "$KIT_DIR" -type f -not -path "*/.git/*" 2>/dev/null | wc -l)

if [ "$FILE_COUNT" -lt 20 ]; then
    check_fail "Only $FILE_COUNT files found (expected 20-200). Generator may have failed."
elif [ "$FILE_COUNT" -gt 200 ]; then
    check_warn "$FILE_COUNT files found (expected 20-200). May include unintended files."
else
    check_pass "$FILE_COUNT files found (within 20-200 range)"
fi

# ============================================================
# SUMMARY
# ============================================================
echo ""
echo "================================================"
echo -e "${BOLD}SUMMARY${NC}"
echo "================================================"
echo ""
echo -e "  ${GREEN}Passed${NC}:   $PASS"
echo -e "  ${YELLOW}Warnings${NC}: $WARNINGS"
echo -e "  ${RED}Failed${NC}:   $ERRORS"
echo ""

TOTAL_CHECKS=$((PASS + ERRORS + WARNINGS))
echo "  Total checks: $TOTAL_CHECKS"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}All checks passed. Kit is ready to push.${NC}"
    echo ""
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}All critical checks passed ($WARNINGS warnings). Review warnings before pushing.${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}$ERRORS check(s) failed. Fix issues before pushing.${NC}"
    echo ""
    exit 1
fi
