# OpenAI Codex CLI — Custom Instructions Cheatsheet

## Official Documentation

- [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [openai/codex — docs/agents_md.md](https://github.com/openai/codex/blob/main/docs/agents_md.md)
- [openai/agents.md spec](https://github.com/openai/agents.md)
- [CLI reference](https://developers.openai.com/codex/cli/reference)

## File Types and Paths

| File                     | Path                           | Format          | Scope                              |
| ------------------------ | ------------------------------ | --------------- | ---------------------------------- |
| Global instructions      | `~/.codex/AGENTS.md`           | Plain markdown  | All projects                       |
| Global override          | `~/.codex/AGENTS.override.md`  | Plain markdown  | All projects (highest priority)    |
| Project instructions     | `<git-root>/AGENTS.md`         | Plain markdown  | Entire repo                        |
| Subdirectory instructions | `<subdir>/AGENTS.md`          | Plain markdown  | That dir and descendants           |
| Subdirectory override    | `<subdir>/AGENTS.override.md`  | Plain markdown  | That dir (higher priority)         |
| User rules               | `~/.codex/rules/default.rules` | Starlark        | Sandbox execution permissions (all projects) |
| Project rules            | `./codex/rules/*.rules`        | Starlark        | Sandbox execution permissions (this project) |

## Format

Plain Markdown — **no frontmatter**. Any heading structure is valid. Content is injected as user-role messages prefixed with:

```
# AGENTS.md instructions for <directory>
```

## Discovery Hierarchy

1. `~/.codex/AGENTS.override.md` (global, highest)
2. `~/.codex/AGENTS.md` (global)
3. `<git-root>/AGENTS.md` → walk down to CWD, loading each directory's file
4. `AGENTS.override.md` beats `AGENTS.md` at the same level
5. Deeper (closer to CWD) files take precedence for conflicting instructions

## Rules Files (Sandbox Execution Permissions)

- [Rules](https://developers.openai.com/codex/rules)
  - Controls which external commands Codex is allowed to execute in the sandbox
  - **Distinct from `AGENTS.md`** — rules = execution permissions; AGENTS.md = agent instructions

### File Format & Location

| File                          | Path                          | Format    | Scope                          |
| ----------------------------- | ----------------------------- | --------- | ------------------------------ |
| User default rules            | `~/.codex/rules/default.rules` | Starlark  | All projects on this machine   |
| Team/project rules            | `./codex/rules/*.rules`        | Starlark  | Project-level; scanned at startup |

Starlark is a Python-like language designed for safe, sandboxed execution (no side effects).

### `prefix_rule()` Syntax

```python
prefix_rule(
    pattern=["gh", "pr", ["view", "list"]],  # required; list of args to match; inner list = alternatives
    decision="allow",                          # "allow" | "prompt" | "forbidden" (default: "allow")
    justification="Read-only GitHub PR ops",   # optional; human-readable explanation
    match=["gh pr view 123"],                  # optional; example commands that should match
    not_match=["gh pr merge 123"],             # optional; example commands that should NOT match
)
```

### Testing Rules

```zsh
codex execpolicy check --rules ~/.codex/rules/default.rules -- gh pr view 123
```

## Configuration (`~/.codex/config.toml`)

```toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
project_doc_max_bytes = 65536    # default: 32 KiB
```

## AGENTS.md as a Universal Open Standard

`AGENTS.md` is **not Codex-specific** — it is an open standard stewarded by the **Agentic AI Foundation** (Linux Foundation) and natively read by 15+ AI tools without any configuration.

- [agents.md — Official Spec Site](https://agents.md/)
- [Linux Foundation / Agentic AI Foundation](https://agenticaifoundation.org/)

### Tools with Native AGENTS.md Support

| Tool              | Support                                                                |
| ----------------- | ---------------------------------------------------------------------- |
| OpenAI Codex CLI  | Native (originator of the format)                                      |
| GitHub Copilot    | Native via `chat.useAgentsMdFile: true` (default on in VS Code)        |
| Claude Code       | Native (reads from project root and parent dirs automatically)         |
| Cursor            | Native (co-founded the open standard)                                  |
| Windsurf          | Native (root = `always_on`; subdir = auto-glob for that dir)           |
| Google Gemini CLI | Native                                                                 |
| Google Jules      | Reads `AGENTS.md` at repo root                                         |
| Amp               | Native                                                                 |
| Factory           | Native                                                                 |
| CodeRabbit        | Auto-detected as coding guidelines (`**/AGENTS.md`, `**/AGENT.md`)     |

### Why This Matters

A single `AGENTS.md` at the repo root is the closest thing to a **universal AI instruction file** — readable by all major tools with zero per-tool configuration. For cross-tool repositories, placing shared instructions in `AGENTS.md` is more portable than any tool-specific format.

## Notes

- No frontmatter — plain markdown only
- Scoping is **directory-based**, not glob-based
- Combined size cap: 32 KiB (configurable via `project_doc_max_bytes`)
- Explicit CLI/system prompts override any `AGENTS.md` content
