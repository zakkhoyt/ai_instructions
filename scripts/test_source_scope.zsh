#!/usr/bin/env -S zsh -euo pipefail
# Test if sourcing creates isolation
typeset flag_debug=""
echo "Before sourcing zparseopts, args: $@"
source /Users/zakkhoyt/.zsh_home/utilities/.zsh_zparseopts
echo "After sourcing zparseopts"
echo "flag_debug: [${flag_debug:-UNSET}]"
echo "Remaining args: $@"
