# ZSH_FOR_SWIFT_PROGRAMMERS

## Proposed document

- Title: **Swift Engineer’s Quick Start to Zsh Scripting**
- Audience: experienced Swift engineers new to shell scripting
- Style: chaptered, copy-paste examples, GitHub footnotes, “pitfall vs preferred pattern”

## Proposed chapter outline

1. **Why Zsh Feels Different from Swift**
   - Runtime model (interpreted shell vs compiled app)
   - Process model, environment, exit codes
   - What “global by default” means in sourced scripts

2. **Mental Model Bridge: Swift → Zsh**
   - `let`/`var` vs `typeset`/`local`
   - optionals vs `${var:-default}`
   - throwing/result vs exit status + `|| { ... }`
   - collections: arrays/dicts in Zsh (`-a`, `-A`)

3. **Bootstrapping in This Repo**
   - required preamble + shellcheck directives
   - sourcing `.zsh_boilerplate`
   - what bootstrap gives you (flags, logging, utilities, env state)
   - why scripts should avoid duplicating bootstrap logic

4. **Critical `source` Semantics (with args)**
   - `source file "$0" "$@"` and temporary positional parameters
   - impact on `zparseopts -D` behavior
   - when parser changes do/do not persist in caller scope
   - safe patterns for wrapper variables

5. **Variable Conventions and Safety**
   - declare everything explicitly
   - `local` only in functions, `typeset` at root scope
   - readonly-by-default policy (and when not to)
   - parser/shared variable redeclaration pitfall (`flag_*`, `opt_*`)
   - naming to avoid collisions in sourced ecosystems

6. **Function Conventions**
   - naming/namespace patterns (script vs library)
   - function docs format (SYNOPSIS/ARGS/EXIT STATUS)
   - named args with `zparseopts` vs positional args

7. **Argument Parsing Patterns**
   - script-specific parsing after bootstrap
   - extracting values correctly from `zparseopts` arrays
   - help behavior and usage contract

8. **`.zsh_logging_utilities` Deep Dive (Core Logging Chapter)**
    - recursive source map used by this library:
       - `source_once "${0:A:h}/.zsh_scripting_core" "$0" "$@"`
       - `source_once "${0:A:h}/.zsh_core_utilities_umbrella" "$0" "$@"`
       - umbrella transitives: `core_utilities/.zsh_source_utilities`, `core_utilities/.zsh_array_utilities`
    - `_slog` as single sink and normalizer:
       - parses logging/meta flags (`--debug`, `--callstack`, `--echo-{e,E,n,N}`)
       - splits args into retained/plain-text args vs ANSI/decorator args
       - translates risky passthrough flags for `echo_pretty` (hyphen→en-dash for select args)
    - output routing model:
       - writes plain text when stdout/stderr is non-TTY
       - falls back to `echo` when `echo_pretty` is unavailable
       - uses `echo_pretty` when available for ANSI-rich output
    - wrapper family and `$@` forwarding contract:
       - base wrappers: `slog`, `slog_d`, `slog_se`, `slog_se_d`, `slog_se_ud`, `slog_v`, `slog_se_v`
       - step/context wrappers: `slog_step_se`, `slog_{success,error,warning,info,debug,trace,critical}_se`
       - all wrappers preserve argument order and forward `"$@"` toward `_slog`
    - variable introspection chapter section:
       - compare `slog_var`/`slog_var_se` with reflective `slog_var1_se`
       - show scalar vs array vs associative-array rendering behavior
       - include debug-only variants (`*_d`) and when to prefer each
    - call stack/source diagnostics section:
       - `---callstack` path from wrappers into `_slog` → `slog_callstack_se`
       - shape of `funcstack`, `funcfiletrace`, `funcsourcetrace`, `functrace` output
       - `slog_source_location_se` for file:line + function context
    - Swift bridge integrations:
       - `echo_pretty` as ANSI renderer (Shell-friendly UX, optional debug/meta behavior)
       - `hatch_log` forwarding status: currently commented in `_slog`; active usage remains in `slog_cron`
       - include future section: using `log stream` predicates for subsystem/category verification
    - caveats and known edges to teach explicitly:
       - recursion hazards when logging helpers call helpers that also log
       - parser-variable reuse and scope leakage in sourced contexts
       - duplicated/legacy helpers and migration path toward fewer logging entry points

9. **Error Handling: Swift `throws` vs Zsh Exit Status**
    - conceptual bridge: Swift `throw`/`Result` vs Zsh command status + `$?`
    - strict-mode options and tradeoffs:
       - `setopt errexit nounset pipefail`
       - where `errexit` surprises happen (conditionals, subshells, pipelines)
    - control-flow patterns to standardize across scripts:
       - command chaining with `&&` and `||`
       - direct command tests: `if <cmd>; then ... fi`
       - inverted command tests: `if ! <cmd>; then ... fi`
       - guard blocks: `<cmd> || { ...; return <code>; }`
    - capturing and propagating failures:
       - immediate capture (`local rval="$?"`) before additional commands
       - choosing between `return`, `exit`, and continuing with degraded behavior
    - operational error messaging with logging helpers:
       - `slog_step_se --context will|did|error|warning|critical`
       - composing "will → run → did/error" patterns for readable failure paths
       - where to use `slog_error_se` vs `slog_critical_se`
    - trap-driven diagnostics and cleanup:
       - `trap` hooks for `ERR`, `EXIT`, and signal handling
       - pairing traps with `slog_*` wrappers for consistent failure output
    - stack introspection and deep diagnostics:
       - `---callstack` flow to `slog_callstack_se`
       - underlying arrays/vars: `funcstack`, `funcfiletrace`, `funcsourcetrace`, `functrace`
       - when to use `slog_source_location_se` for file:line context
    - source tracing and import-debug workflow:
       - `zsh -o sourcetrace` to visualize source order
       - combining sourcetrace with callstack logs when sourced libs mask origin

10. **Zsh Expansion Essentials (Swift dev cheat sheet)**
   - path ops (`:h`, `:t`, `:r`, `:e`, `:A`)
   - `(f)` / `(F)` and array transformations
   - avoid external commands when native expansion exists

11. **Common Pitfalls for Swift Teams**
   - quoting and word splitting
   - `set -euo pipefail` surprises
   - subshell side effects
   - pager traps in CLI commands
   - mutable shared state from sourced libs

12. **Debugging in Zsh (Swift Breakpoint Mindset)**
   - what replaces breakpoints: trace logs, `set -x`, selective xtrace
   - stack/context tools: `funcstack`, callstack helpers, trap diagnostics
   - debugging with sourced libraries and positional-parameter pitfalls
   - `zshdb`: capabilities, limitations, and when it is still useful
   - practical debug workflow for this repo (`--debug`, `--verbose`, trap flags)

13. **Testing and Linting Workflow**
   - shellcheck usage and expected directives
   - minimal validation checklist before PR

14. **Quick Reference Appendices**
   - “Do this / not that” table
   - Swift-to-Zsh pattern lookup table
   - starter script templates (script and library forms)

## Reference strategy (for the final doc)

- Use GitHub footnotes (`[^1]`, `[^2]`, …)
- Cite both internal standards and external canonical docs
- For internal citations, reference section names in:
  - `instructions/zsh/zsh-conventions.instructions.md`
  - `instructions/zsh/zsh-compatibility-notes.instructions.md`
- For external citations, prefer Zsh official docs + ShellCheck manual pages
