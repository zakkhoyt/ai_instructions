
# Atlassian Rovo MCP (Official)

> Official Atlassian MCP server — Jira and Confluence access via the Atlassian Rovo platform.

## Overview

- **Homepage**: [support.atlassian.com — Atlassian Rovo MCP Server](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/setting-up-ides/)
- **GitHub**: [github.com/atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server)
- **MCP URL**: `https://mcp.atlassian.com/v1/mcp` (API token / Basic Auth)

The official Atlassian-hosted MCP server exposes Jira and Confluence tools through the Atlassian Rovo platform. As of March 2026, it supports both API token authentication (long-lived) and OAuth 2.1 (short-lived). **Prefer API token auth** — tokens can last up to 1 year vs. OAuth's ~2-day expiry.

**Why useful for Hatch iOS dev:**
- Create, search, and update Jira tickets without switching to the browser.
- Query Confluence pages and spaces directly from the agent session.
- Link PRs and code changes to Jira issues in-context.

---

## Authentication

**Preferred method: API Token (long-lived)**

Atlassian API tokens last up to 1 year and are encoded into a Basic Auth header.

**How to obtain a token:**
1. Go to [id.atlassian.com → Security → API tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Click **Create API token**, give it a descriptive label, and set expiry (max 1 year)
3. Copy the token immediately — you won't see it again

**How to encode the token:**

```zsh
echo -n "your.email@company.com:YOUR_API_TOKEN" | base64
# Output: base64-encoded string used in Authorization header
```

**How to supply in config:**
- Pass as `Authorization: Basic <base64_string>` in the `headers` key
- Store the base64 string in an environment variable to avoid embedding it in config files

**OAuth fallback (not recommended for daily use):**
- Use `https://mcp.atlassian.com/v1/sse` endpoint with SSE transport
- Authenticates via browser flow — expires every ~2 days requiring re-authentication
- Use only if API tokens are not available in your Atlassian plan

---

## Environment Variables

| Variable                          | Description                                                                          | Required |
| --------------------------------- | ------------------------------------------------------------------------------------ | -------- |
| `ATLASSIAN_MCP_CLASSIC_BASIC_AUTH`| Base64-encoded `email:token` for Basic Auth header                                  | Yes      |

**Set in `~/.zshrc`:**

```zsh
# Create with: echo -n "email:token" | base64
export ATLASSIAN_MCP_CLASSIC_BASIC_AUTH="$(echo -n 'your@email.com:YOUR_API_TOKEN' | base64)"
```

---

## Setup

> Configs below use API token (Basic Auth) as the preferred authentication method. OAuth is noted as secondary.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // Atlassian Rovo MCP — API token via Basic Auth
    // Token: https://id.atlassian.com/manage-profile/security/api-tokens
    // Encode: echo -n "email:token" | base64
    "atlassian-rovo-mcp": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        // Prefer env var to avoid embedding token in config:
        // "Authorization": "Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}"
        "Authorization": "Basic <BASE64_EMAIL_COLON_API_TOKEN>"
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
    // Atlassian Rovo MCP — API token via Basic Auth
    // Token: https://id.atlassian.com/manage-profile/security/api-tokens
    // Encode: echo -n "email:token" | base64
    "atlassian-rovo-mcp": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        "Authorization": "Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}"
      }
    }
  }
}
```

### Claude Code (User scope)

Claude Code does not natively support HTTP MCP servers with custom headers. Use `npx mcp-remote` as a local proxy:

Run once in terminal:

```shell
claude mcp add --scope user --transport stdio atlassian-rovo-mcp -- \
  npx -y mcp-remote https://mcp.atlassian.com/v1/mcp \
  --header "Authorization: Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}"
```

Resulting entry in `~/.claude.json`:

```json
{
  "mcpServers": {
    "atlassian-rovo-mcp": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "npx -y mcp-remote https://mcp.atlassian.com/v1/mcp --header 'Authorization: Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}'"
      ]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```json
{
  "mcpServers": {
    "atlassian-rovo-mcp": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "npx -y mcp-remote https://mcp.atlassian.com/v1/mcp --header 'Authorization: Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}'"
      ]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  "mcpServers": {
    // Atlassian Rovo MCP — API token via Basic Auth
    // Token: https://id.atlassian.com/manage-profile/security/api-tokens
    // Note: Claude Desktop inherits env vars only if launched from terminal.
    //       If launched from Dock/Launchpad, hardcode the base64 value here.
    "atlassian-rovo-mcp": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.atlassian.com/v1/mcp",
        "--header",
        "Authorization: Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}"
      ]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```json
{
  "mcpServers": {
    "atlassian-rovo-mcp": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "npx -y mcp-remote https://mcp.atlassian.com/v1/mcp --header 'Authorization: Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}'"
      ]
    }
  }
}
```

### OAuth (Alternative — short-lived, not recommended)

For platforms that handle OAuth natively (e.g., VSCode Copilot via gallery install):

```jsonc
{
  "servers": {
    // OAuth variant — browser auth required every ~2 days
    "atlassian-rovo-mcp": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/sse"
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Search Jira issues
Search Jira for open P1 bugs in project HSD

# Get a specific ticket
Get details for Jira issue HSD-12345

# Create a Jira ticket
Create a Jira bug in project HSD with summary "BLE connection drops on iOS 26"

# Search Confluence
Search Confluence for documentation about the BLE pairing flow

# Get a Confluence page
Get the Confluence page titled "Nightlight Architecture Overview"
```

---

## References

- [Atlassian: Setting up IDEs — Rovo MCP Server](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/setting-up-ides/)
- [Atlassian: Configuring authentication via API token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
- [Atlassian: API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
- [GitHub: atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server)
- [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote) (proxy for HTTP MCP in stdio-only clients)
