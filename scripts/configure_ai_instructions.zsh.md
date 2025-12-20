
SYNOPSIS
    configure_ai_instructions.zsh [OPTIONS]

DESCRIPTION
    Configure AI instructions for various platforms by copying or symlinking
    instruction files from a central source to target project directories.

OPTIONS
    --source-dir <dir>      User AI directory containing source instructions
                           (default: $Z2K_AI_DIR or $HOME/.ai)
    
    --dest-dir <dir>      Target directory to configure (must be git repo root)
                           (default: current working directory)
    
    --ai-platform <platform>
                           AI platform to configure for
                           Options: copilot, claude, cursor, coderabbit
                           (default: copilot)
    
    --configure-type <type> How to install instructions
                           Options: copy, symlink
                           (default: symlink)

META OPTIONS
    --help                  Display this help message and exit
    --debug                 Enable debug logging
    --dry-run               Show what would be done without making changes
    --regenerate-main       Force regeneration of main instruction file from template
                           (WARNING: This will overwrite any custom edits)
    --dev-link              Create symlink to AI dev directory and update .gitignore
                           (useful for quick access to repo files during development)
    --dev-vscode            Add AI dev directory to VS Code workspace
                           (enables IDE integration for development repo)
    --vscode-settings       Deprecated alias for --workspace-settings
    --workspace-settings    Launch menu to merge VS Code workspace templates
                 - Supports *.code-workspace templates plus .vscode/*.json fragments
                 - Honors optional ordering/topic prefixes (e.g., 01__template)
                 - Creates backups before applying jq-based JSON merges
    --user-settings         Launch menu to merge VS Code user settings templates
                 - Applies files under vscode/user → $HOME/Library/Application Support/Code/User
                 - Requires confirmation via interactive menu to avoid surprises
    --mcp-xcode             Install Xcode MCP server configuration and Swift workspace settings
                           - Auto-detects Package.swift / *.xcworkspace / *.xcodeproj under target
                           - Use with --prompt to interactively confirm installation
                           - Without --prompt, shows what would be installed but doesn't prompt
                           MCP Template: vscode/mcp/xcode-mcpserver-workspace-mcp.json → .vscode/mcp.json
                           Swift Template: vscode/swift-workspace-settings.template.json → workspace settings
    --instructions          Auto-install all applicable instruction files
                           - Skips instructions that are already installed
                           - Use with --prompt to show interactive menu for file selection
                           - Without --prompt, installs all uninstalled files automatically
    --prompt                Enable interactive prompts for installations
                           - When set: shows interactive menus for confirmation/selection
                           - When not set: shows info about what's available but doesn't prompt
                           - 

# CLI Not behaving properly

## --instructions --prompt
### Expect
This should present me with the instrutions menu no matter if any are installed or not. Let the user select what to do interactively
```zsh
$ ~/.ai/scripts/configure_ai_instructions.zsh --instructions --prompt
```
### Actual

I got the Xcode mcp menu? that's supposed ot be behind `--mcp-xcode --prompt`
```zsh
[INFO] ℹ️ Updating source of truth from repository...
[SUCCESS]: ✅ User instructions already up to date (same as repository)
[INFO] ℹ️ Configuring AI instructions for copilot platform
[INFO] ℹ️ Source directory: /Users/zakkhoyt/.ai/instructions
[INFO] ℹ️ Target directory: /Users/zakkhoyt/code/repositories/z2k/github/lgtv-cli/.github/instructions
[INFO] ℹ️ Configuration type: symlink
[INFO] ℹ️ Detected 3 Xcode-related artifact(s) that support the MCP server:
[INFO] ℹ️   - Docs/swift-package-grapher/swift-package-describe/Package.swift
[INFO] ℹ️   - Package.swift
[INFO] ℹ️   - Tests/LGTVWebOSControllerTests/LGTVWebOSControllerTests.swift
[INFO] ℹ️ === Xcode MCP Server Integration ===
[INFO] ℹ️ This installs .vscode/mcp.json (servers) plus Swift workspace settings.
[INFO] ℹ️ Tip: re-run with --mcp-xcode to auto-apply without prompting.
Proceed with installing the Xcode MCP server integration now? [y/N]: 
```
Ansering N just finished the script

```zsh
[INFO] ℹ️ Skipping Xcode MCP server configuration
[SUCCESS]: ✅ All instruction files are already installed and current - skipping
[SUCCESS]: ✅ AI instruction configuration complete!
[INFO] ℹ️ No files were installed
[INFO] ℹ️ Next steps:
  • Instructions will be automatically detected by GitHub Copilot
  • Restart VS Code if needed to ensure instructions are loaded

```


## --instructions

I guess this one worked okay. It found that ther's nothing to do with instructions. I assume if there was an updated to one of the instrution files in the repo it would detect this and install it? It should

### Expect

```zsh
$ ~/.ai/scripts/configure_ai_instructions.zsh --instructions 
```
```zsh
[INFO] ℹ️ Updating source of truth from repository...
[SUCCESS]: ✅ User instructions already up to date (same as repository)
[INFO] ℹ️ Configuring AI instructions for copilot platform
[INFO] ℹ️ Source directory: /Users/zakkhoyt/.ai/instructions
[INFO] ℹ️ Target directory: /Users/zakkhoyt/code/repositories/z2k/github/lgtv-cli/.github/instructions
[INFO] ℹ️ Configuration type: symlink
[INFO] ℹ️ Detected 3 Xcode-related artifact(s) that support the MCP server:
[INFO] ℹ️   - Docs/swift-package-grapher/swift-package-describe/Package.swift
[INFO] ℹ️   - Package.swift
[INFO] ℹ️   - Tests/LGTVWebOSControllerTests/LGTVWebOSControllerTests.swift
[INFO] ℹ️ === Xcode MCP Server Integration ===
[INFO] ℹ️ This installs .vscode/mcp.json (servers) plus Swift workspace settings.
[INFO] ℹ️ To install MCP server, re-run with one of these flags:
[INFO] ℹ️   - Use --mcp-xcode to auto-install without prompting
[INFO] ℹ️   - Use --prompt --mcp-xcode to be prompted for confirmation
[INFO] ℹ️ Skipping Xcode MCP server configuration
[SUCCESS]: ✅ All instruction files are already installed and current - skipping
[SUCCESS]: ✅ AI instruction configuration complete!
[INFO] ℹ️ No files were installed
[INFO] ℹ️ Next steps:
  • Instructions will be automatically detected by GitHub Copilot
  • Restart VS Code if needed to ensure instructions are loaded
```
### Actual

```zsh
```





## <>

### Expect

```zsh
```
### Actual

```zsh
```










* [ ] Add more atlassian__mcp.json
  * [ ] user
  * [ ] workspace
* [ ] clean7
  * [ ] user
  * [ ] workspace


ActionItem: Update `scripts/configure_ai_instructions.zsh`
* context: If `code-workspace` file cannot be auto-discovered (and single result) 
  * [ ] We have env var support, but let's add an explicit argument as well which should take precendence. 
    * Allow multiple like so: `-code-workspace+:=opt_code_workspace_files`
    * Also let's update modify `AI_VSCODE_WORKSPACE_FILE` to support multiple. Rename/retype to `-a AI_VSCODE_WORKSPACE_FILES` 
  * [ ] if zero code-workspace_files are defined via arg or env var, then fall back to autodiscovering
    * [ ] Only look in the dest repo dir (root only). Remove the fall back looking in `$HOME`
    * [ ] if >=1 matches, prompt the user to select which to apply to (multiselect enabled). Default should be the most recenly modified one. Format the menu similar to existing menus
    * [ ] if 0 matches, then prompt the user to enter the path
    * [ ] Apply to all selected, including support for none/empty list (just move on)
* [ ] Add a new flag, `{-no-prompt/-no-ask=flag_no_prompt}`. 
  * [ ] If set, we need to discuss how to handle each prompt. This will be a back and forth convo. 
* [ ] update comments and --help
* [ ] ensure that all files that are modified are first backed up prior to any mutation. 
  * [ ] back them up under `.gitignored/.ai/` (create if needed)
  * [ ] create nested dirs to mirror absolute path of the file. EX: `$repo_root_dir/.gitignored/.ai/Users/zakkhoyt/Library/Application Support/Code/User/settings.json`
  * [ ] leave backup files/dirs in place vs deleting them
  * [ ] when backing up files, allow overwriting the file which is bound to happen pretty quickly
  * [ ] log (--debug) every time a file backup is created. Log the backup file path using --url decoration
    * [ ] also debug log every time a file is mutated which should include the shell command that invokes the python script
      * [ ] use absolute paths
      * [ ] decorate the command using `--code`. 
      * [ ] the filepaths will be included in the command so no need to log them separately
* Let's discuss the args that impact the code-workspace file. 
  * We have `--dev-vscode`
  * We will have `--code-workspace`
  * Any others?
  * Can these be consolidated? Or are they better as separate / complimentary? 
  * Should we rename them to express that they are related?






* [ ] zsh-agent instructions to disable autocorrect / nocorrect
* [ ] Improve debug output to include source file (decorated with --url)





<!-- 
Create a script (./configure_ai_instructions.zsh) to help install these ai instructions to a specific folder for a specific AI service. 

Terms:
* `repo_dir` - this repository's root directory (as cloned on the user's computer)
* `repo_instructions_dir` (`$repo_dir/instructions`) - this repository's directory where instructions are located
* `user_ai_dir` - A user level directory that will contains the "source of truth"
* `user_ai_instructions_dir` - a sub dir of `user_ai_dir` where the instructions are kept (`$user_ai_dir/instructions`)
* `dest_dir` - the directory to configure AI instructions for.
* `<AI TODO>` - TODO task for AI agent to look up details on the internet


Args:
* --source-dir <dir>: (let's call this var `user_ai_dir`). 
  * If not passed as arg, check environment variable `Z2K_AI_DIR` before defaulting to `$HOME/.ai`

* --dest-dir <path> : (let's call this var `dest_dir`) Specify the directory to configure AI instructions for.
  * default: PWD
  * this must also be a root directory of a git repository. 
  * Ask git for the root dir then compare
    * log a warning if no git repository is found
    * log a warning if dest_dir != git_root_dir
* --ai-platform <platform> : (let's call this var `ai_platform`) Specify the AI platform to configure instructions for.
  * valid options: 
    "copilot" aka "github-copilot", "github"
    "claude"
    "cursor"
    "coderabbit"
  * default: "copilot"
* --configure-type <copy | symlink> : (let's call this var `configure_type`) Specify whether to copy or symlink the instructions.
  * valid options: "copy", "symlink"
  * default: "symlink"

# Prepare
* init var `target_instructions_dir` from ai_platform
  * copilot: "$dest_dir/.github/instructions"
  * claude: "$dest_dir/.claude/settings.json"
  * cursor: "$dest_dir/.cursor/rules/mobile.mdc"
  * coderabbit: <AI TODO>

* init var `ai_platform_instruction_file` from ai_platform
  * copilot: "$dest_dir/.github/copilot-instructions.md"
  * claude: "$dest_dir/.claude/settings.json"
  * cursor: "$dest_dir/.cursor/rules/mobile.mdc"
  * coderabbit: <AI TODO>

* init var `ai_instruction_settings_file` from ai_platform
  * copilot: "$ai_platform_instruction_file"
  * cursor: "$ai_platform_instruction_file"
  * claude: "$dest_dir/CLAUDE.md"
  * coderabbit: <AI TODO>
  


* create `$user_ai_instructions_dir` if needed
* Force copy this repository to `$user_ai_instructions_dir`  which will serve as the source of truth

* create `$target_instructions_dir` if needed
* read the contents of `$target_instructions_dir`. We will need a ways to compare existing instructions to those in `$repo_dir/instructions` to denote if they the source instructions have been updated since last linked. git diff? checksum?

* Present a menu to the user to select which instructions to "configure"
  * this menu should list reflect all files in `$user_ai_instructions_dir`
  * The menu should visually indicate which instructions are already installed in the target directory.
  * If configure_type == "copy", then the menu will need to indicate (for installed instructions) whether the source file has been updated since last copy.
  * the contents of the menu should be dynamically generated by listing all files in `$user_ai_instructions_dir`
  * The menu should visually indicate which instructions are already installed, but where the source file has been updated since last copy (if configure_type == "copy")

* For each selected instruction, "install" the file according to `configure_type`
    * if `configure_type` == "symlink", then create a symlink from `$user_ai_instructions_dir/<file>` to `$target_instructions_dir/<file>`
    * if `configure_type` == "copy", then copy the file from `$user_ai_instructions_dir/<file>` to `$target_instructions_dir/<file>` -->

---
<!-- 
# TODO / Additions

## Support development of this repo along side the target repo
* add a new cli flag: `--link-to-ai-dir`
* if set, then create a symlink to `$user_ai_dir` in `$dest_dir1`
```zsh
# I think this is the correct command
ln -s $user_ai_dir $dest_dir1
```
  

* [X] ~~*if `$dest_dir1` contains a vscode-workspace file, modify it as if we had the VSCOde IDE open and "add folder to workspace"*~~ [2025-11-02]
* [X] ~~*if `$dest_dir1` contains a .gitignore file, modify it to ignore the symlink created ^*~~ [2025-11-02]
* [ ] The above turns out to be redundant so let's break ^ into two args
1. --dev-link: create the symlink and update .gitignore
2. --dev-vscode: add folder to workspace
-->

--- 
<!-- 

when prsenting the menu to the user, where it is detected that some files have already been linked/copied

(like this)
```zsh
 1. [S] markdown-conventions.instructions.md
file_status=symlinked
status_indicator='[S]'
 2. [ ] swift-conventions.instructions.md
file_status=not_installed
status_indicator='[ ]'
 3. [S] zsh-conventions.instructions.md
```

pre-enter those already installed files into stdin (type it on behalf of the user, but dont' press enter)

EX:
In this case
```zsh
1 3
```

This way the user has only to press enter to update the files/links -->



---

<!-- # Synthesize and install a main `.github/copilot-instructions.md` (or equiv AI root instruction file)

When a user runs `scripts/configure_ai_instructions.zsh` to configure a repository with AI Instructions, the script does:
* `mkdir -p .github/instructions`, 
* Copy or linke the files from this repo's `instructions/**` to  `.github/instructions/**`
* [ ] However this excludes the main instuction file which for CoPilot is `.github/copilot-instructions.md`
* [ ] Should we create a committed copy in this repository? Where to store it?. 
    * [ ] Perhaps: `mkdir -p ai_platform/copilot; touch ai_platform/copilot/.github/copilot-instructions.md`
    * [ ] Perhaps: `mkdir -p ai_agent_files; mv instructions ai_agent_files; touch ai_agent_files/copilot-instructions.md`
* [ ] or should `scripts/configure_ai_instructions.zsh` create a cusomt one based on analyzing whwat's in the dest repo?   
* [ ] Dependiong on what we decide we might add base instructions for the otehr AI platforms

<!-- Here's one idea i had for solving this. 
Add a new arg flag, where when set the script will (after handling the instruction files):
* check if copilot cli is installed (prompt to install if not (wrap that in a function))
* use copilot cli to:
  * read the repository
  * read the instrutions that this script has already set up
  * set up `.github/copilot-instructions.md`  -->









<!-- 

# New flag to configure workspace settings for ai chat preferences 
* [ ] add an additional flag argument to `scripts/configure_ai_instructions.zsh`, say `--vscode-workspace-settings` 
  * (that's kind of a long name. Maybe something to play with `--dev-vscode`?)
* [ ] when present, and when the script does locate a `*.code-workspace` file, then populate some data into the `settings` dict of that file. 
  * [ ] See `./docs/todo/setup/json/vscode_ai_workspace_settings.json` where I've stored a copy of the data I;d like copied into the target file. 
    * [ ] Let's clean up this source file and relocate it to a more appropriate place.  
* [ ] This data should be added to the settings file, nto duplicated, and should also respect any key/values taht are pre-exising -->


<!-- # Improve `--dev-vscode`
This arg is working well as is (when running `scripts/configure_ai_instructions.zsh`), but it adds the `~/.ai` folder to the VSCodeWorkspace at the end (appends to the end of the json array). 
* [ ] Instead insert the `~/.ai` folder in lex order. This is usually going to be first element givne it's index. 
* [ ] This seems pretty simple to do. LMK if not. 
 -->

<!-- * [ ] New arg to add custom specs to:
  * [ ] `--dev-link`: Add additional `[--dev-link-name <dir_name>]` which has a default value of the last path component of `$user_ai_dir`. When creating the symlink, use this value for the directory name of the sym link. This allows the user to control what the sym link directory name is in their repo
  * [ ] `--dev-vscode`: : Add additional `[--dev-vscode-name <dir_name>]` which has a default value of the last path component of `$user_ai_dir`. When creating the folder name in VSCode, use this value for the folder name. This allows the user to control what the sym link directory name is in their repo -->





<!-- 

The script `scripts/configure_ai_instructions.zsh` is mostly working as expected. I've noticed some problems with the `--dev-vscode` arg. It's not quite working as expected. 

* should modify the first *.code-workspace file found. 
  * If none are found, print that none were found then move on without modifying the workspace
  * If multiple are found, prompt the user which to use
  * if only 1 found, modify that one. 
* When adding the dir to the workspace file, the `"path"` to `$user_ai_dir` should be absolute, if possible.  (in the example below it's relative: `"../../../../../.ai"`)
* The `"name"` property should be set along side `"path"`, and it should be set it should be set to the the last path compontent of `$user_ai_dir` is. In this example it should be `.ai`
* This script should be smart enough to detect if `user_ai_dir` has already been added to the workspace, then print as much and be done with this step. 

## Example 01
The workspace file `userscripts.code-workspace` was updated using `cd $HOME/code/repositories/z2k/github/userscripts && ~/.ai/scripts/configure_ai_instructions.zsh --dev-vscode --debug`

See a capture of the terminal I/O here: `scripts/.gitignored/bug01.log`

This is the diff of that at file after running the script

* Problem 1: The path to `$user_ai_dir` is completely wrong.
  * PWD is `$HOME/code/repositories/z2k/github/userscripts`
  * the relavite path to `$user_ai_dir` is `"path": "../../../../../.ai"`, not `.ai`. Like it's computing what should be `name` and putting it in `path`
* Problem 2: If the path property were correct, it should be absolute path (if possible)
  * Ideally: `$HOME/.ai`, falling back to `~/.ai`, falling back to `/Users/zakkhoyt/.ai`
* Problem 3: The name property is wrong. It should always be the leaf dir name of `path` (or `$user_ai_dir`). Never `"AI Documentation"`

```diff
   "folders": [
     {
       "path": "."
+    },
+    {
+      "path": ".ai",
+      "name": "AI Documentation"
     }
   ],
   "settings": {}
```
Ideal diff
```diff
   "folders": [
     {
       "path": "."
+    },
+    {
+      "path": "/Users/zakkhoyt/.ai",
+      "name": ".ai"
     }
   ],
   "settings": {}
```
 -->


# Merge all vscode files

I'd like to take a better approach to how `$repo_root_dir/scripts/configure_ai_instructions.zsh` merges VSCode json files.


We need to support both User settings and workspace setting files which each can have multiple files

This repo will now store all vscode source files under `$repo_root_dir/vscode/*`
* user settings: `$repo_root_dir/vscode/user/*`
* workspace settings: `$repo_root_dir/vscode/workspace/*`
* etc... (More details below)

All files are JSONC format. 
* Merging should be intelligent
* Merged JSON should lint without errors. 
* Merged JSON should not have duplicate keys
* Comments should be merged/copied over as well, bound to the JSON line below it. 
* Source and dest json should be pretty format (one per line) with comments above the relevante data (if any)
* dictionaries should merge key/value pairs
* arrays should be replaced (I think?)
* Primitives should be replaced

## User Settings

User settings source and dest files will have matching basenames. 
The script needs to match basenames of the source and dest dirs, merging the content of matching basenames. 


### Destination Dirs/Files
VSCode keeps the user's setting files here:
* `$HOME/Library/Application Support/Code/User/*.json`
* Examples:
  * User's main settings file: `$HOME/Library/Application Support/Code/User/settings.json`
  * User's mcp servers file: `$HOME/Library/Application Support/Code/User/mcp.json`
  * User's keybindings file: `$HOME/Library/Application Support/Code/User/keybindings.json`

### Source Dirs/Files
* `$repo_root_dir/vscode/user/*.json`

**Examples**
* `$repo_root_dir/vscode/user/settings.json`
* `$repo_root_dir/vscode/user/mcp.json`
* `$repo_root_dir/vscode/user/keybindings.json`



## Workspace Settings

Workspace settings source and dest files will have matching basenames, except for 1 file, the "code-workspace" file. 
This file is named differently in ever workspace, but does reliably use the `.code-workspace` extension. 
Otherwise workspace files can be merged in the same manner as the user files, by matching the basenames per directory

### Source Dirs/Files
There are two source dirs (nested)

* The Code workspace file itself: `$repo_root_dir/vscode/workspace/workspace.code-workspace`
  * This file is a bit tricky because the dest basename is not predictable and will not match the source.  
  * In this case we want to match the file extension: `*.code-workspace`. 
  * If the destination directory has more than one `*.code-workspace` file, use the one with the most recent modified date.
* Workspaces can have additional json files: `$repo_root_dir/vscode/workspace/.vscode/*.json`
  * Similar to the user files, the script just needs to merge to the same file rootnames: 
  * Examples:
    * `$repo_root_dir/vscode/workspace/.vscode/launch.json`
    * `$repo_root_dir/vscode/workspace/.vscode/mcp.json`
    * `$repo_root_dir/vscode/workspace/.vscode/tasks.json`


### Destination Dirs/Files
* Code workspace file itself: `$dest_dir/*.code-workspace`
* Workspaces have additional settings/config`$dest_dir/.vscode/*.json`
  * Examples:
    * `$dest_dir/.vscode/launch.json`
    * `$dest_dir/.vscode/tasks.json`
    * `$dest_dir/.vscode/mcp.json`


## Multiple sources, 1 destination

* Multiple source files can map to a single destination file. 
* This will allow the source files to be broken out into useful categgories or topics.
* Let's use a convention for the source files: `<dir_path>/[<topic>__]<common>.json` 
  * Where `[<topic>__]` is an optional component of the filename
  * EX 1: Code Workspace file:
    * `$repo_root_dir/vscode/workspace/workspace.code-workspace` -> `$dest_dir/*.code-workspace`
  
  * EX 2: All of these will map to the same file:
    * `$repo_root_dir/vscode/workspace/.vscode/mcp.json` -> `$dest_dir/.vscode/mcp.json`
    * `$repo_root_dir/vscode/workspace/.vscode/xcode__mcp.json` -> `$dest_dir/.vscode/mcp.json`
    * `$repo_root_dir/vscode/workspace/.vscode/jira01__mcp.json` -> `$dest_dir/.vscode/mcp.json`
    * `$repo_root_dir/vscode/workspace/.vscode/jira02__mcp.json` -> `$dest_dir/.vscode/mcp.json`




## Moving VSCode source files to new locations

Let's relocate and rename our current configuraiton files like so:

```zsh
mkdir -p vscode/user
echo "*.json files in this dir will be merged into `$HOME/Library/Application Support/Code/User/*.json` by `scripts/configure_ai_instructions.zsh`" > vscode/user/README.md

mkdir -p vscode/workspace
echo "*.code-workspace files in this dir will be merged into `$dest_dir/*.code-workspace` by `scripts/configure_ai_instructions.zsh`" > vscode/workspace/README.md

mkdir -p vscode/workspace/.vscode
echo "*.code-workspace files in this dir will be merged into `$dest_dir/.vscode/*.json` by `scripts/configure_ai_instructions.zsh`" > vscode/workspace/.vscode/README.md

# workspace/*.code-workspace
mv "vscode/ai-workspace-settings.template.json" "vscode/workspace/ai_autoapprove__workspace.code-workspace"
mv "vscode/xcode-mcpserver-workspace-settings.template.json" "vscode/workspace/xcode-mcpserver__workspace.code-workspace"
mv "vscode/swift-workspace-settings.template.json" "vscode/workspace/swift__workspace.code-workspace"

# workspace/.vscode/*.json
mv "vscode/mcp/xcode-mcpserver-workspace-mcp.json" "vscode/workspace/.vscode/xcode-mcpserver__mcp.json"

```


## CLI Args

The files under `vscode/workspace` should be merged into the dest repo via a prompt menu, a lot like the instruction files (except no sym links here). 
I'm not sure how easy it will be to pre-select items that are already installed in this menu, unless we use a cache file or md5 hashing. 

THe files under `vscode/user` should like wise use a prompt menu, but only if a new arg `--user-settings` is present. Otherwise it should be skipped. 

Research, LMK if I missed something or contradicted myself. Ask me questions. Summarize











# xcode mcp servvers

`scripts/configure_ai_instructions.zsh` now supports optional VSCode settings tailored for the Xcode MCP server.

* New flag `--mcp-xcode` forces installation of the MCP settings template without prompting.
* Outside of that flag, the script scans the target directory (after resolving git root) for `Package.swift`, `*.xcworkspace`, or `*.xcodeproj`.
  * When any of those artifacts are found, the user is prompted to merge the MCP settings.
  * Only the most recent `.code-workspace` file at the repo root is modified, and a backup is created before changes.
* Settings come from `vscode/xcode-mcpserver-workspace-settings.template.json`; the merge routine supports JSON comments so template annotations are preserved.
* The workspace merge reuses the Python-based `json_merge.py` helper, ensuring dictionaries merge recursively while arrays and primitives follow the template values.


* [ ] Merge mcp.json files

## Other

* The base workspace template now lives at `vscode/ai-workspace-settings.template.json`; the old filename has been removed.
* Both the AI workspace template and the Xcode MCP template may include `//` and `/* */` comments. The merge step runs `strip_jsonc.py` to sanitize JSONC and then feeds the result to `json_merge.py`, so no manual cleanup is required.



## Refs
* [GitHub: Cameroncooke - Xcode Build Mcp](https://github.com/cameroncooke/XcodeBuildMCP?tab=readme-ov-file)
* [Install in VSCode](https://insiders.vscode.dev/redirect/mcp/install?name=XcodeBuildMCP&config=%7B%22command%22%3A%22npx%22%2C%22args%22%3A%5B%22-y%22%2C%22xcodebuildmcp%40latest%22%5D%7D)


![alt text](images/XcodeBuildMCP.png)

<!-- ps aux | grep -i mcp (or the specific target name) ensures the Xcode MCP process is alive; long-running background launchd jobs can be inspected with launchctl list | grep MCP.
If the server exposes a TCP socket, confirm it’s bound with lsof -nP -iTCP | grep <port> or target-specific netstat -an | grep <port>; successful LISTEN states indicate it’s ready.
Use whatever health endpoint/command the server exposes (often curl http://localhost:<port>/health or nc localhost <port>) to verify it responds with the expected banner or JSON.
Check recent logs (Console.app, log stream --predicate 'process == "XcodeMCP"', or the server’s own log file) for startup success messages and absence of crashes.
From Xcode, run the command that depends on the MCP server (e.g., initiate the custom build step or tool that uses it); if the integration succeeds without timeouts, the server is functioning. -->





# Dir Heirarchy

LMK what you think. Are there better ways to do this? Ask me questions, then let's agree on a plan.  -->

## Better support for other AI platforms. Both root instruction file and `instructions/**/*`
```zsh
ai_platforms/
├── copilot/
│   └── copilot-instructions.template.md
├── claude/
│   ├── .claude/
│   │   └── settings.template.json
│   └── CLAUDE.template.md
├── cursor/
│   └── .cursor/
│       └── rules/
│           └── mobile.template.mdc
└── coderabbit/
    └── .coderabbit.template.yml
```
