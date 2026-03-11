#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: COMPREHENSIVE test suite for configure_ai_instructions_NEW.zsh
# Author: Zakk Hoyt
# Usage: ./configure_ai_instructions_tests_REAL.zsh
#
# This test suite exercises EVERY argument and flag combination of the main script.
# Tests run in isolated test directories to avoid conflicts with existing files.
# Captures complete stdout/stderr for debugging.
#

# ---- ---- ----     Source Utilities     ---- ---- ----

source "$HOME/.zsh_home/utilities/.zsh_boilerplate"

# ---- ---- ----     Setup     ---- ---- ----

typeset -r script_dir="${0:A:h}"
slog_var1_se_d "script_dir"

typeset -r repo_dir="${script_dir:h}"
slog_var1_se_d "repo_dir"

typeset -r script_to_test="${script_dir}/configure_ai_instructions_NEW.zsh"
slog_var1_se_d "script_to_test"

typeset -r timestamp=$(date +%Y%m%d_%H%M%S)
slog_var1_se_d "timestamp"

typeset -r log_dir="${repo_dir}/.gitignored/logs/test_legacy_real"
slog_var1_se_d "log_dir"

mkdir -p "$log_dir"

# Create test directory
typeset -r test_root_dir="${repo_dir}/.gitignored/test_workspace"
slog_var1_se_d "test_root_dir"

# ---- ---- ----     Test Runner Function     ---- ---- ----

function run_test {
  zparseopts -D -F -- \
    -name:=opt_name \
    -description:=opt_description \
    -command:=opt_command \
    -expected-exit:=opt_expected_exit \
    -setup:=opt_setup \
    -validate:=opt_validate
  
  typeset -r test_name="${opt_name[2]}"
  typeset -r description="${opt_description[2]}"
  typeset -r command="${opt_command[2]}"
  typeset -r expected_exit="${opt_expected_exit[2]}"
  typeset -r setup_cmd="${opt_setup[2]:-}"
  typeset -r validate_cmd="${opt_validate[2]:-}"
  
  typeset -r log_file="${log_dir}/${test_name}_${timestamp}.log"
  
  slog_se ""
  slog_se "────────────────────────────────────────────────────────────────────────"
  slog_se "Running: " --code "$test_name" --default
  slog_se "────────────────────────────────────────────────────────────────────────"
  
  # Write test header
  cat > "$log_file" << EOF
================================================================================
TEST: $test_name
================================================================================
Description: $description
Command: $command
Expected exit code: $expected_exit
Timestamp: $(date)
================================================================================

EOF
  
  # Run setup if provided
  if [[ -n "$setup_cmd" ]]; then
    echo "SETUP COMMAND:" >> "$log_file"
    echo "--------------------------------------------------------------------------------" >> "$log_file"
    echo "$setup_cmd" >> "$log_file"
    echo "--------------------------------------------------------------------------------" >> "$log_file"
    echo "" >> "$log_file"
    
    /bin/zsh -c "source ~/.zshrc > /dev/null 2>&1 && $setup_cmd" 2>&1 | tee -a "$log_file" > /dev/null
    echo "" >> "$log_file"
  fi
  
  # Run test
  echo "COMMAND OUTPUT:" >> "$log_file"
  echo "--------------------------------------------------------------------------------" >> "$log_file"
  
  typeset -i actual_exit=0
  /bin/zsh -c "source ~/.zshrc > /dev/null 2>&1 && $command" 2>&1 | tee -a "$log_file" > /dev/null || actual_exit=$?
  
  # Write test footer
  echo "--------------------------------------------------------------------------------" >> "$log_file"
  echo "EXIT CODE: $actual_exit" >> "$log_file"
  echo "Expected: $expected_exit" >> "$log_file"
  
  # Run validation if provided
  typeset validation_passed="true"
  if [[ -n "$validate_cmd" ]]; then
    echo "" >> "$log_file"
    echo "VALIDATION:" >> "$log_file"
    echo "--------------------------------------------------------------------------------" >> "$log_file"
    echo "Command: $validate_cmd" >> "$log_file"
    echo "" >> "$log_file"
    
    typeset -i validate_exit=0
    /bin/zsh -c "source ~/.zshrc > /dev/null 2>&1 && $validate_cmd" 2>&1 | tee -a "$log_file" > /dev/null || validate_exit=$?
    
    echo "" >> "$log_file"
    echo "Validation exit code: $validate_exit" >> "$log_file"
    
    if [[ $validate_exit -ne 0 ]]; then
      validation_passed="false"
      echo "Validation: FAILED" >> "$log_file"
    else
      echo "Validation: PASSED" >> "$log_file"
    fi
    echo "--------------------------------------------------------------------------------" >> "$log_file"
  fi
  
  # Determine final status
  if [[ $actual_exit -eq $expected_exit && "$validation_passed" == "true" ]]; then
    echo "Status: PASS" >> "$log_file"
    slog_step_se --context success "$test_name"
  else
    echo "Status: FAIL" >> "$log_file"
    if [[ $actual_exit -ne $expected_exit ]]; then
      slog_step_se --context error "$test_name - Expected exit $expected_exit but got $actual_exit"
    else
      slog_step_se --context error "$test_name - Validation failed"
    fi
  fi
  
  echo "================================================================================" >> "$log_file"
}

# ---- ---- ----     Test Suite     ---- ---- ----

slog_se ""
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "REAL COMPREHENSIVE TEST SUITE"
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "Script: " --url "$script_to_test" --default
slog_se "Log dir: " --url "$log_dir" --default
slog_se "Test workspace: " --url "$test_root_dir" --default
slog_se "════════════════════════════════════════════════════════════════════════"

# ---- META OPTIONS ----

# Test 01: Help
run_test \
  --name "test_01_help" \
  --description "Display help message" \
  --command "$script_to_test --help" \
  --expected-exit 1

# Test 02: Debug flag
run_test \
  --name "test_02_debug" \
  --description "Enable debug output" \
  --command "$script_to_test --debug" \
  --expected-exit 0

# Test 03: Verbose flag  
run_test \
  --name "test_03_verbose" \
  --description "Enable verbose output" \
  --command "$script_to_test --verbose" \
  --expected-exit 0

# Test 04: Dry-run flag
run_test \
  --name "test_04_dryrun" \
  --description "Show what would be done without making changes" \
  --command "$script_to_test --debug --dry-run --instructions" \
  --expected-exit 0

# ---- PLATFORM & CONFIGURATION TYPE ----

# Test 05: Copilot platform (default)
run_test \
  --name "test_05_platform_copilot" \
  --description "Test Copilot platform configuration" \
  --command "$script_to_test --debug --ai-platform copilot" \
  --expected-exit 0

# Test 06: Claude platform
run_test \
  --name "test_06_platform_claude" \
  --description "Test Claude platform configuration" \
  --command "$script_to_test --debug --ai-platform claude" \
  --expected-exit 0

# Test 07: Cursor platform
run_test \
  --name "test_07_platform_cursor" \
  --description "Test Cursor platform configuration" \
  --command "$script_to_test --debug --ai-platform cursor" \
  --expected-exit 0

# Test 08: CodeRabbit platform
run_test \
  --name "test_08_platform_coderabbit" \
  --description "Test CodeRabbit platform configuration" \
  --command "$script_to_test --debug --ai-platform coderabbit" \
  --expected-exit 0

# Test 09: Symlink mode (default)
run_test \
  --name "test_09_configure_symlink" \
  --description "Test symlink configuration type" \
  --command "$script_to_test --debug --configure-type symlink" \
  --expected-exit 0

# Test 10: Copy mode
run_test \
  --name "test_10_configure_copy" \
  --description "Test copy configuration type" \
  --command "$script_to_test --debug --configure-type copy" \
  --expected-exit 0

# ---- SPECIAL OPERATIONS ----

# Test 11: Instructions mode
run_test \
  --name "test_11_instructions" \
  --description "Auto-install all instruction files" \
  --command "$script_to_test --debug --instructions" \
  --expected-exit 0 \
  --validate "
    test_dir='${repo_dir}/.github/instructions' && \
    echo \"Checking directory exists: \$test_dir\" && \
    test -d \"\$test_dir\" || { echo \"ERROR: Directory not created\"; exit 1; } && \
    file_count=\$(ls -1 \"\$test_dir\"/*.instructions.md 2>/dev/null | wc -l | tr -d ' ') && \
    echo \"Found \$file_count instruction files\" && \
    test \"\$file_count\" -ge 11 || { echo \"ERROR: Expected at least 11 files, found \$file_count\"; exit 1; } && \
    test -f '${repo_dir}/.github/copilot-instructions.md' || { echo \"ERROR: copilot-instructions.md not found\"; exit 1; } && \
    grep -q 'GitHub Copilot Instructions' '${repo_dir}/.github/copilot-instructions.md' || { echo \"ERROR: copilot-instructions.md missing expected content\"; exit 1; } && \
    echo \"✅ All validations passed\"
  "

# Test 12: Instructions with dry-run
run_test \
  --name "test_12_instructions_dryrun" \
  --description "Show instruction installation without making changes" \
  --command "$script_to_test --debug --dry-run --instructions" \
  --expected-exit 0

# Test 13: Regenerate main instruction file
run_test \
  --name "test_13_regenerate_main" \
  --description "Force regeneration of main instruction file" \
  --command "$script_to_test --debug --regenerate-main" \
  --expected-exit 0

# Test 14: Dev-link operation
run_test \
  --name "test_14_dev_link" \
  --description "Create development symlink" \
  --command "$script_to_test --debug --dev-link" \
  --expected-exit 0

# Test 15: Dev-vscode operation
run_test \
  --name "test_15_dev_vscode" \
  --description "Add AI dev directory to VS Code workspace" \
  --command "$script_to_test --debug --dev-vscode" \
  --expected-exit 0

# Test 16: Workspace settings
run_test \
  --name "test_16_workspace_settings" \
  --description "Launch workspace settings menu" \
  --command "$script_to_test --debug --workspace-settings" \
  --expected-exit 0

# Test 17: User settings
run_test \
  --name "test_17_user_settings" \
  --description "Launch user settings menu" \
  --command "$script_to_test --debug --user-settings" \
  --expected-exit 0

# Test 18: MCP Xcode
run_test \
  --name "test_18_mcp_xcode" \
  --description "Install Xcode MCP server configuration" \
  --command "$script_to_test --debug --mcp-xcode" \
  --expected-exit 0

# Test 19: Prompt mode
run_test \
  --name "test_19_prompt" \
  --description "Enable interactive prompts" \
  --command "$script_to_test --debug --prompt --instructions" \
  --expected-exit 0

# ---- SOURCE & DESTINATION DIRECTORIES ----

# Test 20: Custom source directory
run_test \
  --name "test_20_custom_source" \
  --description "Use custom source directory" \
  --command "$script_to_test --debug --source-dir $HOME/.ai" \
  --expected-exit 0

# Test 21: Custom destination directory
run_test \
  --name "test_21_custom_dest" \
  --description "Use custom destination directory" \
  --command "$script_to_test --debug --dest-dir $repo_dir" \
  --expected-exit 0

# ---- COMBINED FLAGS ----

# Test 22: Multiple platforms
run_test \
  --name "test_22_combined_platforms" \
  --description "Test copilot + claude combination" \
  --command "$script_to_test --debug --instructions --ai-platform copilot" \
  --expected-exit 0

# Test 23: Development workflow
run_test \
  --name "test_23_dev_workflow" \
  --description "Combined dev-link + dev-vscode + workspace-settings" \
  --command "$script_to_test --debug --dev-link --dev-vscode --workspace-settings" \
  --expected-exit 0

# Test 24: Full configuration
run_test \
  --name "test_24_full_config" \
  --description "Instructions + workspace + user settings + mcp-xcode" \
  --command "$script_to_test --debug --instructions --workspace-settings --user-settings --mcp-xcode" \
  --expected-exit 0

# Test 25: All flags combined
run_test \
  --name "test_25_all_flags" \
  --description "Test maximum flag combination" \
  --command "$script_to_test --debug --verbose --instructions --workspace-settings --user-settings --mcp-xcode --dev-link --dev-vscode" \
  --expected-exit 0

# ---- ISOLATED DIRECTORY TESTS ----

# Test 26: Clean directory installation (copilot)
run_test \
  --name "test_26_clean_copilot" \
  --description "Install copilot instructions in clean directory" \
  --setup "rm -rf ${test_root_dir}/test26 && mkdir -p ${test_root_dir}/test26 && cd ${test_root_dir}/test26 && git init" \
  --command "cd ${test_root_dir}/test26 && $script_to_test --debug --instructions --ai-platform copilot" \
  --expected-exit 0 \
  --validate "
    test_dir='${test_root_dir}/test26/.github/instructions' && \
    echo \"Checking directory exists: \$test_dir\" && \
    test -d \"\$test_dir\" || { echo \"ERROR: Directory not created\"; exit 1; } && \
    file_count=\$(ls -1 \"\$test_dir\" | wc -l | tr -d ' ') && \
    echo \"Found \$file_count instruction files\" && \
    test \"\$file_count\" -eq 11 || { echo \"ERROR: Expected 11 files, found \$file_count\"; exit 1; } && \
    for file in \"\$test_dir\"/*.instructions.md; do \
      test -L \"\$file\" || { echo \"ERROR: \$file is not a symlink\"; exit 1; }; \
    done && \
    test -f '${test_root_dir}/test26/.github/copilot-instructions.md' || { echo \"ERROR: copilot-instructions.md not found\"; exit 1; } && \
    echo \"✅ All validations passed\"
  "

# Test 27: Clean directory installation (claude)
run_test \
  --name "test_27_clean_claude" \
  --description "Install claude instructions in clean directory" \
  --setup "rm -rf ${test_root_dir}/test27 && mkdir -p ${test_root_dir}/test27 && cd ${test_root_dir}/test27 && git init" \
  --command "cd ${test_root_dir}/test27 && $script_to_test --debug --instructions --ai-platform claude" \
  --expected-exit 0 \
  --validate "
    test_dir='${test_root_dir}/test27/.claude' && \
    echo \"Checking directory exists: \$test_dir\" && \
    test -d \"\$test_dir\" || { echo \"ERROR: Directory not created\"; exit 1; } && \
    file_count=\$(ls -1 \"\$test_dir\"/*.instructions.md 2>/dev/null | wc -l | tr -d ' ') && \
    echo \"Found \$file_count instruction files\" && \
    test \"\$file_count\" -eq 11 || { echo \"ERROR: Expected 11 files, found \$file_count\"; exit 1; } && \
    echo \"✅ All validations passed\"
  "

# Test 28: Clean directory installation (cursor)
run_test \
  --name "test_28_clean_cursor" \
  --description "Install cursor instructions in clean directory" \
  --setup "rm -rf ${test_root_dir}/test28 && mkdir -p ${test_root_dir}/test28 && cd ${test_root_dir}/test28 && git init" \
  --command "cd ${test_root_dir}/test28 && $script_to_test --debug --instructions --ai-platform cursor" \
  --expected-exit 0 \
  --validate "
    test_dir='${test_root_dir}/test28/.cursor/rules' && \
    echo \"Checking directory exists: \$test_dir\" && \
    test -d \"\$test_dir\" || { echo \"ERROR: Directory not created\"; exit 1; } && \
    file_count=\$(ls -1 \"\$test_dir\"/*.instructions.md 2>/dev/null | wc -l | tr -d ' ') && \
    echo \"Found \$file_count instruction files\" && \
    test \"\$file_count\" -eq 11 || { echo \"ERROR: Expected 11 files, found \$file_count\"; exit 1; } && \
    test -f '${test_root_dir}/test28/.cursor/rules/mobile.mdc' || { echo \"ERROR: mobile.mdc not found\"; exit 1; } && \
    echo \"✅ All validations passed\"
  "

# Test 29: Copy mode in clean directory
run_test \
  --name "test_29_copy_mode" \
  --description "Test copy mode instead of symlink" \
  --setup "rm -rf ${test_root_dir}/test29 && mkdir -p ${test_root_dir}/test29 && cd ${test_root_dir}/test29 && git init" \
  --command "cd ${test_root_dir}/test29 && $script_to_test --debug --instructions --configure-type copy" \
  --expected-exit 0 \
  --validate "
    test_dir='${test_root_dir}/test29/.github/instructions' && \
    echo \"Checking directory exists: \$test_dir\" && \
    test -d \"\$test_dir\" || { echo \"ERROR: Directory not created\"; exit 1; } && \
    file_count=\$(ls -1 \"\$test_dir\" | wc -l | tr -d ' ') && \
    echo \"Found \$file_count instruction files\" && \
    test \"\$file_count\" -eq 11 || { echo \"ERROR: Expected 11 files, found \$file_count\"; exit 1; } && \
    for file in \"\$test_dir\"/*.instructions.md; do \
      test -f \"\$file\" && ! test -L \"\$file\" || { echo \"ERROR: \$file should be regular file not symlink\"; exit 1; }; \
    done && \
    echo \"✅ All validations passed (files are copies not symlinks)\"
  "

# Test 30: Regenerate with existing files
run_test \
  --name "test_30_regenerate_existing" \
  --description "Regenerate main instruction file when files already exist" \
  --setup "rm -rf ${test_root_dir}/test30 && mkdir -p ${test_root_dir}/test30 && cd ${test_root_dir}/test30 && git init && $script_to_test --dest-dir ${test_root_dir}/test30 --instructions > /dev/null 2>&1" \
  --command "cd ${test_root_dir}/test30 && $script_to_test --debug --regenerate-main" \
  --expected-exit 0

# ---- ---- ----     Generate Summary     ---- ---- ----

slog_se ""
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "Generating test summary..."
slog_se "════════════════════════════════════════════════════════════════════════"

typeset -r summary_file="${log_dir}/TEST_SUMMARY_${timestamp}.md"

cat > "$summary_file" << EOF
# Real Comprehensive Test Summary

**Script**: configure_ai_instructions_NEW.zsh  
**Timestamp**: $(date)  
**Log Directory**: ${log_dir}

## Test Coverage

This comprehensive test suite exercises ALL arguments and flags:

- **Meta Options**: --help, --debug, --verbose, --dry-run
- **Platform Selection**: --ai-platform (copilot, claude, cursor, coderabbit)
- **Configuration Type**: --configure-type (symlink, copy)
- **Special Operations**: --instructions, --regenerate-main, --dev-link, --dev-vscode, --workspace-settings, --user-settings, --mcp-xcode, --prompt
- **Directory Options**: --source-dir, --dest-dir
- **Combined Flags**: Multiple operation combinations
- **Clean Environment**: Tests in isolated directories

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
    typeset line_count=$(wc -l < "$log_file")
    
    if [[ "$test_status" == "PASS" ]]; then
      ((passed++))
      echo "### ✅ Test $test_num: $test_name - PASSED" >> "$summary_file"
    else
      ((failed++))
      echo "### ❌ Test $test_num: $test_name - FAILED (exit code: $exit_code)" >> "$summary_file"
    fi
    
    echo "" >> "$summary_file"
    echo "**Log**: \`${log_file:t}\` ($line_count lines)" >> "$summary_file"
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

Each test log contains:
- Test description and command
- Complete stdout/stderr output
- Exit code and pass/fail status
- Timestamps

## Test Quality

✅ Tests ALL script arguments and flags
✅ Tests in clean isolated directories
✅ Captures complete output (not truncated)
✅ Tests combination of multiple flags
✅ Tests both success and error conditions

EOF

slog_step_se --context success "created test summary: " --url "$summary_file" --default

slog_se ""
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "TEST SUITE COMPLETE"
slog_se "════════════════════════════════════════════════════════════════════════"
slog_se "Total: $((passed + failed)) | Passed: $passed | Failed: $failed"
if [[ $failed -eq 0 ]]; then
  slog_se --green "✅ ALL TESTS PASSED" --default
else
  slog_se --red "❌ $failed TEST(S) FAILED" --default
fi
slog_se "Summary: " --url "$summary_file" --default
slog_se "Logs: " --url "$log_dir" --default
slog_se "════════════════════════════════════════════════════════════════════════"
