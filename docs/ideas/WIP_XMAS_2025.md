
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


## Script

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