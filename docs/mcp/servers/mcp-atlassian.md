
# mcp-atlassian (sooperset, 3rd-party)

> Third-party Atlassian MCP server — Jira and Confluence access via long-lived API tokens.

## Overview

- **GitHub**: [github.com/sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
- **Docker image**: `ghcr.io/sooperset/mcp-atlassian:latest`
- **Python (uvx)**: `uvx mcp-atlassian`

`mcp-atlassian` by sooperset is a third-party MCP server that exposes Jira and Confluence tools. Unlike the official Atlassian Rovo MCP, it uses standard Atlassian API tokens directly (no Basic Auth encoding required) and supports both Docker and `uvx` (Python package runner) deployment.

**72 tools** covering full Jira CRUD and Confluence:

| Category       | Tools                                                                                              |
| -------------- | -------------------------------------------------------------------------------------------------- |
| Jira issues    | `jira_get_issue`, `jira_create_issue`, `jira_update_issue`, `jira_delete_issue`                    |
| Comments       | `jira_add_comment`, `jira_edit_comment`                                                            |
| Links          | `jira_create_issue_link`, `jira_remove_issue_link`, `jira_create_remote_issue_link`                |
| Transitions    | `jira_get_transitions`, `jira_transition_issue`                                                    |
| Dev info       | `jira_get_issue_development_info` (PRs, builds, branches, commits)                                 |
| Watchers/votes | `jira_get_issue_watchers`, `jira_add_watcher`, `jira_remove_watcher`                              |
| Search         | `jira_search`, `jira_get_project_issues`                                                           |
| Sprints/Agile  | `jira_get_sprints_from_board`, `jira_add_issues_to_sprint`                                         |
| Confluence     | `confluence_search`, `confluence_get_page`, `confluence_create_page`, `confluence_update_page`     |

**Why prefer this over the official Atlassian Rovo MCP (for API-token users):**
- 72 full Jira CRUD + Confluence tools — the official Rovo MCP only exposes 2 beta tools (`getTeamworkGraphContext`, `getTeamworkGraphObject`) for API-token auth; full Jira CRUD via the official server requires a Rovo AI subscription or OAuth.
- Direct API token support — no base64 encoding ceremony.
- Tokens last up to 1 year vs. OAuth's ~2-day expiry.
- Self-hosted via `uvx` (no Docker) — no reliance on Atlassian's Rovo platform availability.

**Why prefer the official Atlassian Rovo MCP:**
- No toolchain install required (HTTP-only, no `uv`/Docker).
- Managed by Atlassian; tracks upstream API changes automatically.
- Required if your org mandates official Atlassian tooling.

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

> [!TIP]
> Docker is no longer required as of 2026-03-20. `uvx mcp-atlassian` runs the server directly without a container. The uvx method is now preferred.

**uvx variant (recommended — no Docker required):**

```zsh
# Install uv (provides the uvx runner)
brew install uv
# Confirm uvx is available
which uvx  # /opt/homebrew/bin/uvx
```

**Docker variant (legacy — still works):**

```zsh
# Pull the Docker image
docker pull ghcr.io/sooperset/mcp-atlassian:latest
```

### Token Requirement Note

The `JIRA_API_TOKEN` must be a standard Atlassian API token (e.g., `ATATT3x...`) created **without** the `appId=mcp` parameter. Tokens created via `?appId=mcp` are scoped to `mcp.atlassian.com` only and return HTTP 401 on the Jira REST API.

Create your token at:
- [Atlassian: API Tokens (standard, no appId restriction)](https://id.atlassian.com/manage-profile/security/api-tokens)

Use `expiryDays=max` for a 1-year token.

---

## Setup

### VSCode (User scope) — uvx (recommended, no Docker required)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // mcp-atlassian - 3rd-party Atlassian MCP server by sooperset. 72 tools covering Jira
    // and Confluence. Runs via uvx (no Docker required). Uses a scoped Atlassian API token.
    //
    // # References
    // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
    // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
    // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
    //
    // # Installation
    // Install `uv` via Homebrew (provides the `uvx` runner):
    //
    // ```zsh
    // brew install uv
    // ```
    //
    // # Authorization
    // 1) Create an Atlassian API Token (standard, not scoped to appId=mcp)
    //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
    //   * Create token with any name, note the value (e.g., ATATT3x...)
    // 2) Create an env file with your Jira credentials
    //   * Path: `~/.hatch/config/vscode/mcp-atlassian.env`
    //   * Contents: JIRA_URL, JIRA_USERNAME (email), JIRA_API_TOKEN
    "mcp-atlassian": {
      "type": "stdio",
      "command": "/opt/homebrew/bin/uvx",
      "args": [
        "mcp-atlassian",
        "--env-file", "<PATH_TO_MCP_ATLASSIAN_ENV_FILE>",
        "--transport", "stdio"
      ]
    }
  }
}
```

### VSCode (User scope) — Docker + .env file (legacy)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset). Legacy Docker variant with `.env`
  // file auth. Prefer the uvx variant above.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Requires Docker installed and image pulled:
  //
  // ```zsh
  // docker pull ghcr.io/sooperset/mcp-atlassian:latest
  // ```
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // 2) Create env file at `~/.hatch/config/vscode/mcp-atlassian.env` with:
  //   * JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN
  "servers": {
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
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset). Docker variant with workspace-local
  // `.env` file. Add `.vscode/mcp-atlassian.env` to `.gitignore`.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Requires Docker. Pull image:
  //
  // ```zsh
  // docker pull ghcr.io/sooperset/mcp-atlassian:latest
  // ```
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // 2) Create `.vscode/mcp-atlassian.env` with JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN
  // 3) Add `.vscode/mcp-atlassian.env` to `.gitignore`
  "servers": {
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
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset). Wrapper script injects credentials
  // from shell env (Docker or uvx). Wrapper at `~/.hatch/scripts/mcp_atlassian_wrapper.zsh`.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Requires either Docker or `uv` (`brew install uv`).
  // Wrapper script at `~/.hatch/scripts/mcp_atlassian_wrapper.zsh`.
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // 2) Set JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN in the wrapper script's source file
  //   * `~/.hatch/config/.zsh_hatch_jira`
  "servers": {
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

```jsonc
{
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset) via uvx. 72 Jira+Confluence tools.
  // Env vars for credentials; Claude Code inherits shell env.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Install `uv` via Homebrew: `brew install uv`
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  //   * Create token with any name, note the value (e.g., ATATT3x...)
  // 2) Set JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN in `~/.zshrc`; Claude Code inherits shell env
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

```jsonc
{
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset) via uvx. 72 Jira+Confluence tools.
  // Env vars for credentials; Claude Code inherits shell env.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Install `uv` via Homebrew: `brew install uv`
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  //   * Create token with any name, note the value (e.g., ATATT3x...)
  // 2) Set JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN in `~/.zshrc`; Claude Code inherits shell env
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
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset) via wrapper script. Script sources
  // Jira credentials from shell config.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Requires either Docker or `uv`. Wrapper script must be created at indicated path.
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // 2) Populate `~/.hatch/config/.zsh_hatch_jira` with JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN
  // 3) Set path in `command` field below
  "mcpServers": {
    "mcp-atlassian": {
      "command": "/Users/yourname/.hatch/scripts/mcp_atlassian_wrapper.zsh",
      "args": []
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // mcp-atlassian - 3rd-party Atlassian MCP (sooperset) via uvx with /bin/zsh -lc wrapper
  // for PATH resolution in Cursor.
  //
  // # References
  // * [GitHub: sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)
  // * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // * [GitHub: sooperset/mcp-atlassian - Configuration / Environment Variables](https://github.com/sooperset/mcp-atlassian#configuration)
  //
  // # Installation
  // Install `uv` via Homebrew: `brew install uv`
  //
  // # Authorization
  // 1) Create a standard Atlassian API Token (NOT scoped to appId=mcp)
  //   * [Atlassian: Manage API Tokens](https://id.atlassian.com/manage-profile/security/api-tokens)
  // 2) Set JIRA_URL, JIRA_USERNAME, JIRA_API_TOKEN in `~/.zshrc`
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
