#!/usr/bin/env -S zsh -euo pipefail
set -x  # Enable trace
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
set +x  # Disable trace
echo "===== AFTER BOILERPLATE ====="
echo "flag_debug: [${flag_debug:-UNSET}]"
typeset -p flag_debug 2>&1 || echo "flag_debug not defined"
