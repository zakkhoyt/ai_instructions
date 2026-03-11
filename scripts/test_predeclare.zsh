#!/usr/bin/env -S zsh -euo pipefail
# DON'T pre-declare flag_debug
echo "Before sourcing zparseopts, args: $@"
source /Users/zakkhoyt/.zsh_home/utilities/.zsh_zparseopts
echo "After sourcing zparseopts"
typeset -p | grep flag_debug || echo "No flag_debug variable found"
