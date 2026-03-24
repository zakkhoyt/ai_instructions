
# GitHub Actions MCP Server (ko1ynnky)

> **ARCHIVED — Superseded by the official GitHub MCP server.**

---

> [!CAUTION]
> This server (`ko1ynnky/github-actions-mcp-server`) was **archived in July 2025**. Its functionality has been merged into the official GitHub MCP server ([`github/github-mcp-server`](https://github.com/github/github-mcp-server)).
>
> Do not configure this server for new projects. Use [`github/github-mcp-server`](https://github.com/github/github-mcp-server) instead — it includes full GitHub Actions support.

---

## What This Server Did

`github-actions-mcp-server` was a community-built MCP server that exposed GitHub Actions workflows via the MCP protocol, allowing AI agents to:

- Trigger workflow runs (`workflow_dispatch`)
- List and filter workflow runs by branch, status, or conclusion
- Check run status and poll for completion
- Retrieve run logs for failed or completed jobs
- Cancel in-progress workflow runs

It used the GitHub REST API under the hood, authenticated via a GitHub Personal Access Token (PAT), and ran as a local `stdio` process.

---

## Migration: Use the Official GitHub MCP Server

The [`github/github-mcp-server`](https://github.com/github/github-mcp-server) now includes GitHub Actions capabilities that cover everything this archived server provided, plus the full breadth of GitHub's API surface (repos, issues, PRs, code search, etc.).

See [`GITHUB_MCP.md`](./GITHUB_MCP.md) for setup instructions for all AI tools.

**Quick reference — official server capabilities include:**
- All GitHub Actions functionality previously in this server
- Repository browsing and file content access
- Issue and pull request management
- Code search
- Commit history

---

## Archived Configuration (for reference only)

> [!WARNING]
> The configuration below is **deprecated**. The server repository is archived and no longer maintained. These snippets are preserved for historical reference only.

```jsonc
// DEPRECATED — archived July 2025
// Use github/github-mcp-server instead: https://github.com/github/github-mcp-server
// See GITHUB_MCP.md for current setup instructions.
{
  "mcpServers": {
    "github-actions": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "github-actions-mcp-server"],
      "env": {
        "GITHUB_TOKEN": "<YOUR_GITHUB_PAT>"
      }
    }
  }
}
```

---

## References

- [ko1ynnky/github-actions-mcp-server (archived)](https://github.com/ko1ynnky/github-actions-mcp-server) — original archived repository
- [github/github-mcp-server](https://github.com/github/github-mcp-server) — official GitHub MCP server (use this instead)
- [GitHub Personal Access Tokens](https://github.com/settings/tokens)
- [`GITHUB_MCP.md`](./GITHUB_MCP.md) — setup guide for the official GitHub MCP server
