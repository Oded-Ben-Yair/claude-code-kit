#!/usr/bin/env bash
set -euo pipefail

# tmux-parallel.sh — Manage parallel Claude Code sessions via tmux
#
# Creates predefined tmux layouts for workflows that benefit from
# visible parallel execution: long-running evals, multi-model judging,
# cross-project work, and generic worker pools.

SHARED_DIR="$HOME/.claude/tmux-shared"
PREFIX="cc"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

info()  { echo -e "${GREEN}[tmux-parallel]${NC} $*"; }
warn()  { echo -e "${YELLOW}[tmux-parallel]${NC} $*"; }
err()   { echo -e "${RED}[tmux-parallel]${NC} $*" >&2; }

session_exists() { tmux has-session -t "$1" 2>/dev/null; }

ensure_shared() {
    local session="$1"
    mkdir -p "$SHARED_DIR/$session"
}

attach_or_warn() {
    local session="$1"
    if [[ -n "${TMUX:-}" ]]; then
        warn "Already inside tmux. Switch with: tmux switch-client -t $session"
        warn "Or detach first (Ctrl+B d), then: tmux attach -t $session"
    else
        tmux attach-session -t "$session"
    fi
}

# ─── LAYOUTS ───────────────────────────────────────────────────────

layout_eval() {
    local dir="${1:-$(pwd)}"
    local session="${PREFIX}-eval"

    if session_exists "$session"; then
        warn "Session '$session' exists. Attaching..."
        attach_or_warn "$session"
        return
    fi

    ensure_shared "$session"

    # ┌──────────────────────────┐
    # │      Pane 0: main        │  ← Interactive claude (70%)
    # │      (development)       │
    # ├─────────────┬────────────┤
    # │ Pane 1:     │ Pane 2:    │  ← Eval + Monitor (30%)
    # │ eval-runner │ monitor    │
    # └─────────────┴────────────┘

    # -x/-y set size for detached sessions; -l uses absolute sizes (tmux 3.4 compat)
    tmux new-session -d -s "$session" -c "$dir" -x 200 -y 50
    tmux split-window -v -t "$session:0" -c "$dir" -l 15
    tmux split-window -h -t "$session:0.1" -c "$dir" -l 100

    # Pane 0: main dev session
    tmux send-keys -t "$session:0.0" "claude" Enter

    # Pane 1: eval runner (ready, user starts manually)
    tmux send-keys -t "$session:0.1" \
        "echo '# Eval pane — start your eval here'" Enter
    tmux send-keys -t "$session:0.1" \
        "echo '# Example: python3 tests/evaluation/run_live_eval.py --round r99'" Enter

    # Pane 2: monitor
    tmux send-keys -t "$session:0.2" \
        "echo '# Monitor — tail outputs or watch deploys'" Enter
    tmux send-keys -t "$session:0.2" \
        "echo '# Example: tail -f $SHARED_DIR/$session/*.md'" Enter

    tmux select-pane -t "$session:0.0"

    info "Layout 'eval' ready: main + eval-runner + monitor"
    info "Shared dir: $SHARED_DIR/$session/"
    attach_or_warn "$session"
}

layout_multi_judge() {
    local dir="${1:-$(pwd)}"
    local session="${PREFIX}-judge"

    if session_exists "$session"; then
        warn "Session '$session' exists. Attaching..."
        attach_or_warn "$session"
        return
    fi

    ensure_shared "$session"

    # ┌───────────┬───────────┐
    # │ Pane 0:   │ Pane 1:   │
    # │ main      │ judge-A   │
    # ├───────────┼───────────┤
    # │ Pane 2:   │ Pane 3:   │
    # │ judge-B   │ judge-C   │
    # └───────────┴───────────┘

    tmux new-session -d -s "$session" -c "$dir" -x 200 -y 50
    tmux split-window -h -t "$session:0" -c "$dir" -l 100
    tmux split-window -v -t "$session:0.0" -c "$dir" -l 25
    tmux split-window -v -t "$session:0.2" -c "$dir" -l 25

    tmux send-keys -t "$session:0.0" "claude" Enter

    local models=("gemini" "gpt" "grok")
    for i in 0 1 2; do
        local pane=$((i + 1))
        local m="${models[$i]}"
        tmux send-keys -t "$session:0.$pane" \
            "echo '# Judge: $m — use claude -p to score'" Enter
        tmux send-keys -t "$session:0.$pane" \
            "echo '# Output: $SHARED_DIR/$session/judge-${m}.md'" Enter
    done

    tmux select-pane -t "$session:0.0"

    info "Layout 'multi-judge' ready: main + 3 judge panes (gemini/gpt/grok)"
    info "Shared dir: $SHARED_DIR/$session/"
    attach_or_warn "$session"
}

layout_dev_monitor() {
    local dir="${1:-$(pwd)}"
    local session="${PREFIX}-dev"

    if session_exists "$session"; then
        warn "Session '$session' exists. Attaching..."
        attach_or_warn "$session"
        return
    fi

    ensure_shared "$session"

    # ┌──────────────────────────┐
    # │      Pane 0: main        │  ← Interactive claude (80%)
    # ├──────────────────────────┤
    # │ Pane 1: monitor          │  ← Logs/output (20%)
    # └──────────────────────────┘

    tmux new-session -d -s "$session" -c "$dir" -x 200 -y 50
    tmux split-window -v -t "$session:0" -c "$dir" -l 10

    tmux send-keys -t "$session:0.0" "claude" Enter
    tmux send-keys -t "$session:0.1" \
        "echo '# Monitor: tail -f logs, watch deploy status, etc.'" Enter

    tmux select-pane -t "$session:0.0"

    info "Layout 'dev-monitor' ready: main + monitor"
    attach_or_warn "$session"
}

layout_cross_project() {
    local dir_a="${1:-$HOME/projects}"
    local dir_b="${2:-$HOME/projects}"
    local session="${PREFIX}-multi"

    if session_exists "$session"; then
        warn "Session '$session' exists. Attaching..."
        attach_or_warn "$session"
        return
    fi

    ensure_shared "$session"

    # ┌───────────┬───────────┐
    # │ Pane 0:   │ Pane 1:   │
    # │ Project A │ Project B │
    # └───────────┴───────────┘

    tmux new-session -d -s "$session" -c "$dir_a" -x 200 -y 50
    tmux split-window -h -t "$session:0" -c "$dir_b" -l 100

    tmux send-keys -t "$session:0.0" \
        "echo '# Project A ($dir_a) — run: claude'" Enter
    tmux send-keys -t "$session:0.1" \
        "echo '# Project B ($dir_b) — run: claude'" Enter

    tmux select-pane -t "$session:0.0"

    info "Layout 'cross-project' ready: $(basename "$dir_a") | $(basename "$dir_b")"
    attach_or_warn "$session"
}

layout_worker() {
    local dir="${1:-$(pwd)}"
    local n="${2:-2}"
    local session="${PREFIX}-worker"

    if session_exists "$session"; then
        warn "Session '$session' exists. Attaching..."
        attach_or_warn "$session"
        return
    fi

    ensure_shared "$session"

    tmux new-session -d -s "$session" -c "$dir" -x 200 -y 50
    for ((i=1; i<=n; i++)); do
        tmux split-window -v -t "$session:0" -c "$dir" -l 15
    done
    tmux select-layout -t "$session:0" tiled

    tmux send-keys -t "$session:0.0" "claude" Enter
    for ((i=1; i<=n; i++)); do
        tmux send-keys -t "$session:0.$i" \
            "echo '# Worker $i — use: claude -p \"prompt\" > output.md'" Enter
    done

    tmux select-pane -t "$session:0.0"

    info "Layout 'worker' ready: main + $n workers"
    info "Shared dir: $SHARED_DIR/$session/"
    attach_or_warn "$session"
}

# ─── COMMANDS ──────────────────────────────────────────────────────

cmd_start() {
    local layout="${1:-}"
    shift || true

    case "$layout" in
        eval)           layout_eval "$@" ;;
        multi-judge)    layout_multi_judge "$@" ;;
        dev-monitor)    layout_dev_monitor "$@" ;;
        cross-project)  layout_cross_project "$@" ;;
        worker)         layout_worker "$@" ;;
        "")
            err "Missing layout name."
            echo "Layouts: eval, multi-judge, dev-monitor, cross-project, worker"
            exit 1 ;;
        *)
            err "Unknown layout: $layout"
            echo "Layouts: eval, multi-judge, dev-monitor, cross-project, worker"
            exit 1 ;;
    esac
}

cmd_stop() {
    local target="${1:-all}"

    if [[ "$target" == "all" ]]; then
        local sessions
        sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
            | grep "^${PREFIX}-" || true)
        if [[ -z "$sessions" ]]; then
            info "No active parallel sessions."
            return
        fi
        while read -r s; do
            tmux kill-session -t "$s"
            info "Stopped: $s"
        done <<< "$sessions"
    else
        # Try exact name, then with prefix
        local name="$target"
        if ! session_exists "$name"; then
            name="${PREFIX}-${target}"
        fi
        if session_exists "$name"; then
            tmux kill-session -t "$name"
            info "Stopped: $name"
        else
            err "Session not found: $target"
            exit 1
        fi
    fi
}

cmd_send() {
    if [[ $# -lt 2 ]]; then
        err "Usage: tmux-parallel.sh send <session:pane> \"prompt\" [output-file]"
        exit 1
    fi

    local target="$1" prompt="$2" output="${3:-}"

    local session="${target%%:*}"
    local pane="${target##*:}"

    # Resolve session name
    if ! session_exists "$session"; then
        session="${PREFIX}-${session}"
    fi
    if ! session_exists "$session"; then
        err "Session not found: ${target%%:*}"
        exit 1
    fi

    # Default output path
    if [[ -z "$output" ]]; then
        ensure_shared "$session"
        output="$SHARED_DIR/$session/task-pane${pane}-$(date +%H%M%S).md"
    fi

    # Escape prompt for shell
    local escaped_prompt
    escaped_prompt=$(printf '%q' "$prompt")

    tmux send-keys -t "$session:0.$pane" \
        "claude -p $escaped_prompt > $output 2>&1 && echo '--- DONE ---'" Enter

    info "Task sent to $session:pane$pane → $output"
}

cmd_list() {
    local sessions
    sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
        | grep "^${PREFIX}-" || true)

    if [[ -z "$sessions" ]]; then
        info "No active parallel sessions."
        return
    fi

    echo -e "${CYAN}Active parallel sessions:${NC}"
    echo ""

    while read -r s; do
        local attached
        attached=$(tmux list-sessions -F '#{session_name} #{session_attached}' \
            | grep "^$s " | awk '{print $2}')
        local status="detached"
        [[ "$attached" -gt 0 ]] && status="${GREEN}attached${NC}"

        echo -e "  ${BLUE}$s${NC} ($status)"
        tmux list-panes -t "$s" \
            -F "    pane #{pane_index}: #{pane_current_command} [#{pane_width}x#{pane_height}]" \
            2>/dev/null
        echo ""
    done <<< "$sessions"

    # Show shared output files
    echo -e "${CYAN}Shared outputs:${NC}"
    local found=0
    while read -r s; do
        local dir="$SHARED_DIR/$s"
        if [[ -d "$dir" ]] && ls "$dir"/*.md &>/dev/null 2>&1; then
            echo -e "  ${BLUE}$dir/${NC}"
            ls -lt "$dir"/*.md 2>/dev/null | head -5 | awk '{print "    " $6, $7, $8, $9}'
            found=1
        fi
    done <<< "$sessions"
    [[ "$found" -eq 0 ]] && echo "  (none yet)"
}

cmd_monitor() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        err "Usage: tmux-parallel.sh monitor <session-name>"
        exit 1
    fi

    local session="$target"
    [[ "$session" != ${PREFIX}-* ]] && session="${PREFIX}-${session}"

    local dir="$SHARED_DIR/$session"
    mkdir -p "$dir"

    info "Monitoring $dir/ (Ctrl+C to stop)"

    # Use watch as universal fallback (inotifywait not always available)
    watch -n 3 -t "echo '=== tmux-parallel monitor: $session ===' && echo '' && \
        for f in $dir/*.md; do \
            [ -f \"\$f\" ] && echo \"--- \$(basename \$f) (\$(stat -c%y \$f 2>/dev/null | cut -d. -f1)) ---\" && tail -8 \"\$f\" && echo ''; \
        done; \
        [ ! -f $dir/*.md ] 2>/dev/null && echo '(no output files yet)'"
}

show_help() {
    cat <<'HELP'
tmux-parallel — Parallel Claude Code sessions via tmux

USAGE
  tmux-parallel.sh <command> [args]

COMMANDS
  start <layout> [dir]        Create session with predefined layout
  stop [session|all]          Stop session(s) (default: all cc-*)
  send <session:pane> "prompt" Send claude -p task to worker pane
  list                        List active sessions with pane details
  monitor <session>           Watch shared output directory
  help                        Show this help

LAYOUTS
  eval [dir]                  Main + eval-runner + monitor
  multi-judge [dir]           Main + 3 judge panes (gemini/gpt/grok)
  dev-monitor [dir]           Main + output/log monitor
  cross-project [dir-a] [dir-b]  2 side-by-side project panes
  worker [dir] [count]        Main + N worker panes (default: 2)

EXAMPLES
  tmux-parallel.sh start eval ~/projects/hey-seven
  tmux-parallel.sh start cross-project ~/projects/hey-seven ~/projects/sentimark
  tmux-parallel.sh send judge:1 "Score scenarios with gemini"
  tmux-parallel.sh stop eval
  tmux-parallel.sh list

TMUX SHORTCUTS (inside session)
  Ctrl+B arrow     Navigate between panes
  Ctrl+B z         Toggle pane fullscreen
  Ctrl+B d         Detach (session stays alive)
  Ctrl+B [         Scroll mode (q to exit)

SHARED OUTPUT
  ~/.claude/tmux-shared/<session-name>/
  Worker panes write here. Main session reads results.

REATTACH
  tmux attach -t cc-eval      (after detach or new terminal)
HELP
}

# ─── MAIN ──────────────────────────────────────────────────────────

main() {
    local cmd="${1:-help}"
    shift || true

    case "$cmd" in
        start)          cmd_start "$@" ;;
        stop)           cmd_stop "$@" ;;
        send)           cmd_send "$@" ;;
        list)           cmd_list "$@" ;;
        monitor)        cmd_monitor "$@" ;;
        help|-h|--help) show_help ;;
        *)
            err "Unknown command: $cmd"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
