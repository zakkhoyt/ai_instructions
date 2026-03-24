
# Figma MCP

> Access Figma design files, components, and variables from any AI agent.

## Overview

- **MCP URL**: `https://mcp.figma.com/mcp`
- **Auth setup**: [figma.com/developers/api#access-tokens](https://www.figma.com/developers/api#access-tokens)
- **Transport**: HTTP (SSE or streamable HTTP)

The official Figma MCP server provides tools for reading design files, inspecting components, variables, and design tokens.

> **Status**: Stub — full documentation pending. See references below for setup details.

---

## Authentication

**Method: Personal Access Token (long-lived)**

1. Go to [figma.com → Account Settings → Security → Personal access tokens](https://www.figma.com/developers/api#access-tokens)
2. Create a new token with a descriptive label
3. Store in env var: `export FIGMA_PERSONAL_ACCESS_TOKEN="figd_..."`

---

## Environment Variables

| Variable                      | Description                      | Required |
| ----------------------------- | -------------------------------- | -------- |
| `FIGMA_PERSONAL_ACCESS_TOKEN` | Figma personal access token      | Yes      |

---

## Setup (Quick Reference)

### VSCode

```jsonc
{
  "servers": {
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp",
      "headers": {
        "X-Figma-Token": "${FIGMA_PERSONAL_ACCESS_TOKEN}"
      }
    }
  }
}
```

### Claude Desktop

```jsonc
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote",
        "https://mcp.figma.com/mcp",
        "--header", "X-Figma-Token: ${FIGMA_PERSONAL_ACCESS_TOKEN}"
      ]
    }
  }
}
```

---

## References

- [Figma MCP Server announcement](https://www.figma.com/blog/figma-developer-platform-2025/)
- [Figma API: Personal access tokens](https://www.figma.com/developers/api#access-tokens)
- [npm: mcp-remote](https://www.npmjs.com/package/mcp-remote)
