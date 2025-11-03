



#  Build a slog_ function that can print any kind of variable in a number of different styles. 



* [ ]  Document existing 

## Existing Functions
Currently we have several individual functions to log variable details


### `slog_var_se "my_var" "$my_var"`
* works on primitive types only (string, int, bool), but not collections
* bad: requires passing the name and the value


### `slog_var1_se "my_var"`
* works on primitive types (string, int, bool), but not collections
* works by passing the name, but should instead leverage zsh expansion `(P)`


### `slog_array_se "my_array" "${my_array[@]}"`
* works on standard arrays (not associated)
* bad: requires passing the 2 args (name and the value(s))
* bad: only works on arrays (not associated arrays)




###  `slog_var1_se` 
* `slog_var1_se` - Help my update this function to support more variable types

Currently we have several individual functions to log variable details
```zsh
# works on primitive types (string, int, bool), but not collections
# bad: requires passing the name and the value
slog_var_se "my_var" "$my_var"

# works on standard arrays
# bad: requires passing the 2 args (name and the value(s))
# bad: only works on arrays (not associated arrays)
slog_array_se "my_array" "${my_array[@]}"
```

* when logging values, wrap them in single quotes (unless empty)
* when logging values, if value is nil, represent it with `<nil>` (without single quotes)






---

<!-- TODO: zakkhoyt AI P0 - consolidate serveral functions into _slog 
-->

> [!NOTE]
> * [ ] build slog_callstack_se into _slog via args or environment var so that any log function can make use
> * [ ] build slog_marker_se into _slog via args or environment var so that any log function can make use
> * [ ] _slog should be aware of the output. If tty, use as is. Otherwise strip out the echo_pretty args
>   * This way we can write to log files withouth the ANSI noise, etc...
>   * farm these args periodically?


# * [ ] build slog_callstack_se into _slog via args or environment var so that any log function can make use
# * [ ] build slog_marker_se into _slog via args or environment var so that any log function can make use
# * [ ] _slog should be aware of the output. If tty, use as is. Otherwise strip out the echo_pretty args
#   * This way we can write to log files withouth the ANSI noise, etc...
#   * farm these args periodically?
# 
# routes $@ to appropriate tools while filtering $@  (echo vs echo_pretty, then hatch_log (disabled currenlyt))
_slog

# basic logging function flavors
slog
slog_d
slog_se
slog_se_d
slog_se_ud
slog_v
slog_se_v

# "Step" and "flow" functions
* p []
slog_step_se
slog_step_se_d
slog_step_se_v
# slog_step_se wrappers (mainly for legacy)
slog_success_se
slog_success_se_d
slog_success_se_v
slog_error_se
slog_error_se_d
slog_error_se_v
slog_warning_se
slog_warning_se_d
slog_warning_se_v
slog_info_se
slog_info_se_d
slog_info_se_v
slog_debug_se
slog_debug_se_d
slog_debug_se_v
slog_trace_se
slog_trace_se_d
slog_trace_se_v

# similar to siblings, but exit 111
slog_critical_se
slog_critical_se_d
slog_critical_se_v
slog_critical 

slog_deprecated_se
slog_deprecated
deprecated



# * [ ] unifed var logging

# log vars by passing name, value
slog_var
slog_var_se
slog_var_se_d
# log vars by passing name only
# ! Generates shellcheck warnings
slog_var1_se
slog_var1_se_d

# log arrays in various ways
# Indented / flat
# ordered / unordered
# format (json, markdown, etc..)
# * [ ] # allow ANSI formatting via args
slog_array_se
slog_array_se_d
slog_array_se_ud
slog_list


# * [ ] solid "marker", "sign", "ad", "bannder"
#  * support emoji
#  * support color
# Logs message ($*) with colorful full width "ads"
slog_event_se

# Logs a marker line with a message centered within it
slog_marker_se


# Debugging 
slog_callstack_se
slog_source_location_se



slog_cron

# prints some tips for working with the `log` cli tool on macOS (syntax helper)
hatch_log_help

# Adds decorative prefix/postfix to each elemnt in $@
decorate_lines
