
# Siri Shortcuts MCP Server

> Run any Siri Shortcut from your AI agent on macOS.

## Overview

- **GitHub**: [github.com/dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
- **npm package**: [`mcp-server-siri-shortcuts`](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
- **Transport**: stdio
- **Platform**: macOS only (requires Shortcuts.app)

`mcp-server-siri-shortcuts` by dvcrn exposes your macOS Shortcuts library as MCP tools. Any shortcut defined in Shortcuts.app can be invoked by name from an AI agent, enabling deep integration with macOS automation workflows — media controls, file operations, system settings, home automation, and more.

**Why useful:**
- Trigger any shortcut you've already built without leaving the agent session.
- Chain AI-driven decisions with macOS automations (e.g., "archive this file and notify me via shortcut").
- Extend AI agents with custom macOS capabilities without writing server code.

---

## Authentication

No authentication required. The server communicates with Shortcuts.app directly via `shortcuts run` on the local machine. No API keys, tokens, or accounts needed.

---

## Environment Variables

None required.

---

## Setup

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // siri-shortcuts - Run any macOS Siri Shortcut from your AI agent via Shortcuts.app.
    // macOS only. No authentication required.
    //
    // # References
    // * [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
    // * [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
    //
    // # Installation
    // Installed automatically via `npx` on first run.
    //
    // # Authorization
    // None required.
    "siri-shortcuts": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-server-siri-shortcuts"]
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // siri-shortcuts - Run any macOS Siri Shortcut from your AI agent via Shortcuts.app.
  // macOS only. No authentication required. Workspace-scoped config.
  //
  // # References
  // * [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
  // * [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // None required.
  "servers": {
    "siri-shortcuts": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-server-siri-shortcuts"]
    }
  }
}
```

### Claude Code (User scope)

```shell
claude mcp add --scope user --transport stdio siri-shortcuts -- \
  npx -y mcp-server-siri-shortcuts
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // siri-shortcuts - Run any macOS Siri Shortcut from your AI agent via Shortcuts.app.
  // Uses /bin/zsh -lc wrapper for PATH resolution. macOS only.
  //
  // # References
  // * [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
  // * [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "siri-shortcuts": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-server-siri-shortcuts"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // siri-shortcuts - Run any macOS Siri Shortcut from your AI agent via Shortcuts.app.
  // Uses /bin/zsh -lc wrapper for PATH resolution. macOS only.
  //
  // # References
  // * [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
  // * [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "siri-shortcuts": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-server-siri-shortcuts"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // siri-shortcuts - Run any macOS Siri Shortcut from your AI agent via Shortcuts.app.
  // macOS only. No authentication required.
  //
  // # References
  // * [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
  // * [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "siri-shortcuts": {
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y mcp-server-siri-shortcuts"]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // siri-shortcuts - Run any macOS Siri Shortcut from your AI agent via Shortcuts.app.
  // Uses /bin/zsh -lc wrapper for PATH resolution in Cursor. macOS only.
  //
  // # References
  // * [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
  // * [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
  //
  // # Installation
  // Installed automatically via `npx` on first run.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "siri-shortcuts": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec npx -y mcp-server-siri-shortcuts"
      ]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# List available shortcuts
List all my Siri Shortcuts

# Run a shortcut by name
Run the shortcut "Morning Routine"

# Run a shortcut with input
Run the shortcut "Send Message" with input "Meeting starts in 5 minutes"

# Trigger a home automation shortcut
Run the shortcut "Goodnight" to activate my nighttime home scene

# Run a media control shortcut
Run the shortcut "Focus Music" to start my work playlist
```

---

## References

- [GitHub: dvcrn/mcp-server-siri-shortcuts](https://github.com/dvcrn/mcp-server-siri-shortcuts)
- [npm: mcp-server-siri-shortcuts](https://www.npmjs.com/package/mcp-server-siri-shortcuts)
- [Apple: Shortcuts User Guide](https://support.apple.com/guide/shortcuts/welcome/ios)
