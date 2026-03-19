# GitHub Copilot — AI Customization Cheatsheet

## Customization Overview

- [Copilot Customization Overview](https://code.visualstudio.com/docs/copilot/customization/overview)

## Custom Instructions

- [Custom Instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
  - Instruction files: `.github/instructions/*.instructions.md`
  - Global instruction file: `.github/copilot-instructions.md`
  - Frontmatter keys: `name` (string), `description` (string), `applyTo` (glob string, comma-separated)
  - File extension **required**: `.instructions.md`

## Prompt Files

- [Prompt Files](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
  - Location: `.github/prompts/*.prompt.md`
  - Invoked with `@` in Copilot Chat

## Custom Agents

- [Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)

## Agent Skills

- [Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)

## Language Models

- [Language Models](https://code.visualstudio.com/docs/copilot/customization/language-models)

## MCP Servers

- [MCP Servers](https://code.visualstudio.com/docs/copilot/customization/mcp-servers)

## Hooks

- [Hooks](https://code.visualstudio.com/docs/copilot/customization/hooks)

## Plugins

- [Agent Plugins](https://code.visualstudio.com/docs/copilot/customization/agent-plugins)

## Guides

- [Context Engineering Guide](https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide)
- [Customize Copilot Guide](https://code.visualstudio.com/docs/copilot/guides/customize-copilot-guide)

## Key Frontmatter Syntax (`.instructions.md`)

```yaml
---
name: "Display name"
description: "Shown on hover in Chat view"
applyTo: "**/*.ts,**/*.tsx"
---
```

> [!NOTE]
> Unknown frontmatter keys: behavior not officially documented.
> `applyTo` is a comma-separated glob string (not a YAML array).
