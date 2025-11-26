




# zsh environment
* zsh_boilerplate 
* zsh_template
* zsh_utilities

* userscripts
  * violentmonkey.zsh
  * markdown_lineker.user.js




---


# .ai

write the `.ai-checksums` doc under `.gitignored/` (create dir if necessary)

## auto approve

* [ ] Here are some more examples that our default workspace-settings didn't autoapprove 
```zsh
cd /tmp && rm -rf test_run && mkdir test_run && cd test_run && jq -n '{folders: [{path: "."}], settings: {}}' > test.code-workspace && printf "all\n" | ~/.ai/scripts/configure_ai_instructions.zsh --target-dir . --dev-vscode --debug 2>&1 | tee /tmp/test_run.log
```

* [ ] Another
```zsh
cd /tmp && rm -rf test_run4 && mkdir test_run4 && cd test_run4 && jq -n '{folders: [{path: "."}], settings: {}}' > test.code-workspace && printf "all\n" | ~/.ai/scripts/configure_ai_instructions.zsh --target-dir . --dev-vscode > /tmp/test_run4.log 2>&1 && jq '.folders' test.code-workspace
```
> [!NOTE]
> File write operations detected that cannot be auto approved: 
> * /tmp/test_run3/test.code-workspace, 
> * /tmp/test_run4.log

![alt text](images/Code_20251123232614.png)


## --dev-vscode sort order
* [X] ~~*folders should be sorted in lex ordering*~~ [2025-11-23]
* [ ] update workspace file to add .name property


## not adding sections/comments when a repo already contains a  `.github/copilot-instructions.md`







# VSCode Snippets

* [ ] Update [escape_vscode_snippet.zsh](#escape_vscode_snippetzsh) to a point where it can get work done in a useful way

* [ ] re-work TODO/FIXME, etc..
  * [ ] multiline variants
  * [ ] update VSCode syntax highlighting to match

## markdown
* [ ] update TODO/FIXME, etc.. to be multiline

# shellscript


## zsh param expansion templates
* print



## Write new snippets

### zparseopts
* [ ] zparseopts w/an opt
  * [ ] snippet option: `-E|-F|<nil>`
  * [ ] snippet option: arg is mandatory
```zsh
zparseopts -D -E -- \
    -mode:=opt_mode
    opt_mode="${opt_mode[-1]}"
```
* [ ] zparseopts w/an array
* [ ] clean up opt var primitive var
* [ ] clean up opt array var


# .zsh_home
## rework config files for effeciency
* [ ] source vs source_once vs guards
* [ ] use `autoload` for source_once vw trying to configure it earliy
* [ ] clean startup logs consolidate:
  * `Already sourced .zsh_logging_utilities`
  * `[INFO] source_once flag_force_source`
  * `Proceeding with sourcing .zsh_core_utilities_umbrella`
  * `setting _Z2K_SOURCED_CORE_UTILS=/Users/zakkhoyt/.zsh_home/utilities/.zsh_core_utilities_umbrell`
* [ ] use `autoload` apply_unique
* [ ] Disable vim keybinding. I want my escape key for other things
  * look for `bindkey`
* [ ] refactor config files into... autoload? config_categories? Umbrellas?

## zsh_logging_utilities
* [ ] refactor most args to `_slog`
* [ ] Write a function that can log any kind of shell variable in decorated format:
  *  `function slog_any_var_se`
     *  int/float/string: 

```zsh
# unset/empty
$ unset -v my_var
$ slog_var_se "my_var" "$my_var" 
# expected equivalent: `"_myvar\x1B[0m: '\x1B[1mmy value\x1B[0m'" 1>&2`
```
```zsh
# int/float/string: 
$ my_var='my value'
$ slog_var_se "my_var" "$my_var" 
# expected equivalent: `"_myvar\x1B[0m: '\x1B[1mmy value\x1B[0m'" 1>&2`
```
```zsh
# array
$ my_array=(a b c 'd e f')
$ slog_var_se "_myvar" "$_myvar" 
# expected equivalent: `"_myvar\x1B[0m: '\x1B[1mmy value\x1B[0m'" 1>&2`
```


## zsh_boilerplate / zsh_template
* [ ] Finish implementing `.zsh_boilerplate`
  * [ ] Snippet, template, or other quickstart method




## .zsh_alias_public
* [ ] zsh man aliases
ZZ
      * [ ] zsh_boilerplate
      * [ ] zsh_template
    * .rval
    * error handling
    * 
* [ ] share
  * [ ] Push changes back into [environment-toolbox](https://github.com/hatch-baby/environment-toolbox)
  * [ ] back up using [hatch-snippets](https://github.com/hatch-mobile/CodeSnippets)






# shellscripts

Referring to scripts under the `hss` dir

## escape_vscode_snippet.zsh
* [ ] consider using AI to port this script to js/python/swift. Stronger json capabliliteies would be powerful
  * [ ] (VSCode extension)
* [ ] update `escape_vscode_snippet.zsh` enough to work effeciently
* [ ] `--suffix/--no-suffix`: dangling ${0}
* [ ] generate/output full snippet json dictionaries
* [ ] output modes:
  * [ ] stdout (tty / not)
  * [ ] pbcopy | pee
  * [ ] file
    * [ ] replace
    * [ ] append
    * [ ] intelligent insert

* [ ] merge `environment-toolbox` into user snippets
* fracture zsh snippets into a few snippet files:
* ansi
* log / slog_step_se (echo based)
* scripting constructs:
  * shebang



## info / symbol_info / function_info
* [ ] refactor


## man browser

# echo_pretty 
* convert back to custom parsing
* merge tests PR
* add compound