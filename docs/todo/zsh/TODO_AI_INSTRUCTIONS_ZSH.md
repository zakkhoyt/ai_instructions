
# 
`"Re-read .github/instructions/setup-scripts.instructions.md, then apply ALL requirements"`
`"Re-read .github/instructions/zsh-conventions.instructions.md, then apply ALL requirements"`

# Fix/Adjust
* print_usage should always write to `stderr`, not `stdout`
* print_usage should always return 1. The caller should then then use that rval. EX: `print_usage && exit $?`
  * Calling this script with `--help` should never return exit status of 0, and should never write data to `stdout` as that data would be considered valid. 
* print_usage: Always write the help using `slog_se`. Not echo, not echo_pretty. Assume that slog_se is always available. 
* print_usage should return non-0. Callers should exit with it's rval
* print_usage (and all logging) should consolidate multiple lines using variables/array vs calling slog_*, echo_pretty, echo multiple times. 

# Print Usage
Function must be declared before calling, cannot be overwritten as AI suggested

# Always use zparseopts with functions in a script
Avoid positional or unnamed arguments at every opportunity, unless it's a last resort. 
Additionally add/update each function with a comment containing succinct description and a usage synopsis
* [ ] Include text abour references from userscript/markdown_linker/markdown_linker.md
  * [ ] update examples below with references, etc..

EX: Bad
```zsh
function get_file_status {
  local file_basename="$1"
  local source_file="$2"
  local target_file="$target_instructions_dir/$file_basename"
  ...
}
```

EX: Good
```zsh
# Determine installation status of an instruction file (not installed, symlinked, copied, etc.)
# Usage: get_file_status --file-basename "filename.md" --source-file "/path/to/source.md"
function get_file_status {
  zparseopts -D -F -- \
    -file-basename:=opt_file_basename \
    -source-file:=opt_source_file
  
  local file_basename="${opt_file_basename[2]}"
  local source_file="${opt_source_file[2]}"
  local target_file="$target_instructions_dir/$file_basename"
```




## inputs
* --handle-error <fatal | warning>
* --command <command>
  
```zsh

function step {
  zparseopts -D -- \
    {m,-message}:=opt_message \
    {-handle,-handle-error}:=opt_handle_error \
    -cmd:=opt_cmd

  command_args=("$@")

  slog_array_se "opt_message" "${opt_message[@]}"
  slog_array_se "opt_handle_error" "${opt_handle_error[@]}"
  slog_array_se "opt_cmd" "${opt_cmd[@]}"
  slog_array_se "command_args" "${command_args[@]}"


  # opt_handle_error="${opt_handle_error[-1]:-fatal}"


  # slog_step_se --context will "${opt_message}"
  # case $opt_handle_error in 
  # fatal)
  #   ;;
  # warning)
  #   ;;
  # *)
  #   ;;
  # esac


  # zparseopts -D -E -- \
  #   {d,-debug}+=flag_debug \
  #   {-trap-err,-debug-err}=flag_debug_err \
  #   {-trap-exit,-debug-exit}=flag_debug_exit
  
  # # Count # of -d, --debug (or shorthand)
  # flag_debug_level=${#flag_debug[@]}
  
  # if [[ -n $flag_debug || $flag_debug_level -ge 1 ]]; then
  #   # legacy
  #   IS_DEBUG="$flag_debug"
  # fi
  
  # if [[ -n "${flag_debug_err:-}" || $flag_debug_level -ge 2 ]]; then 
  #   source "$HOME/.zsh_home/utilities/.zsh_debug_err"
  #   # source "$HOME/.zsh_home/utilities/.zsh_debug_err" --disable
  # fi
  
  # if [[ -n "${flag_debug_exit:-}" || $flag_debug_level -ge 3  ]]; then 
  #   source "$HOME/.zsh_home/utilities/.zsh_debug_exit"
  #   # source "$HOME/.zsh_home/utilities/.zsh_debug_exit" --disable
  # fi
  
  
}


```


## work

* will: Log that the command will occur
* Depending on success

*  **Intent**: The command to be executed in full (all args, etc..)
*  **Operation**: Perform the operation with error handling
*  **Outcome**: Log success or failure (after the operation)


```zsh
zsh code
```



## output(s)
* stdout
 -->




# zsh
* rather using tail / head, redire4ct stdout / stderr ot a file
* when logging values, wrap them in single quotes (unless empty)
* when logging values, if value is nil, represent it with `<nil>` (without single quotes)

# Vars


# Dependencies
* [ ] Dependencies - document any depenencies clearly
  * [ ] for functions, list the dependencies in the functions comment
  * [ ] for functions, list the dependencies in the functions print_usage function
  * [ ] for script files list the dependencies used in that file in the header comment
  * [ ] for script files list the dependencies used in that file in the print_usage output under a "DEPENDENCIES" section
  * [ ] when generating a `man` include dependencies "DEPENDENCIES" section
  
## update shebang

* [ ] how to DRY further and for a known environment?
```zsh
#!/usr/bin/env -S zsh -euo pipefail
# shellcheck shell=bash
# shellcheck disable=SC2296 # Falsely identifies zsh expansions
# shellcheck disable=SC1091 # Complains about sourcing
```


## update zparseopts
* `-E`? `-F`? none?
* flag_help, flag_verbose, flag_dry_run
* [ ] flag_debug, debug_level, 
* [ ] flag_debug_err -> flag_trap_error
* [ ] flag_debug_exit -> flag_trap_exit
* [ ] check for IS_DEBUG / IS_VERBOSE / IS_DRY_RUN
* [ ] export flag_debug / flag_verbose / IS_DRY_RUN










## slog_* functions
* if the function name contains `*'_se'*` - that function writes to stderr
* if the function name contains `*'_d'` - that function will no-op unless `IS_DEBUG` is set (which is tied to the `--debug` / `flag_debug` and typically set in the zparseopts section)
* if the function name contains `*'_v'` - that function will no-op unless `IS_VERBOSE` is set (which is tied to the `--debug` / `flag_debug` and typically set in the zparseopts section)



## `--dry-run`

In the zparseopts instructions, we add `--dry-run` flag. This sectino discusses the implementation of a dry run mode. 

When this mode is set, we need special handling around any shell commands that write data to disk, affect the shell environment, deletes data, etc...

Instead of executing those commands we shoudl instead print that command to stderr for the user to read and to benefit from  decorated with `--code` `--default`

Do not execute the command twice, rather store the command in a variable, then use that variable for both logging the command and executing it. 

`command_output=$(eval "$command_string")`. Consider writing a helper function for this (which we reuse by moving to `.zsh_scripting_utils` or similar)

# Flow / Step convention



# step

Logging and error handling around an atomic piece of work (typically calling a function or running a command)


## inputs
* the "command" to execute. 
  * This can be anything that is legal in an `if <command>; then <action>; fi` statemement (without `[]` or `[[]]`) 
    * including `<command>`, `my_var=$(<command>)`, `my_var=$(<command> 2>/dev/null)`, etc.
* how to handle errors:
  * fatal (default unless otherwise mentioned or implied via code)
    * The code after this step cannot be executed because of some dependency on this step
    * Log error/rval then exit/return non-0 (base on if script or function)
  * as warning:
    * failure is okay on this step (we will continue to the next step)
    * log error/rval as a WARNING, then continue to the next step

## Action
Peform the command with error handling. That error handling will depend on how we want to handle an error:
* fatal: use the syntax: `command || { # err handler}` sytnax (not `if/fi`) (examples below)
* treat as warning: use the syntax: `if command; then <a>; else <b>; fi` sytnax (examples below)

## logging
Using variants of `slog_step_se_d` log:
* what this step will attemmpt
* the outcome of the the command (Depends on outcome)
  * success
  * error (treate as warning and continue)
  * error (treat as fatal)

### log decorating
* The message should include the `command` using  decorations `--code` and `--default` in the will step at least
* Depending on outcome:
  * error (treate as warning and continue): 
    * collect the exit status (aka rval)
    * log as `slog_step_se --context warning --exit-code rval <message>`
  * error (treat as fatal)
    * collect the exit status (aka rval)
    * log as `slog_step_se --context fatal --exit-code rval <message>`
    * exit $rval / return $rval
  * success
    * log as `slog_step_se --context success --exit-code rval <message>`
## Examples

Example step where error is handled as fatal
```zsh
# [instructions] "step" will
slog_step_se --context will "convert jira_ticket (" --code "$jira_ticket" --default ") to URL format"
jira_ticket_url=$(jira_ticket_to_url $jira_ticket) || {
  rval=$?
  # [instructions] "step" outcome (error, handle as fatal)
  slog_step_se --context fatal --rval "$rval" "convert jira_ticket (" --code "$jira_ticket" --default ") to URL format"
  exit $rval
}
# [instructions] debug log variable assignment
slog_var_se_d "jira_ticket_url" "$jira_ticket_url" 
# [instructions] "step" outcome (success)
slog_step_se --context success "Converted jira_ticket: " --code "$jira_ticket" --default " to URL: " --url "$jira_ticket_url" --default
```

Example step where error is handled as warning
```zsh
# [instructions] "step" will
slog_step_se --context will "convert jira_ticket (" --code "$jira_ticket" --default ") to URL format"

# [instructions] use if/else/fi because we are handling error as warning
if ! jira_ticket_url=$(jira_ticket_to_url $jira_ticket); then
  # [instructions] "step" outcome (error, handle as warning)
  slog_step_se --context warning "Failed to convert jira_ticket: " --code "$jira_ticket" --default " to URL format"
else
  # [instructions] debug log variable assignment
  slog_var_se_d "jira_ticket_url" "$jira_ticket_url" 
  # [instructions] "step" outcome (success)
  slog_step_se --context success "Converted jira_ticket: " --code "$jira_ticket" --default " to URL: " --url "$jira_ticket_url" --default
fi
```

# flow

A flow is a themed sequence of steps. 


```zsh
message_base="fetch content from server"
slog_step_se
```



* if script name or function contains `_step`", that indicates it contains a "step" as defined above
* if script name or function contains `_flow`", then it indicates a "flow" as defined above



## Error vs Warning
Please add this statement to `.github/instructions/zsh-conventions.instructions.md`: When I mention the term "error" or "fatal" that means to log about it at error level then abort (exit non-zero). "warning" means log a warning to stdout then continue. 

<!-- ```text
I'd like to refine the AI instructions for zsh scripts (those which are applied go zsh scripts regardless of directory path)
* Please read `.github/instructions/zsh-conventions.instructions.md` in full. 
* Prompt me for topics to refine and we'll work through them one topic at at a time. 
* At the end I'd like to export those intructions for use in another repository. 
```


* When AI agent runs commands in the terminal, beware of programs that output with a `pager` app. EX: `gh repo view --json owner --jq '.owner.login'` outputs data to `less`. The problme is that ai agent doesn't seem to realize this and then sits there waiting for the human to intervene. One way to work around this is to pipe the output to `cat`. EX: `gh repo view --json owner --jq '.owner.login' | cat`. 

Update ai instructions to 
* Be aware of commands that write to a pager instead of stdout. EX: many `gh` subcommands do this
* When using one of those commands, pipe the output to `cat`

* When writing zsh scripts, specifially when declaring variables, ensure that qualifier works match the context: For example, it's been pretty common for agent generated code to use `local` for vars in the in script main body. This ends up causing bugs, then the agent tries to debug it (wasting resources). Here are a few related points:
* Don't use the `local` qualifier unless the scope is a function (dont' use `local` in a script's root scope)
* Declare and initialize variables in a compound statement where possible: 
    * bad: `local myvar; myvar=0`. This leads to bugs where `myvar=0` ends up in stdout somehow
    * bad: 
    ```zsh
    local myvar
    # later ...
    myvar=0
    ```
    * good: `local myvar=0`. 


* Avoid using `tab` characters. Instead prefer 2 space characters for a tabstop`. One exception might be for here-doc, but most can be done with spaces instead. 


* When naming variables and functions, avoid using reserved keywords from zsh man pages. Two examples that have cause big distractions are: `path` `command` 
  * consult the zsh man pages for 
    * reserved keywords
    * function names
    * variable names

* when adding functions to a script, prefer named arguments vs postional arguments (using zparseopts) 


* working with arrays and multiline strings use zsh expansion's (f) and (F)


## AI Agents and `pager`
AI Agents frequently execute shell commands in the IDE's terminal. Fairly often I will find that the agent is stuck because a command that is has issued writes data using a [pager](https://en.wikipedia.org/wiki/Terminal_pager) without realizing it. This really makes a dent in progress. 
Some examples are:
  * EX: gh, `git diff`, use `| cat` to avoid opening a pager when runing commands

* don't use slog_info_se for menus, script output, etc.. only for logging type tasks. 
* avoid iterating arrays where zsh expansion can be used instead. EX: Prepending "* " to each eleement. 


* In cases where iterating over an array is necessary, alway prefer using c style loops where an index is based off of the array size. This can be useful for logging during the iteration
```zsh
# bad: no index 
for ((i=0; i<="${#lines[@]}"; i++)); do
  slog_se_d "  \${lines[$i]}: ${lines[$i]}"
done

# Good: c-style loop based off of index. Better for logging and debugging
slog_se_d "lines.count: ${#lines[@]}"
for ((i=0; i<="${#lines[@]}"; i++)); do
  line="${lines[$i]:-}"
  if [[ -z "$line" ]]; then continue; fi
  slog_se_d "  \${lines[$i]}: $line"
done
``` -->

* [ ] Add `setopt interactivecomments` to ~/.zshrc
  * [ ] This seems like it's not stick when entered into the terinal
* [ ] Tests for scripts. Where? Testing standards?
  * Bats looks pretty interesting. shUnit2 maybe?
* [ ] docstrings
* [ ] `function <name>` vs `<name>()` vs `function name()`
* [ ] code documentation conventions, libraries, etc... Like quickhelp or python's 



* [ ] `print_usage`
  * formatting: `--help` vs `man`
    * SYNOPSIS style
  * ansi vs none
  * contexts:
    * script header comment
    * --help
    * man page
    * script code itself
  * formatting
    * are there names for there, or rule sets? 
    * Should I collect my favs instead?
    * Dirs for mined examples (miner script, cman, etc...)
  * Source of truth
    * how to keep a source of truth here and derive the others from it?










oh, add a `--dry-run` flag. If set then instead of issueing any write/delete commands, instead print that command decorated with `--code` `--default`

Do not execute the command twice, rather store the command in a variable, then use that variable for both logging the command and executing it. 

`command_output=$(eval "$command_string")`. Consider writing a helper function for this 