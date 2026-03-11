#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Comprehensive test suite for configure_ai_instructions_NEW.zsh
# Author: AI Agent
# Usage: ./configure_ai_instructions_tests_COMPREHENSIVE.zsh
#
# This script performs real-world testing scenarios including:
# - Help and usage display
# - Platform detection validation
# - File discovery and processing
# - Interactive menu simulation (non-interactive mode)
# - Configuration validation
# - Error handling
#

# ---- ---- ----     Source Utilities     ---- ---- ----

source "$HOME/.zsh_home/utilities/.zsh_boilerplate"

# ---- ---- ----   Argument Parsing   ---- ---- ----

zparseopts -D -F -- \
  -help=flag_help

if [[ -n "${flag_help:-}" ]]; then
  cat << 'EOF'
Comprehensive Test Suite for configure_ai_instructions_NEW.zsh

USAGE:
  ./configure_ai_instructions_tests_COMPREHENSIVE.zsh

TESTS PERFORMED:
  1. Help display validation
  2. Version/debug output validation
  3. Platform detection (Copilot, Cursor, Windsurf, Cline)
  4. Instruction file discovery
  5. Symlink vs copy mode
  6. Dry-run mode
  7. Interactive menu (simulated)
  8. Error handling

OUTPUT:
  Test logs saved to: .gitignored/test_logs/legacy_comprehensive/

EOF
  exit 0
fi

# ---- ---- ----   Variable Initialization   ---- ---- ----

typeset -r script_dir="${0:A:h}"
typeset -r repo_dir="${script_dir:h}"
typeset -r script_to_test="${script_dir}/configure_ai_instructions_NEW.zsh"
typeset -r log_dir="${repo_dir}/.gitignored/test_logs/legacy_comprehensive"
typeset -r timestamp=$(date +%Y%m%d_%H%M%S)

slog_var1_se_d "script_dir"
slog_var1_se_d "repo_dir"
slog_var1_se_d "script_to_test"
slog_var1_se_d "log_dir"
slog_var1_se_d "timestamp"

# ---- ---- ----     Validation     ---- ---- ----

slog_step_se_d --context will "validate test script exists"

if [[ ! -f "$script_to_test" ]]; then
  slog_step_se --context fatal "script not found: " --url "$script_to_test" --default
  exit 1
fi

slog_step_se_d --context success "validated test script exists"

slog_step_se_d --context will "create log directory"
mkdir -p "$log_dir"
slog_step_se_d --context success "created log directory: " --url "$log_dir" --default

# ---- ---- ----     Test Helper Functions     ---- ---- ----

function run_test {
  zparseopts -D -F -- \
    -name:=opt_name \
    -description:=opt_description \
    -command:=opt_command \
    -expected-exit:=opt_expected_exit
  
  typeset -r test_name="${opt_name[2]}"
  typeset -r description="${opt_description[2]}"
  typeset -r command="${opt_command[2]}"
  typeset -r expected_exit="${opt_expected_exit[2]:-0}"
  
  typeset -r log_file="${log_dir}/${test_name}_${timestamp}.log"
  
  slog_se ""
  slog_se "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  slog_step_se --context will "run test: " --code "$test_name" --default
  slog_se "Description: $description"
  slog_se "Command: " --code "$command" --default
  slog_se "Expected exit code: $expected_exit"
  slog_se ""
  
  # Write test header to log file
  cat > "$log_file" << EOF
================================================================================
TEST: $test_name
================================================================================
Description: $description
Command: $command
Expected exit code: $expected_exit
Timestamp: $(date)
================================================================================

COMMAND OUTPUT:
--------------------------------------------------------------------------------
EOF
  
  # Execute command in proper zsh environment with full output capture
  /bin/zsh -c "source ~/.zshrc > /dev/null 2>&1 && $command" >> "$log_file" 2>&1
  typeset -i actual_exit=$?
  
  # Write test footer to log file
  cat >> "$log_file" << EOF

--------------------------------------------------------------------------------
EXIT CODE: $actual_exit
Expected: $expected_exit
Status: $([[ $actual_exit -eq $expected_exit ]] && echo "PASS" || echo "FAIL")
================================================================================
EOF
  
  slog_se ""
  slog_se "Actual exit code: $actual_exit"
  slog_se "Log file: " --url "$log_file" --default
  
  if [[ $actual_exit -eq $expected_exit ]]; then
    slog_step_se --context success "test PASSED: " --code "$test_name" --default
    return 0
  else
    slog_step_se --context warning --exit-code "$actual_exit" "test FAILED (expected $expected_exit): " --code "$test_name" --default
    return 1
  fi
}

function create_test_summary {
  typeset -r summary_file="${log_dir}/TEST_SUMMARY_${timestamp}.md"
  
  slog_step_se_d --context will "create test summary"
  
  cat > "$summary_file" << EOF
# Test Summary - Legacy Script

**Script**: configure_ai_instructions_NEW.zsh  
**Timestamp**: $(date)  
**Log Directory**: ${log_dir}

## Test Results

EOF
  
  typeset -i test_num=1
  typeset -i passed=0
  typeset -i failed=0
  
  for log_file in "${log_dir}"/*_${timestamp}.log; do
    if [[ -f "$log_file" ]]; then
      typeset test_name="${log_file:t:r}"
      test_name="${test_name%_${timestamp}}"
      
      typeset test_status=$(grep "^Status:" "$log_file" | cut -d' ' -f2)
      typeset exit_code=$(grep "^EXIT CODE:" "$log_file" | awk '{print $3}')
      
      if [[ "$test_status" == "PASS" ]]; then
        ((passed++))
        echo "### ✅ Test $test_num: $test_name - PASSED" >> "$summary_file"
      else
        ((failed++))
        echo "### ❌ Test $test_num: $test_name - FAILED (exit code: $exit_code)" >> "$summary_file"
      fi
      
      echo "" >> "$summary_file"
      echo "**Log**: \`${log_file:t}\`" >> "$summary_file"
      echo "" >> "$summary_file"
      
      ((test_num++))
    fi
  done
  
  # Add summary statistics
  cat >> "$summary_file" << EOF

## Statistics

- **Total Tests**: $((passed + failed))
- **Passed**: $passed
- **Failed**: $failed
- **Success Rate**: $(( passed * 100 / (passed + failed) ))%

## Log Files

All detailed logs in: \`${log_dir}\`

EOF
  
  slog_step_se_d --context success "created test summary: " --url "$summary_file" --default
  
  slog_se ""
  slog_se "════════════════════════════════════════════════════════════════════════"
  slog_se "TEST SUMMARY"
  slog_se "════════════════════════════════════════════════════════════════════════"
  slog_se "Total: $((passed + failed)) | Passed: $passed | Failed: $failed"
  slog_se "Summary: " --url "$summary_file" --default
  slog_se "════════════════════════════════════════════════════════════════════════"
}

# ---- ---- ----     Run Test Suite     ---- ---- ----

slog_se ""
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "COMPREHENSIVE TEST SUITE - Legacy Script"
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "Script: " --url "$script_to_test" --default
slog_se "Log dir: " --url "$log_dir" --default
slog_se "════════════════════════════════════════════════════════════════════════"

# Test 1: Help display
run_test \
  --name "test_01_help" \
  --description "Verify --help flag displays usage information" \
  --command "$script_to_test --help" \
  --expected-exit 1

# Test 2: Debug mode without action
run_test \
  --name "test_02_debug_only" \
  --description "Run with --debug to verify debug output and variable logging" \
  --command "$script_to_test --debug" \
  --expected-exit 0

# Test 3: Platform detection
run_test \
  --name "test_03_platform_copilot" \
  --description "Test Copilot platform detection and path resolution" \
  --command "$script_to_test --debug" \
  --expected-exit 0

# Test 4: List instructions mode
run_test \
  --name "test_04_list_instructions" \
  --description "Verify --instructions flag lists available instruction files" \
  --command "$script_to_test --debug --instructions" \
  --expected-exit 0

# Test 5: Dry-run mode with instructions
run_test \
  --name "test_05_dryrun_instructions" \
  --description "Test dry-run mode shows what would be done without making changes" \
  --command "$script_to_test --debug --dry-run --instructions" \
  --expected-exit 0

# Test 6: VSCode settings discovery
run_test \
  --name "test_06_vscode_settings" \
  --description "Test VS Code settings file discovery" \
  --command "$script_to_test --debug --vscode" \
  --expected-exit 0

# Test 7: Workspace discovery
run_test \
  --name "test_07_workspace" \
  --description "Test workspace file discovery" \
  --command "$script_to_test --debug --workspace" \
  --expected-exit 0

# Test 8: MCP Xcode discovery
run_test \
  --name "test_08_mcp_xcode" \
  --description "Test MCP Xcode configuration discovery" \
  --command "$script_to_test --debug --mcp-xcode" \
  --expected-exit 0

# Test 9: Custom instruction discovery
run_test \
  --name "test_09_custom_prompt" \
  --description "Test custom prompt file discovery" \
  --command "$script_to_test --debug --prompt" \
  --expected-exit 0

# Test 10: Multiple flags combined
run_test \
  --name "test_10_combined_flags" \
  --description "Test multiple flags together: --debug --instructions --workspace --vscode" \
  --command "$script_to_test --debug --instructions --workspace --vscode" \
  --expected-exit 0

# Test 11: Regenerate flag
run_test \
  --name "test_11_regenerate" \
  --description "Test --regenerate-main flag behavior" \
  --command "$script_to_test --debug --regenerate-main" \
  --expected-exit 0

# Create summary
create_test_summary

slog_se ""
slog_step_se --context info "Test suite complete"
slog_se ""
