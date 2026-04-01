
# XcodeBuildMCP

> Build, test, and automate Xcode and Swift projects from any AI agent.

## Overview

- **Homepage / repo**: [github.com/getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
- **npm package**: [`xcodebuildmcp`](https://www.npmjs.com/package/xcodebuildmcp)

`XcodeBuildMCP` wraps `xcodebuild`, `simctl`, `devicectl`, and related Apple toolchain CLIs behind 61+ structured MCP tools. It lets an AI agent discover Xcode projects, compile code, run the iOS Simulator, deploy to physical devices, execute UI automation, and capture logs — all without leaving the chat session.

**Why useful for Hatch iOS dev:**
- Drives the full `Nightlight.xcworkspace` build + test loop without context-switching to Xcode.
- Supports real-device deployment via `devicectl` (useful for BLE hardware testing).
- UI automation tools can script smoke tests against simulator builds.
- Log-capture tools surface `os.Logger` / `NSLog` output directly in the agent response.

### Tool Categories (61+ tools)

| Workflow            | Tool count | What it covers                                       |
| ------------------- | ---------- | ---------------------------------------------------- |
| `swift-package`     | 6          | Build, run, test Swift Package Manager projects      |
| `simulator`         | 10         | Boot, install, and launch apps on iOS Simulator      |
| `device`            | 6          | Install, launch, and test on physical Apple devices  |
| `macos`             | 5          | Build, run, and test macOS applications              |
| `ui-testing`        | 11         | Tap, swipe, type, screenshot via UI automation       |
| `project-discovery` | 3          | Find `.xcodeproj`, `.xcworkspace`, schemes, settings |
| `xcodebuild`        | 8          | Clean, build, and test via raw `xcodebuild`          |
| `scaffolding`       | 2          | Create new iOS/macOS projects from templates         |
| `log-capture`       | 4          | Capture app logs from simulators and devices         |
| `app-management`    | 3          | Get bundle IDs, app paths, stop running apps         |
| `simulator-config`  | 3          | Set location, appearance, and status bar             |
| `video-recording`   | 1          | Record simulator screen to video                     |

---

## Authentication

**No authentication required.** `XcodeBuildMCP` invokes local Apple toolchain binaries (`xcodebuild`, `simctl`, `devicectl`). The only prerequisite is a working Xcode installation with Command Line Tools active.

---

## Environment Variables

| Variable                          | Description                                                              | Required |
| --------------------------------- | ------------------------------------------------------------------------ | -------- |
| `XCODEBUILDMCP_DYNAMIC_TOOLS`     | Enable dynamic tool loading — `"true"` or `"false"`                     | No       |
| `INCREMENTAL_BUILDS_ENABLED`      | Enable incremental builds — `"true"` or `"false"` (default `"true"`)   | No       |
| `XCODEBUILDMCP_ENABLED_WORKFLOWS` | Comma-separated list of workflow categories to expose                    | No       |
| `XCODEBUILDMCP_SENTRY_DISABLED`   | Disable Sentry telemetry — `"true"` to opt out                          | No       |
| `NODE_ENV`                        | Set to `"development"` to enable debug-mode logging                     | No       |
| `DEBUG`                           | Set to `"*"` for full verbose debug output (combine with `NODE_ENV`)    | No       |

### `XCODEBUILDMCP_ENABLED_WORKFLOWS` Values

| Value               | Description                                    |
| ------------------- | ---------------------------------------------- |
| `project-discovery` | Find `.xcodeproj` and `.xcworkspace` files     |
| `swift-package`     | SPM build / test / run                         |
| `simulator`         | iOS Simulator control                          |
| `device`            | Physical device testing                        |
| `macos`             | macOS builds                                   |
| `doctor`            | System health check                            |
| `ui-testing`        | UI automation                                  |
| `xcodebuild`        | Raw `xcodebuild` operations                    |
| `scaffolding`       | Create new projects                            |
| `log-capture`       | App log collection                             |
| `app-management`    | Bundle ID lookup, app paths                    |
| `simulator-config`  | Simulator appearance / location settings       |
| `video-recording`   | Simulator screen recording                     |

**Recommended sets:**

```
# Hatch iOS / Nightlight workspace
project-discovery,swift-package,simulator,device,macos,doctor,ui-testing

# SPM-only module work
swift-package,simulator,project-discovery,doctor
```

---

## Installation

### Homebrew (recommended)

```zsh
brew tap getsentry/xcodebuildmcp
brew install xcodebuildmcp
```

### npx (no install needed)

```zsh
npx -y xcodebuildmcp@latest mcp
```

### Project-Level Defaults

XcodeBuildMCP supports a `.xcodebuildmcp/config.yaml` file for project-level defaults (workspace, scheme, simulator). This avoids repeating paths in every prompt. See [CONFIGURATION.md](https://github.com/getsentry/XcodeBuildMCP/blob/main/docs/CONFIGURATION.md) for details.

---

## Setup

> No API token is needed. All configs below invoke `xcodebuildmcp` via `npx`, which downloads and caches the package on first run. Set `INCREMENTAL_BUILDS_ENABLED` to `"false"` if you experience stale-artifact issues during iterative development.

### VSCode (User scope)

File: `~/Library/Application Support/Code/User/mcp.json`

```jsonc
{
  "servers": {
    // # About
    // XcodeBuildMCP - MCP server providing 61+ tools for Xcode and Swift development automation
    // (build, test, simulator control, device interaction, UI automation, project scaffolding)
    //
    // # References
    // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
    // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
    // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
    //
    // # Installation
    // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
    //
    // # Authorization
    // None required. Invokes local Apple toolchain binaries (`xcodebuild`, `simctl`, `devicectl`).
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"],
      "env": {
        "INCREMENTAL_BUILDS_ENABLED": "false",
        "NODE_ENV": "development",
        // "DEBUG": "*",
        // "XCODEBUILDMCP_SENTRY_DISABLED": "false",
        // "XCODEBUILDMCP_DYNAMIC_TOOLS": "false",  // set "true" for dynamic tool loading
        // Workflow sets (used when XCODEBUILDMCP_DYNAMIC_TOOLS=false):
        // For HatchSleep type projects:
        // "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,swift-package,simulator,device,macos,doctor,ui-testing",
        // For SPM-only projects:
        // "XCODEBUILDMCP_ENABLED_WORKFLOWS": "swift-package,simulator,project-discovery,doctor",
      }
    }
  }
}
```

With minimal env (simpler variant):

```jsonc
{
  // # About
  // XcodeBuildMCP - MCP server for Xcode and Swift development automation. Minimal env
  // variant with dynamic tool loading enabled (XCODEBUILDMCP_DYNAMIC_TOOLS=true).
  //
  // # References
  // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
  // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
  // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
  //
  // # Authorization
  // None required.
  "servers": {
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"],
      "env": {
        "XCODEBUILDMCP_DYNAMIC_TOOLS": "true",
        "INCREMENTAL_BUILDS_ENABLED": "false"
      }
    }
  }
}
```

### VSCode (Workspace scope)

File: `.vscode/mcp.json`

```jsonc
{
  // # About
  // XcodeBuildMCP - MCP server for Xcode and Swift development automation. Workspace-scoped
  // config with XCODEBUILDMCP_ENABLED_WORKFLOWS tailored to this project.
  //
  // # References
  // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
  // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
  // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
  //
  // # Authorization
  // None required.
  "servers": {
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"],
      "env": {
        "XCODEBUILDMCP_DYNAMIC_TOOLS": "true",
        "INCREMENTAL_BUILDS_ENABLED": "false",
        // Tailor to project type (see XCODEBUILDMCP_ENABLED_WORKFLOWS values above):
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,swift-package,simulator,device,macos,doctor,ui-testing"
      }
    }
  }
}
```

Optional — enable auto-approval for all `XcodeBuildMCP` tools. Add to `.code-workspace` or VSCode `settings.json`:

```jsonc
{
  "settings": {
    "chat.tools.eligibleForAutoApproval": {
      "mcp_xcodebuildmcp_*": true
    }
  }
}
```

### Claude Code (User scope)

Run once in terminal:

```shell
claude mcp add --scope user --transport stdio XcodeBuildMCP -- xcodebuildmcp mcp
```

Resulting entry in `~/.claude.json`:

```jsonc
{
  // # About
  // XcodeBuildMCP - MCP server for Xcode and Swift development automation. Uses
  // /bin/zsh -lc wrapper for PATH resolution in stdio transport.
  //
  // # References
  // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
  // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
  // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "XcodeBuildMCP": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y xcodebuildmcp@latest mcp"],
      "env": {
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,swift-package,simulator,device,macos,doctor,ui-testing"
      }
    }
  }
}
```

### Claude Code (Project scope)

File: `.mcp.json` in repo root

```jsonc
{
  // # About
  // XcodeBuildMCP - MCP server for Xcode and Swift development automation. Uses
  // /bin/zsh -lc wrapper for PATH resolution in stdio transport.
  //
  // # References
  // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
  // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
  // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "XcodeBuildMCP": {
      "type": "stdio",
      "command": "/bin/zsh",
      "args": ["-lc", "npx -y xcodebuildmcp@latest mcp"],
      "env": {
        "INCREMENTAL_BUILDS_ENABLED": "false",
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,swift-package,simulator,device,macos,doctor,ui-testing"
      }
    }
  }
}
```

### Claude Desktop

File: `~/Library/Application Support/Claude/claude_desktop_config.json`

```jsonc
{
  // # About
  // XcodeBuildMCP - MCP server for Xcode and Swift development automation.
  // Claude Desktop config using npx for stdio transport.
  //
  // # References
  // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
  // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
  // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "npx",
      "args": ["-y", "xcodebuildmcp@latest", "mcp"],
      "env": {
        "INCREMENTAL_BUILDS_ENABLED": "false",
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,swift-package,simulator,device,macos,doctor,ui-testing"
      }
    }
  }
}
```

### Cursor

Global: `~/.cursor/mcp.json` — or project: `.cursor/mcp.json`

```jsonc
{
  // # About
  // XcodeBuildMCP - MCP server for Xcode and Swift development automation. Cursor config
  // using /bin/zsh -lc wrapper for PATH resolution.
  //
  // # References
  // * [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
  // * [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
  // * [GitHub: getsentry/XcodeBuildMCP - Configuration / Environment Variables](https://github.com/getsentry/XcodeBuildMCP#configuration)
  //
  // # Installation
  // Installed automatically via `npx` on first run. Requires Xcode and Apple Developer Tools.
  //
  // # Authorization
  // None required.
  "mcpServers": {
    "XcodeBuildMCP": {
      "command": "/bin/zsh",
      "args": [
        "-lc",
        "cd \"${workspaceFolder}\" && exec npx -y xcodebuildmcp@latest mcp"
      ],
      "env": {
        "XCODEBUILDMCP_ENABLED_WORKFLOWS": "project-discovery,swift-package,simulator,device,macos,doctor,ui-testing"
      }
    }
  }
}
```

---

## Common Prompts / Usage Examples

```
# Check that Xcode, CLT, and simulators are healthy
/#mcp_xcodebuildmcp_doctor

# Discover all Xcode projects and workspaces under the current directory
/#mcp_xcodebuildmcp_discover_projs

# List build schemes for the current workspace
/#mcp_xcodebuildmcp_list_schemes

# Build an SPM package
/#mcp_xcodebuildmcp_swift_package_build --packagePath "/path/to/HatchModules"

# Run all SPM tests
/#mcp_xcodebuildmcp_swift_package_test --packagePath "/path/to/HatchModules"

# Boot an iPhone 16 simulator
/#mcp_xcodebuildmcp_boot_simulator --simulatorName "iPhone 16"

# Build and install on booted simulator
/#mcp_xcodebuildmcp_build_and_install_simulator \
  --workspace "Nightlight.xcworkspace" \
  --scheme "Nightlight_Development_iPhone_Only"

# Take a screenshot of the running simulator
/#mcp_xcodebuildmcp_take_screenshot

# Stream live app logs from simulator
/#mcp_xcodebuildmcp_stream_app_logs --bundleId "co.hatch.nightlight"
```

---

## Scoping

XcodeBuildMCP should be scoped to **iOS-focused agents only**, not enabled globally. This keeps non-iOS conversations (Android, docs, etc.) free of irrelevant tool noise.

### Claude Code

Use `mcpServers` in agent YAML frontmatter to scope to specific agents:

```yaml
---
mcpServers:
  - XcodeBuildMCP
---
```

The server definition (command, args) must exist in `.mcp.json` (project-level) or `~/.claude/mcp.json` (user-level).

### GitHub Copilot

Use `mcp-servers` in agent YAML frontmatter (per-agent scoping):

```yaml
---
mcp-servers:
  XcodeBuildMCP:
    type: 'local'
    command: 'xcodebuildmcp'
    args: ['mcp']
    tools: ["*"]
---
```

No separate `.mcp.json` needed — Copilot reads the server definition directly from the agent frontmatter.

### OpenAI Codex

Codex CLI supports MCP servers via `codex mcp add` or a `config.toml` file.

**Add via CLI:**

```zsh
codex mcp add xcodebuildmcp -- xcodebuildmcp mcp
```

**Or add to `~/.codex/config.toml`:**

```toml
[mcp_servers.xcodebuildmcp]
command = "xcodebuildmcp"
args = ["mcp"]
```

See the [Codex CLI docs](https://github.com/openai/codex) for full MCP configuration details.


---

## References

- [GitHub: getsentry/XcodeBuildMCP](https://github.com/getsentry/XcodeBuildMCP)
- [npm: xcodebuildmcp](https://www.npmjs.com/package/xcodebuildmcp)
- [Official setup guide (Google Doc)](https://docs.google.com/document/d/1Qmpdh4kxbw1IAnX0fIUP-Jt5QbbZgnpIlyuZt1GtW6I/)
- [MCP overview: modelcontextprotocol.io](https://modelcontextprotocol.io/)
