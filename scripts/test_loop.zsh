#!/usr/bin/env -S zsh -euo pipefail
# Manually test the loop logic
typeset -a zparse_categories=('meta' 'dev')
echo "Array size: ${#zparse_categories[@]}"
echo "Loop from 0 to ${#zparse_categories[@]}"
for ((c_i=0; c_i<="${#zparse_categories[@]}"; c_i++)); do
  zparse_category="${zparse_categories[$c_i]:-}"
  if [[ -z "$zparse_category" ]]; then 
    echo "  [$c_i]: EMPTY - continuing"
    continue
  fi
  echo "  [$c_i]: $zparse_category"
done
