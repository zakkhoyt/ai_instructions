
# Intercom MCP

> Access Intercom conversations, contacts, and help articles from any AI agent.

## Overview

- **MCP URL**: `https://mcp.intercom.com/mcp`
- **Transport**: HTTP (streamable HTTP)
- **Auth**: OAuth (managed by Intercom)

The official Intercom MCP server exposes customer conversations, contact records, and help center articles through MCP tools.

> **Status**: Stub — full documentation pending. Auth is OAuth-only (no long-lived token option confirmed as of March 2026). See references below.

---

## Authentication

**Method: OAuth (managed by Intercom)**

Authentication uses Intercom's OAuth flow. No long-lived API token option has been confirmed for MCP. Connect via supported AI tools that handle OAuth natively (e.g., Claude Desktop Connectors).

---

## Setup (Quick Reference)

### Claude Desktop (via Connectors)

1. Open Claude Desktop → Settings → Connectors
2. Add MCP server URL: `https://mcp.intercom.com/mcp`
3. Complete OAuth flow in browser

### VSCode

```jsonc
{
  "servers": {
    "intercom": {
      "type": "http",
      "url": "https://mcp.intercom.com/mcp"
    }
  }
}
```

---

## References

- [Intercom MCP documentation](https://mcp.intercom.com)
- [Intercom Developers](https://developers.intercom.com)
