# FZF configuration and helpers

# Use fd if available, fall back to find
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Preview files nicely with bat if available
if command -v batcat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'batcat --style=numbers --color=always --line-range :200 {}' --preview-window=right:60%:wrap"
elif command -v bat >/dev/null 2>&1; then
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :200 {}' --preview-window=right:60%:wrap"
else
  export FZF_CTRL_T_OPTS="--preview 'sed -n \"1,200p\" {}' --preview-window=right:60%:wrap"
fi

# Navigation
fcd() {
  local dir
  dir="$( (command -v fd >/dev/null 2>&1 && fd --type d --hidden --follow --exclude .git .) \
          || find . -type d -not -path "*/\.git/*" ) \
        | fzf --height 60% --layout=reverse --prompt='cd> ')" || return
  cd "$dir" || return
}
alias cdf='fcd'

# File editing
fe() {
  local file
  file="$(fzf --height 70% --layout=reverse --prompt='edit> ' $FZF_CTRL_T_OPTS)" || return
  "${EDITOR:-nano}" "$file"
}

# Process management
fkill() {
  local pid
  pid="$(ps -ef | sed 1d | fzf --height 70% --layout=reverse --prompt='kill> ' \
        --preview 'echo {}' | awk '{print $2}')" || return
  kill -9 "$pid"
}

# History search
fh() {
  local cmd
  cmd="$(history | sed 's/ *[0-9]\+ *//' | fzf --height 70% --layout=reverse --prompt='history> ' --tac)" || return
  printf '%s\n' "$cmd"
}

# Git helpers
gcof() {
  local b
  b="$(git branch --all --format='%(refname:short)' 2>/dev/null \
      | sed 's#^remotes/##' | sort -u \
      | fzf --height 60% --layout=reverse --prompt='branch> ')" || return
  git checkout "${b#origin/}"
}

gshowf() {
  git log --oneline --decorate --graph --color=always \
    | fzf --height 80% --layout=reverse --ansi --prompt='commit> ' \
      --preview 'echo {} | awk "{print \$2}" | xargs -I@ git show --color=always @ | sed -n "1,200p"' \
    | awk '{print $2}' | xargs -r git show
}

gstashf() {
  local s
  s="$(git stash list | fzf --height 60% --layout=reverse --prompt='stash> ')" || return
  git stash apply "$(echo "$s" | cut -d: -f1)"
}

# Docker helpers
dexecf() {
  local c
  c="$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --prompt='container> ' \
      --preview 'echo {}' | awk '{print $1}')" || return
  docker exec -it "$c" bash 2>/dev/null || docker exec -it "$c" sh
}

dlogsf() {
  local c
  c="$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --prompt='logs> ' | awk '{print $1}')" || return
  docker logs -f "$c"
}
