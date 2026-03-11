#!/usr/bin/env -S zsh -euo pipefail
# Trace what zparseopts actually does
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '
setopt xtrace
source /Users/zakkhoyt/.zsh_home/utilities/.zsh_zparseopts
unsetopt xtrace
echo "=== RESULT ==="
typeset -p | grep "flag_" 
