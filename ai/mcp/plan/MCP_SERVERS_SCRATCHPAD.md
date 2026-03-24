
* re-read AI instructions before beginning. Apply thorughout
* You can authenticate with some of the services mentioned in this document by:
  * Using `zsh` instead of `bash` 
    * Upon launching, run: `source "/.zshrc"`
    * This will provide you authentication keys/tokens for things like: 
      * `gh` (CLI)
      * JIRA restful API
        * See jira references:
          * notes: /Documents/notes/JIRA.md
          * zsh: 
            * library/helpers: /.zsh_home/utilities/.zsh_jira_utilities
            * examples
              * /code/repositories/hatch/hatch_sleep/scripts/shell/_packages/jira_notes/jira_notes.zsh
              * /code/repositories/hatch/hatch_sleep/scripts/shell/_packages/jira_notes/**/*
          * fastlane/ruby examples: 
            * $HOME/code/repositories/hatch/hatch_sleep/2/iOS/hatch-sleep-app/fastlane/common
            * $HOME/code/repositories/hatch/hatch_sleep/2/iOS/hatch-sleep-app/fastlane/common
      * Slack restful API
        * references:
          * notes: /Documents/notes/slack/SLACK*.md
          * zsh exmaples: /code/repositories/hatch/hatch_sleep/scripts/shell/_dev/slack/**/*
          * slack Examples: $HOME/code/repositories/hatch/hatch_mobile/HatchTerminal/**/*
          * fastlane/ruby examples: $HOME/code/repositories/hatch/hatch_sleep/2/iOS/hatch-sleep-app/fastlane/common
      * Bugsee: 
        * https://docs.bugsee.com/
    * 


# Goals
I want to put together some sets of documents about MCP Servers that are useful for working on iOS code at hatch. 

## docs
More details on these below, but:
* research: find all details about all mcp servers mentioned in a series of data sources. Source, details.
* refine: From this create a document for each server. Consistent formatting across, example configus for each AI engine (different scopes). Links to official docs throghout.  These should be good enough to use as AI references
* summary document: an overview of all of the refined docs ^, links to them
  

# Sources
## Local Notes/Files
* `$HOME/Documents/notes/ai/mcp/**/*.md`
* `$HOME/Documents/notes/ai/**/*MCP*.md`
* `$HOME/Documents/notes/github/mcp/**/*.md`
* `$HOME/Documents/notes/ai/**/*.md`

## VSCode Settings

I want you to scrape to see what you can find about MCP server, configurations (json, etc) by scraping VSCode files. Be sure to retain any comments that correlate
* [ ] VSCode User Settings: `$HOME/Library/Application Support/Code/User/settings.json`
* [ ] VSCode USer MCP settings: `$HOME/Library/Application Support/Code/User/mcp.json`
  

## Slack
* [This thread](https://hatchbaby.slack.com/archives/C069UBDPYS3/p1773695982924349?thread_ts=1773679538.852139&cid=C069UBDPYS3) was with the iOS dev team about which mcp servers are used/liked
* `@lorraine` listed:
  * XcodeBuildMCP (this one is valid, matches other data sources)
  * GitHub (what's the full name? Server address?)
    * There seems are
  * Jira (which one? You will find two listed in the data sources here. Which is lorraine using?)
  * Bugsee (what's the full name? Server address?)
  * Figma (what's the full name? Server address?)
  * Google CLI (used for what?)
  * Statsig (lorraine mentioned wanting to use this one)


* [Another Slack thread about MCP configs](https://hatchbaby.slack.com/archives/C069UBDPYS3/p1773868711977689): 
  

## Local Repositories
* ripgrep (`rg`) is available on this computer
* When searching through repos, be sure to ignore `**/.build/**` 
* When looking through these repos, be sure to look in `.github/**`, `.claude/**`, `CLAUDE.md`, (all standard AI configs locations)
  * In other words, include hidden files (`rg`'s `-u -u -u` argument)

### Search Terms
Maybe iterate through a list of known mcp server names, and the term `mcp`:
```zsh
for term in (mcp xcodebuildmcp atlassian-mcp '"servers": {' '"command": "'); do 
  rg  -u -u -u --ignore-case "${term}" .
done
```

### Filename of Interest

VSCode normally uses `mcp.json`, but these settings can reside in other VSCode files too:

One example is `docs/ideas/zsh_for_swift_programmers/references/HatchTerminal/.vscode/mcp.json` (read this one)

* `**/mcp.json`
* `**/*.code-workspace`
* `**/settings.json`


* `**/*.json`

This repository is used to configure target repositories for use wiht AI. As such it does merge some MCP servers into the target VSCode files. Look through the sources. Be sure to retain any comments that correlate



* `/conductor/workspaces/.ai/san-francisco/**/*.json`
* `/conductor/workspaces/.ai/san-francisco/**/mcp.json`
* `/conductor/workspaces/.ai/san-francisco/**/settings.json`
* `/conductor/workspaces/.ai/san-francisco/**/*.code-workspace`





* Have a look through these repositories.
  * `$HOME/code/repositories/hatch/hatch_sleep/2/`


### @claude
I had @claude extract MCP servers from slack. I was expecting a search through chat but it returned its slack configs which are def useful

```slack
Zakk Hoyt  [2:52 AM]
Can you extract information about MCP servers? List of servers, names, and configs would be ideal. Links to docs that might contains that stuff
Claude  [2:53 AM]
Based on the configuration I have access to, here are the MCP servers connected to your Claude account:
| # | Name | MCP Server URL |
|---|------|---------------|
| 1 | Figma | https://mcp.figma.com/mcp |
| 2 | Intercom | https://mcp.intercom.com/mcp |
| 3 | Atlassian | https://mcp.atlassian.com/v1/sse |
| 4 | Gmail | https://gmail.mcp.claude.com/mcp |
| 5 | Google Calendar | https://gcal.mcp.claude.com/mcp |
| 6 | Slack | https://mcp.slack.com/mcp |
| 7 | Granola | https://mcp.granola.ai/mcp |
---
Docs / Links that may help:
Figma MCP — figma.com/developers (check their developer docs for MCP details)
Intercom MCP — developers.intercom.com
Atlassian MCP — developer.atlassian.com
Gmail / Google Calendar MCP — These appear to be Anthropic-hosted endpoints*.mcp.claude.com`), so configuration likely lives in your Claude.ai integrations settings
Slack MCP — api.slack.com
Granola MCP — granola.ai
General MCP Docs (Anthropic) — docs.anthropic.com/en/docs/mcp
-------------------------
A couple of notes:
The Gmail and Google Calendar servers use Anthropic-managed endpoints, meaning the auth/config is handled through Claude.ai's connector settings rather than a self-hosted config.
The Atlassian server uses SSE (/v1/sse), while the others appear to use standard MCP over HTTP.
Want me to dig into any specific server's capabilities or tooling?
```


Here's a JSON config representing your connected MCP servers, formatted for use with tools like Claude Desktop (claude_desktop_config.json) or similar MCP clients:{
```json
"mcpServers": {
  "figma": {
    "url": "https://mcp.figma.com/mcp",
    "transport": "http"
  },
  "intercom": {
    "url": "https://mcp.intercom.com/mcp",
    "transport": "http"
  },
  "atlassian": {
    "url": "https://mcp.atlassian.com/v1/sse",
    "transport": "sse"
  },
  "gmail": {
    "url": "https://gmail.mcp.claude.com/mcp",
    "transport": "http"
  },
  "google-calendar": {
    "url": "https://gcal.mcp.claude.com/mcp",
    "transport": "http"
  },
  "slack": {
    "url": "https://mcp.slack.com/mcp",
    "transport": "http"
  },
  "granola": {
    "url": "https://mcp.granola.ai/mcp",
    "transport": "http"
  }
}
```
A few caveats:
* Auth tokens are not exposed — these servers require OAuth or API key



## Google Docs

Looks like maybe someone is putting together series of docs for this (one MCP server per doc). There is only one so far


### xcodebuildmcp
* [xcodebuildmcp](https://docs.google.com/document/d/1Qmpdh4kxbw1IAnX0fIUP-Jt5QbbZgnpIlyuZt1GtW6I/edit?tab=t.j7pcl869nu23#heading=h.t8nsck8539rs)


<details name="xcodebuildmcp">
<summary>expand to see doc contents</summary>

````markdown

 [XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)

# **Setup**

## **Cursor**

1. Go to Cursor \> Settings… \> Cursor Settings.  
2. Select Tools & MCP on the side menu.  
3. Click New MCP Server to open the `mcp.json` file.  
4. Edit it to include the following:

```
{
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec npx -y xcodebuildmcp@latest mcp"
      ],
      "env": {
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "simulator,ui-automation"
      }
    }
  }
}
```

## **Claude Code**

```shell
claude mcp add --scope user --transport stdio XcodeBuildMCP -- xcodebuildmcp mcp
```

That adds something like the following to your `$HOME/.claude.json` file:

```json
"mcpServers": {
   "XcodeBuildMCP": {
     "type": "stdio",
     "command": "/bin/zsh",
     "args": [
       "-lc",
       "npx -y xcodebuildmcp@latest mcp"
     ],
     "env": {
       "XCODEBUILDMCP_ENABLED_WORKFLOWS": "simulator,ui-automation"
     }
   }
 },
```

## **VS Code Copilot**

1. COMMAND-SHIFT-P  
2. Search and select MCP: Open User Configuration  
3. Edit the `mcp.json` file to include the following:

```json
		"XcodeBuildMCP": {
			"type": "stdio",
			"command": "/bin/zsh",
			"args": [
				"-lc",
				"exec npx -y xcodebuildmcp@latest mcp"
			],
			"env": {
				"XCODEBUILDMCP_ENABLED_WORKFLOWS": "simulator,ui-automation"
			}
		}
```

````

</details>




# Action Items
## Mine
* Mine MCP Servers: Search, find, scour, extract any MCP servers using all of the data sources mentioned above
  * Append to a summary document about each MCP server that you discover: `docs/ai/mcp/plan/MCP_SERVERS_MINING.md`
  * Add a section for each server (titled by server name)
    * mining source
    * all details from mining. 
    * aggregate data from multiple sources
    * include json/configuration code (include any AUTH / API values for now)
    * include any comments adjacent to the configuration code
    * include any commented out MCP servers discovered as well. 
    * include multiple servers for the same service> EX: you will find multiple atlassian servers
## Refine
* Reminder to follow AI instructions for markdown documents (references, footnotes, etc...) written in this section
* For each MCP server that we do find, create a dedicated document for it
  * `docs/ai/mcp/servers/${mcp_server_name}.md` (UPPER_SNAKE_CASE if possible)
    * EX: `docs/ai/mcp/servers/${XCODEBUILDMCP}.md`
    * Content should use the same formatting / syntax from the  [XcodebuildMCP Google Doc above](#xcodebuildmcp) example above (to start with)
      * This will require some exatrapolation and some researching from official docs, etc...
    * Refine ruther by filling in any missing information (EX: links to homepage, docs, where to obtain auth tokens, example commands, how to use)
    * These files should include configuration snippets for each AI service, and possibly two scopes: 
      * In a repository 
      * At a user level. 
      * Include a comment or some sort of information about how to provide the tokens to the configs via env vars. Where do those have to be defined (~/.zshrc, `.../.vscode/.env`?)? Does the Ai software need to be launced on command line?
* Create an overview file: `docs/ai/mcp/MCP_SERVERS_HATCH.md` this should list a quicksummary of all of the servers
  * Name, homepage, descriptoin, what it's useful for, a few of the most useful commands



## Possible config files
* List all possible config file paths (where mpc server config data is stored). 
  * for each service (claude, copilot, etc...), 
    * And for each interface which that service can be used (command line, dedicated GUI app, grouped GUI app (like VSCode, or VSCode extensions. Or copilot via Xcode IDE))
      * And for each supported scope supported by config files

What i mean by this is:
* Some AI services ship with thier own GUI app (claude, chatgpt, etc..)
* Some AI services ship as a command line application (claude cli, copilot cli)
* SOme AI services are accessible through additional interfaces
  * claude can be used via `claude cli`, `claude app`, via `vscode's copilot` interface, through `GitHub Copilot for Xcode` (app extension), etc..
* Additionally some of these support defining settings at different scope levels (User vs workspace vs folder)

I want you to create a list in `ai/mcp/MCP_SERVERS.md` that contins all possible config file locations (full permutation). 
Express this as a table or set of tables. 
* use only official documentation for source of truth (no guessing, no treating *.md files as truth)


* Please include all AI platforms  mentioned in this repo as well as all officially supported interfaces (cli, app, app extensions, etc...) on a normal macOS computer




## Configuration Files
* For each AI service (claude cli, claude desktop, copilot cli, vscode, etc...), put to together some configuration files. Under `docs/ai/mcp/configs/templates`
  * A user level configurations file with every server represented with comments, json, but missing the auth token (links where to create it though)
  * A folder/repo level configurations file with every server represented with comments, json, but missing the auth token (links where to create it though)
* Then create the same variants but **WITH** the minde auth tokens or env vars populated. Include additional files if needed (such as `.env`).  Under `docs/ai/mcp/configs/env_vars`
  * A user level configurations file with every server represented with comments, json, but WITH the tokens (links where to create it though)
  * A folder/repo level configurations file with every server represented with comments, json, but WITH the tokens (links where to create it though)
* Then create the same variants but **WITH** the minded auth tokens populated. Under `docs/ai/mcp/configs/tokens`
  * A user level configurations file with every server represented with comments, json, but WITH the tokens (links where to create it though)
  * A folder/repo level configurations file with every server represented with comments, json, but WITH the tokens (links where to create it though) 




---


# Specifics for Generated
I've reviewed some of the documents that you have been creating per the plan. I want to make some changes to the formatting and content of these documents:

## `~/Library/Application Support/Code/User/mcp.json` 
I've been using VSCode as my main AI interface until just recently. This is also where I've been testing out all things MCP related:
* Generally, this file should be READ ONLY from your/Agent's perspective. 
  * This is because I use this file for configuring, testing, and writing comments about the whole MCP setup and configuration
* However this file also serves as one fo the main data sources for the feature branch that we are working on right now
* I'd like you to help me to get this file up to my own standards:
* Comments are allowed in every AI config file that I've come across so far so help me check what my file is missing at this point. 
* After we get it updated then I want you to use this as a reference and data source for  all of the other config files that you are generating under `~/conductor/workspaces/.ai/san-francisco/ai/mcp/configs/templates`
* All commments fill be expressed as `markdown` syntax
  * URLs will be markdown links. Please follow the established convention for link formatting


Goals for this file:
* For each server listed in the file, there should be a multiline comment above with this formatting


```markdown
# About
<!-- MCP_SERVER_NAME - MCP_SERVER_DESCRIPTION -->

# References
* <!-- MCP SERVER HOMEPAGE -->
* <!-- MCP SERVER AUTHENTICAION PAGE -->
* <!-- SERVICE AUTHENTICAION or AUTH TOKEN PAGE (if required) -->

# Installation
<!-- If local install of any tools/servers is required, add a link here -->

<!-- 
If local install of any tools/servers is required, copy setup commands here in a zsh code fence (if possible). 
  
IE: `brew install ...` or smilar
-->


# Authorization
<!-- 
an order list of steps for configuring / authorization

1) ...
  * abc
  * def
2) ...
  * ABC
  * DEF
-->
```

Here is a jsonc example taken from `mcp.json`
```jsonc
		// # About
		// atlassian-rovo-mcp - Official MCP server for Atlassian products (Jira, Confluence, etc) via Rovo MCP Server (https://mcp.atlassian.com/)
		//
		// # References
    // * [Atlassian: Rovo MCP Server - Getting Started](https:support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
    // * [Atlassian: Rovo MCP Server - Configuring Authenticating via API Token](https:support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
    // 
    // # Installation
    // None Required
    // 
    // # Authorization
    // 1) Create a `(Scoped) Atlassian User API token`
    //   * Create a (Scoped) Personal API Token 
    //   * Preconfigured Properties:[Atlassian: Create Personal API token for Rovo MCP Server](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
    // 2) Create a `Basic Authorization` Hash
    //   * Create a `Basic Authorization` Hash from user.email and API token (joined by ":") 
    //   * Copy into terminal: `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
		"atlassian-rovo-mcp": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        "Authorization": "Basic [redacted: basic auth hash]"
			}
		},
```


**Action Items**

* [ ] Review the comments of each MCP server in `~/Library/Application Support/Code/User/mcp.json`. 
  * `"atlassian-rovo-mcp"` is configured according the above, but the others are not
  * Please don't modify my actual file, but create a variant where you apply the comment formatting detailed above to each servers. 
    * Create dirs and write it to `~/conductor/workspaces/.ai/san-francisco/ai/mcp/configs/templates/.gitignored/configs/vscode/user/mcp.json`
  * If needed, you may use files in `~/Documents/notes/ai/mcp/**/*` to fetch / fill in details
  * RE: The header comment. I think it's probably redundant and can be removed
* [ ] Once I review and agree with the new `mcp.json`, please update your plan files and my plan files to include this spec

* I've also updated `~/Documents/notes/ai/mcp/servers/ALASSIAN_MCP_CHEATSHEET.md` in a similar manner. Please consider this as example and add anything you think is useful for the syntax when generating: `~/conductor/workspaces/.ai/san-francisco/ai/mcp/servers/*.md` 



Regarding: `~/conductor/workspaces/.ai/san-francisco/ai/mcp/configs/templates/.gitignored/configs/vscode/user/mcp.json`

not bad but I didn't address somethigns:
* Within the actual json portion for eaach server, there are some comment in some, others no comments.
EX: 
```json
				// Prefer: set SLACK_MCP_XOXP_TOKEN in your shell environment
				// "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
```

I left these with the intent to make it easier to change common config values. I'm not sure if these are actually helpful though. 
* Please read each, then report back to me about each. Please recommmend if they shoud stay (as is), stay (with modification), or go. 
  * Just print in the chat


* Also in each server's comments, under the `# References` Section, we should add a link to an `env vars/config` web page (if one exists)





