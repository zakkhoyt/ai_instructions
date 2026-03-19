# OpenAI Codex CLI — Custom Instructions Cheatsheet

## Official Documentation

- [Custom instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [openai/codex — docs/agents_md.md](https://github.com/openai/codex/blob/main/docs/agents_md.md)
- [openai/agents.md spec](https://github.com/openai/agents.md)
- [CLI reference](https://developers.openai.com/codex/cli/reference)

## File Types and Paths

| File | Path | Format | Scope |
| ---- | ---- | ------ | ----- |
| Global instructions | `~/.codex/AGENTS.md` | Plain markdown | All projects |
| Global override | `~/.codex/AGENTS.override.md` | Plain markdown | All projects (highest priority) |
| Project instructions | `<git-root>/AGENTS.md` | Plain markdown | Entire repo |
| Subdirectory instructions | `<subdir>/AGENTS.md` | Plain markdown | That dir and descendants |
| Subdirectory override | `<subdir>/AGENTS.override.md` | Plain markdown | That dir (higher priority) |

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

## Configuration (`~/.codex/config.toml`)

```toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
project_doc_max_bytes = 65536    # default: 32 KiB
```

## Notes

- No frontmatter — plain markdown only
- Scoping is **directory-based**, not glob-based
- Combined size cap: 32 KiB (configurable)
- Explicit CLI/system prompts override any `AGENTS.md` content
- Google Jules (web agent) also reads `AGENTS.md` at repo root
