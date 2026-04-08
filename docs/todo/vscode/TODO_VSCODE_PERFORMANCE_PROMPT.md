
# Meta
* Re-read AI instructions at `~/.ai/instructions/**/*.md`. read them all, but especially any concerning markdown as this chat will be heavy with markdown
* Within the markdown lists that follow below, any occurrences that are formatted as unchecked (`* [ ]`) indicate an **Action Item** for the AI Agent to complete. 
  * Please process these without being asked to do so 
  * Please mark the checkbox, add a short comment or context, then save the file

# About


## Symptoms 
* VSCode would consume 800% - 1000% and even above that just sitting idle in my main workspaces. 
  * Most of the time, this high CPU would never end, or I never left the app open long enough to see CPU drop back down < 5%. 
* Sometime as I edit the markdown content using VSCode, it becomes unresponsive in strange ways. 
  * Paste operations result in a spinner, sometimes for minutes if it even works at all.
  * When I press the Backspace key, there is significant delay before it occurs (forward typing seems fine though).
* When attempint to use VSCode (editing, typing, drag&drop images & videos) I would be met with spinners, ignored keystorkes, etc...
* I noticed that the disk usage of `~/Library/Application Support/Code/User/` was very hig (~12 GB)


## Remedies

### Expanded Exclude Settings
Updated `*exclude*` settings to include serveral additional "trouble" ddirectories, or large dirs that I have no interested in exploring in VSCode. 

Here are the main settings that were updated:
* "files.exclude"
* "search.exclude"
* "files.watcherExclude"

The above 3 settings are pretty much equal (same values across all 3). I did add comments in these settings as well. 

And a few lesser ones:
* "swift.excludePathsFromPackageDependencies"
* "gitlens.ai.exclude.files"
* "todo-tree.filtering.excludeGlobs"

Most of the changes were applied in user settings, as I try to use consistent patterns and dir names, but sometimes a more acute scope is the right move. 
* User: `~/Library/Application Support/Code/User/settings.json`
* Workspace: `$some_dir/$some_name.code-workspace`
* Workspace Folder: `$some_dir/.vscode/settings.json`

### Clean up disk bloat in VSCode's User dir.
I used AI to help me to locate and delete some files to reduce some bloat
* `12 GB worth` was taking up about `12 GB`. Now < `1 GB`
* Most of this was under `$HOME/Library/Application\ Support/Code/User/workspaceStorage`
* [ ] I can't recall if we cleaned up `$HOME/Library/Application\ Support/Code/User/globalStorage` too? Please evaluate and let me know if there's anything in there that's safe & recommended to delete

### Disabled a number of VSCode extension



* [ ] Please audit my extension then generate a report at: `/Users/zakkhoyt/.ai/docs/todo/vscode/VSCODE_EXTENSIONS_STATUS_REPORT.md`
  * Include a list of all currently disable extensions
  * inlude a list of all currently enabled extension
  * Identify any extensions that you think I should uninstall, disable, replace, or are superfluous. Why?




This has helped performance a ton, and most workspaces are performing as I'd expect. 

I have VSCode open (`$HOME/Documents/notes/notes.code-workspace`) and am having some sluggishness and such. 

---


# Goals
* Even though `notes` is stored in my `iCloud` drive, I do notice the absence of a `.git` repository.
  * As a Programmer I've got a strong habit of using git for any files that modify more than a couple of times, or files/dirs that might change over time. 
  * 



* This workspace contains a LOT of markdown files (my categorized notes).
* The workspace folders:
  * `/Users/zakkhoyt/Documents/notes` - `2.4 GB`
    * As far as I can recall, this is a collection of markdown notes on many many subject.
    * There are some non-markdown files mixed in, certainly. 
      * There are images, mostly stored under `**/images/**/*.png` for use in markdown files. Please verify, call out large collections of images, or large individual files. 
      * There are some videos as well, none should be very big though. Pleaese verify
      * Certainly there are probably some symbolic links nested under `notes` somewhere, likely used for references
  * `/Users/zakkhoyt/Documents/Manuals` - `1.1 GB`
    * This is just a collection of PDF files IIRC. It's very nice to have available here in this workspace so removing the workspace folder isn't what I want to do 





# Outro

Anyhow the CPU is okay (low) at the moment, bowever I've seen it spike to 100% for a few seconds, repeatedlly, during this VSCode session. I'm
not sure how you can dig into the extensions and processsed unless it's actively happening.



I guess let's start by having yuo take a look at dirs & files in the workspace folders (taking the exclude settings into account)




---

<!-- 
 --------------------------------- Followup ----------------
 -->


# Inspect my *.code-workspace files 

As I described above, VSCode has been giving me some trouble recently by consuming way more CPU than it should be. 




