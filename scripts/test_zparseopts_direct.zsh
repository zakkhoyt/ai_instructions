#!/usr/bin/env -S zsh -euo pipefail
# Test zparseopts directly
echo "Before zparseopts: args=$@"
typeset flag_debug=""
zparseopts -D -E -- {d,-debug}+=flag_debug
echo "After zparseopts: flag_debug=[${flag_debug}] remaining_args=$@"
