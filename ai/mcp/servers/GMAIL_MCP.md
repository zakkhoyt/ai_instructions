
# Gmail MCP

> Read and compose Gmail messages from any AI agent (Anthropic-managed OAuth).

## Overview

- **MCP URL**: `https://gmail.mcp.claude.com/mcp`
- **Transport**: HTTP
- **Auth**: Anthropic-managed OAuth (Google account)

The Gmail MCP server is managed by Anthropic and provides tools for reading, searching, and composing Gmail messages. Authentication is handled entirely by Anthropic's OAuth integration with Google.

> **Status**: Stub — full documentation pending. This server is primarily available through Claude.ai / Claude Desktop Connectors. Third-party AI tool support (Claude Code, VSCode Copilot, Cursor) may require `npx mcp-remote`.

---

## Authentication

**Method: Anthropic-managed OAuth (Google)**

- Anthropic manages the Google OAuth integration
- Authenticate once via Claude Desktop Connectors or Claude.ai
- No long-lived API token option (Google OAuth only)

---

## Setup (Quick Reference)

### Claude Desktop (via Connectors — recommended)

1. Open Claude Desktop → Settings → Connectors
2. Add MCP server URL: `https://gmail.mcp.claude.com/mcp`
3. Sign in with Google account when prompted

### Claude Code (via mcp-remote proxy)

```json
{
  "mcpServers": {
    "gmail": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-remote https://gmail.mcp.claude.com/mcp"]
    }
  }
}
```

---

## References

- [Anthropic: MCP Connectors](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)
