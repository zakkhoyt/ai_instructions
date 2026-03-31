
# Granola MCP

> Access Granola meeting notes and transcripts from any AI agent.

## Overview

- **MCP URL**: `https://mcp.granola.ai/mcp`
- **Transport**: HTTP
- **Auth**: OAuth (Granola account)

Granola is an AI meeting notes tool. Its MCP server exposes meeting notes, transcripts, and summaries from your Granola account.

> **Status**: Stub — full documentation pending. Auth is OAuth. See references below.

---

## Authentication

**Method: OAuth (Granola account)**

Authentication uses Granola's OAuth flow. Connect via AI tools that handle OAuth natively or use `npx mcp-remote` with an auth token if available.

---

## Setup (Quick Reference)

### Claude Desktop (via Connectors)

1. Open Claude Desktop → Settings → Connectors
2. Add MCP server URL: `https://mcp.granola.ai/mcp`
3. Complete OAuth flow when prompted

### VSCode

```jsonc
{
  "servers": {
    "granola": {
      "type": "http",
      "url": "https://mcp.granola.ai/mcp"
    }
  }
}
```

---

## References

- [Granola](https://granola.ai)
- [Granola MCP](https://mcp.granola.ai)
