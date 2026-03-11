#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Configure AI instructions with action-based CLI architecture
# Author: Zakk Hoyt (with AI assistance)
# Usage: See print_usage() function or run with --help
#
# This is a complete overhaul of configure_ai_instructions.zsh implementing
# an action-based argument system where every action supports explicit
# --prompt <action> or --no-prompt <action> modes.
#
# Specification: scripts/CONFIGURE_AI_INSTRUCTIONS_OVERHAUL.md

# ---- ---- ----     Source Utilities     ---- ---- ----

source "$HOME/.zsh_home/utilities/.zsh_boilerplate"

# ---- ---- ----   Script Configuration   ---- ---- ----

typeset -r script_name="${0:t}"
typeset -r script_dir="${0:A:h}"
typeset -r repo_dir="${script_dir:h}"

# ---- ---- ----    Global Variables     ---- ---- ----

# Normalized target lists (populated by parser)
typeset -a enabled_targets=()
typeset -a prompt_targets=()
typeset -a auto_targets=()

# Valid target names
typeset -r -a VALID_SIMPLE_ACTIONS=(
  instructions
  dev-link
  dev-vscode
  regenerate-main
  mcp-xcode
)

typeset -r -a VALID_CONFIG_SCOPES=(
  user
  workspace
  folder
)

typeset -r -a VALID_CONFIG_CATEGORIES=(
  settings
  mcp
)

# ---- ---- ----      Help & Usage      ---- ---- ----

function print_usage {
  typeset -r i2="${INDENT_2:-  }"
  typeset -r i4="${INDENT_4:-    }"
  typeset -r i6="${i2}${i4}"

  slog_se --bold "NAME" --default
  slog_se "${i2}${script_name} - Configure AI instructions with action-based CLI"
  slog_se
  
  slog_se --bold "SYNOPSIS" --default
  slog_se "${i2}" --code "${script_name} [OPTIONS] [ACTIONS]" --default
  slog_se
  
  slog_se --bold "DESCRIPTION" --default
  slog_se "${i2}Action-based configuration tool for AI platform instructions,"
  slog_se "${i2}VS Code settings, and development environment setup."
  slog_se
  slog_se "${i2}Each action can run in prompt mode (interactive) or auto mode"
  slog_se "${i2}(automatic) by using --prompt or --no-prompt flags."
  slog_se
  
  slog_se --bold "ACTIONS" --default
  slog_se
  slog_se "${i2}" --bold "Simple Actions" --default
  slog_se "${i4}" --code "instructions" --default
  slog_se "${i6}Manage AI instruction file installation"
  slog_se "${i4}" --code "dev-link" --default
  slog_se "${i6}Create development repository symlink"
  slog_se "${i4}" --code "dev-vscode" --default
  slog_se "${i6}Add repository to VS Code workspace"
  slog_se "${i4}" --code "regenerate-main" --default
  slog_se "${i6}Regenerate main AI instruction file from template"
  slog_se "${i4}" --code "mcp-xcode" --default
  slog_se "${i6}Install Xcode MCP server configuration"
  slog_se
  
  slog_se "${i2}" --bold "Config Actions (Hierarchical)" --default
  slog_se "${i4}" --code "workspace-settings" --default
  slog_se "${i6}Manage VS Code workspace settings templates"
  slog_se "${i4}" --code "user-settings" --default
  slog_se "${i6}Manage VS Code user profile settings templates"
  slog_se
  
  slog_se --bold "OPTIONS" --default
  slog_se
  slog_se "${i2}" --bold "Action Mode Control" --default
  slog_se "${i4}" --code "--prompt <action>" --default
  slog_se "${i6}Run action in interactive/prompt mode (repeatable)"
  slog_se "${i4}" --code "--no-prompt <action>" --default
  slog_se "${i6}Run action in automatic mode (repeatable)"
  slog_se
  
  slog_se "${i2}" --bold "Configuration" --default
  slog_se "${i4}" --code "--source-dir <dir>" --default
  slog_se "${i6}User AI instructions directory (default: ~/.ai)"
  slog_se "${i4}" --code "--dest-dir <dir>" --default
  slog_se "${i6}Target repository directory (default: current dir)"
  slog_se "${i4}" --code "--ai-platform <platform>" --default
  slog_se "${i6}AI platform: copilot, claude, cursor, coderabbit (default: copilot)"
  slog_se "${i4}" --code "--configure-type <type>" --default
  slog_se "${i6}Installation method: symlink or copy (default: symlink)"
  slog_se
  
  slog_se "${i2}" --bold "Meta Options" --default
  slog_se "${i4}" --code "--help" --default
  slog_se "${i6}Display this help message and exit"
  slog_se "${i4}" --code "-d, --debug" --default
  slog_se "${i6}Enable debug output"
  slog_se "${i4}" --code "--dry-run" --default
  slog_se "${i6}Show what would be done without making changes"
  slog_se
  
  slog_se --bold "EXAMPLES" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Install instructions interactively"
  slog_se "${i4}" --code "./${script_name} --prompt instructions" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Auto-install all uninstalled instructions"
  slog_se "${i4}" --code "./${script_name} --no-prompt instructions" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Interactive workspace settings, auto instructions"
  slog_se "${i4}" --code "./${script_name} --prompt workspace-settings --no-prompt instructions" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Multiple actions, all interactive"
  slog_se "${i4}" --code "./${script_name} --prompt instructions --prompt mcp-xcode" --default
  slog_se
  
  slog_se --bold "EXIT STATUS" --default
  slog_se "${i4}" --code "0" --default " Success"
  slog_se "${i4}" --code "1" --default " General error or validation failure"
  slog_se
  
  return 1
}

# ---- ---- ----   Argument Parsing    ---- ---- ----

function parse_arguments {
  # Parse new-style action mode flags
  zparseopts -D -E -- \
    -prompt+:=opt_prompt_targets \
    -no-prompt+:=opt_no_prompt_targets \
    -source-dir:=opt_source_dir \
    -dest-dir:=opt_dest_dir \
    -ai-platform:=opt_ai_platform \
    -configure-type:=opt_configure_type
  
  # Extract values from zparseopts arrays (remove flag names, keep values only)
  # Note: Using global arrays, not local
  prompt_targets=(${opt_prompt_targets:#--prompt})
  auto_targets=(${opt_no_prompt_targets:#--no-prompt})
  
  # Validate targets
  validate_targets "prompt_targets" "auto_targets"
  
  # Build enabled_targets list (union of both)
  enabled_targets=("${prompt_targets[@]}" "${auto_targets[@]}")
  
  # Remove duplicates from enabled_targets
  enabled_targets=(${(u)enabled_targets[@]})
}

# ---- ---- ----   Target Validation   ---- ---- ----

function validate_targets {
  # Get array names as parameters (pass by name)
  typeset prompt_list_name="$1"
  typeset no_prompt_list_name="$2"
  
  # Get array contents using parameter expansion
  typeset -a prompt_list_copy=("${(@P)prompt_list_name}")
  typeset -a no_prompt_list_copy=("${(@P)no_prompt_list_name}")
  
  # Validate all targets
  for target in "${prompt_list_copy[@]}" "${no_prompt_list_copy[@]}"; do
    if ! is_valid_target "$target"; then
      slog_step_se --context fatal "invalid target: " --code "$target" --default
      slog_se "Valid targets:"
      slog_se "  Simple actions: ${(j:, :)VALID_SIMPLE_ACTIONS}"
      slog_se "  Config actions: workspace-settings, user-settings"
      exit 1
    fi
  done
  
  # Check for conflicts (same target in both prompt and no-prompt)
  for target in "${prompt_list_copy[@]}"; do
    if [[ " ${no_prompt_list_copy[*]} " == *" ${target} "* ]]; then
      slog_step_se --context fatal "target specified in both --prompt and --no-prompt: " --code "$target" --default
      slog_se "Choose one mode per target"
      exit 1
    fi
  done
}

function is_valid_target {
  typeset -r target="$1"
  
  # Check simple actions
  if [[ " ${VALID_SIMPLE_ACTIONS[*]} " == *" ${target} "* ]]; then
    return 0
  fi
  
  # Check grouped config actions
  if [[ "$target" == "workspace-settings" || "$target" == "user-settings" ]]; then
    return 0
  fi
  
  # Check config selector syntax: config-<scope>:<category>:<theme>
  if [[ "$target" =~ ^config-([^:]+):([^:]+):(.+)$ ]]; then
    typeset -r scope="${match[1]}"
    typeset -r category="${match[2]}"
    
    # Validate scope
    if [[ ! " ${VALID_CONFIG_SCOPES[*]} " == *" ${scope} "* ]]; then
      return 1
    fi
    
    # Validate category
    if [[ ! " ${VALID_CONFIG_CATEGORIES[*]} " == *" ${category} "* ]]; then
      return 1
    fi
    
    return 0
  fi
  
  return 1
}

# ---- ---- ----      Dispatcher       ---- ---- ----

function dispatch_actions {
  if [[ ${#enabled_targets[@]} -eq 0 ]]; then
    slog_step_se --context fatal "no actions specified. See --help for usage"
    exit 1
  fi
  
  for target in "${enabled_targets[@]}"; do
    if is_prompt_target "$target"; then
      slog_se
      slog_step_se --context info "running action: " --code "$target" --default " (prompt mode)"
      run_prompt_action "$target"
    else
      slog_se
      slog_step_se --context info "running action: " --code "$target" --default " (auto mode)"
      run_auto_action "$target"
    fi
  done
}

function is_prompt_target {
  typeset -r target="$1"
  [[ " ${prompt_targets[*]} " == *" ${target} "* ]]
}

# ---- ---- ----   Action Handlers    ---- ---- ----

function run_prompt_action {
  typeset -r target="$1"
  
  case "$target" in
    instructions)
      run_prompt_instructions
      ;;
    workspace-settings)
      run_prompt_workspace_settings
      ;;
    user-settings)
      run_prompt_user_settings
      ;;
    dev-link)
      run_prompt_dev_link
      ;;
    dev-vscode)
      run_prompt_dev_vscode
      ;;
    regenerate-main)
      run_prompt_regenerate_main
      ;;
    mcp-xcode)
      run_prompt_mcp_xcode
      ;;
    config-*)
      run_prompt_config_selector "$target"
      ;;
    *)
      slog_step_se --context fatal "unknown target in prompt mode: " --code "$target" --default
      exit 1
      ;;
  esac
}

function run_auto_action {
  typeset -r target="$1"
  
  case "$target" in
    instructions)
      run_auto_instructions
      ;;
    workspace-settings)
      run_auto_workspace_settings
      ;;
    user-settings)
      run_auto_user_settings
      ;;
    dev-link)
      run_auto_dev_link
      ;;
    dev-vscode)
      run_auto_dev_vscode
      ;;
    regenerate-main)
      run_auto_regenerate_main
      ;;
    mcp-xcode)
      run_auto_mcp_xcode
      ;;
    config-*)
      run_auto_config_selector "$target"
      ;;
    *)
      slog_step_se --context fatal "unknown target in auto mode: " --code "$target" --default
      exit 1
      ;;
  esac
}

# ---- ---- ----   Stub Handlers     ---- ---- ----

function run_prompt_instructions {
  slog_step_se --context info "Instructions (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_instructions {
  slog_step_se --context info "Instructions (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_workspace_settings {
  slog_step_se --context info "Workspace settings (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_workspace_settings {
  slog_step_se --context info "Workspace settings (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_user_settings {
  slog_step_se --context info "User settings (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_user_settings {
  slog_step_se --context info "User settings (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_dev_link {
  slog_step_se --context info "Dev link (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_dev_link {
  slog_step_se --context info "Dev link (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_dev_vscode {
  slog_step_se --context info "Dev VSCode (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_dev_vscode {
  slog_step_se --context info "Dev VSCode (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_regenerate_main {
  slog_step_se --context info "Regenerate main (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_regenerate_main {
  slog_step_se --context info "Regenerate main (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_mcp_xcode {
  slog_step_se --context info "MCP Xcode (prompt mode) - NOT YET IMPLEMENTED"
}

function run_auto_mcp_xcode {
  slog_step_se --context info "MCP Xcode (auto mode) - NOT YET IMPLEMENTED"
}

function run_prompt_config_selector {
  typeset -r target="$1"
  slog_step_se --context info "Config selector (prompt mode): " --code "$target" --default " - NOT YET IMPLEMENTED"
}

function run_auto_config_selector {
  typeset -r target="$1"
  slog_step_se --context info "Config selector (auto mode): " --code "$target" --default " - NOT YET IMPLEMENTED"
}

# ---- ---- ----   Main Execution    ---- ---- ----

function main {
  # Display help if requested
  if [[ -n "${flag_help:-}" ]]; then
    print_usage
    exit $?
  fi
  
  # Parse and validate arguments
  parse_arguments "$@"
  
  # Dispatch actions
  dispatch_actions
  
  slog_se
  slog_step_se --context success "All actions completed successfully"
}

main "$@"
