#!/usr/bin/env -S zsh -euo pipefail
echo "Initial args: $@"

# Simulate meta category parsing
typeset flag_help="" flag_verbose="" flag_dry_run=""
zparseopts -D -E -- \
  -help=flag_help \
  {v,-verbose}+=flag_verbose \
  -dry-run=flag_dry_run

echo "After meta parse:"
echo "  flag_help=[$flag_help]"
echo "  Remaining args: $@"

# Now simulate dev category parsing
typeset flag_debug=""
zparseopts -D -E -- {d,-debug}+=flag_debug

echo "After dev parse:"
echo "  flag_debug=[$flag_debug]"
echo "  Remaining args: $@"
