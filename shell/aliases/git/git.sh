unalias gpf guncommit-hard gclean gbclean 2>/dev/null || true
# Git aliases and helpers

# Basic git shortcuts
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gl='git log'
alias gla='git log --all --graph --decorate --oneline'
alias glp='git log --pretty=format:"%h - %an, %ar : %s"'
alias gp='git push'
gpf() { _engprod_confirm "Force-with-lease push to the remote?" && git push --force-with-lease "$@"; }
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gr='git rebase'
alias gri='git rebase -i'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias gs='git status'
alias gss='git status --short'
alias gsb='git status -sb'
alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gsw='git switch'
alias gswc='git switch -c'
alias gbr='git branch --show-current'
alias gremote='git remote -v'
alias gball='git branch -a'
alias gblame='git blame'
alias gcount='git rev-list --count HEAD'
alias glast='git log -1 --stat'
alias guncommit='git reset --soft HEAD~1'
guncommit-hard() { _engprod_confirm "Discard local changes and the last commit?" && git reset --hard HEAD~1; }
alias gclean-dry='git clean -n'
gclean() { git clean -nd && _engprod_confirm "Delete the untracked files shown above?" && git clean -fd; }
gbclean() { git branch --merged; echo "Review and delete individual branches according to repository policy."; }

# Create branch and push upstream
gcbp() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcbp <branch-name>"
    return 1
  fi
  git checkout -b "$1" && git push -u origin "$1"
}

# Quick commit all changes with message
gcam() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcam <commit-message>"
    return 1
  fi
  git add --all && git commit -m "$1"
}

# Quick commit all, push
gcamp() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcamp <commit-message>"
    return 1
  fi
  git add --all && git commit -m "$1" && git push
}

# Show what changed in a file
gwhat() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gwhat <file>"
    return 1
  fi
  git log -p --follow -- "$1"
}

# Show file history
ghist() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: ghist <file>"
    return 1
  fi
  git log --follow --pretty=format:"%h - %an, %ar : %s" -- "$1"
}

# Interactive rebase from a specific commit
grih() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: grih <commit-hash>"
    return 1
  fi
  git rebase -i "$1"
}

# Update and rebase current branch
gup() {
  local branch=$(git branch --show-current)
  git fetch origin "$branch" && git rebase "origin/$branch"
}

# Legacy alias for backward compatibility
alias gitnewbranch='gcbp'

# Git bundle — offline transport of repo history
alias gbun='git bundle'
alias gbun-v='git bundle verify'
alias gbun-l='git bundle list-heads'

# Create a full bundle of all refs (default name: <repo>.bundle)
gbun-create() {
    local name="${1:-$(basename "$(git rev-parse --show-toplevel)").bundle}"
    git bundle create "$name" --all && echo "Created: $name"
}

# Create an incremental bundle from a base ref to HEAD
# Usage: gbun-inc <since-ref> [outfile]   e.g. gbun-inc HEAD~20
gbun-inc() {
    if [[ -z "${1:-}" ]]; then
        echo "Usage: gbun-inc <since-ref> [outfile]"
        return 1
    fi
    local since="$1"
    local name="${2:-incremental.bundle}"
    git bundle create "$name" "${since}..HEAD" && echo "Created: $name"
}

# Fetch from a bundle into the current repo
# Usage: gbun-apply <bundle-file>
gbun-apply() {
    if [[ -z "${1:-}" ]]; then
        echo "Usage: gbun-apply <bundle-file>"
        return 1
    fi
    git fetch "$1"
}

# Re-sync global git hooks from the engineering-productivity repo
hooks-install-global() {
    local repo="${ENGPROD_DIR:-$HOME/engineering-productivity}"
    bash "$repo/git/hooks/install-global.sh"
}
