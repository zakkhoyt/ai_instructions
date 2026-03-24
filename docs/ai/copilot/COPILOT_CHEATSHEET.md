# GitHub Copilot — Custom Instructions Cheatsheet

## Official Documentation

- [Custom instructions overview](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions)
- [Repository instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)
- [Personal instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-personal-instructions)
- [Organization instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-organization-instructions)
- [VS Code: Custom instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [VS Code: Prompt files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [VS Code: Custom agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- [VS Code: Agent skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [VS Code: Language models](https://code.visualstudio.com/docs/copilot/customization/language-models)
- [VS Code: MCP servers](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)
- [VS Code: Hooks](https://code.visualstudio.com/docs/copilot/customization/hooks)
- [VS Code: Agent plugins](https://code.visualstudio.com/docs/copilot/customization/agent-plugins)
- [VS Code: Copilot settings reference](https://code.visualstudio.com/docs/copilot/copilot-settings)
- [VS Code: Copilot customization overview](https://code.visualstudio.com/docs/copilot/copilot-customization)
- [VS Code: Context engineering guide](https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide)
- [VS Code: Customize Copilot guide](https://code.visualstudio.com/docs/copilot/guides/customize-copilot-guide)

## File Types and Paths

| File                    | Path                                          | Format                       | Scope                               |
| ----------------------- | --------------------------------------------- | ---------------------------- | ----------------------------------- |
| Repo instructions       | `.github/copilot-instructions.md`             | Plain markdown (no frontmatter) | All requests in repo             |
| Path instructions       | `.github/instructions/*.instructions.md`      | Markdown + YAML frontmatter  | Files matching `applyTo` glob       |
| Prompt files            | `.github/prompts/*.prompt.md`                 | Markdown + YAML frontmatter  | Manually invoked (`/name`)          |
| Agent files             | `.github/agents/*.agent.md`                   | Markdown + YAML frontmatter  | Custom chat agents                  |
| AGENTS.md               | `AGENTS.md` (any dir)                         | Plain markdown               | Auto-loaded when `chat.useAgentsMdFile: true` |
| CLAUDE.md               | `CLAUDE.md` or `.claude/CLAUDE.md`            | Markdown + `@imports`        | Auto-loaded when `chat.useClaudeMdFile: true` |

## `.instructions.md` Frontmatter

```yaml
---
applyTo: "**/*.ts,**/*.tsx"   # glob(s); comma-separate multiples; omit to disable auto-apply
name: "Display Name"          # optional
description: "Short text"     # optional; shown on hover in VS Code
excludeAgent: "code-review"   # optional; "code-review" | "coding-agent" (GitHub.com only)
---
```

## `.prompt.md` Frontmatter

```yaml
---
name: "My Prompt"             # optional; display name when typing /
description: "What it does"   # optional
argument-hint: "Enter value"  # optional; placeholder in chat input
agent: "ask"                  # optional; ask | agent | plan | <custom-agent-name>
model: "gpt-4o"               # optional
tools:                        # optional
  - fetch
  - github
  - servername/*
---
```

## VS Code Settings

| Setting                                               | Default                                  | Purpose                                                      |
| ----------------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------ |
| `chat.instructionsFilesLocations`                     | `{ ".github/instructions": true }`       | Dirs to scan for `.instructions.md`                          |
| `chat.promptFilesLocations`                           | `{ ".github/prompts": true }`            | Dirs to scan for `.prompt.md`                                |
| `chat.agentFilesLocations`                            | `{ ".github/agents": true }`             | Dirs to scan for `.agent.md`                                 |
| `chat.includeApplyingInstructions`                    | `true`                                   | Auto-add matching `applyTo` instructions                     |
| `github.copilot.chat.codeGeneration.useInstructionFiles` | `true`                                | Use `.github/copilot-instructions.md`                        |
| `chat.useAgentsMdFile`                                | `true`                                   | Enable `AGENTS.md` as context (universal open standard)      |
| `chat.useClaudeMdFile`                                | `true`                                   | Enable `CLAUDE.md` as instructions                           |

## Priority (Highest → Lowest)

1. Personal instructions (GitHub.com UI)
2. Repository instructions (file-based)
3. Organization instructions (Org Settings UI)

## Notes

- Instructions apply to **Chat only** — not inline completions
- Multiple matching instruction files are all combined (not overridden)
- `.prompt.md` files are **not** supported on GitHub.com (IDE clients only)
- `applyTo` is a comma-separated glob string (not a YAML array)
- Unknown frontmatter keys: behavior not officially documented
