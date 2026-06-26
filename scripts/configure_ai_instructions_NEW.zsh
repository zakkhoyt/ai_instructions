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


# ---- ---- ----     Helper Functions     ---- ---- ----

function get_platform_paths {
  zparseopts -D -F -- \
    -platform:=opt_platform \
    -target-base:=opt_target_base
  
  typeset -r platform="${opt_platform[2]}"
  slog_var1_se_d "platform"
  
  typeset -r target_base="${opt_target_base[2]}"
  slog_var1_se_d "target_base"
  
  case "$platform" in
    copilot)
      target_instructions_dir="${target_base}/.github/instructions"
      ai_platform_instruction_file="${target_base}/.github/copilot-instructions.md"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    claude)
      target_instructions_dir="${target_base}/.claude"
      ai_platform_instruction_file="${target_base}/.claude/settings.json"
      ai_instruction_settings_file="${target_base}/CLAUDE.md"
      ;;
    cursor)
      target_instructions_dir="${target_base}/.cursor/rules"
      ai_platform_instruction_file="${target_base}/.cursor/rules/mobile.mdc"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    coderabbit)
      target_instructions_dir="${target_base}/.coderabbit"
      ai_platform_instruction_file="${target_base}/.coderabbit/config.yml"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    *)
      slog_step_se --context fatal "Unknown platform: " --code "$platform" --default
      return 1
      ;;
  esac
  
  slog_var1_se_d "target_instructions_dir"
  slog_var1_se_d "ai_platform_instruction_file"
  slog_var1_se_d "ai_instruction_settings_file"
}

function get_file_checksum {
  zparseopts -D -F -- \
    -file-path:=opt_file_path
  
  typeset -r file_path="${opt_file_path[2]}"
  
  if [[ ! -f "$file_path" ]]; then
    slog_step_se --context fatal "File not found: " --url "$file_path" --default
    return 1
  fi
  
  typeset checksum=""
  checksum=$(shasum -a 256 "$file_path" | awk '{print $1}') || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "calculate checksum for: " --url "$file_path" --default
    return "$exit_code"
  }
  
  echo "$checksum"
}

function update_checksum {
  zparseopts -D -F -- \
    -file-name:=opt_file_name \
    -checksum:=opt_checksum \
    -checksum-file:=opt_checksum_file
  
  typeset -r file_name="${opt_file_name[2]}"
  typeset -r checksum="${opt_checksum[2]}"
  typeset -r checksum_file="${opt_checksum_file[2]}"
  
  typeset -r temp_file="${checksum_file}.tmp"
  
  if [[ -f "$checksum_file" ]]; then
    grep -v "^${file_name}:" "$checksum_file" > "$temp_file" 2>/dev/null || true
  else
    touch "$temp_file"
  fi
  
  echo "${file_name}:${checksum}" >> "$temp_file"
  mv "$temp_file" "$checksum_file"
}

function get_stored_checksum {
  zparseopts -D -F -- \
    -file-name:=opt_file_name \
    -checksum-file:=opt_checksum_file
  
  typeset -r file_name="${opt_file_name[2]}"
  typeset -r checksum_file="${opt_checksum_file[2]}"
  
  if [[ ! -f "$checksum_file" ]]; then
    echo ""
    return 0
  fi
  
  typeset stored_checksum=""
  stored_checksum=$(grep "^${file_name}:" "$checksum_file" | cut -d: -f2)
  echo "$stored_checksum"
}

function create_dev_symlink {
  typeset -r dev_link_name="${user_ai_dir:t}"
  typeset -r dev_link_path="${dest_dir}/${dev_link_name}"
  
  slog_step_se_d --context will "set up development directory symlink"
  
  if [[ -L "$dev_link_path" ]]; then
    typeset link_target="${dev_link_path:A}"
    if [[ "$link_target" == "$user_ai_dir" ]]; then
      slog_step_se --context info "Development symlink already correct"
      return 0
    else
      slog_step_se --context warning "Existing symlink points to wrong location, removing"
      rm "$dev_link_path"
    fi
  elif [[ -e "$dev_link_path" ]]; then
    slog_step_se --context fatal "Path exists but is not a symlink: " --url "$dev_link_path" --default
    return 1
  fi
  
  ln -s "$user_ai_dir" "$dev_link_path" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "create development symlink"
    return "$exit_code"
  }
  
  slog_step_se --context success "created development symlink"
}

function update_gitignore {
  zparseopts -D -F -- \
    -entry:=opt_entry \
    -gitignore-file:=opt_gitignore_file
  
  typeset -r entry="${opt_entry[2]}"
  typeset -r gitignore_file="${opt_gitignore_file[2]}"
  
  if [[ -f "$gitignore_file" ]] && grep -qxF "$entry" "$gitignore_file"; then
    return 0
  fi
  
  echo "$entry" >> "$gitignore_file"
  slog_step_se --context success "added to .gitignore: " --code "$entry" --default
}

function select_workspace_settings_file {
  setopt local_options null_glob
  typeset -a workspace_files=("$dest_dir"/*.code-workspace(N))

  if [[ ${#workspace_files[@]} -eq 0 ]]; then
    echo ""
    return 0
  fi

  if [[ ${#workspace_files[@]} -eq 1 ]]; then
    echo "${workspace_files[1]}"
    return 0
  fi

  typeset -a file_mtimes
  for file in "${workspace_files[@]}"; do
    typeset mtime=""
    mtime=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null)
    file_mtimes+=("$mtime:$file")
  done

  typeset -a sorted_files=(${(On)file_mtimes[@]})
  echo "${sorted_files[1]#*:}"
}

function split_template_basename {
  typeset -r filename="$1"
  typeset topic=""
  typeset remainder="$filename"
  if [[ "$filename" == *__* ]]; then
    topic="${filename%%__*}"
    remainder="${filename#*__}"
  fi
  printf '%s|%s' "$topic" "$remainder"
}

function merge_json_files {
  zparseopts -D -F -- \
    -template-file:=opt_template_file \
    -destination-file:=opt_destination_file \
    -description:=opt_description \
    -auto-init=flag_auto_init

  typeset -r template_file="${opt_template_file[2]}"
  typeset -r destination_file="${opt_destination_file[2]}"
  typeset -r description="${opt_description[2]:-JSON merge}"
  typeset auto_init=false
  [[ -n "${flag_auto_init:-}" ]] && auto_init=true

  if [[ -z "$template_file" || -z "$destination_file" ]]; then
    slog_step_se --context fatal "merge_json_files requires --template-file and --destination-file"
    return 1
  fi

  if [[ ! -f "$template_file" ]]; then
    slog_step_se --context fatal "Template file not found: " --url "$template_file" --default
    return 1
  fi

  typeset -r destination_dir="${destination_file:h}"
  if [[ ! -d "$destination_dir" ]]; then
    mkdir -p "$destination_dir" || {
      typeset -i exit_code=$?
      slog_step_se --context fatal --exit-code "$exit_code" "create destination directory: " --url "$destination_dir" --default
      return "$exit_code"
    }
  fi

  if [[ ! -f "$destination_file" ]]; then
    if [[ "$auto_init" == true ]]; then
      printf '{}\n' > "$destination_file" || {
        typeset -i exit_code=$?
        slog_step_se --context fatal --exit-code "$exit_code" "initialize destination file: " --url "$destination_file" --default
        return "$exit_code"
      }
    else
      slog_step_se --context fatal "Destination JSON file not found: " --url "$destination_file" --default
      return 1
    fi
  fi

  typeset -r backup_file="${destination_file}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$destination_file" "$backup_file" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "create backup for: " --url "$destination_file" --default
    return "$exit_code"
  }

  typeset temp_file=""
  temp_file="$(mktemp)"
  typeset -r merge_script="$user_ai_dir/scripts/json_merge.py"
  
  if [[ ! -x "$merge_script" ]]; then
    slog_step_se --context fatal "json_merge.py not found or not executable: " --url "$merge_script" --default
    rm -f "$backup_file" "$temp_file"
    return 1
  fi

  typeset -a merge_command=(
    "$merge_script"
    --destination "$destination_file"
    --template "$template_file"
    --output "$temp_file"
    --indent 2
  )
  
  if [[ -n "${flag_debug:-}" ]]; then
    merge_command+=(--debug)
  fi

  "${merge_command[@]}" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "merge $description with json_merge.py"
    rm -f "$temp_file" "$backup_file"
    return "$exit_code"
  }

  mv "$temp_file" "$destination_file" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "update destination file: " --url "$destination_file" --default
    rm -f "$temp_file" "$backup_file"
    return "$exit_code"
  }

  slog_step_se --context success "merged $description"
  rm -f "$backup_file"
}

typeset workspace_destination_file=""

function get_workspace_destination_file {
  if [[ -n "$workspace_destination_file" ]]; then
    echo "$workspace_destination_file"
    return 0
  fi

  typeset selected_workspace=""
  selected_workspace="$(select_workspace_settings_file)"
  if [[ -z "$selected_workspace" ]]; then
    slog_step_se --context info "No .code-workspace files detected under: " --url "$dest_dir" --default
    return 1
  fi

  workspace_destination_file="${selected_workspace:A}"
  slog_var1_se_d "workspace_destination_file"
  echo "$workspace_destination_file"
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


function synthesize_copilot_instructions {
  typeset -r template_file="$user_ai_dir/ai_platforms/copilot/.github/copilot-instructions.template.md"
  typeset -r output_file="$ai_platform_instruction_file"
  
  slog_step_se_d --context will "synthesize copilot-instructions.md"
  
  if [[ ! -f "$template_file" ]]; then
    slog_step_se --context fatal "Template file not found: " --url "$template_file" --default
    return 1
  fi

  typeset project_overview=""
  typeset detected_languages=""
  typeset detected_frameworks=""
  typeset build_tools=""
  
  project_overview=$(analyze_project_and_populate)
  
  typeset temp_file=""
  temp_file="$(mktemp)"
  
  cat "$template_file" > "$temp_file"
  
  sed -i.bak "s|<!-- PROJECT_OVERVIEW -->|$project_overview|g" "$temp_file"
  sed -i.bak "s|<!-- DETECTED_LANGUAGES -->|$detected_languages|g" "$temp_file"
  sed -i.bak "s|<!-- DETECTED_FRAMEWORKS -->|$detected_frameworks|g" "$temp_file"
  sed -i.bak "s|<!-- BUILD_TOOLS -->|$build_tools|g" "$temp_file"
  
  typeset instruction_list=""
  instruction_list=$(update_instruction_list)
  
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
  rm -f "$temp_list"
  
  mv "$temp_file" "$output_file" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "write synthesized instructions to: " --url "$output_file" --default
    rm -f "$temp_file" "$temp_file.bak"
    return "$exit_code"
  }
  
  rm -f "$temp_file.bak"
  slog_step_se_d --context success "synthesized copilot-instructions.md"
}

function analyze_project_and_populate {
  echo "Add your project-specific coding standards here."
}

function update_instruction_list {
  typeset -a instruction_files=(${(f)"$(find "$target_instructions_dir" -type f -name "*.instructions.md" 2>/dev/null | sort)"})
  
  typeset -a instruction_lines=()
  for file in "${instruction_files[@]}"; do
    typeset filename="${file:t}"
    typeset title="${filename%.instructions.md}"
    instruction_lines+=("- <a>${title}</a>")
  done
  
  # Join array with actual newlines using (F) flag
  echo "${(F)instruction_lines[@]}"
}

function has_instructions_to_install {
  [[ -d "$source_instructions_dir" ]] && [[ -n "$(find "$source_instructions_dir" -type f -name "*.instructions.md" 2>/dev/null)" ]]
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



function apply_workspace_template_if_exists {
  zparseopts -D -F -- \
    -relative-path:=opt_relative_path \
    -description:=opt_description
  
  typeset -r relative_path="${opt_relative_path[2]}"
  typeset -r description="${opt_description[2]}"
  typeset -r template_file="$user_ai_dir/vscode/workspace/$relative_path"
  
  if [[ ! -f "$template_file" ]]; then
    slog_step_se --context warning "Workspace template not found: " --url "$template_file" --default
    return 0
  fi
  
  typeset workspace_file=""
  if ! workspace_file="$(get_workspace_destination_file)"; then
    slog_step_se --context warning "Skipping $description - no .code-workspace file detected"
    return 0
  fi
  
  merge_json_files --template-file "$template_file" --destination-file "$workspace_file" --description "$description"
}

function apply_workspace_dotfile_template_if_exists {
  zparseopts -D -F -- \
    -relative-path:=opt_relative_path \
    -description:=opt_description
  
  typeset -r relative_path="${opt_relative_path[2]}"
  typeset -r description="${opt_description[2]}"
  typeset -r template_file="$user_ai_dir/vscode/workspace/.vscode/$relative_path"
  
  if [[ ! -f "$template_file" ]]; then
    slog_step_se --context warning "Workspace .vscode template not found: " --url "$template_file" --default
    return 0
  fi
  
  typeset -r filename="${template_file:t}"
  typeset parts=""
  typeset topic=""
  typeset remainder=""
  parts="$(split_template_basename "$filename")"
  IFS='|' read -r topic remainder <<< "$parts"
  typeset -r destination_file="$dest_dir/.vscode/$remainder"
  
  merge_json_files --template-file "$template_file" --destination-file "$destination_file" --description "$description" --auto-init
}

function maybe_merge_xcode_mcp_settings {
  typeset should_merge=false
  
  if is_xcode_mcp_installed; then
    slog_step_se --context success "Xcode MCP Server already installed - skipping"
    return 0
  fi
  
  if [[ -n "${flag_mcp_xcode:-}" ]]; then
    should_merge=true
  fi
  
  if [[ "$should_merge" == true ]]; then
    apply_workspace_template_if_exists \
      --relative-path "xcode-mcpserver__workspace.code-workspace" \
      --description "Xcode MCP workspace template"
    apply_workspace_template_if_exists \
      --relative-path "swift__workspace.code-workspace" \
      --description "Swift workspace template"
    apply_workspace_dotfile_template_if_exists \
      --relative-path "xcode-mcpserver__mcp.json" \
      --description "Xcode MCP server configuration"
  fi
}

function run_workspace_settings_menu {
  typeset -r workspace_dir="$user_ai_dir/vscode/workspace"
  typeset -r dot_vscode_dir="$workspace_dir/.vscode"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - skipping workspace template merge"
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
  for file in "${workspace_files[@]}"; do
    printf "%2d. [workspace] %s\n" "$idx" "${file:t}"
    ((idx++))
  done
  
  for file in "${config_files[@]}"; do
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
  
  slog_step_se --context info "Workspace template merge not yet fully implemented"
}

function run_user_settings_menu {
  typeset -r user_templates_dir="$user_ai_dir/vscode/user"
  typeset -r code_user_dir="$HOME/Library/Application Support/Code/User"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context warning "jq not found - skipping user settings merge"
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
  
  slog_step_se --context info "User settings template merge not yet fully implemented"
}

# ---- ---- ----     Main Script Work     ---- ---- ----

# Declare variables that will be set by get_platform_paths
typeset target_instructions_dir=""
typeset ai_platform_instruction_file=""
typeset ai_instruction_settings_file=""

# [step] Set up platform paths
get_platform_paths --platform "$ai_platform" --target-base "$dest_dir"
slog_var1_se_d "target_instructions_dir"
slog_var1_se_d "ai_platform_instruction_file"
slog_var1_se_d "ai_instruction_settings_file"

typeset -r source_instructions_dir="$user_ai_dir/instructions"
slog_var1_se_d "source_instructions_dir"

# [step] Create target instructions directory
slog_step_se_d --context will "create target instructions directory if needed"
if [[ ! -d "$target_instructions_dir" ]]; then
  mkdir -p "$target_instructions_dir" || {
    typeset -i exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "create directory: " --url "$target_instructions_dir" --default
    exit "$exit_code"
  }
  slog_step_se_d --context success "created target instructions directory"
else
  slog_step_se_d --context success "target instructions directory already exists"
fi

# Handle --dev-link flag
if [[ -n "${flag_dev_link:-}" ]]; then
  create_dev_symlink
  typeset -r dev_link_name="${user_ai_dir:t}"
  update_gitignore --entry "$dev_link_name" --gitignore-file "$dest_dir/.gitignore"
  exit 0
fi

# Handle --instructions flag
if [[ -n "${flag_instructions:-}" ]]; then
  if ! has_instructions_to_install; then
    slog_step_se --context info "No instruction files found in: " --url "$source_instructions_dir" --default
    exit 0
  fi
  
  typeset user_selection=""
  if [[ -n "${flag_prompt:-}" ]]; then
    user_selection=$(display_menu)
  else
    user_selection="all"
  fi
  
  if [[ -z "$user_selection" ]]; then
    slog_step_se --context info "No files selected for installation"
    exit 0
  fi
  
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
    
    typeset checksum=""
    checksum=$(get_file_checksum --file-path "$source_file")
    update_checksum --file-name "$file_basename" --checksum "$checksum" --checksum-file "$checksum_file"
    
    slog_step_se_d --context success "installed instruction file: " --url "$file_basename" --default
  done
  
  synthesize_copilot_instructions
fi

slog_step_se --context info "Script execution complete"


# ---- ---- ----     Helper Functions     ---- ---- ----

