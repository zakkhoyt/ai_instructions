
# Web Search MCP Server

> Web search without API keys — search Google/Bing and extract page content from any AI agent using browser automation.

## Overview

- **GitHub**: [github.com/mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
- **Transport**: stdio
- **Installation**: Manual — must clone and build (no npm package published)

`web-search-mcp` by mrkrsl is a rare "no API key required" search server that performs web searches by driving a real browser via Playwright under the hood. Rather than calling a paid search API (e.g., Bing Search API, SerpAPI, Brave Search API), it opens a headless browser, navigates to Google or Bing, runs the query, and returns structured results — just as a human user would. This makes it completely free to use with no account or key setup.

**Why useful:**
- Perform web searches from your AI agent without any API subscription or key.
- Useful for research, documentation lookup, and information gathering during agent sessions.
- Works anywhere Playwright works — no external service dependency.

> **Note**: Because this server uses browser automation for search, it requires a local Playwright browser installation and a one-time manual build. The conventional clone location used in configs below is `$HOME/code/other/mcp/web-search-mcp/`.

---

## Authentication

No authentication required. No API keys, tokens, or accounts needed. Search is performed via headless browser automation.

---

## Environment Variables

None required.

---

## Setup

### Installation (required before first use)

This server has no published npm package and must be cloned and built manually:

```zsh
# Clone to the conventional location
git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
cd $HOME/code/other/mcp/web-search-mcp

# Install dependencies and build
npm install
npx playwright install
npm run build
```

The server entry point after building is:

```zsh
node $HOME/code/other/mcp/web-search-mcp/dist/index.js
```

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // web-search - Web search MCP server using Playwright browser automation. No API key
    // required. Searches Google/Bing and extracts page content via headless browser.
    //
    // # References
    // * [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
    //
    // # Installation
    // Manual build required — no npm package published:
    //   git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
    //   cd $HOME/code/other/mcp/web-search-mcp
    //   npm install && npx playwright install && npm run build
    //
    // # Authorization
    // None required.
    "web-search": {
      "type": "stdio",
      "command": "node",
      "args": ["${env:HOME}/code/other/mcp/web-search-mcp/dist/index.js"]
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // web-search - Web search MCP server using Playwright browser automation. No API key
  // required. Workspace-scoped config.
  //
  // # References
  // * [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
  //
  // # Installation
  // Manual build required — no npm package published:
  //   git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
  //   cd $HOME/code/other/mcp/web-search-mcp
  //   npm install && npx playwright install && npm run build
  //
  // # Authorization
  // None required.
  "servers": {
    "web-search": {
      "type": "stdio",
      "command": "node",
      "args": ["${env:HOME}/code/other/mcp/web-search-mcp/dist/index.js"]
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio web-search -- \
  node $HOME/code/other/mcp/web-search-mcp/dist/index.js
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // web-search - Web search MCP server using Playwright browser automation. No API key
  // required. Uses /bin/zsh -lc wrapper for HOME expansion and PATH resolution.
  //
  // # References
  // * [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
  //
  // # Installation
  // Manual build required — no npm package published:
  //   git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
  //   cd $HOME/code/other/mcp/web-search-mcp
  //   npm install && npx playwright install && npm run build
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "web-search": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "node $HOME/code/other/mcp/web-search-mcp/dist/index.js"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // web-search - Web search MCP server using Playwright browser automation. No API key
  // required. Uses /bin/zsh -lc wrapper for HOME expansion and PATH resolution.
  //
  // # References
  // * [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
  //
  // # Installation
  // Manual build required — no npm package published:
  //   git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
  //   cd $HOME/code/other/mcp/web-search-mcp
  //   npm install && npx playwright install && npm run build
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "web-search": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "node $HOME/code/other/mcp/web-search-mcp/dist/index.js"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // web-search - Web search MCP server using Playwright browser automation. No API key
  // required. Uses /bin/zsh -lc wrapper for HOME expansion.
  //
  // # References
  // * [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
  //
  // # Installation
  // Manual build required — no npm package published:
  //   git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
  //   cd $HOME/code/other/mcp/web-search-mcp
  //   npm install && npx playwright install && npm run build
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "web-search": {
      "command": "/bin/zsh",
      "args": ["-lc", "node $HOME/code/other/mcp/web-search-mcp/dist/index.js"]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // web-search - Web search MCP server using Playwright browser automation. No API key
  // required. Uses /bin/zsh -lc wrapper for HOME expansion and PATH resolution in Cursor.
  //
  // # References
  // * [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
  //
  // # Installation
  // Manual build required — no npm package published:
  //   git clone https://github.com/mrkrsl/web-search-mcp $HOME/code/other/mcp/web-search-mcp
  //   cd $HOME/code/other/mcp/web-search-mcp
  //   npm install && npx playwright install && npm run build
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "web-search": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "node $HOME/code/other/mcp/web-search-mcp/dist/index.js"
      ]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Search the web
Search the web for "Swift concurrency best practices 2024"

# Research a topic
Search for recent articles about Model Context Protocol server development

# Look up documentation
Search for the Playwright MCP server documentation

# Extract page content
Fetch the content of https://example.com and summarize it

# Research a library
Search for "mcp-server-siri-shortcuts npm" and tell me what it does
```

---

## References

- [GitHub: mrkrsl/web-search-mcp](https://github.com/mrkrsl/web-search-mcp)
- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright: Install browsers](https://playwright.dev/docs/browsers)
