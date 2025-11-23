


# configure_ai_instructions.zsh

## `.ai` workspace folder ordering
* when `scripts/configure_ai_instructions.zsh --dev-vscode` a folder is added to the vscode workspace. That seems to be working okay, however I want that file to be the **first** in the array so that it appears first in the IDE (at the top)

## Modify .vscode-workspace settings
* when `--dev-vscode` is passed we add `$HOME/.ai` to the workspace as a folder, but still need to
* [ ] autoapproval for workspace settings: Find the workspace settings file (EX: `HatchTerminal.code-workspace`), then insert/overwrite some settings json to allow auto approval
* [ ] autoapproval for user settings: Find the workspace settings file (EX: `HatchTerminal.code-workspace`), then insert/overwrite some settings json to allow auto approval
* [ ] autoapproval for folder level? settings: Find the workspace settings file (EX: `HatchTerminal.code-workspace`), then insert/overwrite some settings json to allow auto approval


> [!NOTE]
> A list of commands or regular expressions that control whether the run in terminal tool commands require explicit approval. These will be matched against the start of a command. A regular expression can be provided by wrapping the string in / characters followed by optional flags such as i for case-insensitivity.
> 
> Set to true to automatically approve commands, false to always require explicit approval or null to unset the value.
> 
> Note that these commands and regular expressions are evaluated for every sub-command within the full command line, so foo && bar for example will need both foo and bar to match a true entry and must not match a false entry in order to auto approve. Inline commands such as <(foo) (process substitution) should also be detected.
> 
> An object can be used to match against the full command line instead of matching sub-commands and inline commands, for example { approve: false, matchCommandLine: true }. In order to be auto approved both the sub-command and command line must not be explicitly denied, then either all sub-commands or command line needs to be approved.
> 
> Note that there's a default set of rules to allow and also deny commands. Consider setting #chat.tools.terminal.ignoreDefaultAutoApproveRules# to true to ignore all default rules to ensure there are no conflicts with your own rules. Do this at your own risk, the default denial rules are designed to protect you against running dangerous commands.
> 
> Examples:
> | Value                                                     | Description                                                                              |
> | --------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
> | `"mkdir": true`                                           | Allow all commands starting with mkdir                                                   |
> | `"npm run build": true`                                   | Allow all commands starting with npm run build                                           |
> | `"bin/test.sh": true`                                     | Allow all commands that match the path `bin/test.sh` (`bin\test.sh`, `./bin/test.sh`, etc...)    |
> | `"/^git (status|show\\b.*)$/": true`                      | Allow git status and all commands starting with git show                                 |
> | `"/^Get-ChildItem\\b/i": true`                            | will allow Get-ChildItem commands regardless of casing                                   |
> | `"/.*/": true`                                            | Allow all commands (denied commands still require approval)                              |
> | `"rm": false`                                             | Require explicit approval for all commands starting with rm                              |
> | `"/\\.ps1/i": { approve: false, matchCommandLine: true }` | Require explicit approval for any command line that contains ".ps1" regardless of casing |
> | `"rm": null`                                              | Unset the default false value for rm                                                     |








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


