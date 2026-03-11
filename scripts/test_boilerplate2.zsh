#!/usr/bin/env -S zsh -euo pipefail
echo "Before sourcing boilerplate, args: $@"
source "$HOME/.zsh_home/utilities/.zsh_boilerplate" "$0" "$@"
echo "flag_debug after boilerplate: ${flag_debug:-UNSET}"
echo "FLAG_DEBUG after boilerplate: ${FLAG_DEBUG:-UNSET}"
typeset -p | grep -i debug || echo "No debug variables found"
