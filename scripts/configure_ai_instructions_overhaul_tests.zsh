#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Comprehensive test suite for configure_ai_instructions_overhaul.zsh
# Author: AI Agent
# Usage: ./configure_ai_instructions_overhaul_tests.zsh
#
# Tests all action handlers in isolated environment with full I/O logging

# Initialize boilerplate-required variables before sourcing
[[ -z "${IS_DEBUG:-}" ]] && typeset IS_DEBUG=""
[[ -z "${IS_VERBOSE:-}" ]] && typeset IS_VERBOSE=""
[[ -z "${IS_UTILS_DEBUG:-}" ]] && typeset IS_UTILS_DEBUG=""
[[ -z "${IS_DRY_RUN:-}" ]] && typeset IS_DRY_RUN=""

# ---- ---- ----     Source Utilities     ---- ---- ----

source "$HOME/.zsh_home/utilities/.zsh_boilerplate" "$0" "$@"

# ---- ---- ----     Global Variables     ---- ---- ----

typeset -r script_path="/Users/zakkhoyt/.ai/scripts/configure_ai_instructions_overhaul.zsh"
typeset -r log_dir="/Users/zakkhoyt/.ai/.gitignored/logs/test_overhaul"
typeset -r timestamp="$(date +%Y%m%d_%H%M%S)"

typeset test_count=0
typeset pass_count=0
typeset fail_count=0

# ---- ---- ----     Helper Functions     ---- ---- ----

function run_test {
  typeset -r test_name="$1"
  shift
  typeset -a test_args=("$@")
  
  ((test_count++))
  typeset -r test_num="$(printf "%02d" "$test_count")"
  
  slog_se ""
  slog_se --bold "TEST $test_num: " --default "$test_name"
  slog_se --bold "========================================" --default
  
  typeset -r log_file="$log_dir/test_${test_num}_${test_name// /_}_${timestamp}.log"
  
  typeset -r cmd="$script_path ${test_args[*]}"
  slog_se "Command: " --code "$cmd" --default
  slog_se ""
  
  echo "TEST $test_num: $test_name" > "$log_file"
  echo "Command: $cmd" >> "$log_file"
  echo "========================================" >> "$log_file"
  echo "" >> "$log_file"
  
  if "$script_path" "${test_args[@]}" >> "$log_file" 2>&1; then
    ((pass_count++))
    slog_step_se --context success "Test passed"
    echo "" >> "$log_file"
    echo "RESULT: PASS" >> "$log_file"
  else
    typeset -i exit_code=$?
    ((fail_count++))
    slog_step_se --context warning --exit-code "$exit_code" "Test failed"
    echo "" >> "$log_file"
    echo "RESULT: FAIL (exit code: $exit_code)" >> "$log_file"
  fi
  
  slog_se "Log: " --url "$log_file" --default
}

function setup_test_repo {
  typeset -r test_repo="$1"
  
  slog_step_se_d --context will "create test repository: " --url "$test_repo" --default
  
  rm -rf "$test_repo"
  mkdir -p "$test_repo"
  
  git -C "$test_repo" init -q
  git -C "$test_repo" config user.name "Test User"
  git -C "$test_repo" config user.email "test@example.com"
  
  mkdir -p "$test_repo/.github/instructions"
  mkdir -p "$test_repo/.vscode"
  
  slog_step_se_d --context success "created test repository"
}

function verify_instruction_files {
  typeset -r test_repo="$1"
  typeset -r expected_count="$2"
  
  typeset -i actual_count=0
  actual_count=$(find "$test_repo/.github/instructions" -name "*.instructions.md" 2>/dev/null | wc -l | tr -d ' ')
  
  if [[ $actual_count -eq $expected_count ]]; then
    slog_step_se_d --context success "Found $actual_count instruction files (expected $expected_count)"
    return 0
  else
    slog_step_se --context warning "Found $actual_count instruction files (expected $expected_count)"
    return 1
  fi
}

function verify_file_exists {
  typeset -r file_path="$1"
  typeset -r description="${2:-file}"
  
  if [[ -f "$file_path" || -L "$file_path" ]]; then
    slog_step_se_d --context success "verified $description exists"
    return 0
  else
    slog_step_se --context warning "$description not found: " --url "$file_path" --default
    return 1
  fi
}

function verify_symlink {
  typeset -r link_path="$1"
  typeset -r expected_target="$2"
  
  if [[ ! -L "$link_path" ]]; then
    slog_step_se --context warning "not a symlink: " --url "$link_path" --default
    return 1
  fi
  
  typeset actual_target=""
  actual_target="$(readlink "$link_path")"
  
  if [[ "$actual_target" == "$expected_target" ]]; then
    slog_step_se_d --context success "verified symlink points to correct target"
    return 0
  else
    slog_step_se --context warning "symlink target mismatch"
    slog_se "  Expected: " --url "$expected_target" --default
    slog_se "  Actual:   " --url "$actual_target" --default
    return 1
  fi
}

# ---- ---- ----     Test Execution     ---- ---- ----

function main {
  slog_se ""
  slog_se --bold "CONFIGURE_AI_INSTRUCTIONS_OVERHAUL TEST SUITE" --default
  slog_se --bold "=============================================" --default
  slog_se ""
  
  mkdir -p "$log_dir"
  
  typeset -r temp_repo="/tmp/ai_test_repo_$$"
  
  # Test 1: Help flag
  run_test "help_flag" --help
  
  # Test 2: Instructions (auto mode)
  setup_test_repo "$temp_repo"
  run_test "instructions_auto" --no-prompt instructions --dest-dir "$temp_repo"
  verify_instruction_files "$temp_repo" 11
  verify_file_exists "$temp_repo/.github/copilot-instructions.md" "main instruction file"
  
  # Test 3: Dev-link (auto mode)
  setup_test_repo "$temp_repo"
  run_test "dev_link_auto" --no-prompt dev-link --dest-dir "$temp_repo"
  verify_symlink "$temp_repo/ai" "/Users/zakkhoyt/.ai"
  
  # Test 4: Regenerate-main (auto mode)
  setup_test_repo "$temp_repo"
  run_test "regenerate_main_auto" --no-prompt regenerate-main --dest-dir "$temp_repo"
  verify_file_exists "$temp_repo/.github/copilot-instructions.md" "regenerated main file"
  
  # Test 5: Multiple actions together
  setup_test_repo "$temp_repo"
  run_test "multiple_actions" \
    --no-prompt instructions \
    --no-prompt dev-link \
    --no-prompt regenerate-main \
    --dest-dir "$temp_repo"
  verify_instruction_files "$temp_repo" 11
  verify_symlink "$temp_repo/ai" "/Users/zakkhoyt/.ai"
  verify_file_exists "$temp_repo/.github/copilot-instructions.md" "main instruction file"
  
  # Test 6: Workspace settings (auto mode) - will skip if no templates
  setup_test_repo "$temp_repo"
  run_test "workspace_settings_auto" --no-prompt workspace-settings --dest-dir "$temp_repo"
  
  # Test 7: User settings (auto mode) - will skip if no templates
  setup_test_repo "$temp_repo"
  run_test "user_settings_auto" --no-prompt user-settings --dest-dir "$temp_repo"
  
  # Test 8: Dev-vscode (auto mode) - needs workspace file first
  setup_test_repo "$temp_repo"
  echo '{"folders":[]}' > "$temp_repo/test.code-workspace"
  run_test "dev_vscode_needs_link" --no-prompt dev-vscode --dest-dir "$temp_repo"
  
  # Test 9: Dev-vscode with symlink
  setup_test_repo "$temp_repo"
  "$script_path" --no-prompt dev-link --dest-dir "$temp_repo" > /dev/null 2>&1
  echo '{"folders":[]}' > "$temp_repo/test.code-workspace"
  run_test "dev_vscode_with_link" --no-prompt dev-vscode --dest-dir "$temp_repo"
  
  # Test 10: MCP Xcode (auto mode)
  setup_test_repo "$temp_repo"
  run_test "mcp_xcode_auto" --no-prompt mcp-xcode --dest-dir "$temp_repo"
  
  # Test 11: All actions together
  setup_test_repo "$temp_repo"
  echo '{"folders":[]}' > "$temp_repo/test.code-workspace"
  run_test "all_actions_combined" \
    --no-prompt instructions \
    --no-prompt dev-link \
    --no-prompt regenerate-main \
    --no-prompt workspace-settings \
    --no-prompt user-settings \
    --no-prompt dev-vscode \
    --no-prompt mcp-xcode \
    --dest-dir "$temp_repo"
  
  # Cleanup
  rm -rf "$temp_repo"
  
  # Summary
  slog_se ""
  slog_se --bold "TEST SUMMARY" --default
  slog_se --bold "============" --default
  slog_se ""
  slog_se "Total tests:  $test_count"
  slog_se "Passed:       " --green "$pass_count" --default
  slog_se "Failed:       " --red "$fail_count" --default
  slog_se ""
  
  if [[ $fail_count -eq 0 ]]; then
    slog_step_se --context success "All tests passed!"
    return 0
  else
    slog_step_se --context warning "Some tests failed"
    return 1
  fi
}

main "$@"
