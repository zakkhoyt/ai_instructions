#!/usr/bin/env -S zsh -euo pipefail
typeset -a arr=('meta' 'dev')
echo "Array: ${arr[@]}"
echo "Size: ${#arr[@]}"
echo "Element [0]: [${arr[0]:-UNSET}]"
echo "Element [1]: [${arr[1]:-UNSET}]"
echo "Element [2]: [${arr[2]:-UNSET}]"
echo "Element [3]: [${arr[3]:-UNSET}]"
