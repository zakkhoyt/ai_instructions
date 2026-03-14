
# Goals


VSCode can get bogged down with large dirs / file counts, and huge files. This keeps vscode's  CPUs usage spiked at 1000% and also can result in VSCode looping over and over , esp with nested `.git` directories
The goal is to update VSCode settings to exclude these in 3 different ways. 

* I want to apply these changes to `~/Library/Application Support/Code/User/settings.json` 
* Details below






# Fully ignore and hide form Explorer
Here are some filepaths that I want VSCode to 100% ignore:
* Don't want to see it in the explorer UI
* Dont' want vscode to spende any CPU % on it. 
  * No indexing the files/dirs
  * Dont' allow any extentensions accessing spending CPU on these files/dirs

* "**/Library/Application Support/Code/User/workspaceStorage/**": true,
* "**/Library/Application Support/Code/User/globalStorage/**": true,

* "**/DerivedData/**": true,
* "**/node_modules/**": true,

* "**/*cache*/**": true,
* `"**/__pycache__/**": true,` not sure if this is needed after ^


# Fully ignore, but show some/all in Explorer
Then there are some that I want configured the same as above, with the only difference being that I DO want to see them in the explorer UI


* show first 2 levels of these. I want to know that they are there, but as cheaply as possible:
  * "**/.build/*/*/**": true,
  * "**/build/*/*/**": true,
  * "**/Build/*/*/**": true,
  * "**/temp/*/*/**": true,

* "**/.venv/lib/**": 
  * show `**/.venv/*`, but not `**/.venv/lib`


* `**/.docc-build/*/*/**`
  * show first 2 levels

* `**/*.doccarchive/*/*/**`
  * show first 2 levels

* `**/*.swiftpm/*/*/**`
  * show first 2 levels

* `**/Pods/*/*/**`
  * show first 2 levels

* `**/Carthage/*/*/**`
  * show first 2 levels




<!-- Exclude .gitignored for now
* show first two levels of `**/.gitignored/*/*/**` and `**/_gitignored/*/*/**`
-->

* `**/planning_references`
* I want to show and hide some parts of `.git/**`
  * show: 
    * `.git/hooks/`
    * including: `.git/hooks/backups` (which is contradiction to )
    * `.git/gk/config`
    * `.git/ai`
  * hide
    * all other `.git/**`
  * I am only interesetd in the main  `.git`  dir (in the workspace root). Nested .git dirs can be hiden completely and also ignored competly by vscode. 
  * In other words, hide the subdirs that are: huge, not human readable, etc..
* There exists a `**/.venv/**` but i want to change this to `**/.venv/lib/**` and add to other settings as needed


# Other changes

Lastly I want to change these existing terms so these and allow display, indexing, etc...

* `**/backup/**`
* remove any mention of `.hatch`  from these workspaces




# Action Items
* I want to apply the above  changes to `~/Library/Application Support/Code/User/settings.json`, but please make a report / plan first for my confirmation by writing to `docs/todo/vscode/PLAN_VSCODE_SETTINGS.m
* Please look at which vscode extensions are installed as well as all possible vscode settings (not just those currenltly specified in settings.json)
  * Advise which additional settings would improve VSCode performance in reagard to these files/dirs
  * For example: I just changed `"todo-tree.filtering.useBuiltInExcludes": "none"` `"todo-tree.filtering.useBuiltInExcludes": "file and search excludes"` 

Todo-tree › Filtering: Use Built In Excludes
Add VSCode's files. exclude and/or search. exclude list to the ignored paths.

file and search excludes



