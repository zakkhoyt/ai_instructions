
* When i ask a question, or ask about a topic, here is how I'd like you to respond to me in the chat:
  * Always include reference links when responding to a question in chat. 
* For you knowledge, I keep very detailed notes about everything using markdown files. This means I do a LOT of writing markdown code. 
  * Quite frequently I will want to copy information from this agent chat session into my markdown notes. This means that I will frequently want you to pre-present information formatted as markdown source code / markdown code (NOT Rendered markdown)
  * For example, code in markdown code fence format. URLs in markdown link format. 



<!-- 
✅ **COMPLETED** - New instruction file created at `instructions/agent/agent-terminal-conventions.instructions.md`

## Summary

A new instruction file has been created specifically for AI agent terminal command execution behavior:

**Location**: `instructions/agent/agent-terminal-conventions.instructions.md`

**Key Topics Covered**:
1. **Persist Command Output** - Always save long-running command output to log files
2. **Real-Time Human Visibility** - Use `tee` so humans can see what's happening
3. **Avoid Re-Running Long Commands** - Work from saved logs instead of re-executing
4. **Bypass Pagers** - Use `| cat` or `--no-pager` to prevent hanging
5. **Log File Naming** - Use timestamped, organized log files

**Migration**: The "Pager-Aware Command Execution" section has been moved from `instructions/zsh/zsh-conventions.instructions.md` to this new file, as it's more relevant to agent behavior than zsh scripting conventions.

---

# Original Notes Below

I have some new/rought information that I want to refine then add to this repo's `instructions` folder.
The general topic involves `zsh` terminal commands, but it's got a lot more to do with Agent behavior.
It's how i'd like the AI Agent to USE terminal. The end goal is that the agent and myself get more done together.

I don't' think this content belongs in `instructions/zsh/zsh-conventions.instructions.md` as that's more about how I want my scripts to be written. 
I do think this belongs in a new instruction category / file, maybe `instructions/agent/agent-terminal-conventions.instructions.md`?

Work with me to:
* [ ] Selecting an appropriate instruction file destination for this data. 
* [ ] Refine the data (below) so that  AI Agents will best understand it. 

# New Data

````instructions.md

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
````



Also, I noticed that `instructions/zsh/zsh-conventions.instructions.md` actually already contains some data that really should be moved to this new file as it's got much more in common with it. 
I've pasted a copy it here 
````instructions.md
### Pager-Aware Command Execution

**CRITICAL for AI Agents**: Many commands output to a pager (like `less`) instead of stdout, which can cause scripts or AI agents to hang indefinitely waiting for user interaction.

**Common commands that use pagers:**
-   `gh` subcommands (e.g., `gh repo view`, `gh issue view`, `gh pr view`)
-   `git diff`, `git log` (without `--no-pager`)
-   `man` pages
-   `systemctl status`
-   Any command configured with `PAGER` environment variable

**Solution**: Pipe output to `cat` to bypass the pager and write directly to stdout:

✅ **Good (bypasses pager):**
```zsh
gh repo view --json owner --jq '.owner.login' | cat
git --no-pager diff
git --no-pager log --oneline
```

❌ **Bad (opens pager, blocks script):**
```zsh
gh repo view --json owner --jq '.owner.login'  # Opens in less
git diff  # Opens in pager
```

**Alternative approaches:**
-   Use `--no-pager` flag when available: `git --no-pager log`
-   Set environment variable: `GH_PAGER=cat gh repo view`
-   Disable pager globally (not recommended): `export PAGER=cat`

**When to use `| cat`:**
-   Running commands in automated scripts
-   When output needs to be captured in a variable
-   When piping to another command (like `jq`, `grep`, `awk`)
-   In any non-interactive context
```` -->






