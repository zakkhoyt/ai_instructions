# Claude Code — Custom Instructions Cheatsheet

## Official Documentation

- [Overview](https://code.claude.com/docs/en/overview)
- [How Claude Code works](https://code.claude.com/docs/en/how-claude-code-works)
- [Memory / CLAUDE.md](https://code.claude.com/docs/en/memory)
- [Skills and commands](https://code.claude.com/docs/en/skills)
- [Hooks reference](https://code.claude.com/docs/en/hooks)
- [Hooks guide](https://code.claude.com/docs/en/hooks-guide)
- [Settings](https://code.claude.com/docs/en/settings)
- [Built-in commands](https://code.claude.com/docs/en/commands)
- [Extensions overview](https://code.claude.com/docs/en/features-overview)
- [Subagents](https://code.claude.com/docs/en/sub-agents)
- [Permissions](https://code.claude.com/docs/en/permissions)
- [Plugins](https://code.claude.com/docs/en/plugins)
- [CLI reference](https://code.claude.com/docs/en/cli-reference)
- [Documentation index (llms.txt)](https://code.claude.com/docs/llms.txt)

## File Types and Paths

| File                      | Path                              | Format                          | Scope                          |
| ------------------------- | --------------------------------- | ------------------------------- | ------------------------------ |
| User instructions         | `~/.claude/CLAUDE.md`             | Markdown + `@imports`           | All projects                   |
| Project instructions      | `CLAUDE.md` or `.claude/CLAUDE.md` | Markdown + `@imports`          | This project                   |
| Managed policy (macOS)    | `/Library/Application Support/ClaudeCode/CLAUDE.md` | Markdown | All projects (highest priority) |
| Rules (unconditional)     | `.claude/rules/*.md`              | Plain markdown                  | Always loaded                  |
| Rules (path-scoped)       | `.claude/rules/*.md`              | Markdown + `paths:` frontmatter | Files matching `paths` globs   |
| User rules                | `~/.claude/rules/*.md`            | Markdown + `paths:` frontmatter | All projects                   |
| Skills                    | `.claude/skills/<name>/SKILL.md`  | Markdown + YAML frontmatter     | On-demand or auto              |
| Commands (legacy)         | `.claude/commands/<name>.md`      | Markdown + YAML frontmatter     | Slash commands                 |
| User commands             | `~/.claude/commands/<name>.md`    | Markdown + YAML frontmatter     | All projects                   |

## `CLAUDE.md` — `@import` Syntax

```markdown
@path/to/file            # relative to containing CLAUDE.md
@~/.ai/instructions/file # tilde expansion supported
@/absolute/path/file     # absolute paths supported
```

- Imports are recursive up to **5 hops**
- Target: **under 200 lines** per CLAUDE.md for best adherence

## `.claude/rules/*.md` Frontmatter (Path-Scoped)

```yaml
---
paths:
  - "src/api/**/*.ts"
  - "**/*.test.ts"
---
```

Rules **without** `paths:` frontmatter load unconditionally every session.

## `SKILL.md` Frontmatter

```yaml
---
name: my-skill                    # optional; defaults to dir name
description: "..."                # recommended; Claude uses this to decide when to invoke
argument-hint: "[arg]"            # optional; shown in autocomplete
disable-model-invocation: true    # optional; default false — prevents Claude auto-invoking
user-invocable: false             # optional; default true — hides from /menu
allowed-tools: "Read, Grep, Glob" # optional; tools allowed without approval
model: "..."                      # optional
context: fork                     # optional; "fork" = isolated subagent
agent: Explore                    # optional; subagent type when context: fork
---
```

## CLAUDE.md Hierarchy (Highest → Lowest)

1. Managed policy (`/Library/Application Support/ClaudeCode/CLAUDE.md`)
2. Project (`.claude/CLAUDE.md` or `./CLAUDE.md`)
3. User (`~/.claude/CLAUDE.md`)

## Notes

- `.claude/rules/` directory is the Claude Code equivalent of Copilot's `.github/instructions/`
- Skills supersede `.claude/commands/` — prefer skills for new work
- First 200 lines of auto-memory `MEMORY.md` load at session start
- `claudeMdExcludes` in `.claude/settings.local.json` can suppress specific files
- `paths:` is a YAML array of glob strings (not a comma-separated string)
- Symlinks in `.claude/rules/` are supported and resolved normally
- Unknown frontmatter keys: behavior not officially documented
