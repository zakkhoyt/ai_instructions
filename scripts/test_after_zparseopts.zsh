#!/usr/bin/env -S zsh -euo pipefail
source /Users/zakkhoyt/.zsh_home/utilities/.zsh_zparseopts
echo "After zparseopts:"
echo "  zparse_categories: ${zparse_categories[@]:-UNSET}"
echo "  zparse_category (last value): ${zparse_category:-UNSET}"
echo "  c_i (last value): ${c_i:-UNSET}"
