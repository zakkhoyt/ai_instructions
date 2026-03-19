# CodeRabbit — Custom Instructions Cheatsheet

## Official Documentation

- [Configure CodeRabbit](https://docs.coderabbit.ai/configure-coderabbit/)
- [Add custom review instructions](https://docs.coderabbit.ai/guides/review-instructions)
- [Code guidelines (knowledge base)](https://docs.coderabbit.ai/knowledge-base/code-guidelines)
- [Full configuration reference](https://docs.coderabbit.ai/reference/configuration)
- [JSON schema](https://coderabbit.ai/integrations/schema.v2.json)

## File Types and Paths

| File | Path | Format | Scope |
| ---- | ---- | ------ | ----- |
| Config | `.coderabbit.yaml` | YAML (no frontmatter) | Repository-wide |
| Guidelines | Files listed in `knowledge_base.code_guidelines.filePatterns` | Plain markdown | Auto-loaded during reviews |

## `.coderabbit.yaml` Key Structure

```yaml
# yaml-language-server: $schema=https://coderabbit.ai/integrations/schema.v2.json

language: "en-US"
tone_instructions: "Be concise and direct"   # max 250 chars

reviews:
  profile: "chill"          # "chill" | "assertive"
  path_filters:             # include/exclude files from review scope
    - "!dist/**"
    - "!node_modules/**"
  path_instructions:        # glob-scoped review instructions
    - path: "src/controllers/**"
      instructions: |
        - Verify auth and input validation.
    - path: "**/*.test.ts"
      instructions: "Ensure descriptive test names."

knowledge_base:
  code_guidelines:
    enabled: true
    filePatterns:           # extends defaults; does NOT replace them
      - "**/CODING_STANDARDS.md"
  learnings:
    scope: "auto"           # "local" | "global" | "auto"
```

## Auto-Detected Instruction Files

CodeRabbit automatically reads these files as coding guidelines (zero config needed):

| Pattern | Source tool |
| ------- | ----------- |
| `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md` | GitHub Copilot |
| `**/CLAUDE.md` | Claude Code |
| `**/AGENTS.md`, `**/AGENT.md` | OpenAI Codex |
| `**/.cursorrules`, `**/.cursor/rules/*` | Cursor |
| `**/.windsurfrules` | Windsurf |
| `**/GEMINI.md` | Gemini CLI |
| `**/.clinerules/*` | Cline |

## Notes

- **Do NOT** put guideline filenames in `path_instructions` — that tells CodeRabbit to _review_ those files as changed code
- Use `knowledge_base.code_guidelines.filePatterns` to register guideline files
- `path_instructions` uses minimatch glob syntax; `!` prefix = exclusion
- Scope is repository-level only; no per-user file-based config (web UI dashboard for org-level)
