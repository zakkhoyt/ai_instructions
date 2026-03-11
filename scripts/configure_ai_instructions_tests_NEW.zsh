#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Test configure_ai_instructions_NEW.zsh with comprehensive scenarios
# Author: AI Agent
# Usage: ./configure_ai_instructions_tests_NEW.zsh [--debug]
#

# ---- ---- ----     Source Utilities     ---- ---- ----

source "$HOME/.zsh_home/utilities/.zsh_boilerplate"

# ---- ---- ----   Argument Parsing   ---- ---- ----

zparseopts -D -F -- \
  -help=flag_help

if [[ -n "${flag_help:-}" ]]; then
  echo "Test script for configure_ai_instructions_NEW.zsh"
  echo "Usage: $0 [--debug]"
  exit 0
fi

# ---- ---- ----   Variable Initialization   ---- ---- ----

typeset -r script_to_test="./scripts/configure_ai_instructions_NEW.zsh"
typeset -r log_dir=".gitignored/test_logs/legacy_version"
typeset -r timestamp=$(date +%Y%m%d_%H%M%S)

mkdir -p "$log_dir"

# ---- ---- ----     Test Functions     ---- ---- ----

function run_test {
  zparseopts -D -F -- \
    -name:=opt_name \
    -command:=opt_command \
    -log-file:=opt_log_file
  
  typeset -r test_name="${opt_name[2]}"
  typeset -r command="${opt_command[2]}"
  typeset -r log_file="${opt_log_file[2]}"
  
  slog_step_se --context will "run test: " --code "$test_name" --default
  
  echo "=== TEST: $test_name ===" > "$log_file"
  echo "Command: $command" >> "$log_file"
  echo "Timestamp: $(date)" >> "$log_file"
  echo "" >> "$log_file"
  
  eval "$command" >> "$log_file" 2>&1
  typeset -i exit_code=$?
  
  echo "" >> "$log_file"
  echo "Exit code: $exit_code" >> "$log_file"
  
  if [[ $exit_code -eq 0 ]]; then
    slog_step_se --context success "test passed: " --code "$test_name" --default
  else
    slog_step_se --context warning --exit-code "$exit_code" "test failed: " --code "$test_name" --default
  fi
  
  return $exit_code
}

# ---- ---- ----     Run Tests     ---- ---- ----

slog_step_se --context info "Starting test suite for configure_ai_instructions_NEW.zsh"

run_test \
  --name "help_flag" \
  --command "$script_to_test --help" \
  --log-file "$log_dir/test_01_help_${timestamp}.log"

run_test \
  --name "debug_flag" \
  --command "$script_to_test --debug" \
  --log-file "$log_dir/test_02_debug_${timestamp}.log"

run_test \
  --name "instructions_flag" \
  --command "$script_to_test --instructions" \
  --log-file "$log_dir/test_03_instructions_${timestamp}.log"

run_test \
  --name "debug_instructions" \
  --command "$script_to_test --debug --instructions" \
  --log-file "$log_dir/test_04_debug_instructions_${timestamp}.log"

slog_step_se --context info "Test suite complete. Logs saved to: " --url "$log_dir" --default
