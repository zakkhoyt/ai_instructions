
# Playwright MCP Server

> Browser automation with Playwright — navigate, interact, screenshot, and extract web content from any AI agent.

## Overview

- **GitHub**: [github.com/executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
- **npm package**: [`@executeautomation/playwright-mcp-server`](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
- **Transport**: stdio

`playwright-mcp-server` by executeautomation wraps the Playwright browser automation library as an MCP server. It gives AI agents full browser control: navigating to URLs, clicking elements, filling forms, taking screenshots, extracting page content, and running end-to-end test flows — all without leaving the agent session.

**Why useful:**
- Automate repetitive web tasks (form fills, data extraction, UI verification) from the agent.
- Take screenshots of pages for visual inspection or documentation.
- Run end-to-end tests against web apps during development.
- Scrape structured data from pages that require JavaScript execution.

> **Note**: Playwright browsers must be installed before first use:
> ```zsh
> npx playwright install
> ```

---

## Authentication

No authentication required for the MCP server itself. Target websites may require credentials — these are handled through the browser session (cookies, form login) just as a real user would.

---

## Environment Variables

None required for the server. Individual automation sessions may pass credentials inline as needed.

---

## Setup

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // playwright - Browser automation MCP server using Playwright. Navigate pages, click
    // elements, fill forms, take screenshots, and extract content from any AI agent.
    //
    // # References
    // * [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
    // * [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
    // * [Playwright Docs](https://playwright.dev/docs/intro)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    // Playwright browsers must be installed separately:
    //   npx playwright install
    //
    // # Authorization
    // None required.
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"]
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // playwright - Browser automation MCP server using Playwright. Workspace-scoped config.
  // Navigate pages, click elements, fill forms, take screenshots, and extract content.
  //
  // # References
  // * [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
  // * [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
  // * [Playwright Docs](https://playwright.dev/docs/intro)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  // Playwright browsers must be installed separately:
  //   npx playwright install
  //
  // # Authorization
  // None required.
  "servers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"]
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio playwright -- \
  npx -y @executeautomation/playwright-mcp-server
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // playwright - Browser automation MCP server using Playwright. Uses /bin/zsh -lc wrapper
  // for PATH resolution. Navigate, click, fill, screenshot, and extract from web pages.
  //
  // # References
  // * [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
  // * [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
  // * [Playwright Docs](https://playwright.dev/docs/intro)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  // Playwright browsers must be installed separately:
  //   npx playwright install
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @executeautomation/playwright-mcp-server"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // playwright - Browser automation MCP server using Playwright. Uses /bin/zsh -lc wrapper
  // for PATH resolution. Navigate, click, fill, screenshot, and extract from web pages.
  //
  // # References
  // * [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
  // * [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
  // * [Playwright Docs](https://playwright.dev/docs/intro)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  // Playwright browsers must be installed separately:
  //   npx playwright install
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @executeautomation/playwright-mcp-server"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // playwright - Browser automation MCP server using Playwright. No authentication required.
  // Navigate pages, click elements, fill forms, take screenshots, and extract content.
  //
  // # References
  // * [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
  // * [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
  // * [Playwright Docs](https://playwright.dev/docs/intro)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  // Playwright browsers must be installed separately:
  //   npx playwright install
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "playwright": {
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @executeautomation/playwright-mcp-server"]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // playwright - Browser automation MCP server using Playwright. Uses /bin/zsh -lc wrapper
  // for PATH resolution in Cursor. Navigate, click, fill, screenshot, and extract.
  //
  // # References
  // * [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
  // * [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
  // * [Playwright Docs](https://playwright.dev/docs/intro)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  // Playwright browsers must be installed separately:
  //   npx playwright install
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "playwright": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec npx -y @executeautomation/playwright-mcp-server"
      ]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Navigate to a page
Go to https://example.com and take a screenshot

# Extract page content
Go to https://news.ycombinator.com and extract the titles of the top 10 stories

# Fill and submit a form
Go to the login page at https://app.example.com, fill in username "admin" and password from env, then click Sign In

# Click an element
On the current page, click the button labeled "Download Report"

# Run an end-to-end test flow
Navigate to https://app.example.com, log in, create a new item named "Test", verify it appears in the list, then delete it

# Take a screenshot for documentation
Navigate to https://app.example.com/dashboard and take a screenshot for the README
```

---

## References

- [GitHub: executeautomation/mcp-playwright](https://github.com/executeautomation/mcp-playwright)
- [npm: @executeautomation/playwright-mcp-server](https://www.npmjs.com/package/@executeautomation/playwright-mcp-server)
- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright: Install browsers](https://playwright.dev/docs/browsers)
