#!/bin/bash
# Claude Code Sanity Check Script
# Run this BEFORE starting Claude Code to verify configuration

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║       Claude Code Configuration Sanity Check                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

PASS=0
FAIL=0
WARN=0

check_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASS++))
}

check_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAIL++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARN++))
}

# ============================================
echo "📁 Checking Agent Files..."
echo "-------------------------------------------"

AGENTS_DIR="$HOME/.claude/agents"

if [ -f "$AGENTS_DIR/grok-code-fast.md" ]; then
    check_pass "grok-code-fast.md exists"
else
    check_fail "grok-code-fast.md missing"
fi

if [ -f "$AGENTS_DIR/gemini-deep-reasoner.md" ]; then
    check_pass "gemini-deep-reasoner.md exists"
else
    check_fail "gemini-deep-reasoner.md missing"
fi

if [ -f "$AGENTS_DIR/gpt5-pro-brainstormer.md" ]; then
    check_pass "gpt5-pro-brainstormer.md exists"
else
    check_fail "gpt5-pro-brainstormer.md missing"
fi

AGENT_COUNT=$(ls -1 "$AGENTS_DIR"/*.md 2>/dev/null | wc -l)
echo "   Total agents: $AGENT_COUNT"
echo ""

# ============================================
echo "🔧 Checking MCP Servers..."
echo "-------------------------------------------"

if [ -f "$HOME/.claude/mcp-servers/grok/dist/index.js" ]; then
    check_pass "Grok MCP built"
else
    check_fail "Grok MCP not built - run: cd ~/.claude/mcp-servers/grok && npm run build"
fi

# Test if Grok MCP starts
if cd "$HOME/.claude/mcp-servers/grok" && timeout 2 node dist/index.js --help 2>&1 | grep -q "Server started"; then
    check_pass "Grok MCP starts successfully"
else
    check_warn "Grok MCP may have issues starting"
fi
cd - > /dev/null

echo ""

# ============================================
echo "📄 Checking Configuration Files..."
echo "-------------------------------------------"

if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    SIZE=$(wc -c < "$HOME/.claude/CLAUDE.md")
    check_pass "CLAUDE.md exists ($SIZE bytes)"
else
    check_fail "CLAUDE.md missing"
fi

if [ -f "$HOME/.claude/capabilities-registry.json" ]; then
    if python3 -c "import json; json.load(open('$HOME/.claude/capabilities-registry.json'))" 2>/dev/null; then
        check_pass "capabilities-registry.json valid JSON"
    else
        check_fail "capabilities-registry.json invalid JSON"
    fi
else
    check_fail "capabilities-registry.json missing"
fi

if [ -f "$HOME/.claude/skills/smart-router/SKILL.md" ]; then
    check_pass "smart-router skill exists"
else
    check_fail "smart-router skill missing"
fi

if [ -f "$HOME/.claude/skills/multi-model-debate/SKILL.md" ]; then
    check_pass "multi-model-debate skill exists"
else
    check_fail "multi-model-debate skill missing"
fi

echo ""

# ============================================
echo "🔑 Checking API Keys (in settings.json)..."
echo "-------------------------------------------"

SETTINGS="$HOME/.claude/settings.json"
if [ -f "$SETTINGS" ]; then
    if grep -q "XAI_API_KEY" "$SETTINGS"; then
        check_pass "Grok API key configured"
    else
        check_warn "Grok API key not found in settings.json"
    fi
else
    check_fail "settings.json missing"
fi

echo ""

# ============================================
echo "📊 Token Impact Estimate..."
echo "-------------------------------------------"

TOTAL=0
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    SIZE=$(wc -c < "$HOME/.claude/CLAUDE.md")
    TOKENS=$((SIZE / 4))
    echo "   CLAUDE.md: ~$TOKENS tokens"
    TOTAL=$((TOTAL + TOKENS))
fi

if [ -f "$HOME/.claude/capabilities-registry.json" ]; then
    SIZE=$(wc -c < "$HOME/.claude/capabilities-registry.json")
    TOKENS=$((SIZE / 4))
    echo "   capabilities-registry.json: ~$TOKENS tokens"
    TOTAL=$((TOTAL + TOKENS))
fi

if [ -d "$HOME/.claude/skills" ]; then
    SIZE=$(find "$HOME/.claude/skills" -name "*.md" -exec cat {} + 2>/dev/null | wc -c)
    TOKENS=$((SIZE / 4))
    echo "   Skills (all): ~$TOKENS tokens"
    TOTAL=$((TOTAL + TOKENS))
fi

if [ -d "$HOME/.claude/rules" ]; then
    SIZE=$(cat "$HOME/.claude/rules"/*.md 2>/dev/null | wc -c)
    TOKENS=$((SIZE / 4))
    echo "   Rules (all): ~$TOKENS tokens"
    TOTAL=$((TOTAL + TOKENS))
fi

echo "   ---"
echo "   Total ambient: ~$TOTAL tokens"
PERCENT=$((TOTAL * 100 / 200000))
echo "   Context usage: ~$PERCENT% of 200k"

if [ $PERCENT -gt 20 ]; then
    check_warn "High token overhead ($PERCENT%)"
else
    check_pass "Token overhead acceptable ($PERCENT%)"
fi

echo ""

# ============================================
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                        SUMMARY                                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo -e "   ${GREEN}Passed${NC}: $PASS"
echo -e "   ${YELLOW}Warnings${NC}: $WARN"
echo -e "   ${RED}Failed${NC}: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start Claude Code: claude"
    echo "  2. Run in-session tests from: ~/.claude/sanity-check.md"
    echo ""
else
    echo -e "${RED}❌ Some checks failed - fix issues before starting Claude Code${NC}"
    echo ""
    exit 1
fi
