# MCP Servers

> Reference documentation, config templates, and personal configs for MCP (Model Context Protocol) servers used in Hatch iOS development.

---

## Directory Map

```
├── README.md                          ← You are here
├── mcp-config-paths.md                ← Config file location table (all platforms × scopes)
├── ios-mcp-servers.md                 ← Summary table + quick-start for Hatch team
│
├── servers/                           ← Per-server documentation
│   ├── ios-xcodebuild-mcp.md          - Xcode on the command line
│   ├── ios-app-store-connect-mcp.md   - 3rd-party interface for AppStoreConnect and Apple Developer Portal
│   ├── ios-apple-docs-mcp.md          - Retrieve Apple Documentation, WWDC articles, videos, etc...
│   ├── ios-sourcekit-lsp.md           - SourceKit-LSP for Swift code intelligence (LSP, not MCP)
│   ├── atlassian-mcp.md               - Official Atlassian Rovo MCP
│   ├── mcp-atlassian.md               - 3rd-party sooperset mcp-atlassian
│   ├── bugsee-mcp.md                  - Create, Fetch, Comment on, etc.... Bugsee reports
│   ├── github-mcp.md                  - GitHub MCP server
│   ├── slack-mcp.md                   - MCP server to access Slack user posts, public posts, create posts, canvases, search, etc...
│   ├── figma-mcp.md                   - stub
│   ├── google-workspace.md            - Google Docs, Drive, Gmail, Calendar, Sheets, and more
│   ├── intercom-mcp.md                - stub
│   ├── gmail-mcp.md                   - stub
│   ├── google-calendar-mcp.md         - stub
│   ├── granola-mcp.md                 - stub
│   └── statsig-mcp.md                 - stub
│
└── configs/                           ← Platform config files (3 tiers)
    │
    ├── templates/                     ← Template root
    │   ├── claude_code_lsp.json       ← LSP template for SourceKit-LSP (copy to .claude/.lsp.json)
    │   │
    │   ├── hard_coded_tokens/         ← Tier 1: Placeholder values — safe to commit
    │   │   ├── vscode_user_mcp.json
    │   │   ├── vscode_workspace_mcp.json
    │   │   ├── claude_desktop_config.json
    │   │   ├── claude_code_mcp.json
    │   │   ├── cursor_mcp.json
    │   │   └── .gitignored/           ← Personal copies (gitignored)
    │   │       └── zakkhoyt/
    │   │           ├── vscode_user_mcp.json
    │   │           ├── vscode_workspace_mcp.json
    │   │           ├── claude_desktop_config.json
    │   │           ├── claude_code_mcp.json
    │   │           └── cursor_mcp.json
    │   │
    │   └── env_var_tokens/            ← Tier 2: Env var syntax — safe to commit
    │       ├── .env.example           ← All required variable names (no values)
    │       ├── vscode_user_mcp.json   ← Uses ${VAR} syntax
    │       ├── vscode_workspace_mcp.json
    │       ├── claude_desktop_config.json
    │       ├── claude_code_mcp.json
    │       ├── cursor_mcp.json
    │       └── zsh/                   ← zsh-sourced variants
    │           ├── mcp.env            ← Shell export file; source in ~/.zshrc
    │           ├── vscode_user_mcp.json
    │           ├── vscode_workspace_mcp.json
    │           ├── claude_desktop_config.json
    │           ├── claude_code_mcp.json
    │           └── cursor_mcp.json
    │
    └── tokens/                        ← Tier 3: Real tokens — gitignored
```

---

## Config Tiers Explained

There are three tiers of config files, each suited to different use cases:

| Tier          | Directory                              | What's in it                                                              | Commit to git? |
| ------------- | -------------------------------------- | ------------------------------------------------------------------------- | -------------- |
| **Templates** | `configs/templates/hard_coded_tokens/` | Placeholder comments where tokens go — no real values                     | ✅ Yes         |
| **Env vars**  | `configs/templates/env_var_tokens/`    | Platform-specific env var syntax (`${VAR}`, `${env:VAR}`) — no real values | ✅ Yes       |
| **Tokens**    | `configs/tokens/` and `**/.gitignored/**` | Real tokens and credentials — personal use only                        | ❌ No (gitignored) |

### Per-Platform Env Var Syntax

Each AI platform has its own syntax for referencing environment variables:

| Platform       | Syntax in `"env":{}` | Syntax in arg strings | Notes                                                                 |
| -------------- | -------------------- | --------------------- | --------------------------------------------------------------------- |
| VSCode         | `${VAR}`             | `${VAR}`              | Inherited from shell that launched VSCode                             |
| Claude Desktop | `${VAR}`             | `${VAR}`              | Must launch from terminal; Dock launch won't inherit `~/.zshrc`       |
| Claude Code    | `${VAR}`             | `${VAR}`              | Full shell inheritance via `/bin/zsh -lc` wrapper                     |
| Cursor         | `${env:VAR}`         | `${env:VAR}`          | Uses Cursor-specific interpolation syntax                             |

---

## Personal Configs (`.gitignored/zakkhoyt/`)

Personal configs under `**/.gitignored/zakkhoyt/` are excluded from git and contain real credentials. Two variants exist under `configs/templates/env_var_tokens/.gitignored/zakkhoyt/`:

- **`configs/`** — Real tokens hardcoded inline. Copy directly to the platform's config location and use immediately. No env vars or `.env` file required.
- **`env_var_configs/`** — Platform-specific env var syntax, paired with a populated `.env` file. Source the `.env` before launching the AI tool (or add to `~/.zshrc`).

### Regenerating Personal Configs

When regenerating the personal configs under `.gitignored/zakkhoyt/`, produce **both** subdirs:

**`configs/` (hardcoded tokens)**
Replace all `${VAR}` references with literal values from `.env`. Use absolute paths (e.g., `/Users/zakkhoyt/...` not `$HOME/...`). For platforms that need a shell wrapper (`/bin/zsh -lc`), keep those wrappers.

**`env_var_configs/` (env var syntax + populated `.env`)**
Keep the platform-specific env var syntax verbatim from the `env_var_tokens/` tier source files. Add a personal header comment pointing to the `.env` in the same directory. The `.env` is populated with all real values (not `<FILL_IN>` placeholders).

Source values for regeneration:
- Atlassian token + Basic Auth hash: from `.env`
- Bugsee token UUID: `30aa2b68-0d4f-497a-ad68-454267b46e44`
- GitHub PAT: from `.env`
- Slack XOXP token: from `.env`
- App Store Connect: Issuer ID, Key ID, `.p8` path from `.env`; `APP_APPLE_ID` = `<FILL_IN>` (not yet known)

---

## Server Documentation

See [`servers/`](servers/) for per-server docs. Each covers:

- Overview and key capabilities
- Authentication setup (long-lived API token preferred over OAuth)
- Environment variables table
- Per-platform config snippets (VSCode, Claude Code, Claude Desktop, Cursor)
- Usage examples
- References

See [`ios-mcp-servers.md`](ios-mcp-servers.md) for a summary table of all servers with quick-start notes.

See [`mcp-config-paths.md`](mcp-config-paths.md) for the complete config file location table (all platforms × interfaces × scopes, cited from official docs).

---

## References

- [MCP Specification](https://modelcontextprotocol.io/)
- [Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [VSCode MCP docs](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Cursor MCP docs](https://docs.cursor.com/context/model-context-protocol)
- [Claude Desktop MCP quickstart](https://modelcontextprotocol.io/docs/quickstart/user)
