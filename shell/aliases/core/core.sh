# Core bash behavior

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# lesspipe (make less nicer for binaries)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

# Environment Modules is optional; site-specific module paths belong in ~/.bashrc.
if [[ -r /etc/profile.d/modules.sh ]]; then
  source /etc/profile.d/modules.sh
fi

# Destructive convenience helpers must be deliberate and interactive.
_engprod_confirm() {
  [[ -t 0 ]] || { echo "Confirmation requires an interactive terminal." >&2; return 1; }
  local answer
  printf '%s [y/N] ' "$*"
  read -r answer || return 1
  [[ "$answer" = y || "$answer" = Y ]]
}
