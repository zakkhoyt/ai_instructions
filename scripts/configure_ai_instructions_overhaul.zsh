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

# Initialize boilerplate-required variables before sourcing
[[ -z "${IS_DEBUG:-}" ]] && typeset IS_DEBUG=""
[[ -z "${IS_VERBOSE:-}" ]] && typeset IS_VERBOSE=""
[[ -z "${IS_UTILS_DEBUG:-}" ]] && typeset IS_UTILS_DEBUG=""
[[ -z "${IS_DRY_RUN:-}" ]] && typeset IS_DRY_RUN=""

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

# Configuration paths (set by parse_arguments or defaults)
typeset user_ai_dir="${HOME}/.ai"
typeset dest_dir="$(pwd)"
typeset ai_platform="copilot"
typeset configure_type="symlink"

# Derived paths (set after config paths are known)
typeset source_instructions_dir=""
typeset target_instructions_dir=""
typeset ai_platform_instruction_file=""
typeset ai_instruction_settings_file=""

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
  
  return 0
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
  
  # Extract configuration overrides
  [[ -n "${opt_source_dir[2]:-}" ]] && user_ai_dir="${opt_source_dir[2]}"
  [[ -n "${opt_dest_dir[2]:-}" ]] && dest_dir="${opt_dest_dir[2]}"
  [[ -n "${opt_ai_platform[2]:-}" ]] && ai_platform="${opt_ai_platform[2]}"
  [[ -n "${opt_configure_type[2]:-}" ]] && configure_type="${opt_configure_type[2]}"
  
  # Initialize derived paths
  initialize_paths
  
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

function initialize_paths {
  source_instructions_dir="$user_ai_dir/instructions"
  target_instructions_dir="$dest_dir/.github/instructions"
  
  case "$ai_platform" in
    copilot)
      ai_platform_instruction_file="$dest_dir/.github/copilot-instructions.md"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    claude)
      ai_platform_instruction_file="$dest_dir/.claude/instructions.md"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    cursor)
      ai_platform_instruction_file="$dest_dir/.cursorrules"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    coderabbit)
      ai_platform_instruction_file="$dest_dir/.coderabbit.yaml"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    *)
      slog_step_se --context fatal "unsupported AI platform: " --code "$ai_platform" --default
      exit 1
      ;;
  esac
  
  # Create target directory if needed
  mkdir -p "$target_instructions_dir" 2>/dev/null || true
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
  
  # Check grouped config actions (legacy aliases)
  if [[ "$target" == "workspace-settings" || "$target" == "user-settings" ]]; then
    return 0
  fi
  
  # Check config selector syntax: config-<scope>[:<category>][:<theme>]
  
  # Pattern 1: config-<scope>:<category>:<theme>
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
  
  # Pattern 2: config-<scope>:<category>
  if [[ "$target" =~ ^config-([^:]+):([^:]+)$ ]]; then
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
  
  # Pattern 3: config-<scope>
  if [[ "$target" =~ ^config-([^:]+)$ ]]; then
    typeset -r scope="${match[1]}"
    
    # Validate scope
    if [[ ! " ${VALID_CONFIG_SCOPES[*]} " == *" ${scope} "* ]]; then
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

# ---- ---- ----   Helper Functions   ---- ---- ----

function has_instructions_to_install {
  [[ -d "$source_instructions_dir" ]] && [[ -n "$(find "$source_instructions_dir" -type f -name "*.instructions.md" 2>/dev/null)" ]]
}

function get_file_checksum {
  zparseopts -D -F -- \
    -file-path:=opt_file_path
  
  typeset -r file_path="${opt_file_path[2]}"
  shasum -a 256 "$file_path" 2>/dev/null | awk '{print $1}'
}

function get_file_status {
  zparseopts -D -F -- \
    -file-basename:=opt_file_basename \
    -source-file:=opt_source_file \
    -checksum-file:=opt_checksum_file
  
  typeset -r file_basename="${opt_file_basename[2]}"
  typeset -r source_file="${opt_source_file[2]}"
  typeset -r checksum_file="${opt_checksum_file[2]}"
  
  # If no checksum file exists, all files are new
  if [[ ! -f "$checksum_file" ]]; then
    echo "new"
    return 0
  fi
  
  # Calculate current checksum
  typeset -r current_checksum="$(shasum -a 256 "$source_file" 2>/dev/null | awk '{print $1}')"
  
  # Look up stored checksum
  typeset -r stored_checksum="$(grep "^${file_basename}:" "$checksum_file" 2>/dev/null | cut -d: -f2)"
  
  if [[ -z "$stored_checksum" ]]; then
    echo "new"
  elif [[ "$current_checksum" != "$stored_checksum" ]]; then
    echo "modified"
  else
    echo "unchanged"
  fi
}

function format_status_indicator {
  zparseopts -D -F -- \
    -status:=opt_status
  
  typeset -r status_value="${opt_status[2]}"
  
  case "$status_value" in
    new)
      echo "🆕"
      ;;
    modified)
      echo "📝"
      ;;
    unchanged)
      echo "✓"
      ;;
    *)
      echo "?"
      ;;
  esac
}

function display_menu {
  typeset -a instruction_files=(${(f)"$(find "$source_instructions_dir" -type f -name "*.instructions.md" 2>/dev/null | sort)"})
  typeset -r checksum_file="$user_ai_dir/.gitignored/.ai-checksums"
  
  slog_se ""
  slog_se --bold "Available Instruction Files:" --default
  slog_se ""
  
  typeset -i idx=1
  for file in "${instruction_files[@]}"; do
    typeset file_basename="${file:t}"
    typeset source_file="$file"
    typeset file_status=$(get_file_status --file-basename "$file_basename" --source-file "$source_file" --checksum-file "$checksum_file")
    typeset indicator=$(format_status_indicator --status "$file_status")
    
    printf "%2d. %s %s\n" "$idx" "$indicator" "$file_basename"
    ((idx++))
  done
  
  slog_se ""
  slog_se --bold "Legend:" --default " 🆕 = new file, 📝 = modified, ✓ = unchanged"
  slog_se ""
  printf "Enter selections (e.g., '1 3 5', 'all', or press Enter to skip): "
  
  typeset user_input=""
  read -r user_input
  echo "$user_input"
}

function update_checksums {
  zparseopts -D -F -- \
    -file-basename:=opt_file_basename \
    -source-file:=opt_source_file \
    -checksum-file:=opt_checksum_file
  
  typeset -r file_basename="${opt_file_basename[2]}"
  typeset -r source_file="${opt_source_file[2]}"
  typeset -r checksum_file="${opt_checksum_file[2]}"
  
  typeset checksum=""
  checksum=$(get_file_checksum --file-path "$source_file")
  
  # Create checksum dir if needed
  mkdir -p "${checksum_file:h}" 2>/dev/null
  
  # Update or add checksum
  if [[ -f "$checksum_file" ]]; then
    # Remove old entry if exists
    grep -v "^${file_basename}:" "$checksum_file" > "${checksum_file}.tmp" 2>/dev/null || true
    mv "${checksum_file}.tmp" "$checksum_file"
  fi
  
  echo "${file_basename}:${checksum}" >> "$checksum_file"
}

function synthesize_copilot_instructions {
  typeset -r template_file="$user_ai_dir/ai_platforms/copilot/.github/copilot-instructions.template.md"
  typeset -r output_file="$ai_platform_instruction_file"
  
  slog_step_se_d --context will "synthesize copilot-instructions.md"
  
  if [[ ! -f "$template_file" ]]; then
    slog_step_se --context fatal "Template file not found: " --url "$template_file" --default
    return 1
  fi

  typeset project_overview="Add your project-specific overview here."
  typeset detected_languages="(not detected)"
  typeset detected_frameworks="(not detected)"
  typeset build_tools="(not detected)"
  
  typeset temp_file=""
  temp_file="$(mktemp)"
  
  cat "$template_file" > "$temp_file"
  
  sed -i.bak "s|<!-- PROJECT_OVERVIEW -->|$project_overview|g" "$temp_file"
  sed -i.bak "s|<!-- DETECTED_LANGUAGES -->|$detected_languages|g" "$temp_file"
  sed -i.bak "s|<!-- DETECTED_FRAMEWORKS -->|$detected_frameworks|g" "$temp_file"
  sed -i.bak "s|<!-- BUILD_TOOLS -->|$build_tools|g" "$temp_file"
  
  typeset instruction_list=""
  typeset -a instruction_files=(${(f)"$(find "$target_instructions_dir" -type f -name "*.instructions.md" 2>/dev/null | sort)"})
  
  typeset -a instruction_lines=()
  for file in "${instruction_files[@]}"; do
    typeset filename="${file:t}"
    typeset title="${filename%.instructions.md}"
    instruction_lines+=("- <a>${title}</a>")
  done
  
  instruction_list="${(F)instruction_lines[@]}"
  
  # Write instruction list to temp file for insertion
  typeset temp_list=""
  temp_list="$(mktemp)"
  echo "$instruction_list" > "$temp_list"
  
  # Use awk with getline to read from file (handles multiline correctly)
  awk -v listfile="$temp_list" '
    /<!-- INSTRUCTION_FILES_LIST -->/ {
      while ((getline line < listfile) > 0) {
        print line
      }
      close(listfile)
      next
    }
    { print }
  ' "$temp_file" > "$temp_file.new"
  
  mv "$temp_file.new" "$temp_file"
  rm -f "$temp_list" "${temp_file}.bak"
  
  mv "$temp_file" "$output_file" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "write synthesized instructions to: " --url "$output_file" --default
    return "$exit_code"
  }
  
  slog_step_se --context success "synthesized copilot-instructions.md"
}

# ---- ---- ----   Action Handlers    ---- ---- ----

function run_prompt_instructions {
  if ! has_instructions_to_install; then
    slog_step_se --context info "No instruction files found in: " --url "$source_instructions_dir" --default
    return 0
  fi
  
  typeset user_selection=""
  user_selection=$(display_menu)
  
  if [[ -z "$user_selection" ]]; then
    slog_step_se --context info "No files selected for installation"
    return 0
  fi
  
  install_selected_instructions "$user_selection"
}

function run_auto_instructions {
  if ! has_instructions_to_install; then
    slog_step_se --context info "No instruction files found in: " --url "$source_instructions_dir" --default
    return 0
  fi
  
  install_selected_instructions "all"
}

function install_selected_instructions {
  typeset -r user_selection="$1"
  
  typeset -a instruction_files=(${(f)"$(find "$source_instructions_dir" -type f -name "*.instructions.md" 2>/dev/null | sort)"})
  typeset -r checksum_file="$user_ai_dir/.gitignored/.ai-checksums"
  
  typeset -a selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((idx=1; idx<=${#instruction_files[@]}; idx++)); do
      selected_indices+=("$idx")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi
  
  for selection in "${selected_indices[@]}"; do
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#instruction_files[@]} )); then
      slog_step_se --context warning "Invalid selection: " --code "$selection" --default
      continue
    fi
    
    typeset source_file="${instruction_files[$selection]}"
    typeset file_basename="${source_file:t}"
    typeset dest_file="$target_instructions_dir/$file_basename"
    
    slog_step_se_d --context will "install instruction file: " --url "$file_basename" --default
    
    case "$configure_type" in
      symlink)
        ln -sf "$source_file" "$dest_file" || {
          typeset -i exit_code=$?
          slog_step_se --context fatal --exit-code "$exit_code" "create symlink for: " --url "$file_basename" --default
          continue
        }
        ;;
      copy)
        cp "$source_file" "$dest_file" || {
          typeset -i exit_code=$?
          slog_step_se --context fatal --exit-code "$exit_code" "copy file: " --url "$file_basename" --default
          continue
        }
        ;;
    esac
    
    update_checksums --file-basename "$file_basename" --source-file "$source_file" --checksum-file "$checksum_file"
    
    slog_step_se --context success "installed: " --url "$file_basename" --default
  done
  
  synthesize_copilot_instructions
}

function run_prompt_workspace_settings {
  typeset -r workspace_dir="$user_ai_dir/vscode/workspace"
  typeset -r dot_vscode_dir="$workspace_dir/.vscode"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - workspace settings merge requires jq"
    return 0
  fi
  
  if [[ ! -d "$workspace_dir" ]]; then
    slog_step_se --context info "No workspace templates directory found at: " --url "$workspace_dir" --default
    return 0
  fi
  
  setopt local_options null_glob
  typeset -a workspace_files=("$workspace_dir"/*.code-workspace(N))
  typeset -a config_files=("$dot_vscode_dir"/*.json(N))
  
  if [[ ${#workspace_files[@]} -eq 0 && ${#config_files[@]} -eq 0 ]]; then
    slog_step_se --context info "No workspace templates found in: " --url "$workspace_dir" --default
    return 0
  fi
  
  slog_se ""
  slog_se --bold "Workspace Templates Available:" --default
  slog_se ""
  
  typeset -i idx=1
  typeset -a all_files=()
  
  for file in "${workspace_files[@]}"; do
    all_files+=("$file")
    printf "%2d. [workspace] %s\n" "$idx" "${file:t}"
    ((idx++))
  done
  
  for file in "${config_files[@]}"; do
    all_files+=("$file")
    printf "%2d. [.vscode] %s\n" "$idx" "${file:t}"
    ((idx++))
  done
  
  slog_se ""
  printf "Enter selections (e.g., '1 3', 'all', or press Enter to skip): "
  
  typeset user_selection=""
  read -r user_selection
  
  if [[ -z "$user_selection" ]]; then
    slog_step_se --context info "Skipping workspace template merge"
    return 0
  fi
  
  merge_workspace_templates "$user_selection" "${all_files[@]}"
}

function run_auto_workspace_settings {
  typeset -r workspace_dir="$user_ai_dir/vscode/workspace"
  typeset -r dot_vscode_dir="$workspace_dir/.vscode"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - skipping workspace settings"
    return 0
  fi
  
  if [[ ! -d "$workspace_dir" ]]; then
    slog_step_se --context info "No workspace templates found"
    return 0
  fi
  
  setopt local_options null_glob
  typeset -a workspace_files=("$workspace_dir"/*.code-workspace(N))
  typeset -a config_files=("$dot_vscode_dir"/*.json(N))
  typeset -a all_files=("${workspace_files[@]}" "${config_files[@]}")
  
  if [[ ${#all_files[@]} -eq 0 ]]; then
    slog_step_se --context info "No workspace templates found"
    return 0
  fi
  
  merge_workspace_templates "all" "${all_files[@]}"
}

function merge_workspace_templates {
  typeset -r user_selection="$1"
  shift
  typeset -a template_files=("$@")
  
  typeset -a selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((idx=1; idx<=${#template_files[@]}; idx++)); do
      selected_indices+=("$idx")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi
  
  for selection in "${selected_indices[@]}"; do
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#template_files[@]} )); then
      slog_step_se --context warning "Invalid selection: " --code "$selection" --default
      continue
    fi
    
    typeset template_file="${template_files[$selection]}"
    typeset file_basename="${template_file:t}"
    typeset file_extension="${template_file:e}"
    
    slog_step_se_d --context will "merge template: " --url "$file_basename" --default
    
    typeset target_file=""
    if [[ "$file_extension" == "code-workspace" ]]; then
      target_file="$dest_dir/${file_basename}"
    else
      target_file="$dest_dir/.vscode/${file_basename}"
    fi
    
    if [[ ! -f "$target_file" ]]; then
      mkdir -p "${target_file:h}"
      cp "$template_file" "$target_file" || {
        typeset -i exit_code=$?
        slog_step_se --context warning --exit-code "$exit_code" "copy template: " --url "$file_basename" --default
        continue
      }
      slog_step_se --context success "created: " --url "$file_basename" --default
    else
      typeset temp_merged="/tmp/merged_$$.json"
      jq -s '.[0] * .[1]' "$target_file" "$template_file" > "$temp_merged" 2>/dev/null || {
        typeset -i exit_code=$?
        slog_step_se --context warning --exit-code "$exit_code" "merge template: " --url "$file_basename" --default
        rm -f "$temp_merged"
        continue
      }
      mv "$temp_merged" "$target_file"
      slog_step_se --context success "merged: " --url "$file_basename" --default
    fi
  done
}

function run_prompt_user_settings {
  typeset -r user_templates_dir="$user_ai_dir/vscode/user"
  typeset -r code_user_dir="$HOME/Library/Application Support/Code/User"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - user settings merge requires jq"
    return 0
  fi
  
  if [[ ! -d "$user_templates_dir" ]]; then
    slog_step_se --context info "No user settings templates found at: " --url "$user_templates_dir" --default
    return 0
  fi
  
  if [[ ! -d "$code_user_dir" ]]; then
    slog_step_se --context warning "VS Code user settings directory not found: " --url "$code_user_dir" --default
    return 0
  fi
  
  setopt local_options null_glob
  typeset -a user_files=("$user_templates_dir"/*.json(N))
  
  if [[ ${#user_files[@]} -eq 0 ]]; then
    slog_step_se --context info "No user settings templates to merge"
    return 0
  fi
  
  slog_se ""
  slog_se --bold "User Settings Templates Available:" --default
  slog_se ""
  
  typeset -i idx=1
  for file in "${user_files[@]}"; do
    printf "%2d. %s\n" "$idx" "${file:t}"
    ((idx++))
  done
  
  slog_se ""
  printf "Enter selections (e.g., '1 3', 'all', or press Enter to skip): "
  
  typeset user_selection=""
  read -r user_selection
  
  if [[ -z "$user_selection" ]]; then
    slog_step_se --context info "Skipping user settings merge"
    return 0
  fi
  
  merge_user_templates "$user_selection" "$code_user_dir" "${user_files[@]}"
}

function run_auto_user_settings {
  typeset -r user_templates_dir="$user_ai_dir/vscode/user"
  typeset -r code_user_dir="$HOME/Library/Application Support/Code/User"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - skipping user settings"
    return 0
  fi
  
  if [[ ! -d "$user_templates_dir" ]]; then
    slog_step_se --context info "No user settings templates found"
    return 0
  fi
  
  if [[ ! -d "$code_user_dir" ]]; then
    slog_step_se --context warning "VS Code user settings directory not found"
    return 0
  fi
  
  setopt local_options null_glob
  typeset -a user_files=("$user_templates_dir"/*.json(N))
  
  if [[ ${#user_files[@]} -eq 0 ]]; then
    slog_step_se --context info "No user settings templates found"
    return 0
  fi
  
  merge_user_templates "all" "$code_user_dir" "${user_files[@]}"
}

function merge_user_templates {
  typeset -r user_selection="$1"
  typeset -r code_user_dir="$2"
  shift 2
  typeset -a template_files=("$@")
  
  typeset -a selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((idx=1; idx<=${#template_files[@]}; idx++)); do
      selected_indices+=("$idx")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi
  
  for selection in "${selected_indices[@]}"; do
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#template_files[@]} )); then
      slog_step_se --context warning "Invalid selection: " --code "$selection" --default
      continue
    fi
    
    typeset template_file="${template_files[$selection]}"
    typeset file_basename="${template_file:t}"
    typeset target_file="$code_user_dir/$file_basename"
    
    slog_step_se_d --context will "merge user template: " --url "$file_basename" --default
    
    if [[ ! -f "$target_file" ]]; then
      cp "$template_file" "$target_file" || {
        typeset -i exit_code=$?
        slog_step_se --context warning --exit-code "$exit_code" "copy template: " --url "$file_basename" --default
        continue
      }
      slog_step_se --context success "created: " --url "$file_basename" --default
    else
      typeset temp_merged="/tmp/merged_$$.json"
      jq -s '.[0] * .[1]' "$target_file" "$template_file" > "$temp_merged" 2>/dev/null || {
        typeset -i exit_code=$?
        slog_step_se --context warning --exit-code "$exit_code" "merge template: " --url "$file_basename" --default
        rm -f "$temp_merged"
        continue
      }
      mv "$temp_merged" "$target_file"
      slog_step_se --context success "merged: " --url "$file_basename" --default
    fi
  done
}

function run_prompt_dev_link {
  slog_step_se_d --context will "create development repository symlink"
  
  typeset -r link_path="$dest_dir/ai"
  typeset -r target_path="$user_ai_dir"
  
  if [[ -L "$link_path" ]]; then
    typeset current_target=""
    current_target="$(readlink "$link_path")"
    
    if [[ "$current_target" == "$target_path" ]]; then
      slog_step_se --context info "Development symlink already exists and points to correct location"
      return 0
    fi
    
    slog_se "Existing symlink points to different location:"
    slog_se "  Current: " --url "$current_target" --default
    slog_se "  Desired: " --url "$target_path" --default
    slog_se ""
    printf "Replace existing symlink? (y/N): "
    
    typeset response=""
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      slog_step_se --context info "Skipping symlink creation"
      return 0
    fi
    
    rm "$link_path"
  elif [[ -e "$link_path" ]]; then
    slog_step_se --context fatal "Path exists but is not a symlink: " --url "$link_path" --default
    return 1
  fi
  
  ln -s "$target_path" "$link_path" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "create symlink: " --url "$link_path" --default
    return "$exit_code"
  }
  
  slog_step_se --context success "created development symlink: " --url "$link_path" --default " → " --url "$target_path" --default
}

function run_auto_dev_link {
  slog_step_se_d --context will "create development repository symlink (auto mode)"
  
  typeset -r link_path="$dest_dir/ai"
  typeset -r target_path="$user_ai_dir"
  
  if [[ -L "$link_path" ]]; then
    typeset current_target=""
    current_target="$(readlink "$link_path")"
    
    if [[ "$current_target" == "$target_path" ]]; then
      slog_step_se --context info "Development symlink already correct"
      return 0
    fi
    
    rm "$link_path"
  elif [[ -e "$link_path" ]]; then
    slog_step_se --context warning "Path exists but is not a symlink (skipping): " --url "$link_path" --default
    return 0
  fi
  
  ln -s "$target_path" "$link_path" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "create symlink: " --url "$link_path" --default
    return "$exit_code"
  }
  
  slog_step_se --context success "created development symlink: " --url "$link_path" --default
}

function run_prompt_dev_vscode {
  slog_step_se_d --context will "add dev repository folder to VS Code workspace"
  
  typeset -r link_path="$dest_dir/ai"
  
  if [[ ! -L "$link_path" && ! -d "$link_path" ]]; then
    slog_step_se --context warning "Development folder not found at: " --url "$link_path" --default
    slog_se "Run " --code "--prompt dev-link" --default " first to create the symlink"
    return 0
  fi
  
  setopt local_options null_glob
  typeset -a workspace_files=("$dest_dir"/*.code-workspace(N))
  
  if [[ ${#workspace_files[@]} -eq 0 ]]; then
    slog_step_se --context info "No VS Code workspace file found in: " --url "$dest_dir" --default
    return 0
  fi
  
  typeset workspace_file="${workspace_files[1]}"
  slog_se "Workspace file: " --url "${workspace_file:t}" --default
  slog_se ""
  printf "Add dev folder to workspace? (y/N): "
  
  typeset response=""
  read -r response
  
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    slog_step_se --context info "Skipping dev folder addition"
    return 0
  fi
  
  add_dev_folder_to_workspace "$workspace_file" "$link_path"
}

function run_auto_dev_vscode {
  slog_step_se_d --context will "add dev repository folder to VS Code workspace (auto mode)"
  
  typeset -r link_path="$dest_dir/ai"
  
  if [[ ! -L "$link_path" && ! -d "$link_path" ]]; then
    slog_step_se --context info "Development folder not found, skipping"
    return 0
  fi
  
  setopt local_options null_glob
  typeset -a workspace_files=("$dest_dir"/*.code-workspace(N))
  
  if [[ ${#workspace_files[@]} -eq 0 ]]; then
    slog_step_se --context info "No VS Code workspace file found"
    return 0
  fi
  
  typeset workspace_file="${workspace_files[1]}"
  add_dev_folder_to_workspace "$workspace_file" "$link_path"
}

function add_dev_folder_to_workspace {
  typeset -r workspace_file="$1"
  typeset -r dev_path="$2"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - cannot modify workspace file"
    return 0
  fi
  
  typeset temp_workspace="/tmp/workspace_$$.json"
  
  if jq -e '.folders[] | select(.path == "ai")' "$workspace_file" >/dev/null 2>&1; then
    slog_step_se --context info "Dev folder already in workspace"
    return 0
  fi
  
  jq '.folders += [{"path": "ai"}]' "$workspace_file" > "$temp_workspace" || {
    typeset -i exit_code=$?
    slog_step_se --context warning --exit-code "$exit_code" "add dev folder to workspace"
    rm -f "$temp_workspace"
    return 0
  }
  
  mv "$temp_workspace" "$workspace_file"
  slog_step_se --context success "added dev folder to workspace: " --url "${workspace_file:t}" --default
}

function run_prompt_regenerate_main {
  slog_step_se_d --context will "regenerate main AI instruction file"
  
  slog_se "This will regenerate: " --url "$ai_platform_instruction_file" --default
  slog_se ""
  printf "Continue? (y/N): "
  
  typeset response=""
  read -r response
  
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    slog_step_se --context info "Skipping regeneration"
    return 0
  fi
  
  synthesize_copilot_instructions
}

function run_auto_regenerate_main {
  slog_step_se_d --context will "regenerate main AI instruction file (auto mode)"
  synthesize_copilot_instructions
}

function run_prompt_mcp_xcode {
  if is_xcode_mcp_installed; then
    slog_step_se --context info "Xcode MCP Server already installed"
    return 0
  fi
  
  slog_se ""
  slog_se --bold "Xcode MCP Server Installation" --default
  slog_se "This will install:"
  slog_se "  • Xcode MCP workspace template"
  slog_se "  • Swift workspace template"
  slog_se "  • Xcode MCP server configuration (.vscode/mcp.json)"
  slog_se ""
  printf "Install Xcode MCP Server? (y/N): "
  
  typeset response=""
  read -r response
  
  if [[ ! "$response" =~ ^[Yy]$ ]]; then
    slog_step_se --context info "Skipping Xcode MCP installation"
    return 0
  fi
  
  install_xcode_mcp_templates
}

function run_auto_mcp_xcode {
  if is_xcode_mcp_installed; then
    slog_step_se --context info "Xcode MCP Server already installed"
    return 0
  fi
  
  install_xcode_mcp_templates
}

function is_xcode_mcp_installed {
  typeset -r mcp_file="$dest_dir/.vscode/mcp.json"
  
  if [[ ! -f "$mcp_file" ]]; then
    return 1
  fi
  
  if type jq >/dev/null 2>&1; then
    if jq -e '.mcpServers."xcode-mcp-server"' "$mcp_file" >/dev/null 2>&1; then
      return 0
    fi
  else
    if grep -q "xcode-mcp-server" "$mcp_file"; then
      return 0
    fi
  fi
  
  return 1
}

function install_xcode_mcp_templates {
  typeset -r workspace_dir="$user_ai_dir/vscode/workspace"
  typeset success_count=0
  typeset attempted_count=0
  typeset already_exists_count=0
  
  slog_step_se_d --context trace "workspace_dir: " --url "$workspace_dir" --default
  slog_step_se_d --context trace "dest_dir: " --url "$dest_dir" --default
  
  typeset -a templates=(
    "$workspace_dir/xcode-mcpserver__workspace.code-workspace"
    "$workspace_dir/swift__workspace.code-workspace"
    "$workspace_dir/.vscode/xcode-mcpserver__mcp.json"
  )
  
  for template in "${templates[@]}"; do
    slog_step_se_d --context trace "checking template: " --url "$template" --default
    if [[ ! -f "$template" ]]; then
      slog_step_se --context warning "Template not found: " --url "${template:t}" --default
      continue
    fi
    slog_step_se_d --context trace "template exists: " --url "${template:t}" --default
    
    typeset file_basename="${template:t}"
    typeset file_extension="${template:e}"
    typeset target_file=""
    
    if [[ "$file_extension" == "code-workspace" ]]; then
      target_file="$dest_dir/${file_basename}"
    else
      target_file="$dest_dir/.vscode/${file_basename}"
    fi
    
    mkdir -p "${target_file:h}"
    
    if [[ ! -f "$target_file" ]]; then
      attempted_count=$(( attempted_count + 1 ))
      cp "$template" "$target_file" || {
        typeset -i exit_code=$?
        slog_step_se --context warning --exit-code "$exit_code" "install template: " --url "$file_basename" --default
        continue
      }
      success_count=$(( success_count + 1 ))
      slog_step_se --context success "installed: " --url "$file_basename" --default
    else
      if type jq >/dev/null 2>&1 && [[ "$file_extension" == "json" ]]; then
        attempted_count=$(( attempted_count + 1 ))
        typeset temp_merged="/tmp/merged_$$.json"
        jq -s '.[0] * .[1]' "$target_file" "$template" > "$temp_merged" 2>/dev/null || {
          typeset -i exit_code=$?
          slog_step_se --context warning --exit-code "$exit_code" "merge template: " --url "$file_basename" --default " (template contains JSON comments - skipping merge)"
          rm -f "$temp_merged"
          already_exists_count=$(( already_exists_count + 1 ))
          continue
        }
        mv "$temp_merged" "$target_file"
        success_count=$(( success_count + 1 ))
        slog_step_se --context success "merged: " --url "$file_basename" --default
      else
        already_exists_count=$(( already_exists_count + 1 ))
        slog_step_se --context info "template already exists: " --url "$file_basename" --default
      fi
    fi
  done
  
  typeset -i total_final=$(( success_count + already_exists_count ))
  if (( total_final >= ${#templates[@]} )); then
    slog_step_se --context success "Xcode MCP templates ready (installed: $success_count, already present: $already_exists_count)"
    return 0
  elif (( success_count > 0 )); then
    slog_step_se --context success "Xcode MCP Server partial installation complete (installed: $success_count)"
    return 0
  else
    slog_step_se --context warning "Xcode MCP template installation failed (no templates installed)"
    return 1
  fi
}

# ---- ---- ----  Config Selector Parser  ---- ---- ----

function parse_config_selector {
  # Parse config selector: config-<scope>[:<category>][:<theme>]
  # Args:
  #   $1: selector string (e.g., "config-user:settings:swift")
  # Outputs (via named variables):
  #   selector_scope: scope (user|workspace|folder)
  #   selector_category: category (settings|mcp|tasks|launch) or empty
  #   selector_theme: theme name or empty
  # Returns: 0 on success, 1 on parse failure
  
  typeset -r selector="$1"
  slog_var1_se_d "selector"
  
  # Reset output variables
  selector_scope=""
  selector_category=""
  selector_theme=""
  
  # Pattern: config-<scope>:<category>:<theme>
  if [[ "$selector" =~ ^config-([^:]+):([^:]+):(.+)$ ]]; then
    selector_scope="${match[1]}"
    selector_category="${match[2]}"
    selector_theme="${match[3]}"
    slog_var1_se_d "selector_scope"
    slog_var1_se_d "selector_category"
    slog_var1_se_d "selector_theme"
    return 0
  fi
  
  # Pattern: config-<scope>:<category>
  if [[ "$selector" =~ ^config-([^:]+):([^:]+)$ ]]; then
    selector_scope="${match[1]}"
    selector_category="${match[2]}"
    selector_theme=""
    slog_var1_se_d "selector_scope"
    slog_var1_se_d "selector_category"
    slog_var1_se_d "selector_theme"
    return 0
  fi
  
  # Pattern: config-<scope>
  if [[ "$selector" =~ ^config-([^:]+)$ ]]; then
    selector_scope="${match[1]}"
    selector_category=""
    selector_theme=""
    slog_var1_se_d "selector_scope"
    slog_var1_se_d "selector_category"
    slog_var1_se_d "selector_theme"
    return 0
  fi
  
  # Parse failed
  slog_step_se --context fatal "invalid config selector syntax: " --code "$selector" --default
  return 1
}

# ---- ---- ----  Template Discovery  ---- ---- ----

function discover_templates {
  # Discover all template files in vscode/ directory tree
  # Args:
  #   $1: scope (user|workspace|folder)
  #   $2: category filter (optional, empty for all)
  #   $3: theme filter (optional, empty for all)
  # Outputs: Array of matching template file paths (via stdout, one per line)
  # Returns: 0 if templates found, 1 if none found
  
  typeset -r filter_scope="$1"
  typeset -r filter_category="${2:-}"
  typeset -r filter_theme="${3:-}"
  
  slog_var1_se_d "filter_scope"
  slog_var1_se_d "filter_category"
  slog_var1_se_d "filter_theme"
  
  # Map scope to directory
  typeset scope_dir=""
  case "$filter_scope" in
    user)
      scope_dir="${vscode_user_dir}"
      ;;
    workspace)
      scope_dir="${vscode_workspace_dir}"
      ;;
    folder)
      scope_dir="${vscode_folder_dir}"
      ;;
    *)
      slog_step_se --context fatal "invalid scope: " --code "$filter_scope" --default
      return 1
      ;;
  esac
  
  slog_var1_se_d "scope_dir"
  
  # Verify directory exists
  if [[ ! -d "$scope_dir" ]]; then
    slog_step_se --context warning "scope directory does not exist: " --url "$scope_dir" --default
    return 1
  fi
  
  # Discover all JSON files in scope directory
  typeset -a all_templates
  all_templates=()
  
  while IFS= read -r template_file; do
    all_templates+=("$template_file")
  done < <(find "$scope_dir" -type f -name "*.json" 2>/dev/null | sort)
  
  slog_var1_se_d "all_templates"
  
  if [[ ${#all_templates[@]} -eq 0 ]]; then
    slog_step_se --context warning "no templates found in: " --url "$scope_dir" --default
    return 1
  fi
  
  # Filter by category if specified
  typeset -a filtered_templates
  filtered_templates=("${all_templates[@]}")
  
  if [[ -n "$filter_category" ]]; then
    typeset -a category_filtered
    category_filtered=()
    
    for template_file in "${filtered_templates[@]}"; do
      typeset -r basename="${template_file:t}"
      
      # Category detection rules:
      # - settings.json → settings category
      # - *__mcp.json → mcp category
      # - tasks.json → tasks category
      # - launch.json → launch category
      
      typeset matched_category=""
      
      if [[ "$basename" == "settings.json" ]]; then
        matched_category="settings"
      elif [[ "$basename" == *"__mcp.json" ]]; then
        matched_category="mcp"
      elif [[ "$basename" == "tasks.json" ]]; then
        matched_category="tasks"
      elif [[ "$basename" == "launch.json" ]]; then
        matched_category="launch"
      fi
      
      if [[ "$matched_category" == "$filter_category" ]]; then
        category_filtered+=("$template_file")
      fi
    done
    
    filtered_templates=("${category_filtered[@]}")
  fi
  
  slog_var1_se_d "filtered_templates"
  
  # Filter by theme if specified
  if [[ -n "$filter_theme" ]]; then
    typeset -a theme_filtered
    theme_filtered=()
    
    for template_file in "${filtered_templates[@]}"; do
      typeset -r basename="${template_file:t}"
      typeset -r dirname="${template_file:h:t}"
      
      # Theme detection rules:
      # - Filename contains theme (e.g., "swift-settings.json" → swift)
      # - Directory name matches theme (e.g., "xcode/" → xcode)
      # - Prefix before "__mcp.json" (e.g., "xcode-mcpserver__mcp.json" → xcode-mcpserver)
      
      typeset matched_theme=""
      
      # Check directory name
      if [[ "$dirname" == "$filter_theme" ]]; then
        matched_theme="$filter_theme"
      fi
      
      # Check filename prefix
      if [[ "$basename" == "${filter_theme}"* ]]; then
        matched_theme="$filter_theme"
      fi
      
      # Check MCP prefix pattern
      if [[ "$basename" == *"__mcp.json" ]]; then
        typeset -r mcp_prefix="${basename/__mcp.json/}"
        if [[ "$mcp_prefix" == "$filter_theme" ]]; then
          matched_theme="$filter_theme"
        fi
      fi
      
      if [[ -n "$matched_theme" ]]; then
        theme_filtered+=("$template_file")
      fi
    done
    
    filtered_templates=("${theme_filtered[@]}")
  fi
  
  slog_var1_se_d "filtered_templates"
  
  if [[ ${#filtered_templates[@]} -eq 0 ]]; then
    slog_step_se --context warning "no templates matched filters"
    return 1
  fi
  
  # Output matched templates (one per line)
  for template_file in "${filtered_templates[@]}"; do
    echo "$template_file"
  done
  
  return 0
}

# ---- ---- ----  Config Selector Handlers  ---- ---- ----

function run_prompt_config_selector {
  typeset -r target="$1"
  slog_step_se_d --context will "execute config selector (prompt mode): " --code "$target" --default
  
  # Parse selector
  parse_config_selector "$target" || return 1
  
  # Discover matching templates
  typeset -a matched_templates
  matched_templates=()
  
  while IFS= read -r template_file; do
    matched_templates+=("$template_file")
  done < <(discover_templates "$selector_scope" "$selector_category" "$selector_theme")
  
  slog_var1_se_d "matched_templates"
  
  if [[ ${#matched_templates[@]} -eq 0 ]]; then
    slog_step_se --context warning "no templates matched selector: " --code "$target" --default
    return 0
  fi
  
  slog_step_se --context info "Found " --code "${#matched_templates[@]}" --default " template(s) matching selector"
  
  # Show menu and prompt user to select templates
  slog_se
  slog_se "Available templates:"
  
  typeset -i index=1
  for template_file in "${matched_templates[@]}"; do
    typeset -r relative_path="${template_file#${vscode_dir}/}"
    slog_se "  " --code "${index}." --default " ${relative_path}"
    index=$(( index + 1 ))
  done
  
  slog_se
  slog_se "Enter template numbers to merge (space-separated), 'all', or 'skip':"
  read -r selection
  
  slog_var1_se_d "selection"
  
  if [[ "$selection" == "skip" ]]; then
    slog_step_se --context info "user skipped config selector"
    return 0
  fi
  
  typeset -a selected_templates
  selected_templates=()
  
  if [[ "$selection" == "all" ]]; then
    selected_templates=("${matched_templates[@]}")
  else
    # Parse space-separated indices
    typeset -a indices
    indices=(${(s: :)selection})
    
    for idx in "${indices[@]}"; do
      if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx >= 1 && idx <= ${#matched_templates[@]} )); then
        selected_templates+=("${matched_templates[$idx]}")
      else
        slog_step_se --context warning "invalid selection: " --code "$idx" --default
      fi
    done
  fi
  
  slog_var1_se_d "selected_templates"
  
  if [[ ${#selected_templates[@]} -eq 0 ]]; then
    slog_step_se --context info "no templates selected"
    return 0
  fi
  
  # Merge selected templates
  typeset -i merge_success_count=0
  typeset -i merge_failure_count=0
  
  for template_file in "${selected_templates[@]}"; do
    typeset -r relative_path="${template_file#${vscode_dir}/}"
    slog_step_se_d --context will "merge template: " --url "$relative_path" --default
    
    if merge_template "$template_file" "$selector_scope"; then
      slog_step_se_d --context success "merged template: " --url "$relative_path" --default
      merge_success_count=$(( merge_success_count + 1 ))
    else
      slog_step_se --context warning "failed to merge template: " --url "$relative_path" --default
      merge_failure_count=$(( merge_failure_count + 1 ))
    fi
  done
  
  slog_step_se --context success "Merged " --code "$merge_success_count" --default " template(s) (failed: " --code "$merge_failure_count" --default ")"
  
  return 0
}

function run_auto_config_selector {
  typeset -r target="$1"
  slog_step_se_d --context will "execute config selector (auto mode): " --code "$target" --default
  
  # Parse selector
  parse_config_selector "$target" || return 1
  
  # Discover matching templates
  typeset -a matched_templates
  matched_templates=()
  
  while IFS= read -r template_file; do
    matched_templates+=("$template_file")
  done < <(discover_templates "$selector_scope" "$selector_category" "$selector_theme")
  
  slog_var1_se_d "matched_templates"
  
  if [[ ${#matched_templates[@]} -eq 0 ]]; then
    slog_step_se --context warning "no templates matched selector: " --code "$target" --default
    return 0
  fi
  
  slog_step_se --context info "Auto-merging " --code "${#matched_templates[@]}" --default " template(s)"
  
  # Auto-merge all matched templates
  typeset -i merge_success_count=0
  typeset -i merge_failure_count=0
  
  for template_file in "${matched_templates[@]}"; do
    typeset -r relative_path="${template_file#${vscode_dir}/}"
    slog_step_se_d --context will "merge template: " --url "$relative_path" --default
    
    if merge_template "$template_file" "$selector_scope"; then
      slog_step_se_d --context success "merged template: " --url "$relative_path" --default
      merge_success_count=$(( merge_success_count + 1 ))
    else
      slog_step_se --context warning "failed to merge template: " --url "$relative_path" --default
      merge_failure_count=$(( merge_failure_count + 1 ))
    fi
  done
  
  slog_step_se --context success "Merged " --code "$merge_success_count" --default " template(s) (failed: " --code "$merge_failure_count" --default ")"
  
  return 0
}

# ---- ---- ----  Template Merge Logic  ---- ---- ----

function merge_template {
  # Merge a template file into target configuration
  # Args:
  #   $1: template file path
  #   $2: scope (user|workspace|folder)
  # Returns: 0 on success, 1 on failure
  
  typeset -r template_file="$1"
  typeset -r scope="$2"
  
  slog_var1_se_d "template_file"
  slog_var1_se_d "scope"
  
  # Verify template exists
  if [[ ! -f "$template_file" ]]; then
    slog_step_se --context fatal "template file not found: " --url "$template_file" --default
    return 1
  fi
  
  # Determine target file based on template basename and scope
  typeset -r template_basename="${template_file:t}"
  typeset target_file=""
  
  case "$scope" in
    user)
      target_file="${user_ai_dir}/vscode/user/${template_basename}"
      ;;
    workspace)
      # Workspace templates go to dest_dir/.vscode/
      target_file="${dest_dir}/.vscode/${template_basename}"
      ;;
    folder)
      # Folder templates go to dest_dir/.vscode/
      target_file="${dest_dir}/.vscode/${template_basename}"
      ;;
    *)
      slog_step_se --context fatal "invalid scope: " --code "$scope" --default
      return 1
      ;;
  esac
  
  slog_var1_se_d "target_file"
  
  # Create target directory if needed
  typeset -r target_dir="${target_file:h}"
  if [[ ! -d "$target_dir" ]]; then
    slog_step_se_d --context will "create target directory: " --url "$target_dir" --default
    mkdir -p "$target_dir" || {
      typeset -i exit_code=$?
      slog_step_se --context fatal --exit-code "$exit_code" "create target directory: " --url "$target_dir" --default
      return "$exit_code"
    }
    slog_step_se_d --context success "created target directory"
  fi
  
  # If target doesn't exist, just copy template
  if [[ ! -f "$target_file" ]]; then
    slog_step_se_d --context will "copy template (target does not exist): " --url "$target_file" --default
    
    cp "$template_file" "$target_file" || {
      typeset -i exit_code=$?
      slog_step_se --context fatal --exit-code "$exit_code" "copy template: " --url "$target_file" --default
      return "$exit_code"
    }
    
    slog_step_se_d --context success "copied template to: " --url "$target_file" --default
    return 0
  fi
  
  # Target exists - need to merge
  slog_step_se_d --context will "merge template with existing target: " --url "$target_file" --default
  
  # Verify jq is available
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context fatal "jq not found - required for JSON merging"
    return 1
  fi
  
  # Create backup
  typeset -r backup_file="${target_file}.backup"
  cp "$target_file" "$backup_file" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "create backup: " --url "$backup_file" --default
    return "$exit_code"
  }
  
  slog_step_se_d --context success "created backup: " --url "$backup_file" --default
  
  # Attempt merge with jq
  # Strategy: merge template into existing (existing takes precedence)
  jq -s '.[0] * .[1]' "$template_file" "$target_file" > "${target_file}.tmp" 2>/dev/null
  typeset -i merge_exit_code=$?
  
  if [[ $merge_exit_code -eq 0 ]] && [[ -s "${target_file}.tmp" ]]; then
    # Merge succeeded
    mv "${target_file}.tmp" "$target_file" || {
      typeset -i exit_code=$?
      slog_step_se --context fatal --exit-code "$exit_code" "save merged file: " --url "$target_file" --default
      return "$exit_code"
    }
    
    rm -f "$backup_file"
    slog_step_se_d --context success "merged template successfully"
    return 0
  else
    # Merge failed - restore backup
    slog_step_se --context warning --exit-code "$merge_exit_code" "jq merge failed - file may contain JSONC (comments)"
    
    mv "$backup_file" "$target_file" || {
      typeset -i exit_code=$?
      slog_step_se --context fatal --exit-code "$exit_code" "restore backup: " --url "$backup_file" --default
      return "$exit_code"
    }
    
    rm -f "${target_file}.tmp"
    
    # Consider this success if file already exists (already in final state)
    slog_step_se_d --context success "target file already exists (merge not needed)"
    return 0
  fi
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
