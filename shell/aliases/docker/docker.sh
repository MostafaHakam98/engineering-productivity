#!/bin/bash
# Docker aliases and helpers

# Basic docker shortcuts
alias d='docker'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dstop='docker stop'
alias dstart='docker start'
alias drm='docker rm'
alias drmi='docker rmi'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dtop='docker top'

# Docker compose shortcuts
alias dc='docker compose'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'
alias dcp='docker compose ps'
alias dcb='docker compose build'
alias dcrb='docker compose up --build'
alias dce='docker compose exec'
alias dcr='docker compose run'
alias dcre='docker compose restart'
alias dcstop='docker compose stop'
alias dcstart='docker compose start'
alias dcl='docker compose logs'
alias dclf='docker compose logs -f'

# Docker system management
alias dsys='docker system'
alias dsysdf='docker system df'
alias dsysprune='docker system prune'
alias dsysprunea='docker system prune -a'
alias dvol='docker volume'
alias dvols='docker volume ls'
alias dnet='docker network'
alias dnets='docker network ls'
alias drmia='docker rmi $(docker images -q)'

# Container operations
dbash() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dbash <container-name-or-id>"
    return 1
  fi
  docker exec -it "$1" /bin/bash
}

dsh() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dsh <container-name-or-id>"
    return 1
  fi
  docker exec -it "$1" /bin/sh
}

drmf() {
  # If no argument and fzf available, use interactive selection
  if [[ -z "${1:-}" ]] && command -v fzf >/dev/null 2>&1; then
    local container
    container="$(docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
      | fzf --height 60% --layout=reverse --header-lines=1 \
        --prompt='Select container to delete> ' \
      | awk '{print $1}')" || return
    [[ -z "$container" ]] && return
    read -p "Delete container '$container'? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && docker stop "$container" 2>/dev/null && docker rm "$container" && echo "✅ Deleted: $container"
  elif [[ -n "${1:-}" ]]; then
    # Original behavior: stop and remove specified container
    docker stop "$1" && docker rm "$1"
  else
    echo "Usage: drmf [container-name-or-id]"
    echo "  With argument: stop and remove specified container"
    echo "  Without argument (requires fzf): interactive selection"
    return 1
  fi
}

dstopall() {
  docker stop $(docker ps -q)
}

drmall() {
  docker rm $(docker ps -aq)
}

drmfall() {
  docker rm -f $(docker ps -aq)
}

dclean() {
  echo "Cleaning up Docker resources..."
  docker system prune -a --volumes -f
}

dstats() {
  if [[ -z "${1:-}" ]]; then
    docker stats --no-stream
  else
    docker stats --no-stream "$1"
  fi
}

# Docker compose operations
dcex() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dcex <service-name> [command]"
    echo "Example: dcex web bash"
    return 1
  fi
  local service="$1"
  shift
  if [[ -z "${*:-}" ]]; then
    docker compose exec "$service" /bin/bash || docker compose exec "$service" /bin/sh
  else
    docker compose exec "$service" "$@"
  fi
}

dcrun() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dcrun <service-name> <command>"
    echo "Example: dcrun web python manage.py migrate"
    return 1
  fi
  local service="$1"
  shift
  docker compose run --rm "$service" "$@"
}

dclog() {
  if [[ -z "${1:-}" ]]; then
    docker compose logs
  else
    docker compose logs -f "$1"
  fi
}

dcbuild() {
  docker compose build "$@" && docker compose up -d "$@"
}

dcrestart() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dcrestart <service-name>"
    return 1
  fi
  docker compose restart "$1"
}

dcstatus() {
  docker compose ps
}

dcpullup() {
  docker compose pull && docker compose up -d
}

dcconfig() {
  docker compose config
}

dcvalidate() {
  docker compose config --quiet
}

# System utilities
dusage() {
  echo "=== Docker Disk Usage ==="
  docker system df -v
}

dnetls() {
  docker network ls
}

dnetinspect() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dnetinspect <network-name>"
    return 1
  fi
  docker network inspect "$1"
}

dvollist() {
  docker volume ls
}

dvolinspect() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dvolinspect <volume-name>"
    return 1
  fi
  docker volume inspect "$1"
}

dvolprune() {
  docker volume prune -f
}

dip() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: dip <container-name-or-id>"
    return 1
  fi
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

dcpfrom() {
  if [[ -z "${2:-}" ]]; then
    echo "Usage: dcpfrom <container> <container-path> [host-path]"
    echo "Example: dcpfrom mycontainer /app/file.txt ./"
    return 1
  fi
  docker cp "$1:$2" "${3:-.}"
}

dcpto() {
  if [[ -z "${3:-}" ]]; then
    echo "Usage: dcpto <host-path> <container> <container-path>"
    echo "Example: dcpto ./file.txt mycontainer /app/"
    return 1
  fi
  docker cp "$1" "$2:$3"
}

# FZF-based Docker helpers (requires fzf)
# These use container names for easier selection

# Select container and view logs with bat
dlogsf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dlogsf"
    return 1
  fi
  
  local container
  container="$(docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container for logs> ' \
      --preview 'echo {} | awk "{print \$1}" | xargs -I@ docker logs --tail=50 @ 2>/dev/null' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  
  # Use bat if available, otherwise regular logs
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    docker logs -f "$container" 2>&1 | "$bat_cmd" --style=numbers --color=always --paging=never -l log
  else
    docker logs -f "$container"
  fi
}

# Select container and execute command
dexecf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dexecf"
    return 1
  fi
  
  local container
  container="$(docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container to exec> ' \
      --preview 'echo {} | awk "{print \$1}" | xargs -I@ docker inspect @ --format="{{.Config.Image}} - {{.State.Status}}" 2>/dev/null' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  
  # Try bash first, fallback to sh
  docker exec -it "$container" /bin/bash 2>/dev/null || docker exec -it "$container" /bin/sh
}


# Select container and stop
dstopf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dstopf"
    return 1
  fi
  
  local container
  container="$(docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container to stop> ' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  docker stop "$container" && echo "✅ Stopped: $container"
}

# Select container and start
dstartf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dstartf"
    return 1
  fi
  
  local container
  container="$(docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container to start> ' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  docker start "$container" && echo "✅ Started: $container"
}

# Select container and inspect (with jq if available)
dinspectf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dinspectf"
    return 1
  fi
  
  local container
  container="$(docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container to inspect> ' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  
  # Use jq if available for pretty JSON, otherwise raw inspect
  if command -v jq >/dev/null 2>&1; then
    docker inspect "$container" | jq .
  else
    docker inspect "$container"
  fi
}

# Select container and show stats
dstatsf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dstatsf"
    return 1
  fi
  
  local container
  container="$(docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container for stats> ' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  docker stats --no-stream "$container"
}

# Select container and copy file from
dcpfromf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dcpfromf"
    return 1
  fi
  
  local container
  container="$(docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container to copy from> ' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  
  read -p "Container path to copy: " container_path
  [[ -z "$container_path" ]] && return
  
  read -p "Host destination [./]: " host_path
  docker cp "$container:$container_path" "${host_path:-./}" && echo "✅ Copied from $container:$container_path"
}

# Select container and copy file to
dcptof() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dcptof"
    return 1
  fi
  
  local container
  container="$(docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select container to copy to> ' \
    | awk '{print $1}')" || return
  
  [[ -z "$container" ]] && return
  
  read -p "Host file path: " host_path
  [[ -z "$host_path" ]] || [[ ! -f "$host_path" ]] && echo "❌ File not found: $host_path" && return
  
  read -p "Container destination path: " container_path
  [[ -z "$container_path" ]] && return
  
  docker cp "$host_path" "$container:$container_path" && echo "✅ Copied to $container:$container_path"
}

# Select image and inspect (with jq if available)
diinspectf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for diinspectf"
    return 1
  fi
  
  local image
  image="$(docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select image to inspect> ' \
    | awk '{print $1":"$2}')" || return
  
  [[ -z "$image" ]] && return
  
  # Use jq if available
  if command -v jq >/dev/null 2>&1; then
    docker inspect "$image" | jq .
  else
    docker inspect "$image"
  fi
}

# Select image and delete
drmif() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for drmif"
    return 1
  fi
  
  local image
  image="$(docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' \
    | fzf --height 60% --layout=reverse --header-lines=1 \
      --prompt='Select image to delete> ' \
    | awk '{print $1":"$2}')" || return
  
  [[ -z "$image" ]] && return
  
  read -p "Delete image '$image'? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rmi "$image" && echo "✅ Deleted: $image"
  fi
}

# Docker Compose: Select service and view logs
dclogf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dclogf"
    return 1
  fi
  
  local service
  service="$(docker compose ps --format json 2>/dev/null | \
    jq -r '.[] | "\(.Name)\t\(.Service)\t\(.State)"' 2>/dev/null | \
    fzf --height 60% --layout=reverse \
      --prompt='Select service for logs> ' \
      --preview 'echo {} | awk "{print \$2}" | xargs -I@ docker compose logs --tail=50 @ 2>/dev/null' \
    | awk '{print $2}')" || return
  
  [[ -z "$service" ]] && return
  
  # Use bat if available
  if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    local bat_cmd="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
    docker compose logs -f "$service" 2>&1 | "$bat_cmd" --style=numbers --color=always --paging=never -l log
  else
    docker compose logs -f "$service"
  fi
}

# Docker Compose: Select service and exec
dcexf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for dcexf"
    return 1
  fi
  
  local service
  service="$(docker compose ps --format json 2>/dev/null | \
    jq -r '.[] | "\(.Name)\t\(.Service)\t\(.State)"' 2>/dev/null | \
    fzf --height 60% --layout=reverse \
      --prompt='Select service to exec> ' \
    | awk '{print $2}')" || return
  
  [[ -z "$service" ]] && return
  
  docker compose exec "$service" /bin/bash 2>/dev/null || docker compose exec "$service" /bin/sh
}
