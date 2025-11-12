
# Monorepo Scripts

## Swift6 Error Categories
* Write a zsh script that will:
* clean and compile our `Nightlight_Development` scheme
  * [ ] <command>
* collect all stdout/stderr logs while filtering the realtime output to only show compiler warnings
* At the end of the build, sort and categorize the errors by root message
  * Split each error into:
    * [ ] root error message <TODO: Example>
    * [ ] error variant <TODO: parts of the message that vary>
    * [ ] filename:line number <TODO: Example>
    * [ ] 
  * exclude things like filename, line number, and error specifiics to come up with a list of error categories
  * do retain the full error message though



## PR Adds <N> new warnings

## PR contains HatchModules resolve warnings
## PR breaks docc




# `docs`

* dont' rely on `get_errors` tool after making significant changes. Intead compile the smallest scheme which includes the changes (package target first, then app if needed)

* compile package first, then app if needed
  * I told agent to compile to find error while working in a module. it compiled the app
    * `xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -sdk iphonesimulator -destination 'platform=iOS Simulator,name=Any iOS Simulator Device'
 build 2>&1 | grep -A 5 "error:"`
```sh
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"
```


# How to configure copilot to see what it's thinkign in real time?

# Avoid filtering output. Instead use Tee
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"

or zome other approach where i can watch the output live
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"



--- 

# Fix HatchModule warnings

Invalid Resource 'Resources/Assets.xcassets': File not found.
Invalid Resource 'Resources/Localizable.xcstrings': File not found

dependency 'sdk_conversation_kit_ios' is not used by any target
dependency 'sdk_core_utilities_ios' is not used by any target
 

# zing workflow

# Swift Dependency Bridge

# Montly SPM Updates
* [ ] depenedantbot - generate a dep graph
* [ ] 

# N-1
one per year we drop support for the oldest iOS version that is currenntly supported. That's currently `iOS 17.0`. We need to increment this to the next major version `iOS 18.0`

This change needs to be made in:


## Nightlight.xcodeproj

Project Settings (Nightlight.xcodeproj/project.pbxproj)
![Xcode_project_settings](images/Xcode_project_settings.png)

Each target (Nightlight.xcodeproj/project.pbxproj) (there are 5 of them)
* this image shows one 1 of the 5
* Ideally the targets should fall back to the project setting. This is not how it is currently setup
![Xcode_nightlight_target_settings](images/Xcode_nightlight_target_settings.png)



## WalkingSkeletonApp.xcodeproj

Approach this in the same manner as `Nightlight.xcodeproj`


## Package.swift









# User Mapper and Avatar Miner
* functionality; Identify a user across services (typically within our company accounts)
  * Services: an application with user accounts (slack, github, git (sort of), jira, apple developer portal etc...). Please suggest some more services with APIs
  * Identify: means to find that same person on another service. Since there is no standard for user credentials across services, we will need to have a multitiered approach
    * in my experience I've found email address is the best way. 
      This can be tricky though:
        * Some user account email addresses might be using our current `hatch.co` domain, but others might have our older `hatchbaby.com` domain. It might be worth doing a fuzzy/regex match on the domain portion of email addresses
        * Some of our services allow users to bind a pre-existing account (and thus and email address of unknown domain and unknown name). Apple Developer is one of these. 
* inputs:
  * a user account of some sort. Probably best we use a struct with optional properties

  * git committer email
  * git user name
  * github username
    * maybe this can be converted to an email with GitHub APIs?
  * slack user
* outputs: 
  * email address for 
  * username

Our CI system uses a hard coded look up table. 
`iOS/hatch-sleep-app/fastlane/common/hatch.json`
```json
{
    "employees": [
        {
            "github": "zakkhoyt",
            "gitlab": "zakkhoyt",
            "gmail": "zakkhoyt",
            "hatchbaby_email": "zakkhoyt@hatchbaby.com",
            "hatch_email": "zakkhoyt@hatch.co",
            "jira": "Zakk Hoyt",
            "jira_id": "557058:b7e93ab1-1843-4e8c-994e-9ba18eab389e",
            "slack": "zakkhoyt",
            "slack_id": "U0J8WGDFB",
            "team": "iOS",
            "start_date": "2016-01-19",
            "isActive": true,
            "employeeType": "fulltime"
        }
    ]
}
```

## Services

Here are the services we are going to want to support at a minimum

Here is a python library I wrote a long time ago to do similar things as this goal. If nothing, this will show some (probably outdated) examples for interacting with some of these services and also shouldl contains some handy reference links
* /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/1/iOS/hatch-sleep-app/fastlane/scripts/hatchCI/hatchUtilities


## jira: 
**User / Profile Settings**
https://id.atlassian.com/manage-profile/profile-and-visibility


  * API Notes: /Users/zakkhoyt/Documents/notes/JIRA.md
  * manage api tokens: https://id.atlassian.com/manage-profile/security/api-tokens
  * /Users/zakkhoyt/code/repositories/hatch/hatch_mobile/HatchRaycast/scripts/jira_hsd.sh
  * /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/shell/bin/source/jira_notes/jira_notes.zsh
  * /Users/zakkhoyt/.zsh_home/utilities/.zsh_jira_utilities

**API**
  
## slack: 
**User / Profile Settings**
https://hatchbaby.slack.com/account/settings

**API**
* [slack API directory](https://docs.slack.dev/reference/methods)
* [users.list](https://api.slack.com/methods/users.list)
* [conversations.invite](https://api.slack.com/methods/conversations.invite)
* [conversations.setTopic](https://api.slack.com/methods/conversations.setTopic)
* [conversations.list](https://api.slack.com/methods/conversations.list)
  
**Notes**
* slack api notes: `/Users/zakkhoyt/Documents/notes/slack/SLACK_DEV.md`
* slack message and bot notes: `/Users/zakkhoyt/Documents/notes/slack/SLACK.md`

**Scripts**
* swift slack controller: /Users/zakkhoyt/code/repositories/hatch/hatch_mobile/HatchTerminal/Sources/HatchTerminalTools/APIService/SlackService.swift  
* /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/shell/_dev/slack/slack_post_image.zsh

## apple: 
**User / Profile Settings**
* [Apple Account/Profile Settings](https://account.apple.com/account/manage/section/information) 
* [AppStoreConnect API: Team Keys](https://appstoreconnect.apple.com/access/integrations/api)
* [AppStoreConnect API: Individual Keys](https://appstoreconnect.apple.com/access/integrations/api/individual-keys)

**API (AppStoreConnect)**
* [AppStoreConnect API](https://developer.apple.com/documentation/appstoreconnectapi)
* [AppStoreConnect API: Creating API Keys](https://developer.apple.com/documentation/appstoreconnectapi/creating_api_keys_for_app_store_connect_api) 
* [AppStoreConnect API: Users](https://developer.apple.com/documentation/appstoreconnectapi/users)
* [AppStoreConnect API: Get Users](https://developer.apple.com/documentation/appstoreconnectapi/get-v1-users)

**Other**
* [JSON Web Token spec: ](https://tools.ietf.org/html/rfc7519)

**Notes**

**Scripts**



## github: 
**User / Profile Settings**
* [GitHub: User Profile](https://github.com/settings/profile)
* [GitHub: Manage Access Tokens](https://github.com/settings/tokens)


**API**


* [GitHub: RESTful API](https://docs.github.com/en/rest?apiVersion=2022-11-28)
* [GitHub: Keeping your API credentials secureFollow these best practices to keep your API credentials and tokens secure.](https://docs.github.com/en/rest/authentication/keeping-your-api-credentials-secure)
* [GitHub: Scripting with the REST API and JavaScriptWrite a script using the Octokit.js SDK to interact with the REST API.](https://docs.github.com/en/rest/guides/scripting-with-the-rest-api-and-javascript)

* [GitHub: GH CLI](https://cli.github.com/). 
* [GitHub: GH CLI Manual](https://cli.github.com/manual/gh_api)



**Notes**
* Notes: GitHub API - /Users/zakkhoyt/Documents/notes/github/GITHUB_APIS.md
* Notes: GitHub API (restful) - /Users/zakkhoyt/Documents/notes/github/gh_cli/GHCLI_REST_API.md
* Notes: GitHub API (curl) - /Users/zakkhoyt/Documents/notes/github/gh_cli/GHCLI_API_CURL.md
* Notes: GitHub API (gh cli) - /Users/zakkhoyt/Documents/notes/github/gh_cli/GHCLI.md
* Notes: See all *.md files under: /Users/zakkhoyt/Documents/notes/github/**/*.md

**Scripts**
* $HOME/.zsh_home.zsh_hatch_sleep_github
* $HOME/.zsh_homeutilities/.zsh_github_utilities
* $HOME/.zsh_home.zsh_hatch_github
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/bin/github_tool_docs/reference/json/gh_pull_request.json5
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/bin/github_tool_docs/reference/json/gh_api_get_branches.json5
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/_dev/gh_menu.zsh
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/bin/github_tool_docs/github.swift
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/bin/github_tool
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/_dev/github_url_for.zsh
* $HOME/code/repositories/hatch/hatch_sleep/scripts/shell/_dev/zparseopts_github.zsh


**Other**
* GitHub CLI


## gravatar: 
**User / Profile Settings**
**API**
**Notes**



**Scripts**
/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/shell/_dev/hatch/repo_history.sh



I was thinking that for each service we could attempt to retrieve a few properties that are likely to exist across services

```swift
struct User {
  let username: String?
  let emailAddresses: [String]
  let userId: String?
  let firstName: String?
  let lastName: String?
  // other properties? 
}

```

```json
{
    "employees": [
        {
            "github_username": "zakkhoyt",
            "github_firstname": "zakk",
            "github_lastname": "zakkhoyt",
            "github_emails": [
              "zakkhoyt@hatchbaby.com",
              "sneeden@gmail.com"
            ],
            
            "hatchbaby_email": "zakkhoyt@hatchbaby.com",
            "hatchbaby_username": "zakkhoyt",
            "hatchbaby_firstname": "zakk",
            "hatchbaby_lastname": "hoyt",


            "hatch_email": "zakkhoyt@hatch.co",
            "hatch_username": "zakkhoyt",
            "hatch_firstname": "zakk",
            "hatch_lastname": "hoyt",

            "jira_username": "Zakk Hoyt",
            "jira_user_id": "557058:b7e93ab1-1843-4e8c-994e-9ba18eab389e",
            "slack_username": "zakkhoyt",
            "slack_id": "U0J8WGDFB",
            "meta": {
              "team": "iOS",
              "start_date": "2016-01-19",
              "isActive": true,
              "employeeType": "fulltime"
            }
        }
    ]
}
```
