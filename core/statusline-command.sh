#!/bin/bash
# Claude Code Status Line — Terminal Visual State Layer v8.0

input=$(cat)

# Extract current directory
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
cwd="${cwd:-$(pwd)}"
dir_name=$(basename "$cwd")

# Git branch detection
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    [ -n "$branch" ] && git_info=" on $branch"
fi

# Project detection from CLAUDE.md Project Map
project=""
case "$cwd" in
    */sentimark*) project="Sentimark" ;;
    */qc-call-analyzer*) project="QC" ;;
    */axia-seekapa-cs-agents*) project="CS-Agents" ;;
    */seekapa-training*) project="Training" ;;
    */seekapa-compliance*) project="Compliance" ;;
    */phone-spam*) project="SpamChk" ;;
    */khaleeji*) project="Khaleeji" ;;
esac

# Build status line
if [ -n "$project" ]; then
    printf "%s%s | v8.0" "$project" "$git_info"
else
    printf "%s%s | v8.0" "$dir_name" "$git_info"
fi
