# Atuin shell history

# If you installed atuin with its env script:
[[ -r "$HOME/.atuin/bin/env" ]] && source "$HOME/.atuin/bin/env"

# bash-preexec (only if you need it for your setup)
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh

# IMPORTANT: only init once
if command -v atuin >/dev/null 2>&1 && [[ -z "${_ENGPROD_ATUIN_INIT:-}" ]]; then
  eval "$(atuin init bash)"
  _ENGPROD_ATUIN_INIT=1
fi
true
