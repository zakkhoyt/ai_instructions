#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash # trick shellcheck into working with zsh
# shellcheck disable=SC2296 # Falsely identifies zsh expansions
# shellcheck disable=SC1091 # Complains about sourcing without literal path
# shellcheck disable=SC2206
# shellcheck disable=SC2296

#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Cateogrizes and counts swift compiler warnings from xcodebuild (natural format or xcpretty)
#
# ---- ---- ----     Source Utilities     ---- ---- ----

# Determine script directory for relative path fallback
script_dir="${0:A:h}"

# A list of directories to fall back through when sourcing utilities
source_dirs=(
  "${HATCH_SOURCE_DIR:-}"
  "$HOME/.hatch/source"
  "$HOME/.zsh_home/utilities"
  "$script_dir/../../assets/hatch_home/source" # only for environment-toolbox setup scripts
)

config_files=(
  ".zsh_main"
  ".zsh_scripting_utilities"
)

indent_count=0
indent="_"
function _set_indent {
  # =("$@")
  local i
  # echo "$0 args: ${#[@]}" 1>&2
  for ((i=0; i<="${#[@]}"; i++)); do
    element="${*: $i: 1}"
    if [[ -z "$element" ]]; then continue; fi
    # echo "  \${[$i]}: $element" 1>&2
  done
  
  zparseopts -D -- -indent:=opt_indent_count
  local _indent_count=${opt_indent_count[-1]:-0}
  # echo "$0 _indent_count: '$_indent_count'" 1>&2
  indent_count="$_indent_count"
  # echo "$0 indent_count: '$indent_count'" 1>&2
  local _indent=$(printf "%*s" $((indent_count * 2)) "")
  # echo "$0 _indent: '$_indent'" 1>&2
  indent=$_indent
  # echo "$0 indent: '$indent'" 1>&2
  local args=("$@")
  echo "${(F)args[@]}"
}

function log_debug {
  echo "indent(before): '$indent'" 1>&2
  local args; args=(${(f)"$(_set_indent "$@")"})
  echo "indent(after): '$indent'" 1>&2
  # echo "$0 args:\n${(F)args[@]}" 1>&2
  # slog_array_se "args" "${args[@]}"
  
  echo_pretty --code \
  "[DEBUG]   " --default "$indent " "${args[@]}"  1>&2
}
function log_notice {
  # zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  # local indent=$(printf "%*s" $((indent_count * 2)) "")
  local args; args=(${(f)"$(_set_indent "$@")"})
  echo_pretty --bold \
  "[NOTICE]  " --default "$indent " "${args[@]}"  1>&2
}
function log_info {
  zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  local indent=$(printf "%*s" $((indent_count * 2)) "")
  echo_pretty --default \
  "[INFO]    " --default "$indent " "$@"  1>&2
}
function log_will {
  zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  local indent=$(printf "%*s" $((indent_count * 2)) "")
  echo_pretty --default \
  "[WILL]    " --default "$indent " "$@"  1>&2
}
function log_success {
  zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  local indent=$(printf "%*s" $((indent_count * 2)) "")
  echo_pretty --green \
  "[SUCCESS] " --default "$indent " "$@"  1>&2
}
function log_warning {
  zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  local indent=$(printf "%*s" $((indent_count * 2)) "")
  echo_pretty --orange \
  "[WARNING] " --default "$indent " "$@"  1>&2
}
function log_error {
  zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  local indent=$(printf "%*s" $((indent_count * 2)) "")
  echo_pretty --red \
  "[ERROR]   " --default "$indent " "$@"  1>&2
}
function log_fatal {
  zparseopts -D -- -level=indent_count; indent_count=${indent_count[-1]:-0}
  local indent=$(printf "%*s" $((indent_count * 2)) "")
  echo_pretty --red --bold --underline --blink \
  "[FATAL]   " --default "$indent " "$@"  1>&2
}

# log_debug --indent 0 "test log_debug level 0"
# log_debug --indent 1 "test log_debug level 1"
# log_debug --indent 2 "test log_debug level 2"
# log_notice --indent 0 "test log_notice level 0"
# log_notice --indent 1 "test log_notice level 1"
# log_notice --indent 2 "test log_notice level 2"
# log_debug --indent 2 --green "test log_debug level 2 with ansi" --default "."

# return 0
# source_dirs=("$@")

echo "source_dirs.count: ${#source_dirs[@]}" 1>&2
echo "config_files.count: ${#config_files[@]}" 1>&2
echo 


unset -v config_file_sourced
typeset -a sourced_files=()

for ((j=1; j<="${#config_files[@]}"; j++)); do
  log_debug --indent 0 "j[$j]"
  
  log_will --indent 1 "unwrap var config_files"
  config_file="${config_files[$j]:-}"
  if [[ -n "$config_file" ]]; then 
    log_error --indent 2 "Failed to unwrap var config_files"
    continue; 
  fi
  log_success --indent 2 "Did unwrap var config_files: $config_files"

  
  for ((i=1; i<="${#source_dirs[@]}"; i++)); do
    log_debug --indent 1 "i[$i]"
    # source_dir="${source_dirs[$i]:-}"
    # if [[ -z "$source_dir" ]]; then continue; fi
    # echo "    \${source_dirs[$i]}: $source_dir" 1>&2

    # log_debug --indent 3 "  [$j][$i]: ${source_dir:-<nil>}"
    log_will --indent 2 "unwrap var source_dir"
    source_dir="${source_dirs[$i]:-}"
    if [[ -n "$source_dir" ]]; then 
      # log_notice "    \${source_dirs[$i]}: <nil> [SKIPPING]"
      log_will --indent 3 "Failed to unwrap var source_dir"
      continue; 
    fi
    log_success --indent 3 "Did unwrap var source_dir: $source_dir"

    log_will --indent 2 "Verify existence of dir source_dir: $source_dir"
    if [[ ! -d "$source_dir" ]]; then 
      log_warning --indent 3 "Failed to verify existence of dir source_dir: $source_dir [SKIPPING]"
      continue; 
    fi
    log_success --indent 3 "Confirmed existence of dir source_dir: $source_dir"

    # log_debug "    source_filepath: ${source_filepath:-<nil>}"

    source_filepath="${source_dir}/${config_file}"
    log_info --indent 2 "Composed var source_filepath: $source_filepath"


    log_will --indent 2 "Verify existence of file source_filepath: $source_filepath"
    if [[ ! -f "$source_filepath" ]]; then 
      log_warning --indent 3 "Failed to verify existence of file source_filepath: $source_filepath [SKIPPING]"
      continue; 
    fi
    log_success --indent 3 "Confirmed existence of source_filepath: $source_filepath"

    source_command="source \"$source_filepath\" \"$0\" \"$@\""
    log_will --indent 2 "Execute source command: $source_command"
    if ! eval "$source_command" > /dev/null; then
      rval=$?
      log_error --indent 3 "[$rval] Failed to execute source command: $source_command"
      exit $rval
      continue;  
    fi
    log_success --indent 3 "Did execute source command: $source_command"

    sourced_files+=("$source_filepath")
    log_info --indent 2 "Appended $source_filepath to sourced_files}"

    log_notice --indent 2 "Setting config_file_sourced=true before breaking loop"
    config_file_sourced=true
    break
  done
done

log_debug --indent 0 "sourced_files.count: ${#sourced_files[@]}"
for ((i=0; i<="${#sourced_files[@]}"; i++)); do
  sourced_file="${sourced_files[$i]:-}"
  if [[ -z "$sourced_file" ]]; then continue; fi
  # echo "  \${sourced_files[$i]}: $sourced_file" 1>&2
  log_debug --indent 1 "\${sourced_files[$i]}: $sourced_file" 1>&2
done

if [[ -z "${config_file_sourced:-}" ]]; then
  log_fatal --indent 0 "config_file_sourced=nil    Failed to find & source these config files:\n${(F)config_files[@]}\n\nfrom these dirs:\n${(F)source_dirs[@]}\n"
  exit 1
fi

log_success --indent 0 "Successfully sourced .zsh_main from one of these dirs:\n" "${(F)source_dirs[@]}"

# source_dirs_string="${(F)source_dirs[@]}"
# echo "\${(F)source_dirs[@]}:\n${(F)source_dirs[@]}"
# : ${config_file_sourced:?"[FATAL ERROR]: Failed to find & source .zsh_main from these dirs:\n${(F)source_dirs[@]}"}
# # : ${config_file_sourced_fake:?"[FATAL ERROR]: Failed to find & source .zsh_main from these dirs:\n" "${(F)source_dirs[@]}"}
# # : ${config_file_sourced_fake:?$(echo "[FATAL ERROR]: Failed to find & source .zsh_main from these dirs:\n" "${(F)source_dirs[@]}")}
# : ${config_file_sourced_fake:?$(echo "abc123"; echo "[FATAL ERROR]: Failed to find & source .zsh_main from these dirs:\n" "${(F)source_dirs[@]}")}

# ---- ---- ---- Script Args Parsing ---- ---- ----



# ---- ---- ---- Script Var Validation & Refinement ---- ---- ----



# ---- ---- ---- Script Logic ---- ---- ----