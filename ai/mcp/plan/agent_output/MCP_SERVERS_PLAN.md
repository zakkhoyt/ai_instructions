
# MCP Servers Documentation Plan

## Context

The goal is to build a comprehensive, well-structured set of documentation about MCP (Model Context Protocol) servers useful for iOS development at Hatch. The output serves as AI references for engineers, with consistent formatting, real configs, and links to official docs.

Sources mined:
- `$HOME/Documents/notes/ai/mcp/**/*.md` — existing cheatsheets per server
- `$HOME/Library/Application Support/Code/User/mcp.json` — live VSCode user config
- `/conductor/workspaces/.ai/san-francisco/vscode/**/*.json` — template config files
- Slack thread summary — servers recommended by iOS team
- `@claude` Slack bot response — confirmed Claude.ai-connected servers

---

## Servers Identified

| Server Name           | Source                                    | Transport | Auth                  |
| --------------------- | ----------------------------------------- | --------- | --------------------- |
| XcodeBuildMCP         | npm `xcodebuildmcp@latest`                | stdio     | None                  |
| GitHub MCP Server     | `api.githubcopilot.com/mcp/`              | HTTP      | OAuth / GH PAT        |
| Atlassian (official)  | `mcp.atlassian.com/v1/mcp`               | HTTP      | Basic Auth (API token)|
| mcp-atlassian (3p)    | Docker `ghcr.io/sooperset/...`            | stdio     | API token (1 yr)      |
| Bugsee MCP            | `api.bugsee.com/mcp/{token}`              | HTTP      | Token-in-URL          |
| Apple Docs MCP        | npm `@kimsungwhee/apple-docs-mcp`         | stdio     | None                  |
| Figma MCP             | `mcp.figma.com/mcp`                       | HTTP      | Personal Access Token |
| Slack MCP (korotovsky)| npm `slack-mcp-server@latest`             | stdio     | XOXP token            |
| Intercom MCP          | `mcp.intercom.com/mcp`                    | HTTP      | OAuth                 |
| Gmail MCP             | `gmail.mcp.claude.com/mcp`               | HTTP      | Anthropic-managed     |
| Google Calendar MCP   | `gcal.mcp.claude.com/mcp`                | HTTP      | Anthropic-managed     |
| Granola MCP           | `mcp.granola.ai/mcp`                      | HTTP      | OAuth                 |
| Statsig MCP           | TBD                                       | TBD       | TBD                   |

---

## Output Files

### Phase 1 — Mining
- [x] `ai/mcp/plan/agent_output/MCP_SERVERS_PLAN.md` — This plan (tracking checkboxes)
- [x] `ai/mcp/plan/agent_output/MCP_SERVERS_MINING.md` — Raw mining results, one section per server

### Phase 2 — Individual Server Docs

Under `ai/mcp/servers/`:

- [x] `XCODEBUILDMCP.md`
- [x] `GITHUB_MCP.md`
- [x] `ATLASSIAN_MCP.md` (official, API token / Basic Auth)
- [x] `MCP_ATLASSIAN.md` (3rd-party, sooperset Docker / uvx)
- [x] `BUGSEE_MCP.md`
- [x] `APPLE_DOCS_MCP.md`
- [x] `SLACK_MCP.md`
- [x] `FIGMA_MCP.md` (stub — needs full setup sections)
- [x] `INTERCOM_MCP.md` (stub)
- [x] `GMAIL_MCP.md` (stub)
- [x] `GOOGLE_CALENDAR_MCP.md` (stub)
- [x] `GRANOLA_MCP.md` (stub)
- [x] `STATSIG_MCP.md` (stub — MCP availability unconfirmed)
- [x] `APP_STORE_CONNECT_MCP.md` (full doc — added after scrape round 2)

### Phase 3 — Overview

- [x] `ai/mcp/MCP_SERVERS_HATCH.md` — Summary table + quick-start per server

### Phase 4 — Config Templates

#### `ai/mcp/configs/templates/` (no auth values, placeholder comments)
- [x] `vscode_user_mcp.json`
- [x] `vscode_workspace_mcp.json`
- [x] `claude_desktop_config.json`
- [x] `claude_code_mcp.json` (`.mcp.json` for project scope)
- [x] `cursor_mcp.json`

#### `ai/mcp/configs/env_vars/` (tokens via environment variables + sample .env)
- [x] `vscode_user_mcp.json`
- [x] `vscode_workspace_mcp.json`
- [x] `claude_desktop_config.json`
- [x] `.env.example`
- [ ] `claude_code_mcp.json` — **missing; needs per-platform env var research**
- [ ] `cursor_mcp.json` — **missing; needs per-platform env var research**
- [ ] `zsh/mcp.env` — **new: shell export file for zsh env var injection**
- [ ] `zsh/vscode_user_mcp.json` — **new: VSCode variant that relies on zsh-sourced vars**
- [ ] `zsh/claude_desktop_config.json` — **new: Claude Desktop variant via zsh**
- [ ] `zsh/claude_code_mcp.json` — **new: Claude Code variant via zsh**
- [ ] `zsh/cursor_mcp.json` — **new: Cursor variant via zsh**

#### `ai/mcp/configs/templates/.gitignored/zakkhoyt/` (personal use — real tokens — gitignored)
- [ ] `claude_code_mcp.json`
- [ ] `claude_desktop_config.json`
- [ ] `cursor_mcp.json`
- [ ] `vscode_user_mcp.json`
- [ ] `vscode_workspace_mcp.json`

#### `ai/mcp/configs/env_vars/.gitignored/zakkhoyt/` (personal use — real tokens — gitignored)
- [ ] `.env` — populated from `.env.example`
- [ ] `vscode_user_mcp.json`
- [ ] `vscode_workspace_mcp.json`
- [ ] `claude_desktop_config.json`

#### `ai/mcp/configs/tokens/` (actual tokens populated — gitignored)
- [ ] `vscode_user_mcp.json` — **user to populate**
- [ ] `vscode_workspace_mcp.json` — **user to populate**
- [ ] `claude_desktop_config.json` — **user to populate**
- [ ] `.env` — **user to populate from `.env.example`**

### Phase 0 — Config File Locations Table

- [x] `ai/mcp/MCP_SERVERS.md` — full permutation of AI platform × interface × scope (official docs only)

---

## Per-Server Doc Format

Each `ai/mcp/servers/*.md` file follows this structure:

```
# {Server Name}

> One-line description

## Overview
- Homepage / repo link
- What it does, why useful for Hatch iOS dev
- Key tools/capabilities

## Authentication
- Preferred: long-lived API token (document first)
- OAuth: secondary/fallback with expiry note

## Environment Variables
| Variable | Description | Required |

## Setup
### VSCode (User scope)
### VSCode (Workspace scope)
### Claude Code (User scope)
### Claude Code (Project scope)
### Claude Desktop
### Cursor

## Common Prompts / Usage Examples

## References
```

**Auth bias rule**: API token / long-lived auth **first**; OAuth as secondary with expiry note.

---

## Config File Comment Format

Every server entry in all generated config files under `ai/mcp/configs/` must include a
comment block immediately above the server JSON key. The format is:

```jsonc
// # About
// <server-id> - <one-line description>
//
// # References
// * [<Homepage label>](<homepage url>)
// * [<Auth/token page label>](<auth url>)              ← include if auth is required
// * [<Env vars / configuration page label>](<url>)     ← include if env vars are documented
//
// # Installation
// <prose> or None required.
//
// ```zsh
// <install commands if a local tool install is needed>
// ```
//
// # Authorization
// 1) <Step one title>
//   * <detail>
//   * <detail>
// 2) <Step two title>
//   * <detail>
```

### Rules for each section

- **`# About`**: one line — `<server-id> - <description>`. Match the exact key used in the JSON.
- **`# References`**: 2–4 bullets maximum. Required bullets:
  - Homepage / repo
  - Auth/token management page (omit if no auth)
  - Env vars / configuration page (omit if none exists)
- **`# Installation`**: write `None required.` for remote HTTP servers or auto-installed npm packages.
  Include a `zsh` code fence for any tool that requires a manual local install (e.g. `brew install`, `git clone`, `npm run build`).
- **`# Authorization`**: numbered steps with nested bullets. If no auth, write `None required.`
- **All URLs** must use markdown link syntax: `[Link Text](https://url)`. No bare URLs.
- **All comments** use `//` JSONC line comment syntax. Each line is prefixed with `// `.

### Comment format applies to ALL platform examples in server docs

Every config example in `ai/mcp/servers/*.md` — regardless of platform (VSCode, Claude Code,
Claude Desktop, Cursor) — must include its own comment block. If a server doc has multiple
examples for the same platform (e.g. API token vs OAuth), each example gets its own tailored
comment block with auth steps specific to that variant. This rule was established 2026-03-23
and applies to all current and future server docs.

### Inline comments inside JSON bodies

Within a server's JSON body (inside `"env": {}`, `"args": []`, etc.), inline comments are
permitted only for the following purposes:

| Purpose | Convention | Example |
| ------- | ---------- | ------- |
| Optional env vars | `// Optional:` label + commented-out key/value | `// "WEBHOOK_PORT": "3000"` |
| Common configuration variants | Brief label + commented-out key/value | `// For HatchSleep: "XCODEBUILDMCP_ENABLED_WORKFLOWS": "..."` |
| Env var substitution hint (templates/ tier) | One-line note pointing to `env_vars/` tier | `// To use env var substitution instead (see env_vars/ tier):` |

Do **not** include commented-out disabled alternate server blocks inside the JSON body of
config templates. Those belong only in the live personal config (e.g. `~/Library/.../mcp.json`).

### Canonical reference file

`ai/mcp/configs/templates/.gitignored/configs/vscode/user/mcp.json` is the annotated
VSCode User config that serves as the canonical example of this format. When regenerating
any config file under `ai/mcp/configs/`, use this file as the comment style reference
and cross-check all server entries against it.

---

## Remaining Work

| Item                                            | Priority | Notes                                                                                                              |
| ----------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------ |
| `env_vars/` coverage gap                        | High     | Add `claude_code_mcp.json` and `cursor_mcp.json`; research per-platform env var injection approach                |
| `env_vars/zsh/` subdir                          | High     | Create shell-export `.env` + per-platform config variants for zsh-sourced env vars                                |
| Per-platform env var approach research          | High     | Document how each platform (VSCode, Claude Code, Claude Desktop, Cursor) loads env vars from shell vs `.env` file |
| Personal variants (templates `.gitignored/zakkhoyt/`)  | High     | Create real-token copies of all 5 template configs under gitignored dir                                           |
| Personal variants (env_vars `.gitignored/zakkhoyt/`)   | High     | Create real-token `.env` + config files under gitignored dir                                                      |
| Sensitive data audit                            | High     | Verify no real tokens/keys/hashes committed anywhere in `ai/mcp/**` outside `.gitignored/`                        |
| `FIGMA_MCP.md` full doc                         | Medium   | Stub only — needs full setup sections and auth details                                                             |
| `INTERCOM_MCP.md` full doc                      | Low      | Stub — OAuth only, limited dev workflow utility                                                                    |
| `GMAIL_MCP.md` full doc                         | Low      | Stub — Anthropic-managed OAuth                                                                                     |
| `GOOGLE_CALENDAR_MCP.md` full doc               | Low      | Stub — Anthropic-managed OAuth                                                                                     |
| `GRANOLA_MCP.md` full doc                       | Low      | Stub — OAuth, pending official docs                                                                                |
| `STATSIG_MCP.md` full doc                       | Low      | Stub — MCP availability unconfirmed as of March 2026                                                               |
| Populate `configs/tokens/`                      | User     | Templates exist; user must fill in real tokens                                                                     |

---

## Key Source Files

| File | Purpose |
| ---- | ------- |
| `$HOME/Documents/notes/ai/mcp/servers/XCODEBUILDMCP_CHEATSHEET.md` | Source for XcodeBuildMCP |
| `$HOME/Documents/notes/ai/mcp/servers/BUGSEE_MCP_CHEATSHEET.md`    | Source for Bugsee |
| `$HOME/Documents/notes/ai/mcp/servers/MCP_ATLASSIAN_CHEATSHEET.md` | Source for mcp-atlassian (3p) |
| `$HOME/Documents/notes/ai/mcp/servers/APPLE_DOCS_MCP_CHEATSHEET.md`| Source for Apple Docs MCP |
| `$HOME/Documents/notes/ai/mcp/servers/ALASSIAN_MCP_CHEATSHEET.md`  | Source for official Atlassian |
| `$HOME/Documents/notes/ai/mcp/servers/SLACK_MPC_CHEATSHEET.md`     | Source for Slack MCP |
| `$HOME/Library/Application Support/Code/User/mcp.json`             | Live VSCode user config |