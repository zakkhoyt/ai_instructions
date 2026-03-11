# Proposed `--help` Output for configure_ai_instructions.zsh

## New Argument System (Post-Overhaul)

```
USAGE:
    configure_ai_instructions.zsh [OPTIONS]

DESCRIPTION:
    Configure AI instructions and VSCode settings for projects.
    Supports granular control over installation scope, category, and theme.

ACTION TYPES:
    The script supports two types of actions:
    
    1. CONFIG ACTIONS (with selectors):
       Syntax: config-<scope>[:<category>][:<theme>]
       These manage VSCode configuration files with hierarchical selection.
    
    2. SIMPLE ACTIONS:
       Syntax: <action-name>
       These perform specific operations without hierarchical selection.

NEW PROMPT SYSTEM:
    --prompt <action>
        Show interactive menu/confirmation for specified action.
        Can be repeated to prompt for multiple actions.
        
    --no-prompt <action>
        Execute action automatically without prompts.
        Can be repeated for multiple actions.

CONFIG ACTIONS (VSCode Settings with Selectors):
    
    Scope only (all categories & themes):
        --prompt config-user                   # All user profile configs
        --prompt config-workspace              # All workspace configs
        --prompt config-folder                 # All folder (.vscode) configs
    
    Scope + Category (all themes):
        --prompt config-user:settings          # All user settings themes
        --prompt config-user:mcp               # All user MCP themes
        --prompt config-workspace:settings     # All workspace settings themes
        --prompt config-workspace:mcp          # All workspace MCP themes
        --prompt config-folder:settings        # All folder settings themes
    
    Scope + Category + Theme (specific):
        --prompt config-user:settings:swift    # Swift user settings only
        --prompt config-user:mcp:atlassian     # Atlassian MCP user config
        --prompt config-workspace:mcp:xcode-mcpserver
        --prompt config-folder:settings:fileNesting

SIMPLE ACTIONS:
    
    instructions        Manage AI instruction files
        --prompt instructions           # Show menu of instruction files
        --no-prompt instructions        # Auto-install all instructions
    
    dev-link            Create development symlink
        --prompt dev-link               # Confirm before creating symlink
        --no-prompt dev-link            # Create symlink automatically
    
    dev-vscode          Add to VSCode workspace
        --prompt dev-vscode             # Confirm before adding to workspace
        --no-prompt dev-vscode          # Add to workspace automatically
    
    regenerate-main     Regenerate main instruction file
        --prompt regenerate-main        # Confirm before regenerating
        --no-prompt regenerate-main     # Regenerate automatically
    
    mcp-xcode           Install Xcode MCP configuration
        --prompt mcp-xcode              # Confirm before installing
        --no-prompt mcp-xcode           # Install automatically

CONFIG SCOPE DETAILS:
    config-user        User profile settings (~/.../Code/User/*.json)
    config-workspace   Workspace files (*.code-workspace) + .vscode/ in workspace
    config-folder      Folder settings ($dest_dir/.vscode/*.json)

AVAILABLE CATEGORIES (for config actions):
    settings    VS Code settings.json
    mcp         Model Context Protocol servers (mcp.json)
    tasks       Task definitions (tasks.json) [FUTURE]
    launch      Launch configurations (launch.json) [FUTURE]
    keybindings Keyboard shortcuts (keybindings.json) [FUTURE - config-user only]

AVAILABLE THEMES (for config actions):
    config-user scope:
        swift, chat, github, atlassian
    
    config-workspace scope:
        swift, xcode-mcpserver, ai_autoapprove
    
    config-folder scope:
        swift, xcode-mcpserver, atlassian-mcpserver, fileNesting

MAINTENANCE:
    --regenerate-main              Regenerate .github/copilot-instructions.md
    
    --help                         Show this help message
    
    --debug                        Enable debug output

EXAMPLES:
    # Install all user and workspace configs with menus
    configure_ai_instructions.zsh --prompt config-user --prompt config-workspace
    
    # Auto-install specific configs without prompts
    configure_ai_instructions.zsh --no-prompt config-user:settings:swift \\
                                  --no-prompt config-workspace:mcp:xcode-mcpserver
    
    # Install instructions and setup development environment
    configure_ai_instructions.zsh --prompt instructions \\
                                  --prompt dev-link \\
                                  --prompt dev-vscode
    
    # Mixed: prompt for some, auto for others
    configure_ai_instructions.zsh --prompt config-workspace:settings \\
                                  --no-prompt config-user:mcp
    
    # Complete project setup (auto mode)
    configure_ai_instructions.zsh --no-prompt instructions \\
                                  --no-prompt config-user:settings:swift \\
                                  --no-prompt config-workspace \\
                                  --no-prompt dev-link \\
                                  --no-prompt dev-vscode
```

---

## Legacy Arguments (Current Script - Pre-Overhaul)

These are the **current** arguments that exist but are being redesigned:

```
CURRENT FLAGS (TO BE DEPRECATED):
    --instructions              Install instruction files (menu-driven)
                               Maps to: --prompt instructions
    
    --workspace-settings        Workspace settings [BROKEN - doesn't work]
                               Maps to: --prompt config-workspace
    
    --user-settings             User settings [BROKEN - doesn't work]
                               Maps to: --prompt config-user
    
    --mcp-xcode                 Force Xcode MCP installation
                               Maps to: --no-prompt mcp-xcode
    
    --dev-link                  Create development symlink
                               Maps to: --no-prompt dev-link
    
    --dev-vscode                Add to VSCode workspace
                               Maps to: --no-prompt dev-vscode
    
    --prompt                    Enable menu prompts [AMBIGUOUS - being replaced]
                               Old: Boolean flag (all or nothing)
                               New: Repeatable with action targets
    
    --no-prompt                 Disable menu prompts [AMBIGUOUS - being replaced]
                               Old: Boolean flag (all or nothing)
                               New: Repeatable with action targets

ISSUES WITH CURRENT SYSTEM:
    1. --workspace-settings and --user-settings don't work as documented
    2. --prompt has no argument, just enables prompting globally
    3. No way to specify granular control (specific themes/categories)
    4. Boolean flag explosion (would need --swift-user-settings, etc.)
    5. No unified syntax for all action types
```

---

## Auto-Detection Behaviors (Undocumented)

The script currently performs these actions **automatically** without requiring flags:

```
AUTO-DETECTION BEHAVIORS:

XCODE MCP AUTO-DETECTION:
    When: Script detects Package.swift, *.xcworkspace, or *.xcodeproj
    Action: Prompts user to install Xcode MCP server configuration
    New equivalent: --prompt mcp-xcode or --prompt config-workspace:mcp:xcode-mcpserver
    Files affected:
        - Most recent *.code-workspace file (merged)
        - .vscode/mcp.json (created/merged)
    
    Problem: Happens automatically even when user didn't request it
    Solution: Only trigger with explicit action:
              --prompt mcp-xcode
              --prompt config-workspace:mcp:xcode-mcpserver

INSTRUCTION FILE MENU:
    When: No instruction files exist in destination
    Action: Shows menu (gates with has_instructions_to_install check)
    New equivalent: --prompt instructions
    
    Problem: Menu skip logic conflicts with --prompt flag
    Solution: Show menu when --prompt instructions used,
              regardless of installation state

NUMBER FORMATTING:
    Problem: Menu numbering uses printf "%2d" - breaks at 10+ items
    Solution: Use printf "%3d" or dynamic width calculation
```

---

## Arguments Not Yet Discussed

These exist in various TODO sections but haven't been addressed in the overhaul:

```
ICON/ASSET MANAGEMENT:
    --icons [PATH]                 Link app icons from ~/.ai/images/icons/
                                   Default PATH: docs/images/icons/
    
    Behavior:
        - Creates symlink to icon repository
        - Allows customizable destination path
        - Enables AI agents to use consistent icons across repos

PLATFORM-SPECIFIC INSTRUCTIONS:
    --platform <name>              Configure for specific AI platform
    
    Supported platforms:
        copilot, claude, cursor, coderabbit
    
    Behavior:
        - Copies platform-specific root instruction file
        - Applies platform-specific configuration
        - Example: --platform claude creates CLAUDE.md + .claude/settings.json

FUTURE WORKSPACE FOLDER SUPPORT:
    --prompt config-folder[<name>]:<category>[:<theme>]
    
    Examples:
        --prompt config-folder[]:settings              # All folders, settings category
        --prompt config-folder[scripts]:settings       # "scripts" folder only
        --prompt config-folder[src]:settings:swift     # "src" folder, swift theme

WILDCARDS/PATTERNS (FUTURE):
    --prompt config-user:settings:mark*               # All themes starting with "mark"
    --prompt config-workspace:mcp:*-mcpserver         # All MCP server themes
    --prompt config-user:*:swift                      # Swift configs across all categories
```

---

## Workflow Examples

### Setup New Swift Project
```zsh
# Install instructions + Swift configs + Xcode MCP + dev environment
configure_ai_instructions.zsh \\
    --no-prompt instructions \\
    --no-prompt config-user:settings:swift \\
    --no-prompt config-workspace:settings:swift \\
    --no-prompt config-workspace:mcp:xcode-mcpserver \\
    --no-prompt config-folder:settings:swift \\
    --no-prompt dev-link \\
    --no-prompt dev-vscode
```

### Interactive Selection (Current Repo State)
```zsh
# Let user choose what to install via menus
configure_ai_instructions.zsh \\
    --prompt config-user \\
    --prompt config-workspace \\
    --prompt config-folder \\
    --prompt instructions
```

### Minimal Setup (Just Instructions)
```zsh
# Only install instruction files
configure_ai_instructions.zsh --no-prompt instructions
```

### Mixed Auto + Interactive
```zsh
# Auto-install known configs, prompt for workspace-specific ones
configure_ai_instructions.zsh \\
    --no-prompt config-user:settings:swift \\
    --no-prompt config-user:mcp:atlassian \\
    --prompt config-workspace              # Menu for workspace configs
```

### Development Workflow
```zsh
# Setup repository for AI development
configure_ai_instructions.zsh \\
    --no-prompt instructions \\
    --no-prompt dev-link \\
    --no-prompt dev-vscode \\
    --prompt config-workspace
```

---

## Migration Path

**Phase 1** (Current → Transition):
- Keep existing flags working
- Add new `--prompt <scope:category:theme>` system alongside
- Show deprecation warnings for old flags

**Phase 2** (Deprecation):
- Remove `--workspace-settings` and `--user-settings` (already broken)
- Make `--prompt` require argument (error if used without)
- Update all documentation

**Phase 3** (Full Migration):
- Remove all legacy flags
- New syntax is the only supported method
- Update tests and examples

---

## Open Questions

1. **Multiple specifications**: Should `--prompt config-user:settings config-workspace:mcp` work, or require separate flags?
2. **Default behavior**: What happens when script runs with no args at all?
3. **Conflict resolution**: What if `--prompt` and `--no-prompt` both specify same config?
4. **Validation**: Should script validate config-scope:category:theme against available files?
5. **Discovery**: How does user know what themes are available? Add `--list` flag?

---

## Suggested Additional Flags

SUGGESTED ADDITIONAL FLAGS:

```
DISCOVERY:
    --list-actions                 Show all available actions
    --list-config-scopes           Show available config scopes
    --list-categories [SCOPE]      Show categories for config scope
    --list-themes [SCOPE[:CATEGORY]]
                                   Show available themes
    
    Examples:
        --list-actions
        --list-themes config-user:settings
        --list-themes config-workspace
        --list-themes

VALIDATION:
    --dry-run <action>             Show what would be executed without doing it
    --validate                     Check all template files for syntax errors

CLEANUP:
    --unlink <action>              Remove previously installed configs
    --reset                        Remove all installed configs (dangerous!)
```

---

## Files to Update

When implementing this overhaul, update:

1. **scripts/configure_ai_instructions.zsh** - Core logic
2. **scripts/configure_ai_instructions.zsh.md** - Documentation
3. **scripts/CONFIGURE_AI_INSTRUCTIONS_OVERHAUL.md** - Design decisions
4. **README.md** - Usage examples
5. **vscode/user/README.md** - Update references to new syntax
6. **vscode/workspace/README.md** - Update references to new syntax
7. **docs/VSCODE.md** - Update VSCode integration docs
