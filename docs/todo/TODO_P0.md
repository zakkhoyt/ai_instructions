
# On conductor workspace created
```zsh
# TODO: Ensure that PWD is the conductor workspace
# Does conducotr provide ENV vars for htis?
```

## On conductor workspace created (github.com:hatch-baby/mobile) 
# TODO: Ensure repo is `github.com:hatch-baby/mobile`  #1
# Ensure that the git remote contains `github.com:hatch-baby/mobile`
# ```zsh
# # Check that the output of `git remote -v` contains "github.com:hatch-baby/mobile"
# $ git `remote -v
# origin	git@github.com:hatch-baby/mobile.git (fetch)
# origin	git@github.com:hatch-baby/mobile.git (push)
# ```
# TODO: Ensure repo is `github.com:hatch-baby/mobile`  #2
# repo_root_dir shoudl contain `iOS/hatch-sleep-app`

# TODO: At this point our repo/PWD is varified to be "github.com:hatch-baby/mobile"...
# * let' configure our .gitignored dirs
# * And then create symlinks from our common/backed up subjective AI planning notes: `/Users/zakkhoyt/Documents/HatchDocs/ai/planning/${AI_PLANNING_TOPIC}`
# If neither .gitignored nor iOS/hatch-sleep-app/.gitignored exist, create `.gitignored
# TODO: check if neither .gitignored nor iOS/hatch-sleep-app/.gitignored exist
if ! [[ -e ".gitignored" ]] && ! [[ -e "iOS/hatch-sleep-app/.gitignored" ]]; then
  mkdir -p .gitignored
  cd `iOS/hatch-sleep-app`
  ln -s ../../.gitignored
else 
  : # at least one of the .gitignored dirs already exists
fi





# On Prompt Submitted

* Is some information missing: Ask me questions about it (regardless of `planning` mode, `agent` mode, etc...)!
* Is a requested action item vague: Ask me questions about it (regardless of `planning` mode, `agent` mode, etc...)!
* Is there any decisions that could be made easier if you had a little more information? Ask me questions about it (regardless of `planning` mode, `agent` mode, etc...)!
