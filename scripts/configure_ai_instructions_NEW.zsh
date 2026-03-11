#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash # trick shellcheck into working with zsh
# shellcheck disable=SC2296 # Falsely identifies zsh expansions
# shellcheck disable=SC1091 # Complains about sourcing without literal path
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Configure AI instructions for various platforms (copilot, claude, cursor, etc.)
# Author: Zakk Hoyt
# Usage: ./configure_ai_instructions.zsh [OPTIONS]
#
# This script helps install AI instruction files to target projects for different AI platforms.
# It maintains a user-level source of truth and can copy or symlink files to target directories.
# Supports special operations like VS Code workspace configuration, MCP server setup, and
# development symlink creation.
#

# ---- ---- ----     Source Utilities     ---- ---- ----

source "$HOME/.zsh_home/utilities/.zsh_boilerplate"

# ---- ---- ----   Argument Parsing   ---- ---- ----

# Parse script-specific arguments (boilerplate already handled --help, --debug, --dry-run, --verbose)
zparseopts -D -E -- \
  -source-dir:=opt_source_dir \
  -dest-dir:=opt_dest_dir \
  -ai-platform:=opt_ai_platform \
  -configure-type:=opt_configure_type \
  -regenerate-main=flag_regenerate_main \
  -dev-link=flag_dev_link \
  -dev-vscode=flag_dev_vscode \
  -vscode-settings=flag_vscode_settings \
  -workspace-settings=flag_workspace_settings \
  -user-settings=flag_user_settings \
  -mcp-xcode=flag_mcp_xcode \
  -instructions=flag_instructions \
  -prompt=flag_prompt

# Extract values from zparseopts arrays
typeset -r user_ai_dir="${opt_source_dir[2]:-${Z2K_AI_DIR:-$HOME/.ai}}"
slog_var1_se_d "user_ai_dir"

typeset -r dest_dir="${opt_dest_dir[2]:-$PWD}"
slog_var1_se_d "dest_dir"

typeset -r configure_type="${opt_configure_type[2]:-symlink}"
slog_var1_se_d "configure_type"

typeset -r ai_platform="${opt_ai_platform[2]:-copilot}"
slog_var1_se_d "ai_platform"

# Convert flags to simple boolean variables
typeset -r flag_regenerate="${flag_regenerate_main[-1]:-}"
slog_var1_se_d "flag_regenerate"

typeset -r flag_dev_link_set="${flag_dev_link[-1]:-}"
slog_var1_se_d "flag_dev_link_set"

typeset -r flag_dev_vscode_set="${flag_dev_vscode[-1]:-}"
slog_var1_se_d "flag_dev_vscode_set"

typeset -r flag_workspace_set="${flag_workspace_settings[-1]:-${flag_vscode_settings[-1]:-}}"
slog_var1_se_d "flag_workspace_set"

typeset -r flag_user_settings_set="${flag_user_settings[-1]:-}"
slog_var1_se_d "flag_user_settings_set"

typeset -r flag_mcp_xcode_set="${flag_mcp_xcode[-1]:-}"
slog_var1_se_d "flag_mcp_xcode_set"

typeset -r flag_instructions_set="${flag_instructions[-1]:-}"
slog_var1_se_d "flag_instructions_set"

typeset -r flag_prompt_set="${flag_prompt[-1]:-}"
slog_var1_se_d "flag_prompt_set"

# Deprecation warning for old flag name
if [[ -n "${flag_vscode_settings[-1]:-}" && -z "${flag_workspace_settings[-1]:-}" ]]; then
  slog_step_se --context warning "--vscode-settings is deprecated; please use --workspace-settings"
fi

# ---- ---- ----   Help Function   ---- ---- ----

function print_usage {
  typeset -r script_name="${0:A:t}"
  typeset -r i2="${INDENT_2:-  }"
  typeset -r i4="${INDENT_4:-    }"
  typeset -r i6="${i2}${i4}"

  # SYNOPSIS
  slog_se --bold "SYNOPSIS" --default
  slog_se
  slog_se "${i2}" --code "${script_name} [OPTIONS]" --default
  slog_se

  # DESCRIPTION
  slog_se --bold "DESCRIPTION" --default
  slog_se "${i2}Configure AI instructions for various platforms by copying or symlinking"
  slog_se "${i2}instruction files from a central source to target project directories."
  slog_se

  # OPTIONS
  slog_se --bold "OPTIONS" --default
  slog_se
  slog_se "${i2}" --bold --italic "SOURCE & TARGET" --default
  slog_se "${i4}" --code '--source-dir <dir>' --default
  slog_se "${i6}User AI directory containing source instructions"
  slog_se "${i6}(default: \$Z2K_AI_DIR or \$HOME/.ai)"
  slog_se
  slog_se "${i4}" --code '--dest-dir <dir>' --default
  slog_se "${i6}Target directory to configure (must be git repo root)"
  slog_se "${i6}(default: current working directory)"
  slog_se
  slog_se "${i2}" --bold --italic "PLATFORM & TYPE" --default
  slog_se "${i4}" --code '--ai-platform <platform>' --default
  slog_se "${i6}AI platform to configure for"
  slog_se "${i6}Options: copilot, claude, cursor, coderabbit"
  slog_se "${i6}(default: copilot)"
  slog_se
  slog_se "${i4}" --code '--configure-type <type>' --default
  slog_se "${i6}How to install instructions"
  slog_se "${i6}Options: copy, symlink"
  slog_se "${i6}(default: symlink)"
  slog_se
  slog_se "${i2}" --bold --italic "SPECIAL OPERATIONS" --default
  slog_se "${i4}" --code '--instructions' --default
  slog_se "${i6}Auto-install all applicable instruction files"
  slog_se "${i6}Use with --prompt for interactive selection"
  slog_se
  slog_se "${i4}" --code '--regenerate-main' --default
  slog_se "${i6}Force regeneration of main instruction file from template"
  slog_se "${i6}WARNING: This will overwrite any custom edits"
  slog_se
  slog_se "${i4}" --code '--dev-link' --default
  slog_se "${i6}Create symlink to AI dev directory and update .gitignore"
  slog_se
  slog_se "${i4}" --code '--dev-vscode' --default
  slog_se "${i6}Add AI dev directory to VS Code workspace"
  slog_se
  slog_se "${i4}" --code '--workspace-settings' --default
  slog_se "${i6}Launch menu to merge VS Code workspace templates"
  slog_se
  slog_se "${i4}" --code '--user-settings' --default
  slog_se "${i6}Launch menu to merge VS Code user settings templates"
  slog_se
  slog_se "${i4}" --code '--mcp-xcode' --default
  slog_se "${i6}Install Xcode MCP server configuration"
  slog_se
  slog_se "${i4}" --code '--prompt' --default
  slog_se "${i6}Enable interactive prompts for installations"
  slog_se
  slog_se "${i2}" --bold --italic "META-OPTIONS" --default
  slog_se "${i4}" --code '--help' --default
  slog_se "${i6}Display this help message and exit"
  slog_se
  slog_se "${i4}" --code '--dry-run' --default
  slog_se "${i6}Show what would be done without making changes"
  slog_se

  # DEVELOPMENT OPTIONS
  slog_se --bold "DEVELOPMENT OPTIONS" --default
  slog_se
  slog_se "${i4}" --code '-d, --debug' --default
  slog_se "${i6}Enable debug output (can be specified multiple times)"
  slog_se "${i6}" --code '-d' --default "   Basic debug output"
  slog_se "${i6}" --code '-dd' --default "  Enable ERR trap debugging"
  slog_se "${i6}" --code '-ddd' --default " Enable ERR and EXIT trap debugging"
  slog_se
  slog_se "${i4}" --code '--trap-err, --debug-err' --default
  slog_se "${i6}Enable ERR trap handler"
  slog_se
  slog_se "${i4}" --code '--trap-exit, --debug-exit' --default
  slog_se "${i6}Enable EXIT trap handler"
  slog_se

  # ENVIRONMENT
  slog_se --bold "ENVIRONMENT" --default
  slog_se
  slog_se "${i4}" --code 'Z2K_AI_DIR' --default " Override default source directory location"
  slog_se

  # EXIT STATUS
  slog_se --bold "EXIT STATUS" --default
  slog_se
  slog_se "${i4}" --code '0' --default " Success"
  slog_se "${i4}" --code '1' --default " General error"
  slog_se "${i4}" --code '2' --default " Invalid arguments"
  slog_se "${i4}" --code '3' --default " Git repository validation failed"
  slog_se "${i4}" --code '4' --default " File operation failed"
  slog_se

  # EXAMPLES
  slog_se --bold "EXAMPLES" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Configure copilot instructions for current directory"
  slog_se "${i4}" --code "./${script_name}" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Configure claude instructions with copy mode"
  slog_se "${i4}" --code "./${script_name} --ai-platform claude --configure-type copy" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Development workflow"
  slog_se "${i4}" --code "./${script_name} --dev-link --dev-vscode --workspace-settings" --default
  slog_se

  return 1
}

# Display help if requested
if [[ -n "${flag_help:-}" ]]; then
  print_usage
  exit $?
fi

# ---- ---- ----   Variable Initialization   ---- ---- ----

# [step] Detect repository directory
slog_step_se_d --context will "detect repository directory"

typeset -r script_dir="${0:A:h}"
slog_var1_se_d "script_dir"

typeset -r repo_dir="${script_dir:h}"
slog_var1_se_d "repo_dir"

slog_step_se_d --context success "detected repository directory"

# TODO: Continue with rest of implementation
# This is just the conformant foundation - actual functionality to be added

slog_step_se --context info "Script execution complete (placeholder - full implementation in progress)"
