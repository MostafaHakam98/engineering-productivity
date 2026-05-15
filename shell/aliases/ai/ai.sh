#!/bin/bash
# AI Engineering aliases — Claude Code and AI tooling shortcuts
#
# Set ENGPROD_DIR to override the default repo location:
#   export ENGPROD_DIR="$HOME/code/engineering-productivity"

# Install personal global Claude config to ~/.claude/
claude-install-global() {
    local repo="${ENGPROD_DIR:-$HOME/Desktop/Personal/engineering-productivity}"
    bash "$repo/ai/claude/scripts/install-global.sh"
}

# Install project Claude template into current directory's .claude/
claude-install-project() {
    local repo="${ENGPROD_DIR:-$HOME/Desktop/Personal/engineering-productivity}"
    bash "$repo/ai/claude/scripts/install-project.sh"
}

# Sync shared Claude template files into current project (non-destructive)
claude-sync-project() {
    local repo="${ENGPROD_DIR:-$HOME/Desktop/Personal/engineering-productivity}"
    bash "$repo/ai/claude/scripts/sync-project.sh"
}

# Navigate to personal Claude global config
alias cdclaudeconfig='cd "$HOME/.claude"'

# Print all available Claude Code commands and shell aliases
claude-help() {
    local B='\033[0;34m' G='\033[0;32m' Y='\033[1;33m' NC='\033[0m'
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${G}  Claude Code — Command Reference${NC}"
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${Y}Shell Functions${NC}"
    printf "  %-28s %s\n" "claude-install-global"  "Install global config to ~/.claude/"
    printf "  %-28s %s\n" "claude-install-project"  "Install project template into ./.claude/"
    printf "  %-28s %s\n" "claude-sync-project"     "Sync template updates (non-destructive)"
    printf "  %-28s %s\n" "cdclaudeconfig"          "cd to ~/.claude/"
    printf "  %-28s %s\n" "claude-help"             "Show this help"
    echo ""
    echo -e "${Y}Claude Code Slash Commands${NC}  (use inside \`claude\` session)"
    printf "  %-28s %s\n" "/review"      "Review current diff or MR"
    printf "  %-28s %s\n" "/debug"       "Debug a failing command or test"
    printf "  %-28s %s\n" "/plan"        "Plan a change before editing"
    printf "  %-28s %s\n" "/caveman"     "Reduce task to minimal observable facts"
    printf "  %-28s %s\n" "/ci-fix"      "Debug a CI/CD pipeline failure"
    printf "  %-28s %s\n" "/cmake-fix"   "Debug a CMake or native build failure"
    printf "  %-28s %s\n" "/repo-profile" "Profile repo and update .claude/ config"
    echo ""
    echo -e "${Y}Sub-Agents${NC}  (spawned automatically by skills)"
    printf "  %-28s %s\n" "build-doctor"    "CMake, CUDA, MPI, compiler, linker failures"
    printf "  %-28s %s\n" "code-reviewer"   "Diff and MR review"
    printf "  %-28s %s\n" "test-planner"    "Narrowest verification strategy for a change"
    echo ""
    echo -e "${B}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}
