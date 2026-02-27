# VS Code Workspace & Folder Settings Templates

This directory contains JSON/JSONC template files for both **workspace** and **folder** scope settings via `scripts/configure_ai_instructions.zsh`.

## Directory Purpose

**Scopes:** `workspace` and `folder`  
**Destinations:**
- Workspace: `<project_dir>/*.code-workspace`
- Folder: `<project_dir>/.vscode/*.json`

## Workspace vs Folder Scope

| Scope | Destination | When to Use |
|-------|-------------|-------------|
| **Workspace** | `project.code-workspace` | Multi-root workspaces, portable configs |
| **Folder** | `.vscode/*.json` | Single-folder projects, git-committed settings |

## Directory Structure

```
workspace/
├── README.md (this file)
├── *.code-workspace         # Workspace scope templates
└── .vscode/                 # Folder scope templates
    ├── settings.json
    ├── tasks.json
    ├── launch.json
    └── *.json
```

## Filename Convention

### Workspace Files

```
<theme>__workspace.code-workspace
```

**Example:** `xcode-mcpserver__workspace.code-workspace`

**Parsing:**
1. Split on `__`: `<theme>__workspace.code-workspace`
2. Extract **theme**: `xcode-mcpserver`
3. Creates: `<project_dir>/<theme>.code-workspace`

### Folder Files (.vscode/)

```
<theme>__<category>.json
```

**Example:** `.vscode/swift__settings.json`

**Parsing:**
1. Split on `__`: `<theme>__<category>.json`
2. Extract **category**: `settings`
3. Merges into: `<project_dir>/.vscode/<category>.json`

## Filename Terms

- **Theme** - Topic/purpose (e.g., `swift`, `fileNesting`)
- **Category** - Target filename (e.g., `settings`, `tasks`, `launch`)
- **Separator** - Double underscore `__` (required)

## Destination Examples

### Workspace Scope

| Source File | Theme | Creates |
|-------------|-------|---------|
| `xcode-mcpserver__workspace.code-workspace` | `xcode-mcpserver` | `<project>/xcode-mcpserver.code-workspace` |
| `default__workspace.code-workspace` | `default` | `<project>/default.code-workspace` |

### Folder Scope

| Source File | Theme | Category | Merges Into |
|-------------|-------|----------|-------------|
| `.vscode/swift__settings.json` | `swift` | `settings` | `<project>/.vscode/settings.json` |
| `.vscode/fileNesting__settings.json` | `fileNesting` | `settings` | `<project>/.vscode/settings.json` |
| `.vscode/xcode-mcpserver__mcp.json` | `xcode-mcpserver` | `mcp` | `<project>/.vscode/mcp.json` |
| `.vscode/xcode-mcpserver__tasks.json` | `xcode-mcpserver` | `tasks` | `<project>/.vscode/tasks.json` |

## Multiple Sources → One Destination

Multiple themes can merge into the same category:

```
.vscode/swift__settings.json        ─┐
.vscode/fileNesting__settings.json  ├─→ .vscode/settings.json (merged)
.vscode/python__settings.json       ─┘
```

**Merge behavior:**
- Dictionaries: Keys merged recursively (template overrides existing)
- Arrays: Replaced with template values
- Primitives: Replaced with template values
- Comments: Preserved from both sources

## Usage with Script

```zsh
# Show menu to select workspace/folder templates
./script --prompt workspace
./script --prompt folder

# Auto-merge all templates (no menu)
./script --no-prompt workspace
./script --no-prompt folder

# Merge specific category (future)
./script --prompt folder:settings

# Merge specific theme (future)  
./script --prompt folder:settings:swift
```

## File Format

Files must be valid JSON or JSONC (JSON with Comments):

```jsonc
{
  // Comments are preserved during merge
  "setting.name": "value",
  "another.setting": {
    "nested": "works"
  }
}
```

## Adding New Templates

### Workspace Template

1. Create: `<theme>__workspace.code-workspace`
2. Add workspace configuration
3. Run: `./script --prompt workspace`

### Folder Template

1. Create: `.vscode/<theme>__<category>.json`
2. Add settings in JSON/JSONC format
3. Run: `./script --prompt folder`

Templates are auto-discovered - no configuration needed!

## When to Use Which Scope

**Use Workspace (*.code-workspace):**
- Multi-root projects
- Portable configs across machines
- Quick workspace switching
- Don't want settings in git

**Use Folder (.vscode/):**
- Single-folder projects
- Settings shared via git
- Project-specific configurations
- Language-specific setups
