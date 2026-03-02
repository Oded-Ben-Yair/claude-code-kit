#!/bin/bash
# Daily Research Script - Part of Silent Kernel Architecture
# Runs Perplexity research on Claude Code best practices
# Schedule with cron: 0 6 * * * ~/.claude/scripts/daily-research.sh

CLAUDE_DIR="$HOME/.claude"
RESEARCH_FILE="$CLAUDE_DIR/research/daily-updates.md"
DATE=$(date '+%Y-%m-%d')
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Ensure research directory exists
mkdir -p "$CLAUDE_DIR/research"

# Research topics to rotate through
TOPICS=(
    "Claude Code best practices 2026"
    "MCP server development patterns"
    "Multi-agent orchestration LLM"
    "Context engineering LLM optimization"
    "LangGraph vs custom agent orchestration"
)

# Pick today's topic (rotate based on day of week)
DAY_OF_WEEK=$(date '+%u')
TOPIC_INDEX=$((DAY_OF_WEEK % ${#TOPICS[@]}))
TODAY_TOPIC="${TOPICS[$TOPIC_INDEX]}"

# Log the research request
echo "[$TIMESTAMP] Researching: $TODAY_TOPIC" >> "$CLAUDE_DIR/research/research.log"

# Append to daily-updates.md with placeholder for results
cat >> "$RESEARCH_FILE" << EOF

---

### $DATE

**Query**: $TODAY_TOPIC
**Status**: Pending manual review
**Timestamp**: $TIMESTAMP

**Key Findings**:
*Run the following in Claude Code to populate:*
\`\`\`
Use perplexity_research to research: "$TODAY_TOPIC"
Then update this section with findings.
\`\`\`

**Recommended Actions**:
- [ ] Review findings
- [ ] Propose rule updates if applicable
- [ ] Get user approval

**Applied to Rules**: Pending
**User Approved**: Pending

EOF

echo "Research entry added for: $TODAY_TOPIC"
echo "Review in Claude Code session to populate findings."
