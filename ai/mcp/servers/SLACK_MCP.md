
# Slack MCP (korotovsky)

> Read Slack channels, threads, and user profiles from any AI agent using a long-lived XOXP token.

## Overview

- **GitHub**: [github.com/korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
- **npm package**: [`slack-mcp-server`](https://www.npmjs.com/package/slack-mcp-server)
- **Auth setup guide**: [github.com/korotovsky/slack-mcp-server/docs/01-authentication-setup.md](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)

`slack-mcp-server` by korotovsky is a third-party MCP server that connects to the Slack API using a `XOXP` user token. It exposes tools for reading channels, searching messages, reading threads, and looking up user profiles.

**Why useful for Hatch iOS dev:**
- Search Slack discussions without switching to the Slack app.
- Reference Slack threads in the AI session when debugging issues or reading context.
- Look up teammates' profiles or contact information inline.

> **Note**: Claude.ai and Claude Desktop also offer an official Anthropic-managed Slack MCP connector at `mcp.slack.com/mcp` (OAuth). The korotovsky server is preferred for agent use because the `XOXP` token is long-lived (no OAuth re-auth cycle).

---

## Authentication

**Preferred method: XOXP user token (long-lived)**

A Slack `xoxp-` token grants access to the Slack workspace on behalf of your user account. Unlike OAuth app flows that may require periodic reauthorization, XOXP tokens remain valid until explicitly revoked.

**How to obtain a token:**
1. Open the Slack app settings for the MCP integration:
   - [app.slack.com → App Settings → OAuth & Permissions](https://app.slack.com/app-settings/T03TR3R94/A0AMLQF741Y/oauth)
2. Copy the **User OAuth Token** (starts with `xoxp-`)
3. Store it in an environment variable — never embed it directly in committed config files

---

## Environment Variables

| Variable               | Description                                                  | Required |
| ---------------------- | ------------------------------------------------------------ | -------- |
| `SLACK_MCP_XOXP_TOKEN` | Slack user OAuth token (`xoxp-...`) for the MCP integration | Yes      |

**Set in `~/.zshrc`:**

```zsh
export SLACK_MCP_XOXP_TOKEN="xoxp-your-token-here"
```

---

## Setup

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // Slack MCP (korotovsky) — XOXP user token
    // Token: https://app.slack.com/app-settings/.../oauth
    "slack": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "slack-mcp-server@latest", "--transport", "stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  "servers": {
    // Slack MCP (korotovsky) — XOXP token from env var
    "slack": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "slack-mcp-server@latest", "--transport", "stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio slack -- \
  npx -y slack-mcp-server@latest --transport stdio
```

Resulting entry in `~/.claude.json`:

```json
{
  "mcpServers": {
    "slack": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y slack-mcp-server@latest --transport stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```json
{
  "mcpServers": {
    "slack": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y slack-mcp-server@latest --transport stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  "mcpServers": {
    // Slack MCP (korotovsky) — XOXP token from env var
    // Note: Claude Desktop must be launched from terminal to inherit SLACK_MCP_XOXP_TOKEN.
    "slack": {
      "command": "npx",
      "args": ["-y", "slack-mcp-server@latest", "--transport", "stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```json
{
  "mcpServers": {
    "slack": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec npx -y slack-mcp-server@latest --transport stdio"
      ],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Read a Slack channel
Read the last 20 messages in #ios-dev

# Search Slack
Search Slack for discussions about BLE connection timeout

# Read a specific thread
Read the Slack thread starting with this message: <message link>

# Look up a user
Look up the Slack profile for user john.smith
```

---

## References

- [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
- [Authentication setup guide](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
- [npm: slack-mcp-server](https://www.npmjs.com/package/slack-mcp-server)
- [Slack App OAuth settings (Hatch workspace)](https://app.slack.com/app-settings/T03TR3R94/A0AMLQF741Y/oauth)
