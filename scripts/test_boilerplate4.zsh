#!/usr/bin/env -S zsh -euo pipefail
# Test if zparseopts can see global $@ even when source doesn't pass it
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "flag_debug: ${flag_debug:-UNSET}"
echo "flag_help: ${flag_help:-UNSET}"
echo "Remaining args: $@"
