
# GitHub Projects MCP

> Query and track GitHub Projects v2 boards, items, and fields from any AI agent.

---

## Overview

- **Homepage / docs**: [github.com/redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
- **PyPI package**: [`github-projects-mcp`](https://pypi.org/project/github-projects-mcp/)
- **Transport**: stdio
- **Installation**: `pip install github-projects-mcp` or `uvx github-projects-mcp` (preferred)

`github-projects-mcp` is a community MCP server that exposes the GitHub Projects v2 GraphQL API as MCP tools. It allows AI agents to read project boards, enumerate items, inspect field values, and track project status — all without leaving the agent session.

**Key capabilities:**
- List projects for a user or organization
- Read project items (cards) with their fields and statuses
- Inspect custom field definitions on a project
- Track project board state to understand sprint or backlog status

---

## Authentication

`github-projects-mcp` authenticates using a **GitHub Personal Access Token (PAT)**. The token must have the following OAuth scopes:

- `project` — Full read/write access to projects
- `read:project` — Read-only access to projects (minimum required for read operations)

**How to create a token:**
1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Choose **Tokens (classic)** and click **Generate new token (classic)**
3. Select scopes: `project` and/or `read:project`
4. Copy the token — it will not be shown again

---

## Environment Variables

| Variable       | Description                                              | Required |
| -------------- | -------------------------------------------------------- | -------- |
| `GITHUB_TOKEN` | GitHub PAT with `project` and `read:project` scopes     | Yes      |

**Set in `~/.zshrc`:**

```zsh
export GITHUB_TOKEN="ghp_your_token_here"
```

---

## Setup

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // github-projects - Query GitHub Projects v2 boards, items, and fields from AI agents.
    //
    // # References
    // * [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
    // * [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
    // * [GitHub: Create a PAT](https://github.com/settings/tokens)
    //
    // # Installation
    // ```zsh
    // pip install github-projects-mcp
    // ```
    // (Or: brew install uv && uvx github-projects-mcp)
    //
    // # Authorization
    // 1) Create a GitHub Personal Access Token
    //   * [GitHub: Create PAT](https://github.com/settings/tokens)
    //   * Select scopes: project, read:project
    // 2) Set as GITHUB_TOKEN env var in ~/.zshrc
    "github-projects": {
      "type": "stdio",
      "command": "uvx",
      "args": ["github-projects-mcp"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
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
    // # About
    // github-projects - Query GitHub Projects v2 boards, items, and fields from AI agents.
    // Workspace-scoped config.
    //
    // # References
    // * [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
    // * [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
    // * [GitHub: Create a PAT](https://github.com/settings/tokens)
    //
    // # Installation
    // ```zsh
    // pip install github-projects-mcp
    // ```
    // (Or: brew install uv && uvx github-projects-mcp)
    //
    // # Authorization
    // 1) Create a GitHub Personal Access Token
    //   * [GitHub: Create PAT](https://github.com/settings/tokens)
    //   * Select scopes: project, read:project
    // 2) Set as GITHUB_TOKEN env var in ~/.zshrc
    "github-projects": {
      "type": "stdio",
      "command": "uvx",
      "args": ["github-projects-mcp"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio github-projects -- \
  uvx github-projects-mcp
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // github-projects - Query GitHub Projects v2 boards, items, and fields from AI agents.
  //
  // # References
  // * [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
  // * [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
  // * [GitHub: Create a PAT](https://github.com/settings/tokens)
  //
  // # Installation
  // ```zsh
  // pip install github-projects-mcp
  // ```
  // (Or: brew install uv && uvx github-projects-mcp)
  //
  // # Authorization
  // 1) Create a GitHub Personal Access Token
  //   * [GitHub: Create PAT](https://github.com/settings/tokens)
  //   * Select scopes: project, read:project
  // 2) Set as GITHUB_TOKEN env var in ~/.zshrc; Claude Code inherits shell env
  "mcpServers": {
    "github-projects": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "uvx github-projects-mcp"],
      "env": {
        "GITHUB_TOKEN": "<YOUR_GITHUB_PAT>"
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
  // github-projects - Query GitHub Projects v2 boards, items, and fields from AI agents.
  // Project-scoped config.
  //
  // # References
  // * [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
  // * [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
  // * [GitHub: Create a PAT](https://github.com/settings/tokens)
  //
  // # Installation
  // ```zsh
  // pip install github-projects-mcp
  // ```
  // (Or: brew install uv && uvx github-projects-mcp)
  //
  // # Authorization
  // 1) Create a GitHub Personal Access Token
  //   * [GitHub: Create PAT](https://github.com/settings/tokens)
  //   * Select scopes: project, read:project
  // 2) Set as GITHUB_TOKEN env var in ~/.zshrc; Claude Code inherits shell env
  "mcpServers": {
    "github-projects": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "uvx github-projects-mcp"],
      "env": {
        "GITHUB_TOKEN": "<YOUR_GITHUB_PAT>"
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
  // github-projects - Query GitHub Projects v2 boards, items, and fields from AI agents.
  //
  // # References
  // * [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
  // * [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
  // * [GitHub: Create a PAT](https://github.com/settings/tokens)
  //
  // # Installation
  // ```zsh
  // pip install github-projects-mcp
  // ```
  // (Or: brew install uv && uvx github-projects-mcp)
  //
  // # Authorization
  // 1) Create a GitHub Personal Access Token
  //   * [GitHub: Create PAT](https://github.com/settings/tokens)
  //   * Select scopes: project, read:project
  // 2) Set as GITHUB_TOKEN env var in ~/.zshrc
  //   * Launch Claude Desktop from terminal to inherit GITHUB_TOKEN
  "mcpServers": {
    "github-projects": {
      "command": "/bin/zsh",
      "args": ["-lc", "uvx github-projects-mcp"],
      "env": {
        "GITHUB_TOKEN": "<YOUR_GITHUB_PAT>"
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
  // github-projects - Query GitHub Projects v2 boards, items, and fields from AI agents.
  //
  // # References
  // * [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
  // * [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
  // * [GitHub: Create a PAT](https://github.com/settings/tokens)
  //
  // # Installation
  // ```zsh
  // pip install github-projects-mcp
  // ```
  // (Or: brew install uv && uvx github-projects-mcp)
  //
  // # Authorization
  // 1) Create a GitHub Personal Access Token
  //   * [GitHub: Create PAT](https://github.com/settings/tokens)
  //   * Select scopes: project, read:project
  // 2) Set GITHUB_TOKEN in ~/.zshrc
  "mcpServers": {
    "github-projects": {
      "command": "/bin/zsh",
      "args": ["-lc", "uvx github-projects-mcp"],
      "env": {
        "GITHUB_TOKEN": "<YOUR_GITHUB_PAT>"
      }
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# List all projects for a user or org
List all GitHub Projects for the organization "my-org"

# List projects for my account
What GitHub Projects do I have?

# Read project items
Show me all items in project "Sprint 42"

# Check item status
What is the status of each item in the current sprint project?

# Inspect project fields
What custom fields are defined on the "Roadmap" project?

# Track backlog
List all items in the backlog column of project "Q3 Planning"

# Find items by status
Show all "In Progress" items in the team project board
```

---

## References

- [GitHub: redducklabs/github-projects-mcp](https://github.com/redducklabs/github-projects-mcp)
- [PyPI: github-projects-mcp](https://pypi.org/project/github-projects-mcp/)
- [GitHub Personal Access Tokens](https://github.com/settings/tokens)
- [GitHub Projects v2 documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects)
- [GitHub Projects v2 GraphQL API](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-api-to-manage-projects)
