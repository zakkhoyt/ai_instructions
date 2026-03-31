
# SourceKit-LSP (iOS / Swift)

> Apple's official Swift Language Server Protocol implementation — gives your AI assistant real-time code intelligence: go-to-definition, hover docs, cross-module references, and diagnostics across the entire Hatch iOS codebase.

## Overview

- **Repo**: [github.com/swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp)
- **Protocol**: LSP (Language Server Protocol) — **not** MCP
- **Transport**: stdio
- **Config file**: `.claude/.lsp.json` (Claude Code) — see per-client notes below
- **Binary**: `sourcekit-lsp` — **ships with Xcode**; no separate install needed

SourceKit-LSP is Apple's official LSP server for Swift and C-family languages (C, C++, Objective-C). It layers on top of `sourcekitd` (Swift) and `clangd` (C/ObjC) to provide full code intelligence. It is bundled with every Xcode installation and every Swift toolchain from swift.org.

> **LSP vs MCP**: Unlike the MCP servers in this directory, SourceKit-LSP uses the [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) and is configured through your AI client's LSP plugin system — not through `mcpServers` / `servers` config blocks.

---

## Why This Config Is Needed for Hatch

The Hatch repo is a monorepo. Without explicit configuration, Claude Code starts `sourcekit-lsp` from the repo root and never discovers `Nightlight.xcworkspace` two levels deep at `iOS/hatch-sleep-app/`. This causes all cross-module imports (`HatchModels`, `ArgumentKit`, etc.) to go unresolved.

The `.claude/.lsp.json` config pins `workspaceFolder` to `iOS/hatch-sleep-app` so SourceKit-LSP finds the workspace and builds its module index correctly.

---

## Capabilities

| Feature | Supported |
|---------|-----------|
| Code completion | ✅ |
| Go to definition | ✅ |
| Find all references | ✅ (after build / background index) |
| Hover (type info, docs) | ✅ |
| Diagnostics | ✅ |
| Semantic syntax highlighting | ✅ |
| Cross-module navigation | ✅ (requires indexed build) |
| Refactoring actions | ✅ |
| Background indexing | ✅ (experimental, opt-in) |

---

## Installation

No separate installation is needed. `sourcekit-lsp` ships with Xcode:

```zsh
# Verify the binary is available:
xcrun --find sourcekit-lsp
# → /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp
```

---

## Claude Code Setup

### Config file location

Place the following at the **repo root**:

```
.claude/.lsp.json
```

### Hatch monorepo config

```jsonc
{
  // SourceKit-LSP — Swift language intelligence for Claude Code
  //
  // References:
  // * [Claude Code: LSP plugin docs](https://docs.anthropic.com/en/docs/claude-code/lsp)
  // * [GitHub: swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp)
  // * [sourcekit-lsp: Configuration File](https://github.com/swiftlang/sourcekit-lsp/blob/main/Documentation/Configuration%20File.md)
  //
  // Why workspaceFolder = iOS/hatch-sleep-app:
  //   Without this, sourcekit-lsp starts from the monorepo root and never
  //   discovers Nightlight.xcworkspace, causing all cross-module imports to
  //   go unresolved (HatchModels, ArgumentKit, etc.)
  "sourcekit-lsp": {
    "command": "sourcekit-lsp",
    "args": [
      "--scratch-path",
      ".build/sourcekit-lsp"
    ],
    "extensionToLanguage": {
      ".swift": "swift"
    },
    "workspaceFolder": "iOS/hatch-sleep-app",
    "startupTimeout": 15000,
    "restartOnCrash": true,
    "maxRestarts": 3
  }
}
```

> **Note**: This file is already committed to the repo via [PR #1491](https://github.com/hatch-baby/mobile/pull/1491). No action needed if you've pulled `main`.

### All `.lsp.json` fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | `string` | LSP binary to execute. Must be in `$PATH` or a full path. |
| `args` | `string[]` | Command-line arguments. Use `--scratch-path` to set the index cache location. |
| `extensionToLanguage` | `object` | Maps file extensions to LSP language identifiers. |
| `workspaceFolder` | `string` | Workspace root path passed to the server. **Critical for monorepos.** |
| `startupTimeout` | `number` | Max milliseconds to wait for the server to start. |
| `shutdownTimeout` | `number` | Max milliseconds to wait for graceful shutdown. |
| `restartOnCrash` | `boolean` | Automatically restart on crash. |
| `maxRestarts` | `number` | Max consecutive restart attempts before giving up. |
| `env` | `object` | Extra environment variables for the server process. |
| `initializationOptions` | `object` | Options sent in the LSP `initialize` request. |
| `settings` | `object` | Settings sent via `workspace/didChangeConfiguration`. |
| `transport` | `string` | `"stdio"` (default) or `"socket"`. |

---

## VSCode / GitHub Copilot

VSCode handles SourceKit-LSP automatically via the [Swift extension for VS Code](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang). No manual `.lsp.json` is required.

```zsh
# Install the Swift extension:
code --install-extension sswg.swift-lang
```

The extension auto-discovers `sourcekit-lsp` from the active Xcode toolchain and configures workspace roots. For monorepos you can set `swift.path` and `swift.sourcekit-lsp.serverArguments` in VS Code settings if needed.

---

## Cursor

Cursor has built-in LSP support. Point it at the `sourcekit-lsp` binary via **Settings → Languages → Swift**:

```jsonc
// .cursor/settings.json  (or global settings)
{
  "swift.path": "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin",
  "swift.sourcekit-lsp.serverPath": "sourcekit-lsp",
  "swift.sourcekit-lsp.serverArguments": [
    "--scratch-path", ".build/sourcekit-lsp"
  ]
}
```

---

## SourceKit-LSP Configuration File (`.sourcekit-lsp/config.json`)

For advanced tuning, SourceKit-LSP also reads its own config file from the workspace root. This is separate from the Claude Code `.lsp.json` and applies to all editors.

```jsonc
// iOS/hatch-sleep-app/.sourcekit-lsp/config.json
{
  "backgroundIndexing": true,          // Experimental: index without building first
  "swiftPM": {
    "configuration": "debug"
  },
  "logging": {
    "level": "default"                 // "debug" | "info" | "default" | "error"
  }
}
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Cross-module imports unresolved | `workspaceFolder` not set or wrong | Set `workspaceFolder: "iOS/hatch-sleep-app"` in `.lsp.json` |
| `sourcekit-lsp: not found` | Not in `$PATH` | Use `xcrun --find sourcekit-lsp` to get the full path and set `command` to that |
| Slow startup / index building | First-run index build | Wait for `Indexing` status bar indicator to complete; subsequent starts are fast |
| Server crashes frequently | Indexing large codebase | Increase `maxRestarts`, add `--scratch-path` to isolate cache, or enable `backgroundIndexing` |
| Hover / completion shows nothing | Workspace not yet indexed | Build the project once (`xcodebuild`) to populate the index |

---

## References

- [GitHub: swiftlang/sourcekit-lsp](https://github.com/swiftlang/sourcekit-lsp)
- [sourcekit-lsp: Configuration File](https://github.com/swiftlang/sourcekit-lsp/blob/main/Documentation/Configuration%20File.md)
- [sourcekit-lsp: Editor Integration](https://github.com/swiftlang/sourcekit-lsp/blob/main/Documentation/Editor%20Integration.md)
- [Claude Code: LSP Plugin Docs](https://docs.anthropic.com/en/docs/claude-code/lsp)
- [VS Code: Swift Extension (sswg.swift-lang)](https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang)
- [Language Server Protocol Specification](https://microsoft.github.io/language-server-protocol/)
- [PR #1491: Configure SourceKit-LSP for Claude Code](https://github.com/hatch-baby/mobile/pull/1491)
