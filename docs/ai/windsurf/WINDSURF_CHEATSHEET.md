# Windsurf (Cascade) — AI Customization Cheatsheet

## Memories & Rules Overview

- [Cascade Memories](https://docs.windsurf.com/windsurf/cascade/memories)
  - Workspace rules: `.windsurf/rules/*.md`
  - Global rules file: `~/.codeium/windsurf/memories/global_rules.md` (no frontmatter, always on)
  - Character limit: 12,000 per workspace rule file; 6,000 for global rules

## Rule Activation Modes (`trigger` field)

| `trigger` value  | Behavior                                                         |
| ---------------- | ---------------------------------------------------------------- |
| `always_on`      | Always applied (no globs needed)                                 |
| `model_decision` | Agent decides based on `description`                             |
| `glob`           | Applied when Cascade reads/edits files matching `globs`          |
| `manual`         | User must `@mention` the rule explicitly in Cascade input        |

## Frontmatter Keys

| Key           | Type   | Required when           | Description                              |
| ------------- | ------ | ----------------------- | ---------------------------------------- |
| `trigger`     | string | Always                  | Activation mode (see table above)        |
| `globs`       | string | `trigger: glob`         | Glob pattern, e.g. `**/*.test.ts`        |
| `description` | string | `trigger: model_decision` | Brief description for agent to read    |

## Rules Directory

- [Windsurf Rules Directory](https://windsurf.com/editor/directory) — curated rule templates

## Key Frontmatter Syntax (`.windsurf/rules/*.md`)

```yaml
---
trigger: glob
globs: "**/*.test.ts"
---
```

```yaml
---
trigger: always_on
---
```

> [!NOTE]
> `global_rules.md` and `AGENTS.md` at root do **not** use frontmatter — they are always on.
> Unknown frontmatter keys: behavior not officially documented.
