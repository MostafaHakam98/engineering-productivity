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
  dir="$(find . -type d -not -path '*/\.git/*' 2>/dev/null | \
    fzf --height 60% --layout=reverse \
      --prompt='cd> ' \
      --preview 'ls -lah {} 2>/dev/null | head -20')" || return
  [[ -n "$dir" ]] && cd "$dir" && pwd
}
alias cdf='fcd'

# File editing with bat preview
fe() {
  local file
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    file="$(fzf --height 70% --layout=reverse \
      --prompt='edit> ' \
      --preview "$bat_cmd --style=numbers --color=always --line-range :200 {}" \
      --preview-window=right:60%:wrap)" || return
  else
    file="$(fzf --height 70% --layout=reverse \
      --prompt='edit> ' \
      --preview 'cat {} | head -200' \
      --preview-window=right:60%:wrap)" || return
  fi
  [[ -n "$file" ]] && "${EDITOR:-vim}" "$file"
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

# File browsing and previewing
# List files and preview with cat/bat
fls() {
  local file
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    file="$(ls -la | fzf --height 80% --layout=reverse --header-lines=1 \
      --prompt='file> ' \
      --preview "$bat_cmd --style=numbers --color=always --line-range :200 {9..} 2>/dev/null || $bat_cmd --style=numbers --color=always --line-range :200 {} 2>/dev/null" \
      --preview-window=right:60%:wrap \
    | awk '{for(i=9;i<=NF;i++) printf "%s ", $i; print ""}')" || return
  else
    file="$(ls -la | fzf --height 80% --layout=reverse --header-lines=1 \
      --prompt='file> ' \
      --preview 'cat {9..} 2>/dev/null || cat {} 2>/dev/null | head -200' \
      --preview-window=right:60%:wrap \
    | awk '{for(i=9;i<=NF;i++) printf "%s ", $i; print ""}')" || return
  fi
  [[ -n "$file" ]] && printf '%s\n' "$file"
}

# Browse files in current directory with preview
fcat() {
  local file
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    file="$(find . -type f -not -path '*/\.git/*' 2>/dev/null | \
      fzf --height 80% --layout=reverse \
        --prompt='preview> ' \
        --preview "$bat_cmd --style=numbers --color=always --line-range :200 {}" \
        --preview-window=right:60%:wrap)" || return
  else
    file="$(find . -type f -not -path '*/\.git/*' 2>/dev/null | \
      fzf --height 80% --layout=reverse \
        --prompt='preview> ' \
        --preview 'cat {} | head -200' \
        --preview-window=right:60%:wrap)" || return
  fi
  [[ -n "$file" ]] && printf '%s\n' "$file"
}

# Browse and edit files
fvim() {
  local file
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    file="$(find . -type f -not -path '*/\.git/*' 2>/dev/null | \
      fzf --height 80% --layout=reverse \
        --prompt='edit> ' \
        --preview "$bat_cmd --style=numbers --color=always --line-range :200 {}" \
        --preview-window=right:60%:wrap)" || return
  else
    file="$(find . -type f -not -path '*/\.git/*' 2>/dev/null | \
      fzf --height 80% --layout=reverse \
        --prompt='edit> ' \
        --preview 'cat {} | head -200' \
        --preview-window=right:60%:wrap)" || return
  fi
  [[ -n "$file" ]] && "${EDITOR:-vim}" "$file"
}


# Browse files and show full content with bat
fbat() {
  local file
  file="$(find . -type f -not -path '*/\.git/*' 2>/dev/null | \
    fzf --height 80% --layout=reverse \
      --prompt='view> ' \
      --preview 'bat --style=numbers --color=always --line-range :200 {} 2>/dev/null || batcat --style=numbers --color=always --line-range :200 {} 2>/dev/null || cat {} | head -200' \
      --preview-window=right:60%:wrap)" || return
  
  if [[ -n "$file" ]]; then
    if command -v bat >/dev/null 2>&1; then
      bat --style=numbers --color=always --paging=always "$file"
    elif command -v batcat >/dev/null 2>&1; then
      batcat --style=numbers --color=always --paging=always "$file"
    else
      less "$file"
    fi
  fi
}

# Browse files and grep content
fgrep() {
  local file
  local pattern="${1:-}"
  
  if [[ -z "$pattern" ]]; then
    read -p "Search pattern: " pattern
    [[ -z "$pattern" ]] && return
  fi
  
  file="$(grep -rl "$pattern" . 2>/dev/null | \
    fzf --height 80% --layout=reverse \
      --prompt="grep '$pattern'> " \
      --preview "grep -n --color=always '$pattern' {} | head -50" \
      --preview-window=right:60%:wrap)" || return
  
  if [[ -n "$file" ]]; then
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
      local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
      grep -n --color=always "$pattern" "$file" | "$bat_cmd" --style=numbers --color=always -l bash
    else
      grep -n --color=always "$pattern" "$file" | less -R
    fi
  fi
}

# Browse and preview JSON files with jq
fjq() {
  local file
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for fjq"
    return 1
  fi
  
  file="$(find . -type f \( -name "*.json" -o -name "*.jsonl" \) -not -path '*/\.git/*' 2>/dev/null | \
    fzf --height 80% --layout=reverse \
      --prompt='json> ' \
      --preview 'jq . {} 2>/dev/null | head -200 || echo "Invalid JSON"' \
      --preview-window=right:60%:wrap)" || return
  
  if [[ -n "$file" ]]; then
    if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
      local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
      jq . "$file" | "$bat_cmd" --style=numbers --color=always -l json
    else
      jq . "$file" | less -R
    fi
  fi
}

# Browse recent files
frecent() {
  local file
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    file="$(find . -type f -mtime -7 -not -path '*/\.git/*' 2>/dev/null | \
      fzf --height 80% --layout=reverse \
        --prompt='recent> ' \
        --preview "$bat_cmd --style=numbers --color=always --line-range :200 {}" \
        --preview-window=right:60%:wrap)" || return
  else
    file="$(find . -type f -mtime -7 -not -path '*/\.git/*' 2>/dev/null | \
      fzf --height 80% --layout=reverse \
        --prompt='recent> ' \
        --preview 'cat {} | head -200' \
        --preview-window=right:60%:wrap)" || return
  fi
  [[ -n "$file" ]] && printf '%s\n' "$file"
}

# Browse and delete files (with confirmation)
frm() {
  local file
  file="$(find . -type f -not -path '*/\.git/*' 2>/dev/null | \
    fzf --height 80% --layout=reverse \
      --prompt='delete> ' \
      --preview 'cat {} | head -50' \
      --preview-window=right:60%:wrap)" || return
  
  if [[ -n "$file" ]]; then
    read -p "Delete '$file'? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm "$file" && echo "✅ Deleted: $file"
    fi
  fi
}
