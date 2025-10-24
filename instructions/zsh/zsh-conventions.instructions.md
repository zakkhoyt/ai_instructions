---
applyTo: "**/*.zsh"
---

# Universal Zsh Scripting Conventions

**IMPORTANT**: These conventions apply to **ALL** `.zsh` files in this repository, regardless of location or purpose. Path-specific instruction files inherit and extend these base rules.

---

## ⚡ Quick Compliance Checklist

When writing or modifying **ANY** Zsh script in this repository, ensure:

- ✅ **Zsh expansion used** - Parameter expansion, array manipulation (see [Zsh Expansion](#zsh-expansion-required))
  - Use `${var:-default}`, `${#array[@]}`, `${(f)"string"}`, `${(F)array[@]}`, `${array:#pattern}`, etc.
  - Use `(f)` to split strings into arrays, `(F)` to join arrays into strings
  - Avoid external commands when Zsh builtins suffice (`dirname`, `basename`, `wc`, etc.)
- ✅ **Shellcheck directives present** - Standard 3 directives after shebang
- ✅ **Header comments complete** - "About this Script" section with description
- ✅ **Source utilities correctly** - Use `source_dirs` array pattern (see [Source Scripting Utilities](#source-scripting-utilities))
- ✅ **zparseopts used** - With `-D --` flags (see [Script Argument Parsing](#script-argument-parsing))
  - Must include `--help=flag_help` and `{d,-debug}+=flag_debug`
- ✅ **Logging functions used** - `slog_*` functions (or `log_*` for setup scripts)
- ✅ **Function syntax correct** - Use `function name { }` (not `name() { }`)
- ✅ **Functions use named arguments** - Prefer `zparseopts` over positional parameters (see [Function Arguments](#function-arguments-named-vs-positional))
- ✅ **Variable naming follows conventions** - `lower_snake` for local/file-scoped, `UPPER_SNAKE` for cross-file/exported
- ✅ **No reserved keywords** - Avoid `path`, `command`, `status`, `functions`, etc. (see [Reserved Keywords](#reserved-keywords))

**→ If unsure about any item, refer to the detailed sections below.**

---

## Table of Contents

1. [Shellcheck Directives](#shellcheck-directives)
2. [Header Comments](#header-comments)
3. [Source Scripting Utilities](#source-scripting-utilities)
4. [Script Argument Parsing](#script-argument-parsing)
5. [Help and Usage Functions](#help-and-usage-functions)
6. [Variable Naming Conventions](#variable-naming-conventions)
7. [Function Syntax](#function-syntax)
8. [Zsh Expansion (Required)](#zsh-expansion-required)
9. [Error Handling and Logging Pattern](#error-handling-and-logging-pattern)
10. [Context Logging](#context-logging)
11. [Recommendations](#recommendations)

---

## Shellcheck Directives

All Zsh scripts must include these directives immediately after the shebang to enable proper linting:

```zsh
# shellcheck shell=bash # trick shellcheck into working with zsh
# shellcheck disable=SC2296 # Falsely identifies zsh expansions
# shellcheck disable=SC1091 # Complains about sourcing without literal path
```

**Rationale**: These directives allow shellcheck to work with Zsh-specific syntax while suppressing false positives.

---

## Header Comments

All Zsh scripts must include a header comment block after the shebang and shellcheck directives.

### Required Header Structure

```zsh
#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
#
# Purpose: Brief description of what this script does
# Author: Your name or team
# Usage: ./script_name.zsh [options]
#
```

### Minimum Required Information

At minimum, all scripts must document:

1. **Purpose**: One-line description of what the script does
2. **Author**: Who wrote or maintains the script
3. **Usage**: How to call the script (basic syntax)

### Standard Section Headers

Use these standard section headers to organize script structure:

```zsh
# ---- ---- ----  About this Script  ---- ---- ----
# [Header comments here]

# ---- ---- ----   Argument Parsing   ---- ---- ----
# [Argument parsing code]

# ---- ---- ----     Script Work     ---- ---- ----
# [Main script logic]
```

### Path-Specific Requirements

Some script locations require more detailed header comments:

-   **Setup scripts** (`scripts/**/setup*.zsh`): Must include comprehensive headers documenting all operations, requirements, and warnings. See `setup-scripts.instructions.md` for detailed requirements.
-   **Utility scripts** (`scripts/utilities/**/*.zsh`): Should document whether the script can be executed standalone or must be sourced.
-   **Executable scripts** (`assets/hatch_home/scripts/**/*.zsh`): Should include usage examples and any environment dependencies.

---

## Source Scripting Utilities

**CRITICAL**: All Zsh scripts must source `.zsh_scripting_utilities` to access shared logging functions (`slog_*`) and utility functions.

### Required Pattern

Immediately after the shebang and shellcheck directives, source `.zsh_scripting_utilities` with fallback paths:

```zsh
#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
# [Your header comments]

# ---- ---- ----     Source Utilities     ---- ---- ----

# Determine script directory for relative path fallback
script_dir="${0:A:h}"

# Define standard source file directories (used for utilities and trap handlers)
source_dirs=(
  "${HATCH_SOURCE_DIR:-}"
  "$HOME/.hatch/source"
  "$HOME/.zsh_home/utilities"
  "$script_dir/../../assets/hatch_home/source"
)

# Source .zsh_scripting_utilities
unset -v scripting_utilities_found
for source_dir in "${source_dirs[@]}"; do
  if [[ -n "$source_dir" && -f "$source_dir/.zsh_scripting_utilities" ]]; then
    source "$source_dir/.zsh_scripting_utilities" "$0" "$@" > /dev/null
    scripting_utilities_found=true
    break
  fi
done

# Error if all paths failed
if [[ -z "$scripting_utilities_found" ]]; then
  # echo "ERROR: Cannot find .zsh_scripting_utilities in any expected location:" >&2
  # for source_dir in "${source_dirs[@]}"; do
  #   [[ -n "$source_dir" ]] && echo "  - $source_dir/.zsh_scripting_utilities" >&2
  # done
  echo "ERROR: Cannot find .zsh_scripting_utilities in any expected location:\n${(F)source_dirs[@]}" >&2 && exit 1
fi
```

### Shared Directory Pattern

The `source_dirs` array can be reused for sourcing multiple files (e.g., `.zsh_debug_err`, `.zsh_debug_exit`):

```zsh
# Example: Source trap handler using same directory list
for source_dir in "${source_dirs[@]}"; do
  if [[ -n "$source_dir" && -f "$source_dir/.zsh_debug_err" ]]; then source "$source_dir/.zsh_debug_err"; break; fi
done


```

### Fallback Path Priority

The array tries paths in this order:

1. **`$HATCH_SOURCE_DIR/.zsh_scripting_utilities`** - When sourced in setup environment (preferred)
2. **`$HOME/.hatch/source/.zsh_scripting_utilities`** - When executed standalone after installation
3. **`"$HOME/.zsh_home/utilities/.zsh_scripting_utilities"`** - Legacy path for backward compatibility
4. **`$script_dir/../../assets/hatch_home/source/.zsh_scripting_utilities`** - During development/testing from repository

### Why This Pattern?

-   **Flexibility**: Works in multiple contexts (setup, standalone, development)
-   **Resilience**: Falls back through paths until one succeeds
-   **Clear errors**: Reports all attempted paths if all fail
-   **Zsh expansion**: Uses `${0:A:h}` instead of `dirname "$(realpath "$0")"`

### Path-Specific Overrides

Some script locations may have simpler sourcing requirements (e.g., scripts that only run in setup environment). Path-specific instruction files may override this pattern with location-appropriate alternatives.

---

## Variable Naming Conventions

All Zsh files must follow these naming and casing rules:

### Naming and Casing Rules

-   **Local variables** (including function-scoped and loop variables): Use `lower_snake` case
    ```zsh
    local file_path="/tmp/example"
    local current_user="admin"
    
    # Loop variables
    for item_name in "${items[@]}"; do
      local processed_count=0
    done
    ```

-   **Variables used only in same file**: Use `lower_snake` case
    ```zsh
    temp_dir="/tmp/workspace"
    processing_status="pending"
    ```

-   **Variables used across files**: Use `UPPER_SNAKE` case
    ```zsh
    HATCH_HOME_DIR="$HOME/.hatch"
    SCRIPT_BASENAME="$(basename "$0")"
    SOURCE_FILEPATH="$(realpath "$0")"
    ```

-   **Exported variables**: Always use `UPPER_SNAKE` case
    ```zsh
    export DATABASE_URL="postgres://..."
    export HATCH_LOG_LEVEL_MASK=info
    export SETUP_LOG_FILE="${logs_dir}/setup.log"
    ```

-   **zparseopts variables**: Follow prefix conventions with appropriate casing based on scope
    ```zsh
    # Function-local zparseopts variables (lower_snake with prefix)
    zparseopts -D -F -- \
      -help=flag_help \
      -output-file:=opt_output_file \
      -debug=flag_debug
    
    # Variables used across files (UPPER_SNAKE with prefix)
    FLAG_DEBUG=""
    OPT_OUTPUT_FILE=""
    ```
    - Flag-style arguments: Prefix with `flag_` or `FLAG_`
    - Key/value arguments: Prefix with `opt_` or `OPT_`

-   **Environment variables from external systems**: Preserve original casing
    ```zsh
    # System environment variables - keep as-is
    echo "$HOME"
    echo "$PATH"
    echo "$USER"
    ```

### Reserved Keywords

**CRITICAL**: Avoid naming variables or functions using Zsh reserved keywords, built-in functions, or special variables. These cause unexpected behavior and bugs that are difficult to debug.

❌ **Common problematic names**:
```zsh
# Reserved keywords
status       # Reserved keyword
commands     # Reserved keyword
options      # Reserved keyword
functions    # Reserved keyword

# Built-in/special variables (cause major issues)
path         # Zsh special variable (tied to PATH)
command      # Zsh built-in command/keyword

# Other built-ins to avoid
which        # Built-in command
type         # Built-in command
```

✅ **Safe alternatives**:
```zsh
# Instead of problematic names
exit_status      # Instead of: status
command_list     # Instead of: commands
option_values    # Instead of: options
function_names   # Instead of: functions

# Critical renames (path and command cause major bugs)
file_path        # Instead of: path
dir_path         # Instead of: path
command_string   # Instead of: command
command_name     # Instead of: command
```

**Why this matters:**
-   `path` is a special Zsh variable tied to the `PATH` environment variable - using it causes PATH corruption
-   `command` is a Zsh built-in that affects command resolution - using it breaks command execution
-   These bugs cause significant wasted debugging time
-   AI agents frequently make these mistakes

**Reference documentation:**
-   Consult `man zshbuiltins` for built-in commands and functions
-   Consult `man zshparam` for special parameters and variables
-   Consult `man zshoptions` for reserved option names
-   When in doubt, choose a more specific descriptive name

### Variable Declaration and `local` Qualifier

**CRITICAL**: The `local` qualifier must ONLY be used within functions. Using `local` in a script's root scope causes bugs and unexpected behavior.

#### Scope Rules

✅ **Good (correct `local` usage):**
```zsh
# In script root scope - no local qualifier
script_dir="${0:A:h}"
temp_file="/tmp/output.txt"

# Within function - use local qualifier
function process_file {
  local file_path="$1"
  local exit_code=0
  # function logic
}
```

❌ **Bad (`local` in root scope):**
```zsh
# DON'T DO THIS - causes bugs
local script_dir="${0:A:h}"  # local in root scope
local temp_file="/tmp/output.txt"  # local in root scope
```

**Why this matters:**
-   `local` restricts variable scope to functions only
-   Using `local` outside functions causes undefined behavior
-   AI agents frequently make this mistake, leading to wasted debugging time

#### Declaration and Initialization

**CRITICAL**: Always declare and initialize variables in a single compound statement. Separating declaration and initialization can cause unexpected output to stdout.

✅ **Good (compound statement):**
```zsh
local my_var=0
local file_path="/tmp/file.txt"
local result="$(some_command)"
```

❌ **Bad (separate declaration and initialization):**
```zsh
# Immediate initialization after declaration
local my_var
my_var=0  # Can leak to stdout

# Delayed initialization (even worse)
local file_path
# ... other code ...
file_path="/tmp/file.txt"  # Can leak to stdout
```

**Why this matters:**
-   Separate initialization (`my_var=0`) can write to stdout unexpectedly
-   Causes bugs where variable assignments appear in command output
-   Breaks pipes and variable captures
-   Single compound statements are atomic and predictable
-   The problem occurs whether initialization is immediate or delayed

#### Multiple Variable Declarations

When declaring multiple related variables, still use compound statements:

✅ **Good:**
```zsh
local var1="value1"
local var2="value2"
local var3="value3"
```

❌ **Bad:**
```zsh
local var1 var2 var3  # Don't declare multiple on one line
var1="value1"  # Can leak to stdout
var2="value2"
var3="value3"
```

### Examples

✅ **Good:**
```zsh
# Local variable
local file_path="/tmp/example"

# Variable used only in same file
current_user="admin"

# Exported variable
export DATABASE_URL="postgres://..."

# Variable used across files (sourced/exported)
CONFIG_DIR="/etc/myapp"
export HATCH_HOME_DIR="$HOME/.hatch"
```

❌ **Bad:**
```zsh
# Local variable should be lower_snake
local FilePath="/tmp/example"

# Exported variable should be UPPER_SNAKE
export database_url="postgres://..."

# Variable used across files should be UPPER_SNAKE
config_dir="/etc/myapp"

# Using reserved keyword
status="complete"  # DON'T DO THIS
```

---

## Function Syntax

Define functions using the `function name { ... }` syntax for clarity and easy searching:

```zsh
function my_function {
  local param1="$1"
  # function logic
}
```

**Why this syntax:**
-   Clearly distinguishes functions from commands
-   Easier to search for function definitions: `grep -r "^function "`
-   More readable and explicit
-   Consistent with Zsh best practices

❌ **Don't use:**
```zsh
my_function() {  # Avoid this syntax
  # ...
}
```

### Function Arguments: Named vs Positional

**STRONGLY PREFER**: Use `zparseopts` with named arguments instead of positional arguments in functions.

✅ **Good (named arguments with zparseopts):**
```zsh
function process_file {
  # Parse named arguments
  zparseopts -D -F -- \
    -file-path:=opt_file_path \
    -output-dir:=opt_output_dir \
    -verbose=flag_verbose
  
  # Extract values
  local file_path="${opt_file_path[2]}"
  local output_dir="${opt_output_dir[2]}"
  local verbose="${flag_verbose:-}"
  
  # Function logic
  [[ -n "$verbose" ]] && echo "Processing $file_path"
  # ...
}

# Call with named arguments
process_file --file-path "/path/to/file" --output-dir "/output" --verbose
```

❌ **Avoid (positional arguments):**
```zsh
function process_file {
  local file_path="$1"
  local output_dir="$2"
  local verbose="$3"
  
  # Function logic - unclear what each argument means
  # ...
}

# Call with positional arguments - hard to read
process_file "/path/to/file" "/output" "true"
```

**Why prefer named arguments:**
-   **Self-documenting**: Argument names make code intent clear
-   **Order-independent**: Arguments can be passed in any order
-   **Maintainable**: Adding new arguments doesn't break existing calls
-   **Type-safe**: Flags vs values are explicit
-   **Consistent**: Matches script-level argument parsing patterns

**When positional arguments are acceptable:**
-   Very simple functions with 1-2 obvious parameters
-   Internal helper functions with clear, single-purpose parameters
-   When function signature is stable and unlikely to change

**Example of acceptable positional use:**
```zsh
function get_basename {
  local file_path="$1"
  echo "${file_path:t}"
}
```

---

## Zsh Expansion (Required)

**CRITICAL RULE**: ALWAYS use Zsh's native expansion capabilities. This applies to ALL operations where Zsh expansion is available as an alternative to external commands or other methods.

**Why**: Zsh expansions are faster (no subprocess spawning), more reliable (no PATH dependencies), and more maintainable (pure Zsh syntax).

**This is NOT optional** - any time you can use a Zsh expansion instead of:
- External commands (`dirname`, `basename`, `realpath`, `tr`, `awk`, `sed`)
- Multiple command pipelines
- Subshell operations
- Array/string manipulation utilities

You **MUST** use the Zsh expansion.

### Path Manipulation (ALWAYS Use Zsh Expansion)

**REQUIRED**: Use Zsh parameter expansion modifiers. Never use `dirname`, `basename`, `realpath` or similar external commands:

```zsh
# Path manipulation
${var:h}     # head (dirname)           /a/b/c.txt → /a/b
${var:t}     # tail (basename)          /a/b/c.txt → c.txt
${var:r}     # root (remove extension)  /a/b/c.txt → /a/b/c
${var:e}     # extension only           /a/b/c.txt → txt

# Path resolution
${var:A}     # Absolute + resolve symlinks
${var:a}     # Absolute (no symlink resolve)
${var:P}     # Physical (resolve symlinks, like realpath)

# Chaining modifiers
${var:A:h}   # Absolute dir of file     ./script.sh → /full/path
${var:t:r}   # Basename without ext     /a/b/c.txt → c
${file:A:h:h}  # Go up two directories from file's location
```

**Examples:**

✅ **Good (Zsh expansion):**
```zsh
script_dir="${0:A:h}"
script_name="${0:t}"
file_without_ext="${config_file:t:r}"
```

❌ **Bad (external commands):**
```zsh
script_dir="$(dirname "$(realpath "$0")")"
script_name="$(basename "$0")"
file_without_ext="$(basename "$config_file" .txt)"
```

### Case Conversion (ALWAYS Use Zsh Expansion)

**REQUIRED**: Use Zsh expansion for case conversion. Never use `tr`, `awk`, `sed` or similar external commands:

```zsh
# Upper/lowercase
${var:u}     # uppercase first char
${var:l}     # lowercase first char
${var:U}     # UPPERCASE ALL
${var:L}     # lowercase all
```

**Examples:**

✅ **Good:**
```zsh
upper_name="${name:U}"
lower_name="${name:L}"
```

❌ **Bad:**
```zsh
upper_name="$(echo "$name" | tr '[:lower:]' '[:upper:]')"
lower_name="$(echo "$name" | tr '[:upper:]' '[:lower:]')"
```

### Array and Multiline Conversions (ALWAYS Use Zsh Expansion)

**REQUIRED**: Use Zsh expansion flags `(f)` and `(F)` for array/string conversions. Never use loops, `awk`, `sed`, or other external tools.

**The (f) and (F) flags:**
- **(f)** - Split on newlines (converts multiline string → array)
- **(F)** - Join with newlines (converts array → multiline string)

**Basic patterns:**

```zsh
# Convert multiline string to array using (f)
array=(${(f)"${my_multiline_var}"})

# Convert array to multiline string using (F)
multiline_string="${(F)array[@]}"
```

**Complete example:**

```zsh
# Parse multiline command output into array
output="line1
line2
line3"
lines=(${(f)"${output}"})

# Now you can work with the array
echo "Line count: ${#lines[@]}"
echo "First line: ${lines[1]}"

# Convert array back to multiline string
echo "${(F)lines[@]}"
```

**Real-world use cases:**

✅ **Good (using (f) to parse command output):**
```zsh
# Parse git status output into array
git_status_output="$(git status --porcelain)"
changed_files=(${(f)"${git_status_output}"})

# Process each file
for file in "${changed_files[@]}"; do
  echo "Processing: $file"
done
```

✅ **Good (using (F) to build multiline output):**
```zsh
# Build error message from array
error_lines=(
  "Configuration error:"
  "  - Missing required file: config.yml"
  "  - Invalid port number: abc"
  "  - Database connection failed"
)

# Output as multiline string
slog_error_se "${(F)error_lines[@]}"
```

❌ **Bad (using loops instead of (f)):**
```zsh
# DON'T DO THIS - use (f) instead
lines=()
while IFS= read -r line; do
  lines+=("$line")
done <<< "$output"
```

❌ **Bad (using external tools instead of (F)):**
```zsh
# DON'T DO THIS - use (F) instead
multiline_string="$(printf '%s\n' "${array[@]}")"
```

**Why (f) and (F) matter:**
-   **Performance**: No external processes, no loops
-   **Reliability**: Built into Zsh, always available
-   **Clarity**: Intent is immediately obvious
-   **Consistency**: Matches other Zsh expansion patterns

**Advanced: Combining with other operations:**

```zsh
# Split, filter empty lines, and trim whitespace in one expression
non_empty_lines=(${(f)"${output}"})
non_empty_lines=("${(@)non_empty_lines:#}")  # Remove empty elements

# Join array with custom separator (not just newlines)
comma_separated="${(j:,:)array[@]}"  # Use (j:,:) for commas
```

### Extracting zparseopts Values (ALWAYS Use Zsh Expansion)

**REQUIRED**: Use Zsh array filtering to extract values from `zparseopts` arrays. Never use loops, `grep`, `awk`, or external parsing:

```zsh
zparseopts -E -- -label+:=opt_labels_array

# Remove all flag occurrences, leaving only values
opt_label_values=(${opt_labels_array:#--label})

# Count occurrences of the flag
opt_labels_count=${#${(M)opt_labels_array:#--label}}
```

---

## Error Handling and Logging Pattern

**DEFAULT**: All Zsh scripts should use `slog_*` functions (from `.zsh_scripting_utilities`) for logging. Path-specific instruction files may override this to use alternative logging functions (e.g., `log_*` in setup scripts).

### Error Handling Context

All scripts in this repository run with error handling enabled (via shebang or parent shell):
-   `set -e` / `-e`: Exit immediately if a command exits with a non-zero status
-   `set -u` / `-u`: Treat unset variables as an error
-   `set -o pipefail` / `-o pipefail`: Pipeline exits with status of last failing command

**Therefore**: Always add error handling around commands that can fail using the patterns below.

### Safe Variable Checking

**CRITICAL**: When checking if a variable is unset or empty, always use the `:-` expansion to provide a default value. This prevents errors when `set -u` is active.

✅ **Good (safe):**
```zsh
if [[ -z "${some_file:-}" ]]; then
  echo "Variable is unset or empty"
fi
```

❌ **Bad (unsafe with set -u):**
```zsh
if [[ -z "$some_file" ]]; then  # Will error if some_file is unset
  echo "Variable is unset or empty"
fi
```

### The Three-Step Pattern

Every operation that can succeed or fail must follow this pattern:

1.  **Intent**: Log what will be done (before the operation)
2.  **Operation**: Perform the operation with error handling
3.  **Result**: Log success or failure (after the operation)

### Error Message Format

**CRITICAL**: Always format error and warning messages with the exit code in brackets at the front:

```zsh
# Correct format
slog_error_se "[$exit_code] Failed to install package"
slog_warning_se "[$exit_code] Failed to set preference"

# Wrong formats - don't use these
slog_error_se "Failed to install package (exit code: $exit_code)"  # ❌
slog_error_se "Error $exit_code: Failed to install package"        # ❌
slog_error_se "Failed to install package - exit $exit_code"        # ❌
```

**Why this format:**
-   Consistent parsing in logs and monitoring tools
-   Exit code is immediately visible
-   Easy to grep/search: `grep '\[42\]' logs/*.log`
-   Follows standard error message conventions

### Pattern 1: Fatal Errors (Critical Operations)

Use the **dangling `|| { ... exit }` pattern** when failure should stop script execution:

```zsh
# 1. Log intent
slog_info_se "Installing package X..."

# 2. Perform operation with error handling
some_command || {
  exit_code=$?
  slog_error_se "[$exit_code] Failed to install package X"
  exit $exit_code
}

# 3. Log success (only reached if command succeeded)
slog_success_se "Successfully installed package X"
```

**Key Points**:
-   Use `|| { slog_error_se; exit }` to keep success path clean
-   Success message follows error handler (only reached if command succeeds)
-   Capture `$?` immediately to preserve exit status
-   Exit with captured exit code (or unique code for specific failures)
-   **Format error messages as**: `[$exit_code] <description>` (exit code in brackets at front)

**Use for**:
-   Installing required packages
-   Creating critical directories
-   Configuring essential system settings
-   Downloading required resources

**Alternative syntax for explicit validation:**
```zsh
# Check condition first, then handle error
if ! some_command; then
  exit_code=$?
  slog_error_se "[$exit_code] Command failed"
  exit $exit_code
fi

slog_success_se "Command succeeded"
```

### Pattern 2: Non-Fatal Warnings (Best-Effort Operations)

Use the **if/then/else/fi pattern** when failure should be logged but script continues:

```zsh
# 1. Log intent
slog_info_se "Configuring optional preference..."

# 2. Perform operation - success logs in if branch, warning logs in else branch
if defaults write com.apple.dock tilesize -int 52; then
  slog_success_se "Set dock tile size"
else
  exit_code=$?
  slog_warning_se "[$exit_code] Failed to set dock tile size"
fi
# Script continues regardless of success/failure
```

**CRITICAL**: Success logs in the `if` branch, warning logs in the `else` branch.

**Key Points**:
-   Use `if/then/else/fi` to log both success and failure cases
-   Success message in `if` branch, warning in `else` branch
-   Capture `$?` in else branch to preserve exit status
-   Script execution continues after else branch
-   **Format warning messages as**: `[$exit_code] <description>` (exit code in brackets at front)

**Use for**:
-   User preferences (Dock size, Finder settings)
-   Optional configurations (Safari debug menu)
-   Cosmetic settings (desktop wallpaper, dark mode)
-   Creating convenience symlinks

### ❌ Common Mistake

**DON'T** use `|| { }` for non-fatal operations (doesn't log success):

```zsh
# BAD: Using || with braces for non-fatal operations
defaults write com.apple.dock tilesize -int 52 || {
  exit_code=$?
  slog_warning_se "[$exit_code] Failed to set dock tile size"
}
# This doesn't log success - violates "log success and failure" requirement
```

### Quick Decision Guide

**When to use which pattern:**

| Pattern | Use When | Exit on Failure? |
|---------|----------|------------------|
| `\|\| { exit }` | Operation is **critical** to script success | Yes |
| `if/else` | Operation is **optional** or best-effort | No |

### Path-Specific Overrides

Some directories use different logging functions:
-   Setup scripts (`scripts/**/*.zsh`): May use `log_*` functions instead of `slog_*`
-   Path-specific instruction files document these overrides

---

## Script Argument Parsing

### Use zparseopts

Script arguments should be handled using `zparseopts` where possible, or where conversion is easy. If converting requires a significant refactor, retain the current approach.

**Key Conventions:**
-   **For new code**: Always call `zparseopts` with at least the `-D -F` arguments
-   **For existing code**: When converting to `zparseopts`, omitting `-D`, `-E`, or any capital letter is tolerable, but prefer matching the new standard
-   **Argument definition order**: Capital letter arguments should be listed first and separated from others using `--`
-   **Multi-line format**: Define arguments one per line using the trailing `\` syntax
-   **Long-form names**: Always include a long-form name (e.g., `--help`) for arguments
    -   **Exception**: `{d,-debug}+` uses short-form `-d` to enable quick debug level changes (`-d`, `-dd`, `-ddd`)
-   **Standard arguments**: **All scripts must include `-help=flag_help` and `{d,-debug}+=flag_debug` in the main zparseopts block** (additional arguments are script-specific)
-   **Variable naming**:
    -   Flag-style arguments (e.g., `--help`): Prefix with `flag_` or `FLAG_` based on scope
    -   Key/value arguments (e.g., `--mode create` or `--mode=create`): Prefix with `opt_` or `OPT_`
-   **Associative arrays**: Consider using the `-A <kv_array>` syntax if it does not conflict with other argument styles
-   **Avoid flag arrays**: Avoid using the `-a <flag_array>` syntax as it is mutually exclusive with the flag variable approach


**Example for existing code (audit or conversion to zparseopts):**
```zsh
zparseopts -D -- \
  -help=flag_help \
  {d,-debug}+=flag_debug \
  # other script relevant args
```

**Example for new code:**
```zsh
zparseopts -D -- \
  -help=flag_help \
  {d,-debug}+=flag_debug \
  # other script relevant args
```

### Optional: Trap Debugging Support

**When to use**: Scripts that need advanced debugging capabilities with ERR and EXIT trap handlers.

**Usage**: Add this zparseopts block AFTER the main script arguments block. To enable: prompt AI with "implement trap args" or "add trap debugging support".

**Implementation Pattern:**

```zsh
# Stage 1: Main script arguments (required)
zparseopts -D -- \
  -help=flag_help \
  {d,-debug}+=flag_debug \
  # ... other script relevant arguments

if [[ -n "${flag_help:-}" ]]; then
  print_usage
  exit 0
fi

# Stage 2: Trap debugging arguments (optional - omit this entire block if not needed)
zparseopts -D -- \
  {-trap-err,-debug-err}=flag_debug_err \
  {-trap-exit,-debug-exit}=flag_debug_exit

flag_debug_level=${#flag_debug[@]}

if [[ -n "${flag_debug_err:-}" || $flag_debug_level -ge 2 ]]; then 
  for source_dir in "${source_dirs[@]}"; do
    if [[ -n "$source_dir" && -f "$source_dir/.zsh_debug_err" ]]; then source "$source_dir/.zsh_debug_err"; break; fi
  done
fi

if [[ -n "${flag_debug_exit:-}" || $flag_debug_level -ge 3 ]]; then 
  for source_dir in "${source_dirs[@]}"; do
    if [[ -n "$source_dir" && -f "$source_dir/.zsh_debug_exit" ]]; then source "$source_dir/.zsh_debug_exit"; break; fi
  done
fi
```

**Key Points:**
-   **Stage 1**: Always include main script arguments with `{d,-debug}+=flag_debug`
-   **Stage 2**: Only include if trap debugging is needed (completely optional)
-   **Flags**: `-D --` removes processed args, no `-E` or `-F` (allows flexible parsing)
-   **Debug Levels**:
    -   Level 1: Basic debug (single `-d` or `--debug`)
    -   Level 2: ERR trap enabled (`-dd` or `--trap-err`)
    -   Level 3: EXIT trap enabled (`-ddd` or `--trap-exit`)
-   **Shared Directories**: Uses `source_dirs` array defined in "Source Scripting Utilities" section
-   **No Error Handling**: Trap files are sourced silently; the trap handlers themselves verify proper setup

### Long-Form Arguments

Always prefer long-form arguments for clarity:

```zsh
./my_script.zsh --verbose --output-file /path/to/file
```

---

## Help and Usage Functions

**CRITICAL**: All scripts that accept command-line arguments must include a `print_usage` function bound to the `--help` argument.

### Standard Structure

```zsh
function print_usage {
  cat << 'EOF'
SYNOPSIS
    script_name.zsh [OPTIONS]

OPTIONS
    --required-arg <value>
                        Description of required argument
    --optional-arg <value>
                        Description of optional argument (optional)

META OPTIONS
    --help              Display this help message and exit
    --debug             Enable debug logging

ENVIRONMENT
    REQUIRED_VAR        Description of required environment variable
    OPTIONAL_VAR        Description of optional environment variable (optional)

EXIT VALUES
    0                   Success
    1                   General error
    40-49               Validation/verification failures
    50-59               Configuration errors

STDOUT
    Description of what gets written to stdout on success

STDERR
    Debug logs and context information (when --debug is enabled)

EXAMPLES
EOF
  echo_pretty "    # Example command" --default
  echo_pretty "    " --code "./script_name.zsh --required-arg value" --default
  echo ""
  echo_pretty "    # Example with optional flags" --default
  echo_pretty "    " --code "./script_name.zsh --required-arg value --debug" --default

  cat << 'EOF'

REFERENCES
EOF
  echo_pretty "    SwiftArgumentParser: " --url "https://apple.github.io/swift-argument-parser/" --default
}
```

### Formatting Rules

1.  **Section Headers**: Use UPPERCASE without colons
    -   ✅ `SYNOPSIS`
    -   ✅ `OPTIONS`
    -   ✅ `ENVIRONMENT`
    -   ❌ `Synopsis:` (lowercase and colon)
    -   ❌ `Usage:` (use SYNOPSIS instead)

2.  **Section Order**:
    1.  `SYNOPSIS` - Brief command syntax
    2.  `OPTIONS` - Main arguments
    3.  `META OPTIONS` / `DEV OPTIONS` - Secondary arguments
    4.  `ENVIRONMENT` / `ENV VARS` - Environment variables
    5.  `EXIT VALUES` / `RETURN VALUES` - Exit codes
    6.  `STDOUT` - What gets written to stdout
    7.  `STDERR` - What gets written to stderr
    8.  `EXAMPLES` - Example usage
    9.  `REFERENCES` - Links to documentation

3.  **Argument Organization**: Within each section, list:
    -   Mandatory arguments first
    -   Optional arguments last (marked with "(optional)")

4.  **Decorators in Examples**:
    -   Use `--code` and `--default` for command examples
    -   Use `--url` and `--default` for URLs

5.  **SwiftArgumentParser Style**: Follow conventions from Swift's ArgumentParser for synopsis formatting:
    -   Reference: `swift package --help`
    -   Web docs: https://apple.github.io/swift-argument-parser/

### Binding to --help

```zsh
# Argument parsing
zparseopts -D -F -- \
  -help=flag_help \
  -other-arg:=opt_other_arg

# Display help if requested
if [[ -n "${flag_help:-}" ]]; then
  print_usage
  exit 0
fi
```

---

## Context Logging

### Match Output Destination

When printing information to terminal, match the adjacent output destination:

✅ **Good:**
```zsh
slog_warning_se "Error occurred"
slog_se ""  # Empty line also to stderr (matching context)
slog_warning_se "Additional context"
```

❌ **Bad:**
```zsh
slog_warning_se "Error occurred"
echo ""  # Writes to stdout, breaks context
slog_warning_se "Additional context"
```

### Use Available Logging Functions

Don't use `echo ""` for empty lines when `slog_se ""` or `slog ""` are available:

✅ **Good:**
```zsh
slog_info_se "Processing file..."
slog_se ""  # Empty line using available function
slog_info_se "Next step..."
```

❌ **Bad:**
```zsh
slog_info_se "Processing file..."
echo ""  # Don't use echo when slog is available
slog_info_se "Next step..."
```

### Minimize Write Commands

**CRITICAL**: Use minimal write commands (`slog_*`, `echo_pretty`, `echo`, `printf`) within the same context block. Leverage multiline strings instead.

**Benefits**:
-   Fewer function calls = better performance
-   Single atomic write = better output consistency
-   Easier to read and maintain

✅ **Good (multiline string):**
```zsh
slog_se "Will install software update"
if echo "$update_output" | grep -q "Failed to authenticate"; then
  slog_warning_se "Install software update failed.
Attempting interactive authentication...
You will be prompted to enter the password for " --code "$admin_username" --default " multiple times during download and installation
"
  # more code ...
fi
```

❌ **Bad (multiple calls):**
```zsh
slog_se "Will install software update"
if echo "$update_output" | grep -q "Failed to authenticate"; then
  slog_warning_se "Install software update failed."
  slog_warning_se "Attempting interactive authentication..."
  slog_warning_se "You will be prompted to enter the password for " --code "$admin_username" --default " multiple times during download and installation"
  # more code ...
fi
```

**Multiline Syntax Options**:
-   Heredoc: `cat << 'EOF'`
-   Trailing backslash: `"line1 \␤line2"`
-   Direct newlines in quotes: `"line1␤line2"`

### Decorator Requirements

**CRITICAL**: Always use appropriate decorators when logging specific types of content with `slog_*` functions:

1.  **Commands**: Always decorate with `--code` and `--default`
    ```zsh
    slog_info_se "executing: " --code "gh issue create --title 'Example'" --default
    slog_success_se "ran command: " --code "brew install package" --default
    ```

2.  **File paths and URLs**: Always decorate with `--url` and `--default`
    ```zsh
    slog_success_se "created file: " --url "$file_path" --default
    slog_info_se "visit: " --url "https://github.com/repo/issues/123" --default
    slog_error_se "failed to read: " --url "$config_file" --default
    ```

3.  **Variable names and identifiers**: Always decorate with `--code` and `--default`
    ```zsh
    slog_info_se "using account: " --code "$username" --default
    slog_debug_se "value of flag: " --code "$flag_debug" --default
    ```

**Why decorators matter**:
-   Improves readability in terminal output
-   Provides visual distinction between message and data
-   Consistent formatting across all scripts
-   Makes logs easier to parse and search

---

## Recommendations

### Pager-Aware Command Execution

**CRITICAL for AI Agents**: Many commands output to a pager (like `less`) instead of stdout, which can cause scripts or AI agents to hang indefinitely waiting for user interaction.

**Common commands that use pagers:**
-   `gh` subcommands (e.g., `gh repo view`, `gh issue view`, `gh pr view`)
-   `git diff`, `git log` (without `--no-pager`)
-   `man` pages
-   `systemctl status`
-   Any command configured with `PAGER` environment variable

**Solution**: Pipe output to `cat` to bypass the pager and write directly to stdout:

✅ **Good (bypasses pager):**
```zsh
gh repo view --json owner --jq '.owner.login' | cat
git --no-pager diff
git --no-pager log --oneline
```

❌ **Bad (opens pager, blocks script):**
```zsh
gh repo view --json owner --jq '.owner.login'  # Opens in less
git diff  # Opens in pager
```

**Alternative approaches:**
-   Use `--no-pager` flag when available: `git --no-pager log`
-   Set environment variable: `GH_PAGER=cat gh repo view`
-   Disable pager globally (not recommended): `export PAGER=cat`

**When to use `| cat`:**
-   Running commands in automated scripts
-   When output needs to be captured in a variable
-   When piping to another command (like `jq`, `grep`, `awk`)
-   In any non-interactive context

### Array Iteration Patterns

**FIRST PRIORITY**: Avoid loops entirely when Zsh expansion can accomplish the task. Only use loops when expansion is insufficient.

**When loops are necessary**, always prefer C-style loops with index counters over `for item in array` syntax.

#### Prefer Zsh Expansion Over Loops

✅ **Good (no loop needed):**
```zsh
# Add prefix to each array element
prefixed_items=("${(@)items/#/* }")

# Filter array elements
non_empty=(${items:#})

# Transform array elements
uppercase_items=("${(@U)items}")
```

❌ **Bad (unnecessary loop):**
```zsh
# DON'T DO THIS - use expansion instead
prefixed_items=()
for item in "${items[@]}"; do
  prefixed_items+=("* $item")
done
```

#### C-Style Loops When Iteration is Necessary

When loops cannot be avoided, use C-style loops with index counters:

✅ **Good (C-style loop with index):**
```zsh
# Log array count before iteration
slog_info_se "Processing ${#lines[@]} lines"

# C-style loop with index - enables logging with line numbers
for ((i=1; i<=${#lines[@]}; i++)); do
  line="${lines[$i]:-}"
  
  # Skip empty elements
  if [[ -z "$line" ]]; then continue; fi
  
  # Index available for logging/debugging
  slog_debug_se "  lines[$i]: $line"
  
  # Process line
  process_line "$line"
done
```

❌ **Avoid (no index available):**
```zsh
# Bad - no index for logging or debugging
for line in "${lines[@]}"; do
  slog_debug_se "  $line"  # Can't show which line number
  process_line "$line"
done
```

**Why prefer C-style loops with indices:**
-   **Debugging**: Index shows exact position in array
-   **Logging**: Can display "processing item 5 of 10"
-   **Error handling**: Can report which element failed
-   **Conditional logic**: Easy to skip/process based on position
-   **Progress tracking**: Can calculate percentage complete

**Example with progress logging:**
```zsh
total=${#files[@]}
slog_info_se "Processing $total files"

for ((i=1; i<=total; i++)); do
  file="${files[$i]:-}"
  if [[ -z "$file" ]]; then continue; fi
  
  slog_info_se "[$i/$total] Processing: $file"
  process_file "$file"
done

slog_success_se "Completed processing $total files"
```

**When `for item in array` is acceptable:**
-   Very simple loops with no logging/debugging needs
-   No need to track position or progress
-   Working with command output directly: `for file in *.txt; do ...`

### Indentation and Whitespace

**CRITICAL**: Avoid tab characters in Zsh scripts. Always use spaces for indentation.

**Standard indentation**: Use **2 spaces** per indentation level.

✅ **Good (spaces):**
```zsh
function process_data {
  local input="$1"
  
  if [[ -n "$input" ]]; then
    for item in "${items[@]}"; do
      echo "Processing: $item"
    done
  fi
}
```

❌ **Bad (tabs):**
```zsh
function process_data {
→ local input="$1"
→ 
→ if [[ -n "$input" ]]; then
→ → for item in "${items[@]}"; do
→ → → echo "Processing: $item"
→ → done
→ fi
}
```

**Why avoid tabs:**
-   Tab rendering varies across editors and contexts
-   Mixing tabs and spaces causes alignment issues
-   Spaces provide consistent visual appearance
-   Better compatibility with linters and formatters

**Rare exception**: Heredocs may require tabs for specific formatting, but even these can usually be done with spaces:

```zsh
# Prefer spaces even in heredocs
cat << 'EOF'
  Line with 2-space indent
    Line with 4-space indent
EOF
```

### Echo with jq

When using `echo` and `jq` together:

1.  **Use `echo -n`** to exclude trailing newline (increases compatibility):
    ```zsh
    echo -n "$json_data" | jq '.field'
    ```

2.  **Consider `echo -E`** to keep escape sequences literal (prevents expansion):
    ```zsh
    # Without -E: "A\n\tB" expands to multiline with tab
    # With -E: "A\n\tB" stays as literal string
    echo -E "A\n\tB" | jq -R .
    ```

---

## Summary Checklist

When writing or reviewing Zsh scripts, verify:

-   [ ] Shellcheck directives present after shebang
-   [ ] Variables follow naming conventions (lower_snake vs UPPER_SNAKE)
-   [ ] No reserved keywords used as variable/function names (`path`, `command`, `status`, etc.)
-   [ ] `local` qualifier only used within functions (never in root scope)
-   [ ] Variables declared and initialized in compound statements
-   [ ] Functions use `function name { }` syntax
-   [ ] Functions prefer named arguments (zparseopts) over positional parameters
-   [ ] Indentation uses spaces (2 spaces per level), not tabs
-   [ ] Zsh expansions preferred over external commands (`${var:h}` not `dirname`)
-   [ ] Array/string conversions use `(f)` and `(F)` flags (not loops or external tools)
-   [ ] Loops avoided when Zsh expansion suffices; C-style loops with indices when needed
-   [ ] Safe variable checking with `:-` expansion
-   [ ] Shared `source_dirs` array defined for sourcing utilities and trap handlers
-   [ ] zparseopts used for argument parsing with `-D --` flags
-   [ ] Trap debugging arguments added if needed (optional)
-   [ ] `print_usage` function present and bound to `--help`
-   [ ] Help formatting follows SYNOPSIS/OPTIONS/ENVIRONMENT structure
-   [ ] Context logging minimizes write commands (use multiline strings)
-   [ ] Output destination consistency (stderr with stderr, stdout with stdout)
-   [ ] Decorators used correctly (--code for commands/vars, --url for paths/URLs)
-   [ ] Commands that use pagers are piped to `cat` or use `--no-pager`
-   [ ] `echo -n` used with `jq` pipelines
