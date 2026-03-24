
# MCP Servers at Hatch

> Overview of all Model Context Protocol (MCP) servers used (or recommended) for iOS development at Hatch.
> For config file path reference by AI platform, see [MCP_SERVERS.md](MCP_SERVERS.md).

## What is MCP?

The [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) is an open standard that lets AI assistants connect to external tools, data sources, and services. Once configured, your AI assistant can directly query Jira, browse Apple docs, run Xcode builds, search Slack, and more — without copy-pasting.

---

## Servers Summary

| Server Name               | File                                                             | Transport | Auth                              | Use at Hatch                                       |
| ------------------------- | ---------------------------------------------------------------- | --------- | --------------------------------- | -------------------------------------------------- |
| `XcodeBuildMCP`           | [XCODEBUILDMCP.md](servers/XCODEBUILDMCP.md)                    | stdio     | None                              | Build, test, run iOS/macOS apps                    |
| `apple-docs`              | [APPLE_DOCS_MCP.md](servers/APPLE_DOCS_MCP.md)                  | stdio     | None                              | Apple developer documentation + WWDC               |
| `apple-store`             | [APP_STORE_CONNECT_MCP.md](servers/APP_STORE_CONNECT_MCP.md)    | stdio     | App Store Connect API Key (.p8)   | App Store Connect: IAP, TestFlight, reviews, subs  |
| `atlassian-rovo-mcp`      | [ATLASSIAN_MCP.md](servers/ATLASSIAN_MCP.md)                    | HTTP      | Basic Auth (API token, 1 yr)      | Jira, Confluence (official Atlassian)              |
| `mcp-atlassian`           | [MCP_ATLASSIAN.md](servers/MCP_ATLASSIAN.md)                    | stdio     | API token (1 yr)                  | Jira, Confluence (3rd-party, Docker)               |
| `bugsee`                  | [BUGSEE_MCP.md](servers/BUGSEE_MCP.md)                          | HTTP      | Token-in-URL (long-lived)         | Crash reports, bug tracking                        |
| `github`                  | [GITHUB_MCP.md](servers/GITHUB_MCP.md)                          | HTTP      | GitHub OAuth / PAT                | PRs, issues, code search, CI                       |
| `slack` (korotovsky)      | [SLACK_MCP.md](servers/SLACK_MCP.md)                            | stdio     | XOXP token (long-lived)           | Search Slack, read threads                         |
| `figma`                   | [FIGMA_MCP.md](servers/FIGMA_MCP.md)                            | HTTP      | OAuth / Personal Access Token     | Design inspection, asset export                    |
| `intercom`                | [INTERCOM_MCP.md](servers/INTERCOM_MCP.md)                      | HTTP      | OAuth / API key                   | Customer support tickets                           |
| `gmail`                   | [GMAIL_MCP.md](servers/GMAIL_MCP.md)                            | HTTP      | Anthropic-managed                 | Gmail (via Claude.ai integrations)                 |
| `google-calendar`         | [GOOGLE_CALENDAR_MCP.md](servers/GOOGLE_CALENDAR_MCP.md)        | HTTP      | Anthropic-managed                 | Calendar (via Claude.ai integrations)              |
| `granola`                 | [GRANOLA_MCP.md](servers/GRANOLA_MCP.md)                        | HTTP      | OAuth                             | Meeting notes and transcripts                      |
| `statsig`                 | [STATSIG_MCP.md](servers/STATSIG_MCP.md)                        | TBD       | TBD                               | Feature flags, experiments (planned)               |

---

## Quick Start: Most Useful Servers for iOS Dev

### 1. `XcodeBuildMCP` — Build & Test

61+ tools for Xcode, Swift, and iOS development. **Highest priority** for iOS engineers.

```shell
# Add to Claude Code (user scope):
claude mcp add --scope user --transport stdio XcodeBuildMCP -- xcodebuildmcp mcp
```

Key tools: `doctor`, `discover_projs`, `list_schemes`, `swift_package_build`, `swift_package_test`, `simulator_*`

→ [Full docs](servers/XCODEBUILDMCP.md)

---

### 2. `mcp-atlassian` — Jira & Confluence

Best option for Jira: API tokens last 1 year. Uses Docker or `uvx`.

```sh
# .env file at: $HOME/.hatch/config/vscode/mcp-atlassian.env
JIRA_URL=https://hatchbaby.atlassian.net
JIRA_USERNAME=<you>@hatch.co
JIRA_API_TOKEN=<token from https://id.atlassian.com/manage-profile/security/api-tokens>
```

→ [Full docs](servers/MCP_ATLASSIAN.md)

---

### 3. `atlassian-rovo-mcp` — Official Atlassian MCP

Official server from Atlassian. Supports API tokens as of March 2026.

```zsh
# Create basic auth token:
echo -n "you@hatch.co:YOUR_API_TOKEN" | base64
```

Then use `Authorization: Basic <base64>` header.

→ [Full docs](servers/ATLASSIAN_MCP.md)

---

### 4. `apple-docs` — Apple Documentation

Zero-auth. Searches Apple developer docs, WWDC sessions, sample code.

```shell
claude mcp add --scope user --transport stdio apple-docs -- npx -y @kimsungwhee/apple-docs-mcp
```

→ [Full docs](servers/APPLE_DOCS_MCP.md)

---

### 5. `bugsee` — Crash Reports

Token is embedded in the URL. Get your token at [app.bugsee.com/settings](https://app.bugsee.com/#/settings/user/integrations).

```jsonc
{
  "servers": {
    "bugsee": {
      "type": "http",
      "url": "https://api.bugsee.com/mcp/<YOUR_TOKEN>"
    }
  }
}
```

→ [Full docs](servers/BUGSEE_MCP.md)

---

### 6. `slack` — Search Slack

Uses korotovsky's server with a long-lived XOXP token.

```zsh
export SLACK_MCP_XOXP_TOKEN="xoxp-..."  # Add to ~/.zshrc
```

→ [Full docs](servers/SLACK_MCP.md)

---

## Config File Locations by AI Platform

See [MCP_SERVERS.md](MCP_SERVERS.md) for the full table of config file paths by platform, interface, and scope.

Quick reference:

| Platform         | User Config Path                                                        | Key          |
| ---------------- | ----------------------------------------------------------------------- | ------------ |
| Claude Code      | `~/.claude.json`                                                        | `mcpServers` |
| Claude Desktop   | `~/Library/Application Support/Claude/claude_desktop_config.json`      | `mcpServers` |
| VSCode Copilot   | `~/Library/Application Support/Code/User/mcp.json`                     | `servers`    |
| Cursor           | `~/.cursor/mcp.json`                                                    | `mcpServers` |
| Windsurf         | `~/.codeium/windsurf/mcp_config.json`                                   | `mcpServers` |

> **Note**: VSCode/GitHub Copilot uses `"servers"` as the JSON key. All other platforms use `"mcpServers"`.

---

## Config Templates

Complete config files are under `ai/mcp/configs/`:

| Directory              | Contents                                              |
| ---------------------- | ----------------------------------------------------- |
| `configs/templates/`   | Placeholder configs — no real tokens                  |
| `configs/env_vars/`    | Configs using `${ENV_VAR}` references + `.env.example`|
| `configs/tokens/`      | Configs with real tokens — **gitignore these files**  |

---

## References

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP Servers Registry](https://github.com/modelcontextprotocol/servers)
- [Search: Awesome MCP Servers](https://mcpservers.org/search)
- [Anthropic Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [VSCode MCP docs](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Cursor MCP docs](https://docs.cursor.com/context/model-context-protocol)
