

# IDEA: Improve existing VSCOde Snippets

* Point AI to some more recently crafted snippets

## ActionItems
* Find bugs in current snippets
* Remove duplicates in comments, descriptions, etc...
* Consolidate "flavors" of a snippet into a single snippet that uses droplists and value transformations
* Split/fracture global snippet files into more specific categories for the language specified. 
  * EX: `$HOME/Library/Application Support/Code/User/snippets/shellscript.json` could be split into
    * `$HOME/Library/Application Support/Code/User/snippets/shellscript-variables.json` - related to variables. Declares (typeset, local, readonly, etc...), transformation using zsh expansion, and such
    * `$HOME/Library/Application Support/Code/User/snippets/shellscript-loops.json` - snippets related to looping such as `.array_loop_echo`, `.argloop`, `.argsloop`
    * `$HOME/Library/Application Support/Code/User/snippets/shellscript-slog.json` - snippets related to all of the `slog_*` functions availble in `$HOME/.zsh_home/utilities/.zsh_logging_utilities`
    * `$HOME/Library/Application Support/Code/User/snippets/shellscript-ansi.json` - snippets related to ansi escape sequences. 
      * Often used to decorate `stdout` with the `echo` command
      * `echo_pretty` has named args in place of awkward escape code sequences. EX: `echo_pretty --underline --cyan "https://google.com" --default`
      * 


# IDEA: Use AI to help pump out some useful VSCode snippets


```zsh
.loop
```
