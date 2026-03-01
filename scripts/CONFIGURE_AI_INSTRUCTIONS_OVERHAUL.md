# Configure AI Instructions Script Overhaul

**File:** [scripts/configure_ai_instructions.zsh](scripts/configure_ai_instructions.zsh)

**Status:** Planning Phase - Discussion Required

**Last Updated:** 2026-02-03

---

## Executive Summary

The `configure_ai_instructions.zsh` script's instruction file installation menu has degraded significantly. The core issue is that the `--instructions` and `--prompt` flags have conflicting and confusing behaviors that don't match user expectations.

### Critical Problems Identified

1. **Menu only displays when no files are installed** - If any instructions exist, the menu is skipped entirely
2. **Numbering breaks after 9** - Uses `%2d` format which wraps 10+ to `1.`, `2.` etc.
3. **Flag behavior is unclear** - `--instructions --prompt` shows Xcode MCP menu instead of instructions menu
4. **User intent is ambiguous** - Selecting files doesn't clarify what action (symlink/copy) will be taken
5. **No way to modify existing installations** - Can't switch from copy to symlink or update without deleting first

---

## How The Script Was Designed (Original Intent)

### Flag Interactions (As Documented in Help)

```zsh
--instructions          Auto-install all applicable instruction files
                       - Use with --prompt to show interactive menu for file selection

--prompt                Enable interactive prompts for installations
                       - When set: shows interactive menus for confirmation/selection
                       - When not set: shows info but doesn't prompt
```

### Expected Behavior Matrix

| Flags | Expected Behavior |
|-------|-------------------|
| *(none)* | Show info about available instructions, no installation |
| `--instructions` | Auto-install all uninstalled files (no prompts) |
| `--prompt` | Show interactive menu for all files |
| `--instructions --prompt` | Auto-install but prompt for confirmation first |

### Actual Behavior (Current)

| Flags | Actual Behavior | Problem |
|-------|-----------------|---------|
| *(none)* | Shows info only if files need installation | ✅ Works |
| `--instructions` | Auto-installs uninstalled files | ✅ Works |
| `--prompt` | Shows menu ONLY if has files to install | ❌ **Broken** |
| `--instructions --prompt` | Shows Xcode MCP menu, then skips instructions | ❌ **Broken** |

---

## Root Cause Analysis

### Issue 1: Conditional Menu Display

**Location:** [configure_ai_instructions.zsh:1892-1938](configure_ai_instructions.zsh#L1892-L1938)

```zsh
if [[ -n "${flag_instructions:-}" ]]; then
  if has_instructions_to_install; then
    log_success "All instruction files are already installed and current - skipping"
  else
    if [[ -n "${flag_prompt:-}" ]]; then
      # --prompt --instructions: Show interactive menu
      display_menu
    else
      # --instructions alone: Auto-install
      # ... auto-install logic ...
    fi
  fi
else
  if [[ -n "${flag_prompt:-}" ]]; then
    # --prompt alone: Show interactive menu
    display_menu
  else
    # ... show info only ...
  fi
fi
```

**Problem:** When `--instructions` is set and `has_instructions_to_install` returns false (all files installed), the menu is never shown. User cannot:
- Update outdated copied files
- Switch from copy to symlink
- Re-link broken symlinks
- Review current installation status

**Root Cause:** The logic assumes "instructions to install" means "any action needed", but it only checks for `not_installed` or `copied_outdated` status. It ignores:
- `copied_modified` - User modified files
- `wrong_symlink` - Symlink points to wrong location
- User wanting to review/change current state

### Issue 2: Number Formatting

**Location:** [configure_ai_instructions.zsh:1685](configure_ai_instructions.zsh#L1685)

```zsh
printf "%2d. %s %s\n" "$file_index" "$status_indicator" "$file_basename"
```

**Problem:** `%2d` format only reserves 2 characters, so:
- Items 1-9 display as ` 1.` through ` 9.`
- Items 10+ display as `10.` through `99.`
- Items 100+ wrap to `100` (3 chars, breaking alignment)

**Example Current Output:**
```
 1. [ ] file1.md
 2. [ ] file2.md
 ...
 9. [ ] file9.md
10. [ ] file10.md  # No leading space, breaks alignment
11. [ ] file11.md
```

**User's Reported Output:**
```
 9. [ ] userscript-conventions.instructions.md
1.  [ ] zsh-compatibility-notes.instructions.md  # Wraps to "1." somehow?
2.  [ ] zsh-conventions.instructions.md
```

This suggests something more complex is happening - possibly terminal width issues or array indexing problems.

### Issue 3: Xcode MCP Menu Interference

**Location:** [configure_ai_instructions.zsh:1883](configure_ai_instructions.zsh#L1883)

```zsh
# Offer Xcode MCP server configuration
maybe_merge_xcode_mcp_settings

# Handle instruction file installation
if [[ -n "${flag_instructions:-}" ]]; then
  # ... instruction logic ...
fi
```

**Problem:** The Xcode MCP function runs **before** the instruction installation logic and respects `--prompt`. When both `--instructions --prompt` are set:
1. Xcode MCP menu shows (if Xcode files detected)
2. User declines or accepts
3. Instruction logic finds all files installed
4. Skips menu display with "already installed" message

**Root Cause:** Execution order + both systems responding to `--prompt` independently.

### Issue 4: Unclear User Intent

**Problem:** When user selects files from menu, the action taken depends on `--configure-type` flag (default: `symlink`), but this isn't shown in the menu.

**Current Menu:**
```zsh
 1. [ ] agent-chat-response-conventions.instructions.md
 2. [S] 🔗 agent-terminal-conventions.instructions.md
 3. [ ] swift-conventions.instructions.md

Enter selections: 1 3
```

**User doesn't know:**
- Will selecting `1` symlink or copy?
- Will selecting `2` (already symlinked) re-link, skip, or copy?
- Can I switch `2` from symlink to copy?

---

## Where User Thinks Problems Are

Based on the user's feedback:

1. ✅ **Numbering bug** - User correctly identified `%2d` issue
2. ✅ **Menu skipped when files exist** - User correctly identified the `has_instructions_to_install` gate
3. ✅ **Flag confusion** - User correctly noted `--instructions --prompt` doesn't behave as expected
4. ⚠️ **User action intent** - User suspects this is confusing but hasn't fully articulated the solution
5. ❌ **Multiple instruction files** - User mentions script used to work better, suggesting recent regression

### User is Correct About

- The menu should ALWAYS display when `--prompt` is set, regardless of installation status
- The numbering format needs fixing
- The flags don't interact clearly
- User needs ability to modify existing installations

### User May Be Mistaken About

- The script "used to do a much better job" - Actually, the current logic may have always been problematic, but user is only now encountering edge cases (like having some files already installed)

---

## Proposed Solutions

### Solution 1: Always Show Menu When `--prompt` Set

**Change:** Remove the `has_instructions_to_install` gate when `--prompt` is present.

**Current Code:**
```zsh
if [[ -n "${flag_instructions:-}" ]]; then
  if has_instructions_to_install; then
    log_success "All instruction files are already installed - skipping"
  else
    if [[ -n "${flag_prompt:-}" ]]; then
      display_menu
    fi
  fi
fi
```

**Proposed Fix:**
```zsh
if [[ -n "${flag_instructions:-}" ]]; then
  if [[ -n "${flag_prompt:-}" ]]; then
    # Always show menu when prompt requested
    log_info "=== Instruction File Installation ==="
    display_menu
  else
    # Auto-install logic (only if work needed)
    if has_instructions_to_install; then
      log_info "=== Auto-installing instruction files ==="
      # ... auto-install ...
    else
      log_success "All instruction files are already installed and current - skipping"
    fi
  fi
fi
```

**Benefits:**
- User can review current state
- User can modify existing installations
- Matches expected behavior of `--prompt` flag

---

### Solution 1a: Help User When No Instructions Exist

**Change:** When no instruction files exist in destination AND user hasn't requested installation, provide helpful guidance.

**Scenario:** User runs script without `--instructions` flag, but destination has no AI instructions configured.

**Proposed Behavior:**
```zsh
# Early in script execution, check instruction status
log_info "Checking for AI instructions..."

if ! has_any_instructions_installed; then
  log_warning "This repository contains no AI instructions."
  log_info "Run this command to install them:"
  echo ""
  # ANSI decorated command suggestion (using new syntax)
  printf "  \033[1;36m%s --prompt instructions\033[0m\n" "$0"
  echo ""
  log_info "Or for automatic installation (all files):"
  printf "  \033[1;36m%s --no-prompt instructions\033[0m\n" "$0"
  echo ""
  # Don't exit - continue with other operations
fi
```

**Where This Runs:**
- After argument parsing
- Before instruction menu logic
- Only when `--instructions` NOT explicitly requested
- Does NOT block other operations (VSCode settings, MCP, etc.)

**Benefits:**
- User immediately knows instructions are missing
- Clear guidance on how to fix it
- ANSI highlighting makes command easy to identify and copy
- Non-blocking - other script features still work
- Runs even when `--no-prompt` set (informational only)

**Helper Function:**
```zsh
has_any_instructions_installed() {
  local dest_dir="${1:-.}"
  local instructions_dir="$dest_dir/.github/instructions"
  
  # Check if directory exists and has any .instructions.md files
  if [[ -d "$instructions_dir" ]]; then
    local count=$(find "$instructions_dir" -name "*.instructions.md" -type f 2>/dev/null | wc -l)
    [[ $count -gt 0 ]]
  else
    return 1
  fi
}
```

**Alternative Messaging (More Concise):**
```zsh
if ! has_any_instructions_installed; then
  echo ""
  log_warning "⚠️  No AI instructions found in this repository"
  echo "   Install with: \033[1;36m$0 --prompt instructions\033[0m"
  echo ""
fi
```

---

### Solution 2: Fix Number Formatting

**Change:** Use `%3d` for up to 999 files (more than sufficient).

**Current:**
```zsh
printf "%2d. %s %s\n" "$file_index" "$status_indicator" "$file_basename"
```

**Proposed:**
```zsh
printf "%3d. %s %s\n" "$file_index" "$status_indicator" "$file_basename"
```

**Alternative (Dynamic Width):**
```zsh
# Calculate max width needed
local max_index=${#file_basenames[@]}
local width=${#max_index}

# Use calculated width
printf "%${width}d. %s %s\n" "$file_index" "$status_indicator" "$file_basename"
```

**Benefits:**
- Handles 10+ files correctly
- Dynamic approach scales to any number of files

---

### Solution 3: Clarify Action Intent in Menu

**Change:** Show what action will be taken in menu header.

**Current Menu:**
```zsh
[INFO] ℹ️ === Instruction File Installation ===
[INFO] ℹ️ Available instruction files:
 1. [ ] agent-chat-response-conventions.instructions.md
```

**Proposed Menu:**
```zsh
[INFO] ℹ️ === Instruction File Installation ===
[INFO] ℹ️ Installation method: SYMLINK (use --configure-type copy to change)
[INFO] ℹ️ Available instruction files:
 1. [ ] agent-chat-response-conventions.instructions.md
```

**Alternative (Allow per-file action):**

This is more complex but provides maximum flexibility:

```zsh
[INFO] ℹ️ === Instruction File Installation ===
[INFO] ℹ️ Available instruction files:
 1. [ ] agent-chat-response-conventions.instructions.md
 2. [S] 🔗 agent-terminal-conventions.instructions.md
 3. [C] 📄 swift-conventions.instructions.md

Actions:
  S - Symlink (default)
  C - Copy
  R - Remove/uninstall
  U - Update (for copied files)
  
Examples:
  "1 2 3"     - Symlink files 1, 2, 3
  "S 1 2 3"   - Symlink files 1, 2, 3 (explicit)
  "C 4 5"     - Copy files 4, 5
  "R 2"       - Remove file 2
  "U 3"       - Update file 3 (if copied)
  "all"       - Symlink all files
  "C all"     - Copy all files

Enter selection:
```

**Benefits:**
- User knows exactly what will happen
- Supports mixed operations in one invocation
- Allows modifications to existing installations

---

### Solution 4: Separate Xcode MCP from Instructions

**Change:** Only run Xcode MCP setup when explicitly requested via `--mcp-xcode`.

**Current:**
```zsh
# Always runs if Xcode files detected
maybe_merge_xcode_mcp_settings

# Then handle instructions
if [[ -n "${flag_instructions:-}" ]]; then
  # ...
fi
```

**Proposed:**
```zsh
# Only run if explicitly requested
if [[ -n "${flag_mcp_xcode:-}" ]]; then
  maybe_merge_xcode_mcp_settings
fi

# Handle instructions independently
if [[ -n "${flag_instructions:-}" ]]; then
  # ...
fi
```

**Benefits:**
- Clear separation of concerns
- `--instructions --prompt` only affects instructions
- `--mcp-xcode --prompt` only affects MCP setup
- Both can be used together if needed

---

### Solution 5: Improve Flag Documentation

**Change:** Update help text and add examples.

**Current Help:**
```zsh
--instructions          Auto-install all applicable instruction files
                       - Use with --prompt to show interactive menu

--prompt                Enable interactive prompts for installations
```

**Proposed Help:**
```zsh
--instructions          Manage instruction file installation
                       - Without --prompt: Auto-install all uninstalled files
                       - With --prompt: Show interactive menu for all files
                       
--prompt                Enable interactive prompts for installations
                       - Shows menus even when no changes needed
                       - Allows reviewing and modifying current state

EXAMPLES:
  # Review current installation state (interactive menu)
  $0 --prompt
  
  # Auto-install all missing files (no prompts)
  $0 --instructions
  
  # Show menu before auto-installing
  $0 --instructions --prompt
  
  # Configure Xcode MCP interactively
  $0 --mcp-xcode --prompt
  
  # Install instructions and Xcode MCP together
  $0 --instructions --mcp-xcode --prompt
```

**Benefits:**
- Clear documentation of behavior
- Examples show common use cases
- Users understand flag interactions

---

## Implementation Plan

### Phase 1: Critical Fixes (High Priority)

1. **Fix menu display logic** - Solution 1
   - Remove `has_instructions_to_install` gate when `--prompt` is set
   - Test: `--prompt` should always show menu
   - Test: `--instructions --prompt` should show menu then auto-install selections

2. **Fix number formatting** - Solution 2
   - Change `%2d` to `%3d` or dynamic width
   - Test with 10+ instruction files
   - Verify alignment is consistent

3. **Separate Xcode MCP logic** - Solution 4
   - Only run MCP setup when `--mcp-xcode` is set
   - Test: `--instructions --prompt` should not show Xcode menu
   - Test: `--mcp-xcode --prompt` should show Xcode menu

### Phase 2: Usability Improvements (Medium Priority)

4. **Add action intent to menu** - Solution 3 (simple version)
   - Show installation method in menu header
   - Document how to change method
   - Consider adding confirmation step

5. **Update help documentation** - Solution 5
   - Add examples section
   - Clarify flag interactions
   - Document all use cases

### Phase 3: Advanced Features (Low Priority)

6. **Per-file action selection** - Solution 3 (advanced version)
   - Design syntax for mixed operations
   - Implement parser for action prefixes
   - Add support for remove/update operations
   - Extensive testing of edge cases

---

## Testing Matrix

### Test Cases for Phase 1

| Test Case | Command | Expected Behavior |
|-----------|---------|-------------------|
| 1.1 | `--prompt` (no files installed) | Show menu with all [ ] status |
| 1.2 | `--prompt` (some files installed) | Show menu with mixed statuses |
| 1.3 | `--prompt` (all files installed) | Show menu with all [S] or [C] status |
| 1.4 | `--instructions` (no files) | Auto-install all files |
| 1.5 | `--instructions` (some files) | Auto-install missing files only |
| 1.6 | `--instructions` (all files) | Skip with "already installed" message |
| 1.7 | `--instructions --prompt` (no files) | Show menu, then install selections |
| 1.8 | `--instructions --prompt` (all files) | Show menu (not auto-skip) |
| 1.9 | No flags (no files) | Show info about available instructions |
| 1.10 | No flags (all files) | Show "all installed" message |

### Test Cases for Number Formatting

| Test Case | File Count | Expected Format |
|-----------|------------|-----------------|
| 2.1 | 1-9 files | ` 1.`, ` 2.`, ... ` 9.` |
| 2.2 | 10-99 files | ` 10.`, ` 11.`, ... ` 99.` |
| 2.3 | 100+ files | `100.`, `101.`, ... |

### Test Cases for Xcode MCP Separation

| Test Case | Command | Xcode Files Present | Expected Behavior |
|-----------|---------|---------------------|-------------------|
| 3.1 | `--instructions` | Yes | Only instructions menu, no MCP |
| 3.2 | `--instructions --prompt` | Yes | Only instructions menu, no MCP |
| 3.3 | `--mcp-xcode` | Yes | Only MCP setup, no instructions |
| 3.4 | `--mcp-xcode --prompt` | Yes | MCP prompt shown |
| 3.5 | `--instructions --mcp-xcode` | Yes | Instructions auto-install, MCP auto-setup |
| 3.6 | `--mcp-xcode` | No | Info message, skip MCP |

---

## User Feedback & Decisions

### ✅ DECISION: Always Show Menu When `--prompt` Set

**User's requirement:** If `--instructions --prompt` is provided, ALWAYS show the menu. Never skip with "already installed" message. Let the user decide what to do.

**Rationale:**
- User may want to review current state
- User may want to switch from symlink to copy
- User may want to uninstall files
- The whole point of `--prompt` is to defer to user

**Implementation:** Remove ALL `has_instructions_to_install` gates when `--prompt` flag is present.

---

### ✅ DECISION: Use 3-Digit Number Formatting

**Change:** `printf "%2d"` → `printf "%3d"`

**Rationale:** Supports up to 100 instruction files, which is more than sufficient.

---

### ✅ DECISION: Eliminate "Already Installed" Skip Logic

**User's requirement:** Remove the optimization that skips the menu when all files are installed. Always defer to user.

**Change:** The script should:
1. Show status of all files (which are installed, which aren't)
2. Present the menu
3. Let user choose to skip (by pressing Enter) or take action

---

### ✅ DECISION: Action Flags Are Sufficient (No Need for Separate `--instructions`)

**User's clarification:** We don't need to keep `--instructions` as a separate "auto-install" flag.

**Proposed behavior:**
- Each action can be in **prompt mode** (via `--prompt <action>`) or **auto mode** (default)
- Example:
  ```zsh
  # Auto mode (no prompting)
  ./script instructions
  
  # Prompt mode
  ./script --prompt instructions
  ```

**Note for Phase 2:** Consider adding explicit `--no-prompt <action>` for clarity, but not needed initially.

---

### ✅ DECISION: Keep Grouped Action Granularity for VSCode Settings

**User question:** Should each `vscode/**/*.json` file be a separate action?

**Answer:** No - keep current grouped approach:
- `workspace-settings` - Single action that shows menu for ALL workspace/vscode templates
- `user-settings` - Single action that shows menu for ALL user profile templates

**Rationale:**
1. User mental model: "configure my workspace" vs "configure specific file X"
2. Interactive menu provides fine-grained selection when needed
3. Simple to use: fewer flags to remember
4. Auto-discovery: new templates automatically appear in menu
5. Matches current design which already works well

**Example usage:**
```zsh
# Show menu to select which workspace templates to merge
./script --prompt workspace-settings

# Auto-apply all workspace templates (no menu)
./script workspace-settings

# Show both workspace and user settings menus
./script --prompt workspace-settings --prompt user-settings
```

---

### ✅ DECISION: Improve "All Installed" Message

**Current (bad):**
```zsh
[SUCCESS]: ✅ All instruction files are already installed and current - skipping
```

**Proposed (good):**
```zsh
[INFO] ℹ️ Instruction file installation status:
  [S] 🔗 agent-chat-response-conventions.instructions.md
  [S] 🔗 agent-terminal-conventions.instructions.md
  [C] 📄 swift-conventions.instructions.md
  [ ]    python-conventions.instructions.md (not installed)
[SUCCESS] ✅ 10 of 11 instruction files installed (1 not installed)
```

This gives visibility into WHICH files and their status.

---

## Argument Structure Revamp Proposal

### User Clarifications

**✅ Confirmed:** We don't need separate `--instructions` flag. Each action can be:
- **Auto mode** (default): Execute without prompting
- **Prompt mode**: Show menu/confirmation via `--prompt <action>`

**✅ Confirmed:** Keep grouped action granularity for VSCode settings:
- `workspace-settings` - One action, shows menu for all workspace templates
- `user-settings` - One action, shows menu for all user templates
- Per-file granularity would be too painful for users

---

### Current Args → New Actions Mapping

| Current Argument | New Action Name | Prompt Behavior |
|-----------------|-----------------|-----------------|
| `--instructions` | `instructions` | Menu to select files |
| `--mcp-xcode` | `mcp-xcode` | Y/N confirmation |
| `--workspace-settings` | `workspace-settings` | Menu to select templates |
| `--user-settings` | `user-settings` | Menu to select templates |
| `--dev-link` | `dev-link` | Y/N confirmation |
| `--dev-vscode` | `dev-vscode` | Y/N confirmation |
| `--regenerate-main` | `regenerate-main` | Y/N confirmation |

---

### How Script Currently Handles `vscode/**/*.json`

**Two high-level group actions:**

#### `workspace-settings` → Shows unified menu for:
1. **Workspace templates:** `vscode/workspace/*.code-workspace`
   - Merge into active `*.code-workspace` file
2. **`.vscode` templates:** `vscode/workspace/.vscode/*.json`
   - Merge into `$dest_dir/.vscode/<basename>`

**Example menu:**
```zsh
 1. [workspace] swift → active workspace
 2. [workspace] xcode-mcpserver → active workspace  
 3. [.vscode] xcode-mcpserver__mcp.json → .vscode/mcp.json
 4. [.vscode] fileNesting__settings.json → .vscode/settings.json
```

#### `user-settings` → Shows menu for:
- **User templates:** `vscode/user/*.json`
  - Merge into `~/Library/Application Support/Code/User/<basename>`

**Example menu:**
```zsh
 1. [user] swift__settings.json → settings.json
 2. [user] chat__settings.json → settings.json  
 3. [user] github__settings.json → settings.json
```

**File naming:** `<topic>__<basename>` (double underscore separator)

---

### Current Problem: Boolean Flag Explosion

**Current design:**
```zsh
--instructions          # Boolean: handle instructions?
--prompt                # Boolean: show prompts?
--mcp-xcode            # Boolean: handle Xcode MCP?
--workspace-settings   # Boolean: handle workspace settings?
--user-settings        # Boolean: handle user settings?
--dev-link             # Boolean: create dev symlink?
--dev-vscode           # Boolean: add to VS Code workspace?
```

**Issues:**
1. Combinatorial complexity: 2^7 = 128 possible flag combinations
2. Unclear interactions: What does `--instructions --prompt --mcp-xcode` do?
3. Inconsistent behavior: Some flags auto-run, some require `--prompt`
4. Hard to extend: Adding new features requires new boolean flags

---

### Proposed Design: Action-Based with Scoped Prompting

**User's proposal:**
```zsh
--prompt <action>    # Repeatable: which actions should prompt?
```

**Interpretation A: `--prompt` as sole action trigger**

```zsh
# Syntax
./script --prompt <action> [--prompt <action> ...]

# Examples
./script --prompt instructions              # Prompt for instructions only
./script --prompt xcode-mcpserver          # Prompt for Xcode MCP only
./script --prompt instructions --prompt xcode-mcpserver  # Prompt for both

# Auto-install (no prompting) - how?
./script ???  # Need to discuss default behavior
```

**Questions:**
- What happens with no flags? Show info only?
- How do you auto-install without prompting?
- Do we keep `--instructions` as separate flag for auto-install?

---

**Interpretation B: Keep action flags, make `--prompt` scope which get prompted**

```zsh
# Syntax
./script [--<action>...] [--prompt [<action>...]]

# Examples
./script --instructions                     # Auto-install instructions (no prompt)
./script --instructions --prompt            # Prompt for instructions
./script --instructions --mcp-xcode --prompt xcode-mcpserver  # Auto instructions, prompt xcode

# Prompt for everything enabled
./script --instructions --mcp-xcode --prompt
```

**Benefits:**
- Action flags are explicit (clear what script will attempt)
- `--prompt` with no args means "prompt for everything enabled"
- `--prompt <action>` scopes prompting to specific actions
- Backward compatible: existing `--instructions` still works

---

### How Script Currently Handles `vscode/**/*.json` Files

The script has TWO high-level flags that show interactive menus:

#### 1. `--workspace-settings` → `run_workspace_settings_menu()`

Scans and presents menu for:
- **Workspace templates:** `vscode/workspace/*.code-workspace`
  - Example: `swift__workspace.code-workspace`
  - Example: `xcode-mcpserver__workspace.code-workspace`
  - Merges into: **active `*.code-workspace` file** (auto-detected or selected)
  
- **.vscode templates:** `vscode/workspace/.vscode/*.json`
  - Example: `xcode-mcpserver__mcp.json`
  - Example: `fileNesting__settings.json`
  - Merges into: `$dest_dir/.vscode/<basename>`

**Menu output:**
```zsh
Workspace templates available:
 1. [workspace] swift → active workspace
 2. [workspace] xcode-mcpserver → active workspace
 3. [.vscode] xcode-mcpserver__mcp.json → .vscode/mcp.json
 4. [.vscode] fileNesting__settings.json → .vscode/settings.json
Enter selections (e.g., '1 3' or 'all'):
```

#### 2. `--user-settings` → `run_user_settings_menu()`

Scans and presents menu for:
- **User templates:** `vscode/user/*.json`
  - Example: `swift__settings.json`
  - Example: `chat__settings.json`
  - Example: `github__settings.json`
  - Merges into: `~/Library/Application Support/Code/User/<basename>`

**Menu output:**
```zsh
User settings templates available:
 1. [user] swift__settings.json → settings.json
 2. [user] chat__settings.json → settings.json
 3. [user] github__settings.json → settings.json
Enter selections (e.g., '2 4' or 'all'):
```

#### File Naming Convention

Files use `__` (double underscore) as separator:
- `<theme>__<category>`
- Theme is used for menu display and topic identification
- Category is used for target filename

**Examples:**
- `swift__settings.json` → theme: `swift`, category: `settings.json`
- `xcode-mcpserver__mcp.json` → theme: `xcode-mcpserver`, category: `mcp.json`
- `fileNesting__settings.json` → theme: `fileNesting`, category: `settings.json`

---

### Proposed Valid Action Names

Based on current functionality:

| Action Name | Description | Current Flag | What It Does |
|-------------|-------------|--------------|--------------|
| `instructions` | Instruction file installation | `--instructions` | Shows menu or auto-installs `.github/instructions/*.md` |
| `workspace-settings` | VS Code workspace/vscode settings | `--workspace-settings` | Shows menu of `vscode/workspace/**/*.json` templates |
| `user-settings` | VS Code user profile settings | `--user-settings` | Shows menu of `vscode/user/*.json` templates |
| `dev-link` | Create dev symlink | `--dev-link` | Creates symlink + updates `.gitignore` |
| `dev-vscode` | Add to VS Code workspace | `--dev-vscode` | Adds folder to `*.code-workspace` |
| `regenerate-main` | Regenerate main instruction file | `--regenerate-main` | Regenerates `.github/copilot-instructions.md` |

**Special case (currently separate):**
- `--mcp-xcode` - This is currently a special case that:
  1. Detects Xcode artifacts
  2. Applies specific templates: `xcode-mcpserver__mcp.json` + `swift__workspace.code-workspace`
  3. Should this become just another template in `workspace-settings`? Or remain special?

**Future actions:**
- `claude-settings` - Claude AI settings
- `cursor-rules` - Cursor rules
- `coderabbit-config` - CodeRabbit configuration

---

### Action Granularity Discussion

**Question:** Should each `vscode/**/*.json` file be a separate action?

**Example approach 1: One action per file (too granular)**
```zsh
# Would require:
./script --prompt swift-workspace-settings \
         --prompt xcode-mcp-settings \
         --prompt file-nesting-settings \
         --prompt swift-user-settings \
         --prompt chat-user-settings
         
# This is painful!
```

**Example approach 2: Group by scope (current design)**
```zsh
# Much simpler:
./script --prompt workspace-settings  # All workspace + .vscode templates
./script --prompt user-settings       # All user profile templates

# Can still be selective in the menu
```

**Example approach 3: Hybrid (prompt for individual templates)**
```zsh
# Show menu but non-interactively apply specific ones:
./script --prompt workspace-settings:swift
./script --prompt workspace-settings:xcode-mcpserver
./script --prompt workspace-settings:all

# Or auto-apply without menu:
./script workspace-settings:swift
```

**Recommendation:** **Keep current grouped approach (Approach 2)**

**Rationale:**
1. User rarely wants to skip individual templates - they usually want "all workspace settings" or "all user settings"
2. The interactive menu allows fine-grained selection when needed
3. Simple to understand: "workspace" vs "user" is clear distinction
4. Easy to extend: add new templates, they auto-appear in menu
5. Matches user mental model: "configure my workspace" vs "configure my user profile"

**Special handling for `--mcp-xcode`:**
- This could be deprecated in favor of `--prompt workspace-settings` (select xcode templates from menu)
- OR: Keep it as convenience shortcut that auto-applies xcode-specific templates
- **Recommend:** Keep as convenience shortcut with note that templates are also in `workspace-settings` menu

---

### Proposed Argument Design (Final)

**Recommended: Interpretation B (keep action flags, scope prompting)**

```zsh
zparseopts -D -E -- \
  -instructions=flag_instructions \
  -mcp-xcode=flag_mcp_xcode \
  -workspace-settings=flag_workspace_settings \
  -user-settings=flag_user_settings \
  -dev-link=flag_dev_link \
  -dev-vscode=flag_dev_vscode \
  -prompt+:=opt_prompt_actions \
  # ... other flags ...
```

**Processing:**
```zsh
# Extract action names from --prompt flags
local -a prompt_actions=(${opt_prompt_actions[@]:#--prompt})

# Determine which actions are enabled
local -a enabled_actions=()
[[ -n "$flag_instructions" ]] && enabled_actions+=(instructions)
[[ -n "$flag_mcp_xcode" ]] && enabled_actions+=(xcode-mcpserver)
# ... etc ...

# Determine which actions should prompt
local -a actions_to_prompt=()
if [[ ${#prompt_actions[@]} -eq 0 ]]; then
  if [[ -n "$flag_prompt" ]]; then
    # --prompt with no args: prompt for ALL enabled actions
    actions_to_prompt=("${enabled_actions[@]}")
  else
    # No --prompt: auto-run all enabled actions
    actions_to_prompt=()
  fi
else
  # --prompt <action>: only prompt for specified actions
  actions_to_prompt=("${prompt_actions[@]}")
fi

# Execute each action
for action in "${enabled_actions[@]}"; do
  if [[ "${actions_to_prompt[@]}" =~ "$action" ]]; then
    execute_action_with_prompt "$action"
  else
    execute_action_auto "$action"
  fi
done
```

---

### Usage Examples with New Design

```zsh
# ═══════════════════════════════════════════════════════════
# CURRENT USE CASES (backward compatible)
# ═══════════════════════════════════════════════════════════

# 1. Auto-install all uninstalled instructions (no prompts)
./script --instructions

# 2. Show instructions menu interactively
./script --instructions --prompt

# 3. Auto-setup Xcode MCP
./script --mcp-xcode

# 4. Prompt for Xcode MCP setup
./script --mcp-xcode --prompt

# ═══════════════════════════════════════════════════════════
# NEW CAPABILITIES (with scoped prompting)
# ═══════════════════════════════════════════════════════════

# 5. Auto-install instructions, prompt for Xcode MCP
./script --instructions --mcp-xcode --prompt xcode-mcpserver

# 6. Prompt for instructions, auto-install Xcode MCP
./script --instructions --mcp-xcode --prompt instructions

# 7. Do multiple things, prompt for all
./script --instructions --mcp-xcode --workspace-settings --prompt

# 8. Do multiple things, prompt for specific ones
./script --instructions --mcp-xcode --workspace-settings \
  --prompt instructions --prompt workspace-settings
# (auto-installs xcode-mcpserver without prompting)

# ═══════════════════════════════════════════════════════════
# DEFAULT BEHAVIOR (no action flags)
# ═══════════════════════════════════════════════════════════

# 9. Show info about available instructions (no installation)
./script

# 10. Prompt for instructions (infer from --prompt argument)
./script --prompt instructions
# Equivalent to: ./script --instructions --prompt instructions
```

---

### Arguments Deprecated/Displaced

**Deprecated:**
- ❌ Old `--prompt` (boolean) → New `--prompt [<action>...]` (optional repeatable value)

**Displaced:**
- None! All existing action flags remain:
  - ✅ `--instructions`
  - ✅ `--mcp-xcode`
  - ✅ `--workspace-settings`
  - ✅ `--user-settings`
  - ✅ `--dev-link`
  - ✅ `--dev-vscode`

**Backward Compatibility:**
```zsh
# OLD (still works)
./script --instructions --prompt

# NEW (equivalent, but more explicit)
./script --instructions --prompt instructions

# Both achieve the same result, but new syntax is clearer
```

---

### Arguments Remaining for Discussion

**Configuration flags (unchanged):**
- `--source-dir <dir>` - User AI directory
- `--dest-dir <dir>` - Target repository directory  
- `--ai-platform <platform>` - AI platform (copilot/claude/cursor/coderabbit)
- `--configure-type <type>` - Installation method (copy/symlink)

**Meta flags (unchanged):**
- `--help` - Show help
- `--debug` - Enable debug logging
- `--dry-run` - Show what would happen

**Questions:**
1. Should `--prompt <action>` imply `--<action>` if not explicitly set?
   - Example: `./script --prompt instructions` auto-enables `--instructions`?
   - **Recommendation:** Yes, for convenience
   
2. What's the default behavior when NO flags provided?
   - **Current:** Show info about available instructions
   - **Proposed:** Same, but show more detail (status table)
   
3. Should we add a `--all` flag to enable all actions?
   - Example: `./script --all --prompt` (prompt for everything)
   - **Recommendation:** Not needed, user can be explicit

---

### Implementation Plan for Arg Revamp

**Phase 1: Make `--prompt` accept optional values**
```zsh
# Change zparseopts to accept repeatable optional values
-prompt+::=opt_prompt_actions  # Note the :: (optional value)
```

**Phase 2: Update action execution logic**
- Check if action is in `actions_to_prompt` list
- If yes: call `execute_with_prompt`
- If no: call `execute_auto`

**Phase 3: Update help text**
- Document new `--prompt [<action>...]` syntax
- Add examples showing scoped prompting
- Mark old `--prompt` as "prompts for all enabled actions"

**Phase 4: Add convenience inference**
- If `--prompt <action>` without `--<action>`, auto-enable the action
- Example: `./script --prompt instructions` → `./script --instructions --prompt instructions`

---

### Open Questions on Arg Revamp

**Q1: Should `--prompt <action>` auto-enable that action?**

Example:
```zsh
# User types this
./script --prompt instructions

# Should it be equivalent to this?
./script --instructions --prompt instructions
```

**Pros:**
- More convenient (less typing)
- User intent is clear: "I want to work with instructions"

**Cons:**  
- Less explicit (action flag not visible)
- Could be confusing if user expects to also set `--instructions`

**Recommendation:** YES - auto-enable for convenience. Document clearly in help.

---

**Q2: How to handle "prompt for all" vs "prompt for specific"?**

**Option A: Empty `--prompt` means all**
```zsh
./script --instructions --mcp-xcode --prompt          # Prompt for both
./script --instructions --mcp-xcode --prompt instructions  # Prompt only instructions
```

**Option B: Special keyword for all**
```zsh
./script --instructions --mcp-xcode --prompt all      # Prompt for both
./script --instructions --mcp-xcode --prompt instructions  # Prompt only instructions
```

**Recommendation:** Option A - empty `--prompt` is more intuitive.

---

**Q3: Should we validate action names?**

If user types:
```zsh
./script --prompt instrutions  # Typo!
```

Should we:
- **Option A:** Error: "Invalid action 'instrutions'. Did you mean 'instructions'?"
- **Option B:** Warning: "Unknown action 'instrutions' - ignoring"
- **Option C:** Silently ignore

**Recommendation:** Option A - fail fast with helpful error message.

---

## Argument Overhaul Contract (Pre-Refactor Lock)

This section is the **implementation contract** for the new argument scheme.
Refactoring should not start until this contract is accepted as complete coverage of existing behavior.

### 1) Target Types (Final)

The new scheme has two target types:

1. **Settings selectors** (JSON merge targets)
  - Syntax: `<scope>[:<category>][:<theme>]`
  - Scope: `user` | `workspace` | `folder`
  - Category (initial): `settings` | `mcp`
  - Theme: parsed from `<theme>__<category>.json` prefix

2. **Action targets** (non-selector operations)
  - `instructions`
  - `mcp-xcode`
  - `dev-link`
  - `dev-vscode`
  - `regenerate-main`

### 2) New Flag Semantics (Final)

```zsh
--prompt <target>       # run target in interactive mode
--no-prompt <target>    # run target in automatic mode
```

Rules:
- `--prompt` and `--no-prompt` are repeatable.
- Mentioning a target under either flag **enables** that target.
- Bare `--prompt` (no value) means: prompt all currently enabled targets.
- Unknown/invalid target is a hard error with suggestion.
- Conflict (`--prompt X` and `--no-prompt X`) is a hard error.

### 3) Selector Rules (Final)

- Only `user|workspace|folder` support `:category` and `:theme` selectors.
- `instructions`, `mcp-xcode`, `dev-link`, `dev-vscode`, `regenerate-main` do **not** accept hierarchy.
- `instructions:*` is invalid.
- If category is omitted, all categories in scope match.
- If theme is omitted, all themes in matched category match.

### 4) Backward Compatibility Rules (Final)

Legacy flags remain temporarily, mapped to new targets:

| Legacy Flag | Normalized Target | Mode if no `--prompt` target override |
|------------|-------------------|----------------------------------------|
| `--instructions` | `instructions` | auto |
| `--workspace-settings` | `workspace` | prompt (menu) for legacy parity |
| `--user-settings` | `user` | prompt (menu) for legacy parity |
| `--mcp-xcode` | `mcp-xcode` | auto |
| `--dev-link` | `dev-link` | auto |
| `--dev-vscode` | `dev-vscode` | auto |
| `--regenerate-main` | `regenerate-main` | auto |

`--vscode-settings` continues as alias to `--workspace-settings` during migration.

### 5) Behavior Contract Matrix (Action × prompt/no-prompt)

| Target | `--prompt <target>` | `--no-prompt <target>` |
|-------|----------------------|------------------------|
| `instructions` | Show instruction status/menu always; user selects files; Enter = skip | Auto-install by configured method for eligible files |
| `user[:cat[:theme]]` | Show filtered user-template menu, then merge selections | Auto-merge all filtered user templates |
| `workspace[:cat[:theme]]` | Show filtered workspace/.vscode template menu, then merge selections | Auto-merge all filtered workspace templates |
| `folder[:cat[:theme]]` | Show filtered `.vscode` template menu for folder scope | Auto-merge all filtered folder templates |
| `mcp-xcode` | Y/N confirm prompt then apply MCP+swift templates | Apply MCP+swift templates directly |
| `dev-link` | Y/N confirm then create symlink + `.gitignore` update | Create symlink + `.gitignore` update |
| `dev-vscode` | Y/N confirm then add folder to workspace | Add folder to workspace |
| `regenerate-main` | Y/N confirm then regenerate/sync main file | Regenerate/sync main file |

### 6) Existing Functionality Coverage Checklist

| Existing Capability | Covered by New Scheme? | Target Syntax |
|---------------------|------------------------|---------------|
| Instruction installation menu | ✅ | `--prompt instructions` |
| Instruction auto-install | ✅ | `--no-prompt instructions` |
| Workspace settings menu merge | ✅ | `--prompt workspace` (or filtered selector) |
| Workspace settings auto-merge | ✅ | `--no-prompt workspace[:category[:theme]]` |
| User settings menu merge | ✅ | `--prompt user` (or filtered selector) |
| User settings auto-merge | ✅ | `--no-prompt user[:category[:theme]]` |
| Xcode MCP apply | ✅ | `--no-prompt mcp-xcode` |
| Xcode MCP prompt/confirm | ✅ | `--prompt mcp-xcode` |
| Dev symlink (`--dev-link`) | ✅ | `--no-prompt dev-link` / `--prompt dev-link` |
| Add dev folder to workspace (`--dev-vscode`) | ✅ | `--no-prompt dev-vscode` / `--prompt dev-vscode` |
| Regenerate main instruction file | ✅ | `--no-prompt regenerate-main` / `--prompt regenerate-main` |
| Source/dest/platform/configure-type options | ✅ (unchanged) | Keep existing option flags |
| Deprecated alias `--vscode-settings` | ✅ (temporary) | Alias to `workspace` target |

### 7) Gaps To Close Before Refactor Starts

These are implementation gaps, not design gaps:

1. `--no-prompt` does not exist in parser yet.
2. `--prompt <value>` is not parsed as value list yet (currently boolean only).
3. Target normalization/validation/conflict detection is not implemented yet.
4. Action dispatcher is still hardcoded legacy flow order.
5. `mcp-xcode` still piggybacks global prompt behavior; must become target-scoped.
6. Help/docs currently mix future and current behavior and need contract-aligned wording.

### 8) Readiness Decision

**Are we ready to refactor?**

- **Yes, with this contract locked.**
- No additional behavior-design work is required to begin.
- Remaining work is implementation against this contract.

---

## Implementation Plan (Argument Overhaul)

### Phase A — Parser + Normalization

1. Add repeatable value parsing:
  - `-prompt+:=opt_prompt_targets`
  - `-no-prompt+:=opt_no_prompt_targets`
2. Parse targets into normalized structures:
  - `enabled_targets`
  - `prompt_targets`
  - `auto_targets`
3. Add validation:
  - unknown targets
  - invalid selector hierarchy
  - prompt/auto conflicts

### Phase B — Dispatcher Refactor

4. Replace monolithic tail logic with dispatcher by normalized targets.
5. Add per-target `run_prompt_<target>` and `run_auto_<target>` wrappers.
6. Keep legacy flags as adapters that feed normalized targets.

### Phase C — Settings Selector Engine

7. Implement selector resolution for `user|workspace|folder` by `scope/category/theme`.
8. Reuse existing menu render/merge code with filtered template sets.
9. Support both interactive and auto application for same selector engine.

### Phase D — Non-Selector Actions

10. Move `instructions`, `mcp-xcode`, `dev-link`, `dev-vscode`, `regenerate-main` into target-scoped handlers.
11. Remove global prompt coupling from `mcp-xcode` path.
12. Ensure instruction menu always appears under `--prompt instructions`.

### Phase E — UX + Docs + Tests

13. Update `print_usage` and `scripts/HELP_OUTPUT_PROPOSED.md` to match this contract.
14. Add behavior tests (or scripted probes) for each matrix row.
15. Verify migration behavior for legacy flags and alias.

### Exit Criteria (Start Coding Gate)

Refactor branch can start once:
- Contract section above is accepted.
- No unresolved target/syntax decisions remain.
- Matrix rows are represented in test checklist.

---

## Next Steps

1. **Review this document** - User and AI discuss argument revamp proposal
2. **Answer open questions** - Decide on:
   - Q1: Auto-enable actions when `--prompt <action>` used?
   - Q2: Empty `--prompt` vs `--prompt all`?
   - Q3: Validate action names strictly?
3. **Prioritize changes** - Decide implementation order:
   - Phase 1: Fix critical menu bugs (numbering, skip logic)
   - Phase 2: Implement argument revamp
   - Phase 3: Add advanced features
4. **Create feature branch** - `git checkout -b fix/configure-instructions-overhaul`
5. **Implement Phase 1** - Critical fixes
6. **Test thoroughly** - Run all test cases
7. **Implement Phase 2** - Argument revamp
8. **Document changes** - Update help text and README

---

## Decisions Made

### Q1: Menu Display Default

When user presses Enter without selecting anything:

**Option A:** Skip all changes (current behavior) ← **USER PREFERENCE**
```zsh
Default action (press Enter): skip (no changes)
```

**Option B:** Apply to pre-selected (installed) files
```zsh
Default selection: 1 2 3
Press Enter to re-install these files, or enter new selection:
```

**Discussion:** User prefers Option A - always defer to user, don't assume they want to re-install.

---

### Q2: Action Intent UI

**Option A:** Simple - show method in header (easier to implement)
```zsh
[INFO] Installation method: SYMLINK
```

**Option B:** Advanced - allow per-file actions (more powerful)
```zsh
Enter selection (prefix with action):
  S 1 2 3   - Symlink files 1, 2, 3
  C 4       - Copy file 4
```

**Discussion:** Option A gets us working faster. Option B provides much better UX but requires significant parser changes. Should we do A now, B later? Or skip B entirely?

---

### Q3: Handling Already-Installed Files

When user selects an already-installed file from menu:

**Option A:** Skip with info message
```zsh
[INFO] File already installed: agent-terminal-conventions.instructions.md
```

**Option B:** Re-install (replace)
```zsh
[INFO] Re-installing: agent-terminal-conventions.instructions.md
```

**Option C:** Ask user
```zsh
[PROMPT] File already installed. Re-install? [y/N]:
```

**Discussion:** Option B seems most useful (allows updating), but should we confirm if file is modified? Or always replace?

---

### Q4: Mixed Configure Types

Currently, `--configure-type` applies to ALL files. Should we support mixed installations?

**Example:**
- User wants to symlink platform-agnostic files (agent, git, markdown)
- User wants to copy language-specific files (swift, python) to customize per-project

**Possible Solutions:**
- Add per-file action syntax (Q2 Option B)
- Add include/exclude patterns for configure-type
- Leave as-is (single type per invocation)

**Discussion:** Is this a real use case? Or academic?

---

## Migration Concerns

### Breaking Changes

1. **Xcode MCP separation** - Users relying on automatic MCP detection will need to add `--mcp-xcode` flag
   - **Mitigation:** Keep detection, but only show info message without installing
   - **Mitigation:** Document in changelog

2. **Menu always shows with `--prompt`** - Scripts expecting quick skip may now show menu
   - **Mitigation:** This is actually the correct behavior
   - **Mitigation:** Users can remove `--prompt` if they want auto-behavior

### Backward Compatibility

All existing working use cases should continue to work:
- `--instructions` alone still auto-installs
- `--configure-type copy/symlink` still works
- All other flags unchanged

---

## Success Criteria

### Phase 1 Complete When:

- ✅ User can run `--prompt` and see menu regardless of installation state
- ✅ User can run `--instructions --prompt` without seeing Xcode MCP menu
- ✅ Menu numbering displays correctly for 10+ files
- ✅ All test cases in Testing Matrix pass
- ✅ No regressions in existing functionality

### Phase 2 Complete When:

- ✅ User knows what action will be taken before selecting files
- ✅ Help text clearly explains all flag combinations
- ✅ Examples cover common use cases

### Phase 3 Complete When:

- ✅ User can perform mixed operations in single invocation
- ✅ User can remove/update existing installations from menu
- ✅ Complex use cases documented and tested

---

## Next Steps

1. **Review this document** - User and AI discuss solutions and answer open questions
2. **Prioritize changes** - Decide which phases to implement now vs. later
3. **Create feature branch** - `git checkout -b fix/configure-instructions-menu`
4. **Implement Phase 1** - Critical fixes only
5. **Test thoroughly** - Run all test cases in matrix
6. **Document changes** - Update help text and README
7. **Deploy and monitor** - Watch for issues in real usage

---

## Notes

- Keep this document updated as decisions are made
- Move resolved questions to "Decisions" section
- Track implementation progress with checkboxes
- Link to PRs/commits as work completes

---

## Decisions Made

### ✅ DECISION: Adopt Colon-Delimited Hierarchical Syntax

**Proposed syntax:** `--prompt <scope>[:<category>][:<theme>]`

**Approved by user** - This provides the right balance of flexibility and clarity.

---

## VSCode Config File Architecture

### Terminology (Finalized)

| Term | Definition | Examples | Notes |
|------|------------|----------|-------|
| **Scope** | Top-level location/context | `user`, `workspace`, `folder` | Where the config lives |
| **Category** | Target file type | `settings`, `mcp`, `tasks`, `launch` | What kind of config |
| **Theme** | Topic/purpose | `swift`, `xcode-mcpserver`, `chat` | What the config is about |

### Filename Convention

**Pattern:** `<theme>__<category>.<ext>`

- **Theme** - Parsed from filename prefix before `__`
- **Category** - Parsed from filename suffix after `__`
- **Separator** - Double underscore `__` (required)

**Examples:**
```
swift__settings.json           → Theme: swift,  Category: settings
xcode-mcpserver__mcp.json      → Theme: xcode-mcpserver,  Category: mcp
chat__settings.json            → Theme: chat,  Category: settings
ai_autoapprove__workspace.code-workspace  → Theme: ai_autoapprove,  Category: workspace
```

### Directory Structure & Scopes

```
vscode/
├── user/                          # SCOPE: user
│   ├── swift__settings.json       # → ~/Library/.../User/settings.json
│   ├── chat__settings.json        # → ~/Library/.../User/settings.json
│   ├── atlassian__mcp.json        # → ~/Library/.../User/mcp.json
│   └── github__settings.json      # → ~/Library/.../User/settings.json
│
└── workspace/                     # SCOPE: workspace
    ├── *.code-workspace           # → $dest_dir/*.code-workspace (active)
    │   ├── swift__workspace.code-workspace
    │   ├── xcode-mcpserver__workspace.code-workspace
    │   └── ai_autoapprove__workspace.code-workspace
    │
    └── .vscode/                   # SCOPE: folder (workspace root folder)
        ├── xcode-mcpserver__mcp.json      # → $dest_dir/.vscode/mcp.json
        ├── atlassian-mcpserver__mcp.json  # → $dest_dir/.vscode/mcp.json
        └── fileNesting__settings.json     # → $dest_dir/.vscode/settings.json
```

### How Target File is Computed

#### For `user/` scope:
```
Source:      vscode/user/<theme>__<category>.json
Target:      ~/Library/Application Support/Code/User/<category>.json
```

#### For `workspace/` scope (workspace files):
```
Source:      vscode/workspace/<theme>__workspace.code-workspace
Target:      $dest_dir/*.code-workspace (auto-detected, most recent if multiple)
```

#### For `folder/` scope (root folder `.vscode/`):
```
Source:      vscode/workspace/.vscode/<theme>__<category>.json
Target:      $dest_dir/.vscode/<category>.json
```

### Multiple Sources → One Target File

Multiple templates can merge into the same target file:

```
# These all merge into ~/Library/.../User/settings.json
user/swift__settings.json
user/chat__settings.json
user/github__settings.json

# These all merge into $dest_dir/.vscode/mcp.json
workspace/.vscode/xcode-mcpserver__mcp.json
workspace/.vscode/atlassian-mcpserver__mcp.json
```

---

## New Argument Syntax: Colon-Delimited Hierarchy

### Syntax Specification

```
--prompt <scope>[:<category>][:<theme>]
--no-prompt <scope>[:<category>][:<theme>]
```

Where:
- `<scope>` - Required: `user` | `workspace` | `folder` | `instructions`
- `:<category>` - Optional: `settings` | `mcp` | `tasks` | `launch` | etc.
- `:<theme>` - Optional: `swift` | `xcode-mcpserver` | `chat` | etc.

### Specificity Levels

| Specificity | Pattern | Example | What It Matches |
|-------------|---------|---------|-----------------|
| **Broad** | `<scope>` | `--prompt user` | All categories & themes in user scope |
| **Medium** | `<scope>:<category>` | `--prompt workspace:mcp` | All MCP configs in workspace scope |
| **Narrow** | `<scope>:<category>:<theme>` | `--prompt user:settings:swift` | Only swift settings in user scope |

### Example Usage

```zsh
# ════════════════════════════════════════════════════════════
# SCOPE ONLY (broadest - all categories & themes)
# ════════════════════════════════════════════════════════════

# All user configs (settings, mcp, tasks, etc.)
./script --prompt user

# All workspace configs (workspace files + .vscode folder)
./script --prompt workspace

# All folder configs (.vscode/ only)
./script --prompt folder

# ════════════════════════════════════════════════════════════
# SCOPE + CATEGORY (medium specificity)
# ════════════════════════════════════════════════════════════

# All settings in workspace (any theme)
./script --prompt workspace:settings

# All MCP configs in user (any theme)
./script --prompt user:mcp

# All MCP configs in folder scope
./script --prompt folder:mcp

# ════════════════════════════════════════════════════════════
# SCOPE + CATEGORY + THEME (narrowest - most specific)
# ════════════════════════════════════════════════════════════

# Only swift settings in user
./script --prompt user:settings:swift

# Only xcode-mcpserver MCP in workspace
./script --prompt workspace:mcp:xcode-mcpserver

# Only fileNesting settings in folder
./script --prompt folder:settings:fileNesting

# ════════════════════════════════════════════════════════════
# MULTIPLE ACTIONS
# ════════════════════════════════════════════════════════════

# Merge workspace MCP AND user settings
./script --prompt workspace:mcp --prompt user:settings

# Auto-merge workspace MCP, prompt for user settings
./script --no-prompt workspace:mcp --prompt user:settings

# ════════════════════════════════════════════════════════════
# COMBINED WITH INSTRUCTIONS
# ════════════════════════════════════════════════════════════

# Instructions + workspace MCP
./script --prompt instructions --prompt workspace:mcp

# Auto-install instructions, prompt for workspace configs
./script --no-prompt instructions --prompt workspace
```

### Special Cases

#### Instructions Action
```zsh
# Instructions is a special scope (not VSCode configs)
./script --prompt instructions
./script --no-prompt instructions

# No hierarchy for instructions (it's just files)
# These are INVALID:
./script --prompt instructions:something  # ❌ NO
```

#### Other Actions (dev-link, dev-vscode, etc.)
```zsh
# These remain simple actions (no hierarchy)
./script --prompt dev-link
./script --prompt dev-vscode
./script --prompt mcp-xcode       # Special shortcut, may deprecate
./script --prompt regenerate-main
```

### Implementation Notes

**Parsing logic (Zsh):**
```zsh
# Split on colon using zsh parameter expansion
local -a parts=(${(s.:.)action_spec})
local scope="${parts[1]}"
local category="${parts[2]:-}"
local theme="${parts[3]:-}"

# Match files based on specificity
if [[ -n "$theme" && -n "$category" ]]; then
  # Narrow: scope + category + theme
  # Match: vscode/<scope>/<theme>__<category>.json
elif [[ -n "$category" ]]; then
  # Medium: scope + category
  # Match: vscode/<scope>/*__<category>.json
else
  # Broad: scope only
  # Match: vscode/<scope>/*__*.json (all files)
fi
```

### Future: Pattern Matching (Phase 2+)

Not implementing initially, but syntax could support:

```zsh
# Multiple themes (OR)
./script --prompt workspace:settings:swift|python

# Wildcard matching
./script --prompt workspace:mcp:xcode*

# Multiple categories
./script --prompt user:settings|mcp:swift
```

**Decision:** Phase 2 feature - requires more complex parsing.

---

## Future: Multi-Folder Support

### Current Limitation

Script currently only supports **workspace root folder** (`.vscode/` at `$dest_dir/.vscode/`).

VS Code actually supports per-folder `.vscode/` for each workspace folder:

```
$dest_dir/
├── .vscode/              # Root folder (currently supported)
│   ├── settings.json
│   └── mcp.json
├── scripts/
│   └── .vscode/          # Scripts folder (NOT YET supported)
│       └── settings.json
└── tests/
    └── .vscode/          # Tests folder (NOT YET supported)
        └── settings.json
```

### Proposed Future Syntax

```zsh
# Syntax: folder[folder_name]:<category>:<theme>

# All folders (root + subfolders)
./script --prompt folder:settings

# Specific folder by name
./script --prompt folder[scripts]:settings

# Root folder explicitly
./script --prompt folder[]:settings
```

**Priority:** After argument overhaul complete.

---

## Future: Markdown App Icons (Phase 3+)

### Current Behavior

AI agents across workspaces using this repo's instructions create/add application icons as defined in `markdown-conventions.instructions.md`:

**Example (notes workspace):**
- Absolute: `/Users/zakkhoyt/Documents/notes/docs/images/icons/accessibility_inspector.png`
- Relative: `docs/images/icons/accessibility_inspector.png`

**Observation:** Icons are currently duplicated across workspaces. Each workspace maintains its own copy in a consistent location (`docs/images/icons/`), but this leads to:
1. **Duplication** - Same app icon stored in multiple repos
2. **Inconsistency** - Different versions/variants of same icon across workspaces
3. **Maintenance burden** - Updates require changing all copies

### Proposed Solution: Centralized Icon Archive + Symbolic Links

**Concept:** Maintain single source of truth for app icons in this repository, then symlink them into target workspaces (similar to instruction file linking).

**Architecture:**
```
~/.ai/                               # This repository
├── assets/
│   └── icons/
│       ├── accessibility_inspector.png
│       ├── xcode.png
│       ├── safari.png
│       └── ...
│
/path/to/notes/                      # Target workspace
├── docs/
│   └── images/
│       └── icons/                   # Symlinked directory
│           ├── accessibility_inspector.png → ~/.ai/assets/icons/accessibility_inspector.png
│           ├── xcode.png → ~/.ai/assets/icons/xcode.png
│           └── ...
```

**Benefits:**
1. **Single source** - One copy of each icon
2. **Automatic propagation** - New icons added to source immediately available in all workspaces
3. **Consistency** - All workspaces use identical icons
4. **Disk efficiency** - No duplication

### Integration with configure_ai_instructions.zsh

**New Action:** `app-icons`

```zsh
# Prompt to install app icons
./configure_ai_instructions.zsh --prompt app-icons

# Auto-install all app icons
./configure_ai_instructions.zsh --no-prompt app-icons
```

**Menu-driven interface:**
```zsh
[INFO] ℹ️  === App Icon Installation ===
[INFO] ℹ️  Target directory: docs/images/icons/
[INFO] ℹ️  Available app icons:
  1. [ ] accessibility_inspector.png
  2. [🔗] xcode.png
  3. [ ] safari.png
  4. [ ] terminal.png
  ...

Enter selections (e.g., '1 3 5' or 'all'):
```

**Implementation approach:**
```zsh
install_app_icons() {
  local source_dir="$HOME/.ai/assets/icons"
  local target_dir="${icon_dir:-docs/images/icons}"  # Customizable
  
  # Create target directory if needed
  mkdir -p "$target_dir"
  
  # Symlink icons (similar to instruction file logic)
  # ...
}
```

### Open Questions

#### 1. Directory vs File Symlinks

**Option A: Symlink entire directory**
```zsh
ln -s ~/.ai/assets/icons docs/images/icons
```

**Pros:**
- Simple - one symlink
- New icons automatically appear
- Easy to maintain

**Cons:**
- All-or-nothing - can't selectively include icons
- May expose unused icons in workspace
- Harder to track which icons are actually used

**Option B: Symlink individual files**
```zsh
ln -s ~/.ai/assets/icons/xcode.png docs/images/icons/xcode.png
ln -s ~/.ai/assets/icons/safari.png docs/images/icons/safari.png
```

**Pros:**
- Selective - only link needed icons
- Clear tracking of what's used
- Menu can show install status per icon

**Cons:**
- More complex - multiple symlinks
- New icons require manual linking
- Requires icon discovery mechanism

**Recommendation:** Option B (individual file symlinks) for consistency with instruction file behavior and explicit control.

#### 2. Icon Target Directory Customization

**Current observation:** `docs/images/icons/` is common but not universal.

**Proposed solutions:**

**Option A: Configuration flag**
```zsh
./configure_ai_instructions.zsh --prompt app-icons --icon-dir path/to/icons
```

**Option B: Auto-detect from existing structure**
```zsh
# Script searches for existing icon directories:
find "$dest_dir" -type d -name "icons" 2>/dev/null

# If found: use existing location
# If multiple: prompt user to select
# If none: use default docs/images/icons/
```

**Option C: Configuration file**
```json
// .ai-config.json
{
  "iconDirectory": "docs/images/icons"
}
```

**Recommendation:** Option B (auto-detect) with fallback to `docs/images/icons/` as default. Avoids config file overhead while supporting common patterns.

#### 3. New Icon Discovery by AI Agents

**Scenario:** AI agent needs an icon not yet in central archive.

**Proposed workflow:**

1. **Agent checks source of truth:**
   ```zsh
   # Check if icon exists in ~/.ai/assets/icons/
   if [[ -f ~/.ai/assets/icons/new_app.png ]]; then
     # Create symlink in workspace
     ln -s ~/.ai/assets/icons/new_app.png docs/images/icons/new_app.png
   fi
   ```

2. **If not found, agent:**
   - Downloads/creates icon
   - Saves to central archive: `~/.ai/assets/icons/new_app.png`
   - Creates symlink in workspace
   - (Optional) Updates manifest/index file

3. **Instruction file update:**
   - Update `markdown-conventions.instructions.md` to include new discovery workflow
   - Add section on checking central archive first
   - Document fallback behavior (download → save to archive → link)

**Required instruction additions:**
```markdown
## App Icon Management

When adding app icons to markdown documentation:

1. **Check central archive first:**
   - Source: `~/.ai/assets/icons/`
   - If icon exists, create symlink to workspace icons directory
   
2. **If icon doesn't exist:**
   - Download/create icon (PNG format, 512x512 recommended)
   - Save to central archive: `~/.ai/assets/icons/<app_name>.png`
   - Create symlink in workspace: `<icon_dir>/<app_name>.png`
   
3. **Icon naming convention:**
   - Lowercase with underscores: `accessibility_inspector.png`
   - No spaces or special characters
   - Descriptive and consistent
```

#### 4. Relationship to Existing Script Logic

**Evaluation needed:**
- Does script already handle `docs/images/icons/` or similar directories?
- Are there existing asset management patterns to follow?
- Should this integrate with `--dev-link` or `--dev-vscode` features?

**Answer:** Script does NOT currently handle icon assets. This would be entirely new functionality following the template/symlink pattern established for:
- Instruction files (`.github/instructions/*.md`)
- VSCode settings (`vscode/**/*.json`)

### Implementation Priority

**Priority:** Low - Phase 3+

**Rationale:**
- Dependent on core argument overhaul completion
- Requires new asset directory structure in this repo
- Need to establish icon naming conventions
- Should follow same patterns as instruction/settings features

**Prerequisites:**
1. Complete argument syntax overhaul (scope:category:theme)
2. Implement new menu system
3. Test with instruction and VSCode settings features
4. Create `assets/icons/` directory structure
5. Populate with common app icons

**Implementation phases:**
1. **Phase 3a:** Create asset directory, populate with initial icons
2. **Phase 3b:** Add menu logic (mirror instruction file menu)
3. **Phase 3c:** Update `markdown-conventions.instructions.md` with discovery workflow
4. **Phase 3d:** Test with multiple workspaces

---

## Future: Additional Categories (Phase 2+)

### Planned Categories

| Category | Filename | Current Support |
|----------|----------|-----------------|
| `settings` | `settings.json` | ✅ Yes |
| `mcp` | `mcp.json` | ✅ Yes |
| `tasks` | `tasks.json` | ❌ Future |
| `launch` | `launch.json` | ❌ Future |
| `extensions` | `extensions.json` | ❌ Future |
| `keybindings` | `keybindings.json` | ❌ Future (user only) |

### Implementation Goal

Adding new categories should require **ZERO code changes** - just drop template files in appropriate directory.

**Priority:** After argument overhaul + multi-folder support.

---

## Future: Xcode Project Auto-Detection (Phase 3+)

### Current Behavior

The script automatically detects Xcode projects and prompts for MCP server installation:

**Detection Logic:**
- Scans target directory for: `Package.swift`, `*.xcworkspace`, `*.xcodeproj`
- When detected: Prompts user to install Xcode MCP server configuration
- Files modified:
  - Most recent `*.code-workspace` file (merged)
  - `.vscode/mcp.json` (created/merged)

**Problem:** This happens automatically regardless of user flags, which:
- Interrupts workflow when user didn't request it
- Conflicts with explicit `--prompt` specifications
- Makes behavior unpredictable

### Proposed Rework

**Goal:** Make auto-detection opt-in and integrate with new argument system.

**Approach:**
```zsh
# Explicit request (new syntax)
./script --prompt workspace:mcp:xcode-mcpserver

# Auto-detection with opt-in
./script --detect-project-type --prompt workspace:mcp

# Or as a new flag
./script --auto-configure-mcp
```

**Design Questions:**
1. Should detection be completely opt-in, or prompt only if detected?
2. Should this work for other project types (Node.js, Python, etc.)?
3. How to make this extensible for future MCP servers?

**Potential Extensions:**
- Detect Node.js projects → suggest Node MCP configs
- Detect Python projects → suggest Python MCP configs
- Detect Swift Package → suggest Swift-specific settings
- Detect React/Vue → suggest framework-specific configs

**Priority:** Low - Revisit after core argument overhaul and category expansion complete. Current behavior works for most cases, just needs refinement.

---

## Decisions Made

*(To be filled in during discussion)*

---

## References

- [configure_ai_instructions.zsh](scripts/configure_ai_instructions.zsh)
- [Original bug report](scripts/configure_ai_instructions.zsh.md)
- [Related issue: Numbering bug](scripts/configure_ai_instructions.zsh.md#L74-L75)
- [Related issue: Menu skip bug](scripts/configure_ai_instructions.zsh.md#L76-L80)
