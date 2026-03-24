
# LLDB MCP

> Debug Swift, Objective-C, and C++ apps with LLDB directly from your AI assistant.

## Overview

- **Homepage / repo**: [github.com/stass/lldb-mcp](https://github.com/stass/lldb-mcp)

`lldb-mcp` is a Model Context Protocol server that exposes LLDB — Apple's debugger — as a set of MCP tools. It lets an AI agent attach to running processes, set breakpoints, inspect variables, step through code, and evaluate expressions without leaving the chat session.

**Platform**: macOS only. LLDB ships with Xcode; no separate installation needed beyond a working Xcode setup.

**Key capabilities:**
- Attach to or launch Swift, Objective-C, and C++ processes
- Set and manage breakpoints by file/line or symbol name
- Inspect local variables, registers, and memory at runtime
- Step over, step into, step out, and continue execution
- Evaluate LLDB expressions and Swift/ObjC code in the debugger context
- Read crash logs and core dump state

---

## Authentication

**No authentication required.** `lldb-mcp` invokes the local `lldb` binary that ships with Xcode. The only prerequisite is a working Xcode installation with Command Line Tools active.

---

## Environment Variables

No environment variables are required or defined by `lldb-mcp`. The server discovers `lldb` via the system `PATH`, which is populated by Xcode Developer Tools.

---

## Setup

> **Prerequisites**: `Xcode` (or Xcode Command Line Tools) must be installed. Clone the repo and install the Python package once before configuring any client.
>
> ```zsh
> git clone https://github.com/stass/lldb-mcp "$HOME/code/other/mcp/lldb-mcp"
> cd "$HOME/code/other/mcp/lldb-mcp"
> pip install -e .
> ```
>
> The path `$HOME/code/other/mcp/lldb-mcp/` is the conventional clone location used in all configs below. Adjust if you clone elsewhere — the `lldb_mcp.py` path must be absolute.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // lldb - MCP server exposing LLDB debugging capabilities (breakpoints, variable
    // inspection, stepping, expression evaluation) for Swift/ObjC/C++ apps on macOS.
    //
    // # References
    // * [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
    //
    // # Installation
    // Must be cloned and installed locally.
    // ```zsh
    // git clone https://github.com/stass/lldb-mcp
    // cd lldb-mcp
    // pip install -e .
    // ```
    //
    // # Authorization
    // None required.
    "lldb": {
      "command": "python3",
      "args": ["${env:HOME}/code/other/mcp/lldb-mcp/lldb_mcp.py"]
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // lldb - MCP server exposing LLDB debugging capabilities (breakpoints, variable
  // inspection, stepping, expression evaluation) for Swift/ObjC/C++ apps on macOS.
  //
  // # References
  // * [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
  //
  // # Installation
  // Must be cloned and installed locally.
  // ```zsh
  // git clone https://github.com/stass/lldb-mcp
  // cd lldb-mcp
  // pip install -e .
  // ```
  //
  // # Authorization
  // None required.
  "servers": {
    "lldb": {
      "command": "python3",
      "args": ["${env:HOME}/code/other/mcp/lldb-mcp/lldb_mcp.py"]
    }
  }
}
```

### Claude Code (User scope)

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // lldb - MCP server exposing LLDB debugging capabilities (breakpoints, variable
  // inspection, stepping, expression evaluation) for Swift/ObjC/C++ apps on macOS.
  // Uses /bin/zsh -lc wrapper for PATH resolution in stdio transport.
  //
  // # References
  // * [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
  //
  // # Installation
  // Must be cloned and installed locally.
  // ```zsh
  // git clone https://github.com/stass/lldb-mcp
  // cd lldb-mcp
  // pip install -e .
  // ```
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "lldb": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "python3 $HOME/code/other/mcp/lldb-mcp/lldb_mcp.py"]
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // lldb - MCP server exposing LLDB debugging capabilities (breakpoints, variable
  // inspection, stepping, expression evaluation) for Swift/ObjC/C++ apps on macOS.
  // Uses /bin/zsh -lc wrapper for PATH resolution in stdio transport.
  //
  // # References
  // * [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
  //
  // # Installation
  // Must be cloned and installed locally.
  // ```zsh
  // git clone https://github.com/stass/lldb-mcp
  // cd lldb-mcp
  // pip install -e .
  // ```
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "lldb": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "python3 $HOME/code/other/mcp/lldb-mcp/lldb_mcp.py"]
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // lldb - MCP server exposing LLDB debugging capabilities (breakpoints, variable
  // inspection, stepping, expression evaluation) for Swift/ObjC/C++ apps on macOS.
  //
  // # References
  // * [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
  //
  // # Installation
  // Must be cloned and installed locally.
  // ```zsh
  // git clone https://github.com/stass/lldb-mcp
  // cd lldb-mcp
  // pip install -e .
  // ```
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "lldb": {
      "command": "python3",
      "args": ["/Users/your-username/code/other/mcp/lldb-mcp/lldb_mcp.py"]
    }
  }
}
```

> [!NOTE]
> Claude Desktop does not expand `$HOME` in `args`. Use the literal absolute path (e.g., `/Users/your-username/code/other/mcp/lldb-mcp/lldb_mcp.py`).

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // lldb - MCP server exposing LLDB debugging capabilities (breakpoints, variable
  // inspection, stepping, expression evaluation) for Swift/ObjC/C++ apps on macOS.
  // Uses /bin/zsh -lc wrapper for PATH resolution.
  //
  // # References
  // * [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
  //
  // # Installation
  // Must be cloned and installed locally.
  // ```zsh
  // git clone https://github.com/stass/lldb-mcp
  // cd lldb-mcp
  // pip install -e .
  // ```
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "lldb": {
      "command": "/bin/zsh",
      "args": ["-lc", "python3 $HOME/code/other/mcp/lldb-mcp/lldb_mcp.py"]
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Attach to a running process by name
Attach LLDB to the Nightlight app process

# Set a breakpoint at a symbol
Set a breakpoint on BLEClientCoordinator.sendCommand

# Set a breakpoint at a specific file and line
Set a breakpoint at BLEClient.swift line 142

# List all active breakpoints
List all breakpoints currently set

# Inspect local variables at the current frame
Show all local variables in the current stack frame

# Print the value of a specific variable
Print the value of the `command` variable

# Evaluate an expression in the current context
Evaluate the expression `peripheral.state.rawValue` in the current frame

# Step over the next line
Step over the current line

# Step into the next function call
Step into the next function call

# Continue execution until the next breakpoint
Continue execution

# Show the current backtrace
Show the call stack / backtrace for the current thread

# Read a crash log
Analyze the crash log at ~/Library/Logs/DiagnosticReports/Nightlight.crash
```

---

## References

- [GitHub: stass/lldb-mcp](https://github.com/stass/lldb-mcp)
- [LLDB Documentation](https://lldb.llvm.org/)
- [Apple Developer: Debugging with LLDB](https://developer.apple.com/documentation/xcode/debugging-with-the-xcode-debugger)
- [MCP overview: modelcontextprotocol.io](https://modelcontextprotocol.io/)
