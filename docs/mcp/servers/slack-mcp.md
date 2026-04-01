
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

**How to obtain a token (via LastPass)**
* Lastpass: `Shared-iOS-devs` -> `MCP` -> `SLACK_MCP_XOXP_TOKEN`


**How to obtain a token (via Slack Dev Portal)**
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
    // # About
    // slack - MCP server for reading and searching Slack channels, threads, and user profiles.
    // Uses an XOXP user OAuth token for authentication.
    //
    // # References
    // * [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
    // * [korotovsky/slack-mcp-server: Authentication Setup](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
    // * [Slack App Settings - OAuth & Permissions](https://app.slack.com/app-settings/)
    // * [GitHub: korotovsky/slack-mcp-server - Environment Variables](https://github.com/korotovsky/slack-mcp-server#environment-variables)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // 1) Obtain a Slack XOXP User OAuth Token
    //   * Visit your Slack app's OAuth & Permissions page
    //   * Copy the `xoxp-...` token from the OAuth Tokens section
    // 2) Set the token in your shell profile so VSCode can read it via ${env:SLACK_MCP_XOXP_TOKEN}:
    //   * Add to ~/.zshrc: export SLACK_MCP_XOXP_TOKEN="xoxp-..."
    "slack": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "slack-mcp-server@latest", "--transport", "stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${env:SLACK_MCP_XOXP_TOKEN}"
      }
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // slack - MCP server for reading and searching Slack channels, threads, and user profiles.
  // Workspace-scoped config; XOXP token sourced from env var.
  //
  // # References
  // * [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
  // * [korotovsky/slack-mcp-server: Authentication Setup](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
  // * [Slack App Settings - OAuth & Permissions](https://app.slack.com/app-settings/)
  // * [GitHub: korotovsky/slack-mcp-server - Environment Variables](https://github.com/korotovsky/slack-mcp-server#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // 1) Obtain a Slack XOXP User OAuth Token
  //   * Visit your Slack app's OAuth & Permissions page
  //   * Copy the `xoxp-...` token from the OAuth Tokens section
  // 2) Set the token as `SLACK_MCP_XOXP_TOKEN` in `~/.zshrc`
  "servers": {
    "slack": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "slack-mcp-server@latest", "--transport", "stdio"],
      "env": {
        "SLACK_MCP_XOXP_TOKEN": "${env:SLACK_MCP_XOXP_TOKEN}"
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

```jsonc
{
  // # About
  // slack - MCP server for reading and searching Slack channels, threads, and user profiles.
  // Uses /bin/zsh -lc wrapper for PATH resolution. XOXP token from shell env.
  //
  // # References
  // * [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
  // * [korotovsky/slack-mcp-server: Authentication Setup](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
  // * [Slack App Settings - OAuth & Permissions](https://app.slack.com/app-settings/)
  // * [GitHub: korotovsky/slack-mcp-server - Environment Variables](https://github.com/korotovsky/slack-mcp-server#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // 1) Obtain a Slack XOXP User OAuth Token
  //   * Visit your Slack app's OAuth & Permissions page
  //   * Copy the `xoxp-...` token from the OAuth Tokens section
  // 2) Set as `SLACK_MCP_XOXP_TOKEN` in `~/.zshrc`; Claude Code inherits shell env
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

```jsonc
{
  // # About
  // slack - MCP server for reading and searching Slack channels, threads, and user profiles.
  // Uses /bin/zsh -lc wrapper for PATH resolution. XOXP token from shell env.
  //
  // # References
  // * [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
  // * [korotovsky/slack-mcp-server: Authentication Setup](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
  // * [Slack App Settings - OAuth & Permissions](https://app.slack.com/app-settings/)
  // * [GitHub: korotovsky/slack-mcp-server - Environment Variables](https://github.com/korotovsky/slack-mcp-server#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // 1) Obtain a Slack XOXP User OAuth Token
  //   * Visit your Slack app's OAuth & Permissions page
  //   * Copy the `xoxp-...` token from the OAuth Tokens section
  // 2) Set as `SLACK_MCP_XOXP_TOKEN` in `~/.zshrc`; Claude Code inherits shell env
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
  // # About
  // slack - MCP server for reading and searching Slack channels, threads, and user profiles.
  // XOXP token from env var. Requires terminal launch to inherit SLACK_MCP_XOXP_TOKEN.
  //
  // # References
  // * [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
  // * [korotovsky/slack-mcp-server: Authentication Setup](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
  // * [Slack App Settings - OAuth & Permissions](https://app.slack.com/app-settings/)
  // * [GitHub: korotovsky/slack-mcp-server - Environment Variables](https://github.com/korotovsky/slack-mcp-server#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // 1) Obtain a Slack XOXP User OAuth Token
  //   * Visit your Slack app's OAuth & Permissions page
  //   * Copy the `xoxp-...` token from the OAuth Tokens section
  // 2) Set as `SLACK_MCP_XOXP_TOKEN` in `~/.zshrc`
  //   * Launch Claude Desktop from terminal to inherit SLACK_MCP_XOXP_TOKEN
  "mcpServers": {
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

```jsonc
{
  // # About
  // slack - MCP server for reading and searching Slack channels, threads, and user profiles.
  // Requires /bin/zsh -lc wrapper for PATH resolution in Cursor. XOXP token from shell env.
  //
  // # References
  // * [GitHub: korotovsky/slack-mcp-server](https://github.com/korotovsky/slack-mcp-server)
  // * [korotovsky/slack-mcp-server: Authentication Setup](https://github.com/korotovsky/slack-mcp-server/blob/master/docs/01-authentication-setup.md)
  // * [Slack App Settings - OAuth & Permissions](https://app.slack.com/app-settings/)
  // * [GitHub: korotovsky/slack-mcp-server - Environment Variables](https://github.com/korotovsky/slack-mcp-server#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // 1) Obtain a Slack XOXP User OAuth Token
  //   * Visit your Slack app's OAuth & Permissions page
  //   * Copy the `xoxp-...` token from the OAuth Tokens section
  // 2) Set as `SLACK_MCP_XOXP_TOKEN` in `~/.zshrc`
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
