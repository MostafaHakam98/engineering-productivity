#!/bin/bash
# General tool aliases

alias c='clear'
alias cls='clear'
alias mkdirp='mkdir -p'
alias rmf='rm -rf'

# Tool shortcuts
alias bat='batcat'
alias vpn='sudo openfortivpn'
alias pycharm='/opt/jetbrains/pycharm-*/bin/pycharm.sh'

# Long-running command notification
alert() {
  local icon
  if [ $? = 0 ]; then
    icon="terminal"
  else
    icon="error"
  fi
  local cmd=$(history | tail -n1 | sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')
  notify-send --urgency=low -i "$icon" "$cmd"
}

# Keep ~/.bash_aliases support if you still want it
if [[ -f ~/.bash_aliases ]]; then
  source ~/.bash_aliases
fi
