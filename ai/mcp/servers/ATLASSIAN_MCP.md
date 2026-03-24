
# Atlassian Rovo MCP (Official)

> Official Atlassian MCP server — Jira and Confluence access via the Atlassian Rovo platform.

## Overview

- **Homepage**: [support.atlassian.com — Atlassian Rovo MCP Server](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/setting-up-ides/)
- **GitHub**: [github.com/atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server)
- **MCP URL**: `https://mcp.atlassian.com/v1/mcp` (API token / Basic Auth)

The official Atlassian-hosted MCP server exposes Jira and Confluence tools through the Atlassian Rovo platform. As of March 2026, it supports both API token authentication (long-lived) and OAuth 2.1 (short-lived). **Prefer API token auth** — tokens can last up to 1 year vs. OAuth's ~2-day expiry.

> [!IMPORTANT]
> **API token limitation (March 2026):** When authenticated via API token (Basic Auth), the official Rovo MCP only exposes 2 beta tools — `getTeamworkGraphContext` and `getTeamworkGraphObject` — and both fail internally with a "slauth token missing" error. Full Jira CRUD tools require a **Rovo AI subscription** or OAuth. If you need API-token-based Jira CRUD, use [`mcp-atlassian` (sooperset)](./MCP_ATLASSIAN.md) instead.

**Why useful for Hatch iOS dev:**
- Create, search, and update Jira tickets without switching to the browser (requires Rovo subscription or OAuth).
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
    // # About
    // atlassian-rovo-mcp - Official Atlassian MCP server for Jira and Confluence via the
    // Rovo MCP Server. Supports creating/editing issues, searching, commenting, and more.
    //
    // # References
    // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
    // * [Atlassian: Rovo MCP Server - Configuring Authentication via API Token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
    // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
    //
    // # Installation
    // None required. Remote HTTP server hosted by Atlassian.
    //
    // # Authorization
    // 1) Create a (Scoped) Atlassian User API Token for the `Rovo MCP Server` app
    //   * [Atlassian: Create API Token (pre-configured for Rovo MCP)](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
    //   * On the token creation page: select app `Rovo MCP Server`, set expiry to max (1 year)
    //   * Note: tokens scoped to the `Jira` app will NOT work — must use `Rovo MCP Server`
    // 2) Create a Basic Authorization hash
    //   * Combine `user.email:api_token` and base64-encode:
    //   * `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
    // 3) Paste the hash as the `Authorization: Basic <hash>` header value below
    "atlassian-rovo-mcp": {
      "type": "http",
      "url": "https://mcp.atlassian.com/v1/mcp",
      "headers": {
        // Prefer env var to avoid embedding token in config:
        // "Authorization": "Basic ${ATLASSIAN_MCP_CLASSIC_BASIC_AUTH}"
        "Authorization": "Basic <YOUR_BASIC_AUTH_HASH>"
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
  // atlassian-rovo-mcp - Official Atlassian MCP server for Jira and Confluence via the
  // Rovo MCP Server. Workspace-scoped config; auth token stored as env var.
  //
  // # References
  // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
  // * [Atlassian: Rovo MCP Server - Configuring Authentication via API Token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  //
  // # Installation
  // None required. Remote HTTP server hosted by Atlassian.
  //
  // # Authorization
  // 1) Create a (Scoped) Atlassian User API Token for the `Rovo MCP Server` app
  //   * [Atlassian: Create API Token (pre-configured for Rovo MCP)](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
  //   * On the token creation page: select app `Rovo MCP Server`, set expiry to max (1 year)
  //   * Note: tokens scoped to the `Jira` app will NOT work — must use `Rovo MCP Server`
  // 2) Create a Basic Authorization hash
  //   * Combine `user.email:api_token` and base64-encode:
  //   * `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
  // 3) Store the hash as `ATLASSIAN_MCP_CLASSIC_BASIC_AUTH` in `~/.zshrc`
  "servers": {
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

```jsonc
{
  // # About
  // atlassian-rovo-mcp - Official Atlassian MCP server for Jira and Confluence. Uses
  // mcp-remote proxy to bridge HTTP MCP to stdio transport for Claude Code.
  //
  // # References
  // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
  // * [Atlassian: Rovo MCP Server - Configuring Authentication via API Token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Create a (Scoped) Atlassian User API Token for the `Rovo MCP Server` app
  //   * [Atlassian: Create API Token (pre-configured for Rovo MCP)](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
  //   * On the token creation page: select app `Rovo MCP Server`, set expiry to max (1 year)
  //   * Note: tokens scoped to the `Jira` app will NOT work — must use `Rovo MCP Server`
  // 2) Create a Basic Authorization hash
  //   * `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
  // 3) Set as `ATLASSIAN_MCP_CLASSIC_BASIC_AUTH` in `~/.zshrc`; Claude Code inherits shell env
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

```jsonc
{
  // # About
  // atlassian-rovo-mcp - Official Atlassian MCP server for Jira and Confluence. Uses
  // mcp-remote proxy to bridge HTTP MCP to stdio transport for Claude Code.
  //
  // # References
  // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
  // * [Atlassian: Rovo MCP Server - Configuring Authentication via API Token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Create a (Scoped) Atlassian User API Token for the `Rovo MCP Server` app
  //   * [Atlassian: Create API Token (pre-configured for Rovo MCP)](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
  //   * On the token creation page: select app `Rovo MCP Server`, set expiry to max (1 year)
  //   * Note: tokens scoped to the `Jira` app will NOT work — must use `Rovo MCP Server`
  // 2) Create a Basic Authorization hash
  //   * `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
  // 3) Set as `ATLASSIAN_MCP_CLASSIC_BASIC_AUTH` in `~/.zshrc`; Claude Code inherits shell env
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
  // # About
  // atlassian-rovo-mcp - Official Atlassian MCP server for Jira and Confluence. Uses
  // mcp-remote proxy to bridge HTTP MCP to stdio transport for Claude Desktop.
  //
  // # References
  // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
  // * [Atlassian: Rovo MCP Server - Configuring Authentication via API Token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  //
  // # Authorization
  // 1) Create a (Scoped) Atlassian User API Token for the `Rovo MCP Server` app
  //   * [Atlassian: Create API Token (pre-configured for Rovo MCP)](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
  //   * On the token creation page: select app `Rovo MCP Server`, set expiry to max (1 year)
  //   * Note: tokens scoped to the `Jira` app will NOT work — must use `Rovo MCP Server`
  // 2) Create a Basic Authorization hash
  //   * `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
  // 3) Set as `ATLASSIAN_MCP_CLASSIC_BASIC_AUTH` in `~/.zshrc`
  //   * Launch Claude Desktop from terminal to inherit env var, or hardcode the base64 value
  "mcpServers": {
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

```jsonc
{
  // # About
  // atlassian-rovo-mcp - Official Atlassian MCP server for Jira and Confluence. Uses
  // mcp-remote proxy via /bin/zsh -lc wrapper for PATH resolution in Cursor.
  //
  // # References
  // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
  // * [Atlassian: Rovo MCP Server - Configuring Authentication via API Token](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-api-token/)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
  //
  // # Installation
  // `npx mcp-remote` proxies HTTP MCP to stdio. Installed automatically via npx.
  // Requires /bin/zsh -lc wrapper for PATH resolution in Cursor.
  //
  // # Authorization
  // 1) Create a (Scoped) Atlassian User API Token for the `Rovo MCP Server` app
  //   * [Atlassian: Create API Token (pre-configured for Rovo MCP)](https://id.atlassian.com/manage-profile/security/api-tokens?autofillToken=&expiryDays=max&appId=mcp&selectedScopes=all)
  //   * On the token creation page: select app `Rovo MCP Server`, set expiry to max (1 year)
  //   * Note: tokens scoped to the `Jira` app will NOT work — must use `Rovo MCP Server`
  // 2) Create a Basic Authorization hash
  //   * `echo -n "${ATLASSIAN_USER_EMAIL}:${ATLASSIAN_AUTH_TOKEN}" | base64 | pbcopy`
  // 3) Set as `ATLASSIAN_MCP_CLASSIC_BASIC_AUTH` in `~/.zshrc`
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
  // # About
  // atlassian-rovo-mcp - Official Atlassian MCP server (OAuth variant). Browser auth
  // required every ~2 days when token expires. Not recommended for daily use.
  //
  // # References
  // * [Atlassian: Rovo MCP Server - Getting Started](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/getting-started-with-the-atlassian-remote-mcp-server/)
  // * [Atlassian: Rovo MCP Server - OAuth Authentication](https://support.atlassian.com/atlassian-rovo-mcp-server/docs/configuring-authentication-via-oauth/)
  //
  // # Installation
  // None required. Remote SSE server hosted by Atlassian.
  //
  // # Authorization
  // 1) No pre-configuration required — OAuth triggers a browser popup on first connect.
  // 2) Re-authenticate every ~2 days when the token expires.
  "servers": {
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
