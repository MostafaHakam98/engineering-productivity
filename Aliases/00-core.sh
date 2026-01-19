# Core bash behavior

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

# lesspipe (make less nicer for binaries)
[[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

source /etc/profile.d/modules.sh
module use /.bs/libs/module
module use /opt/devstack/libs/modules
