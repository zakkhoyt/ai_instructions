
# mcp-atlassian (sooperset, 3rd-party)

> Third-party Atlassian MCP server — Jira and Confluence access via long-lived API tokens.

## Overview

- **GitHub**: [github.com/sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
- **Docker image**: `ghcr.io/sooperset/mcp-atlassian:latest`
- **Python (uvx)**: `uvx mcp-atlassian`

`mcp-atlassian` by sooperset is a third-party MCP server that exposes Jira and Confluence tools. Unlike the official Atlassian Rovo MCP, it uses standard Atlassian API tokens directly (no Basic Auth encoding required) and supports both Docker and `uvx` (Python package runner) deployment.

**Why prefer this over the official Atlassian MCP:**
- Direct API token support — no base64 encoding ceremony.
- Tokens last up to 1 year vs. OAuth's ~2-day expiry.
- Self-hosted via Docker or `uvx` — no reliance on Atlassian's Rovo platform availability.
- Supports both Jira and Confluence in one server.

**Why prefer the official Atlassian MCP:**
- No Docker or Python toolchain required.
- Managed by Atlassian; tracks upstream API changes automatically.

---

## Authentication

**Preferred method: Atlassian API token (long-lived, up to 1 year)**

**How to obtain a token:**
1. Go to [id.atlassian.com → Security → API tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
2. Create a token with a descriptive label and max expiry (1 year)
3. Copy the token — store it in a `.env` file or your shell environment

**Required credentials:**

| Variable              | Description                                               |
| --------------------- | --------------------------------------------------------- |
| `JIRA_URL`            | Your Jira instance base URL (e.g. `https://org.atlassian.net`) |
| `JIRA_USERNAME`       | Your Atlassian account email                              |
| `JIRA_API_TOKEN`      | Atlassian API token (from link above)                     |
| `CONFLUENCE_URL`      | Confluence URL (e.g. `https://org.atlassian.net/wiki`) — optional |
| `CONFLUENCE_USERNAME` | Confluence account email — optional, defaults to `JIRA_USERNAME` |
| `CONFLUENCE_API_TOKEN`| Confluence API token — optional, can reuse Jira token    |

---

## Environment Variables

Credentials are passed to the Docker container or `uvx` process via environment variables. **Do not commit these values to git.** Use one of the patterns below.

### Option A — `.env` file (recommended for VSCode)

Store credentials in a `.env` file, loaded via Docker `--env-file`:

```zsh
# ~/.hatch/config/vscode/mcp-atlassian.env
# (gitignored location — safe for personal use)

# API Tokens: https://id.atlassian.com/manage-profile/security/api-tokens
JIRA_URL=https://yourorg.atlassian.net
JIRA_USERNAME=you@yourorg.com
JIRA_API_TOKEN=<your_jira_api_token>

# Optional: Confluence (can reuse Jira token for same account)
CONFLUENCE_URL=https://yourorg.atlassian.net/wiki
CONFLUENCE_USERNAME=you@yourorg.com
CONFLUENCE_API_TOKEN=<your_confluence_api_token>
```

### Option B — Shell environment variables (recommended for Claude Code / non-Docker)

Add to `~/.zshrc`:

```zsh
export JIRA_URL="https://yourorg.atlassian.net"
export JIRA_USERNAME="you@yourorg.com"
export JIRA_API_TOKEN="<your_jira_api_token>"
export CONFLUENCE_URL="https://yourorg.atlassian.net/wiki"
export CONFLUENCE_API_TOKEN="<your_confluence_api_token>"
```

### Option C — Wrapper script (recommended for Claude Desktop / Cursor)

A wrapper script sources credentials from your shell env and passes them to Docker:

```zsh
#!/usr/bin/env -S zsh -euo pipefail
# ~/.hatch/scripts/mcp_atlassian_wrapper.zsh
# Sources Jira credentials and launches mcp-atlassian via Docker

source "$HOME/.hatch/config/.zsh_hatch_jira"

docker run \
  --rm \
  --interactive \
  --env JIRA_URL="$MY_JIRA_URL" \
  --env JIRA_USERNAME="$MY_JIRA_USERNAME" \
  --env JIRA_API_TOKEN="$MY_JIRA_MCP_SERVER_TOKEN" \
  'ghcr.io/sooperset/mcp-atlassian:latest' \
  --transport stdio
```

---

## Prerequisites

**Docker variant:**

```zsh
# Pull the Docker image
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

**uvx variant (no Docker required):**

```zsh
# Install uv (Python package runner)
brew install uv

# Install mcp-atlassian tool
uv tool install mcp-atlassian
```

---

## Setup

### VSCode (User scope) — Docker + .env file

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // mcp-atlassian (sooperset) — 3rd-party, API token auth via .env file
    // Tokens: https://id.atlassian.com/manage-profile/security/api-tokens
    "mcp-atlassian": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--env-file", "${env:HOME}/.hatch/config/vscode/mcp-atlassian.env",
        "ghcr.io/sooperset/mcp-atlassian:latest",
        "--transport", "stdio"
      ]
    }
  }
}
```

### VSCode (Workspace scope) — Docker + workspace .env file

File: `.vscode/mcp.json`

> **Note**: Add `.vscode/mcp-atlassian.env` to `.gitignore` — it contains real credentials.

```jsonc
{
  "servers": {
    // mcp-atlassian (sooperset) — workspace .env file variant
    // Add .vscode/mcp-atlassian.env to .gitignore!
    // Tokens: https://id.atlassian.com/manage-profile/security/api-tokens
    "mcp-atlassian": {
      "type": "stdio",
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--env-file", "${workspaceFolder}/.vscode/mcp-atlassian.env",
        "ghcr.io/sooperset/mcp-atlassian:latest",
        "--transport", "stdio"
      ]
    }
  }
}
```

### VSCode (User scope) — wrapper script variant

```jsonc
{
  "servers": {
    // mcp-atlassian via wrapper script that injects credentials from shell env
    "mcp-atlassian": {
      "type": "stdio",
      "command": "${env:HOME}/.hatch/scripts/mcp_atlassian_wrapper.zsh",
      "args": []
    }
  }
}
```

### Claude Code (User scope)

Claude Code inherits shell env vars when invoked from terminal. Use `uvx` if available, otherwise the wrapper script:

```shell
# uvx variant (requires uv installed)
claude mcp add --scope user --transport stdio mcp-atlassian -- \
  /bin/zsh -lc "uvx mcp-atlassian --transport stdio"

# Wrapper script variant
claude mcp add --scope user --transport stdio mcp-atlassian -- \
  /Users/yourname/.hatch/scripts/mcp_atlassian_wrapper.zsh
```

Resulting entry in `~/.claude.json` (uvx variant):

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "uvx mcp-atlassian --transport stdio"],
      "env": {
        "JIRA_URL": "${JIRA_URL}",
        "JIRA_USERNAME": "${JIRA_USERNAME}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
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
    "mcp-atlassian": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "uvx mcp-atlassian --transport stdio"],
      "env": {
        "JIRA_URL": "${JIRA_URL}",
        "JIRA_USERNAME": "${JIRA_USERNAME}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
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
    // mcp-atlassian via wrapper script
    // Wrapper sources credentials from ~/.hatch/config/.zsh_hatch_jira
    // Tokens: https://id.atlassian.com/manage-profile/security/api-tokens
    "mcp-atlassian": {
      "command": "/Users/yourname/.hatch/scripts/mcp_atlassian_wrapper.zsh",
      "args": []
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec uvx mcp-atlassian --transport stdio"
      ],
      "env": {
        "JIRA_URL": "${JIRA_URL}",
        "JIRA_USERNAME": "${JIRA_USERNAME}",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Search Jira
Search Jira for open P1 bugs assigned to me in project HSD

# Get a specific Jira ticket
Get details for Jira issue HSD-12345 including comments

# Create a ticket
Create a Jira story in project HSD: "Add BLE reconnection retry backoff"

# Confluence search
Search Confluence for pages about the Nightlight device protocol

# Get Confluence page
Get the Confluence page with title "Mobile Release Process"
```

---

## References

- [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
- [Docker Hub: ghcr.io/sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian/pkgs/container/mcp-atlassian)
- [Atlassian: API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
- [uv: Python package installer and runner](https://github.com/astral-sh/uv)
