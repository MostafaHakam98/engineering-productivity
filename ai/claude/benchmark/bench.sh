#!/usr/bin/env bash
# Benchmark Claude Code variants on a task and compare token usage.
# Usage:
#   ./bench.sh "your task prompt"
#   ./bench.sh "your task prompt" debug        # also run /debug skill
#   ./bench.sh tasks/T1.txt                    # read task from file
#   ./bench.sh tasks/T1.txt review plan        # run skills too
#
# Output: token comparison table across default, /caveman, and any named skills.

set -euo pipefail

RESULTS_DIR="$(dirname "$0")/results"
mkdir -p "$RESULTS_DIR"

# ── helpers ───────────────────────────────────────────────────────────────────

die() { echo "ERROR: $*" >&2; exit 1; }

require() {
    command -v "$1" &>/dev/null || die "'$1' not found — install it first"
}

require claude
require jq

# ── args ──────────────────────────────────────────────────────────────────────

[[ $# -lt 1 ]] && { echo "Usage: $0 <task|task-file> [skill ...]"; exit 1; }

TASK_ARG="$1"; shift
EXTRA_SKILLS=("$@")

if [[ -f "$TASK_ARG" ]]; then
    TASK="$(cat "$TASK_ARG")"
    TASK_ID="$(basename "$TASK_ARG" .txt)"
else
    TASK="$TASK_ARG"
    TASK_ID="task_$(date +%s)"
fi

# caveman-raw: strip task to uppercase imperatives, no politeness
caveman_raw_prompt() {
    local task="$1"
    # uppercase, collapse whitespace, slap terse wrapper
    local core
    core=$(echo "$task" | tr '[:lower:]' '[:upper:]' | tr -s ' ' | sed 's/[.!?]*$//')
    echo "UGH. ${core}. DO NOW. NO EXPLAIN. JUST DO."
}

# variants: always run default, caveman, caveman-raw; add any extra skills passed as args
VARIANTS=("default" "caveman" "caveman-raw" "${EXTRA_SKILLS[@]}")

# ── run variants ──────────────────────────────────────────────────────────────

declare -A INPUT OUT CACHE_READ CACHE_CREATE COST_USD DURATION_MS

run_variant() {
    local variant="$1"
    local prompt

    case "$variant" in
        default)      prompt="$TASK" ;;
        caveman)      prompt="/caveman $TASK" ;;
        caveman-raw)  prompt="$(caveman_raw_prompt "$TASK")" ;;
        *)            prompt="/$variant $TASK" ;;
    esac

    local out_file="$RESULTS_DIR/${TASK_ID}_${variant}.json"

    echo -n "  running '$variant' ... "
    claude --output-format json --print -p "$prompt" \
        > "$out_file" 2>&1 \
        || { echo "FAILED (see $out_file)"; return 1; }
    echo "done"

    INPUT[$variant]=$(jq '.usage.input_tokens // 0'              "$out_file")
    OUT[$variant]=$(jq '.usage.output_tokens // 0'               "$out_file")
    CACHE_READ[$variant]=$(jq '.usage.cache_read_input_tokens // 0' "$out_file")
    CACHE_CREATE[$variant]=$(jq '.usage.cache_creation_input_tokens // 0' "$out_file")
    COST_USD[$variant]=$(jq '.total_cost_usd // 0'               "$out_file")
    DURATION_MS[$variant]=$(jq '.duration_ms // 0'               "$out_file")
}

echo ""
echo "Task: $TASK_ID"
echo "────────────────────────────────────────────────────────────────────────"

for v in "${VARIANTS[@]}"; do
    run_variant "$v" || true
done

# ── table ─────────────────────────────────────────────────────────────────────

printf "\n%-12s  %9s  %9s  %11s  %14s  %10s  %8s\n" \
    "variant" "in_tokens" "out_tokens" "cache_read" "cache_create" "cost_usd" "ms"
printf "%-12s  %9s  %9s  %11s  %14s  %10s  %8s\n" \
    "------------" "---------" "----------" "-----------" "------------" "----------" "--------"

for v in "${VARIANTS[@]}"; do
    [[ -z "${INPUT[$v]+x}" ]] && continue
    printf "%-12s  %9s  %9s  %11s  %14s  %10.6f  %8s\n" \
        "$v" \
        "${INPUT[$v]}" \
        "${OUT[$v]}" \
        "${CACHE_READ[$v]}" \
        "${CACHE_CREATE[$v]}" \
        "${COST_USD[$v]}" \
        "${DURATION_MS[$v]}"
done

# ── savings vs default ────────────────────────────────────────────────────────

echo ""
echo "Δ vs default (positive = cheaper/fewer than default):"
printf "%-14s  %13s  %13s  %13s  %12s\n" \
    "variant" "cache_read_Δ" "out_tokens_Δ" "total_ctx_Δ" "cost_usd_Δ"
printf "%-14s  %13s  %13s  %13s  %12s\n" \
    "--------------" "-------------" "-------------" "-------------" "------------"

BASE_OUT="${OUT[default]:-0}"
BASE_CACHE="${CACHE_READ[default]:-0}"
BASE_COST="${COST_USD[default]:-0}"

for v in "${VARIANTS[@]}"; do
    [[ "$v" == "default" ]] && continue
    [[ -z "${OUT[$v]+x}" ]] && continue
    DELTA_OUT=$(( BASE_OUT - OUT[$v] ))
    DELTA_CACHE=$(( BASE_CACHE - CACHE_READ[$v] ))
    DELTA_CTX=$(( (BASE_OUT + BASE_CACHE) - (OUT[$v] + CACHE_READ[$v]) ))
    DELTA_COST=$(echo "$BASE_COST - ${COST_USD[$v]}" | bc -l)
    printf "%-14s  %+13d  %+13d  %+13d  %+12.6f\n" \
        "$v" "$DELTA_CACHE" "$DELTA_OUT" "$DELTA_CTX" "$DELTA_COST"
done

echo ""
echo "Results saved to: $RESULTS_DIR/"
