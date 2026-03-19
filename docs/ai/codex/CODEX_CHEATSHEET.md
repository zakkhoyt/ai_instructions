# OpenAI Codex — AI Customization Cheatsheet

## AGENTS.md Overview

- [Custom Instructions with AGENTS.md](https://developers.openai.com/codex/guides/agents-md)
- [AGENTS.md Spec (GitHub)](https://github.com/openai/codex/blob/main/docs/agents_md.md)
- [AGENTS.md Community Spec](https://agents.md/)
  - Open format stewarded by the **Agentic AI Foundation** (Linux Foundation)
  - Also adopted by: Amp, Jules (Google), Cursor, Factory

## File Format

- Pure markdown — **no YAML frontmatter**, no glob scoping syntax
- Scoping is **directory-based only** (proximity wins)
- Filename: `AGENTS.md` (standard), `AGENTS.override.md` (temporary override)

## File Discovery & Precedence

1. Global: `~/.codex/AGENTS.md` (or `AGENTS.override.md`)
2. Project: walks from git root → current working directory, one file per dir
3. Files concatenated root → cwd; later (closer) files override earlier guidance
4. Max combined size: 32 KiB (configurable via `project_doc_max_bytes`)

## Custom Fallback Filenames

```toml
# ~/.codex/config.toml
project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]
```

## Skills

- [Agent Skills](https://developers.openai.com/codex/skills)

## Advanced Configuration

- [Advanced Configuration](https://developers.openai.com/codex/config-advanced)

## Key Difference from Other Tools

> [!IMPORTANT]
> `AGENTS.md` has **no frontmatter and no glob scoping**. Scoping is purely by directory placement.
> A file named `src/AGENTS.md` applies to everything under `src/`.
> This format is intentionally simple and cross-tool compatible.
