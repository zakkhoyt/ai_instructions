
# Bugsee MCP

> Access Bugsee crash reports and issues from any AI agent.

## Overview

- **Homepage**: [bugsee.com](https://bugsee.com)
- **MCP documentation**: [docs.bugsee.com/mcp-server-api/overview](https://docs.bugsee.com/mcp-server-api/overview)
- **Blog posts**: [bugsee.com/blog](https://bugsee.com/blog)
- **Token management**: [app.bugsee.com → Settings → User → Integrations](https://app.bugsee.com/#/settings/user/integrations)
- **MCP URL**: `https://api.bugsee.com/mcp/{YOUR_TOKEN_UUID}`

Bugsee's MCP server exposes your Bugsee crash reports, issues, and analytics directly to an AI agent. The MCP endpoint is an HTTP server where your personal access token is embedded in the URL path.

**Why useful for Hatch iOS dev:**
- Query crash reports and issue details without switching to the Bugsee web dashboard.
- Ask the AI to analyze crash patterns across issues.
- Surface Bugsee data alongside Jira tickets and code review in a single session.

---

## Authentication

**Method: Token-in-URL (long-lived personal access token)**

The Bugsee MCP server uses a UUID access token embedded in the URL path — no separate header or environment variable is needed for the HTTP transport.

**How to obtain a token:**
1. Go to [app.bugsee.com → Settings → User → Integrations](https://app.bugsee.com/#/settings/user/integrations)
2. Create a new MCP integration token
3. Copy the resulting MCP server URL — it embeds your UUID token

**Your MCP URL format:**

```
https://api.bugsee.com/mcp/<YOUR_UUID_TOKEN>
```

> **Security note**: Anyone with this URL has access to your Bugsee data. Treat it like a password — store it in an environment variable and avoid embedding it in committed config files.

---

## Environment Variables

| Variable           | Description                                              | Required |
| ------------------ | -------------------------------------------------------- | -------- |
| `BUGSEE_MCP_TOKEN` | UUID portion of your Bugsee MCP URL (the token segment) | Yes      |

**Set in `~/.zshrc`:**

```zsh
export BUGSEE_MCP_TOKEN="your-uuid-here"
```

---

## Setup

> Bugsee MCP is an **HTTP** endpoint. Tools that natively support HTTP MCP (VSCode Copilot, Cursor) can connect directly. Tools that require `stdio` (Claude Code, Claude Desktop) use `npx mcp-remote` as a local proxy.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // bugsee - Crash reporting and bug tracking MCP server for Bugsee. Auth token is
    // embedded in the MCP URL (token-in-URL pattern). No headers required.
    //
    // # References
    // * [Bugsee: MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
    // * [Bugsee: User Integrations / Auth Tokens](https://app.bugsee.com/#/settings/user/integrations)
    //
    // # Installation
    // None required. Remote HTTP server hosted by Bugsee.
    //
    // # Authorization
    // 1) Generate a Bugsee MCP Auth Token
    //   * [Bugsee: User Integrations](https://app.bugsee.com/#/settings/user/integrations)
    //   * Click `Generate Token` and copy the UUID
    // 2) Replace `<YOUR_BUGSEE_MCP_TOKEN>` in the URL below with your token UUID
    "bugsee": {
      "type": "http",
      "url": "https://api.bugsee.com/mcp/<YOUR_BUGSEE_MCP_TOKEN>"
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // bugsee - Crash reporting and bug tracking MCP server for Bugsee. Auth token embedded
  // in URL via env var (token-in-URL pattern). Workspace-scoped config.
  //
  // # References
  // * [Bugsee: MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
  // * [Bugsee: User Integrations / Auth Tokens](https://app.bugsee.com/#/settings/user/integrations)
  //
  // # Installation
  // None required. Remote HTTP server hosted by Bugsee.
  //
  // # Authorization
  // 1) Generate a Bugsee MCP Auth Token
  //   * [Bugsee: User Integrations](https://app.bugsee.com/#/settings/user/integrations)
  //   * Click `Generate Token` and copy the UUID
  // 2) Set as `BUGSEE_MCP_TOKEN` in `~/.zshrc`
  "servers": {
    "bugsee": {
      "type": "http",
      "url": "https://api.bugsee.com/mcp/${BUGSEE_MCP_TOKEN}"
    }
  }
}
```

### Claude Code (User scope)

Claude Code requires `stdio` transport. Use `npx mcp-remote` as a local HTTP-to-stdio proxy:

```shell
claude mcp add --scope user --transport stdio bugsee -- \
  npx -y mcp-remote "https://api.bugsee.com/mcp/${BUGSEE_MCP_TOKEN}"
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // bugsee - Bugsee crash/bug tracking via mcp-remote proxy for stdio transport.
  // Token embedded in URL from shell env var.
  //
  // # References
  // * [Bugsee: MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
  // * [Bugsee: User Integrations / Auth Tokens](https://app.bugsee.com/#/settings/user/integrations)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Generate a Bugsee MCP Auth Token
  //   * [Bugsee: User Integrations](https://app.bugsee.com/#/settings/user/integrations)
  //   * Click `Generate Token` and copy the UUID
  // 2) Set as `BUGSEE_MCP_TOKEN` in `~/.zshrc`; Claude Code inherits shell env
  "mcpServers": {
    "bugsee": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-remote https://api.bugsee.com/mcp/${BUGSEE_MCP_TOKEN}"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // bugsee - Bugsee crash/bug tracking via mcp-remote proxy for stdio transport.
  // Token embedded in URL from shell env var.
  //
  // # References
  // * [Bugsee: MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
  // * [Bugsee: User Integrations / Auth Tokens](https://app.bugsee.com/#/settings/user/integrations)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Generate a Bugsee MCP Auth Token
  //   * [Bugsee: User Integrations](https://app.bugsee.com/#/settings/user/integrations)
  //   * Click `Generate Token` and copy the UUID
  // 2) Set as `BUGSEE_MCP_TOKEN` in `~/.zshrc`; Claude Code inherits shell env
  "mcpServers": {
    "bugsee": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-remote https://api.bugsee.com/mcp/${BUGSEE_MCP_TOKEN}"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // bugsee - Bugsee crash/bug tracking via mcp-remote proxy for stdio transport.
  // Token embedded in URL. Requires terminal launch to inherit BUGSEE_MCP_TOKEN.
  //
  // # References
  // * [Bugsee: MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
  // * [Bugsee: User Integrations / Auth Tokens](https://app.bugsee.com/#/settings/user/integrations)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Generate a Bugsee MCP Auth Token
  //   * [Bugsee: User Integrations](https://app.bugsee.com/#/settings/user/integrations)
  //   * Click `Generate Token` and copy the UUID
  // 2) Set as `BUGSEE_MCP_TOKEN` in `~/.zshrc`
  //   * Launch Claude Desktop from terminal to inherit BUGSEE_MCP_TOKEN,
  //     or hardcode the full URL with token embedded
  "mcpServers": {
    "bugsee": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://api.bugsee.com/mcp/${BUGSEE_MCP_TOKEN}"
      ]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

This example uses the `mcp-remote` stdio proxy, which allows the shell to expand `${BUGSEE_MCP_TOKEN}` before passing the URL:

```jsonc
{
  // # About
  // bugsee - Bugsee crash/bug tracking via mcp-remote proxy. Uses /bin/zsh -lc wrapper
  // for PATH resolution in Cursor. Token embedded in URL from shell env var.
  //
  // # References
  // * [Bugsee: MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
  // * [Bugsee: User Integrations / Auth Tokens](https://app.bugsee.com/#/settings/user/integrations)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Generate a Bugsee MCP Auth Token
  //   * [Bugsee: User Integrations](https://app.bugsee.com/#/settings/user/integrations)
  //   * Click `Generate Token` and copy the UUID
  // 2) Set as `BUGSEE_MCP_TOKEN` in `~/.zshrc`
  "mcpServers": {
    "bugsee": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "npx -y mcp-remote https://api.bugsee.com/mcp/${BUGSEE_MCP_TOKEN}"
      ]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Analyze a specific Bugsee issue
Please help me analyze Bugsee issue MYAPP-123

# Find recent crashes
Show me the top 5 crashes from the last 7 days in the Nightlight app

# Get issue details
Get full details for Bugsee issue NIGHTLIGHT-456 including stack trace
```

---

## References

- [Bugsee MCP Server Documentation](https://docs.bugsee.com/mcp-server-api/overview)
- [Bugsee Blog](https://bugsee.com/blog)
- [Bugsee: User Integrations (token management)](https://app.bugsee.com/#/settings/user/integrations)
- [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote) (HTTP-to-stdio proxy for Claude Code/Desktop)
