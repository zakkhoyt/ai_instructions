
# Google Calendar MCP

> Read and create Google Calendar events from any AI agent (Anthropic-managed OAuth).

## Overview

- **MCP URL**: `https://gcal.mcp.claude.com/mcp`
- **Transport**: HTTP
- **Auth**: Anthropic-managed OAuth (Google account)

The Google Calendar MCP server is managed by Anthropic and provides tools for reading, searching, and creating calendar events. Authentication is handled entirely by Anthropic's OAuth integration with Google.

> **Status**: Stub — full documentation pending. This server is primarily available through Claude.ai / Claude Desktop Connectors. Third-party AI tool support may require `npx mcp-remote`.

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
2. Add MCP server URL: `https://gcal.mcp.claude.com/mcp`
3. Sign in with Google account when prompted

### Claude Code (via mcp-remote proxy)

```json
{
  "mcpServers": {
    "google-calendar": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-remote https://gcal.mcp.claude.com/mcp"]
    }
  }
}
```

---

## References

- [Anthropic: MCP Connectors](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Model Context Protocol](https://modelcontextprotocol.io)
