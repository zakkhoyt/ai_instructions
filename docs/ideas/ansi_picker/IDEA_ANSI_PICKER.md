

The idea here is to have an easy way to let users pick an item from a list in `zsh` scripts. 

* [ ] Will be written in `swift` as an executable and possibly a backing library
* [ ] Depends on `https://github.com/hatch-mobile/HatchTerminal` for things like  `ANSIUtilities`, `HatchTerminalTools`, etc...
  * [ ] HatchTerminal already depends on `https://github.com/zakkhoyt/VWWUtility` which has lots of userul stuff too




Present a menu, then let the user navigate it with arrow keys
EX:

```zsh
Select an item using the ← ↑ ↓ → keys. 
Press ␣ or ↩ to enter change the value
Press  ⎋ to go back
Press ? or h for help
```

Root menu
```zsh
$menu_header
$menu_title
∙ [ ] agent-chat-response-conventions.instructions.md
∙ [S] 🔗 agent-swift-terminal-conventions.instructions.md
∙ [S] 🔗 agent-terminal-conventions.instructions.md
∙ [S] 🔗 git-branching.instructions.md
∙ [S] 🔗 markdown-conventions.instructions.md
∙ [S] 🔗 python-conventions.instructions.md
∙ [S] 🔗 swift-conventions.instructions.md
∙ [S] 🔗 userscript-conventions.instructions.md
∙ [C] 📄 zsh-compatibility-notes.instructions.md
∙ [S] 🔗 zsh-conventions.instructions.md
$menu_footer
```


Instruction File Menu
```zsh
∙ [ ]       None
∙ [C] 📄    Copy
∙ [S] 🔗    Symbolic Link
```