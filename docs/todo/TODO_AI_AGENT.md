
When the agent is asked to write up a markdown document to answer a question, I am expecting that:
* Every piece of content that goes into that document has been researched and not just assumed.
* Expect refernce links throughout that markdown document. (see AI instruction about markdown conventions)
* What DO NOT WANT, is assumptions, or lazy research (research without fact checking)

## Example

I asked a chat agent this:

```prompt
I have iOS 26 and macOS 26. i have icloud turned on for photos. content that I take on my phone does eventually show up on my computer but is there a way to force them to sync? For example I started editing a series of photos on my phone and want to continue on my mac but photos on the mac aren't showing the update I made recently.

Write up a document at apple/APPLE_PHOTOS.md
```

Below are two responses

### BAD
This first response is awful, unfactual, and just not helpful for anyone. Why it would make stuff up like this I'll never understand
The markdown document is full of make believe. Almost none of this is based in reality



```response
Added a dedicated iCloud Photos sync walkthrough in APPLE_PHOTOS.md covering quick refresh tactics on iPhone/iPad, manual sync tools on macOS, and a troubleshooting checklist with Apple support references so you can force edits to land before switching devices.
Included a short cross-device workflow section to remind you how to hand off edits smoothly when you leave one device mid-session.
Possible next steps:

Test the “Sync Now” button on macOS after finishing edits on iPhone to confirm latency.
Note any additional edge cases (e.g., managed Apple IDs, VPN constraints) in the same file if you run into them.
```

and the markdown it wrote

```markdown
# Apple Photos Sync Cheatsheet (iOS 26 · macOS 26)

## Quick TL;DR
- Edits usually sync within a minute when both devices are on Wi‑Fi, unlocked, and plugged in.
- On iPhone: leave Photos open, pull down in `Library → All Photos` to trigger `Updating…`, or toggle `iCloud Photos` off/on (keep `Optimize iPhone Storage`).
- On Mac: open Photos, go to `Photos ▸ Settings ▸ iCloud`, click **Sync Now**, or quit/reopen Photos to re-handshake iCloud.
- If stuck, verify `System Status`, enough iCloud storage, and matching Apple IDs.

## Force Sync on iPhone (iOS 26)
1. **Check network & power**
   - Connect to strong Wi‑Fi, disable Low Power Mode, and plug in if <50% battery.
2. **Run Photos in foreground**
   - Open `Photos ▸ Library ▸ All Photos` and wait; swipe down to show the activity spinner (`Updating…`, `Uploading…`).
3. **Refresh iCloud Photos toggle**
   - Go to `Settings ▸ Photos`, toggle **iCloud Photos** off → Keep on iPhone → back on. Remain on this screen while the initial rescan completes.
4. **Free up processing time**
   - In `Settings ▸ Battery`, temporarily disable `Low Data Mode` and ensure `Background App Refresh` is allowed for Photos.
5. **Last resort**
   - Force-restart the device, then repeat steps 1–3.

## Force Sync on Mac (macOS 26)
1. **Verify iCloud Photos status**
   - Open Photos → `Photos ▸ Settings ▸ iCloud` → ensure **iCloud Photos** is checked.
2. **Manual sync kick**
   - In the same panel, click **Sync Now** (bottom right of the Photos Settings window once **iCloud Photos** is enabled). If the button is greyed out, uncheck/recheck **iCloud Photos** and confirm.
3. **Keep Photos active**
   - Leave the Photos window frontmost; large edits queue faster when Photos is not minimized and Mac stays awake (`System Settings ▸ Displays ▸ Advanced ▸ Prevent sleeping`).
4. **Rebuild library sync cache**
   - Option-launch Photos → choose the library → allow the repair tool to run. Do this only if sync has stalled for hours/days.
5. **Network reset**
   - Toggle Wi‑Fi off/on or switch networks; heavy VPN/firewall rules can delay sync.

## Cross-Device Editing Workflow
- **Finish edits on iPhone** → leave Photos open and the device plugged in for ~1 minute → confirm the edited photo shows a latest timestamp in `All Photos`.
- **Move to Mac** → open Photos → hit **Sync Now** → check the photo’s `Info` pane; status should read `iCloud: Updated Just Now`.
- If the edit still lags, duplicate the photo on iPhone (shares the edit history) which often forces a new asset upload.

## Troubleshooting Checklist
- Confirm both devices use the same Apple ID and `Settings ▸ [name] ▸ iCloud ▸ Photos` is ON.
- Ensure iCloud storage is not full; Photos pauses uploads when <1 GB remains.
- Check [Apple System Status](https://www.apple.com/support/systemstatus/) for `Photos` or `iCloud Account & Sign In` outages.
- Disable Low Power Mode (iPhone) and `Optimize Mac Storage` temporarily if local edits refuse to upload.
- Large RAW/LUT-heavy edits may queue; keep devices awake until progress bars finish.

## References
- [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264)
- [Apple System Status](https://www.apple.com/support/systemstatus/)

```

```markdown
# Apple Photos Sync Cheatsheet (iOS 26 · macOS 26)

## Quick, fact-checked takeaways
- iCloud Photos automatically keeps your Originals and edits in sync across devices signed in with the same Apple ID; there is no manual **Sync Now** button in the Photos preferences on macOS 26. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264)
- Upload speed depends on your internet connection and library size, so recent edits might need time before they appear elsewhere. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#howitworks)
- You can see the current upload status (and pause/resume for a day) inside the Photos app on both platforms by opening `Library → All Photos` and scrolling to the bottom. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#pause)

## Make sure iCloud Photos is actually syncing

### On iPhone or iPad (iOS/iPadOS 26)
1. Open `Settings ▸ [your name] ▸ iCloud`.
2. Tap **Photos**.
3. Turn on **Sync this device** (this is iCloud Photos). Optional: enable **Optimize iPhone Storage** if you need more local space. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#turnon)

### On Mac (macOS 26)
1. Go to `Apple menu  ▸ System Settings`.
2. Select your name in the sidebar, then pick **iCloud**.
3. Under **Apps Using iCloud**, click **Photos** and enable **Sync this Mac**. Storage options (Download Originals vs Optimize Mac Storage) live in `Photos ▸ Settings ▸ iCloud`. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#turnon)

## Check sync progress or pause/resume
- **On iPhone/iPad:** open Photos, tap `Library ▸ Collections`, then tap the profile button. The status line shows whether items are uploading; you can tap **Pause** to stop uploads for a day. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#pause)
- **On Mac:** open Photos, choose `Library ▸ All Photos`, scroll to the bottom, and look for the status banner. Use the nearby **Pause** control if you need to temporarily halt uploads. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#pause)

## What to try when edits seem stuck
- Confirm you are editing the same photo library (no shared albums or duplicates) and that both devices show `Sync this device/Mac` enabled. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#turnon)
- Leave the Photos app open and the device on Wi‑Fi; Apple notes the timing depends on your connection, so keeping the device awake helps uploads finish. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#howitworks)
- Verify you still have iCloud storage available. iCloud Photos uses your iCloud quota plus local device space, so near-zero free space can delay updates. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#storage)
- Check [Apple System Status](https://www.apple.com/support/systemstatus/) for current service alerts affecting iCloud Photos.
- If progress appears frozen for hours, quit and reopen Photos, or toggle `Sync this device/Mac` off and on (expect a rescan). This isn’t documented as required, but it forces Photos to re-handshake with iCloud.

## Editing expectation
- When you crop, adjust, or revert a photo on one device, iCloud stores the original and pushes the edit to every other device automatically. [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264#use)

## References
- [Apple Support – Set up and use iCloud Photos](https://support.apple.com/en-us/HT204264)
- [Apple System Status](https://www.apple.com/support/systemstatus/)

```



<!-- 
✅ **COMPLETED** - New instruction file created at `instructions/agent/agent-chat-response-conventions.instructions.md`

## Summary

A new instruction file has been created specifically for AI agent chat response behavior:

**Location**: `instructions/agent/agent-chat-response-conventions.instructions.md`

**Key Topics Covered**:
1. **Markdown Source Format** - Present information as markdown source code, not rendered markdown
2. **Reference Links** - Always include reference links in markdown source format
3. **Code Snippets** - Use markdown code fences for all code examples
4. **URLs and Links** - Present URLs in markdown link syntax `[text](url)`

**Configuration**: The instruction has been registered with the configure_ai_instructions.zsh script and is now active in the repository.

---

# Original Request

* When i ask a question, or ask about a topic, here is how I'd like you to respond to me in the chat:
  * For you knowledge, I keep very detailed notes about everything using markdown files. This means I do a LOT of writing markdown code. 
    * Quite frequently I will want to copy information from this agent chat session into my markdown notes. This means that I will frequently want you to pre-present information formatted as markdown source code / markdown code (NOT Rendered markdown)
    * For example, code in markdown code fence format. URLs in markdown link format, etc...
    * So when I say "markdown source" or "markdown code", this is what I'm referring to
  * Always include reference links when responding to a question in chat. Present reference links in `markdown source` format
-->



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






