
# Apple Docs MCP

> Access Apple's official developer documentation, frameworks, APIs, and WWDC videos from any AI agent.

## Overview

- **Homepage / repo**: [github.com/kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
- **npm package**: [`@kimsungwhee/apple-docs-mcp`](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)

`apple-docs-mcp` provides 15 tools for searching and browsing Apple's developer documentation directly inside an AI agent session. It covers SwiftUI, UIKit, Foundation, Core Data, ARKit, and every other Apple framework — plus WWDC video transcripts from 2012–2025 (bundled offline, no network request needed for WWDC content).

**Why useful for Hatch iOS dev:**
- Instant lookup of Swift/Objective-C APIs without leaving the chat session.
- WWDC transcript search surfaces guidance from Apple engineers on obscure topics.
- Platform compatibility analysis confirms which OS versions support a given API.
- 1,260+ WWDC sessions bundled in the package — works offline, zero rate limits.

### Tools (15 total)

| Tool                          | Description                                                           |
| ----------------------------- | --------------------------------------------------------------------- |
| `search_apple_docs`           | Full-text search across Apple Developer Documentation                 |
| `get_apple_doc_content`       | Fetch detailed documentation for a specific API or symbol             |
| `list_technologies`           | Browse all Apple technologies by category, platform, beta status      |
| `search_framework_symbols`    | Search classes, structs, protocols within a specific framework        |
| `get_related_apis`            | Find related APIs via inheritance, conformance, "See Also"            |
| `resolve_references_batch`    | Batch-resolve all API references extracted from a doc page            |
| `get_platform_compatibility`  | Check iOS/macOS/watchOS/tvOS/visionOS availability for an API         |
| `find_similar_apis`           | Discover Apple-recommended similar APIs and topic groupings           |
| `get_documentation_updates`   | Track recent WWDC announcements, SDK updates, release notes           |
| `get_technology_overviews`    | Get comprehensive technology guides with hierarchical navigation      |
| `get_sample_code`             | Browse Apple's sample code projects by framework or keyword           |
| `search_wwdc_videos`          | Search 1,260+ WWDC sessions by keyword, topic, or year                |
| `get_wwdc_video_details`      | Get full WWDC session transcript, code examples, and resources        |
| `list_wwdc_topics`            | List 19 topic categories (Swift, SwiftUI, Spatial Computing, etc.)   |
| `list_wwdc_years`             | List WWDC years with session counts (2012–2025)                       |

---

## Authentication

**No authentication required.** `apple-docs-mcp` calls Apple's public developer documentation JSON API. No tokens, no accounts.

---

## Environment Variables

| Variable                      | Description                                                       | Required |
| ----------------------------- | ----------------------------------------------------------------- | -------- |
| `USER_AGENT_ROTATION_ENABLED` | Enable UserAgent rotation — `"true"` or `"false"` (default true) | No       |
| `USER_AGENT_POOL_STRATEGY`    | Rotation strategy — `"random"`, `"sequential"`, or `"smart"`     | No       |
| `USER_AGENT_MAX_RETRIES`      | Max retry attempts per request (default `3`)                      | No       |
| `NODE_ENV`                    | Set to `"development"` for verbose debug logging                  | No       |

---

## Setup

> No API token needed. All configs below run `@kimsungwhee/apple-docs-mcp` via `npx`.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // apple-docs - Access Apple developer documentation, frameworks, APIs, and 1,260+ WWDC sessions
    // (2012–2025) offline via MCP. Covers iOS, macOS, watchOS, tvOS, visionOS.
    //
    // # References
    // * [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
    // * [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
    // * [GitHub: kimsungwhee/apple-docs-mcp - Environment Variables](https://github.com/kimsungwhee/apple-docs-mcp#environment-variables)
    //
    // # Installation
    // Installed automatically via `npx` on first run. No additional setup required.
    //
    // # Authorization
    // None required.
    "apple-docs": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // apple-docs - Access Apple developer documentation, frameworks, APIs, and 1,260+ WWDC
  // sessions (2012–2025) offline via MCP. Workspace-scoped config.
  //
  // # References
  // * [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
  // * [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
  // * [GitHub: kimsungwhee/apple-docs-mcp - Environment Variables](https://github.com/kimsungwhee/apple-docs-mcp#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run. No additional setup required.
  //
  // # Authorization
  // None required.
  "servers": {
    "apple-docs": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

### Claude Code (User scope)

Run once in terminal:

```shell
claude mcp add --scope user --transport stdio apple-docs -- npx -y @kimsungwhee/apple-docs-mcp@latest
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // apple-docs - Access Apple developer documentation, frameworks, APIs, and 1,260+ WWDC
  // sessions (2012–2025) offline via MCP. Uses /bin/zsh -lc wrapper for PATH resolution.
  //
  // # References
  // * [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
  // * [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
  // * [GitHub: kimsungwhee/apple-docs-mcp - Environment Variables](https://github.com/kimsungwhee/apple-docs-mcp#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run. No additional setup required.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "apple-docs": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // apple-docs - Access Apple developer documentation, frameworks, APIs, and 1,260+ WWDC
  // sessions (2012–2025) offline via MCP. Uses /bin/zsh -lc wrapper for PATH resolution.
  //
  // # References
  // * [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
  // * [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
  // * [GitHub: kimsungwhee/apple-docs-mcp - Environment Variables](https://github.com/kimsungwhee/apple-docs-mcp#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run. No additional setup required.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "apple-docs": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y @kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // apple-docs - Access Apple developer documentation, frameworks, APIs, and 1,260+ WWDC
  // sessions (2012–2025) offline via MCP. Claude Desktop config.
  //
  // # References
  // * [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
  // * [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
  // * [GitHub: kimsungwhee/apple-docs-mcp - Environment Variables](https://github.com/kimsungwhee/apple-docs-mcp#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run. No additional setup required.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "apple-docs": {
      "command": "npx",
      "args": ["-y", "@kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // apple-docs - Access Apple developer documentation, frameworks, APIs, and 1,260+ WWDC
  // sessions (2012–2025) offline via MCP. Cursor config.
  //
  // # References
  // * [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
  // * [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
  // * [GitHub: kimsungwhee/apple-docs-mcp - Environment Variables](https://github.com/kimsungwhee/apple-docs-mcp#environment-variables)
  //
  // # Installation
  // Installed automatically via `npx` on first run. No additional setup required.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "apple-docs": {
      "command": "npx",
      "args": ["-y", "@kimsungwhee/apple-docs-mcp@latest"]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Search for a specific API
Search for withAnimation API documentation

# Get full documentation for a symbol
Get detailed information about URLSession async/await methods

# Check platform compatibility
Get platform compatibility for SwiftData

# Explore framework structure
Show me SwiftUI framework API index

# Find related APIs
Find APIs related to UIViewController

# Browse WWDC sessions
Search WWDC videos about Swift concurrency

# Get WWDC session transcript
Get details for WWDC session 10176

# Track recent SDK changes
Show me the latest WWDC documentation updates

# Browse sample code
Show SwiftUI sample code projects
```

---

## References

- [GitHub: kimsungwhee/apple-docs-mcp](https://github.com/kimsungwhee/apple-docs-mcp)
- [npm: @kimsungwhee/apple-docs-mcp](https://www.npmjs.com/package/@kimsungwhee/apple-docs-mcp)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [WWDC Video Library](https://developer.apple.com/videos/)
