#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091

source "$HOME/.zsh_home/utilities/.zsh_scripting_utilities" "$0" "$@" > /dev/null

# TODO: zakkhoyt - source boilerplate 

#
# Debug trap for hanging issues - set DEBUG_HANG=1 to enable
if [[ -n "${DEBUG_HANG:-}" ]]; then
  trap 'echo "[TRAP] Line $LINENO in ${FUNCNAME[0]:-main}" >&2' DEBUG
fi
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Configure AI instructions for various platforms (copilot, claude, cursor, etc.)
# Author: Zakk Hoyt
# Usage: ./configure_ai_instructions.zsh [OPTIONS]
#
# This script helps install AI instruction files to target projects for different AI platforms.
# It maintains a user-level source of truth and can copy or symlink files to target directories.
#

# ---- ---- ----     Logging Functions     ---- ---- ----

# # Simple logging functions for standalone script (adapted from setup.config)
# function log_info {
#   echo "${ANSI_INFO_GRAY_FG:-}[INFO]${ANSI_DEFAULT:-}: ℹ️ $*" >&2
# }

# Helper function to strip decorator arguments (--url, --code, --bold, --default, etc.)
# for use in plain echo fallback and log file writing
# Usage: strip_decorators "message" --url "path" --default
function strip_decorators {
  local -a retained_args=()
  for arg in "$@"; do
    # Skip arguments that start with -- (decorator flags)
    if [[ "$arg" != --* ]]; then
      retained_args+=("$arg")
    fi
  done
  echo "${(F)retained_args[@]}"
}

# TODO: zakkhoyt P0 - fix these logging func


function _log {
  # Then write to console with formatting
  if type slog_info_se >/dev/null 2>&1; then
    slog_step_se --step info "$@"
  elif type echo_pretty >/dev/null 2>&1; then
    echo_pretty --rgb 0x99 0x99 0x99 "[INFO] ℹ️ " --default "$@" 1>&2
  else
    local -a message_args; message_args=(${(f)"$(strip_decorators "$@")"})
    echo "${ANSI_INFO_GRAY_FG:-}[INFO]${ANSI_DEFAULT:-}: ℹ️ ${(j| |)message_args}" 1>&2
  fi
}

# Log an informational message with support for color/format decorators
# Usage: log_info "checking if homebrew is installed"
# Usage with decorators: log_info "checking directory " --url "$HOME/.hatch" --default
function log_info {
  # # Write to log file first
  # write_to_log "[INFO] ℹ️ " "$@"
  
  # Then write to console with formatting
  if type slog_info_se >/dev/null 2>&1; then
    slog_step_se --step info "$@"
  elif type echo_pretty >/dev/null 2>&1; then
    echo_pretty --rgb 0x99 0x99 0x99 "[INFO] ℹ️ " --default "$@" 1>&2
  else
    local -a message_args; message_args=(${(f)"$(strip_decorators "$@")"})
    echo "${ANSI_INFO_GRAY_FG:-}[INFO]${ANSI_DEFAULT:-}: ℹ️ ${(j| |)message_args}" 1>&2
  fi
}

function log_success {
  echo "${ANSI_GREEN2_FG:-}[SUCCESS]${ANSI_DEFAULT:-}: ✅ $*" >&2
}

function log_warning {
  echo "${ANSI_YELLOW2_FG:-}[WARNING]${ANSI_DEFAULT:-}: ⚠️ $*" >&2
}

function log_error {
  echo "${ANSI_RED2_FG:-}[ERROR]${ANSI_DEFAULT:-}: ❌ $*" >&2
}

function log_debug {
  if [[ -n "${flag_debug:-}" ]]; then
    echo "${ANSI_YELLOW2_FG:-}[DEBUG]${ANSI_DEFAULT:-}: 🐛 $*" >&2
  fi
}

# Set basic ANSI colors if not already defined
ANSI_RED2_FG=${ANSI_RED2_FG:-'\033[91m'}
ANSI_GREEN2_FG=${ANSI_GREEN2_FG:-'\033[92m'}
ANSI_YELLOW2_FG=${ANSI_YELLOW2_FG:-'\033[93m'}
ANSI_BLUE2_FG=${ANSI_BLUE2_FG:-'\033[94m'}
ANSI_MAGENTA2_FG=${ANSI_MAGENTA2_FG:-'\033[95m'}
ANSI_CYAN2_FG=${ANSI_CYAN2_FG:-'\033[96m'}
ANSI_INFO_GRAY_FG=${ANSI_INFO_GRAY_FG:-'\033[90m'}
ANSI_BOLD=${ANSI_BOLD:-'\033[1m'}
ANSI_DEFAULT=${ANSI_DEFAULT:-'\033[0m'}

# Render colored/emoji status indicators for menu + legend
function format_status_indicator {
  local status_value="$1"
  local indicator emoji color
  case "$status_value" in
    not_installed)
      indicator="[ ]"
      color="$ANSI_INFO_GRAY_FG"
      emoji=""
      ;;
    symlinked)
      indicator="[S]"
      color="$ANSI_GREEN2_FG"
      emoji="🔗"
      ;;
    copied_current)
      indicator="[C]"
      color="$ANSI_BLUE2_FG"
      emoji="📄"
      ;;
    copied_outdated)
      indicator="[O]"
      color="$ANSI_YELLOW2_FG"
      emoji="⏳"
      ;;
    copied_modified)
      indicator="[M]"
      color="$ANSI_MAGENTA2_FG"
      emoji="✏️"
      ;;
    copied_unknown)
      indicator="[U]"
      color="$ANSI_CYAN2_FG"
      emoji="❔"
      ;;
    wrong_symlink)
      indicator="[?]"
      color="$ANSI_RED2_FG"
      emoji="⚠️"
      ;;
    *)
      indicator="[ ]"
      color="$ANSI_INFO_GRAY_FG"
      emoji=""
      ;;
  esac
  if [[ -n "$emoji" ]]; then
    echo "${color}${indicator}${ANSI_DEFAULT} ${emoji}"
  else
    echo "${color}${indicator}${ANSI_DEFAULT}"
  fi
}

# Execute a command or print what would be executed in dry-run mode
# Usage: execute_or_dry_run "rm '$file'" "remove file"
function execute_or_dry_run {
  local command_string="$1"
  local description="${2:-command}"
  
  if [[ -n "${flag_dry_run:-}" ]]; then
    log_info "DRY-RUN would execute $description: ${ANSI_YELLOW2_FG:-}$command_string${ANSI_DEFAULT:-}"
    return 0
  else
    log_debug "Executing $description: ${ANSI_YELLOW2_FG:-}$command_string${ANSI_DEFAULT:-}"
    eval "$command_string"
  fi
}

# ---- ---- ----   Argument Parsing   ---- ---- ----

zparseopts -D -F -- \
  -help=flag_help \
  {d,-debug}+=flag_debug \
  -dry-run=flag_dry_run \
  -dev-link=flag_dev_link \
  -dev-vscode=flag_dev_vscode \
  -vscode-settings=flag_vscode_settings \
  -workspace-settings=flag_workspace_settings \
  -user-settings=flag_user_settings \
  -mcp-xcode=flag_mcp_xcode \
  -regenerate-main=flag_regenerate_main \
  -source-dir:=opt_source_dir \
  -dest-dir:=opt_dest_dir \
  -ai-platform:=opt_ai_platform \
  -configure-type:=opt_configure_type

# ---- ---- ----     Help Function     ---- ---- ----

script_basename="${0:A:t}"
function print_usage {
  cat << 'EOF'
SYNOPSIS
    configure_ai_instructions.zsh [OPTIONS]

DESCRIPTION
    Configure AI instructions for various platforms by copying or symlinking
    instruction files from a central source to target project directories.

OPTIONS
    --source-dir <dir>      User AI directory containing source instructions
                           (default: $Z2K_AI_DIR or $HOME/.ai)
    
    --dest-dir <dir>      Target directory to configure (must be git repo root)
                           (default: current working directory)
    
    --ai-platform <platform>
                           AI platform to configure for
                           Options: copilot, claude, cursor, coderabbit
                           (default: copilot)
    
    --configure-type <type> How to install instructions
                           Options: copy, symlink
                           (default: symlink)

META OPTIONS
    --help                  Display this help message and exit
    --debug                 Enable debug logging
    --dry-run               Show what would be done without making changes
    --regenerate-main       Force regeneration of main instruction file from template
                           (WARNING: This will overwrite any custom edits)
    --dev-link              Create symlink to AI dev directory and update .gitignore
                           (useful for quick access to repo files during development)
    --dev-vscode            Add AI dev directory to VS Code workspace
                           (enables IDE integration for development repo)
    --vscode-settings       Deprecated alias for --workspace-settings
    --workspace-settings    Launch menu to merge VS Code workspace templates
                 - Supports *.code-workspace templates plus .vscode/*.json fragments
                 - Honors optional ordering/topic prefixes (e.g., 01__template)
                 - Creates backups before applying jq-based JSON merges
    --user-settings         Launch menu to merge VS Code user settings templates
                 - Applies files under vscode/user → $HOME/Library/Application Support/Code/User
                 - Requires confirmation via interactive menu to avoid surprises
    --mcp-xcode             Install Xcode MCP server configuration and Swift workspace settings
                           - Auto-detects Package.swift / *.xcworkspace / *.xcodeproj under target
                           - Prompts when artifacts exist; --mcp-xcode applies without prompting
                           MCP Template: vscode/mcp/xcode-mcpserver-workspace-mcp.json → .vscode/mcp.json
                           Swift Template: vscode/swift-workspace-settings.template.json → workspace settings

ENVIRONMENT
    Z2K_AI_DIR             Override default source directory location

EXIT VALUES
    0                      Success
    1                      General error
    2                      Invalid arguments
    3                      Git repository validation failed
    4                      File operation failed

EXAMPLES
    # Configure copilot instructions for current directory
    ./${script_basename}

    # Configure claude instructions with copy mode
    ./${script_basename} --ai-platform claude --configure-type copy

    # Configure specific target directory
    ./${script_basename} --dest-dir /path/to/project

    # Merge VS Code workspace templates (chat auto-approvals, AI preferences)
    ./${script_basename} --workspace-settings

    # Merge VS Code user settings templates into your macOS profile
    ./${script_basename} --user-settings

    # Development workflow: link dev directory and add to VS Code workspace
    ./${script_basename} --dev-link --dev-vscode

    # Preview changes without modifying files
    ./${script_basename} --dry-run

    # Configure a VSCode workspace for as prompt free of an AI Agent experience as possible
    ~/.ai/scripts/configure_ai_instructions.zsh --dev-vscode --workspace-settings --debug
    ./${script_basename} --dev-vscode --workspace-settings --debug
EOF
}

# Display help if requested
if [[ -n "${flag_help:-}" ]]; then
  print_usage
  exit 0
fi

if [[ -n "${flag_vscode_settings:-}" && -z "${flag_workspace_settings:-}" ]]; then
  log_warning "--vscode-settings is deprecated; please use --workspace-settings"
  flag_workspace_settings="1"
fi

# ---- ---- ----     Variable Initialization     ---- ---- ----

# Extract argument values
user_ai_dir="${opt_source_dir[2]:-${Z2K_AI_DIR:-$HOME/.ai}}"
dest_dir="${opt_dest_dir[2]:-$PWD}"
configure_type="${opt_configure_type[2]:-symlink}"
ai_platform="${opt_ai_platform[2]:-copilot}"

# Detect repository directory (where this script is located)
script_dir="${0:A:h}"
repo_dir="${script_dir:h}"  # Parent of scripts/ directory

common_repo_instructions_dir="$repo_dir/instructions"
platform_repo_instructions_dir="$repo_dir/ai_platforms/$ai_platform/.github/instructions"

common_user_instructions_dir="$user_ai_dir/instructions"
platform_user_instructions_dir="$user_ai_dir/ai_platforms/$ai_platform/.github/instructions"

if [[ -d "$common_repo_instructions_dir" ]]; then
  repo_instructions_dir="$common_repo_instructions_dir"
  user_ai_instructions_dir="$common_user_instructions_dir"
  log_debug "Using shared instructions directory: $repo_instructions_dir"
else
  repo_instructions_dir="$platform_repo_instructions_dir"
  user_ai_instructions_dir="$platform_user_instructions_dir"
  log_debug "Shared instructions directory missing; falling back to platform path: $repo_instructions_dir"
fi

log_debug "script_dir: $script_dir"
log_debug "repo_dir: $repo_dir"
log_debug "user_ai_dir: $user_ai_dir"
log_debug "dest_dir: $dest_dir"

# ---- ---- ----     Input Validation     ---- ---- ----

# Validate AI platform
typeset ai_platform_name=''
case "$ai_platform" in
  copilot|github-copilot|github)
    ai_platform="copilot"
    ai_platform_name="GitHub Copilot"
    ;;
  claude)
    ai_platform_name="Claude" 
    ;;
  cursor)
    ai_platform_name="Cursor"
    ;;
  coderabbit)
    ai_platform_name="CodeRabbit"
    ;;
  *)
    log_error "Invalid AI platform: $ai_platform"
    log_error "Valid options: copilot, claude, cursor, coderabbit"
    exit 2
    ;;
esac

# Validate configure type
case "$configure_type" in
  copy|symlink)
    # Valid types
    ;;
  *)
    log_error "Invalid configure type: $configure_type"
    log_error "Valid options: copy, symlink"
    exit 2
    ;;
esac

# Validate target directory exists
if [[ ! -d "$dest_dir" ]]; then
  log_error "Target directory does not exist: $dest_dir"
  exit 3
fi

# Check if target directory is a git repository
dest_dir_absolute="${dest_dir:A}"
if ! git_root_dir="$(cd "$dest_dir" && git rev-parse --show-toplevel 2>/dev/null)"; then
  log_warning "Target directory is not a git repository: $dest_dir"
else
  if [[ "$dest_dir_absolute" != "$git_root_dir" ]]; then
    log_warning "Target directory is not git repository root"
    log_warning "Target: $dest_dir_absolute"
    log_warning "Git root: $git_root_dir"
    log_info "Using git root as target directory"
    dest_dir="$git_root_dir"
    dest_dir_absolute="$git_root_dir"
  fi
fi

# Detect Xcode-related artifacts once dest_dir is finalized
typeset -a xcode_project_artifacts=()
typeset xcode_find_output=""
if xcode_find_output="$(
  find "$dest_dir" \
    \( -path '*/.*' -prune \) -o \
    \( \( -name "Package.swift" -a -type f \) -o \( -name "*.xcworkspace" -a -type d \) -o \( -name "*.xcodeproj" -a -type d \) \) -print 2>/dev/null
)"; then
  if [[ -n "$xcode_find_output" ]]; then
    xcode_project_artifacts=(${(f)xcode_find_output})
    log_debug "Detected ${#xcode_project_artifacts[@]} Xcode artifact(s) under target directory"
  fi
else
  log_warning "Failed to scan for Xcode project files under $dest_dir"
fi

# Swift-only projects may not contain Package.swift or Xcode workspace files. Detect a single
# Swift source file (skipping private directories like .build/.swiftpm) and treat it as enough
# evidence to prompt for MCP integration.
typeset swift_file_example=""
if swift_file_example="$(
  find "$dest_dir" \( -path '*/.*' -prune \) -o \( -name "*.swift" -a -type f -print -quit \) 2>/dev/null
)"; then
  if [[ -n "$swift_file_example" ]]; then
    typeset already_listed="false"
    for artifact_path in "${xcode_project_artifacts[@]}"; do
      if [[ "$artifact_path" == "$swift_file_example" ]]; then
        already_listed="true"
        break
      fi
    done
    if [[ "$already_listed" == "false" ]]; then
      xcode_project_artifacts+=("$swift_file_example")
      typeset swift_display="${swift_file_example#$dest_dir/}"
      [[ "$swift_display" == "$swift_file_example" ]] && swift_display="$swift_file_example"
      log_debug "Detected Swift source file (sample): $swift_display"
    fi
  fi
else
  log_warning "Failed to scan for Swift source files under $dest_dir"
fi

# Validate repository instructions directory exists
if [[ ! -d "$repo_instructions_dir" ]]; then
  log_error "Repository instructions directory not found: $repo_instructions_dir"
  exit 4
fi

# ---- ---- ----     Platform Configuration     ---- ---- ----

# Determine platform-specific directory paths based on AI platform
# Usage: get_platform_paths "copilot" "/path/to/project"
function get_platform_paths {
  local platform="$1"
  local target_base="$2"
  
  case "$platform" in
    copilot)
      target_instructions_dir="$target_base/.github/instructions"
      ai_platform_instruction_file="$target_base/.github/copilot-instructions.md"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    claude)
      target_instructions_dir="$target_base/.claude"
      ai_platform_instruction_file="$target_base/.claude/settings.json"
      ai_instruction_settings_file="$target_base/CLAUDE.md"
      ;;
    cursor)
      target_instructions_dir="$target_base/.cursor/rules"
      ai_platform_instruction_file="$target_base/.cursor/rules/mobile.mdc"
      ai_instruction_settings_file="$ai_platform_instruction_file"
      ;;
    coderabbit)
      # TODO: Research CodeRabbit configuration paths
      log_error "CodeRabbit platform not yet implemented"
      exit 2
      ;;
  esac
}

get_platform_paths "$ai_platform" "$dest_dir"

log_debug "target_instructions_dir: $target_instructions_dir"
log_debug "ai_platform_instruction_file: $ai_platform_instruction_file"

# ---- ---- ----     Directory Setup     ---- ---- ----

# Create user AI instructions directory if needed
if [[ ! -d "$user_ai_instructions_dir" ]]; then
  log_info "Creating user AI instructions directory: $user_ai_instructions_dir"
  command_string="mkdir -p '$user_ai_instructions_dir'"
  if ! execute_or_dry_run "$command_string" "create user AI directory"; then
    log_error "Failed to create directory: $user_ai_instructions_dir"
    exit 4
  fi
fi

# Force copy repository instructions to user directory (source of truth)
log_info "Updating source of truth from repository..."
if [[ "$repo_instructions_dir" != "$user_ai_instructions_dir" ]]; then
  command_string="cp -r '$repo_instructions_dir'/* '$user_ai_instructions_dir'/"
  if ! execute_or_dry_run "$command_string" "copy repository instructions"; then
    log_error "Failed to copy instructions from repository to user directory"
    exit 4
  fi
  log_success "Updated user instructions from repository"
else
  log_debug "Repository and user instructions directories are the same - no copy needed"
  log_success "User instructions already up to date (same as repository)"
fi

# Create target instructions directory if needed
if [[ ! -d "$target_instructions_dir" ]]; then
  log_info "Creating target instructions directory: $target_instructions_dir"
  command_string="mkdir -p '$target_instructions_dir'"
  if ! execute_or_dry_run "$command_string" "create target instructions directory"; then
    log_error "Failed to create directory: $target_instructions_dir"
    exit 4
  fi
fi

# ---- ---- ----     Checksum Management     ---- ---- ----

checksums_dir="$dest_dir/.gitignored"
checksums_file="$checksums_dir/.ai-checksums"

# Ensure checksums directory exists inside .gitignored
if [[ ! -d "$checksums_dir" ]]; then
  log_info "Creating checksums directory: $checksums_dir"
  command_string="mkdir -p '$checksums_dir'"
  if ! execute_or_dry_run "$command_string" "create checksums directory"; then
    log_error "Failed to create checksums directory: $checksums_dir"
    exit 4
  fi
fi

# Calculate SHA256 checksum of a file
# Usage: get_file_checksum "/path/to/file"
function get_file_checksum {
  local file_path="$1"
  if [[ -f "$file_path" ]]; then
    shasum -a 256 "$file_path" | cut -d' ' -f1
  else

  fi
}

# Store checksum in tracking file for comparison on future runs
# Usage: update_checksum "filename.md" "sha256hash..."
function update_checksum {
  local file_name="$1"
  local checksum="$2"
  
  # Create or update checksums file
  if [[ -f "$checksums_file" ]]; then
    # Remove existing entry for this file
    grep -v "^$file_name:" "$checksums_file" > "${checksums_file}.tmp" || true
    mv "${checksums_file}.tmp" "$checksums_file"
  fi
  
  # Add new checksum
  echo "$file_name:$checksum" >> "$checksums_file"
}

# Retrieve previously stored checksum for a file
# Usage: get_stored_checksum "filename.md"
function get_stored_checksum {
  local file_name="$1"
  if [[ -f "$checksums_file" ]]; then
    grep "^$file_name:" "$checksums_file" | cut -d':' -f2
  else

  fi
}

# ---- ---- ----     Status Detection     ---- ---- ----

# Determine installation status of an instruction file (not installed, symlinked, copied, etc.)
# Usage: get_file_status --file-basename "filename.md" --source-file "/path/to/source.md"
function get_file_status {
  zparseopts -D -F -- \
    -file-basename:=opt_file_basename \
    -source-file:=opt_source_file
  
  local file_basename="${opt_file_basename[2]}"
  local source_file="${opt_source_file[2]}"
  local source_file_abs="${source_file:A}"
  local target_file="$target_instructions_dir/$file_basename"
  local target_file_abs="${target_file:A}"
  
  log_debug "status-check: $file_basename → target=$target_file"
  
  if [[ -L "$target_file" ]]; then
    local link_target
    if ! link_target="$(readlink "$target_file" 2>/dev/null)"; then
      log_debug "status-check:   symlink but unreadable (treat as wrong)"
      echo "wrong_symlink"
      return
    fi
    if [[ "$link_target" != /* ]]; then
      link_target="${target_file:h}/$link_target"
    fi
    local link_target_abs="${link_target:A}"
    log_debug "status-check:   symlink target=$link_target_abs"
    if [[ "$link_target_abs" == "$source_file_abs" ]]; then
      echo "symlinked"
    else
      echo "wrong_symlink"
    fi
    return
  fi
  
  if [[ ! -e "$target_file" ]]; then
    log_debug "status-check:   not installed (missing $target_file)"
    echo "not_installed"
    return
  fi
  
  # Regular file - check if it matches source
  if [[ "$configure_type" == "copy" ]]; then
    local source_checksum
    local target_checksum
    local stored_checksum
    
    source_checksum="$(get_file_checksum "$source_file_abs")"
    target_checksum="$(get_file_checksum "$target_file")"
    stored_checksum="$(get_stored_checksum "$file_basename")"
    
    if [[ "$target_checksum" == "$source_checksum" ]]; then
      echo "copied_current"
    elif [[ -n "$stored_checksum" && "$target_checksum" == "$stored_checksum" ]]; then
      echo "copied_outdated"
    else
      echo "copied_modified"
    fi
  else
    echo "copied_unknown"
  fi
}

# ---- ---- ----     Development Directory Symlink     ---- ---- ----

# Create a symlink to the AI development directory in the target repository
# Verifies existing symlinks point to the correct location
# Usage: create_dev_symlink
function create_dev_symlink {
  local dev_link_name="${user_ai_dir:t}"
  local dev_link_path="$dest_dir/$dev_link_name"
  
  log_info "Setting up development directory symlink..."
  log_debug "Dev symlink path: $dev_link_path"
  log_debug "Dev symlink target: $user_ai_dir"
  
  # Check if symlink already exists
  if [[ -L "$dev_link_path" ]]; then
    local link_target="${dev_link_path:A}"
    if [[ "$link_target" == "$user_ai_dir" ]]; then
      log_success "Development symlink already correct: $dev_link_name → $user_ai_dir"
      return 0
    else
      log_error "[1] Development symlink points to wrong location"
      log_error "Expected: $user_ai_dir"
      log_error "Actual: $link_target"
      exit 1
    fi
  fi
  
  # Check if regular file/directory exists at target path
  if [[ -e "$dev_link_path" ]]; then
    log_error "[1] Cannot create development symlink: path already exists as regular file/directory"
    log_error "Path: $dev_link_path"
    exit 1
  fi
  
  # Create the symlink
  log_info "Creating development symlink: $dev_link_name → $user_ai_dir"
  command_string="ln -s '$user_ai_dir' '$dev_link_path'"
  if ! execute_or_dry_run "$command_string" "create development symlink"; then
    local exit_code=$?
    log_error "[$exit_code] Failed to create development symlink at '$dev_link_path'"
    exit "$exit_code"
  fi
  
  if [[ -z "${flag_dry_run:-}" ]]; then
    log_success "Created development symlink: $dev_link_name"
  else
    log_success "DRY-RUN: Would create development symlink: $dev_link_name"
  fi
}

# Update VS Code workspace file to include the development directory
# Adds the dev folder as a workspace folder if not already present
# Usage: update_vscode_workspace --user-ai-dir "/Users/user/.ai"
function update_vscode_workspace {
  zparseopts -D -F -- \
    -user-ai-dir:=opt_user_ai_dir
  
  local user_ai_dir_path="${opt_user_ai_dir[2]}"
  
  log_info "Updating VS Code workspace configuration..."
  
  # Check if jq is available (warning-level if missing, not fatal)
  if ! type jq >/dev/null 2>&1; then
    log_warning "jq not found - skipping VS Code workspace update (jq required for JSON manipulation)"
    return 0
  fi
  
  # Find all .code-workspace files at repo root
  local workspace_files
  workspace_files=(${(f)"$(find "$dest_dir" -maxdepth 1 -name "*.code-workspace" -type f 2>/dev/null)"})
  
  if [[ ${#workspace_files[@]} -eq 0 ]]; then
    log_info "No .code-workspace file found in repository root - skipping workspace update"
    return 0
  fi
  
  local workspace_file
  
  if [[ ${#workspace_files[@]} -eq 1 ]]; then
    workspace_file="${workspace_files[1]}"
    log_debug "Found workspace file: $workspace_file"
  else
    # Multiple workspace files - prompt user to select
    log_info "Found ${#workspace_files[@]} workspace files:"

    
    # Sort by modification time (newest first) and build selection menu
    local -a sorted_files
    local -a file_mtimes
    
    for file in "${workspace_files[@]}"; do
      local mtime
      mtime=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null)
      file_mtimes+=("$mtime:$file")
    done
    
    # Sort by mtime descending (newest first)
    sorted_files=(${(On)file_mtimes[@]})
    
    local file_index=1
    local -a display_files
    
    for entry in "${sorted_files[@]}"; do
      local file="${entry#*:}"
      local file_basename="${file:t}"
      display_files+=("$file")
      printf "%2d. %s\n" "$file_index" "$file_basename"
      ((file_index++))
    done
    

    echo "Enter selection (default: 1 - most recently modified): "
    echo -n "1"
    
    read -r user_selection
    
    # Use pre-filled "1" if user just pressed Enter
    if [[ -z "$user_selection" ]]; then
      user_selection="1"
      log_debug "Using pre-selected workspace file: 1"
    fi
    
    # Validate selection
    if [[ ! "$user_selection" =~ ^[0-9]+$ ]] || [[ "$user_selection" -lt 1 ]] || [[ "$user_selection" -gt ${#display_files[@]} ]]; then
      log_warning "Invalid selection: $user_selection - skipping workspace update"
      return 0
    fi
    
    workspace_file="${display_files[$user_selection]}"
    log_debug "Selected workspace file: $workspace_file"
  fi
  workspace_file="${workspace_file:A}"
  log_debug "Workspace file (absolute): $workspace_file"
  
  # Get absolute path for user_ai_dir and the display name
  local user_ai_dir_absolute="${user_ai_dir_path:A}"
  local dev_link_name="${user_ai_dir_path:t}"
  
  log_debug "User AI directory (absolute): $user_ai_dir_absolute"
  log_debug "Display name: $dev_link_name"
  
  # Check if user_ai_dir already exists in workspace (by comparing absolute paths)
  log_debug "Checking if user AI directory already in workspace..."
  
  # Extract all folder paths from workspace and convert to absolute paths for comparison
  local existing_paths
  existing_paths=$(jq -r '.folders[]?.path // empty' "$workspace_file" 2>/dev/null)
  
  if [[ -n "$existing_paths" ]]; then
    while IFS= read -r folder_path; do
      # Convert workspace folder path to absolute (relative to workspace file directory)
      local workspace_dir="${workspace_file:h}"
      local folder_absolute
      
      if [[ "$folder_path" == /* ]]; then
        # Already absolute path
        folder_absolute="${folder_path:A}"
      else
        # Relative path - resolve relative to workspace file location
        folder_absolute="${workspace_dir}/${folder_path}"
        folder_absolute="${folder_absolute:A}"
      fi
      
      log_debug "Comparing: $folder_absolute == $user_ai_dir_absolute"
      
      if [[ "$folder_absolute" == "$user_ai_dir_absolute" ]]; then
        log_success "Development folder already in workspace: $folder_path"
        return 0
      fi
    done <<< "$existing_paths"
  fi
  
  # Create backup before modification
  local backup_file="${workspace_file}.backup"
  
  log_debug "Creating backup: $backup_file"
  command_string="cp '$workspace_file' '$backup_file'"
  if ! execute_or_dry_run "$command_string" "backup workspace file"; then
    local exit_code=$?
    log_error "[$exit_code] Failed to create backup of workspace file"
    exit "$exit_code"
  fi
  
  # Add the dev folder to the workspace with absolute path and proper name, sorted lexicographically
  log_info "Adding development directory to workspace: $user_ai_dir_absolute"
  local temp_workspace="${workspace_file}.tmp"
  
  local workspace_dir="${workspace_file:h}"
  local workspace_dir_name="${workspace_dir:t}"
  log_debug "Workspace directory name (for '.' entries): $workspace_dir_name"
  
  # Build jq filter for sorting folders lexicographically by name
  # All variables ($folder_path, $folder_name, $workspace_dir) are passed via --arg
  local jq_sort_filter='.folders += [{path: $folder_path, name: $folder_name}] | .folders |= map(if .path == "." and ((.name // "") | length) == 0 then .name = $workspace_dir_name else . end) | .folders |= map(.sort_name = (if .name then .name elif .path | startswith(".") then ($workspace_dir + "/" + .path) else .path end)) | .folders |= sort_by(.sort_name) | .folders |= map(del(.sort_name))'
  
  command_string="jq --arg folder_path '$user_ai_dir_absolute' --arg folder_name '$dev_link_name' --arg workspace_dir '$workspace_dir' --arg workspace_dir_name '$workspace_dir_name' '$jq_sort_filter' '$workspace_file' > '$temp_workspace'"
  if ! execute_or_dry_run "$command_string" "parse and update workspace JSON"; then
    local exit_code=$?
    log_error "[$exit_code] Failed to parse or update workspace JSON"
    log_debug "Restoring from backup..."
    command_string="mv '$backup_file' '$workspace_file'"
    if ! execute_or_dry_run "$command_string" "restore workspace backup"; then
      log_error "[restore-failed] Could not restore backup: manual recovery needed at $backup_file"
      exit "$exit_code"
    fi
    log_success "Restored backup after failed update"
    exit "$exit_code"
  fi
  
  # Replace original with updated version
  command_string="mv '$temp_workspace' '$workspace_file'"
  if ! execute_or_dry_run "$command_string" "finalize workspace update"; then
    local exit_code=$?
    log_error "[$exit_code] Failed to finalize workspace update"
    log_debug "Restoring from backup..."
    command_string="mv '$backup_file' '$workspace_file'"
    if ! execute_or_dry_run "$command_string" "restore workspace backup"; then
      log_error "[restore-failed] Could not restore backup: manual recovery needed at $backup_file"
      exit "$exit_code"
    fi
    log_success "Restored backup after failed finalization"
    exit "$exit_code"
  fi
  
  # Verify update succeeded (only if not in dry-run mode)
  if [[ -z "${flag_dry_run:-}" && -f "$workspace_file" ]]; then
    local folder_exists
    folder_exists=$(jq --arg folder "$user_ai_dir_absolute" '.folders[]? | select(.path == $folder) | .path' "$workspace_file" 2>/dev/null)
    if [[ -n "$folder_exists" ]]; then
      log_success "Updated VS Code workspace configuration"
      log_debug "Removing backup file: $backup_file"
      rm -f "$backup_file"
    else
      log_error "[1] Workspace update verification failed - path not found in folders"
      log_debug "Restoring from backup..."
      command_string="mv '$backup_file' '$workspace_file'"
      if ! execute_or_dry_run "$command_string" "restore workspace backup"; then
        log_error "[restore-failed] Could not restore backup: manual recovery needed at $backup_file"
      fi
      exit 1
    fi
  else
    log_success "DRY-RUN: Would update VS Code workspace configuration"
  fi
}

# Select the VS Code workspace file to modify (newest .code-workspace at repo root)
# Prints empty string if none found.
function select_workspace_settings_file {
  setopt local_options null_glob
  local -a workspace_files=("$dest_dir"/*.code-workspace(N))

  if [[ ${#workspace_files[@]} -eq 0 ]]; then
    echo ""
    return 0
  fi

  if [[ ${#workspace_files[@]} -eq 1 ]]; then
    echo "${workspace_files[1]}"
    return 0
  fi

  local -a file_mtimes
  for file in "${workspace_files[@]}"; do
    local mtime
    mtime=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null)
    file_mtimes+=("$mtime:$file")
  done

  local sorted_files=(${(On)file_mtimes[@]})
  echo "${sorted_files[1]#*:}"
}

# Split a template filename into optional topic prefix and remainder
# Output format: "topic|remainder"
function split_template_basename {
  local filename="$1"
  local topic=""
  local remainder="$filename"
  if [[ "$filename" == *__* ]]; then
    topic="${filename%%__*}"
    remainder="${filename#*__}"
  fi
  printf '%s|%s' "$topic" "$remainder"
}

# Merge arbitrary JSONC template data into a destination file using deep merge semantics.
# Dictionaries merge recursively, while arrays/primitives are replaced by the template values.
# Usage: merge_json_files --template-file <path> --destination-file <path> [--description <text>] [--auto-init]
function merge_json_files {
  zparseopts -D -F -- \
    -template-file:=opt_template_file \
    -destination-file:=opt_destination_file \
    -description:=opt_description \
    -auto-init=flag_auto_init

  local template_file="${opt_template_file[2]}"
  local destination_file="${opt_destination_file[2]}"
  local description="${opt_description[2]:-JSON merge}"
  local auto_init=false
  [[ -n "${flag_auto_init:-}" ]] && auto_init=true

  if [[ -z "$template_file" || -z "$destination_file" ]]; then
    log_error "merge_json_files requires --template-file and --destination-file"
    return 1
  fi

  if [[ -n "${flag_dry_run:-}" ]]; then
    log_info "DRY-RUN: Would merge $description"
    log_debug "Template: $template_file → Destination: $destination_file"
    return 0
  fi

  if [[ ! -f "$template_file" ]]; then
    log_error "Template file not found: $template_file"
    return 1
  fi

  local destination_dir="${destination_file:h}"
  if [[ ! -d "$destination_dir" ]]; then
    if ! mkdir -p "$destination_dir"; then
      log_error "Failed to create destination directory: $destination_dir"
      return 1
    fi
  fi

  if [[ ! -f "$destination_file" ]]; then
    if [[ "$auto_init" == true ]]; then
      if ! printf '{}\n' > "$destination_file"; then
        log_error "Failed to initialize destination file: $destination_file"
        return 1
      fi
    else
      log_error "Destination JSON file not found: $destination_file"
      return 1
    fi
  fi

  local backup_file="${destination_file}.backup.$(date +%Y%m%d_%H%M%S)"
  if ! cp "$destination_file" "$backup_file"; then
    log_error "Failed to create backup for $destination_file"
    return 1
  fi

  local temp_file
  temp_file="$(mktemp)"
  local merge_script="$user_ai_dir/scripts/json_merge.py"
  if [[ ! -x "$merge_script" ]]; then
    log_error "json_merge.py not found or not executable: $merge_script"
    rm -f "$backup_file" "$temp_file"
    return 1
  fi

  local -a merge_command=(
    "$merge_script"
    --destination "$destination_file"
    --template "$template_file"
    --output "$temp_file"
    --indent 2
  )
  if [[ -n "${flag_debug:-}" ]]; then
    merge_command+=(--debug)
  fi

  if ! "${merge_command[@]}"; then
    log_error "Failed to merge $description with json_merge.py"
    rm -f "$temp_file" "$backup_file"
    return 1
  fi

  if ! mv "$temp_file" "$destination_file"; then
    log_error "Failed to update destination file: $destination_file"
    rm -f "$temp_file" "$backup_file"
    return 1
  fi

  log_success "Merged $description"
  rm -f "$backup_file"
}

typeset workspace_destination_file=""

# Determine (and cache) the workspace .code-workspace file to modify
function get_workspace_destination_file {
  if [[ -n "$workspace_destination_file" ]]; then
    echo "$workspace_destination_file"
    return 0
  fi

  local selected_workspace
  selected_workspace="$(select_workspace_settings_file)"
  if [[ -z "$selected_workspace" ]]; then
    log_info "No .code-workspace files detected under $dest_dir"
    return 1
  fi

  workspace_destination_file="${selected_workspace:A}"
  log_debug "Workspace destination selected: $workspace_destination_file"
  echo "$workspace_destination_file"
}

# Interactive menu for workspace (.code-workspace) and .vscode JSON templates
function run_workspace_settings_menu {
  local workspace_dir="$user_ai_dir/vscode/workspace"
  local dot_vscode_dir="$workspace_dir/.vscode"

  if ! type jq >/dev/null 2>&1; then
    log_warning "jq not found - skipping workspace template merge"
    return 0
  fi

  if [[ ! -d "$workspace_dir" ]]; then
    log_info "No workspace templates directory found at $workspace_dir"
    return 0
  fi

  setopt local_options null_glob

  local -a workspace_files=("$workspace_dir"/*.code-workspace(N))
  local -a config_files=("$dot_vscode_dir"/*.json(N))

  local -a template_paths=()
  local -a template_types=()
  local -a template_targets=()
  local -a template_labels=()

  local file filename parts topic remainder label

  for file in "${workspace_files[@]}"; do
    [[ -f "$file" ]] || continue
    filename="${file:t}"
    parts="$(split_template_basename "$filename")"
    IFS='|' read -r topic remainder <<< "$parts"
    label="[workspace] ${topic:-${remainder%.code-workspace}} → active workspace"
    template_paths+=("$file")
    template_types+=("workspace")
    template_targets+=("")
    template_labels+=("$label")
  done

  for file in "${config_files[@]}"; do
    [[ -f "$file" ]] || continue
    filename="${file:t}"
    parts="$(split_template_basename "$filename")"
    IFS='|' read -r topic remainder <<< "$parts"
    label="[.vscode] ${topic:-${remainder%.json}} → .vscode/$remainder"
    template_paths+=("$file")
    template_types+=("dotvscode")
    template_targets+=("$remainder")
    template_labels+=("$label")
  done

  if [[ ${#template_paths[@]} -eq 0 ]]; then
    log_info "No workspace templates found in $workspace_dir"
    return 0
  fi

  log_info "Workspace templates available:"
  local idx=1
  while [[ $idx -le ${#template_paths[@]} ]]; do
    printf "%2d. %s\n" "$idx" "${template_labels[$idx]}"
    ((idx++))
  done

  printf "Enter selections (e.g., '1 3' or 'all'). Press Enter to skip: "
  local user_selection=""
  read -r user_selection

  if [[ -z "$user_selection" ]]; then
    log_info "Skipping workspace template merge"
    return 0
  fi

  local -a selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((idx=1; idx<=${#template_paths[@]}; idx++)); do
      selected_indices+=("$idx")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi

  local selection template_path type target label_value workspace_file dest_file
  for selection in "${selected_indices[@]}"; do
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#template_paths[@]} )); then
      log_warning "Invalid selection: $selection"
      continue
    fi

    template_path="${template_paths[$selection]}"
    type="${template_types[$selection]}"
    target="${template_targets[$selection]}"
    label_value="${template_labels[$selection]}"

    case "$type" in
      workspace)
        if ! workspace_file="$(get_workspace_destination_file)"; then
          log_warning "Cannot apply $label_value - no .code-workspace file detected"
          continue
        fi
        merge_json_files --template-file "$template_path" --destination-file "$workspace_file" --description "$label_value"
        ;;
      dotvscode)
        dest_file="$dest_dir/.vscode/$target"
        merge_json_files --template-file "$template_path" --destination-file "$dest_file" --description "$label_value" --auto-init
        ;;
      *)
        log_warning "Unknown template category: $type"
        ;;
    esac
  done
}

# Interactive menu for VS Code user profile templates
function run_user_settings_menu {
  local user_templates_dir="$user_ai_dir/vscode/user"
  local code_user_dir="$HOME/Library/Application Support/Code/User"

  if ! type jq >/dev/null 2>&1; then
    log_warning "jq not found - skipping user settings merge"
    return 0
  fi

  if [[ ! -d "$user_templates_dir" ]]; then
    log_info "No user settings templates found at $user_templates_dir"
    return 0
  fi

  if [[ ! -d "$code_user_dir" ]]; then
    log_warning "VS Code user settings directory not found: $code_user_dir"
    return 0
  fi

  setopt local_options null_glob
  local -a user_files=("$user_templates_dir"/*.json(N))

  if [[ ${#user_files[@]} -eq 0 ]]; then
    log_info "No user settings templates to merge"
    return 0
  fi

  local -a template_paths=()
  local -a template_targets=()
  local -a template_labels=()

  local file filename parts topic remainder label
  for file in "${user_files[@]}"; do
    [[ -f "$file" ]] || continue
    filename="${file:t}"
    parts="$(split_template_basename "$filename")"
    IFS='|' read -r topic remainder <<< "$parts"
    label="[user] ${topic:-${remainder%.json}} → $remainder"
    template_paths+=("$file")
    template_targets+=("$remainder")
    template_labels+=("$label")
  done

  log_info "User settings templates available:"
  local idx=1
  while [[ $idx -le ${#template_paths[@]} ]]; do
    printf "%2d. %s\n" "$idx" "${template_labels[$idx]}"
    ((idx++))
  done

  printf "Enter selections (e.g., '2 4' or 'all'). Press Enter to skip: "
  local user_selection=""
  read -r user_selection

  if [[ -z "$user_selection" ]]; then
    log_info "Skipping user settings merge"
    return 0
  fi

  local -a selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((idx=1; idx<=${#template_paths[@]}; idx++)); do
      selected_indices+=("$idx")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi

  local selection template_path target dest_file label_value
  for selection in "${selected_indices[@]}"; do
    if [[ ! "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#template_paths[@]} )); then
      log_warning "Invalid selection: $selection"
      continue
    fi

    template_path="${template_paths[$selection]}"
    target="${template_targets[$selection]}"
    label_value="${template_labels[$selection]}"
    dest_file="$code_user_dir/$target"
    merge_json_files --template-file "$template_path" --destination-file "$dest_file" --description "$label_value" --auto-init
  done
}

function apply_workspace_template_if_exists {
  local relative_path="$1"
  local description="$2"
  local template_file="$user_ai_dir/vscode/workspace/$relative_path"

  if [[ ! -f "$template_file" ]]; then
    log_warning "Workspace template not found: $template_file"
    return 0
  fi

  local workspace_file
  if ! workspace_file="$(get_workspace_destination_file)"; then
    log_warning "Skipping $description - no .code-workspace file detected"
    return 0
  fi

  merge_json_files --template-file "$template_file" --destination-file "$workspace_file" --description "$description"
}

function apply_workspace_dotfile_template_if_exists {
  local relative_path="$1"
  local description="$2"
  local template_file="$user_ai_dir/vscode/workspace/.vscode/$relative_path"

  if [[ ! -f "$template_file" ]]; then
    log_warning "Workspace .vscode template not found: $template_file"
    return 0
  fi

  local filename="${template_file:t}"
  local parts topic remainder
  parts="$(split_template_basename "$filename")"
  IFS='|' read -r topic remainder <<< "$parts"
  local destination_file="$dest_dir/.vscode/$remainder"

  merge_json_files --template-file "$template_file" --destination-file "$destination_file" --description "$description" --auto-init
}

# Prompt (if needed) and merge Xcode MCP configuration and Swift workspace settings when appropriate
function maybe_merge_xcode_mcp_settings {
  local should_merge=false
  if [[ -n "${flag_mcp_xcode:-}" ]]; then
    should_merge=true
  elif [[ ${#xcode_project_artifacts[@]} -gt 0 ]]; then
    log_info "Detected ${#xcode_project_artifacts[@]} Xcode-related artifact(s) that support the MCP server:"
    local preview_limit=5
    local idx=1
    local artifact_path=""
    for artifact_path in "${xcode_project_artifacts[@]}"; do
      local artifact_display="${artifact_path#$dest_dir/}"
      [[ "$artifact_display" == "$artifact_path" ]] && artifact_display="$artifact_path"
      log_info "  - $artifact_display"
      ((idx++))
      if (( idx > preview_limit )); then
        log_info "  - ... (${#xcode_project_artifacts[@]} total)"
        break
      fi
    done
    log_info "=== Xcode MCP Server Integration ==="
    log_info "This installs .vscode/mcp.json (servers) plus Swift workspace settings."
    log_info "Tip: re-run with --mcp-xcode to auto-apply without prompting."
    printf "Proceed with installing the Xcode MCP server integration now? [y/N]: "
    local user_choice=""
    read -r user_choice
    if [[ "${user_choice:l}" == y* ]]; then
      should_merge=true
    else
      log_info "Skipping Xcode MCP server configuration"
    fi
  fi

  if [[ "$should_merge" == true ]]; then
    apply_workspace_template_if_exists "xcode-mcpserver__workspace.code-workspace" "Xcode MCP workspace template"
    apply_workspace_template_if_exists "swift__workspace.code-workspace" "Swift workspace template"
    apply_workspace_dotfile_template_if_exists "xcode-mcpserver__mcp.json" "Xcode MCP server configuration"
  fi
}

# Update .gitignore to ignore the development directory symlink
# Adds the dev folder to .gitignore if not already present
# Usage: update_gitignore --dev-link-name ".ai"
# Update .gitignore to ignore the development directory symlink
# Prevents accidental commits of symlink to user AI directory
# Usage: update_gitignore --dev-link-name <name>
function update_gitignore {
  zparseopts -D -F -- \
    -dev-link-name:=opt_dev_link_name
  
  local dev_link_name="${opt_dev_link_name[2]}"
  local gitignore_file="$dest_dir/.gitignore"
  
  log_info "Updating .gitignore to ignore development symlink..."
  
  # Check if .gitignore exists
  if [[ ! -f "$gitignore_file" ]]; then
    log_debug "No .gitignore file found - skipping update"
    return 0
  fi
  
  log_debug "Found .gitignore file: $gitignore_file"
  
  # Check if dev_link_name is already in .gitignore
  log_debug "Checking for existing entry in .gitignore: $dev_link_name"
  if grep -q "^${dev_link_name}$" "$gitignore_file"; then
    log_success "Development symlink already ignored in .gitignore: $dev_link_name"
    return 0
  fi
  
  # Create backup before modification
  local backup_file="${gitignore_file}.backup"
  
  log_debug "Creating backup: $backup_file"
  command_string="cp '$gitignore_file' '$backup_file'"
  if ! execute_or_dry_run "$command_string" "backup .gitignore file"; then
    local exit_code=$?
    log_error "[$exit_code] Failed to create backup of .gitignore"
    exit "$exit_code"
  fi
  
  # Add dev_link_name to .gitignore
  log_info "Adding entry to .gitignore: $dev_link_name"
  command_string="echo '$dev_link_name' >> '$gitignore_file'"
  if ! execute_or_dry_run "$command_string" "add development symlink to .gitignore"; then
    local exit_code=$?
    log_error "[$exit_code] Failed to update .gitignore - restoring backup"
    command_string="mv '$backup_file' '$gitignore_file'"
    if ! execute_or_dry_run "$command_string" "restore .gitignore backup"; then
      log_error "[restore-failed] Could not restore backup: manual recovery needed at $backup_file"
      exit "$exit_code"
    fi
    log_success "Restored backup after failed update"
    exit "$exit_code"
  fi
  
  # Verify the entry was actually added (only if not in dry-run mode)
  if [[ -z "${flag_dry_run:-}" ]]; then
    if grep -q "^${dev_link_name}$" "$gitignore_file"; then
      log_success "Added development symlink to .gitignore: $dev_link_name"
      log_debug "Removing backup file: $backup_file"
      rm -f "$backup_file"
    else
      log_error "[1] .gitignore verification failed - entry not found after append"
      log_debug "Restoring from backup..."
      command_string="mv '$backup_file' '$gitignore_file'"
      if ! execute_or_dry_run "$command_string" "restore .gitignore backup"; then
        log_error "[restore-failed] Could not restore backup: manual recovery needed at $backup_file"
      fi
      exit 1
    fi
  else
    log_success "DRY-RUN: Would add development symlink to .gitignore: $dev_link_name"
  fi
}

# ---- ---- ----     Template Synthesis     ---- ---- ----

# Synthesize copilot-instructions.md from template with project analysis
# and list of installed instruction files
# Usage: synthesize_copilot_instructions
function synthesize_copilot_instructions {
  local template_file="$user_ai_dir/ai_platforms/copilot/.github/copilot-instructions.template.md"
  local output_file="$ai_platform_instruction_file"
  
  log_info "Synthesizing copilot-instructions.md"
  
  # Check if template exists
  if [[ ! -f "$template_file" ]]; then
    log_error "Template file not found: $template_file"
    return 1
  fi

  if [[ -n "${flag_dry_run:-}" ]]; then
    log_info "DRY-RUN: Would synthesize copilot-instructions.md at $output_file"
    return 0
  fi
  
  # Check if output file exists and --regenerate-main wasn't passed
  if [[ -f "$output_file" ]] && [[ -z "${flag_regenerate_main:-}" ]]; then
    # Prompt user for update

    log_info "File exists: $output_file"
    echo "Options:"
    echo "  1. Update instruction file list only (preserve user edits)"
    echo "  2. Skip (do nothing)"
    echo "  3. Regenerate entire file from template (lose user edits)"

    read -r "response?Enter choice [1]: "
    response="${response:-1}"
    
    case "$response" in
      1)
        log_info "Updating instruction file list section..."
        update_instruction_list
        return $?
        ;;
      2)
        log_info "Skipping copilot-instructions.md update"
        return 0
        ;;
      3)
        log_info "Regenerating entire file from template..."
        # Continue to full regeneration below
        ;;
      *)
        log_error "Invalid choice: $response"
        return 1
        ;;
    esac
  fi
  
  # Full regeneration: copy template and populate
  log_debug "Copying template to output"
  if ! cp "$template_file" "$output_file"; then
    log_error "Failed to copy template"
    return 1
  fi
  
  # Analyze project and populate template
  analyze_project_and_populate
  update_instruction_list
  
  log_success "Created: $output_file"
  return 0
}

# Analyze target project and populate PROJECT_ANALYSIS section
# Usage: analyze_project_and_populate
function analyze_project_and_populate {
  local output_file="$ai_platform_instruction_file"
  
  # Detect languages from file extensions
  local -A lang_map=(
    ["swift"]="Swift"
    ["py"]="Python"
    ["js"]="JavaScript"
    ["ts"]="TypeScript"
    ["go"]="Go"
    ["rs"]="Rust"
    ["java"]="Java"
    ["kt"]="Kotlin"
    ["rb"]="Ruby"
    ["php"]="PHP"
    ["c"]="C"
    ["cpp"]="C++"
    ["cs"]="C#"
    ["sh"]="Shell"
    ["zsh"]="Zsh"
  )
  
  local detected_languages=()
  for ext lang in "${(@kv)lang_map}"; do
    if find "$dest_dir" -maxdepth 3 -name "*.$ext" -type f 2>/dev/null | head -n 1 | grep -q .; then
      detected_languages+=("$lang")
    fi
  done
  
  # Detect frameworks/tools
  local detected_frameworks=()
  [[ -f "$dest_dir/Package.swift" ]] && detected_frameworks+=("Swift Package Manager")
  [[ -f "$dest_dir/package.json" ]] && detected_frameworks+=("Node.js/npm")
  [[ -f "$dest_dir/Podfile" ]] && detected_frameworks+=("CocoaPods")
  [[ -f "$dest_dir/Gemfile" ]] && detected_frameworks+=("Ruby/Bundler")
  [[ -f "$dest_dir/requirements.txt" ]] && detected_frameworks+=("Python/pip")
  [[ -f "$dest_dir/Cargo.toml" ]] && detected_frameworks+=("Rust/Cargo")
  [[ -f "$dest_dir/go.mod" ]] && detected_frameworks+=("Go Modules")
  [[ -f "$dest_dir/pom.xml" ]] && detected_frameworks+=("Maven")
  [[ -f "$dest_dir/build.gradle" ]] && detected_frameworks+=("Gradle")
  
  # Detect build tools
  local detected_build_tools=()
  [[ -f "$dest_dir/Makefile" ]] && detected_build_tools+=("Make")
  [[ -f "$dest_dir/CMakeLists.txt" ]] && detected_build_tools+=("CMake")
  [[ -d "$dest_dir/.github/workflows" ]] && detected_build_tools+=("GitHub Actions")
  
  # Build replacement strings
  local lang_list="${(j:, :)detected_languages[@]}"
  [[ -z "$lang_list" ]] && lang_list="(not detected)"
  
  local framework_list="${(j:, :)detected_frameworks[@]}"
  [[ -z "$framework_list" ]] && framework_list="(not detected)"
  
  local build_tool_list="${(j:, :)detected_build_tools[@]}"
  [[ -z "$build_tool_list" ]] && build_tool_list="(not detected)"
  
  # Replace placeholders in file
  sed -i '' "s|\*\*Detected Languages:\*\* <!-- AUTO-GENERATED -->|\*\*Detected Languages:\*\* $lang_list|" "$output_file"
  sed -i '' "s|\*\*Detected Frameworks:\*\* <!-- AUTO-GENERATED -->|\*\*Detected Frameworks:\*\* $framework_list|" "$output_file"
  sed -i '' "s|\*\*Build Tools:\*\* <!-- AUTO-GENERATED -->|\*\*Build Tools:\*\* $build_tool_list|" "$output_file"
  
  log_debug "Project analysis complete"
}

# Update the instruction file list in the REGENERATE section
# Usage: update_instruction_list
function update_instruction_list {
  local output_file="$ai_platform_instruction_file"
  
  # Get list of installed instruction files (include symlinks)
  local instruction_files=()
  if [[ -d "$target_instructions_dir" ]]; then
    instruction_files=(${(f)"$(find "$target_instructions_dir" -name "*.instructions.md" \( -type f -o -type l \) 2>/dev/null | sort)"})
  fi
  
  if [[ ${#instruction_files[@]} -eq 0 ]]; then
    log_warning "No instruction files installed yet"
    return 0
  fi
  
  # Build markdown list
  local file_list_lines=()
  for file_path in "${instruction_files[@]}"; do
    local file_basename="${file_path:t}"
    local relative_path=".github/instructions/$file_basename"
    local display_name="${file_basename%.instructions.md}"
    display_name="${display_name//-/ }"
    display_name="${(C)display_name}"  # Capitalize words
    file_list_lines+=("- [$display_name]($relative_path)")
  done
  
  # Create temp file with new content
  local temp_file="$(mktemp)"
  local in_regenerate_section=false
  
  while IFS= read -r line; do
    if [[ "$line" == "<!-- AI_INSTRUCTIONS_REGENERATE_START -->" ]]; then
      echo "$line" >> "$temp_file"
      echo "<!-- This section is automatically updated by configure_ai_instructions.zsh -->" >> "$temp_file"
      echo "<!-- Do not manually edit between these markers -->" >> "$temp_file"
      echo "" >> "$temp_file"
      for file_line in "${file_list_lines[@]}"; do
        echo "$file_line" >> "$temp_file"
      done
      echo "" >> "$temp_file"
      in_regenerate_section=true
    elif [[ "$line" == "<!-- AI_INSTRUCTIONS_REGENERATE_END -->" ]]; then
      echo "$line" >> "$temp_file"
      in_regenerate_section=false
    elif [[ "$in_regenerate_section" == false ]]; then
      echo "$line" >> "$temp_file"
    fi
  done < "$output_file"
  
  # Replace original file
  mv "$temp_file" "$output_file"
  log_debug "Updated instruction file list"
}

# ---- ---- ----     Interactive Menu     ---- ---- ----

# Display menu of available instruction files and process user selections
# Pre-fills selection with already-installed files for convenient re-linking/updating
# User can select individual files or 'all' to install all files
# Usage: display_menu
function display_menu {
  log_info "Available instruction files:"

  local xtrace_was_on=false
  if [[ -o xtrace ]]; then
    xtrace_was_on=true
    set +x
    log_debug "Temporarily disabling xtrace for menu rendering"
  fi
  
  # Get list of instruction files recursively
  local instruction_files
  instruction_files=(${(f)"$(find "$user_ai_instructions_dir" -name "*.instructions.md" -type f | sort)"})
  
  if [[ ${#instruction_files[@]} -eq 0 ]]; then
    log_error "No instruction files found in $user_ai_instructions_dir"
    exit 4
  fi
  
  local file_index=1
  local file_basenames=()
  local file_full_paths=()
  local installed_indices=()
  
  for file_path in "${instruction_files[@]}"; do
    local file_basename="${file_path:t}"
    file_basenames+=("$file_basename")
    file_full_paths+=("$file_path")
    
    local file_status="$(get_file_status --file-basename "$file_basename" --source-file "$file_path")"
    log_debug "menu-entry: index=$file_index file=$file_basename status=$file_status"
    
    local status_indicator="$(format_status_indicator "$file_status")"
    
    printf "%2d. %s %s\n" "$file_index" "$status_indicator" "$file_basename"
    
    # Collect indices of already-installed files
    if [[ "$file_status" != "not_installed" ]]; then
      installed_indices+=("$file_index")
    fi
    
    ((file_index++))
  done
  
  echo "Status Legend:"
  printf "  %-18s %s\n" "$(format_status_indicator not_installed)" "Not installed"
  printf "  %-18s %s\n" "$(format_status_indicator symlinked)" "Symlinked (current)"
  printf "  %-18s %s\n" "$(format_status_indicator copied_current)" "Copied (current)"
  printf "  %-18s %s\n" "$(format_status_indicator copied_outdated)" "Copied (outdated)"
  printf "  %-18s %s\n" "$(format_status_indicator copied_modified)" "Copied (modified)"
  printf "  %-18s %s\n" "$(format_status_indicator copied_unknown)" "Copied (unknown)"
  printf "  %-18s %s\n" "$(format_status_indicator wrong_symlink)" "Wrong symlink target"
  
  # Build pre-filled selection string from already-installed files
  local default_selection=""
  if [[ ${#installed_indices[@]} -gt 0 ]]; then
    # Join installed indices with spaces
    default_selection="${(j: :)installed_indices[@]}"
  else
    default_selection=""
  fi
  
  # Prompt user with selection
  if [[ -n "$default_selection" ]]; then
    printf "Default selection (press Enter to accept):\n  %b\n" "${ANSI_BOLD}${default_selection}${ANSI_DEFAULT}"
    printf "Type a new selection or press Enter to use the default shown above: "
    log_debug "menu-default: $default_selection"
  else
    printf "Default action (press Enter): %b\n" "${ANSI_BOLD}skip (no changes)${ANSI_DEFAULT}"
    printf "Enter selections by space-separated numbers (EX: '1 2'), or 'all': "
    log_debug "menu-default: <skip>"
  fi
  
  # Read user input
  read -r user_selection
  
  # If user entered nothing but we had default, use the default
  if [[ -z "$user_selection" && -n "$default_selection" ]]; then
    user_selection="$default_selection"
    log_debug "Using default selection: $user_selection"
  elif [[ -z "$user_selection" && -z "$default_selection" ]]; then
    # User entered nothing and nothing was pre-filled
    log_warning "No files selected - no changes will be made"
    return 0
  fi
  
  local selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((i=1; i<=${#file_basenames[@]}; i++)); do
      selected_indices+=("$i")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi
  
  # # Process selections
  # for index in "${selected_indices[@]}"; do

  # selected_indices=("$@")
  local i
  slog_se_d "selected_indices.count: ${#selected_indices[@]}"
  for ((i=0; i<="${#selected_indices[@]}"; i++)); do
    index="${selected_indices[$i]:-}"
    if [[ -z "$index" ]]; then 
      slog_se_d "  \${selected_indices[$i]}: <nil>"
      continue; 
    fi
    slog_se_d "  \${selected_indices[$i]}: $index"



    if [[ "$index" =~ ^[0-9]+$ ]] && [[ "$index" -ge 1 ]] && [[ "$index" -le ${#file_basenames[@]} ]]; then
      local file_basename="${file_basenames[$index]}"
      local file_full_path="${file_full_paths[$index]}"
      slog_se_d "    calling install_instruction_file"
      install_instruction_file --file-basename "$file_basename" --source-file "$file_full_path"
      slog_se_d "    did call install_instruction_file"  
    else
      log_warning "Invalid selection: $index"
    fi
  done

  slog_se_d "finished loop in $0"

  if [[ "$xtrace_was_on" == true ]]; then
    log_debug "Restoring xtrace after menu rendering"
    set -x
  fi
}

# ---- ---- ----     File Installation     ---- ---- ----

# Array to track installed files for summary
installed_files=()

# Install a single instruction file by creating symlink or copying
# Tracks installation in installed_files array for summary display
# Usage: install_instruction_file --file-basename "filename.md" --source-file "/path/to/source.md"
function install_instruction_file {
  zparseopts -D -F -- \
    -file-basename:=opt_file_basename \
    -source-file:=opt_source_file
  
  local file_basename="${opt_file_basename[2]}"
  local source_file="${opt_source_file[2]}"
  local target_file="$target_instructions_dir/$file_basename"
  
  log_info "Installing $file_basename..."
  
  # Remove existing file/symlink
  if [[ -e "$target_file" || -L "$target_file" ]]; then
    log_debug "Removing existing: $target_file"
    command_string="rm '$target_file'"
    if ! execute_or_dry_run "$command_string" "remove existing file"; then
      log_error "Failed to remove existing file: $target_file"
      return 1
    fi
  fi
  
  # Install according to configure type
  case "$configure_type" in
    symlink)
      log_debug "Creating symlink: $target_file -> $source_file"
      command_string="ln -s '$source_file' '$target_file'"
      if ! execute_or_dry_run "$command_string" "create symlink"; then
        log_error "Failed to create symlink: $target_file"
        return 1
      fi
      if [[ -z "${flag_dry_run:-}" ]]; then
        log_success "Symlinked $file_basename"
        installed_files+=("$file_basename")
      else
        log_success "DRY-RUN: Would symlink $file_basename"
        installed_files+=("$file_basename")
      fi
      ;;
    copy)
      log_debug "Copying file: $source_file -> $target_file"
      command_string="cp '$source_file' '$target_file'"
      if ! execute_or_dry_run "$command_string" "copy file"; then
        log_error "Failed to copy file: $target_file"
        return 1
      fi
      
      # Checksum will be regenerated after menu completes
      if [[ -z "${flag_dry_run:-}" ]]; then
        log_success "Copied $file_basename"
        installed_files+=("$file_basename")
      else
        log_success "DRY-RUN: Would copy $file_basename"
        installed_files+=("$file_basename")
      fi
      ;;
  esac
}

# ---- ---- ----     Script Work     ---- ---- ----

dry_run_prefix=""
if [[ -n "${flag_dry_run:-}" ]]; then
  dry_run_prefix="DRY-RUN: "
  log_warning "Running in DRY-RUN mode - no changes will be made"
fi

log_info "${dry_run_prefix}Configuring AI instructions for $ai_platform platform"
log_info "Source directory: $user_ai_instructions_dir"
log_info "Target directory: $target_instructions_dir"
log_info "Configuration type: $configure_type"

# Create development directory symlink and update .gitignore if requested
if [[ -n "${flag_dev_link:-}" ]]; then
  local dev_link_name="${user_ai_dir:t}"
  create_dev_symlink
  update_gitignore --dev-link-name "$dev_link_name"
fi

# Add development directory to VS Code workspace if requested
if [[ -n "${flag_dev_vscode:-}" ]]; then
  update_vscode_workspace --user-ai-dir "$user_ai_dir"
fi

# Launch workspace template menu if requested
if [[ -n "${flag_workspace_settings:-}" ]]; then
  run_workspace_settings_menu
fi

# Launch user settings template menu if requested
if [[ -n "${flag_user_settings:-}" ]]; then
  run_user_settings_menu
fi

# Offer Xcode MCP server configuration and Swift workspace settings if requested or detected
maybe_merge_xcode_mcp_settings

# Synthesize main instruction file for copilot platform (only if it doesn't exist)
if [[ "$ai_platform" == "copilot" ]] && [[ ! -f "$ai_platform_instruction_file" ]]; then
  synthesize_copilot_instructions
fi

# Display interactive menu
display_menu
# Regenerate checksums file based on currently installed copied files
if [[ -z "${flag_dry_run:-}" ]]; then
  log_debug "Regenerating checksums file: $checksums_file"
  log_debug "Target instructions dir: $target_instructions_dir"
  
  # Clear old checksums file
  : > "$checksums_file"
  
  # Scan for copied files (regular files, not symlinks) and regenerate checksums
  if [[ -d "$target_instructions_dir" ]]; then
    log_debug "About to run find command..."
    local copied_files=()
    copied_files=(${(f)"$(find "$target_instructions_dir" -name "*.instructions.md" -type f 2>/dev/null | sort)"})
    
    log_debug "Find command completed"
    log_debug "Found ${#copied_files[@]} copied files"
    
    for file_path in "${copied_files[@]}"; do
      local file_basename="${file_path:t}"
      local checksum
      checksum="$(get_file_checksum "$file_path")"
      if [[ -n "$checksum" ]]; then
        echo "$file_basename:$checksum" >> "$checksums_file"
        log_debug "Added checksum for: $file_basename"
      fi
    done
    
    if [[ ${#copied_files[@]} -gt 0 ]]; then
      log_debug "Regenerated checksums for ${#copied_files[@]} copied file(s)"
    fi
  fi
fi

# Update copilot-instructions.md with newly installed files
if [[ "$ai_platform" == "copilot" ]] && [[ ${#installed_files[@]} -gt 0 ]]; then
  log_info "Updating copilot-instructions.md with installed files..."
  update_instruction_list
  log_success "Updated instruction file list"
fi

if [[ -n "${flag_dry_run:-}" ]]; then
  log_success "DRY-RUN: AI instruction configuration simulation complete!"
else
  log_success "AI instruction configuration complete!"
fi

# Show summary of installed file
if [[ ${#installed_files[@]} -gt 0 ]]; then
  local action_verb
  if [[ "$configure_type" == "symlink" ]]; then
    action_verb="Symlinked"
  else
    action_verb="Copied"
  fi
  
  local dry_run_prefix_summary=""
  if [[ -n "${flag_dry_run:-}" ]]; then
    dry_run_prefix_summary="Would have "
    action_verb="${action_verb:l}"  # Lowercase for "would have symlinked"
  fi
  
  log_info "${dry_run_prefix_summary}${action_verb} ${#installed_files[@]} file(s) to " --url "$target_instructions_dir" --default ":"
  
  # Build multiline list of files using (F) expansion
  local file_lines=()
  for ((i=1; i<=${#installed_files[@]}; i++)); do
    file_lines+=("  ${i}. ${installed_files[$i]}")
  done
  echo "${(F)file_lines[@]}"
else
  log_info "No files were installed"
fi

# Show next step
log_info "Next steps:"

case "$ai_platform" in
  copilot)
    echo "  • Instructions will be automatically detected by $ai_platform_name"
    echo "  • Restart VS Code if needed to ensure instructions are loaded"
    ;;
  claude)
    echo "  • Instructions may require additional configuration in $ai_platform_name"
    echo "  • Check $ai_platform_name documentation for platform-specific setup"
    ;;
  cursor)
    echo "  • Instructions should be automatically detected by $ai_platform_name"
    echo "  • Restart $ai_platform_name if needed to ensure instructions are loaded"
    ;;
  coderabbit)
    echo "  • Instructions should be automatically detected by $ai_platform_name"
    echo "  • Restart $ai_platform_name if needed to ensure instructions are loaded"
    ;;
esac
