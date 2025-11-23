
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
````






