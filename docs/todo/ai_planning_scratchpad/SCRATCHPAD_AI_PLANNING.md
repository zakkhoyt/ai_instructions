# Test COverage Skills
* Context to coderabbit
* ask @sam



# Questions / Unknowns
* Have AI create a comparison of instructions, rules, plans, prompts, kills, hooks, etc...
  * What the term means
* include all supported AI systems
* References, footnotes, etc...
* include example prompts to have AI assist in creating the flies


* ai_platform - term
  * definition (with link to official docs)
  * all valid filepath(s) (with link to official docs)
    * all possible places where the file can be stored and used by the agent without extra direction


# File naming conventions
* ${ai_category}_${doc_properties}_${topic}_${phase_name}.md
  * ai_category:
    * `INSTRUCTIONS`
    * `RULES`
    * `PLANS`
    * `PROMPTS`
    * `COMMANDS`
    * `SKILLS`
  * doc_properties
    * scratchpad, draft: (input for AI. AI should treat as readonly)
    * working, wip: (input for AI. AI should mark off checkmarks)
    * final: (output from AI. Dev should take caution to edit the document)
  * topic: 
    * The topic of discussion for the document
    * can also be a Jire Issue: `HSD-1234`
  * phase_name: `PHASE-01`, `PHASE-02`. etc...
    * Pad the number to two digits (leading `0`s)
  * examples: 
    * U_SNAKE: PLANNING_SCRATCHPAD_BLEBACKUP_PHASE-01.md
    * camel_snake: planning_scratchpad_bleBackup_phase01.md
    * no phases_: planning_scratchpad_bleBackup.md


# Thoughts
* agents tend to get off track, especially when a tool is shut down / relaunched
  * [ ] how to prevent this, or how to keep them on track in an automated way? Having to manually remind them is taxing

## Plan Document (dupe)
<!-- 
TODO: Maintain a PLAN_*.md document
* Please also maintain a the plan as a markdown document: `/Users/zakkhoyt/Documents/HatchDocs/ai/planning/slack_updates/PLANNING_SLACK_UPDATE_HELPER.md`
  * update this document when ever the plan changes. This includes adding new steps/phases/tasks, completing steps/phases/tasks, etc...
 -->


# Phases of work

* Please break the work in in this prompt down into a reasonable number of `phases`


## Plan Document (dupe)
<!-- 
TODO: Maintain a PLAN_*.md document
* Please also maintain a the plan as a markdown document: `/Users/zakkhoyt/Documents/HatchDocs/ai/planning/slack_updates/PLANNING_SLACK_UPDATE_HELPER.md`
  * update this document when ever the plan changes. This includes adding new steps/phases/tasks, completing steps/phases/tasks, etc...
 -->


## Iterative Branches and Pull Requests per Phase
<!-- TODO: ensure this sentiment is included
I have merged the work above into `main`. Please create a new branch and pull request focused on creating cheatsheet documents for documentation links, config file paths, config file syntax,  for AI platforms and applications. 
Make the branch, do an empty commit, push, create the PR. 

I will give instructions for the next steps afterwards
 -->


Each phase of work should be done on it's own (iterative) `branch` and `pull request`. 

As each phase of work begins, the first order of business is to:
* create a new `git branch` for this phase of work, building on this previous phase, all the way back to `phase 1`, then `main`. 
* Branch format(s): 
  * The branch should be in `lower_snake_case` 
  * If a jira ticket is involved: 
    * `${git_author}/${jira_ticket}/${feature_topic}/phase_${phase_number}/${phase_topic}` 
    * EX: `zakkhoyt/hsd-1234/ble_client_update/phase_1/accessory_kit_support` 
  * If no jira ticket, omit that term
    * `${git_author}/${feature_topic}/phase_${phase_number}/${phase_topic}` 
    * EX: `zakkhoyt/ble_client_update/phase_1/accessory_kit_support` 
* Agent must make an immediate commit and push when creating a new branch
* Create a new/separate PR for each phase of work
  * The PR's branch is created from the branch of the previous phase,
    * However the pull request's should merge back to `main`, not the branch of the previous phase
    * This means each phase's PR will include the changes of all phase branches in the feature. This is intended. 
      * This is also why an immediate commit when each branch is created (making the PR easier to review when that first non-emptuy commit comes in)
  * The PR's title should begin with the plan's title/theme and phase number, in square braces: EX: `[ArgumentKit Phase 1]`
  * The PR's title should end with  the jira ticket number (if any) in square braces. EX: `[HSD-1234]`
  * Populate the PR's body (a template) with an overview of the work done in the entire phase, (not just the current commit)
* Agent must make an immediate commit, push, and create the PR
  * if there are no changes (IE; first phase), then use the `--allow-empty` argument
* The pull requests's body should be updated on every `git push` if needed. Reminder that it the body needs to describe the work done over the entire current phase
  * NOT all phases
  * NOT just the current commit
* Be sure to push/update the Pull Reqeust before moving on to the next phase


```zsh
$ git branch --show-current
zakkhoyt/hsd-1234/ble_client_update/phase_1/accessory_kit_support
$ git switch -c "zakkhoyt/hsd-1234/ble_client_update/phase_2/accessory_kit_unit_tests"
# Do make an immediate commit / push. This will help to review only the work releveant to this PR as the phase is implemented. committed, pushed. 
$ git commit --allow-empty -m "Initial commit for phase 2 - Accessory kit unit tests"
$ git push
# When a Jira ticket is involved
$ gh pr create --title "[BLE Client Update Phase 2] Accessory kit unit tests [HSD-1234]" --body-file .github/PULL_REQUEST_TEMPLATE/default_no_comments.md --base 'main' --assignee '@me' --draft
# When no Jira ticket is involved, use `--label "Skip Jira Ticket Check"`
$ gh pr create --title "[BLE Client Update Phase 2] Accessory kit unit tests [HSD-1234]" --body-file .github/PULL_REQUEST_TEMPLATE/default_no_comments.md --base 'main' --assignee '@me' --draft --label "Skip Jira Ticket Check"

# implement phase 2 work
# git add .
# git commit -m "Phase 2 work complete ..."
# git push
# # On lint fails, 
# # pushd iOS/hatch-sleep-app && bundle exec fastlane format_all && bundle exec fastlane lint_all && popd
# # update PR body if needed
# gh pr edit ...
```


See example PRs from ArgumentKit planning
* [[ArgumentKit Phase 1] Environment variable support + configurable UserDefaults keys](https://github.com/hatch-baby/mobile/pull/1563)
* [[ArgumentKit Phase 2] Combine publishers + Event/Error enums](https://github.com/hatch-baby/mobile/pull/1564)
* [[ArgumentKit Phase 3] Package consolidation + targets/ directory restructure](https://github.com/hatch-baby/mobile/pull/1565)
* [[ArgumentKit Phase 4] Refactor + Modernize](https://github.com/hatch-baby/mobile/pull/1569)
* [[ArgumentKit Phase 5] SwiftUI UI](https://github.com/hatch-baby/mobile/pull/1573)
* [[ArgumentKit Phase 6] Remove NotificationCenter, update consumers](https://github.com/hatch-baby/mobile/pull/1574)
* [[ArgumentKit Phase 7] Add DocC catalogs](https://github.com/hatch-baby/mobile/pull/1593)
* [[ArgumentKit Phase 8] Migrate ArgumentKit into HatchModules](https://github.com/hatch-baby/mobile/pull/1594)



# Pushing, Linting, formatting
```zsh
# This will trigger pre-push git hook which runs lint checks
git push
# On lint fails, 
# pushd iOS/hatch-sleep-app && bundle exec fastlane format_all && bundle exec fastlane lint_all && popd
```
* [ ] how to run formatter code
* [ ] how to run pre-push hook
* 





---
# TODO: Re-Read AI Instructions / Rules

* [ ] AI platform specific
* [ ] docs/
* [ ] fully, recursively
* Prefer user config filepaths that are nested inside some directory in the user's home dir, if possible
  * Good: `~/.claude/.settings.json`  (not that this should be considered a legal/supported filepath. Always check official docs
  * Bad: `~/.claude.json`




# TODO: Refactoring code as a `Feature Module` under HatchModules

## Macros
* [ ] @Dependency
* [ ] #LogAll
* [ ] @StateCopyable
