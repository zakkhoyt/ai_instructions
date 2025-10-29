
# 
`"Re-read .github/instructions/setup-scripts.instructions.md, then apply ALL requirements"`
`"Re-read .github/instructions/zsh-conventions.instructions.md, then apply ALL requirements"`




# zsh


* rather using tail / head, redire4ct stdout / stderr ot a file
* when logging values, wrap them in single quotes (unless empty)
* when logging values, if value is nil, represent it with `<nil>` (without single quotes)


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

## Flow / Step convention


* [ ] `step` - wrapper around a shell command
  * [ ] will
    * [ ] error
    * [ ] warning
  * [ ] did
* [ ] `flow` - A sequential chain of `step` operations
  * [ ] will
    * [ ] error
    * [ ] warning
  * [ ] success


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