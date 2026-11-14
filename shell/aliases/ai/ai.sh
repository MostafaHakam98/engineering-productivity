#!/bin/bash
# AI Engineering aliases — agent config and editor extension shortcuts
#
# One shared config in ai/shared/ is rendered into every agent's own dialect.
# Targets are declared in ai/targets/*.target — add a file, get a new agent.
#
# Set ENGPROD_DIR to override the default repo location:
#   export ENGPROD_DIR="$HOME/code/engineering-productivity"

_engprod_dir() {
    echo "${ENGPROD_DIR:-$HOME/engineering-productivity}"
}

# List the agent targets this kit can install into
ai-targets() {
    local repo; repo="$(_engprod_dir)"
    local t
    for t in "$repo"/ai/targets/*.target; do
        [ -f "$t" ] || continue
        printf "  %-12s %s\n" "$(basename "$t" .target)" \
            "$(sed -n 's/^TARGET_LABEL="\(.*\)"$/\1/p' "$t")"
    done
}

# Install the shared config into one agent, or all of them
#   ai-install claude | codex | cursor | metwally | all  [--dry-run]
ai-install() {
    local repo; repo="$(_engprod_dir)"
    if [ $# -eq 0 ]; then
        echo "usage: ai-install <target|all> [--dry-run]"; echo; ai-targets; return 1
    fi
    bash "$repo/ai/scripts/install-global.sh" "$@"
}

# Render a target to a temp directory without installing, to inspect or diff
ai-port() {
    local repo; repo="$(_engprod_dir)"
    if [ $# -eq 0 ]; then
        echo "usage: ai-port <target> [--out DIR]"; echo; ai-targets; return 1
    fi
    bash "$repo/ai/scripts/port.sh" "$@"
}

# Bootstrap a project template in the current directory, in a target's dialect
ai-install-project() {
    local repo; repo="$(_engprod_dir)"
    if [ $# -eq 0 ]; then
        echo "usage: ai-install-project <target> [--force]"; echo; ai-targets; return 1
    fi
    bash "$repo/ai/scripts/install-project.sh" "$@"
}

# Install the third-party skills declared in ai/shared/external-skills.json
ai-external-skills() {
    local repo; repo="$(_engprod_dir)"
    bash "$repo/ai/scripts/install-external-skills.sh" "$@"
}

# Build and install the editor extensions declared under extensions/
ext-install() {
    local repo; repo="$(_engprod_dir)"
    bash "$repo/extensions/install.sh" "$@"
}

# --- Claude-specific conveniences -------------------------------------------

claude-install-global()  { ai-install claude "$@"; }
claude-install-project() { ai-install-project claude "$@"; }
claude-sync-project()    { ai-install-project claude --force "$@"; }

alias cdclaudeconfig='cd "$HOME/.claude"'

# Print the AI kit command reference
ai-help() {
    local B='\033[0;34m' G='\033[0;32m' Y='\033[1;33m' NC='\033[0m'
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${G}  AI Agent Kit — Command Reference${NC}"
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${Y}Targets${NC}"
    ai-targets
    echo ""
    echo -e "${Y}Shell Functions${NC}"
    printf "  %-28s %s\n" "ai-install <target|all>"  "Install shared config into an agent"
    printf "  %-28s %s\n" "ai-port <target>"         "Render to a temp dir without installing"
    printf "  %-28s %s\n" "ai-install-project <t>"   "Bootstrap a project template here"
    printf "  %-28s %s\n" "ai-external-skills"       "Install declared third-party skills"
    printf "  %-28s %s\n" "ai-targets"               "List available agent targets"
    printf "  %-28s %s\n" "ext-install [name]"       "Build & install editor extensions"
    printf "  %-28s %s\n" "claude-install-global"    "Alias for: ai-install claude"
    printf "  %-28s %s\n" "claude-install-project"   "Bootstrap .claude/ in a project"
    printf "  %-28s %s\n" "cdclaudeconfig"           "cd to ~/.claude/"
    printf "  %-28s %s\n" "ai-help"                  "Show this help"
    echo ""
    echo -e "${Y}Slash Commands${NC}  (Claude: /name · Codex & Metwally: /name · Cursor: commands)"
    printf "  %-28s %s\n" "/review"       "Review current diff or MR"
    printf "  %-28s %s\n" "/debug"        "Debug a failing command or test"
    printf "  %-28s %s\n" "/plan"         "Plan a change before editing"
    printf "  %-28s %s\n" "/caveman"      "Reduce task to minimal observable facts"
    printf "  %-28s %s\n" "/ci-fix"       "Debug a CI/CD pipeline failure"
    printf "  %-28s %s\n" "/cmake-fix"    "Debug a CMake or native build failure"
    printf "  %-28s %s\n" "/repo-profile" "Profile repo and update project config"
    echo ""
    echo -e "${Y}Skills${NC}  (model-invoked when the task matches)"
    printf "  %-28s %s\n" "code-review"   "Diff, MR and PR review with tagged findings"
    printf "  %-28s %s\n" "debug"         "Failing command, test, build or pipeline"
    printf "  %-28s %s\n" "plan-change"   "Non-trivial edits and refactors"
    printf "  %-28s %s\n" "ci-fix"        "CI/CD pipeline debugging"
    printf "  %-28s %s\n" "cmake-fix"     "CMake, CUDA, MPI and native builds"
    printf "  %-28s %s\n" "checkpoint"    "Reconstruct every open thread of work"
    printf "  %-28s %s\n" "vibe-audit"    "Reverse-engineer and document a vibe-coded module"
    printf "  %-28s %s\n" "caveman"       "Collapse scope to observable facts"
    printf "  %-28s %s\n" "repo-profile"  "Generate project-specific agent config"
    echo ""
    echo -e "${Y}Sub-Agents${NC}  (Claude Code and Codex only)"
    printf "  %-28s %s\n" "build-doctor"  "CMake, CUDA, MPI, compiler, linker failures"
    printf "  %-28s %s\n" "code-reviewer" "Diff and MR review"
    printf "  %-28s %s\n" "test-planner"  "Narrowest verification strategy for a change"
    echo ""
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Retained: previously the only help entry point.
claude-help() { ai-help; }
