# Cursor — Custom Rules Cheatsheet

## Official Documentation

- [Rules — Cursor Docs](https://cursor.com/docs/context/rules)
- [docs.cursor.com/context/rules](https://docs.cursor.com/context/rules)

## File Types and Paths

| File              | Path                       | Format                       | Scope                           |
| ----------------- | -------------------------- | ---------------------------- | ------------------------------- |
| Project rules     | `.cursor/rules/*.mdc`      | Markdown + YAML frontmatter  | Per rule type (see below)       |
| Project rules (alt) | `.cursor/rules/*.md`     | Markdown + YAML frontmatter  | Per rule type                   |
| Legacy (deprecated) | `.cursorrules`           | Plain markdown               | Always loaded (repo-wide)       |
| User rules        | Cursor Settings → Rules (UI) | Plain text                 | All projects on this machine    |
| Team rules        | Dashboard (Enterprise)     | Managed                      | Org-wide                        |
| AGENTS.md         | `AGENTS.md` (any dir)      | Plain markdown               | Auto-loaded (Cursor co-founded the open standard) |

## `.mdc` Frontmatter Schema

```yaml
---
description: "When and why to apply this rule"   # required for Agent Requested type
globs: "**/*.ts, src/components/**"              # string or array; triggers Auto Attached
alwaysApply: false                               # true = Always type
---
```

## Four Rule Types

| Type               | `alwaysApply` | `globs` | `description` | Trigger                             |
| ------------------ | ------------- | ------- | ------------- | ----------------------------------- |
| **Always**         | `true`        | —       | optional      | Every chat session                  |
| **Auto Attached**  | `false`       | set     | optional      | Matching file in context            |
| **Agent Requested** | `false`      | —       | **required**  | AI decides based on description     |
| **Manual**         | `false`       | —       | —             | Only when `@rule-name` typed        |

## Priority (Highest → Lowest)

1. Team (Dashboard/Enterprise)
2. Project (`.cursor/rules/`)
3. User (Settings UI)

## Community Resources

- [Deep Dive into Cursor Rules (>0.45)](https://forum.cursor.com/t/a-deep-dive-into-cursor-rules-0-45/60721)
- [My Take on Cursor Rules](https://forum.cursor.com/t/my-take-on-cursor-rules/67535)

## Notes

- `.cursorrules` (root file) is still functional but officially deprecated — migrate to `.cursor/rules/*.mdc`
- `globs` uses standard glob patterns (e.g., `**/*.py`, `src/**`)
- No documented character limits per rule file
- Cursor co-founded the AGENTS.md open standard (alongside OpenAI, Windsurf, and others)
- Unknown frontmatter keys: behavior not officially documented
- `globs` accepts a string (comma-separated or single pattern); array format also seen in practice
