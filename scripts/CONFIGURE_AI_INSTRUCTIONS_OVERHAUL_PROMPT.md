this script is SOOO FAR AWAY from conforming to AI instructions for `zsh` scripts. I am beyond disappointed with this implementation. The AI agent had no regard for established convention, AI instructions, input prompts. 



Roll these changes back to ea430d14e782cead25c8fde9d931287a29ff7de8 for scripts/configure_ai_instructions.zsh and scripts/configure_ai_instructions_tests.zsh

then let's start completely over. 

ActionItems:

* Re-read AI instruction files paying particular attention those relating to `zsh`. Apply all instructions to all code edits moving forward.
  * All zsh scripts in this workspace will begin with `source "$HOME/.zsh_home/utilities/.zsh_boilerplate"`
    * `.zsh_boilerplate` is an important and key library. It recursively sources several other zsh libraries. 
      * Iterate through the full hierarchy of library files, reading each one so that you understand what they provide.
        * Lean on those tool when even possible. 
        * Avoid duplicating logic or writing second versions
* Rewrite the entire script (`scripts/configure_ai_instructions.zsh`) so that it fully conforms with AI instructions for zsh. I don't want a couple of changes, I want rewrite of this thing. 
  * I'm 100% serious about conforming, I will reject it in a heartbeat.
* Also, rewrite the entire script (`scripts/configure_ai_instructions_tests.zsh`) so that it fully conforms with AI instructions for zsh as well
* Test these chages. Fully exercise the script's arguments and check the output. Start with valid known conditions. Keep a log of the terminal I/O for my inspection (include stdout & stderr)
* ensure all documentaion, comments, --help, print_usage, etc.. are up to date as well
* Commit and push the changes including the testing logs Do not skip this step. 


* Next read the entirety of `scripts/CONFIGURE_AI_INSTRUCTIONS_OVERHAUL.md` then implement the overhaul, but please implement it as a second script: `scripts/configure_ai_instructions_overhaul.zsh`. 
* likewise implement a second `scripts/configure_ai_instructions_tests.zsh` to test ^. 
* again test test test, keeping the CLI logs for my review (as a separate file from the legacy version) 
* ensure all documentaion, comments, --help, print_usage, etc.. are up to date as well
* commit push



