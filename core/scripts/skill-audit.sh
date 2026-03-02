#!/bin/bash
# Skill Audit Script — Validates all active skills against standards
# Checks: YAML frontmatter, name field, description length, no XML, directory structure, metadata.version

trap 'exit 0' ERR

SKILLS_DIR="$HOME/.claude/skills"
PASS=0
FAIL=0
WARN=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

results=()

inc_pass() { PASS=$((PASS + 1)); }
inc_fail() { FAIL=$((FAIL + 1)); }
inc_warn() { WARN=$((WARN + 1)); }

add_result() {
    local skill="$1"
    local check="$2"
    local status="$3"
    local detail="$4"
    results+=("${skill}|${check}|${status}|${detail}")
}

check_skill() {
    local skill_path="$1"
    local skill_name=""
    local skill_file=""

    # Determine if directory or flat file
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        skill_file="$skill_path/SKILL.md"
        if [ ! -f "$skill_file" ]; then
            add_result "$skill_name" "SKILL.md" "FAIL" "Missing SKILL.md in directory"
            inc_fail
            return
        fi
    elif [ -f "$skill_path" ]; then
        skill_name=$(basename "$skill_path" .md)
        skill_file="$skill_path"
        add_result "$skill_name" "Structure" "WARN" "Flat file (should be directory with SKILL.md)"
        inc_warn
    else
        return
    fi

    # Check 1: YAML frontmatter with --- delimiters
    # Strip \r for WSL compatibility
    local first_line
    first_line=$(head -n 1 "$skill_file" | tr -d '\r')
    if [ "$first_line" != "---" ]; then
        add_result "$skill_name" "Frontmatter" "FAIL" "Missing opening --- delimiter"
        inc_fail
        return
    fi

    # Find closing --- (line 2+), strip \r before matching
    local closing_line
    closing_line=$(tail -n +2 "$skill_file" | tr -d '\r' | grep -n "^---$" | head -n 1 | cut -d: -f1)
    if [ -z "$closing_line" ]; then
        add_result "$skill_name" "Frontmatter" "FAIL" "Missing closing --- delimiter"
        inc_fail
        return
    fi
    add_result "$skill_name" "Frontmatter" "PASS" "Valid YAML delimiters"
    inc_pass

    # Extract frontmatter content (between the two --- lines), strip \r
    local fm_end=$((closing_line + 1))
    local frontmatter
    frontmatter=$(sed -n "2,${fm_end}p" "$skill_file" | tr -d '\r' | head -n -1)

    # Check 2: name field matches directory/file name
    local name_value
    name_value=$(echo "$frontmatter" | grep -E "^name:" | head -n 1 | sed 's/^name:[[:space:]]*//')
    if [ -z "$name_value" ]; then
        add_result "$skill_name" "Name field" "FAIL" "Missing name field"
        inc_fail
    elif [ "$name_value" = "$skill_name" ]; then
        add_result "$skill_name" "Name field" "PASS" "Matches directory name"
        inc_pass
    else
        add_result "$skill_name" "Name field" "FAIL" "name='$name_value' != dir='$skill_name'"
        inc_fail
    fi

    # Check 3: description under 1024 chars
    # Handle multi-line YAML description (| or > block scalar)
    local desc_line
    desc_line=$(echo "$frontmatter" | grep -n "^description:" | head -n 1 | cut -d: -f1)
    local desc_text=""
    if [ -n "$desc_line" ]; then
        local desc_value
        desc_value=$(echo "$frontmatter" | sed -n "${desc_line}p" | sed 's/^description:[[:space:]]*//')
        if [ "$desc_value" = "|" ] || [ "$desc_value" = ">" ]; then
            # Multi-line: collect indented lines after description:
            local line_num=$((desc_line + 1))
            local total_lines
            total_lines=$(echo "$frontmatter" | wc -l)
            while [ "$line_num" -le "$total_lines" ]; do
                local line
                line=$(echo "$frontmatter" | sed -n "${line_num}p")
                if echo "$line" | grep -qE "^[[:space:]]"; then
                    desc_text="${desc_text}${line}"
                else
                    break
                fi
                line_num=$((line_num + 1))
            done
        else
            desc_text="$desc_value"
        fi
    fi

    if [ -z "$desc_text" ]; then
        add_result "$skill_name" "Description" "FAIL" "Missing description field"
        inc_fail
    else
        local desc_len=${#desc_text}
        if [ "$desc_len" -le 1024 ]; then
            add_result "$skill_name" "Description" "PASS" "${desc_len} chars (max 1024)"
            inc_pass
        else
            add_result "$skill_name" "Description" "FAIL" "${desc_len} chars exceeds 1024 limit"
            inc_fail
        fi
    fi

    # Check 4: No XML tags in frontmatter
    if echo "$frontmatter" | grep -qE "<[a-zA-Z][a-zA-Z0-9_-]*[^>]*>"; then
        add_result "$skill_name" "No XML" "FAIL" "XML tags found in frontmatter"
        inc_fail
    else
        add_result "$skill_name" "No XML" "PASS" "No XML tags"
        inc_pass
    fi

    # Check 5: Directory structure (not flat file) — already handled above for flat files
    if [ -d "$skill_path" ]; then
        add_result "$skill_name" "Structure" "PASS" "Directory with SKILL.md"
        inc_pass
    fi

    # Check 6: metadata.version present
    if echo "$frontmatter" | grep -qE "^[[:space:]]*version:"; then
        add_result "$skill_name" "Version" "PASS" "metadata.version present"
        inc_pass
    elif echo "$frontmatter" | grep -qE "^metadata:"; then
        # Check nested metadata block for version
        local meta_line
        meta_line=$(echo "$frontmatter" | grep -n "^metadata:" | head -n 1 | cut -d: -f1)
        local after_meta
        after_meta=$(echo "$frontmatter" | tail -n "+$((meta_line + 1))")
        if echo "$after_meta" | grep -qE "^[[:space:]]+version:"; then
            add_result "$skill_name" "Version" "PASS" "metadata.version present"
            inc_pass
        else
            add_result "$skill_name" "Version" "WARN" "metadata block exists but no version field"
            inc_warn
        fi
    else
        add_result "$skill_name" "Version" "WARN" "No metadata.version field"
        inc_warn
    fi
}

# Header
echo ""
echo -e "${BOLD}${CYAN}Skill Audit Report${NC}"
echo -e "${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo "================================================"
echo ""

# Find all active skills (skip archive/)
for entry in "$SKILLS_DIR"/*/; do
    entry="${entry%/}"
    local_name=$(basename "$entry")
    # Skip archive directory
    if [ "$local_name" = "archive" ]; then
        continue
    fi
    check_skill "$entry"
done

# Also check flat .md files in skills dir
for entry in "$SKILLS_DIR"/*.md; do
    if [ -f "$entry" ]; then
        check_skill "$entry"
    fi
done

# Print results table
printf "\n${BOLD}%-25s %-15s %-6s %s${NC}\n" "SKILL" "CHECK" "STATUS" "DETAIL"
printf "%-25s %-15s %-6s %s\n" "-------------------------" "---------------" "------" "------------------------------"

for result in "${results[@]}"; do
    IFS='|' read -r skill check status detail <<< "$result"
    color="$NC"
    case "$status" in
        PASS) color="$GREEN" ;;
        FAIL) color="$RED" ;;
        WARN) color="$YELLOW" ;;
    esac
    printf "%-25s %-15s ${color}%-6s${NC} %s\n" "$skill" "$check" "$status" "$detail"
done

# Summary
echo ""
echo "================================================"
echo -e "Summary: ${GREEN}${PASS} PASS${NC} | ${RED}${FAIL} FAIL${NC} | ${YELLOW}${WARN} WARN${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}Some skills need attention.${NC}"
else
    echo -e "${GREEN}All skills pass audit checks.${NC}"
fi

exit 0
