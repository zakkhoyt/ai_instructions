#!/usr/bin/env -S zsh -euo pipefail
# Replicate the zparseopts loop logic
typeset -a zparse_categories=('meta' 'dev')
echo "Categories: ${zparse_categories[@]}"
echo "Loop from c_i=0 to ${#zparse_categories[@]}"
for ((c_i=0; c_i<="${#zparse_categories[@]}"; c_i++)); do
  zparse_category="${zparse_categories[$c_i]:-}"
  echo "  c_i=$c_i zparse_category=[$zparse_category]"
  if [[ -z "$zparse_category" ]]; then 
    echo "    -> empty, continue"
    continue
  fi
  case "$zparse_category" in
  meta)
    echo "    -> Running meta zparseopts"
    typeset flag_help=""
    zparseopts -D -E -- -help=flag_help
    echo "       flag_help=[$flag_help] remaining_args=$@"
    ;;
  dev|developer)
    echo "    -> Running dev zparseopts"
    typeset flag_debug=""
    zparseopts -D -E -- {d,-debug}+=flag_debug
    echo "       flag_debug=[$flag_debug] remaining_args=$@"
    ;;
  esac
done
echo "Final: flag_help=[${flag_help:-UNSET}] flag_debug=[${flag_debug:-UNSET}]"
