
# MCP Servers Mining

> Raw mining results — one section per server. This is the source-of-record for facts gathered before writing individual server docs.

---

## XcodeBuildMCP

**Source**: `$HOME/Documents/notes/ai/mcp/servers/XCODEBUILDMCP_CHEATSHEET.md`

- **npm package**: `xcodebuildmcp@latest` (published by Sentry)
- **GitHub**: `github.com/getsentry/XcodeBuildMCP`
- **Transport**: stdio
- **Auth**: None — invokes local Apple toolchain binaries (`xcodebuild`, `simctl`, `devicectl`)
- **Tool count**: 61+
- **Workflow categories** (12): `swift-package`, `simulator`, `device`, `macos`, `ui-testing`, `project-discovery`, `xcodebuild`, `scaffolding`, `log-capture`, `app-management`, `simulator-config`, `video-recording`
- **Key env vars**: `XCODEBUILDMCP_DYNAMIC_TOOLS`, `INCREMENTAL_BUILDS_ENABLED`, `XCODEBUILDMCP_ENABLED_WORKFLOWS`, `XCODEBUILDMCP_SENTRY_DISABLED`, `NODE_ENV`, `DEBUG`
- **Recommended workflow set (Hatch iOS)**: `project-discovery,swift-package,simulator,device,macos,doctor,ui-testing`
- **Live VSCode user config**: present in `$HOME/Library/Application Support/Code/User/mcp.json` with `INCREMENTAL_BUILDS_ENABLED: false`, `NODE_ENV: development`, `DEBUG: *`

---

## Apple Docs MCP

**Source**: `$HOME/Documents/notes/ai/mcp/servers/APPLE_DOCS_MCP_CHEATSHEET.md`

- **npm package**: `@kimsungwhee/apple-docs-mcp`
- **GitHub**: `github.com/kimsungwhee/apple-docs-mcp`
- **Transport**: stdio
- **Auth**: None
- **Tool count**: 15
- **WWDC data**: Bundled in package — 1,260+ sessions (2012–2025), 35 MB, offline capable, zero rate limits
- **Key tools**: `search_apple_docs`, `get_apple_doc_content`, `search_wwdc_videos`, `get_wwdc_video_details`, `get_platform_compatibility`
- **Optional env vars**: `USER_AGENT_ROTATION_ENABLED`, `USER_AGENT_POOL_STRATEGY`, `USER_AGENT_MAX_RETRIES`
- **Live VSCode user config**: present in `$HOME/Library/Application Support/Code/User/mcp.json`

---

## Atlassian Rovo MCP (Official)

**Source**: `$HOME/Documents/notes/ai/mcp/servers/ALASSIAN_MCP_CHEATSHEET.md`

- **GitHub**: `github.com/atlassian/atlassian-mcp-server`
- **MCP URL**: `https://mcp.atlassian.com/v1/mcp` (API token — Basic Auth)
- **MCP URL (OAuth)**: `https://mcp.atlassian.com/v1/sse` (OAuth 2.1 — SSE transport, ~2-day expiry)
- **Transport**: HTTP (streamable) or SSE
- **Auth**: `Authorization: Basic base64(email:token)` using Atlassian API token
- **API token source**: `https://id.atlassian.com/manage-profile/security/api-tokens`
- **Auth update (March 2026)**: Page now states "OAuth 2.1 or API tokens" — API token support confirmed
- **Encoding**: `echo -n "email:token" | base64`
- **Hatch Jira URL**: `https://hatchbaby.atlassian.net`
- **Live VSCode user config**: Not present (not in live mcp.json; Atlassian MCP present via mcp-atlassian 3p server only)
- **References**: Atlassian Support docs, GitHub repo

---

## mcp-atlassian (sooperset, 3rd-party)

**Source**: `$HOME/Documents/notes/ai/mcp/servers/MCP_ATLASSIAN_CHEATSHEET.md`

- **GitHub**: `github.com/sooperset/mcp-atlassian`
- **Docker image**: `ghcr.io/sooperset/mcp-atlassian:latest`
- **Python (uvx)**: `uvx mcp-atlassian`
- **Transport**: stdio
- **Auth**: Direct Atlassian API token — `JIRA_URL`, `JIRA_USERNAME`, `JIRA_API_TOKEN` env vars
- **Token source**: `https://id.atlassian.com/manage-profile/security/api-tokens` — up to 1 year
- **Also supports**: `CONFLUENCE_URL`, `CONFLUENCE_USERNAME`, `CONFLUENCE_API_TOKEN`
- **Deployment patterns**:
  1. Docker with `--env-file` pointing to a gitignored `.env`
  2. Docker with a wrapper script that sources credentials from shell env
  3. `uvx mcp-atlassian` directly (no Docker needed)
- **Live VSCode user config**: **Present** — using wrapper script `$HOME/.hatch/scripts/mcp_atlassian_wrapper.zsh`
- **Wrapper script** (from cheatsheet): sources `$HOME/.hatch/config/.zsh_hatch_jira`, runs Docker container passing mapped env vars

---

## Bugsee MCP

**Source**: `$HOME/Documents/notes/ai/mcp/servers/BUGSEE_MCP_CHEATSHEET.md`

- **MCP URL**: `https://api.bugsee.com/mcp/{UUID_TOKEN}`
- **Transport**: HTTP
- **Auth**: Token-in-URL (UUID personal access token)
- **Token source**: `https://app.bugsee.com/#/settings/user/integrations`
- **Claude Desktop**: requires `npx mcp-remote https://api.bugsee.com/mcp/{TOKEN}` (Claude Desktop doesn't natively support HTTP MCP)
- **VSCode**: native HTTP support — `"type": "http"` with full URL
- **Live VSCode user config**: **Present** — `"type": "http"`, `"url": "https://api.bugsee.com/mcp/30aa2b68-0d4f-497a-ad68-454267b46e44"` (real token embedded in live config)
- **Example prompt**: `Please help me analyze Bugsee issue MYAPP-123`

---

## GitHub MCP Server

**Sources**: `$HOME/Documents/notes/ai/mcp/AI_MCP_COPILOT.md`, live VSCode `mcp.json`

- **Remote URL**: `https://api.githubcopilot.com/mcp/`
- **Local package**: `@modelcontextprotocol/server-github`
- **Transport**: HTTP (remote) or stdio (local npm)
- **Auth**:
  - GitHub Copilot extension in VSCode: OAuth managed via `gallery` field
  - All other tools: GitHub Personal Access Token (PAT) via env var
- **PAT source**: `https://github.com/settings/tokens` — classic or fine-grained, up to 1 year
- **Live VSCode user config**: **Present** (two entries: `github/github-mcp-server` and `io.github.github/github-mcp-server` both pointing to same URL, different gallery versions)
- **Live config note**: Both entries use `"type": "http"` with Copilot OAuth gallery metadata — no PAT in live config
- **Claude Code / Desktop / Cursor**: use `@modelcontextprotocol/server-github` with `GITHUB_PERSONAL_ACCESS_TOKEN`

---

## Slack MCP (korotovsky)

**Source**: `$HOME/Documents/notes/ai/mcp/servers/SLACK_MPC_CHEATSHEET.md`

- **GitHub**: `github.com/korotovsky/slack-mcp-server`
- **npm**: `slack-mcp-server@latest`
- **Transport**: stdio
- **Auth**: `SLACK_MCP_XOXP_TOKEN` — Slack XOXP user token (long-lived)
- **Token source**: Slack app OAuth settings page
- **Hatch app settings**: `https://app.slack.com/app-settings/T03TR3R94/A0AMLQF741Y/oauth`
- **Token format**: `xoxp-<...>`
- **Live VSCode user config**: **Present** — `SLACK_MCP_XOXP_TOKEN` hardcoded (real token in live config; should be moved to env var)
- **Note**: Official Slack also offers `mcp.slack.com/mcp` (HTTP, OAuth) — korotovsky is preferred because XOXP token is long-lived

---

## Figma MCP

**Sources**: Team Slack discussion, MCP servers list

- **MCP URL**: `https://mcp.figma.com/mcp`
- **Transport**: HTTP
- **Auth**: Personal Access Token (`X-Figma-Token` header)
- **Token source**: `https://www.figma.com/developers/api#access-tokens`
- **Status**: Details not fully mined — stub doc written

---

## Intercom MCP

**Sources**: MCP servers list, Claude.ai connected apps

- **MCP URL**: `https://mcp.intercom.com/mcp`
- **Transport**: HTTP
- **Auth**: OAuth (Intercom account) — no long-lived token confirmed
- **Status**: Stub doc written

---

## Gmail MCP

**Sources**: Claude.ai connected apps

- **MCP URL**: `https://gmail.mcp.claude.com/mcp`
- **Transport**: HTTP
- **Auth**: Anthropic-managed Google OAuth
- **Status**: Stub doc written — primarily useful via Claude Desktop Connectors

---

## Google Calendar MCP

**Sources**: Claude.ai connected apps

- **MCP URL**: `https://gcal.mcp.claude.com/mcp`
- **Transport**: HTTP
- **Auth**: Anthropic-managed Google OAuth
- **Status**: Stub doc written — primarily useful via Claude Desktop Connectors

---

## Granola MCP

**Sources**: MCP servers list, Claude.ai connected apps

- **MCP URL**: `https://mcp.granola.ai/mcp`
- **Transport**: HTTP
- **Auth**: OAuth (Granola account)
- **Status**: Stub doc written

---

## Statsig MCP

**Sources**: Hatch iOS team wishlist (mentioned by Lorraine)

- **Transport**: TBD
- **Auth**: TBD
- **Status**: Stub doc written — MCP availability unconfirmed as of March 2026
- **Homepage**: `https://statsig.com`
