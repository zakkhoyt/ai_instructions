# Meta

* Re-read AI instructions at `~/.ai/instructions/**/*.md`. read them all, but especially any concerning markdown as this chat will be heavy with markdown
* Within the markdown lists that follow below, any occurrences that are formatted as unchecked (`* [ ]`) indicate an **Action Item** for the AI Agent to complete. 
  * Please process these without being asked to do so 
  * Please mark the checkbox, add a short comment or context, then save the file

* Read related context informaiton: `$HOME/.ai/docs/todo/vscode/TODO_VSCODE_PERFORMANCE_PROMPT.md`


# About


* This workspace serves as my personal notes. It is composed of MANY markdown files across MANY categories.

* The VSCode Workspace contains two root/workspace folders:
  * `notes` - `/Users/zakkhoyt/Documents/notes` - `2.4 GB`
    * As far as I can recall, this is a collection of markdown notes on many many subject.
    * There are some non-markdown files mixed in, certainly. 
      * There are images, mostly stored under `**/images/**/*.png` for use in markdown files. Please verify, call out large collections of images, or large individual files. 
      * There are some videos as well, none should be very big though. Pleaese verify
      * Certainly there are probably some symbolic links nested under `notes` somewhere, likely used for references
  * `/Users/zakkhoyt/Documents/Manuals` - `1.1 GB`
    * This is just a collection of PDF files IIRC. It's very nice to have available here in this workspace so removing the workspace folder isn't what I want to do 


As detailed in `$HOME/.ai/docs/todo/vscode/TODO_VSCODE_PERFORMANCE_PROMPT.md`, the noted workspace folder needs some review and clean up




## Review Composition of File Hierarchy 

This workspace
* Review all files, dirs, symbolic links, etc.. under `~/Documents/notes/**/*`
* Expected:
  * lots of `*.md` files
  * maybe some `*.html` files which are sometimes used / mixed with markdown
  * lots of `images/**/*.png` files (and `jpg`, `svg`), assets for markdow files
  * lots of `videos/**/*.mp4` files (and `mov`, etc....), assets for markdow files
  * like some symbolic links to allow VSCode to access those dirs/files in this workspace
    * [ ] Perhaps we need either to add some of these sybollically linked dirs to the `exclude` list
    * [ ] or 
  * All of the above files should be reasonable in terms of bytes. 
* Unexpected
  * All of the above files should be < some threshold. How about `5 MB`?




## Back the `~/Documents/notes`
As a Programmer I've got a strong habit of using git for any files that modify more than a couple of times, or files/dirs that might change over time. 

* Even though `~/Documents/notes` is stored in my `iCloud` drive, I do notice the absence of a `.git` repository.
* I'd like to have this dir backed with a git repository, but it's current large size is a valid prerequisite.

> [!IMPORTANT]
> I have just now created a `.git` repo, commmited little, and pushed to github (private).
> AI Agent can commit, if necessary, but SHOULD NOT `git push` until the dir size has been reduced significantly


**Action Items**
* [ ] After Working through `Review Composition of File Hierarchy`, we should be able to start commiting and pushing
* [ ] Mirror the contents fo the `exclude` settings to `.gitignore`
* [ ] depending on what files remain after the review, perhaps we should configure this repostiory with `git lfs`?

