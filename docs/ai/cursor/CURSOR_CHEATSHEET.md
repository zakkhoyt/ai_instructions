# Cursor — AI Customization Cheatsheet

## Rules Overview

- [Rules | Cursor Docs](https://cursor.com/docs/context/rules)
  - Location: `.cursor/rules/*.mdc`
  - File extension: `.mdc` (preferred) or `.md`
  - Legacy: `.cursorrules` at project root (deprecated, migrate to `.cursor/rules/`)

## Frontmatter Keys (`.mdc` files)

| Key           | Type    | Description                                              |
| ------------- | ------- | -------------------------------------------------------- |
| `description` | string  | What the rule does; used by agent to decide if relevant  |
| `globs`       | string  | Glob pattern(s) for file-scoped activation               |
| `alwaysApply` | boolean | If `true`, applies to every session unconditionally      |

## Rule Activation Modes

Controlled via the `type` dropdown in Cursor Settings (maps to frontmatter):

- **Always**: `alwaysApply: true` — applies every session
- **Auto Attached**: `globs: "**/*.ts"` — applies to matching files
- **Agent Requested**: `description:` only, `alwaysApply: false` — agent decides
- **Manual**: no auto-trigger, added explicitly by user

## Community Resources

- [Deep Dive into Cursor Rules (>0.45)](https://forum.cursor.com/t/a-deep-dive-into-cursor-rules-0-45/60721)
- [My Take on Cursor Rules](https://forum.cursor.com/t/my-take-on-cursor-rules/67535)

## Key Frontmatter Syntax (`.cursor/rules/*.mdc`)

```yaml
---
description: Standards for frontend components
globs: "src/components/**/*.tsx"
alwaysApply: false
---
```

> [!NOTE]
> Unknown frontmatter keys: behavior not officially documented.
> `globs` accepts a string (comma-separated or single pattern); array format also seen in practice.
