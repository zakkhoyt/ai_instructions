# AI Instructions Repository

A centralized collection of AI instruction files for various programming languages and AI platforms (GitHub Copilot, Claude, Cursor, etc.). This repository serves as a single source of truth for consistent AI coding assistance across all your projects.

## 🎯 What This Repository Does

This repository provides:

- **Language-specific coding conventions** - Instructions for `swift`, `python`, `zsh`, `markdown`, `javascript`, and more
- **Platform-specific configurations** - Support for `github copilot`, `claude`, `cursor`, and `coderabbit`
- **Easy installation script** - Automated setup for adding instructions to any project
- **Centralized management** - Update once, deploy everywhere

## 📂 Repository Structure

```
.
├── instructions/              # AI instruction files (source of truth)
│   ├── markdown/
│   │   └── markdown-conventions.instructions.md
│   ├── python/
│   │   ├── python-conventions.instructions.md
│   │   └── python-git-branching.instructions.md
│   ├── swift/
│   │   └── swift-conventions.instructions.md
│   ├── userscript/
│   │   └── userscript-conventions.instructions.md
│   └── zsh/
│       └── zsh-conventions.instructions.md
├── scripts/
│   ├── configure_ai_instructions.zsh          # Legacy installation script
│   ├── configure_ai_instructions_overhaul.zsh # New action-based architecture
│   ├── configure_ai_instructions.md           # Script documentation
│   └── install_git_hooks.zsh                  # Git hooks installer
└── docs/                     # Additional documentation
```

## 🚀 Quick Start

### Installation

1. **Clone this repository** to your local machine (recommend `~/.ai`)
   ```zsh
   git clone <repo-url> ~/.ai
   ```

2. **Configure your current project** with AI instructions:
   
   **Legacy script (original):**
   ```zsh
   cd /path/to/your/project
   ~/.ai/scripts/configure_ai_instructions.zsh
   ```
   
   **Overhaul script (new architecture):**
   ```zsh
   cd /path/to/your/project
   ~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt instructions
   ```

3. **Select instructions** from the interactive menu

That's it! Your project now has AI instructions configured.

### Before & After Example

Here's what happens when you configure a project for GitHub Copilot:

```
your-project/                    your-project/
├── src/                         ├── src/
├── tests/                       ├── tests/
├── package.json                 ├── package.json
├── README.md                    ├── README.md
└── .gitignore                   ├── .gitignore
                                 └── .github/
                                     └── instructions/
                                         ├── swift-conventions.instructions.md
                                         ├── git-branching.instructions.md
                                         └── markdown-conventions.instructions.md

        BEFORE                           AFTER
```

## 🛠️ The Configuration Script

### Overview

The `scripts/configure_ai_instructions.zsh` script is the heart of this repository. It automates the process of installing AI instruction files into your projects with support for multiple AI platforms.

### What It Does

1. **Syncs Instructions** - Copies the latest instructions from this repo to your user directory (`~/.ai` by default)
2. **Platform Detection** - Configures instructions for your chosen AI platform (Copilot, Claude, Cursor, etc.)
3. **Smart Installation** - Creates symlinks or copies files based on your preference
4. **Status Tracking** - Shows which instructions are already installed and their current state
5. **Interactive Menu** - Presents a user-friendly interface for selecting which instructions to install

### Basic Usage

```zsh
# Configure GitHub Copilot instructions for current directory (default behavior)
~/.ai/scripts/configure_ai_instructions.zsh

# Configure for a specific project
~/.ai/scripts/configure_ai_instructions.zsh --dest-dir /path/to/project

# Configure for Claude with copy mode instead of symlinks
~/.ai/scripts/configure_ai_instructions.zsh --ai-platform claude --configure-type copy

# Use a custom source directory
~/.ai/scripts/configure_ai_instructions.zsh --source-dir /custom/path
```

### Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source-dir <dir>` | User AI directory containing source instructions | `$Z2K_AI_DIR` or `$HOME/.ai` |
| `--dest-dir <dir>` | Target project directory (must be git repo root) | Current directory |
| `--ai-platform <platform>` | AI platform: `copilot`, `claude`, `cursor`, `coderabbit` | `copilot` |
| `--configure-type <type>` | Installation method: `symlink` or `copy` | `symlink` |
| `--help` | Display help message | - |
| `--debug` | Enable debug logging | - |
| `--dry-run` | Show what would be done without making changes | - |
| `--dev-link` | Create symlink to AI dev directory and update `.gitignore` | - |
| `--dev-vscode` | Add AI dev directory to VS Code workspace | - |
| `--workspace-settings` | Merge VS Code workspace templates via menu | - |
| `--user-settings` | Merge VS Code user settings templates via menu | - |
| `--workspace-settings` | Merge VS Code workspace templates via menu | - |
| `--user-settings` | Merge VS Code user settings templates via menu | - |

### Status Indicators

When you run the script, it displays a menu with status indicators:

```
 1. [S] swift-conventions.instructions.md
 2. [ ] python-conventions.instructions.md
 3. [C] markdown-conventions.instructions.md
 4. [O] zsh-conventions.instructions.md
```

**Legend:**
- `[ ]` - Not installed
- `[S]` - Symlinked (current)
- `[C]` - Copied (current)
- `[O]` - Copied (outdated - source has been updated)
- `[M]` - Copied (modified - local changes detected)
- `[U]` - Copied (unknown status)
- `[?]` - Wrong symlink target

### Platform-Specific Behavior

The script automatically configures the correct directory structure for each AI platform:

- **GitHub Copilot**: `.github/instructions/`
- **Claude**: `.claude/` with `CLAUDE.md` settings file
- **Cursor**: `.cursor/rules/`
- **CodeRabbit**: *(coming soon)*

### Development Features

#### `--dev-link`
Creates a symlink to this repository in your project and updates `.gitignore` to exclude it. Useful when actively developing AI instructions:

```zsh
~/.ai/scripts/configure_ai_instructions.zsh --dev-link
```

This creates a `.ai/` symlink in your project pointing to your AI instructions repository.

#### `--dev-vscode`
Adds this repository as a folder to your VS Code workspace file, making it easy to edit instructions while working on your project:

```zsh
~/.ai/scripts/configure_ai_instructions.zsh --dev-vscode
```

#### VS Code Template Library (`--workspace-settings`, `--user-settings`)
Template files live under `vscode/workspace` and `vscode/user` so you can merge JSONC snippets into either your repository workspace or global VS Code profile:

- `vscode/workspace/*.code-workspace` → merged into the newest `*.code-workspace` at the repo root
- `vscode/workspace/.vscode/*.json` → merged into `.vscode/<file>.json` inside the repo
- `vscode/user/*.json` → merged into `$HOME/Library/Application Support/Code/User/<file>.json`

File names may start with an optional `<topic>__` prefix (for example, `xcode__mcp.json`) to control display order while still mapping to the same destination file. Run the menus to apply a subset of templates:

```zsh
# Workspace templates (project-local)
~/.ai/scripts/configure_ai_instructions.zsh --workspace-settings

# User profile templates (global VS Code settings)
~/.ai/scripts/configure_ai_instructions.zsh --user-settings
```

### Copy vs Symlink Mode

**Symlink Mode (default):**
- Creates symlinks to the source files
- Instructions automatically update when you pull changes to this repo
- Ideal for most use cases

**Copy Mode:**
- Creates independent copies of instruction files
- Allows per-project customization
- The script tracks checksums to detect when source files are updated

## 🆕 Overhaul Script (New Architecture)

### Overview

The `scripts/configure_ai_instructions_overhaul.zsh` script is a complete rewrite with an **action-based architecture** that supports repeatable flags, hierarchical config selectors, and batch operations. It provides all the functionality of the legacy script plus powerful new features.

### Key Improvements

1. **Repeatable Actions** - Execute multiple operations in one command
2. **Hierarchical Config Selectors** - Fine-grained control over template application
3. **Prompt/Auto Modes** - Interactive or automatic operation per action
4. **Better Testing** - 17 comprehensive tests with isolated temp repos

### Action-Based Syntax

The overhaul script uses explicit action flags instead of positional arguments:

```zsh
# Action: instructions (legacy behavior)
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt instructions

# Action: dev-link (create symlink to ~/.ai)
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --no-prompt dev-link

# Action: regenerate-main (rebuild README_INSTRUCTIONS.md)
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --no-prompt regenerate-main

# Multiple actions in one command
~/.ai/scripts/configure_ai_instructions_overhaul.zsh \
  --prompt instructions \
  --no-prompt dev-link \
  --no-prompt regenerate-main
```

### Config Selector Engine

The overhaul introduces a powerful hierarchical config selector syntax for applying VS Code/MCP templates:

#### Syntax Levels

**Level 1 - Scope (Broadest):**
```zsh
# All user configs (all categories, all themes)
--no-prompt config-user

# All workspace configs
--no-prompt config-workspace

# All folder configs
--no-prompt config-folder
```

**Level 2 - Scope + Category:**
```zsh
# All user settings templates (any theme)
--prompt config-user:settings

# All workspace MCP configs (any theme)
--no-prompt config-workspace:mcp

# All folder tasks templates
--prompt config-folder:tasks
```

**Level 3 - Scope + Category + Theme (Most Specific):**
```zsh
# Only swift settings for user scope
--prompt config-user:settings:swift

# Only xcode-mcpserver MCP config for workspace
--no-prompt config-workspace:mcp:xcode-mcpserver

# Only debugging launch config for folder scope
--prompt config-folder:launch:debugging
```

#### Valid Scopes

- **`user`** - Global VS Code settings (`~/Library/Application Support/Code/User/`)
- **`workspace`** - Workspace-level configs (`.vscode/` in repo root)
- **`folder`** - Folder-level configs (`.vscode/` in workspace folders)

#### Valid Categories

- **`settings`** - VS Code settings.json templates
- **`mcp`** - MCP server configurations
- **`tasks`** - Task runner configs (tasks.json)
- **`launch`** - Debug launch configs (launch.json)

#### Theme Detection

Themes are auto-detected from template filenames and directories:
- Directory name: `xcode/settings.json` → theme: `xcode`
- Filename prefix: `swift-settings.json` → theme: `swift`
- MCP pattern: `xcode-mcpserver__mcp.json` → theme: `xcode-mcpserver`

### Legacy Aliases

For backward compatibility, the overhaul script supports legacy flag names:

```zsh
# Legacy: --workspace-settings
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt workspace-settings

# New equivalent: config-workspace:settings
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt config-workspace:settings

# Legacy: --user-settings
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt user-settings

# New equivalent: config-user:settings
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt config-user:settings
```

### Migration Guide

**Old Script:**
```zsh
~/.ai/scripts/configure_ai_instructions.zsh
```

**Overhaul Equivalent:**
```zsh
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --prompt instructions
```

**Old: Multiple Operations**
```zsh
~/.ai/scripts/configure_ai_instructions.zsh --dev-link
~/.ai/scripts/configure_ai_instructions.zsh --workspace-settings
~/.ai/scripts/configure_ai_instructions.zsh --user-settings
```

**Overhaul: Single Command**
```zsh
~/.ai/scripts/configure_ai_instructions_overhaul.zsh \
  --no-prompt dev-link \
  --prompt workspace-settings \
  --prompt user-settings
```

### Complex Examples

**Apply all user Swift settings automatically:**
```zsh
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --no-prompt config-user:settings:swift
```

**Interactive selection of all MCP configs across all scopes:**
```zsh
~/.ai/scripts/configure_ai_instructions_overhaul.zsh \
  --prompt config-user:mcp \
  --prompt config-workspace:mcp \
  --prompt config-folder:mcp
```

**Full project setup in one command:**
```zsh
~/.ai/scripts/configure_ai_instructions_overhaul.zsh \
  --no-prompt instructions \
  --no-prompt dev-link \
  --no-prompt regenerate-main \
  --prompt config-workspace:settings \
  --no-prompt config-workspace:mcp \
  --no-prompt mcp-xcode
```

### Getting Help

View all available actions and syntax:
```zsh
~/.ai/scripts/configure_ai_instructions_overhaul.zsh --help
```

---

## 🔧 Advanced Workflows

### Updating All Projects

To update instructions across multiple projects:

```zsh
# Update the AI instructions repository
cd ~/.ai && git pull

# Re-run the configuration script in each project (symlink mode auto-updates)
cd /path/to/project1 && ~/.ai/scripts/configure_ai_instructions.zsh
cd /path/to/project2 && ~/.ai/scripts/configure_ai_instructions.zsh
```

### Creating Custom Instructions

1. Add your `.instructions.md` file to the appropriate subdirectory in `instructions/`
2. Commit and push your changes
3. Run the configuration script in your projects to install the new instructions

## 🤝 Contributing

Instructions should follow this format:
- Filename: `<topic>-conventions.instructions.md`
- Location: `instructions/<language>/`
- Content: Clear, actionable guidance for AI coding assistants

## 📚 References

- [GitHub Copilot Documentation](https://docs.github.com/en/copilot)
- [GitHub: Premium Requests](https://docs.github.com/en/copilot/concepts/billing/copilot-requests)

## 📝 License

See LICENSE file for details.

---

**Maintained by**: Zakk Hoyt  
**Repository**: ai_instructions

