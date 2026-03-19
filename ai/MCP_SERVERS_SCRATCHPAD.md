
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











