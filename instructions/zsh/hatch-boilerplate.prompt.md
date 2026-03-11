---
name: hatch-zsh-coding
description: 'Zsh script development with hatch workspace standards, boilerplate, and library ecosystem'
argument-hint: Describe the zsh script task or feature
---

# Hatch Zsh Development Standards

## MANDATORY: Zsh Script Boilerplate

**Every zsh script in this workspace MUST begin with:**

```zsh
#!/usr/bin/env zsh
source "$HOME/.zsh_home/utilities/.zsh_boilerplate" "$0" "$@"
```

This single line recursively sources the entire zsh utility library ecosystem and provides:
- Argument parsing (zparseopts)
- Logging functions
- Git/GitHub utilities
- File operations
- UI utilities
- Swift/Xcode helpers
- And many more...

**Location:** `$HOME/.zsh_home/utilities/.zsh_boilerplate`

---

## Available Utility Libraries (Auto-Sourced)

After sourcing the boilerplate, all these libraries are available:

### Logging Functions (`/Users/zakkhoyt/.zsh_home/utilities/.zsh_logging_utilities`)
**Functions:** `slog_*`, `slog_var_*`, `slog_error_*`, `slog_step_*`
```zsh
slog_se "Simple message"
slog_var_se "VARIABLE_NAME" "$variable_value"
slog_error_se "Error occurred"
slog_array_se "array_name" "${array[@]}"
```

### Argument Parsing (`/Users/zakkhoyt/.zsh_home/utilities/.zsh_zparseopts`)
**Features:** Supports categories: `meta`, `dev`, `indent`, `multiline`
```zsh
source $HOME/.zsh_home/utilities/.zsh_zparseopts "$@"
# Provides: flag_help, flag_verbose, flag_dry_run, flag_debug
```

### Git Utilities (`/Users/zakkhoyt/.zsh_home/utilities/.zsh_git_utilities`)
**Location:** Check for git helper functions available post-boilerplate

### GitHub Utilities (`/Users/zakkhoyt/.zsh_home/utilities/.zsh_github_utilities`)
**Location:** GitHub CLI helpers and wrappers

### File Utilities (`/Users/zakkhoyt/.zsh_home/utilities/.zsh_file_utilities`)
**Location:** File operation helpers

### Swift/Xcode Utilities (`/Users/zakkhoyt/.zsh_home/utilities/.zsh_swift_utilities`)
**Location:** Xcode build and Swift tooling helpers

### Additional Libraries:
- **Scripting Core:** `$HOME/.zsh_home/utilities/.zsh_scripting_core`
- **Scripting Functions:** `$HOME/.zsh_home/utilities/.zsh_scripting_functions`
- **UI Utilities:** `$HOME/.zsh_home/utilities/.zsh_ui_utilities`
- **Jira Utilities:** `$HOME/.zsh_home/utilities/.zsh_jira_utilities`
- **Homebrew Utilities:** `$HOME/.zsh_home/utilities/.zsh_homebrew_utilities`

---

## AI Coding Instructions (MANDATORY for All Code Edits)

### Chat Response Conventions
**File:** `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/instructions/agent-chat-response-conventions.instructions.md`

Apply these when responding:
- ✅ **Markdown source format** - Present information as markdown source, not rendered
- ✅ **Reference links included** - Always include markdown links: `[Link Text](url)`
- ✅ **Copy-friendly code** - Use code fences: ````zsh\ncode\n````
- ✅ **URLs as markdown links** - Never bare URLs, use `[text](url)` syntax

### Terminal Command Conventions
**File:** `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/instructions/agent-terminal-conventions.instructions.md`

Apply these when executing commands:
- ✅ **Persist output** - Save long-running command output to `.gitignored/` logs
- ✅ **Human visibility** - Use `2>&1 | tee log_file` for real-time output capture
- ✅ **Bypass pagers** - Use `| cat`, `--no-pager`, or `PAGER=cat` for git/gh
- ✅ **Reuse logs** - Never re-run commands; filter existing log files instead
- ✅ **Timestamp logs** - Use `$(date +%Y%m%d_%H%M%S)` in log names

### Git Branching Conventions
**File:** `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/instructions/git-branching.instructions.md`

---

## Library Usage Best Practices

### DO: Leverage Available Utilities
```zsh
# ✅ GOOD - Use logging from boilerplate
slog_se "Processing files..."
slog_var_se "INPUT_DIR" "$input_dir"
slog_error_se "Failed to process file"

# ✅ GOOD - Use argument parsing from boilerplate
[[ -n "${flag_help:-}" ]] && print_usage

# ✅ GOOD - Use git utilities if they exist in boilerplate
# Check .zsh_git_utilities for available functions
```

### DON'T: Duplicate Logic
```zsh
# ❌ BAD - Don't rewrite utilities already in boilerplate
my_log_function() { echo "[LOG] $*"; }

# ✅ GOOD - Use boilerplate functions instead
slog_se "$*"
```

### Exploration Command
To see what functions are available after sourcing boilerplate:
```zsh
source "$HOME/.zsh_home/utilities/.zsh_boilerplate"
typeset -F | grep slog_  # See all logging functions
```

---

## Project Structure References

- **CLAUDE.md:** `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/CLAUDE.md` - Project AI instructions (check this first!)
- **Docs directory:** `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/docs/` - Architecture, patterns, workflows
- **iOS patterns:** `docs/patterns/ios-architecture.md`, `docs/patterns/ios-testing.md`, etc.
- **Android patterns:** `docs/patterns/android-architecture.md`, `docs/patterns/android-testing.md`, etc.

---

## Quick Checklist Before Writing Zsh Code

- [ ] Script starts with boilerplate: `source "$HOME/.zsh_home/utilities/.zsh_boilerplate" "$0" "$@"`
- [ ] Using `slog_*` functions for logging (not `echo`)
- [ ] Using argument parsing from boilerplate for flags (not manual parsing)
- [ ] No replicated logic - checked if utility already exists in libraries
- [ ] Chat responses use markdown source format with references
- [ ] Terminal commands either quick (<5s) or persisted to timestamped logs
- [ ] No bare URLs in responses (all formatted as markdown links)

---

## Example Usage

When asking for help with zsh scripts, reference this prompt:

```
@zsh-hatch-coding Create a script that processes files and logs output using the boilerplate ecosystem
```

Or for terminal operations:

```
@zsh-hatch-coding Fix the build script and ensure output is persisted following terminal conventions
```

---

## References

- [Boilerplate Location](file:///Users/zakkhoyt/.zsh_home/utilities/.zsh_boilerplate)
- [Chat Response Conventions](file:///Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/instructions/agent-chat-response-conventions.instructions.md)
- [Terminal Command Conventions](file:///Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/.github/instructions/agent-terminal-conventions.instructions.md)
- [Project CLAUDE.md](file:///Users/zakkhoyt/code/repositories/hatch/hatch_sleep/CLAUDE.md)
