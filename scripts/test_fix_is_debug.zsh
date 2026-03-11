#!/usr/bin/env -S zsh -euo pipefail
# Initialize IS_DEBUG before sourcing boilerplate!
export IS_DEBUG=""
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "=== AFTER BOILERPLATE ==="
echo "flag_debug: [${flag_debug:-UNSET}]"
echo "IS_DEBUG: [${IS_DEBUG:-UNSET}]"
