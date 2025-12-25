
# Notes 
## ANSI keyboard listener




----

# Homebrew
* [ ] setup `zakkhoyt/tap`
* [ ] write a `ruby-conventions-instruction.md`, add to ~/.ai
# EchoPretty
* updated `--help`
* man page
* completion scripts
* publish on homebrew
* precompiled release



# VSCode Snippets
* [ ] `[markdown]` gh alerts (picker)
* [ ] `[markdown]` admonitions (picker)
* [ ] `[markdown]` code fence language (picker)
* [ ] `[markdown]` <details> plain 
  * [ ] [`open`]
  * [ ] [`summary.element`]
* [ ] `[markdown]` <details> group
  * [ ] [details.name]





# AI 


## vscode auto approve cases

These images capture some persistent cases where I'm still being prompted to allow certain terminal commands

Let's take a look at how we can modify the settings files under `vscode/user` and `vscode/workspace` to do better

* `docs/todo/images/Code_20251123232614.png`
* `docs/todo/images/Code_20251225155003.png`
* `docs/todo/images/Code_20251225155008.png`
* `docs/todo/images/Visual Studio Code_20251210002318.png`
* `docs/todo/images/Visual Studio Code_20251210010829.png`
* `docs/todo/images/Visual Studio Code_20251210010921.png`
* `docs/todo/images/Visual Studio Code_20251210011125.png`
* `docs/todo/images/Visual Studio Code_20251210011218.png`
* `docs/todo/images/vscode_ai_agent_prompt_00.png`
* `docs/todo/images/vscode_ai_agent_prompt_01.png`
* `docs/todo/images/vscode_ai_agent_prompt_02.png`

## Script


### Rework instructions menu

I think i'd like to change how this menu works. Right now there is no way to uninstalled or change from copy to link, etc...

What if we could instead, enter a letter for each position?

Maybe it's time to build that ANSI menu system with keyboard listeners

```zsh
 1. [ ] agent-chat-response-conventions.instructions.md
 2. [S] 🔗 agent-swift-terminal-conventions.instructions.md
 3. [S] 🔗 agent-terminal-conventions.instructions.md
 4. [S] 🔗 git-branching.instructions.md
 5. [S] 🔗 markdown-conventions.instructions.md
 6. [S] 🔗 python-conventions.instructions.md
 7. [S] 🔗 swift-conventions.instructions.md
 8. [S] 🔗 userscript-conventions.instructions.md
 9. [ ] zsh-compatibility-notes.instructions.md
10. [S] 🔗 zsh-conventions.instructions.md
Status Legend:
  [ ]       Not installed
  [S] 🔗     Symlinked (current)
  [C] 📄     Copied (current)
  [O] ⏳     Copied (outdated)
  [M] ✏️    Copied (modified)
  [U] ❔     Copied (unknown)
  [?] ⚠️    Wrong symlink target
Default selection (press Enter to accept):
  2 3 4 5 6 7 8 10
Type a new selection or press Enter to use the default shown above:
```


### Rework Args
* There are several parts of the arguments thats aren't working
* Other args seem like they are related but have different names
* Too much deprecation

Keep these as is (from `.zsh_boilerplate`). BTW these are the only things that sould be in the "meta" script options
The rest belog in the OPTIONS section
```zsh
META OPTIONS
    --help                  Display this help message and exit
    --dry-run               Show what would be done without making changes
    --debug                 x1 = Enable debug logging. x2 = exit trap. x3 = error trap. x4 = callstack logging
    --trap-error
    --trap-exit
```



```zsh
zsh code
```

### Instructions Not Working
* `--instructions` | `--instructions --prompt`
* `--instructions --prompt`


### VSCode fuctions too complicated in the args
* Add the `~/.ai` folder to `*.code-workspace` file,
  * if `*.code-workspace` can't be autolocated, then:
    * if `--prompt` is present, prompt the user for the path
    * else error + details
    * 
<!-- * `--vscode-settings <user>` 
* `--vscode-settings <workspace>` - Infer workspace. Error if not possible 
* `--vscode-settings <workspace> --prompt` - Infer workspace, prompt if needed
* [ ] `--vscode-settings <folder>` Which folder? 
* `--vscode-settings <folder> --prompt` Prompt user to pick a folder -->

## VSCode Settings
* Sort out script + instructions install
* Sort out script + vscode settings "install" / "merge"
* Sort out 
* 