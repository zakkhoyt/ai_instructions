
# Google Workspace MCP (taylorwilsdon)

> Read and write Google Docs, Drive, Gmail, Calendar, Sheets, Forms, Tasks, and Contacts from any AI agent using OAuth.

## Overview

- **GitHub**: [github.com/taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)
- **Package**: installed via `uvx workspace-mcp` (Python, no npm)
- **Transport**: stdio

`google_workspace_mcp` by taylorwilsdon is a third-party MCP server that connects to Google APIs via a standard OAuth 2.0 Desktop application flow. Each engineer authenticates once with their own Google account; credentials are cached locally.

**What it gives you:**
- Read and write Google Docs and Drive files
- Read Gmail, Calendar, Sheets, Forms, Tasks, Contacts
- Apps Script and Google Chat tools

> **Note**: The OAuth *client* credentials (client ID + secret) can be shared across the team via LastPass — see [Team Credential Sharing](#team-credential-sharing) below. Each engineer still authenticates with their own Google account on first run.

---

## Prerequisites

1. `uv` installed (`brew install uv`)
2. Google OAuth client JSON downloaded locally (see [Authentication](#authentication))
3. Required Google APIs enabled in the OAuth project (at minimum: Drive API + Docs API)

---

## Authentication

Google Workspace MCP uses a Desktop OAuth 2.0 flow. The OAuth client credentials (client ID and secret) are stored as a JSON file on each engineer's machine.

**Obtain the shared OAuth client JSON via LastPass:**
- LastPass: `Shared-iOS-devs` → `MCP` → `GOOGLE_WORKSPACE`

Copy the JSON to a local path on your machine:

```zsh
~/.zsh_home/tokens/mcp/google/google_mcp_client.json
```

> **Never commit this file.** It contains your team's OAuth client secret.

On first use, your AI client will open a browser window for Google sign-in. After completing sign-in once, tokens are cached at `~/.google_workspace_mcp/credentials` and reused automatically.

---

## Team Credential Sharing

The OAuth *client* JSON (`client_id`, `client_secret`, redirect URIs) can be shared with the team because it identifies the application, not the user. It is safe to distribute internally via LastPass.

| Safe to share (via LastPass) | Never share |
|------------------------------|-------------|
| `client_id`, `client_secret`, redirect URIs | Per-user token cache files under `~/.google_workspace_mcp/credentials` |
| `GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET` | Access tokens, refresh tokens |

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GOOGLE_CLIENT_SECRET_PATH` | Absolute path to the local OAuth client JSON file | Yes |
| `USER_GOOGLE_EMAIL` | Your Hatch Google account email (`@hatch.co`) | Yes |

**Set in `~/.zshrc`:**

```zsh
export GOOGLE_MCP_CLIENT_SECRET_PATH="$HOME/.zsh_home/tokens/mcp/google/google_mcp_client.json"
export GOOGLE_MCP_USER_EMAIL="you@hatch.co"
```

---

## Installation

`uvx` downloads and runs `workspace-mcp` automatically. Only `uv` itself needs to be installed:

```zsh
brew install uv
# Verify:
uvx workspace-mcp --help
```

> **Do not use `npx workspace-mcp`** — that package does not exist on npm.

---

## Setup

### Claude Code (User scope)

```zsh
claude mcp add --scope user --transport stdio google-workspace -- uvx workspace-mcp --single-user
```

Then set env vars in your Claude config for `GOOGLE_CLIENT_SECRET_PATH` and `USER_GOOGLE_EMAIL`.

### Claude Code / Claude Desktop (config snippet)

```jsonc
{
  "mcpServers": {
    // # About
    // google-workspace - Google Workspace MCP server. Access Docs, Drive, Gmail, Calendar, Sheets, Forms, Tasks, and Contacts.
    //
    // # References
    // * [GitHub: taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)
    // * [Google Cloud Console: OAuth Credentials](https://console.cloud.google.com/apis/credentials)
    //
    // # Authorization
    // 1) Obtain the shared Google OAuth client JSON
    //   * LastPass: `Shared-iOS-devs` → `MCP` → `GOOGLE_WORKSPACE` (shared team token)
    //   * Copy JSON to ~/.zsh_home/tokens/mcp/google/google_mcp_client.json
    // 2) Set GOOGLE_CLIENT_SECRET_PATH and USER_GOOGLE_EMAIL env vars
    // 3) On first use a browser OAuth prompt appears — sign in once; tokens cache locally
    "google-workspace": {
      "type": "stdio",
      "command": "uvx",
      "args": ["workspace-mcp", "--single-user"],
      "env": {
        "GOOGLE_CLIENT_SECRET_PATH": "${GOOGLE_MCP_CLIENT_SECRET_PATH}",
        "USER_GOOGLE_EMAIL": "${GOOGLE_MCP_USER_EMAIL}"
      }
    }
  }
}
```

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    "google-workspace": {
      "type": "stdio",
      "command": "uvx",
      "args": ["workspace-mcp", "--single-user"],
      "env": {
        // * LastPass: `Shared-iOS-devs` → `MCP` → `GOOGLE_WORKSPACE` (shared team token)
        "GOOGLE_CLIENT_SECRET_PATH": "${userHome}/.zsh_home/tokens/mcp/google/google_mcp_client.json",
        "USER_GOOGLE_EMAIL": "${GOOGLE_MCP_USER_EMAIL}"
      }
    }
  }
}
```

Then reload window: `Command Palette → Developer: Reload Window`

**OAuth sign-in in VSCode:**
1. First Google tool call triggers an OAuth URL prompt
2. Open the link in browser and complete sign-in
3. Retry the same tool call — future calls reuse cached tokens

---

## Common Prompts / Usage Examples

```
# Read a Google Doc
Read the document at https://docs.google.com/document/d/<ID>/edit

# If full URL fails, use the raw document ID
Read doc 1Qmpdh4kxbw1IAnX0fIUP-Jt5QbbZgnpIlyuZt1GtW6I

# Search Drive
Find files in Drive related to "Q1 roadmap"

# Read Gmail
Show my last 10 unread emails

# Check Calendar
What meetings do I have tomorrow?
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `npm 404 workspace-mcp not found` | Used `npx` instead of `uvx` | Use `uvx workspace-mcp` |
| `ModuleNotFoundError: No module named 'mcp'` | Wrong Python environment | Use clean `uvx workspace-mcp` |
| Repeated auth prompts after sign-in | `USER_GOOGLE_EMAIL` mismatches authenticated account | Ensure `USER_GOOGLE_EMAIL` matches your actual Google login |
| `Google Drive API is not enabled` | API not enabled in OAuth project | Enable Drive API in Google Cloud Console; wait 1–2 min |
| `File not found: https://docs.google.com/...` | Full URL passed as file ID | Pass raw document ID only |

---

## References

- [GitHub: taylorwilsdon/google_workspace_mcp](https://github.com/taylorwilsdon/google_workspace_mcp)
- [Model Context Protocol - Introduction](https://modelcontextprotocol.io/docs/getting-started/intro)
- [VS Code MCP Servers](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
- [Google Cloud Console: API Library](https://console.cloud.google.com/apis/library)
- [Google Cloud Console: OAuth Credentials](https://console.cloud.google.com/apis/credentials)
