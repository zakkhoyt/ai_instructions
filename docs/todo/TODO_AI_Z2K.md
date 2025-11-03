


# Add comments


# When running terminal commands

* rather using tail / head, redire4ct stdout / stderr ot a file


# Exiting project where AI can help

## jira_notes
* [ ] run from any dir under the repo, not just root or iOS dir
* [ ] --mode notes


## LGTV "driver"
* [ ] LGTV websockets connection. Always wanted to convert that lua script to Swift and then add a system tray application, and all the things Swift code can unlock

## MIDI LUT
* [ ] alesis to UHD LUT (javascript)
* [ ] alesis to GM LUT (javascript)



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







# Copilot Usage
* [X] ~~*Enable Copilot Metrics API*~~ [2025-10-24]
* [CURL: Copilot Metrics API](https://docs.github.com/en/rest/copilot/copilot-metrics?apiVersion=2022-11-28) 

