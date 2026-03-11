#!/usr/bin/env -S zsh -euo pipefail
typeset -a arr=('meta' 'dev')
echo "Size: ${#arr[@]}"
echo "Loop with c_i<=\${#arr[@]}:"
for ((c_i=0; c_i<="${#arr[@]}"; c_i++)); do
  elem="${arr[$c_i]:-EMPTY}"
  echo "  c_i=$c_i elem=[$elem]"
  # After first non-empty element, break (simulating what zparseopts might do)
  if [[ "$elem" == "meta" ]]; then
    echo "  Breaking after meta!"
    break
  fi
done
echo "Loop ended at c_i=$c_i"
