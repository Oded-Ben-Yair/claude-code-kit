#!/bin/bash
# E2E Test Suite for Claude Code Orchestration
# Run this to validate the orchestration environment is working correctly
#
# Usage: ~/.claude/scripts/test-orchestration-e2e.sh [--verbose]
#
# Exit codes:
#   0 = All tests passed
#   1 = One or more tests failed

# set -e removed to allow tests to continue after failures

CLAUDE_DIR="$HOME/.claude"
VERBOSE=${1:-""}
PASS=0
FAIL=0
TESTS_RUN=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS++))
    ((TESTS_RUN++))
}

log_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    if [ -n "$2" ]; then
        echo -e "  ${YELLOW}→ $2${NC}"
    fi
    ((FAIL++))
    ((TESTS_RUN++))
}

log_info() {
    if [ "$VERBOSE" = "--verbose" ]; then
        echo -e "  ℹ $1"
    fi
}

echo "================================================"
echo "Claude Code Orchestration E2E Test Suite"
echo "================================================"
echo ""

# ============================================================
# TEST GROUP 1: Core Configuration Files
# ============================================================
echo "--- Test Group 1: Core Configuration Files ---"

# Test 1.1: CLAUDE.md exists
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    log_pass "CLAUDE.md exists"
else
    log_fail "CLAUDE.md exists" "File not found at $CLAUDE_DIR/CLAUDE.md"
fi

# Test 1.2: CLAUDE.md contains critical behavior rules
if grep -q "Mock Data Prohibition" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
    log_pass "CLAUDE.md contains Mock Data Prohibition"
else
    log_fail "CLAUDE.md contains Mock Data Prohibition" "Critical rule missing"
fi

# Test 1.3: CLAUDE.md contains Verification Protocol
if grep -q "Verification Protocol" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
    log_pass "CLAUDE.md contains Verification Protocol"
else
    log_fail "CLAUDE.md contains Verification Protocol" "Critical rule missing"
fi

# Test 1.4: CLAUDE.md contains Production Apps warning
if grep -q "PRODUCTION APPLICATIONS" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
    log_pass "CLAUDE.md contains Production Apps warning"
else
    log_fail "CLAUDE.md contains Production Apps warning" "Safety warning missing"
fi

# Test 1.5: CLAUDE.md contains Global Constraints
if grep -q "Global Constraints" "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null; then
    log_pass "CLAUDE.md contains Global Constraints"
else
    log_fail "CLAUDE.md contains Global Constraints" "Critical section missing"
fi

# Test 1.6: CLAUDE.md line count (should be under 200 after refactoring, or under 500 before)
lines=$(wc -l < "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null || echo "0")
if [ "$lines" -gt 0 ] && [ "$lines" -lt 500 ]; then
    log_pass "CLAUDE.md line count reasonable ($lines lines)"
else
    log_fail "CLAUDE.md line count" "Got $lines lines"
fi

echo ""

# ============================================================
# TEST GROUP 2: Rules Files
# ============================================================
echo "--- Test Group 2: Rules Files ---"

# Required rules files
REQUIRED_RULES=(
    "fpf-reasoning.md"
    "visual-validation.md"
    "capability-routing.md"
    "db-isolation.md"
    "git-workflow.md"
    "azure-safety.md"
    "code-quality.md"
)

for rule in "${REQUIRED_RULES[@]}"; do
    if [ -f "$CLAUDE_DIR/rules/$rule" ]; then
        log_pass "rules/$rule exists"
    else
        log_fail "rules/$rule exists" "File not found"
    fi
done

# Test: All referenced rules in CLAUDE.md exist
echo ""
echo "Checking cross-references..."
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
    refs=$(grep -oE 'rules/[a-z0-9-]+\.md' "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null | sort -u || true)
    for ref in $refs; do
        if [ -f "$CLAUDE_DIR/$ref" ]; then
            log_pass "Referenced $ref exists"
        else
            log_fail "Referenced $ref exists" "Dangling reference in CLAUDE.md"
        fi
    done
fi

echo ""

# ============================================================
# TEST GROUP 3: Hooks
# ============================================================
echo "--- Test Group 3: Hooks ---"

# Required hooks
REQUIRED_HOOKS=(
    "session-start-context.sh"
    "session-start-enhanced.sh"
)

for hook in "${REQUIRED_HOOKS[@]}"; do
    if [ -f "$CLAUDE_DIR/hooks/$hook" ]; then
        log_pass "hooks/$hook exists"
        # Check if executable
        if [ -x "$CLAUDE_DIR/hooks/$hook" ]; then
            log_pass "hooks/$hook is executable"
        else
            log_fail "hooks/$hook is executable" "Missing execute permission"
        fi
    else
        log_fail "hooks/$hook exists" "File not found"
    fi
done

# Test: session-start-enhanced.sh produces output
if [ -x "$CLAUDE_DIR/hooks/session-start-enhanced.sh" ]; then
    output=$("$CLAUDE_DIR/hooks/session-start-enhanced.sh" 2>/dev/null || echo "")
    if echo "$output" | grep -q "Quick Capability Router"; then
        log_pass "Hook injects Capability Router"
    else
        log_fail "Hook injects Capability Router" "Router table not in output"
    fi
    if echo "$output" | grep -q "Session Rules Reminder"; then
        log_pass "Hook injects Session Rules"
    else
        log_fail "Hook injects Session Rules" "Rules reminder not in output"
    fi
fi

echo ""

# ============================================================
# TEST GROUP 4: Agents
# ============================================================
echo "--- Test Group 4: Agents ---"

# Core agents
CORE_AGENTS=(
    "architect-planner.md"
    "code-worker.md"
    "code-judge.md"
)

for agent in "${CORE_AGENTS[@]}"; do
    if [ -f "$CLAUDE_DIR/agents/$agent" ]; then
        log_pass "agents/$agent exists"
    else
        log_fail "agents/$agent exists" "Core agent missing"
    fi
done

# Consolidated agents
CONSOLIDATED_AGENTS=(
    "gemini-specialist.md"
    "research-specialist.md"
    "realtime-specialist.md"
    "reasoning-specialist.md"
)

for agent in "${CONSOLIDATED_AGENTS[@]}"; do
    if [ -f "$CLAUDE_DIR/agents/$agent" ]; then
        log_pass "agents/$agent exists"
    else
        log_fail "agents/$agent exists" "Consolidated agent missing"
    fi
done

echo ""

# ============================================================
# TEST GROUP 5: Skills
# ============================================================
echo "--- Test Group 5: Skills ---"

# Core skills
CORE_SKILLS=(
    "morning-update/SKILL.md"
    "end-of-session/SKILL.md"
    "enforce-capabilities/SKILL.md"
    "frontend/SKILL.md"
    "azure-unified/SKILL.md"
)

for skill in "${CORE_SKILLS[@]}"; do
    if [ -f "$CLAUDE_DIR/skills/$skill" ]; then
        log_pass "skills/$skill exists"
    else
        log_fail "skills/$skill exists" "Core skill missing"
    fi
done

echo ""

# ============================================================
# TEST GROUP 6: Templates & Patterns
# ============================================================
echo "--- Test Group 6: Templates & Patterns ---"

# Templates
if [ -f "$CLAUDE_DIR/templates/project-status.json" ]; then
    log_pass "templates/project-status.json exists"
    # Verify it's valid JSON
    if command -v jq &>/dev/null; then
        if jq empty "$CLAUDE_DIR/templates/project-status.json" 2>/dev/null; then
            log_pass "templates/project-status.json is valid JSON"
        else
            log_fail "templates/project-status.json is valid JSON" "Invalid JSON"
        fi
    fi
else
    log_fail "templates/project-status.json exists" "Template missing"
fi

# Patterns
if [ -f "$CLAUDE_DIR/patterns/failure_patterns.json" ]; then
    log_pass "patterns/failure_patterns.json exists"
else
    log_fail "patterns/failure_patterns.json exists" "Patterns file missing"
fi

echo ""

# ============================================================
# TEST GROUP 7: MCP Configuration
# ============================================================
echo "--- Test Group 7: MCP Configuration ---"

# Check if settings.json mentions MCPs (it's in ~/.claude/settings.json or similar)
if [ -f "$HOME/.claude.json" ]; then
    if grep -q "mcpServers" "$HOME/.claude.json" 2>/dev/null; then
        log_pass "MCP servers configured in ~/.claude.json"
    else
        log_fail "MCP servers configured" "No mcpServers in ~/.claude.json"
    fi
else
    log_info "~/.claude.json not found (may be in different location)"
fi

echo ""

# ============================================================
# TEST GROUP 8: Session Index
# ============================================================
echo "--- Test Group 8: Session Tracking ---"

if [ -f "$CLAUDE_DIR/session-index.json" ]; then
    log_pass "session-index.json exists"
    if command -v jq &>/dev/null; then
        if jq empty "$CLAUDE_DIR/session-index.json" 2>/dev/null; then
            log_pass "session-index.json is valid JSON"
            count=$(jq '.stats.total_sessions // 0' "$CLAUDE_DIR/session-index.json" 2>/dev/null)
            log_info "Total sessions tracked: $count"
        else
            log_fail "session-index.json is valid JSON" "Invalid JSON"
        fi
    fi
else
    log_fail "session-index.json exists" "Session tracking not initialized"
fi

echo ""

# ============================================================
# TEST GROUP 9: Research & Daily Updates
# ============================================================
echo "--- Test Group 9: Research Infrastructure ---"

if [ -d "$CLAUDE_DIR/research" ]; then
    log_pass "research/ directory exists"
    if [ -f "$CLAUDE_DIR/research/daily-updates.md" ]; then
        log_pass "research/daily-updates.md exists"
    else
        log_fail "research/daily-updates.md exists" "Daily updates file missing"
    fi
else
    log_fail "research/ directory exists" "Research infrastructure missing"
fi

echo ""

# ============================================================
# TEST GROUP 10: Plans Directory
# ============================================================
echo "--- Test Group 10: Plans ---"

if [ -d "$CLAUDE_DIR/plans" ]; then
    log_pass "plans/ directory exists"
    plan_count=$(ls -1 "$CLAUDE_DIR/plans"/*.md 2>/dev/null | wc -l || echo "0")
    log_info "Active plans: $plan_count"
else
    log_fail "plans/ directory exists" "Plans directory missing"
fi

echo ""

# ============================================================
# SUMMARY
# ============================================================
echo "================================================"
echo "TEST SUMMARY"
echo "================================================"
echo -e "Tests run: $TESTS_RUN"
echo -e "Passed:    ${GREEN}$PASS${NC}"
echo -e "Failed:    ${RED}$FAIL${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$FAIL test(s) failed.${NC}"
    echo "Review failures above and fix before proceeding."
    exit 1
fi
