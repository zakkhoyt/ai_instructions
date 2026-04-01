
# MCP Servers for iOS Development at Hatch

> Overview of all Model Context Protocol (MCP) servers recommended for iOS development at Hatch.
> For config file paths by AI platform, see [mcp-config-paths.md](mcp-config-paths.md).

## What is MCP?

The [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) is an open standard that lets AI assistants connect to external tools, data sources, and services. Once configured, your AI assistant can directly query Jira, browse Apple docs, run Xcode builds, search Slack, and more — without copy-pasting.

---

## Servers Summary

| Server Name               | File                                                                           | Transport | Auth                              | Use at Hatch                                       |
| ------------------------- | ------------------------------------------------------------------------------ | --------- | --------------------------------- | -------------------------------------------------- |
| `XcodeBuildMCP`           | [ios-servers/ios-xcodebuild-mcp.md](servers/ios-xcodebuild-mcp.md)                        | stdio     | None                              | Build, test, run iOS/macOS apps                    |
| `apple-docs`              | [ios-apple-docs-mcp.md](servers/ios-apple-docs-mcp.md)                        | stdio     | None                              | Apple developer documentation + WWDC               |
| `apple-store`             | [ios-app-store-connect-mcp.md](servers/ios-app-store-connect-mcp.md)          | stdio     | App Store Connect API Key (.p8)   | App Store Connect: IAP, TestFlight, reviews, subs  |
| `atlassian-rovo-mcp`      | [atlassian-mcp.md](servers/atlassian-mcp.md)                                  | HTTP      | Basic Auth (API token, 1 yr)      | Jira, Confluence (official Atlassian)              |
| `mcp-atlassian`           | [mcp-atlassian.md](servers/mcp-atlassian.md)                                  | stdio     | API token (1 yr)                  | Jira, Confluence (3rd-party alternative)           |
| `bugsee`                  | [bugsee-mcp.md](servers/bugsee-mcp.md)                                | HTTP      | Token-in-URL (long-lived)         | Crash reports, bug tracking                        |
| `github`                  | [github-mcp.md](servers/github-mcp.md)                                        | stdio     | GitHub PAT                        | PRs, issues, code search, CI                       |
| `slack`                   | [slack-mcp.md](servers/slack-mcp.md)                                          | stdio     | XOXP token (long-lived)           | Search Slack, read threads                         |
| `figma`                   | [figma-mcp.md](servers/figma-mcp.md)                                          | HTTP      | OAuth / Personal Access Token     | Design inspection, asset export                    |
| `statsig`                 | [statsig-mcp.md](servers/statsig-mcp.md)                                      | TBD       | TBD                               | Feature flags, experiments (planned)               |
| `google-workspace`        | [google-workspace.md](servers/google-workspace.md)                            | stdio     | OAuth (client JSON + per-user)    | Docs, Drive, Gmail, Calendar, Sheets, and more     |
| `sourcekit-lsp`           | [ios-sourcekit-lsp.md](servers/ios-sourcekit-lsp.md)                          | stdio     | None (bundled with Xcode)         | Swift code intelligence: hover, go-to-def, refs    |
| `intercom`                | [intercom-mcp.md](servers/intercom-mcp.md)                                     | HTTP      | OAuth / API key                   | Customer support tickets                           |
| `gmail`                   | [gmail-mcp.md](servers/gmail-mcp.md)                                           | HTTP      | Anthropic-managed                 | Gmail (via Claude.ai integrations)                 |
| `google-calendar`         | [google-calendar-mcp.md](servers/google-calendar-mcp.md)                       | HTTP      | Anthropic-managed                 | Calendar (via Claude.ai integrations)              |
| `granola`                 | [granola-mcp.md](servers/granola-mcp.md)                                       | HTTP      | Granola OAuth                     | Meeting notes and transcripts                      |

---

## Quick Start: Most Useful Servers for iOS Dev

### 1. `XcodeBuildMCP` — Build & Test

61+ tools for Xcode, Swift, and iOS development. **Highest priority** for iOS engineers.

```zsh
# Add to Claude Code (user scope):
claude mcp add --scope user --transport stdio XcodeBuildMCP -- xcodebuildmcp mcp
```

Key tools: `doctor`, `discover_projs`, `list_schemes`, `swift_package_build`, `swift_package_test`, `simulator_*`

→ [Full docs](servers/ios-xcodebuild-mcp.md)

---

### 2. `apple-docs` — Apple Documentation

Zero-auth. Searches Apple developer docs, WWDC sessions, sample code.

```zsh
claude mcp add --scope user --transport stdio apple-docs -- npx -y @kimsungwhee/apple-docs-mcp
```

→ [Full docs](servers/ios-apple-docs-mcp.md)

---

### 3. Atlassian — Jira & Confluence

Two options; use the official server first and fall back to the 3rd-party if needed.

#### 3a. `atlassian-rovo-mcp` — Official Atlassian MCP

Official server from Atlassian. Supports API tokens as of March 2026.

```zsh
# Create basic auth token:
echo -n "you@hatch.co:YOUR_API_TOKEN" | base64
```

Then use `Authorization: Basic <base64>` header.

→ [Full docs](servers/atlassian-mcp.md)

#### 3b. `mcp-atlassian` — 3rd-Party Alternative

Best fallback for Jira: API tokens last 1 year. Uses Docker or `uvx`.

```zsh
# .env file at: $HOME/.hatch/config/vscode/mcp-atlassian.env
JIRA_URL=https://hatchbaby.atlassian.net
JIRA_USERNAME=<you>@hatch.co
JIRA_API_TOKEN=<token from https://id.atlassian.com/manage-profile/security/api-tokens>
```

→ [Full docs](servers/mcp-atlassian.md)

---

### 4. `bugsee` — Crash Reports

Token is embedded in the URL. Get your token at [app.bugsee.com/settings](https://app.bugsee.com/#/settings/user/integrations).

```jsonc
{
  "servers": {
    "bugsee": {
      "type": "http",
      "url": "https://api.bugsee.com/mcp/<YOUR_BUGSEE_MCP_TOKEN>"
    }
  }
}
```

→ [Full docs](servers/bugsee-mcp.md)

---

### 5. `slack` — Search Slack

Uses korotovsky's server with a long-lived XOXP token.

**Token**: LastPass → `Shared-iOS-devs` → `MCP` → `SLACK_MCP_XOXP_TOKEN`

```zsh
export SLACK_MCP_XOXP_TOKEN="xoxp-..."  # Add to ~/.zshrc
```

→ [Full docs](servers/slack-mcp.md)

---

### 6. `github` — GitHub

Pull requests, issues, code search, CI status.

→ [Full docs](servers/github-mcp.md)

---

### 7. `apple-store` — App Store Connect

Manage IAP, TestFlight builds, reviews, and subscriptions. Requires an App Store Connect API key (`.p8` file).

→ [Full docs](servers/ios-app-store-connect-mcp.md)

---

### 8. `figma` — Design Inspection

Inspect Figma designs, export assets, read design tokens directly from chat.

→ [Full docs](servers/figma-mcp.md)

---

### 9. `statsig` — Feature Flags *(planned)*

Feature flag and experiment management via Statsig.

→ [Full docs](servers/statsig-mcp.md)

---

### 10. `google-workspace` — Google Workspace

Docs, Drive, Gmail, Calendar, Sheets, Forms, Tasks, and Contacts — all in chat.

**Client JSON**: LastPass → `Shared-iOS-devs` → `MCP` → `GOOGLE_WORKSPACE`

1. Copy the OAuth client JSON to `~/.zsh_home/tokens/mcp/google/google_mcp_client.json`
2. Add env vars to `~/.zshrc`:

```zsh
export GOOGLE_MCP_CLIENT_SECRET_PATH="$HOME/.zsh_home/tokens/mcp/google/google_mcp_client.json"
export GOOGLE_MCP_USER_EMAIL="you@hatch.co"
```

3. Add to Claude Code:

```zsh
claude mcp add --scope user --transport stdio google-workspace -- uvx workspace-mcp --single-user
```

On first use a browser OAuth prompt appears — sign in once, tokens cache locally.

→ [Full docs](servers/google-workspace.md)

---

### 11. `sourcekit-lsp` — Swift Code Intelligence *(Claude Code only)*

Gives Claude real-time Swift code intelligence: go-to-definition, hover docs, cross-module references, and diagnostics. Ships with Xcode — no install needed.

> **LSP, not MCP**: This uses Claude Code's `.lsp.json` config, not the MCP `mcpServers` config. See [`configs/templates/claude_code_lsp.json`](configs/templates/claude_code_lsp.json) for the ready-to-use template.

The config is already committed to the repo at `.claude/.lsp.json`. If you've pulled `main`, no action is needed. To apply manually:

```zsh
# Verify the binary is available:
xcrun --find sourcekit-lsp
```

Then copy [`configs/templates/claude_code_lsp.json`](configs/templates/claude_code_lsp.json) to `.claude/.lsp.json` in the repo root.

→ [Full docs](servers/ios-sourcekit-lsp.md)

---

## Config File Locations by AI Platform

See [mcp-config-paths.md](mcp-config-paths.md) for the full table of config file paths by platform, interface, and scope.

Quick reference:

| Platform         | User Config Path                                                       | Key          |
| ---------------- | ---------------------------------------------------------------------- | ------------ |
| Claude Code      | `~/.claude.json`                                                       | `mcpServers` |
| Claude Desktop   | `~/Library/Application Support/Claude/claude_desktop_config.json`     | `mcpServers` |
| VSCode Copilot   | `~/Library/Application Support/Code/User/mcp.json`                    | `servers`    |
| Cursor           | `~/.cursor/mcp.json`                                                   | `mcpServers` |
| Windsurf         | `~/.codeium/windsurf/mcp_config.json`                                  | `mcpServers` |

> **Note**: VSCode/GitHub Copilot uses `"servers"` as the JSON key. All other platforms use `"mcpServers"`.

---

## Config Templates

Complete config files are under `configs/`:

| Directory                         | Contents                                                |
| --------------------------------- | ------------------------------------------------------- |
| `configs/templates/hard_coded_tokens/`   | Placeholder configs — fill in actual token values       |
| `configs/templates/env_var_tokens/`      | Configs using `${ENV_VAR}` references + `.env.example`  |
| `configs/templates/env_var_tokens/zsh/`  | Same as above, but vars sourced from `~/.zshrc`         |

---

## References

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP Servers Registry](https://github.com/modelcontextprotocol/servers)
- [Search: Awesome MCP Servers](https://mcpservers.org/search)
- [Anthropic Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [VSCode MCP docs](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Cursor MCP docs](https://docs.cursor.com/context/model-context-protocol)
