#!/usr/bin/env -S zsh -euo pipefail
echo "=== BEFORE zparseopts ==="
typeset -p | grep -E "^(typeset|local)" | wc -l
source /Users/zakkhoyt/.zsh_home/utilities/.zsh_zparseopts
echo "=== AFTER zparseopts ==="
typeset -p | grep "flag_" || echo "No flag_ variables"
typeset -p | grep "zparse" | head -5
