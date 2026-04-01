
# MCP Config File Locations

> For every AI platform that supports MCP, this table lists the exact config file path for each interface and scope.

**Source policy**: Every path below is sourced from official documentation. Unverified paths are marked `[unverified]`. Do not add a row without citing the official doc URL.

---

## Config File Locations by Platform

| AI Platform    | Interface        | Scope     | Config File Path                                                                   | Root Key     | Notes                                                                          | Source                                                                               |
| -------------- | ---------------- | --------- | ---------------------------------------------------------------------------------- | ------------ | ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ |
| Claude Code    | CLI (`claude`)   | User      | `~/.claude.json`                                                                   | `mcpServers` | Edited via `claude mcp add --scope user` or directly                          | [Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp)          |
| Claude Code    | CLI (`claude`)   | Project   | `.mcp.json` (repo root)                                                            | `mcpServers` | Committed to the repo; shared with team                                        | [Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp)          |
| Claude Code    | CLI (`claude`)   | Local     | `.mcp.json.local` (repo root)                                                      | `mcpServers` | Gitignored personal overrides for the project scope                            | [Claude Code MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp)          |
| Claude Desktop | macOS app        | User      | `~/Library/Application Support/Claude/claude_desktop_config.json`                 | `mcpServers` | Edit via Settings → Developer → Edit Config                                    | [MCP Quickstart: User](https://modelcontextprotocol.io/docs/quickstart/user)        |
| VSCode Copilot | VSCode extension | User      | `~/Library/Application Support/Code/User/mcp.json`                                | `servers`    | Root key is `"servers"`, not `"mcpServers"` — differs from all other platforms | [VSCode MCP docs](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)      |
| VSCode Copilot | VSCode extension | Workspace | `.vscode/mcp.json` (repo root)                                                     | `servers`    | Root key is `"servers"`, not `"mcpServers"` — differs from all other platforms | [VSCode MCP docs](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)      |
| Cursor         | Cursor IDE       | User      | `~/.cursor/mcp.json`                                                               | `mcpServers` |                                                                                | [Cursor MCP docs](https://docs.cursor.com/context/model-context-protocol)           |
| Cursor         | Cursor IDE       | Project   | `.cursor/mcp.json` (repo root)                                                     | `mcpServers` |                                                                                | [Cursor MCP docs](https://docs.cursor.com/context/model-context-protocol)           |
| Windsurf       | Windsurf IDE     | User      | `~/.codeium/windsurf/mcp_config.json`                                              | `mcpServers` |                                                                                | [Windsurf MCP docs](https://docs.codeium.com/windsurf/mcp)                          |
| Windsurf       | Windsurf IDE     | Workspace | `.windsurf/mcp_config.json` (repo root) `[unverified]`                             | `mcpServers` | Path inferred from pattern — confirm against official Windsurf docs            | [Windsurf MCP docs](https://docs.codeium.com/windsurf/mcp)                          |

---

## Key Differences Between Platforms

| Aspect               | Claude Code                                                                                  | Claude Desktop                           | Cursor                                                                          | Windsurf                                 | VSCode Copilot                 |
| -------------------- | -------------------------------------------------------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------- | ------------------------------ |
| Root JSON key        | `"mcpServers"`                                                                               | `"mcpServers"`                           | `"mcpServers"`                                                                  | `"mcpServers"`                           | `"servers"`                    |
| stdio support        | Yes (default)                                                                                | Yes (default)                            | Yes (default)                                                                   | Yes (default)                            | `"type": "stdio"` field        |
| HTTP support         | Yes — `claude mcp add --transport http <url>` (recommended; SSE deprecated per 2026 docs)   | No — use `npx mcp-remote` proxy          | Yes — `{ "url": "http://server/sse" }` or Streamable HTTP via standard config  | No — use `npx mcp-remote` proxy          | `"type": "http"` field         |
| SSE support          | Deprecated (use HTTP instead)                                                                | No — use `npx mcp-remote` proxy          | Yes — `{ "url": "http://server/sse" }` via standard config                     | No — use `npx mcp-remote` proxy          | `"type": "sse"` field          |
| Comments in JSON     | Not supported (plain JSON)                                                                   | Not supported (plain JSON)               | Not supported (plain JSON)                                                      | Not supported (plain JSON)               | Supported (JSONC format)       |

---

## Platform Notes

### Claude Code

- **User scope** (`~/.claude.json`): applies to all projects for the logged-in user
- **Project scope** (`.mcp.json`): committed to repo root, shared with all teammates
- **Local scope** (`.mcp.json.local`): gitignored personal overrides for project scope config
- HTTP transport is natively supported (recommended): `claude mcp add --scope <user|project|local> --transport http <name> --url <url>`
- SSE is deprecated as of 2026 — use HTTP instead, or `npx mcp-remote` as a stdio proxy for legacy SSE servers
- stdio is the default for self-hosted servers: `claude mcp add --scope <user|project|local> --transport stdio <name> -- <command> [args]`

### Claude Desktop

- Single user-scope config file only — no workspace or project scope
- HTTP MCP not natively supported — use `npx mcp-remote <url>` as a stdio proxy
- Edit via: **Settings → Developer → Edit Config** or directly with a text editor
- Must be launched from a terminal session to inherit shell environment variables (e.g. `open /Applications/Claude.app` from terminal, not from Dock)

### VSCode Copilot

- **Critical difference**: root key is `"servers"`, not `"mcpServers"` — this differs from every other platform
- Supports HTTP (`"type": "http"`), SSE (`"type": "sse"`), and stdio (`"type": "stdio"`) natively
- User scope: applies across all workspaces for the logged-in user
- Workspace scope: `.vscode/mcp.json` in repo root — can be committed to share with team
- JSONC (JSON with Comments) is fully supported in all VSCode config files

### Cursor

- Both user (`~/.cursor/mcp.json`) and project (`.cursor/mcp.json`) scopes supported
- Uses `mcpServers` root key (same as Claude Code/Desktop)
- HTTP and SSE transports are natively supported via standard config: `{ "url": "http://server/sse" }` or Streamable HTTP
- For env var inheritance, use the `/bin/zsh -lc` wrapper pattern: `"command": "/bin/zsh", "args": ["-lc", "..."]`

### Windsurf (Codeium)

- User scope path: `~/.codeium/windsurf/mcp_config.json`
- Uses `mcpServers` root key
- Workspace-scope path not confirmed in official documentation — marked `[unverified]` in table above

---

## Config Templates

Ready-to-use config files for each platform are in `docs/mcp/configs/templates/`.

| Directory                               | Style                                          | Committed? |
| --------------------------------------- | ---------------------------------------------- | ---------- |
| `configs/templates/hard_coded_tokens/`  | Fill in literal token values directly in JSON  | Yes (no real tokens) |
| `configs/templates/env_var_tokens/`     | Reference `${ENV_VAR}` — define vars in shell  | Yes        |
| `configs/templates/env_var_tokens/zsh/` | Same as above, but with `mcp.env` for `~/.zshrc` sourcing | Yes |

Each directory contains one file per platform: `claude_code_mcp.json`, `claude_desktop_config.json`, `cursor_mcp.json`, `vscode_user_mcp.json`, `vscode_workspace_mcp.json`.

### LSP Config Template (Claude Code only)

`configs/templates/claude_code_lsp.json` — copy to `.claude/.lsp.json` in the repo root to enable [SourceKit-LSP](ios-mcp-servers.md#11-sourcekit-lsp--swift-code-intelligence-claude-code-only) Swift code intelligence in Claude Code. This is separate from the MCP config.

For full server details, see [ios-mcp-servers.md](ios-mcp-servers.md).


---

## References

- [Claude Code: MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp)
- [Claude Desktop / MCP Quickstart (User)](https://modelcontextprotocol.io/docs/quickstart/user)
- [VSCode: Use MCP servers in VS Code](https://code.visualstudio.com/docs/copilot/chat/mcp-servers)
- [Cursor: Model Context Protocol](https://docs.cursor.com/context/model-context-protocol)
- [Windsurf: MCP](https://docs.codeium.com/windsurf/mcp)
- [Model Context Protocol specification](https://modelcontextprotocol.io/)
