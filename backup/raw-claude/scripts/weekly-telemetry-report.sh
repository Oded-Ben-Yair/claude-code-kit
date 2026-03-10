#!/usr/bin/env bash
set -euo pipefail

# Weekly telemetry analysis for hook enforcement
TELEMETRY_DIR="/home/odedbe/.claude/telemetry"
VIOLATIONS_LOG="${TELEMETRY_DIR}/violations.jsonl"
REPORT_FILE="${TELEMETRY_DIR}/weekly-report-$(date +%Y-%m-%d).md"

echo "# Weekly Hook Enforcement Report" > "$REPORT_FILE"
echo "**Generated**: $(date -u +"%Y-%m-%d %H:%M UTC")" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ ! -f "$VIOLATIONS_LOG" ]; then
  echo "No violations logged yet." >> "$REPORT_FILE"
  cat "$REPORT_FILE"
  exit 0
fi

# Count violations by hook
echo "## Violations by Hook" >> "$REPORT_FILE"
echo "| Hook | Count |" >> "$REPORT_FILE"
echo "|------|-------|" >> "$REPORT_FILE"

for hook in stop-verify schema-verify dead-code-check debug-first deploy-gate; do
  count=$(grep -cE "\"(hook|hook_name)\":\"${hook}\"" "$VIOLATIONS_LOG" 2>/dev/null || true)
  count=${count:-0}
  echo "| ${hook} | ${count} |" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"

# Count violations by category
echo "## Violations by Category" >> "$REPORT_FILE"
echo "| Category | Count |" >> "$REPORT_FILE"
echo "|----------|-------|" >> "$REPORT_FILE"

for cat in verification schema dead-code bypass deployment unverified_completion unverified_table commit_without_debug stale_debug_trace premature_verification; do
  count=$(grep -cE "\"(category|violation_type)\":\"${cat}\"" "$VIOLATIONS_LOG" 2>/dev/null || true)
  count=${count:-0}
  [ "$count" -eq 0 ] && continue
  echo "| ${cat} | ${count} |" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"

# Count by day (last 7 days)
echo "## Daily Trend (Last 7 Days)" >> "$REPORT_FILE"
echo "| Date | Violations |" >> "$REPORT_FILE"
echo "|------|------------|" >> "$REPORT_FILE"

for i in $(seq 0 6); do
  day=$(date -u -d "$i days ago" +"%Y-%m-%d" 2>/dev/null || date -u -v-${i}d +"%Y-%m-%d")
  count=$(grep -c "\"timestamp\":\"${day}" "$VIOLATIONS_LOG" 2>/dev/null || true)
  count=${count:-0}
  echo "| ${day} | ${count} |" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"

# Total stats
total=$(wc -l < "$VIOLATIONS_LOG" 2>/dev/null || echo "0")
if [ -f "${TELEMETRY_DIR}/passes.jsonl" ]; then
  passes=$(wc -l < "${TELEMETRY_DIR}/passes.jsonl")
else
  passes=0
fi
echo "## Summary" >> "$REPORT_FILE"
echo "- **Total violations**: ${total}" >> "$REPORT_FILE"
echo "- **Total passes**: ${passes}" >> "$REPORT_FILE"
if [ "$total" -gt 0 ] && [ "$passes" -gt 0 ]; then
  rate=$(( (passes * 100) / (passes + total) ))
  echo "- **Compliance rate**: ${rate}%" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "## Recent Violations (Last 10)" >> "$REPORT_FILE"
echo '```json' >> "$REPORT_FILE"
tail -10 "$VIOLATIONS_LOG" >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"

cat "$REPORT_FILE"
