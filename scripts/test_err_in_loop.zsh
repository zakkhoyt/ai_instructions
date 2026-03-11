#!/usr/bin/env -S zsh -eo pipefail
# Note: using -e means any error will exit
typeset -a arr=('meta' 'dev')
for ((c_i=0; c_i<=2; c_i++)); do
  elem="${arr[$c_i]:-EMPTY}"
  echo "c_i=$c_i elem=$elem"
  case "$elem" in
  meta)
    echo "  In meta case"
    # This will cause an error with -e -u
    echo "  Accessing unset var: ${UNSET_VAR}"
    ;;
  dev)
    echo "  In dev case"
    ;;
  esac
done
echo "Loop completed"
