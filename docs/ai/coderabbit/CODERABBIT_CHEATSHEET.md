# CodeRabbit — AI Customization Cheatsheet

## Configuration Overview

- [Configure CodeRabbit](https://docs.coderabbit.ai/configure-coderabbit/)
- [Configuration Reference](https://docs.coderabbit.ai/reference/configuration)

## Review Instructions

- [Add Custom Review Instructions](https://docs.coderabbit.ai/guides/review-instructions)
  - All instruction configuration lives in `.coderabbit.yaml`
  - **No per-file frontmatter** — CodeRabbit does not use individual instruction files

## Path-Based Review Instructions

- [Path-Based Review Instructions](https://docs.coderabbit.ai/configuration/path-instructions)

```yaml
# .coderabbit.yaml
reviews:
  path_instructions:
    - path: "src/controllers/**"
      instructions: |
        - Focus on authentication, authorization, and input validation.
        - Flag any direct database queries that bypass the ORM layer.
    - path: "**/*.test.ts"
      instructions: |
        - Ensure all tests have descriptive names.
        - Check for missing edge cases.
```

## AST-Based Instructions

- [AST-Based Path Instructions](https://docs.coderabbit.ai/configuration/ast-grep-instructions)
  - Structural code pattern rules using `ast-grep`

## Code Guidelines (External Rule File Auto-Detection)

- [Code Guidelines](https://www.coderabbit.ai/blog/code-guidelines-bring-your-coding-rules-to-coderabbit)
  - CodeRabbit **automatically scans** `.cursorrules`, `.copilot-instructions`, and other coding standards files as context enrichment
  - This means Copilot/Cursor rule files in the repo are picked up by CodeRabbit automatically

## Key Difference from Other Tools

> [!IMPORTANT]
> CodeRabbit has **no per-file instruction format**. Glob scoping is expressed via `.coderabbit.yaml` under `reviews.path_instructions[].path`, not in individual markdown files.
> CodeRabbit uses minimatch syntax for glob patterns.
