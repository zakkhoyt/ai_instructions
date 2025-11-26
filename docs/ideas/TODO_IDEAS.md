


# Notes for plist/defaults
Have AI create these docs
* shell/plist/SCOUT.md
* shell/plist/DEFAULTS.md
* shell/plist/PLISTBUDDY.md
* shell/plist/PLUTIL.md 
* shell/plist/...

# node based data mining
* thesaurus / dictionary idea. Get AI to help

# ssh-key
Read this markdown file which helps to configure a computer to connect to another computer over ssh without using passwords. 

Create a zsh script to automate this procedurs as described in the document. Add as m any CLI args as needed, providing reasonable default values



# ViolentMonkey
## Markdown Link

Create a violentmonkey script that can create a markdown link from any HTML anchor (`<a>`) in the web page with varying title data sources. 
See: [TODO_VIOLENTMONKEY_MARKDOWN_LINK.md](TODO_VIOLENTMONKEY_MARKDOWN_LINK.md)

# Firefox 
## UserScript Suppport
* [ ] Can Firefox directly support UserScripts? This article certainly reads that way: [userScripts - Mozilla | MDN](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/userScripts)

# create git branch, pr, 

* [ ] talk about crititcal/fatal steps vs warning. Do as many of these steps as possible without fatal logging & exiting. 
  * Some step are critical like having a feature branch. EX: If the user is already on a branch where the name == the computed feature branch name, then short circuit the code instead of 

## check if current git branch is default branch
* if not, then 
  * ensure there is nothing to push to remote. if there is: Error / exit 
  * ensure there are no uncommitted changes. if there is: Error / exit 
  * [ ] Let's discuss this: Delete local branch? delete remote branch?
    * For now, let's prompt before performing any destructive actions below. 
    * If exists a PR for this feature branch, and that PR is not merged, print this info for the user and move to the next step
    * If exists a PR for this feature branch, and that PR has been merged, then let's consider if we shoudl delete local & remote branches
      * [ ] if it's "safe to do so", then we can delete the local branch (`git branch -D <branch_name>`). This will need to be done after the next step though
      * [ ] if it's "safe to do so" (IE: if pr == merged, but remote branch still exists), offer to delete remote branch. This will need to be done after the next step though
  * We should be clear switch to default branch (as there is nothign left to commit/push/cleanup), with possible follow up commands to delete the local/remote branches (from ^)
* if so (nothing to do yet)

## we should be on default branch now
* reference: See the `gfff` command in zsh terminal
* pull latest from remote to ensure we are in sync
* `git reset --hard origin/$default_branch`
* as an non-essential task: pull remote tags and remote branches from origin
  * this should be done in a background process since it takes a little while
  * the info should be either stored to a file `.gitignored/git/<somefile>` and then printed to terminal later when complete

## create feature branch
we now have a stable foundation to create a feature branch
create a new branch. Something like this
```zsh
# git_user and topic are mandatory
# category is optional. nice to have
git switch -c "<git_user>/[category]/<topic>"
```
* each path component in the branch name should be formatted as `lower_snake_case`. 
  * EX: `john_doe/fbi/unsolved_homicides`
  * EX: `john_doe/unsolved_homicides`
* git_user: 
  *  to `lower_snake_case`
  * pull from `git config`. 


