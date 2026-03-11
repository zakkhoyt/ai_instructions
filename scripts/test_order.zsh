#!/usr/bin/env -S zsh -euo pipefail
echo "=== BEFORE boilerplate ==="
echo "Args: $@"
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "=== AFTER boilerplate ==="
echo "flag_debug: [${flag_debug:-UNSET}]"
echo "IS_DEBUG: [${IS_DEBUG:-UNSET}]"
echo "Remaining args: $@"
