
# iTerm MCP

> Run terminal commands, read output, and interact with your active `iTerm2` session from any AI agent.

## Overview

- **Homepage / repo**: [github.com/ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
- **npm package**: [`iterm-mcp`](https://www.npmjs.com/package/iterm-mcp)

`iterm-mcp` is a Model Context Protocol server that bridges an AI agent to the active `iTerm2` terminal session. The agent can write commands, read back output (selecting only the lines it cares about for token efficiency), send control characters (`ctrl-c`, `ctrl-z`, etc.), and drive REPLs interactively.

> [!IMPORTANT]
> **macOS only.** `iterm-mcp` requires `iTerm2` to be installed and running. It has no equivalent on Linux or Windows and is not useful in those environments.

**Why useful for Hatch iOS dev:**

- Run `xcodebuild`, `swift`, `fastlane`, and `xcrun` commands through the agent without switching terminal windows.
- Drive interactive REPLs (`lldb`, `swift repl`) from chat.
- Monitor long-running build or test output and have the agent summarise only the relevant lines.
- Send `ctrl-c` to abort runaway processes the agent started.

### Tools (3 tools)

| Tool                   | Description                                                                            |
| ---------------------- | -------------------------------------------------------------------------------------- |
| `write_to_terminal`    | Writes text / a command to the active `iTerm2` terminal. Returns line count produced.  |
| `read_terminal_output` | Reads the requested number of lines from the active `iTerm2` terminal.                 |
| `send_control_character` | Sends a control character (e.g. `ctrl-c`, `ctrl-z`) to the active terminal.         |

---

## Authentication

None required.

---

## Environment Variables

No environment variables are required or supported by `iterm-mcp`.

---

## Setup

> [!NOTE]
> `iTerm2` must be installed and running before any tool call is made. Node.js `18+` is required. All configs below invoke `iterm-mcp` via `npx`, which downloads and caches the package on first run.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // iterm - MCP server providing terminal access to the active iTerm2 session.
    // Supports writing commands, reading output, and sending control characters.
    //
    // # References
    // * [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
    // * [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
    //
    // # Installation
    // Installed automatically via `npx` on first run. Requires iTerm2 and Node 18+.
    //
    // # Authorization
    // None required.
    "iterm": {
      "command": "npx",
      "args": ["-y", "iterm-mcp"]
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // iterm - MCP server providing terminal access to the active iTerm2 session.
  // Supports writing commands, reading output, and sending control characters.
  //
  // # References
  // * [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
  // * [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires iTerm2 and Node 18+.
  //
  // # Authorization
  // None required.
  "servers": {
    "iterm": {
      "command": "npx",
      "args": ["-y", "iterm-mcp"]
    }
  }
}
```

### Claude Code (User scope)

Run once in terminal:

```shell
claude mcp add --scope user --transport stdio iterm -- npx -y iterm-mcp
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // iterm - MCP server providing terminal access to the active iTerm2 session.
  // Supports writing commands, reading output, and sending control characters.
  //
  // # References
  // * [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
  // * [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires iTerm2 and Node 18+.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "iterm": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y iterm-mcp"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // iterm - MCP server providing terminal access to the active iTerm2 session.
  // Supports writing commands, reading output, and sending control characters.
  //
  // # References
  // * [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
  // * [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires iTerm2 and Node 18+.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "iterm": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y iterm-mcp"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // iterm - MCP server providing terminal access to the active iTerm2 session.
  // Supports writing commands, reading output, and sending control characters.
  //
  // # References
  // * [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
  // * [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires iTerm2 and Node 18+.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "iterm": {
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y iterm-mcp"]
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // iterm - MCP server providing terminal access to the active iTerm2 session.
  // Supports writing commands, reading output, and sending control characters.
  //
  // # References
  // * [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
  // * [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires iTerm2 and Node 18+.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "iterm": {
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y iterm-mcp"]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Run a shell command and read its output
Write "xcodebuild -list -workspace Nightlight.xcworkspace" to the terminal,
then read the last 30 lines of output.

# Abort a running process
Send ctrl-c to the active terminal to stop the current command.

# Check the last build result
Read the last 50 lines of terminal output to summarise any build errors.

# Run Swift package tests and report failures
Write "swift test" to the terminal, wait for it to finish,
then read the last 100 lines and list any failing tests.

# Start an lldb session
Write "lldb ./MyApp" to the terminal to start a debugging session,
then interact with the REPL interactively.

# Run fastlane and watch for errors
Write "bundle exec fastlane ios beta" to the terminal,
then read output incrementally and report any lane failures.
```

---

## References

- [GitHub: ferrislucas/iterm-mcp](https://github.com/ferrislucas/iterm-mcp)
- [npm: iterm-mcp](https://www.npmjs.com/package/iterm-mcp)
- [MCP overview: modelcontextprotocol.io](https://modelcontextprotocol.io/)
- [iTerm2](https://iterm2.com/)
