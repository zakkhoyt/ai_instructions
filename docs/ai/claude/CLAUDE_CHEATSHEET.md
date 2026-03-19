# Claude Code — AI Customization Cheatsheet

## Memory & Instructions Overview

- [How Claude Remembers Your Project](https://code.claude.com/docs/en/memory)

## CLAUDE.md Files

- [CLAUDE.md Reference](https://code.claude.com/docs/en/memory#claudemd-files)
  - Project: `./CLAUDE.md` or `./.claude/CLAUDE.md`
  - User-level: `~/.claude/CLAUDE.md`
  - Managed policy (macOS): `/Library/Application Support/ClaudeCode/CLAUDE.md`
  - Supports `@path/to/file` import syntax

## Rules (`.claude/rules/`)

- [Organize Rules with `.claude/rules/`](https://code.claude.com/docs/en/memory#organize-rules-with-clauderules)
  - Any `.md` file in `.claude/rules/` is auto-discovered recursively
  - File extension: `.md` (no special extension required)
  - Path-specific rules use `paths:` frontmatter (YAML array of globs)
  - User-level rules: `~/.claude/rules/`
  - Symlinks are supported and resolved normally

## Skills

- [Skills](https://code.claude.com/docs/en/skills)
  - Load on demand, not at session start
  - For task-specific instructions not needed in context all the time

## Settings

- [Settings](https://code.claude.com/docs/en/settings)

## Sub-agents

- [Sub-agents / Persistent Memory](https://code.claude.com/docs/en/sub-agents#enable-persistent-memory)

## Key Frontmatter Syntax (`.claude/rules/*.md`)

```yaml
---
paths:
  - "src/api/**/*.ts"
  - "src/**/*.{ts,tsx}"
  - "tests/**/*.test.ts"
---
```

> [!NOTE]
> `paths` is a YAML array of glob strings (not a comma-separated string).
> Rules without `paths` frontmatter load unconditionally for all files.
> Unknown frontmatter keys: behavior not officially documented.
