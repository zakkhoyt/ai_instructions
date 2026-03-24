# Gemini CLI — Custom Instructions Cheatsheet

## Official Documentation

- [Provide context with GEMINI.md](https://google-gemini.github.io/gemini-cli/docs/cli/gemini-md.html)
- [geminicli.com: GEMINI.md](https://geminicli.com/docs/cli/gemini-md/)
- [gemini-cli GitHub: docs/cli/gemini-md.md](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/gemini-md.md)
- [Gemini CLI configuration](https://geminicli.com/docs/reference/configuration/)
- [Jules — Getting Started](https://jules.google/docs/)
- [Jules API](https://developers.google.com/jules/api)

## File Types and Paths

| File | Path | Format | Scope |
| ---- | ---- | ------ | ----- |
| Global instructions | `~/.gemini/GEMINI.md` | Plain markdown | All projects |
| Project instructions | `GEMINI.md` (git root or any ancestor) | Plain markdown | Repo and subdirs |
| Subdirectory instructions | `<subdir>/GEMINI.md` | Plain markdown | Loaded JIT when dir accessed |

## Format

Plain Markdown — **no frontmatter**. Any heading structure is valid.

## `@import` Syntax (within GEMINI.md)

```markdown
@./components/style-guide.md
@/absolute/path/to/standards.md
```

## Discovery Hierarchy (all concatenated, additive)

1. `~/.gemini/GEMINI.md` (global, loaded first)
2. Upward traversal: walks from CWD up to nearest `.git` root, loading any `GEMINI.md` in each ancestor directory (topmost → CWD)
3. Downward traversal (JIT): when a tool accesses a file/directory, scans into subdirs for `GEMINI.md`, respecting `.gitignore` and `.geminiignore`

## Configurable Filename (`settings.json`)

```json
{
  "context": {
    "fileName": ["AGENTS.md", "CONTEXT.md", "GEMINI.md"]
  }
}
```

## Memory Commands

```
/memory show      # display full concatenated context
/memory reload    # rescan all GEMINI.md files
/memory add <text>  # append to ~/.gemini/GEMINI.md
```

## Notes

- No frontmatter — plain markdown only
- Scoping is **directory-based**, not glob-based
- All discovered files are **additively concatenated** (no override logic)
- Google Jules (async web agent) also reads `AGENTS.md` at repo root
- `.geminiignore` can suppress files from JIT scanning
