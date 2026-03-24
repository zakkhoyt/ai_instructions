
# MCP Servers — Follow-up Work Tracker

Tracks outstanding topics and decisions established after the initial MCP server documentation
pass. See `agent_output/MCP_SERVERS_PLAN.md` for the master plan and checklist.

---

## Spec: Comment Format Applies to All Platform Examples (2026-03-23)

Every config code block in `ai/mcp/servers/*.md` must include a `# About / # References /
# Installation / # Authorization` comment block — not just the VSCode section. This applies to
every platform example (Claude Code, Claude Desktop, Cursor, VSCode User, VSCode Workspace) and
to every auth variant (API token vs OAuth when both are shown).

**Rule:** If two examples exist for the same platform with different auth, each gets its own
tailored comment block whose `# Authorization` steps match that specific variant.

---

## Outstanding: Env Vars Coverage Gap

`ai/mcp/configs/env_vars/` currently only contains 3 files (`vscode_user_mcp.json`,
`vscode_workspace_mcp.json`, `claude_desktop_config.json`) while `ai/mcp/configs/templates/`
has 5. Missing: `claude_code_mcp.json` and `cursor_mcp.json`.

### Required research before generating

For each AI platform, document:
1. **Native env var support** — does the platform natively read from a `.env` file, system env,
   or requires explicit `"env": {}` keys in the config?
2. **Shell inheritance** — if launched from a zsh terminal that sources `~/.zshrc`, do env vars
   flow through? (Answer is yes for most stdio-based tools.)
3. **Platform-specific approach** — document the canonical way to supply secrets to each platform.

### New `env_vars/zsh/` subdir

Create a `zsh/` subdirectory under `env_vars/` for shell-based env var injection:

```
ai/mcp/configs/env_vars/zsh/
├── mcp.env                    # Shell export file — source in ~/.zshrc
├── vscode_user_mcp.json       # VSCode config relying on zsh-sourced vars
├── vscode_workspace_mcp.json
├── claude_desktop_config.json
├── claude_code_mcp.json
└── cursor_mcp.json
```

The `mcp.env` file uses `export VAR=value` syntax (not `VAR=value` like `.env.example`).
Configs in this dir reference `${ENV_VAR}` substitution without any `.env` file loading —
they assume the vars are already in the shell environment.

---

## Outstanding: Sensitive Data Policy (2026-03-23)

### Rule

No real tokens, keys, hashes, or org-specific identifiers may appear in any committed file
under `ai/mcp/**` — **except** files inside a `.gitignored/` directory or files covered by
`.gitignore`.

Applies to:
- `ai/mcp/configs/templates/*.json`
- `ai/mcp/configs/env_vars/*.json`
- `ai/mcp/configs/env_vars/.env.example`
- `ai/mcp/servers/*.md`
- `ai/mcp/plan/**/*.md`

### Personal variants with real tokens

Create two gitignored directories for personal (populated) config copies:

**`ai/mcp/configs/templates/.gitignored/zakkhoyt/`**
```
claude_code_mcp.json
claude_desktop_config.json
cursor_mcp.json
vscode_user_mcp.json
vscode_workspace_mcp.json
```

**`ai/mcp/configs/env_vars/.gitignored/zakkhoyt/`**
```
.env                           # Real tokens (copied + filled from .env.example)
vscode_user_mcp.json
vscode_workspace_mcp.json
claude_desktop_config.json
```

These files contain `<YOUR_...>` placeholders replaced with actual values. They are excluded
from git via `.gitignore` patterns covering `**/.gitignored/**`.

---

## Follow-up: Docs Sync Back to Notes (low priority)

Once docs under `ai/mcp/servers/` are stable, evaluate syncing back to
`~/Documents/notes/ai/mcp/` (reverse direction). Discuss before executing — the notes directory
is a personal scratchpad and the sync direction/strategy needs agreement.

---

## Follow-up: Testing MCP Configs (low priority)

Copy config files to a small test repo and iterate through each server with live commands to
verify they work. Update each `ai/mcp/servers/*.md` with a `## Testing` section including
which commands were tried and results.

---

## Follow-up: Stub Docs Needing Full Content

| File                    | Status          | Notes                                      |
| ----------------------- | --------------- | ------------------------------------------ |
| `FIGMA_MCP.md`          | Stub (medium)   | Needs full setup + auth sections           |
| `INTERCOM_MCP.md`       | Stub (low)      | OAuth only                                 |
| `GMAIL_MCP.md`          | Stub (low)      | Anthropic-managed OAuth                    |
| `GOOGLE_CALENDAR_MCP.md`| Stub (low)      | Anthropic-managed OAuth                    |
| `GRANOLA_MCP.md`        | Stub (low)      | OAuth, pending official docs               |
| `STATSIG_MCP.md`        | Stub (low)      | MCP availability unconfirmed March 2026    |
