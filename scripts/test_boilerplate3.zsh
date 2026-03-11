#!/usr/bin/env -S zsh -euo pipefail
# Don't pass "$@" to boilerplate?
source "$HOME/.zsh_home/utilities/.zsh_boilerplate" "$0"
echo "flag_debug: ${flag_debug:-UNSET}"
echo "Remaining args: $@"
