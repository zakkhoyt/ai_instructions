#!/usr/bin/env -S zsh -euo pipefail
# CORRECT: Don't pass args to boilerplate
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "flag_debug: [${flag_debug:-UNSET}]"
echo "flag_help: [${flag_help:-UNSET}]"
