#!/usr/bin/env -S zsh -euo pipefail
# Initialize all IS_* variables before sourcing boilerplate!
export IS_DEBUG=""
export IS_VERBOSE=""
export IS_DRY_RUN=""
export IS_UTILS_DEBUG=""
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "=== AFTER BOILERPLATE ==="
echo "flag_debug: [${flag_debug:-UNSET}]"
echo "IS_DEBUG: [${IS_DEBUG:-UNSET}]"
