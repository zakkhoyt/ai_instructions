#!/usr/bin/env -S zsh -euo pipefail
# Enable zparseopts debugging
export IS_UTILS_DEBUG="true"
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "=== RESULT ==="
echo "flag_debug: [${flag_debug:-UNSET}]"
