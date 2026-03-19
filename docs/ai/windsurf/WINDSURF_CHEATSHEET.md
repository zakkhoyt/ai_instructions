# Windsurf (Codeium) — Custom Rules Cheatsheet

## Official Documentation

- [Welcome to Windsurf Docs](https://docs.windsurf.com/)
- [AGENTS.md support](https://docs.windsurf.com/windsurf/cascade/agents-md)
- [Cascade Memories / Rules](https://docs.windsurf.com/windsurf/cascade/memories)
- [Windsurf Rules Directory](https://windsurf.com/editor/directory)

## File Types and Paths

| File               | Path                                              | Format                       | Scope                                            |
| ------------------ | ------------------------------------------------- | ---------------------------- | ------------------------------------------------ |
| Workspace rules    | `.windsurf/rules/*.md`                            | Markdown + YAML frontmatter  | Per trigger type (see below)                     |
| Legacy             | `.windsurfrules`                                  | Plain markdown               | Always on (workspace)                            |
| Global rules       | `~/.codeium/windsurf/memories/global_rules.md`    | Plain markdown               | All workspaces                                   |
| AGENTS.md (root)   | `AGENTS.md`                                       | Plain markdown               | `always_on` equivalent (no config needed)        |
| AGENTS.md (subdir) | `<subdir>/AGENTS.md`                              | Plain markdown               | Auto-glob for `<subdir>/**`                      |

## `.windsurf/rules/*.md` Frontmatter

```yaml
---
trigger: always_on          # see trigger values below
globs: "**/*.test.ts"       # required when trigger: glob
---
```

```yaml
---
trigger: model_decision
description: "Apply when editing React components"
---
```

## Trigger Values

| Value            | Behavior                                                                |
| ---------------- | ----------------------------------------------------------------------- |
| `always_on`      | Full content in system prompt every message                             |
| `model_decision` | Model sees description only; loads full content when relevant           |
| `glob`           | Activates when files matching `globs:` are accessed                     |
| `manual`         | Only when `@rule-name` typed in Cascade input                           |

## Priority (Highest → Lowest)

1. System (enterprise managed)
2. Global (`~/.codeium/windsurf/memories/global_rules.md`)
3. Workspace (`.windsurf/rules/`)

## Character Limits

| Scope                            | Limit                                                              |
| -------------------------------- | ------------------------------------------------------------------ |
| Global rules                     | 6,000 characters                                                   |
| Per workspace rule file          | 12,000 characters                                                  |
| Global + workspace combined      | 12,000 characters (global takes priority if exceeded)              |

## Notes

- AGENTS.md at repo root = `always_on`; AGENTS.md in subdirectory = auto-glob for that dir
- AGENTS.md requires **no frontmatter and no configuration** — Windsurf auto-discovers it
- `.windsurfrules` is the legacy flat-file equivalent (still works, no frontmatter)
- `global_rules.md` has no frontmatter and is always applied
- Unknown frontmatter keys: behavior not officially documented
