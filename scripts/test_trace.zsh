#!/usr/bin/env -S zsh -euo pipefail
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
echo "=== After boilerplate ==="
echo "zparse_categories: ${zparse_categories[@]:-UNSET}"
echo "flag_debug: [${flag_debug:-UNSET}]"
echo "Args remaining: $@"
