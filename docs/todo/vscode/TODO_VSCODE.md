
# Goals


VSCode can get bogged down with large dirs / file counts, and huge files. This keeps vscode's  CPUs usage spiked at 1000% and also can result in VSCode looping over and over , esp with nested `.git` directories
The goal is to update VSCode settings to exclude these in 3 different ways. 

* I want to apply these changes to `~/Library/Application Support/Code/User/settings.json` 
* generally by adding to `files.exclude`, `search.exclude`, `files.watcherExclude`

* These fall into a few categgories below
  * Dont' want vscode to spende any CPU % on it. 
    * No indexing the files/dirs, no iterating/crawling files, nothign. VSCode shoudl 100% not be aware of these
      * `search.exclude`, `files.watcherExclude`
  * Don't want to see it in VSCode's Explorer UI
      * `files.exclude`, 
  * am I misisng any additional settings to add these to? Consult all possible VSCode settings via official docs, not existing settings.json
      * no need to worry about settings for extensions right now
  * some section may contain .git folder globs. Do we  need to consider vscode's git settings?






## VSCode to Fully ignore and Hide in Explorer Pane
Here are some filepaths that I want VSCode to 100% ignore:
* Dont' want vscode to spende any CPU % on it  (see above)
* Don't want to see it in the explorer UI at all (see above)


* `**/Library/Application Support/Code/User/workspaceStorage/`
* `**/Library/Application Support/Code/User/globalStorage/`
* `**/DerivedData/`
* `**/node_modules/`
* `**/*cache*/`
* `**/__pycache__/` not sure if this is needed after ^
* remove any `**/.venv/` from current settings
  * add `**/.venv/lib/` to all 3 settings

* Exclude anything deeper than the first 2 levels of these in explorer. I want to know that they are there, but as cheaply as possible:
  * `**/.build/*/*/`
  * `**/build/*/*/`
  * `**/Build/*/*/`
  * `**/temp/*/*/`
  * `**/.docc-build/*/*/`
  * `**/*.doccarchive/*/*/`
  * `**/*.swiftpm/*/*/`
  * `**/Pods/*/*/`
  * `**/Carthage/*/*/`
  * `**/planning_references/*`

* I want to exclude some  parts of `.git/`  (only the .git/ in the workspace root dir, not nested. Ignore and hide all nested)
  * show: 
    * `.git/hooks/`
      * including: `.git/hooks/backups` (which is contradiction to )
    * `.git/gk/config`
    * `.git/ai`
  * hide
    * all other `.git/`
  * I am only interesetd in the main  `.git`  dir (in the workspace root). Nested .git dirs can be hiden completely and also ignored competly by vscode. 
  * In other words, hide the subdirs that are: huge, not human readable, etc..





## Other changes

Lastly I want to change these existing terms so these and allow display, indexing, etc...

* remove any `**/backup/` from these settings
* remove any mention of `.hatch`  from these settings




# Action Items
* I want to apply the above  changes to `~/Library/Application Support/Code/User/settings.json`, but please make a report / plan first for my confirmation by writing to `docs/todo/vscode/PLAN_VSCODE_SETTINGS.m
* Please look at which vscode extensions are installed as well as all possible vscode settings (not just those currenltly specified in settings.json)
  * Advise which additional settings would improve VSCode performance in reagard to these files/dirs
  * For example: I just changed `"todo-tree.filtering.useBuiltInExcludes": "none"` `"todo-tree.filtering.useBuiltInExcludes": "file and search excludes"` 
  * Another example: `Gitlens › Ai › Exclude: Files`
    * some of these probably build upon vscode's files.exclude or similar, others maybe not.
  * Research all possible settings and all possible extension settings then produce a report: `docs/todo/vscode/PLAN_VSCODE_ADDITIONAL_SETTINGS.md`
    
