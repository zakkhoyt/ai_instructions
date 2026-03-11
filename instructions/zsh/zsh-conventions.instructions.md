---
applyTo: "**/*.zsh"
---

# Universal Zsh Scripting Conventions

**IMPORTANT**: These conventions apply to **ALL** `.zsh` files in this repository, regardless of location or purpose. Path-specific instruction files inherit and extend these base rules.

---

## ⚡ Quick Compliance Checklist

When writing or modifying **ANY** Zsh script in this repository, ensure:

- ✅ **Zsh expansion used** - Parameter expansion, array manipulation (see the "Zsh Expansion" section)
  - Use `${var:-default}`, `${#array[@]}`, `${(f)"string"}`, `${(F)array[@]}`, `${array:#pattern}`, etc.
  - Use `(f)` to split strings into arrays, `(F)` to join arrays into strings
  - Avoid external commands when Zsh builtins suffice (`dirname`, `basename`, `wc`, etc.)
- ✅ **Shellcheck directives present** - Standard 3 directives after shebang
- ✅ **Header comments complete** - "About this Script" section with description
- ✅ **Source boilerplate correctly** - Source `.zsh_boilerplate` at script start (see the "Source Zsh Boilerplate" section)
- ✅ **Do not re-parse common flags** - `.zsh_boilerplate` already handles common/dev flags (see the "Script Argument Parsing" section)
  - Common flags handled by boilerplate include `--help`, `-d/--debug`, `--dry-run`, `--verbose`, `--trap-err`, `--trap-exit`
  - Script code should parse only script-specific arguments unless extending shared parser behavior
- ✅ **Logging functions used** - `slog_*` functions (or `log_*` for setup scripts)
- ✅ **Function syntax correct** - Use `function name { }` (not `name() { }`)
- ✅ **Functions use named arguments** - Prefer `zparseopts` over positional parameters (see the "Function Arguments" guidance)
- ✅ **Variable naming follows conventions** - `lower_snake` for local/file-scoped, `UPPER_SNAKE` for cross-file/exported
- ✅ **Variables explicitly declared** - Declare variables before use; prefer readonly declarations where possible (see "Variable Declaration and `local` Qualifier")
- ✅ **Type-specific declarations used** - Use `typeset` flags according to context (not only `-r`, `-a`, `-A`)
- ✅ **No reserved keywords** - Avoid `path`, `command`, `status`, `functions`, etc. (see the reserved keyword list below)

**→ If unsure about any item, refer to the detailed sections below.**

---

## Short Option Commentary Rule

We always prefer long-form options. When a command (including `zparseopts`, builtins like `typeset`/`autoload`, or external tools) only exposes short flags, annotate every invocation so future edits know what each flag does.

1. Add a block of `#` comments immediately above the command.
2. Document **each** short flag on its own line, sorted lexicographically, in the format `# -X: human-readable description`.
3. When practical, add a `See:` line that points to the man page or `--help` section explaining the options.
4. Apply this rule everywhere—production scripts, helper functions, examples, and instruction files themselves.

Example:

```zsh
# -U: do not inherit caller options
# -z: treat file as zsh-style function
# See: `man zshbuiltins # s/autoload`
autoload -Uz z2k_dbg
```


## Table of Contents

<!-- markdown-link-check-disable -->
1. [Shellcheck Directives](#shellcheck-directives)
2. [Header Comments](#header-comments)
3. [Source Zsh Boilerplate](#source-zsh-boilerplate)
4. [Script Argument Parsing](#script-argument-parsing)
5. [Help and Usage Functions](#help-and-usage-functions)
6. [Variable Naming Conventions](#variable-naming-conventions)
7. [Function Syntax](#function-syntax)
8. [Zsh Expansion (Required)](#zsh-expansion-required)
9. [Output and Logging](#output-and-logging)
10. [Step Pattern: Structured Operation Logging](#step-pattern-structured-operation-logging)
11. [Context Logging](#context-logging)
12. [Recommendations](#recommendations)
<!-- markdown-link-check-enable -->

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

- **Setup scripts** (`scripts/**/setup*.zsh`): Must include comprehensive headers documenting all operations, requirements, and warnings. See `setup-scripts.instructions.md` for detailed requirements.
- **Utility scripts** (`scripts/utilities/**/*.zsh`): Should document whether the script can be executed standalone or must be sourced.
- **Executable scripts** (`assets/hatch_home/scripts/**/*.zsh`): Should include usage examples and any environment dependencies.

---

## Source Zsh Boilerplate

**CRITICAL**: All Zsh scripts must source `.zsh_boilerplate` near the top of the file. The boilerplate is the canonical bootstrap for:
- common argument parsing (`--help`, `-d/--debug`, `--dry-run`, `--verbose`, trap/debug flags)
- loading shared utility libraries (`slog_*`, scripting/ui/git/jira/homebrew/swift/xcode/file helpers)
- establishing common environment variables used by utility functions

### Required Pattern

Immediately after header comments, initialize required variables then source `.zsh_boilerplate`:

```zsh
#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296
# shellcheck disable=SC1091
#
# ---- ---- ----  About this Script  ---- ---- ----
# [Your header comments]

# ---- ---- ----     Source Utilities     ---- ---- ----

# Initialize variables required by boilerplate (must be done before sourcing)
export IS_DEBUG=""
export IS_VERBOSE=""
export IS_DRY_RUN=""
export IS_UTILS_DEBUG=""

source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
```

**CRITICAL**: The IS_* variables MUST be initialized before sourcing boilerplate. This is because:
1. Boilerplate sources `.zsh_zparseopts` which uses `slog_var_se_d` calls
2. Those logging functions check `IS_DEBUG` and `IS_VERBOSE` WITHOUT the `:-` guard
3. With `-euo pipefail`, accessing unset variables causes script exit
4. Initializing to empty strings prevents this while still allowing boilerplate to set proper values

### What You Get From Boilerplate

After sourcing `.zsh_boilerplate`, scripts can assume these are already available:

- **Common/dev flags parsed** via `.zsh_zparseopts`
  - supports categories such as `meta`, `dev`, and optional parser modes
  - sets or refines variables such as `flag_help`, `flag_debug`, `flag_dry_run`, debug-level behavior
  - enables trap utilities via `--trap-err` / `--trap-exit` and debug levels
- **Logging functions** via `.zsh_logging_utilities`
  - `slog_*`, `slog_step_*`, `slog_var*`, `slog_array*`, callstack/source-location helpers
- **Utility library families** via `.zsh_scripting_utilities` and transitively sourced libs
  - jira/git/github/homebrew/scripting core/scripting functions/ui/swift/xcode/file utilities

### Common Environment/State Available

Boilerplate and its sourced libraries establish commonly used state such as:
- debug/test/verbosity flags (`IS_DEBUG`, `IS_VERBOSE`, `IS_DRY_RUN`, related `FLAG_*` values)
- script metadata and formatting helpers used by logging utilities
- loaded utility functions expected by instruction examples (`slog_se`, `slog_step_se`, etc.)

### Rules for Script Authors

- **Do not duplicate** the old `source_dirs` loop in new scripts.
- **Do not re-implement** common/dev parsing blocks already handled by `.zsh_boilerplate`.
- Parse only script-specific options in the script body (or in dedicated parser functions).
- If a script requires custom bootstrap behavior, document the exception in its header.

---

## Variable Naming Conventions

All Zsh files must follow these naming and casing rules:

### Naming and Casing Rules

- **Local variables** (including function-scoped and loop variables): Use `lower_snake` case
    ```zsh
    function process_items {
      local -r file_path="/tmp/example"
      local -r current_user="admin"

      # Loop variables
      for item_name in "${items[@]}"; do
        local processed_count=0
      done
    }
    ```

- **Variables used only in same file**: Use `lower_snake` case
    ```zsh
    typeset -r temp_dir="/tmp/workspace"
    typeset -r processing_status="pending"
    ```

- **Variables used across files**: Use `UPPER_SNAKE` case
    ```zsh
    typeset -r HATCH_HOME_DIR="$HOME/.hatch"
    typeset -r SCRIPT_BASENAME="${0:t}"
    typeset -r SOURCE_FILEPATH="${0:A}"
    ```

- **Exported variables**: Always use `UPPER_SNAKE` case
    ```zsh
    export DATABASE_URL="postgres://..."
    export HATCH_LOG_LEVEL_MASK=info
    export SETUP_LOG_FILE="${logs_dir}/setup.log"
    ```

- **zparseopts variables**: Follow prefix conventions with appropriate casing based on scope
    ```zsh
    # Function-local zparseopts variables (lower_snake with prefix)
    zparseopts -D -F -- \
      -help=flag_help \
      -output-file:=opt_output_file \
      -debug=flag_debug
    
    # Variables used across files (UPPER_SNAKE with prefix)
    # Mutable on purpose: parser/shared state may be reassigned across parse phases.
    typeset FLAG_DEBUG=""
    typeset OPT_OUTPUT_FILE=""
    ```
    - Flag-style arguments: Prefix with `flag_` or `FLAG_`
    - Key/value arguments: Prefix with `opt_` or `OPT_`

- **Environment variables from external systems**: Preserve original casing
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
- `path` is a special Zsh variable tied to the `PATH` environment variable - using it causes PATH corruption
- `command` is a Zsh built-in that affects command resolution - using it breaks command execution
- These bugs cause significant wasted debugging time
- AI agents frequently make these mistakes

**Reference documentation:**
- Consult `man zshbuiltins` for built-in commands and functions
- Consult `man zshparam` for special parameters and variables
- Consult `man zshoptions` for reserved option names
- When in doubt, choose a more specific descriptive name

### Variable Declaration and `local` Qualifier

**CRITICAL**: The `local` qualifier must ONLY be used within functions. Using `local` in a script's root scope causes bugs and unexpected behavior.

#### Always Declare Variables

**REQUIRED**: Variables must be explicitly declared before use.

- In **function scope**, use `local` declarations.
- In **script root scope**, use `typeset` (not `local`).
- Prefer **readonly declarations** where values should not change.

✅ **Good:**
```zsh
# root scope
typeset -r script_dir="${0:A:h}"
typeset -r script_name="${0:t}"

function run_task {
  local -r task_name="build"
  local task_rval=0
}
```

❌ **Bad:**
```zsh
# root scope with local is invalid
local script_dir="${0:A:h}"

# undeclared then assigned
some_value="abc"
```

#### zparseopts Exception

`zparseopts` creates and initializes its target variables. You do not need to predeclare those parse target variables.

```zsh
zparseopts -D -E -- \
  -done=flag_done \
  -some-key:=opt_some_value

# zparseopts allocates flag_done / opt_some_value.
# Declare wrapper variables that your code owns.
typeset -r some_value="${opt_some_value[-1]:-default}"
```

Use this exception only for parse-target variables; declare all wrapper/derived variables explicitly.

#### Readonly-By-Default Rule

When a variable should not change after initialization, declare it readonly at declaration time.

✅ **Good:**
```zsh
typeset -r config_path="$HOME/.config/myapp/config.yml"
local -r mode="safe"
```

Use mutable variables only when mutation is intentional and required by control flow.

#### Before Declaring Readonly (Critical)

**CRITICAL**: Before adding `-r` to any variable declaration, verify the variable is never reassigned later in the script.

**Analysis steps:**
1. Search entire script for reassignments: `grep "^variable_name=" script.zsh`
2. Check within functions: `grep "variable_name=" script.zsh` (without `^` anchor)
3. If any reassignments exist, the variable **MUST** remain mutable (omit `-r`)
4. Only use `-r` if variable is never reassigned after initialization

**Example of proper analysis:**

```zsh
# Step 1: Search for all assignments to dest_dir
$ grep "dest_dir=" script.zsh
483:typeset dest_dir="${opt_dest_dir[2]:-$PWD}"
570:dest_dir="$git_root_dir"

# Step 2: Analysis shows reassignment on line 570
# Conclusion: dest_dir MUST remain mutable

# ✅ Correct - no -r flag
typeset dest_dir="${opt_dest_dir[2]:-$PWD}"

# Later in script (line 570):
if [[ "$dest_dir_absolute" != "$git_root_dir" ]]; then
  dest_dir="$git_root_dir"  # Valid reassignment
fi
```

**Common mistake:**

```zsh
# ❌ Bad - declares readonly but reassigns later
typeset -r dest_dir="${opt_dest_dir[2]:-$PWD}"

# Later in script:
dest_dir="$git_root_dir"  # CRASH: attempt to assign readonly variable
```

**When to use readonly:**

```zsh
# ✅ Good - variable never reassigned
typeset -r script_dir="${0:A:h}"
typeset -r script_name="${0:t}"
typeset -r config_file="$HOME/.config/app.yml"

# These variables are set once and never change
```

#### Type-Specific Declarations

Use `typeset` flags to match variable semantics and storage needs. `-r`, `-a`, and `-A` are common examples, not an exhaustive list.

Examples of commonly used flags:

- `-r`: readonly
- `-a`: indexed array
- `-A`: associative array
- `-i`: integer semantics
- `-F`: floating-point semantics
- `-x`: export to environment

Choose flags based on runtime intent (immutability, type behavior, environment export, etc.).

Use declaration flags to match variable type and mutability:

```zsh
typeset -r -a my_array=(a b 'cd')
typeset -r -A my_dict=([a]='A' [b]='B')
```

When mutability is required, omit `-r` but keep type flags (`-a`, `-A`).

#### Readonly Re-Declaration Pitfall (Critical)

Do not redeclare a variable as readonly if that variable may already be defined/populated by bootstrap code, shared libraries, or prior parsing passes.

This is especially important for reused CLI parse variables such as `flag_debug`, `flag_help`, `flag_dry_run`, etc. If those already hold a value, attempting readonly redeclaration can fail.

❌ **Bad:**
```zsh
# May fail if flag_debug already exists with a value from boilerplate/parser code
typeset -r flag_debug="${flag_debug:-}"
```

✅ **Good:**
```zsh
# Keep parser/shared vars mutable if they are reused across parse phases
typeset flag_debug="${flag_debug:-}"

# Create a readonly wrapper variable owned by current scope
typeset -r effective_flag_debug="${flag_debug:-}"
```

Rule of thumb:
- Parser/shared variables (`flag_*`, `opt_*`, other cross-phase state) should usually remain non-readonly.
- Derived wrapper variables that represent final decisions can be readonly.

#### Scope Rules

✅ **Good (correct `local` usage):**
```zsh
# In script root scope - no local qualifier
typeset -r script_dir="${0:A:h}"
typeset -r temp_file="/tmp/output.txt"

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
- `local` restricts variable scope to functions only
- Using `local` outside functions causes undefined behavior
- AI agents frequently make this mistake, leading to wasted debugging time

#### Declaration and Initialization

**CRITICAL**: Always declare and initialize variables in a single compound statement. Separating declaration and initialization can cause unexpected output to stdout.

> **Local variables are never exempt.** In `zsh` the `local` builtin does **not** create an uninitialized placeholder the way some other shells do; writing
> `local foo; foo="bar"` can emit `foo=bar` to stdout and leak state. Therefore every `local` declaration **must** include its initial value, even if that
> value is an empty string. Treat this as a universal rule for **all** variables (local, global, exported, associative, arrays, etc.): declare and assign in a
> single statement to avoid uninitialized reads, stdout leakage, and shellcheck false positives.

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
- Separate initialization (`my_var=0`) can write to stdout unexpectedly
- Causes bugs where variable assignments appear in command output
- Breaks pipes and variable captures
- Single compound statements are atomic and predictable
- The problem occurs whether initialization is immediate or delayed

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
# Script root scope variable
typeset -r file_path="/tmp/example"

# Function-local variable
function process_example {
  local -r file_path="/tmp/example"
}

# Variable used only in same file
typeset -r current_user="admin"

# Exported variable
export DATABASE_URL="postgres://..."

# Variable used across files (sourced/exported)
typeset -r CONFIG_DIR="/etc/myapp"
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

### Variable Debugging Pattern (Required)

**For every variable assignment (initialization or value change), immediately log the variable using `slog_var1_se_d`:**

```zsh
# For scalar variables (script root scope)
typeset -r my_var="some_value"
slog_var1_se_d "my_var"

# For arrays (script root scope)
typeset -r -a my_array=("item1" "item2" "item3")
slog_var1_se_d "my_array"

# For associative arrays (script root scope)
typeset -r -A my_dict=([name]="zakk" [role]="maintainer")
slog_var1_se_d "my_dict"

# For result variables (script root scope)
# Mutable on purpose: value and rval are populated at runtime.
typeset result="$(some_command)"
typeset -i result_rval=$?
slog_var1_se_d "result"
slog_var1_se_d "result_rval"

# For result variables (function scope)
function example_step {
  local result="$(some_command)"
  local -i result_rval=$?

  slog_var1_se_d "result"
  slog_var1_se_d "result_rval"
}
```

**`slog_var1_se_d` semantics:**
- `var1` means one required argument: the variable name as a string (for example, `"platforms"`)
- Do not pass the variable value as a second argument
- Arrays are formatted across multiple lines with one index/element per line
- Associative arrays are formatted across multiple lines with key/value pairs sorted by key (lexicographic order)
- `slog_var_se_d` is deprecated and should not be used

**Why this pattern:**
- Provides complete variable visibility when `--debug` flag is used
- Makes debugging significantly easier by showing all variable assignments
- No performance cost when debug mode is off (functions no-op)
- Creates a self-documenting record of variable flow

**Rule:** Every variable assignment should be followed by `slog_var1_se_d "<variable_name>"`.

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
- Clearly distinguishes functions from commands
- Easier to search for function definitions: `grep -r "^function "`
- More readable and explicit
- Consistent with Zsh best practices

❌ **Don't use:**
```zsh
my_function() {  # Avoid this syntax
  # ...
}
```

### Function Comments and Documentation

**REQUIRED**: Every function must include a markdown-style documentation block above its definition. This format is designed to be both human-readable and machine-extractable (by removing the `# ` comment prefix).

#### Documentation Format

Functions should use markdown-style comments with standardized section headers. The format supports:
- **Section headers**: Use markdown H1 headers (`# SYNOPSIS`, `# ARGS`, etc.)
- **Subsection headers**: Use markdown H2 headers (`# ## Subsection Title`)
- **Code blocks**: Use markdown triple-backticks for code examples
- **Inline code**: Use markdown backticks for inline code/variables
- **Lists**: Use markdown asterisk syntax for bullet points
- **Links**: Use markdown link syntax `[text](https://example.com)`

**Complete documentation template:**

```zsh
# Brief one-line description of what the function does
# # SYNOPSIS
# ```zsh
# function_name --arg1 <value1> --arg2 <value2> [--optional-arg <value>]
# ```
# # ARGS
# * `--arg1 <value>` - Description of first argument
# * `--arg2 <value>` - Description of second argument
# * `--optional-arg <value>` - Description of optional argument (optional)
# # EXIT STATUS
# * `0` - Success
# * `1` - Error: description of error condition
# # STDOUT
# Description of what gets written to stdout, or "None" if nothing
# # STDERR
# * Description of stderr output
# * Another stderr condition
# # EXAMPLES
# ```zsh
# function_name --arg1 value1 --arg2 value2
# function_name --arg1 value1 --arg2 value2 --optional-arg value3
# ```
# # REFERENCES
# ## Topic or Tool Name
# * `man command_name`
# * [website.example.com: Topic Name](https://website.example.com/path)
# # OTHER
# Additional notes, implementation details, or important context
function function_name {
  zparseopts -D -F -- \
    -arg1:=opt_arg1 \
    -arg2:=opt_arg2 \
    -optional-arg:=opt_optional_arg
  # function implementation
}
```

#### Required Sections

At minimum, every function must include:

1. **Brief description** (first line)
2. **SYNOPSIS** - Function call syntax with argument names
3. **ARGS** - List of all arguments with descriptions
4. **EXIT STATUS** - Possible return codes and their meanings

#### Optional Sections

Include these sections when relevant:

- **STDOUT** - What gets written to stdout (use "None" if nothing)
- **STDERR** - What gets written to stderr
- **EXAMPLES** - Usage examples (highly recommended)
- **REFERENCES** - Links to documentation, man pages, or related topics
- **OTHER** - Additional notes, implementation details, or important context

#### Minimal Example

For simple functions, the minimal documentation is acceptable:

```zsh
# Brief one-line description of what function does
# # SYNOPSIS
# ```zsh
# function_name --arg1 <value1>
# ```
# # ARGS
# * `--arg1 <value>` - Description of argument
# # EXIT STATUS
# * `0` - Success
# * `1` - Error: description of error
# # STDOUT
# None
# # STDERR
# Error messages if operation fails
function function_name {
  zparseopts -D -F -- -arg1:=opt_arg1
  # function implementation
}
```

#### Real-World Example

From the `append_unique` function:

```zsh
# Appends items to a zsh array and removes duplicates.
# # SYNOPSIS
# ```zsh
# append_unique --array <name> <items...>
# ```
# # ARGS
# * `--array <name>` - Name of the array variable to append to (must be an array type)
# * `<items...>` - One or more items to append to the array
# # EXIT STATUS
# * `0` - Success
# * `1` - Error: --array option missing, array name not found, or variable is not an array
# # STDOUT
# None
# # STDERR
# * Error messages if arguments are invalid
# * Warning if array contents appear to have been passed as arguments
# * Hint for tied arrays if uppercase name provided (PATH, FPATH, etc.)
# # EXAMPLES
# ```zsh
# append_unique --array path /usr/local/bin /opt/homebrew/bin
# append_unique --array fpath ~/.zsh/functions ~/.oh-my-zsh/custom
# ```
# # REFERENCES
# ## Array subscript `(I)` flag
# * `man zshparam` (search "Subscript Flags")
# * [zsh.sourceforge.io: Array-Subscript-Flags](https://zsh.sourceforge.io/Doc/Release/Parameters.html#Array-Subscript-Flags)
# ## Tied arrays (path/PATH)
# * `man zshparam` (search "Special Parameters")
# * [zsh.sourceforge.io: Array-Parameters](https://zsh.sourceforge.io/Doc/Release/Parameters.html#Array-Parameters)
# # OTHER
# Zsh provides array versions of uppercase colon-delimited environment variables.
# These special "tied" arrays automatically synchronize with their string counterparts:
# * `path` ↔ `PATH` - Executable search paths
# * `fpath` ↔ `FPATH` - Function search paths (for autoload)
# * `manpath` ↔ `MANPATH` - Manual page search paths
# * `cdpath` ↔ `CDPATH` - Directory search paths for cd command
# * `mailpath` ↔ `MAILPATH` - Mail file locations
function append_unique {
  # function implementation
}
```

#### Why Markdown-Style Documentation

- **Machine-extractable**: Remove `# ` prefix to get valid markdown documentation
- **Human-readable**: Familiar markdown syntax is easy to read in source
- **IDE support**: Many editors parse comment blocks for inline help
- **Syntax highlighting**: Better Comments extension highlights structure elements
- **Consistency**: Uniform documentation style across entire codebase
- **AI-friendly**: Clear structure helps AI agents understand function behavior
- **Documentation tools**: Compatible with tools like `shdoc` that extract markdown from comments

#### Documentation vs print_usage

**IMPORTANT**: Function documentation is separate from script `print_usage` functions:
- **Function docs**: Document individual functions with markdown-style comments
- **`print_usage`**: Document script command-line interface with formatted help text
- These serve different purposes and should not be confused

### Function-Level Error Handling

**CRITICAL**: Functions must apply the same error handling patterns as script-level code. All functions follow the three-phase error handling pattern:

1. **Intent**: Log what will be done using `slog_step_se --context will`
2. **Operation**: Execute the operation with proper error handling
3. **Outcome**: Log success or failure (fatal or warning)

#### Fatal Error Handling in Functions

Use `return` instead of `exit` for fatal errors within functions:

✅ **Good (fatal error in function):**
```zsh
# Verify required directory exists
# Usage: get_backup_path --source-dir "/path/to/backup"
function get_backup_path {
  zparseopts -D -F -- \
    -source-dir:=opt_source_dir
  
  local source_dir="${opt_source_dir[2]}"
  
  # [step] Verify backup source directory exists
  slog_step_se --context will "verify backup source directory: " --url "$source_dir" --default
  
  if [[ ! -d "$source_dir" ]]; then
    slog_step_se --context fatal "backup source directory does not exist: " --url "$source_dir" --default
    return 1
  fi
  
  slog_step_se --context success "verified backup source directory exists: " --url "$source_dir" --default
  echo "$source_dir"
}
```

**Critical differences from script-level fatal handling:**
- Use `return <code>` instead of `exit <code>`
- Use `return` to signal failure to the calling code
- Calling code decides whether to `exit` the entire script or recover

#### Calling Functions with Fatal Error Handling

When calling functions that can fail, use `|| { }` pattern with exit code capture:

✅ **Good (calling function with error handling):**
```zsh
# [step] Get backup directory
slog_step_se --context will "determine backup directory"

typeset backup_path=""
backup_path=$(get_backup_path --source-dir "$source_dir") || {
  typeset -i exit_code=$?
  slog_step_se --context fatal --exit-code "$exit_code" "determine backup directory"
  exit $exit_code
}

slog_var1_se_d "backup_path"
slog_step_se --context success "determined backup directory: " --url "$backup_path" --default
```

#### Warning Error Handling in Functions

Use `if/then/else/fi` for operations that should not stop the function:

✅ **Good (warning error in function):**
```zsh
# Update optional user preference
# Usage: maybe_update_preference --preference-name "dock_size" --preference-value "64"
function maybe_update_preference {
  zparseopts -D -F -- \
    -preference-name:=opt_pref_name \
    -preference-value:=opt_pref_value
  
  local pref_name="${opt_pref_name[2]}"
  local pref_value="${opt_pref_value[2]}"
  
  # [step] Update user preference
  slog_step_se --context will "update preference: " --code "$pref_name" --default " = " --code "$pref_value" --default
  
  if defaults write com.example.app "$pref_name" "$pref_value" 2>/dev/null; then
    slog_step_se --context success "updated preference: " --code "$pref_name" --default
    return 0
  else
    local exit_code=$?
    slog_step_se --context warning --exit-code "$exit_code" "failed to update preference (optional): " --code "$pref_name" --default
    return 0  # Still return 0 - this is optional and shouldn't fail the caller
  fi
}
```

#### External Tool Dependency Handling in Functions

When functions depend on external tools that might not be available, handle gracefully:

✅ **Good (fatal dependency check in function):**
```zsh
# Parse JSON output - requires jq
# Usage: parse_json_field --json-string '{}' --field "name"
function parse_json_field {
  zparseopts -D -F -- \
    -json-string:=opt_json_string \
    -field:=opt_field
  
  local json_string="${opt_json_string[2]}"
  local field="${opt_field[2]}"
  
  # [step] Verify jq is available
  slog_step_se --context will "verify jq tool is available"
  
  if ! type jq >/dev/null 2>&1; then
    slog_step_se --context fatal "required tool not found: jq"
    return 1
  fi
  
  slog_step_se --context success "verified jq tool is available"
  
  # [step] Parse JSON field
  slog_step_se --context will "parse JSON field: " --code "$field" --default
  
  local result
  result=$(echo "$json_string" | jq -r ".${field}") || {
    local exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "parse JSON field: " --code "$field" --default
    return "$exit_code"
  }
  
  echo "$result"
}
```

✅ **Good (optional dependency, graceful fallback):**
```zsh
# Try to pretty-print JSON with jq if available, otherwise use cat
# Usage: try_pretty_json --json-string '{}'
function try_pretty_json {
  zparseopts -D -F -- \
    -json-string:=opt_json_string
  
  local json_string="${opt_json_string[2]}"
  
  # Check if jq is available (optional - this is best-effort)
  if ! type jq >/dev/null 2>&1; then
    slog_debug_se "jq not available - using plain JSON output"
    echo "$json_string"
    return 0
  fi
  
  # [step] Pretty-print JSON with jq
  slog_step_se --context will "pretty-print JSON"
  
  if echo "$json_string" | jq . >/dev/null 2>&1; then
    echo "$json_string" | jq .
    slog_step_se --context success "pretty-printed JSON"
  else
    slog_step_se --context warning "invalid JSON - using plain output"
    echo "$json_string"
  fi
  
  return 0
}
```

#### Backup and Restore Error Handling in Functions

When functions modify files, always use backup/restore pattern for error safety:

✅ **Good (file modification with backup/restore):**
```zsh
# Add an entry to a configuration file safely
# Usage: append_config_entry --config-file "/etc/app.conf" --entry "key=value"
function append_config_entry {
  zparseopts -D -F -- \
    -config-file:=opt_config_file \
    -entry:=opt_entry
  
  local config_file="${opt_config_file[2]}"
  local entry="${opt_entry[2]}"
  local backup_file="${config_file}.backup"
  
  # [step] Verify configuration file exists
  slog_step_se --context will "verify configuration file exists: " --url "$config_file" --default
  
  if [[ ! -f "$config_file" ]]; then
    slog_step_se --context fatal "configuration file not found: " --url "$config_file" --default
    return 1
  fi
  
  slog_step_se --context success "verified configuration file exists"
  
  # [step] Create backup
  slog_step_se --context will "create backup of configuration file"
  
  if ! cp "$config_file" "$backup_file"; then
    local exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "failed to create backup"
    return "$exit_code"
  fi
  
  slog_step_se --context success "created backup of configuration file"
  
  # [step] Append entry
  slog_step_se --context will "append entry to configuration: " --code "$entry" --default
  
  if echo "$entry" >> "$config_file"; then
    slog_step_se --context success "appended entry to configuration"
  else
    local exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "failed to append entry - restoring backup"
    if mv "$backup_file" "$config_file"; then
      slog_step_se --context success "restored backup after failed append"
    else
      slog_step_se --context fatal "could not restore backup - manual recovery needed at: " --url "$backup_file" --default
    fi
    return "$exit_code"
  fi
  
  # [step] Clean up backup
  slog_debug_se "removing backup file: " --url "$backup_file" --default
  rm -f "$backup_file"
  
  return 0
}
```

#### Summary: Error Handling Decision Guide for Functions

| Scenario | Pattern | Return Code |
|----------|---------|-------------|
| **Critical operation that must succeed** | `||` with fatal log and `return 1` | Non-zero on failure |
| **Operation can fail but function continues** | `if/then/else/fi` with warning log | Return 0 (always) |
| **External tool dependency required** | Check availability, fatal if missing | Non-zero on missing |
| **External tool dependency optional** | Graceful fallback if missing | Zero (always) |
| **File modification** | Always use backup/restore pattern | Non-zero on file operation failure |
| **Multi-step operation** | Combine patterns: fatal for critical steps, warning for optional | Depends on step |

#### Key Error Handling Rules for Functions

1. **Always return explicit exit codes**: Don't rely on implicit `return 0` at end
   ```zsh
   # Good
   if operation_succeeds; then
     return 0
   else
     return 1
   fi
   
   # Also good - explicit at end
   return 0
   ```

2. **Capture exit codes from critical commands**:
   ```zsh
   command || {
     exit_code=$?
     slog_step_se --context fatal --exit-code "$exit_code" "message"
     return "$exit_code"
   }
   ```

3. **Use function return values in calling code**:
   ```zsh
   result=$(my_function) || {
     exit_code=$?
     # Handle the error at script level
   }
   ```

4. **Document expected return values in function comments**:
   ```zsh
   # Process data file
   # Returns: 0 on success, 1 if file invalid, 2 if file not found
   # Usage: process_file --file "/path/to/file"
   function process_file {
     # ...
   }
   ```

5. **Never suppress stderr in function calls** (unless specifically filtering):
   ```zsh
   # Bad
   result=$(my_function 2>/dev/null) || handle_error
   
   # Good - let errors flow through
   result=$(my_function) || handle_error
   ```

---

## Function Arguments: Named vs Positional

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
- **Self-documenting**: Argument names make code intent clear
- **Order-independent**: Arguments can be passed in any order
- **Maintainable**: Adding new arguments doesn't break existing calls
- **Type-safe**: Flags vs values are explicit
- **Consistent**: Matches script-level argument parsing patterns

**When positional arguments are acceptable:**
- Very simple functions with 1-2 obvious parameters
- Internal helper functions with clear, single-purpose parameters
- When function signature is stable and unlikely to change

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
- **Performance**: No external processes, no loops
- **Reliability**: Built into Zsh, always available
- **Clarity**: Intent is immediately obvious
- **Consistency**: Matches other Zsh expansion patterns

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

## Output and Logging

**CRITICAL**: All output in Zsh scripts must use the standardized logging and formatting functions provided by the `.zsh_boilerplate` bootstrap chain.

### Core Logging Functions

After sourcing boilerplate (see the "Source Zsh Boilerplate" section), scripts have access to two primary output function families:

| Function          | Destination  | When                                     |
| ----------------- | ------------ | ---------------------------------------- |
| `slog`            | stdout       | Standard output                          |
| `slog_se`         | stderr       | Standard error output                    |
| `slog_d`          | stdout       | Debug output (when `IS_DEBUG` set)       |
| `slog_se_d`       | stderr       | Debug error output (when `IS_DEBUG` set) |
| `echo_pretty`     | configurable | Decorated output with colors/formatting  |

### Function Naming Patterns

All `slog_*` functions follow consistent naming conventions:

- **`_se` suffix**: Writes to **stderr** (standard error)
  - Without `_se`: Writes to **stdout** (standard output)
  
- **`_d` suffix**: Only writes when `IS_DEBUG` environment variable is set
  - Examples: `slog_d`, `slog_se_d`
  
- **`_v` suffix**: Only writes when `IS_VERBOSE` environment variable is set
  - Examples: `slog_v`, `slog_se_v`

### Modern Contextual Logging: slog_step_se

**PREFERRED**: Use `slog_step_se` for all contextual logging instead of the deprecated context-specific functions.

**Synopsis:**
```zsh
slog_step_se [--context <context_value>] [--exit-code <exit_code>] [message ...]
```

**Context Values:**
- `todo` - Task to be completed
- `fixme` - Code that needs fixing
- `idea` - Suggestion or potential improvement
- `trace` - Execution trace information
- `info` - Informational message
- `will` - Intent (what will be done)
- `did` - Completion (what was done)
- `success` - Successful operation
- `warning` - Warning condition
- `error` - Error condition
- `fatal` - Fatal error
- `severe` - Severe issue
- `critical` - Critical failure
- `finished` - Task completion marker

**Parameters:**
- `--context <value>`: (also accepted as `--step`) Specifies the logging context from the list above
- `--exit-code <code>`: Optional exit code to display with the message
- `message`: Zero or more arguments compatible with `echo_pretty` syntax (text, colors, decorators)

**Examples:**
```zsh
# Simple info message
slog_step_se --context info "Starting deployment process"

# Intent logging
slog_step_se --step will "download packages from repository"

# Success with decorated output
slog_step_se --context success "created file: " --url "$output_path" --default

# Error with exit code
slog_step_se --context error --exit-code 1 "Failed to connect to " --code "$hostname" --default

# Warning with multi-color formatting
slog_step_se --step warning --red "Authentication failed" --default ", retrying with token"
```

### Deprecated Context-Specific Functions

The following functions still exist but should **NOT** be used in new code. Use `slog_step_se` instead:

| Deprecated Function | Replacement                              |
| ------------------- | ---------------------------------------- |
| `slog_info_se`      | `slog_step_se --context info`           |
| `slog_success_se`   | `slog_step_se --context success`        |
| `slog_warning_se`   | `slog_step_se --context warning`        |
| `slog_error_se`     | `slog_step_se --context error`          |

### echo_pretty: Formatted Output

`echo_pretty` provides rich ANSI formatting through argument-based syntax. It supports extensive color and text decoration options.

**Basic Syntax:**
```zsh
echo_pretty [formatting_args...] "text" [more_formatting_args...] "more text"
```

**Foreground Colors (8-bit):**
```zsh
--black, --red, --green, --yellow, --blue, --magenta, --cyan, --white
--bright-black, --bright-red, --bright-green, --bright-yellow
--bright-blue, --bright-magenta, --bright-cyan, --bright-white
```

**Background Colors (8-bit):**
```zsh
--bg-black, --bg-red, --bg-green, --bg-yellow, --bg-blue, --bg-magenta
--bg-cyan, --bg-white, --bg-bright-black, --bg-bright-red, etc.
```

**Extended Colors:**
```zsh
--color-8bit <0-255>        # 8-bit color palette
--bg-color-8bit <0-255>     # 8-bit background
--color-24bit <r> <g> <b>   # RGB foreground (0-255 each)
--bg-color-24bit <r> <g> <b> # RGB background
```

**Font Decorators:**
```zsh
--bold, --dim, --italic, --underline, --blink
--reverse, --hidden, --strikethrough
```

**Special Formatting:**
```zsh
--default         # Reset all formatting to defaults
--code            # Format as inline code (colored, distinct)
--url             # Format as URL/file path (colored, underlined)
```

**Cursor Control:**
```zsh
--cursor-up <n>, --cursor-down <n>, --cursor-forward <n>, --cursor-back <n>
--cursor-save, --cursor-restore, --cursor-hide, --cursor-show
--clear-line, --clear-screen
```

**Examples:**
```zsh
# Basic colored output
echo_pretty --green "Success" --default ": Operation completed"

# Code formatting
echo_pretty "Run: " --code "brew install package" --default

# URL formatting  
echo_pretty "Visit: " --url "https://example.com" --default

# Complex multi-color
echo_pretty --bold --blue "STATUS:" --default " " \
            --green "✓" --default " Deployment " \
            --yellow "ready" --default

# 24-bit RGB color
echo_pretty --color-24bit 255 100 50 "Custom orange text" --default
```

**Integration with slog_step_se:**
```zsh
# slog_step_se accepts echo_pretty arguments
slog_step_se --context info \
  "Processing file: " --url "$file_path" --default \
  " (size: " --code "${file_size}KB" --default ")"
```

### Output Best Practices

**Rule 1: Never use plain `echo` for informational output**

After sourcing utilities, always use `slog_*` or `echo_pretty` for any script output. The only acceptable uses of `echo` are:

1. **Heredoc boundaries** (unavoidable syntax requirement)
2. **Test scripts** explicitly testing output formatting
3. **Return values** from functions meant to be captured (use with caution)

For all other cases, the enhanced logging functions provide better formatting, consistency, and debugging capability.

**Examples:**

✅ **Good:**
```zsh
slog_se "Starting backup process"
slog_step_se --context will "create directory: " --url "$backup_dir" --default
echo_pretty --green "Backup complete" --default
```

❌ **Bad:**
```zsh
echo "Starting backup process"  # Don't use echo
echo "Creating directory: $backup_dir"  # Don't use echo
echo "Backup complete"  # Don't use echo
```

---

## Step Pattern: Structured Operation Logging

**CRITICAL**: All operations that can succeed or fail must use the Step Pattern for consistent, traceable execution logging.

### Overview

The **Step Pattern** is a three-phase structure for operations:

1. **Intent**: Log what will be done (before the operation)
2. **Operation**: Perform the operation with error handling
3. **Result**: Log success or failure (after the operation)

This pattern provides complete visibility into script execution and makes debugging significantly easier.

### Error Handling Context

All scripts in this repository run with error handling enabled (via shebang or parent shell):
- `set -e` / `-e`: Exit immediately if a command exits with a non-zero status
- `set -u` / `-u`: Treat unset variables as an error
- `set -o pipefail` / `-o pipefail`: Pipeline exits with status of last failing command

**Therefore**: Always add error handling around commands that can fail using the Step Pattern.

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

### Modern Logging API: slog_step_se

**PREFERRED**: Use `slog_step_se --context <type>` for all step logging. This modern API replaces the older context-specific functions.

**Synopsis:**
```zsh
slog_step_se [--context <context>] [--exit-code <code>] [message ...]
```

**Context Values:**
- `will` - Intent (what will be done)
- `success` - Successful operation
- `fatal` - Fatal error (script must exit)
- `warning` - Warning condition (script continues)
- `error` - Error condition (deprecated, use `fatal` or `warning`)
- `info` - Informational message
- `trace` - Execution trace information
- `did` - Completion (what was done)
- `todo` - Task to be completed
- `fixme` - Code that needs fixing
- `idea` - Suggestion or potential improvement
- `finished` - Task completion marker
- `severe` - Severe issue
- `critical` - Critical failure

**Parameters:**
- `--context <value>`: (also accepted as `--step`) Specifies the logging context
- `--exit-code <code>`: (also accepted as `--rval`) Exit code to display with the message (automatically formats as `[$exit_code]` at front)
- `message`: Zero or more arguments compatible with `echo_pretty` syntax (text, colors, decorators like `--code`, `--url`, `--default`)

### Step Pattern Structure

**Complete pattern with all required elements:**

```zsh
# [step] Comment marker for searchability
slog_step_se --context will "operation description" --code "$variable" --default

# Mutable on purpose: assigned by command substitution in the next statement.
typeset result=""
result=$(command_with_args) || {
  typeset -i exit_code=$?
  slog_step_se --context fatal --exit-code "$exit_code" "operation description"
  exit $exit_code  # Use 'exit' in script root scope, 'return' in functions
}

slog_var1_se_d "result"
slog_step_se --context success "operation completed" --code "$result" --default
```

**Key Components:**

1. **Comment marker**: `# [step]` - Makes steps easily searchable
2. **Intent log**: `--context will` - Describes what will happen
3. **Operation**: Command with error handler using `|| { }`
4. **Exit code capture**: `exit_code=$?` - Preserve exact exit status
5. **Error log**: `--context fatal` with `--exit-code` - Reports failure
6. **Scope-aware exit**: `exit` for script root, `return` for functions
7. **Debug log**: `slog_var1_se_d` - Log result variable for debugging by variable name
8. **Success log**: `--context success` - Reports successful completion

### Step Logging Levels and Command Messages

- **Intent logs (`will`) must use debug level**: Call `slog_step_se_d --context will ...` for "will" statements so routine intent chatter stays hidden unless `--debug` is enabled.
- **Success logs must use debug level**: Use `slog_step_se_d --context success ...` to keep success spam out of normal stderr while still available for debugging.
- **Warning logs must use debug level**: When treating a failure as non-fatal, report it with `slog_step_se_d --context warning ...`; only true errors stay at non-debug level.
- **Error/fatal logs remain at normal severity**: Continue using `slog_step_se --context fatal|error ...` so failures are always visible.

Every step that executes an external command/script must follow this pattern:

1. **Compose the command first** in a string variable (e.g., `typeset -r cmd="rsync ..."` at script root, or `local cmd="rsync ..."` in functions). Never inline the command directly inside the `if`/`||` statements without capturing it in a variable.
2. **Build reusable message arguments** (commonly via an array like `typeset -r -a message_args=("sync files with " --code "$cmd" --default)` at script root, or `local -a ...` in functions).
3. **Use those arguments in every log message** (`will`, `success`, `warning`, `error`) so the exact command (decorated with `--code`/`--default`) is always shown.

Example fatal step with the required logging levels and command handling:

```zsh
typeset -r cmd="swift ${(qqq)SP_SUBCOMMAND} --sdk ${(qqq)SDK_PATH} --arch ${(qqq)ARCHITECTURE} -Xswiftc -target -Xswiftc ${(qqq)TARGET} ${(qqq)@}"
typeset -r -a message_args=("compile code using command: " --code "$cmd" --default)

slog_step_se_d --context will "Will " "${(j| |)message_args[@]}"
if ! gh_validate "$IS_DEBUG" > /dev/null 2>&1; then
  typeset -i rval=$?
  slog_step_se --context fatal --exit-code "$rval" "Failed to " "${(j| |)message_args[@]}"
  exit "$rval"
fi
slog_step_se_d --context success "Did " "${(j| |)message_args[@]}"
```

### Pattern 1: Fatal Steps (Critical Operations)

Use `--context fatal` when failure should stop script execution:

```zsh
# [step] Read repository's default branch
slog_step_se --context will "read repository's default branch"

# Mutable on purpose: populated by command substitution in the next statement.
typeset git_default_branch=""
git_default_branch="$(git rev-parse --abbrev-ref "$(git remote)"/HEAD | sed 's|origin/||g')" || {
  typeset -i exit_code=$?
  slog_step_se --context fatal --exit-code "$exit_code" "read repository's default branch"
  exit $exit_code
}

slog_var1_se_d "git_default_branch"
slog_step_se --context success "Read repository's default branch: " --code "$git_default_branch" --default
```

**Use for:**
- Installing required packages
- Reading critical configuration
- Creating essential directories
- Validating prerequisites
- Git operations in automated workflows
- API calls that must succeed

**Scope-Aware Exit Handling:**
```zsh
# In script root scope - use 'exit'
command || {
  exit_code=$?
  slog_step_se --context fatal --exit-code "$exit_code" "operation failed"
  exit $exit_code  # ✅ Correct for script scope
}

# In function scope - use 'return'
function my_function {
  command || {
    exit_code=$?
    slog_step_se --context fatal --exit-code "$exit_code" "operation failed"
    return $exit_code  # ✅ Correct for function scope
  }
}
```

### Pattern 2: Warning Steps (Best-Effort Operations)

Use `--context warning` with `if/then/else/fi` when failure should be logged but script continues:

```zsh
# [step] Configure optional preference
slog_step_se --context will "configure dock tile size"

if defaults write com.apple.dock tilesize -int 52; then
  slog_step_se --context success "Configured dock tile size"
else
  exit_code=$?
  slog_step_se --context warning --exit-code "$exit_code" "Failed to configure dock tile size (optional)"
fi
# Script continues regardless
```

**Use for:**
- User preferences (Dock size, Finder settings)
- Optional configurations (Safari debug menu)
- Cosmetic settings (desktop wallpaper, dark mode)
- Creating convenience symlinks
- Non-essential Git operations

**Key Differences from Fatal Pattern:**
- Uses `if/then/else/fi` instead of `|| { }`
- Uses `--context warning` instead of `--context fatal`
- No `exit` or `return` - script continues after `fi`
- Success log in `if` branch, warning in `else` branch

### Pattern 3: Validation Steps

Use conditional logic for validations that don't execute external commands:

```zsh
# [step] Validate current branch is default branch
slog_step_se --context will "validate current branch (" --code "$git_current_branch" --default ") is default branch (" --code "$git_default_branch" --default ")"

if [[ "$git_current_branch" != "$git_default_branch" ]]; then 
  slog_step_se --context fatal "Current branch (" --code "$git_current_branch" --default ") is not default branch (" --code "$git_default_branch" --default "). Cannot create feature branch from non-default branch."
  exit 1
fi

slog_step_se --context success "Validated current branch (" --code "$git_current_branch" --default ") is default branch"
```

**Use for:**
- Validating environment variables
- Checking file/directory existence
- Comparing values
- Verifying prerequisites

### Exit Code Formatting

**CRITICAL**: The `--exit-code` parameter automatically formats error messages with `[$exit_code]` at the front. Never manually format exit codes.

✅ **Good (automatic formatting):**
```zsh
slog_step_se --context fatal --exit-code "$exit_code" "Failed to install package"
# Output: "[42] Failed to install package"
```

❌ **Bad (manual formatting):**
```zsh
slog_step_se --context fatal "[$exit_code] Failed to install package"  # Don't do this
slog_step_se --context fatal "Failed to install package (exit code: $exit_code)"  # Don't do this
```

**Why automatic formatting:**
- Consistent across all error messages
- Exit code is immediately visible
- Easy to grep/search: `grep '\[42\]' logs/*.log`
- Prevents formatting inconsistencies

### Deprecated Functions

The following older functions still exist but should **NOT** be used in new code. They delegate to `slog_step_se`:

| Deprecated Function | Modern Replacement |
|---------------------|-------------------|
| `slog_info_se` | `slog_step_se --context info` |
| `slog_success_se` | `slog_step_se --context success` |
| `slog_warning_se` | `slog_step_se --context warning` |
| `slog_error_se` | `slog_step_se --context fatal` or `warning` |

**Migration:** When refactoring existing code, prefer converting to the modern `slog_step_se` API for consistency.

### Complete Step Example

From `jira_notes.zsh`:

```zsh
# [step] Fetch Jira ticket JSON
slog_step_se --context will "fetch JSON for jira ticket " --code "$jira_ticket" --default

jira_json=$(get_jira_ticket "$jira_ticket" "$IS_DEBUG") || {
  exit_code=$?
  slog_step_se --context fatal --exit-code "$exit_code" "fetch JSON for jira ticket " --code "$jira_ticket" --default
  exit $exit_code
}

slog_var1_se_d "jira_json"
slog_step_se --context success "Fetched JSON for jira ticket " --code "$jira_ticket" --default
```

**This example demonstrates:**
- `# [step]` comment marker for searchability
- Intent logging with decorated output (`--code` for variable, `--default` for reset)
- Error handling with exit code capture
- Fatal error logging with automatic `[$exit_code]` formatting
- Scope-aware exit (script root scope uses `exit`)
- Debug variable logging
- Success logging with decorated output

### Quick Decision Guide

**Choose the right pattern:**

| Pattern | Context | Exit on Failure? | When to Use |
|---------|---------|------------------|-------------|
| Fatal Step | `fatal` | Yes (`exit` or `return`) | Operation is **critical** to script success |
| Warning Step | `warning` | No (continues) | Operation is **optional** or best-effort |
| Validation Step | `fatal` | Yes (`exit` or `return`) | Condition **must** be true to proceed |

### Path-Specific Overrides

Some directories use different logging functions:
- Setup scripts (`scripts/**/*.zsh`): May use `log_*` functions instead of `slog_*`
- Path-specific instruction files document these overrides

---

## Script Argument Parsing

### Boilerplate + Script-Specific Parsing Pattern (Standard)

**ALL scripts must treat `.zsh_boilerplate` as stages 1-2** (common flags + trap/debug behavior), then parse only script-specific options locally.

```zsh
# Initialize variables required by boilerplate
export IS_DEBUG=""
export IS_VERBOSE=""
export IS_DRY_RUN=""
export IS_UTILS_DEBUG=""

# Stage 0 (required): bootstrap common behavior
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"

# Stage 1-2 already handled by boilerplate:
# - common flags like --help, -d/--debug, --dry-run, --verbose
# - trap/debug flags like --trap-err, --trap-exit

# Stage 3: parse script-specific arguments only
zparseopts -D -- \
  -mode:=opt_mode \
  -other-arg:=opt_other_arg

mode="${opt_mode[-1]:-default_value}"
other_arg="${opt_other_arg[-1]:-default_value}"
```

**Key Points:**
- Do not duplicate boilerplate-managed stages in each script.
- Use `${array[-1]:-default}` to extract zparseopts values.
- Keep script parsing focused on script-specific options and arguments.

### Use zparseopts

Script arguments should be handled using `zparseopts` where possible, or where conversion is easy. If converting requires a significant refactor, retain the current approach.

**zparseopts Flag Reference:**
- **`-D`**: Remove recognized options from `$@` (like `shift`) - **always use this**
- **`-E`**: Continue parsing even when encountering unrecognized options (skip over them) - **use for parallel multi-stage parsing**
- **`-F`**: Fail immediately with error on first unrecognized option - **rarely needed, prefer checking `$@` after parsing**
- **Neither `-E` nor `-F`**: Stop parsing at first unrecognized option (leaves it in `$@`) - **use for sequential multi-stage parsing**

**Multi-Stage Parsing Patterns:**

**Pattern 1: Sequential stages** (each modifies `$@`, next stage sees remainder):
```zsh
# Stage 1: Use -D only (no -E, no -F)
zparseopts -D -- -help=flag_help {d,-debug}+=flag_debug
# Stage 2: Use -D only
zparseopts -D -- -trap-err=flag_trap_err
# Stage 3: Use -D only
zparseopts -D -- -mode:=opt_mode
# Check for unrecognized options
if [[ ${#@} -gt 0 ]]; then
  echo "ERROR: Unrecognized options: $@" >&2
  exit 1
fi
```

**Pattern 2: Parallel stages** (each function receives full `"$@"`):
```zsh
function parse_file_options {
  zparseopts -D -E -- -dir:=opt_dir -depth:=opt_depth
}
function parse_player_options {
  zparseopts -D -E -- -player:=opt_player -volume:=opt_volume
}
# In main():
parse_file_options "$@"    # Removes -dir/-depth, skips -player/-volume
parse_player_options "$@"  # Removes -player/-volume
# Check for unrecognized options
if [[ ${#@} -gt 0 ]]; then
  echo "ERROR: Unrecognized options: $@" >&2
  exit 1
fi
```

**Key Conventions:**
- **For new code**: Always use `-D`, choose `-E` based on parsing pattern
- **Argument definition order**: Capital letter arguments should be listed first and separated from others using `--`
- **Multi-line format**: Define arguments one per line using the trailing `\` syntax
- **Long-form names**: Always include a long-form name (e.g., `--help`) for arguments
  - **Exception**: `{d,-debug}+` uses short-form `-d` to enable quick debug level changes (`-d`, `-dd`, `-ddd`)
- **Standard arguments**: handled by `.zsh_boilerplate`; script-local zparseopts should focus on script-specific options
- **Variable naming**:
  - Flag-style arguments (e.g., `--help`): Prefix with `flag_` or `FLAG_` based on scope
  - Key/value arguments (e.g., `--mode create` or `--mode=create`): Prefix with `opt_` or `OPT_`
- **Associative arrays**: Consider using the `-A <kv_array>` syntax if it does not conflict with other argument styles
- **Avoid flag arrays**: Avoid using the `-a <flag_array>` syntax as it is mutually exclusive with the flag variable approach

### Trap Debugging Support

Trap-debug setup is handled by `.zsh_boilerplate` and `.zsh_zparseopts` (including debug level behavior and explicit trap flags).

For normal scripts, do not add custom trap sourcing blocks unless the script has a specialized trap policy that must differ from shared behavior.

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
  typeset -r script_name="${0:A:t}"
  typeset -r i2="${INDENT_2:-  }"
  typeset -r i4="${INDENT_4:-    }"
  typeset -r i6="${i2}${i4}"

  # SYNOPSIS
  slog_se --bold "SYNOPSIS" --default
  slog_se
  slog_se "${i2}" --code "${script_name} [OPTIONS] [DEVELOPMENT OPTIONS]" --default
  slog_se

  # OPTIONS
  slog_se --bold "OPTIONS" --default
  slog_se
  slog_se "${i2}" --bold --italic "SCRIPT OPTIONS" --default
  slog_se "${i4}" --code '--required-arg <value>' --default
  slog_se "${i6}Description of required argument"
  slog_se "${i4}" --code '--optional-arg <value>' --default
  slog_se "${i6}Description of optional argument (optional)"
  slog_se
  slog_se "${i2}" --bold --italic "META-OPTIONS" --default
  slog_se "${i4}" --code '--help' --default
  slog_se "${i6}Display this help message and exit"
  slog_se "${i4}" --code '--dry-run' --default
  slog_se "${i6}Show what would be done without making changes"
  slog_se

  # DEVELOPMENT OPTIONS
  slog_se --bold "DEVELOPMENT OPTIONS" --default
  slog_se
  slog_se "${i4}" --code '-d, --debug' --default
  slog_se "${i6}Enable debug output (can be specified multiple times for more verbosity)"
  slog_se "${i6}" --code '-d' --default " Basic debug output"
  slog_se "${i6}" --code '-dd' --default " Enable ERR trap debugging (see --trap-err)"
  slog_se "${i6}${i2}(also: -d -d, -d2)"
  slog_se "${i6}" --code '-ddd' --default " Enable ERR and EXIT trap debugging (see --trap-exit)"
  slog_se "${i6}${i2}(also: -d -d -d, -d3)"
  slog_se
  slog_se "${i4}" --code '--trap-err, --debug-err' --default
  slog_se "${i6}Enable ERR trap handler (shows line numbers on script failures)"
  slog_se
  slog_se "${i4}" --code '--trap-exit, --debug-exit' --default
  slog_se "${i6}Enable EXIT trap handler (shows exit status information)"
  slog_se

  # ENVIRONMENT
  slog_se --bold "ENVIRONMENT" --default
  slog_se
  slog_se "${i4}" --code 'REQUIRED_VAR' --default " Description of required environment variable"
  slog_se "${i4}" --code 'OPTIONAL_VAR' --default " Description of optional environment variable (optional)"
  slog_se

  # EXIT STATUS
  slog_se --bold "EXIT STATUS" --default
  slog_se
  slog_se "${i4}" --code '0' --default " Success"
  slog_se "${i4}" --code '1' --default " General error"
  slog_se "${i4}" --code '40-49' --default " Validation/verification failures"
  slog_se "${i4}" --code '50-59' --default " Configuration errors"
  slog_se

  # OUTPUT / STDERR
  slog_se --bold "OUTPUT" --default
  slog_se
  slog_se "${i2}Description of what gets written to stdout on success"
  slog_se
  slog_se --bold "STDERR" --default
  slog_se
  slog_se "${i2}Debug logs and context information (when --debug is enabled)"
  slog_se

  # EXAMPLES
  slog_se --bold "EXAMPLES" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Example command"
  slog_se "${i4}" --code "./${script_name} --required-arg value" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Example with debug output"
  slog_se "${i4}" --code "./${script_name} --required-arg value --debug" --default
  slog_se
  slog_se "${i2}${SYMBOL_BULLET:-•} Example with full trap debugging"
  slog_se "${i4}" --code "./${script_name} --required-arg value -ddd" --default
  slog_se

  # REFERENCES
  slog_se --bold "REFERENCES" --default
  slog_se
  slog_se "${i4}SwiftArgumentParser: " --url "https://apple.github.io/swift-argument-parser/" --default

  return 1
}
```

### Formatting Rules

1.  **Section Headers**: Use UPPERCASE without colons
    -   ✅ `SYNOPSIS`
    -   ✅ `OPTIONS`
    -   ✅ `DEVELOPMENT OPTIONS`
    -   ✅ `ENVIRONMENT`
    -   ❌ `Synopsis:` (lowercase and colon)
    -   ❌ `Usage:` (use SYNOPSIS instead)

2.  **Section Order**:
    1.  `SYNOPSIS` - Brief command syntax
    2.  `OPTIONS` - Script-specific arguments (Stage 3) plus `--help` and `--dry-run` (Stage 1)
    3.  `DEVELOPMENT OPTIONS` - Debug and trap control flags (Stage 1 & 2)
    4.  `ENVIRONMENT` / `ENV VARS` - Environment variables
    5.  `EXIT STATUS` / `EXIT VALUES` - Exit codes
    6.  `OUTPUT` / `STDOUT` - What gets written to stdout
    7.  `STDERR` - What gets written to stderr
    8.  `EXAMPLES` - Example usage
    9.  `REFERENCES` - Links to documentation

3.  **Argument Organization**: Within each section, list:
    -   Mandatory arguments first
    -   Optional arguments last (marked with "(optional)")

4.  **Decorators in Examples**:
    -   Use `--code` and `--default` for command examples
    -   Use `--url` and `--default` for URLs

5.  **Rendering Implementation**:
  -   Prefer `slog_se` for all `print_usage` output so content consistently goes to stderr
  -   Prefer decoration-first calls (`--bold`, `--italic`, `--code`, `--url`) over plain text where applicable
  -   Avoid direct `echo_pretty` calls in `print_usage`
  -   Heredoc usage is discouraged for decorated sections because decorator tokens are not applied inside static blocks

6.  **SwiftArgumentParser Style**: Follow conventions from Swift's ArgumentParser for synopsis formatting:
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
  exit $?
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
- Fewer function calls = better performance
- Single atomic write = better output consistency
- Easier to read and maintain

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
- Heredoc: `cat << 'EOF'`
- Trailing backslash: `"line1 \␤line2"`
- Direct newlines in quotes: `"line1␤line2"`

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
- Improves readability in terminal output
- Provides visual distinction between message and data
- Consistent formatting across all scripts
- Makes logs easier to parse and search

---

## Recommendations

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
- **Debugging**: Index shows exact position in array
- **Logging**: Can display "processing item 5 of 10"
- **Error handling**: Can report which element failed
- **Conditional logic**: Easy to skip/process based on position
- **Progress tracking**: Can calculate percentage complete

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
- Very simple loops with no logging/debugging needs
- No need to track position or progress
- Working with command output directly: `for file in *.txt; do ...`

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
- Tab rendering varies across editors and contexts
- Mixing tabs and spaces causes alignment issues
- Spaces provide consistent visual appearance
- Better compatibility with linters and formatters

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

- [ ] Shellcheck directives present after shebang
- [ ] Variables follow naming conventions (lower_snake vs UPPER_SNAKE)
- [ ] No reserved keywords used as variable/function names (`path`, `command`, `status`, etc.)
- [ ] `local` qualifier only used within functions (never in root scope)
- [ ] Root-scope variables declared with `typeset` (not implicit assignment)
- [ ] Variables declared and initialized in compound statements
- [ ] `zparseopts` target variables treated as parser-managed exception only
- [ ] Wrapper/derived variables explicitly declared (prefer readonly)
- [ ] **Readonly (`-r`) verified**: Searched for reassignments with `grep "variable_name=" script.zsh` before adding `-r`
- [ ] Type flags selected according to situation (`-r`, `-a`, `-A`, `-i`, `-F`, `-x`, etc.)
- [ ] Shared/parser vars are not redeclared readonly when reused across parsing/bootstrap phases
- [ ] Functions use `function name { }` syntax
- [ ] Functions prefer named arguments (zparseopts) over positional parameters
- [ ] Indentation uses spaces (2 spaces per level), not tabs
- [ ] Zsh expansions preferred over external commands (`${var:h}` not `dirname`)
- [ ] Array/string conversions use `(f)` and `(F)` flags (not loops or external tools)
- [ ] Loops avoided when Zsh expansion suffices; C-style loops with indices when needed
- [ ] Safe variable checking with `:-` expansion
- [ ] `.zsh_boilerplate` sourced near top of script
- [ ] No duplicate common flag parsing block added in script body
- [ ] `zparseopts` used for script-specific argument parsing with `-D --` flags
- [ ] `print_usage` function present and bound to `--help`
- [ ] Help formatting follows SYNOPSIS/OPTIONS/ENVIRONMENT structure
- [ ] Context logging minimizes write commands (use multiline strings)
- [ ] Output destination consistency (stderr with stderr, stdout with stdout)
- [ ] Decorators used correctly (--code for commands/vars, --url for paths/URLs)
- [ ] Commands that use pagers are piped to `cat` or use `--no-pager`
- [ ] `echo -n` used with `jq` pipelines
- [ ] **Script tested**: Run with representative inputs to verify no runtime errors
