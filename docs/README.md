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
│   ├── configure_ai_instructions.zsh  # Main installation script
│   ├── configure_ai_instructions.md   # Script documentation
│   └── install_git_hooks.zsh          # Git hooks installer
└── docs/                     # Additional documentation
```

## 🚀 Quick Start

### Installation

1. **Clone this repository** to your local machine (recommend `~/.ai`)
   ```zsh
   git clone <repo-url> ~/.ai
   ```

2. **Configure your current project** with AI instructions:
   ```zsh
   cd /path/to/your/project
   ~/.ai/scripts/configure_ai_instructions.zsh
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
~/.ai/scripts/configure_ai_instructions.zsh --target-dir /path/to/project

# Configure for Claude with copy mode instead of symlinks
~/.ai/scripts/configure_ai_instructions.zsh --ai-platform claude --configure-type copy

# Use a custom source directory
~/.ai/scripts/configure_ai_instructions.zsh --source-dir /custom/path
```

### Command-Line Options

| Option | Description | Default |
|--------|-------------|---------|
| `--source-dir <dir>` | User AI directory containing source instructions | `$Z2K_AI_DIR` or `$HOME/.ai` |
| `--target-dir <dir>` | Target project directory (must be git repo root) | Current directory |
| `--ai-platform <platform>` | AI platform: `copilot`, `claude`, `cursor`, `coderabbit` | `copilot` |
| `--configure-type <type>` | Installation method: `symlink` or `copy` | `symlink` |
| `--help` | Display help message | - |
| `--debug` | Enable debug logging | - |
| `--dry-run` | Show what would be done without making changes | - |
| `--dev-link` | Create symlink to AI dev directory and update `.gitignore` | - |
| `--dev-vscode` | Add AI dev directory to VS Code workspace | - |

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

### Copy vs Symlink Mode

**Symlink Mode (default):**
- Creates symlinks to the source files
- Instructions automatically update when you pull changes to this repo
- Ideal for most use cases

**Copy Mode:**
- Creates independent copies of instruction files
- Allows per-project customization
- The script tracks checksums to detect when source files are updated

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