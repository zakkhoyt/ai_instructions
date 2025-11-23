
## Other command line considerations that the AI Agent should take

### Always store outputs to log files
When executing long running commands, or commands with long stdout/stderr there are 2 things that I ask:
1.) ALWAYS ALWAYS ALWAYS save the output(s) to file(s). Stdout to one, stderr to another. Or compine them before writing to a file. I don't have a preference. 
    * the reason is I often see AI agents do this:
```zsh
some_long_running_command | tail -n 20 | grep "ERROR"
# Whoops, grep came up empty. 
# Then the AI Agent runs the long runing command again with a slightly different filter
some_long_running_command | tail -n 30 | grep "ERROR\|error"
```
This is such a huge waste of time. Intead save the FULL output to a temp file which can be read multiple times
```zsh
log_file=".gitignored/build/some_long_running_command_$timestamp.log"
some_long_running_command > "$log_file" 2>&1 
tail "$log_file" -n 20 | grep "ERROR"
# Applying a new filter is much faster
tail "$log_file" -n 30 | grep "ERROR\|error"
```
2) When AI Agent directly filter output, I (the human) cannot see/read what's going on in real time. I often have info that will save us both much much time. But if I can't understand the situation in real time, things are going to take us both a lot longer
```zsh
# Commands like this keep the human from understanding what's happening in real time. 
some_long_running_command | tail -n 20 | grep "ERROR"
```

I dont' have the perfect solution here, but if AI agent would use an app like `tee` where stdout/stderr still render to the the terminal in real time, 
but `tee` (tee like app) creates a duplicate stream that the agent can then filter in realtime. 
```zsh
# something along the lines of this (def pseudocode)
some_long_running_command | tee_app 1>&3 2>&4 | tail -n 20 | grep "ERROR"
```









# when sourcing config files, how can we check if it's arleady been sourced then avoid sourcing again?
* will this have impacts from cli: `source ~/.zshrc`. Can we override the check? arguent? Can we zparseopts? --force-source

# update _slog to hanle many things
* detect if output / tty, stipping ANSI related args if not (allowing us to pipe to log files for examples)
* update to take args like `--callstack`
  * `--callstack`
  * `--context <context>`
  * `--rval <rval>` | `--exit-code <code>` | `--return-code <code>`
  * Build a list of other args from TODOs in .zsh_logging_utils


# ripgrep is installed and available and can be much more performant than grep. 

# .aiignore / .aiignored


# Use homebrew to install runtime tools to make things efficient


* how to auto allow things like pipes, $(...), {...}, for loops, etc...
EX: IT treats this grep special asks to allow `cancel|timeout|timed out`
```zsh
grep -iE "(cancel|timeout|timed out)" scripts/.gitignored/github_runner/_diag/Worker_20241104*.log | grep -v "CancellationToken" | head -20
```



# How to configure vscode's ai agent to auto-approve EVERY terminal command. 

I'm trying to set up Visual Studio Code's AI chat agent so that it doesn't need to ask me for approval, ever, when running commands in the terminal. 

Despite setting up both `user` and `workspace` settings to autoapprove like this
```zsh
"chat.tools.terminal.autoApprove": {
    "/.*/": {
        "approve": true,
        "matchCommandLine": true
    },
    "*": {
        "approve": true,
        "matchCommandLine": true
    },
}
```

it continues to prompt me if the command has:

* any pipes (` | `)
* any parentises, braces, or curly braces
* This include for loops, do, while, et...

![alt text](images/vscode_ai_agent_prompt_02.png) 
![alt text](images/vscode_ai_agent_prompt_01.png) 
![alt text](images/vscode_ai_agent_prompt_00.png)

Here are is the VScode user and workspace settings

![alt text](images/vscode_ai_workspace_settings.png) 
![alt text](images/vscode_ai_user_settings.png) 





# How to cconfigure copilot to see what it's thinkign in real time?




# Avoid filtering output. Instead use Tee
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"

or zome other approach where i can watch the output live
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"