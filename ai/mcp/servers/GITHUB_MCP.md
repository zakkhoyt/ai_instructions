
# GitHub MCP Server

> Access GitHub repositories, issues, pull requests, and code search from any AI agent.

## Overview

- **Homepage / docs**: [github.com/github/github-mcp-server](https://github.com/github/github-mcp-server)
- **MCP URL (HTTP)**: `https://api.githubcopilot.com/mcp/`
- **npm package**: [`@modelcontextprotocol/server-github`](https://www.npmjs.com/package/@modelcontextprotocol/server-github) (community server, older)

The GitHub MCP server exposes GitHub's API through structured MCP tools: repository browsing, issue and PR management, code search, file content access, commit history, and more.

**Two deployment options:**
1. **Remote HTTP** (`https://api.githubcopilot.com/mcp/`) — hosted by GitHub, requires GitHub Copilot subscription for VSCode Copilot. For other tools, authenticate with a GitHub PAT via `npx mcp-remote`.
2. **Local stdio** (`@modelcontextprotocol/server-github`) — runs locally via `npx`, authenticates with a GitHub PAT. Works with all AI tools.

**Why useful for Hatch iOS dev:**
- Create and review PRs without leaving the agent session.
- Search code across the Hatch mobile repo for patterns or usages.
- Read issue descriptions, comments, and linked PRs inline.
- Automate PR creation after code changes.

---

## Authentication

**Preferred method: GitHub Personal Access Token (PAT) — long-lived**

PATs can be created with fine-grained permissions and last up to 1 year (or indefinitely for classic tokens).

**How to obtain a token:**
1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Generate a **fine-grained personal access token** (recommended) or a classic token
3. Grant repository permissions appropriate for your use: read/write issues, PRs, code, etc.
4. Copy the token and store it in an environment variable

**GitHub Copilot OAuth (VSCode Copilot only):**
- When connecting via the VSCode Copilot extension marketplace, GitHub manages OAuth automatically
- This is handled by the `gallery` metadata in the config — no manual token needed
- Not applicable to Claude Code, Claude Desktop, or Cursor

---

## Environment Variables

| Variable                      | Description                                                    | Required                         |
| ----------------------------- | -------------------------------------------------------------- | -------------------------------- |
| `GITHUB_PERSONAL_ACCESS_TOKEN`| GitHub PAT for authenticating the stdio MCP server            | Yes (for non-Copilot tools)      |

**Set in `~/.zshrc`:**

```zsh
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token_here"
```

---

## Setup

### VSCode (User scope) — GitHub Copilot managed (recommended)

The VSCode Copilot extension handles GitHub OAuth automatically when the server is installed from the GitHub MCP gallery. The `gallery` field triggers this flow.

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // GitHub MCP — Copilot OAuth (managed by GitHub)
    // Install via: https://github.com/github/github-mcp-server
    // Auth is handled automatically via GitHub Copilot extension
    // Note: VSCode registers this as "io.github.github/github-mcp-server" when installed via Copilot gallery
    "io.github.github/github-mcp-server": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "gallery": "https://api.mcp.github.com",
      "version": "0.33.0"
    }
  }
}
```

### VSCode (User scope) — PAT variant (no Copilot subscription required)

```jsonc
{
  "servers": {
    // GitHub MCP — local stdio server with PAT auth
    // PAT: https://github.com/settings/tokens
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
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
    // GitHub MCP — PAT from env var
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio github -- \
  npx -y @modelcontextprotocol/server-github
```

Resulting entry in `~/.claude.json`:

```json
{
  "mcpServers": {
    "github": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
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
    "github": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
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
    // GitHub MCP — PAT from env var
    // PAT: https://github.com/settings/tokens
    // Note: Launch Claude Desktop from terminal to inherit GITHUB_PERSONAL_ACCESS_TOKEN.
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
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
    "github": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec npx -y @modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Browse a repository
Show me the directory structure of the hatch-mobile repository

# Search code
Search for all usages of BLEClient in the Hatch iOS repo

# List open PRs
List all open pull requests in the hatch-mobile repo assigned to me

# Get a PR
Get the details and diff for PR #1234

# Search issues
Search GitHub issues for "BLE timeout" in the Nightlight repo

# Create a PR
Create a pull request from branch zakk/HSD-12345/fix-ble-timeout to main
```

---

## References

- [GitHub: github/github-mcp-server](https://github.com/github/github-mcp-server)
- [GitHub: modelcontextprotocol/server-github (community)](https://github.com/modelcontextprotocol/servers/tree/main/src/github)
- [GitHub Personal Access Tokens](https://github.com/settings/tokens)
- [npm: @modelcontextprotocol/server-github](https://www.npmjs.com/package/@modelcontextprotocol/server-github)
- [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote) (HTTP-to-stdio proxy)
