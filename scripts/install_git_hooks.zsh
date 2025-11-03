

#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Install git hooks from repository to target project
# Author: Zakk Hoyt
# Usage: ./install_git_hooks.zsh [OPTIONS]
#
# This script helps install git hooks from a central source to target git repositories.
# It can copy or symlink hooks from git/hooks/* to target/.git/hooks/*
#

# ---- ---- ----     Logging Functions     ---- ---- ----

function strip_decorators {
  local -a retained_args=()
  for arg in "$@"; do
    if [[ "$arg" != --* ]]; then
      retained_args+=("$arg")
    fi
  done
  echo "${(F)retained_args[@]}"
}

function log_info {
  if type slog_step_se >/dev/null 2>&1; then
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
ANSI_INFO_GRAY_FG=${ANSI_INFO_GRAY_FG:-'\033[90m'}
ANSI_DEFAULT=${ANSI_DEFAULT:-'\033[0m'}

# ---- ---- ----     Dry-Run Helper     ---- ---- ----

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
  -source-dir:=opt_source_dir \
  -target-dir:=opt_target_dir \
  -install-type:=opt_install_type

# ---- ---- ----     Help Function     ---- ---- ----

function print_usage {
  cat << 'EOF'
SYNOPSIS
    install_git_hooks.zsh [OPTIONS]

DESCRIPTION
    Install git hooks from a central source to target git repository.
    Hooks can be copied or symlinked from source to .git/hooks directory.

OPTIONS
    --source-dir <dir>      Source directory containing git hooks
                           (default: $Z2K_AI_DIR/git/hooks or $HOME/.ai/git/hooks)
    
    --target-dir <dir>      Target git repository root directory
                           (default: current working directory)
    
    --install-type <type>   How to install hooks
                           Options: copy, symlink
                           (default: symlink)

META OPTIONS
    --help                  Display this help message and exit
    --debug                 Enable debug logging
    --dry-run               Show what would be done without making changes

ENVIRONMENT
    Z2K_AI_DIR             Override default source directory location

EXIT VALUES
    0                      Success
    1                      General error
    2                      Invalid arguments
    3                      Git repository validation failed
    4                      File operation failed

EXAMPLES
    # Install hooks to current git repository
    ./install_git_hooks.zsh

    # Install hooks with copy mode
    ./install_git_hooks.zsh --install-type copy

    # Install hooks to specific repository
    ./install_git_hooks.zsh --target-dir /path/to/repo
EOF
}

# Display help if requested
if [[ -n "${flag_help:-}" ]]; then
  print_usage
  exit 0
fi

# ---- ---- ----     Variable Initialization     ---- ---- ----

# Extract argument values
user_ai_dir="${Z2K_AI_DIR:-$HOME/.ai}"
source_hooks_dir="${opt_source_dir[2]:-$user_ai_dir/git/hooks}"
target_dir="${opt_target_dir[2]:-$PWD}"
install_type="${opt_install_type[2]:-symlink}"

# Detect repository directory (where this script is located)
script_dir="${0:A:h}"
repo_dir="${script_dir:h}"  # Parent of scripts/ directory

log_debug "script_dir: $script_dir"
log_debug "repo_dir: $repo_dir"
log_debug "source_hooks_dir: $source_hooks_dir"
log_debug "target_dir: $target_dir"

# ---- ---- ----     Input Validation     ---- ---- ----

# Validate install type
case "$install_type" in
  copy|symlink)
    # Valid types
    ;;
  *)
    log_error "Invalid install type: $install_type"
    log_error "Valid options: copy, symlink"
    exit 2
    ;;
esac

# Validate target directory exists
if [[ ! -d "$target_dir" ]]; then
  log_error "Target directory does not exist: $target_dir"
  exit 3
fi

# Check if target directory is a git repository
target_dir_absolute="${target_dir:A}"
if ! git_root_dir="$(cd "$target_dir" && git rev-parse --show-toplevel 2>/dev/null)"; then
  log_error "Target directory is not a git repository: $target_dir"
  exit 3
else
  if [[ "$target_dir_absolute" != "$git_root_dir" ]]; then
    log_warning "Target directory is not git repository root"
    log_warning "Target: $target_dir_absolute"
    log_warning "Git root: $git_root_dir"
    log_warning "Using git root: $git_root_dir"
    target_dir="$git_root_dir"
  fi
fi

target_hooks_dir="$target_dir/.git/hooks"

# Validate source hooks directory exists
if [[ ! -d "$source_hooks_dir" ]]; then
  log_error "Source hooks directory not found: $source_hooks_dir"
  exit 4
fi

# ---- ---- ----     Status Detection     ---- ---- ----

function get_hook_status {
  local hook_basename="$1"
  local source_file="$2"
  local target_file="$target_hooks_dir/$hook_basename"
  
  if [[ ! -e "$target_file" ]]; then
    echo "not_installed"
    return
  fi
  
  if [[ -L "$target_file" ]]; then
    local link_target="${target_file:A}"
    if [[ "$link_target" == "$source_file" ]]; then
      echo "symlinked"
    else
      echo "wrong_symlink"
    fi
    return
  fi
  
  # Regular file exists
  echo "file_exists"
}

# ---- ---- ----     Interactive Menu     ---- ---- ----

function display_menu {
  log_info "Available git hooks:"
  echo ""
  
  # Get list of hook files
  local hook_files
  hook_files=(${(f)"$(find "$source_hooks_dir" -type f ! -name "*.sample" ! -name ".*" | sort)"})
  
  if [[ ${#hook_files[@]} -eq 0 ]]; then
    log_error "No hook files found in $source_hooks_dir"
    exit 4
  fi
  
  local file_index=1
  local hook_basenames=()
  local hook_full_paths=()
  
  for file_path in "${hook_files[@]}"; do
    local hook_basename="${file_path:t}"
    hook_basenames+=("$hook_basename")
    hook_full_paths+=("$file_path")
    
    local hook_status
    hook_status="$(get_hook_status "$hook_basename" "$file_path")"
    
    local status_indicator
    case "$hook_status" in
      not_installed)   status_indicator="[ ]" ;;
      symlinked)       status_indicator="[S]" ;;
      wrong_symlink)   status_indicator="[?]" ;;
      file_exists)     status_indicator="[F]" ;;
    esac
    
    printf "%2d. %s %s\n" "$file_index" "$status_indicator" "$hook_basename"
    ((file_index++))
  done
  
  echo ""
  echo "Status Legend:"
  echo "  [ ] Not installed    [S] Symlinked (correct)"
  echo "  [F] File exists      [?] Wrong symlink target"
  echo ""
  
  # Get user selection
  echo "Enter selections by space-separated numbers (EX: '1 2'), or 'all': "
  read -r user_selection
  
  local selected_indices=()
  if [[ "$user_selection" == "all" ]]; then
    for ((i=1; i<=${#hook_basenames[@]}; i++)); do
      selected_indices+=("$i")
    done
  else
    selected_indices=(${(s: :)user_selection})
  fi
  
  # Process selections
  for index in "${selected_indices[@]}"; do
    if [[ "$index" =~ ^[0-9]+$ ]] && [[ "$index" -ge 1 ]] && [[ "$index" -le ${#hook_basenames[@]} ]]; then
      local hook_basename="${hook_basenames[$index]}"
      local hook_full_path="${hook_full_paths[$index]}"
      install_hook_file "$hook_basename" "$hook_full_path"
    else
      log_warning "Invalid selection: $index"
    fi
  done
}

# ---- ---- ----     File Installation     ---- ---- ----

# Array to track installed hooks for summary
installed_hooks=()

function install_hook_file {
  local hook_basename="$1"
  local source_file="$2"
  local target_file="$target_hooks_dir/$hook_basename"
  
  log_info "Installing $hook_basename..."
  
  # Remove existing file/symlink
  if [[ -e "$target_file" || -L "$target_file" ]]; then
    log_debug "Removing existing: $target_file"
    command_string="rm '$target_file'"
    if ! execute_or_dry_run "$command_string" "remove existing hook"; then
      log_error "Failed to remove existing hook: $target_file"
      return 1
    fi
  fi
  
  # Install according to install type
  case "$install_type" in
    symlink)
      log_debug "Creating symlink: $target_file -> $source_file"
      command_string="ln -s '$source_file' '$target_file'"
      if ! execute_or_dry_run "$command_string" "create symlink"; then
        log_error "Failed to create symlink: $target_file"
        return 1
      fi
      if [[ -z "${flag_dry_run:-}" ]]; then
        log_success "Symlinked $hook_basename"
        installed_hooks+=("$hook_basename")
      else
        log_success "DRY-RUN: Would symlink $hook_basename"
        installed_hooks+=("$hook_basename")
      fi
      ;;
    copy)
      log_debug "Copying file: $source_file -> $target_file"
      command_string="cp '$source_file' '$target_file' && chmod +x '$target_file'"
      if ! execute_or_dry_run "$command_string" "copy hook"; then
        log_error "Failed to copy hook: $target_file"
        return 1
      fi
      
      if [[ -z "${flag_dry_run:-}" ]]; then
        log_success "Copied $hook_basename"
        installed_hooks+=("$hook_basename")
      else
        log_success "DRY-RUN: Would copy $hook_basename"
        installed_hooks+=("$hook_basename")
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

log_info "${dry_run_prefix}Installing git hooks"
log_info "Source directory: $source_hooks_dir"
log_info "Target directory: $target_hooks_dir"
log_info "Installation type: $install_type"

# Display interactive menu
display_menu

if [[ -n "${flag_dry_run:-}" ]]; then
  log_success "DRY-RUN: Git hooks installation simulation complete!"
else
  log_success "Git hooks installation complete!"
fi

# Show summary of installed hooks
echo ""
if [[ ${#installed_hooks[@]} -gt 0 ]]; then
  local action_verb
  if [[ "$install_type" == "symlink" ]]; then
    action_verb="Symlinked"
  else
    action_verb="Copied"
  fi
  
  local dry_run_prefix_summary=""
  if [[ -n "${flag_dry_run:-}" ]]; then
    dry_run_prefix_summary="Would have "
    action_verb="${action_verb:l}"  # Lowercase
  fi
  
  log_info "${dry_run_prefix_summary}${action_verb} ${#installed_hooks[@]} hook(s) to " --url "$target_hooks_dir" --default ":"
  
  # Build multiline list of hooks
  local hook_lines=()
  for ((i=1; i<=${#installed_hooks[@]}; i++)); do
    hook_lines+=("  ${i}. ${installed_hooks[$i]}")
  done
  echo "${(F)hook_lines[@]}"
else
  log_info "No hooks were installed"
fi

# Show next steps
echo ""
log_info "Next steps:"
echo "  • Git hooks will run automatically on respective git events"
echo "  • Test hooks with: git <hook-name> (e.g., git commit for pre-commit)"
echo "  • View hooks in: " && echo "    " "$target_hooks_dir"

