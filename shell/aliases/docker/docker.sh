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
  if [[ -z "${1:-}" ]]; then
    echo "Usage: drmf <container-name-or-id>"
    return 1
  fi
  docker stop "$1" && docker rm "$1"
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
