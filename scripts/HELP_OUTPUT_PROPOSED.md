# Proposed `--help` Output for configure_ai_instructions.zsh

## New Argument System (Post-Overhaul)

```
USAGE:
    configure_ai_instructions.zsh [OPTIONS]

DESCRIPTION:
    Configure AI instructions and VSCode settings for projects.
    Supports granular control over installation scope, category, and theme.

NEW PROMPT SYSTEM:
    --prompt <scope[:<category>][:<theme>]>
        Show interactive menu for specified configuration.
        
        Scope only (all categories & themes):
            --prompt user                   # All user profile configs
            --prompt workspace              # All workspace configs
            --prompt folder                 # All folder (.vscode) configs
        
        Scope + Category (all themes):
            --prompt user:settings          # All user settings themes
            --prompt user:mcp               # All user MCP themes
            --prompt workspace:settings     # All workspace settings themes
            --prompt workspace:mcp          # All workspace MCP themes
            --prompt folder:settings        # All folder settings themes
        
        Scope + Category + Theme (specific):
            --prompt user:settings:swift    # Swift user settings only
            --prompt user:mcp:atlassian     # Atlassian MCP user config
            --prompt workspace:mcp:xcode-mcpserver
            --prompt folder:settings:fileNesting
    
    --no-prompt <scope[:<category>][:<theme>]>
        Auto-apply configuration without menu (same scope syntax as --prompt).
        
        Examples:
            --no-prompt user                # Install all user configs
            --no-prompt workspace:mcp       # Install all workspace MCP configs
            --no-prompt user:settings:swift # Install swift user settings only

AVAILABLE SCOPES:
    user        User profile settings (~/.../Code/User/*.json)
    workspace   Workspace files (*.code-workspace)
    folder      Folder settings ($dest_dir/.vscode/*.json)

AVAILABLE CATEGORIES:
    settings    VS Code settings.json
    mcp         Model Context Protocol servers (mcp.json)
    tasks       Task definitions (tasks.json) [FUTURE]
    launch      Launch configurations (launch.json) [FUTURE]
    keybindings Keyboard shortcuts (keybindings.json) [FUTURE - user only]

AVAILABLE THEMES:
    User scope:
        swift, chat, github, atlassian
    
    Workspace scope:
        swift, xcode-mcpserver, ai_autoapprove
    
    Folder scope:
        swift, xcode-mcpserver, atlassian-mcpserver, fileNesting

INSTRUCTION FILES:
    --prompt instructions           # Show menu of instruction files
    --no-prompt instructions        # Auto-install all instructions
    
    Note: Instruction files are copied/symlinked from:
        ~/.ai/instructions/** → $dest_dir/.github/instructions/

DEVELOPMENT FLAGS:
    --dev-link [NAME]              Create symlink to ~/.ai in project
                                   Optional NAME overrides default dirname
    
    --dev-vscode [NAME]            Add ~/.ai folder to VSCode workspace
                                   Optional NAME overrides display name

MAINTENANCE:
    --regenerate-main              Regenerate .github/copilot-instructions.md
    
    --help                         Show this help message
    
    --debug                        Enable debug output

EXAMPLES:
    # Install all user and workspace configs with menus
    configure_ai_instructions.zsh --prompt user --prompt workspace
    
    # Auto-install specific configs without prompts
    configure_ai_instructions.zsh --no-prompt user:settings:swift \\
                                  --no-prompt workspace:mcp:xcode-mcpserver
    
    # Install instructions and setup development environment
    configure_ai_instructions.zsh --prompt instructions \\
                                  --dev-link \\
                                  --dev-vscode
    
    # Mixed: prompt for some, auto for others
    configure_ai_instructions.zsh --prompt workspace:settings \\
                                  --no-prompt user:mcp
```

---

## Legacy Arguments (Current Script - Pre-Overhaul)

These are the **current** arguments that exist but are being redesigned:

```
CURRENT FLAGS (TO BE DEPRECATED):
    --instructions              Install instruction files (menu-driven)
    --workspace-settings        Workspace settings [BROKEN - doesn't work]
    --user-settings             User settings [BROKEN - doesn't work]
    --mcp-xcode                 Force Xcode MCP installation
    --prompt                    Enable menu prompts [AMBIGUOUS]
    --no-prompt                 Disable menu prompts [AMBIGUOUS]

ISSUES WITH CURRENT SYSTEM:
    1. --workspace-settings and --user-settings don't work as documented
    2. --prompt has no argument, just enables prompting globally
    3. No way to specify granular control (specific themes/categories)
    4. Boolean flag explosion (would need --swift-user-settings, etc.)
```

---

## Auto-Detection Behaviors (Undocumented)

The script currently performs these actions **automatically** without requiring flags:

```
XCODE MCP AUTO-DETECTION:
    When: Script detects Package.swift, *.xcworkspace, or *.xcodeproj
    Action: Prompts user to install Xcode MCP server configuration
    Files affected:
        - Most recent *.code-workspace file (merged)
        - .vscode/mcp.json (created/merged)
    
    Problem: Happens even when user didn't request it
    Solution: Should only trigger with --prompt workspace:mcp:xcode-mcpserver
              or via menu when using --prompt workspace:mcp

INSTRUCTION FILE MENU:
    When: No instruction files exist in destination
    Action: Always shows menu (gates with has_instructions_to_install check)
    
    Problem: Menu skip logic conflicts with --prompt flag
    Solution: Should show menu when --prompt instructions used,
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
    --prompt folder[<name>]:<category>[:<theme>]
    
    Examples:
        --prompt folder[]:settings              # All folders, settings category
        --prompt folder[scripts]:settings       # "scripts" folder only
        --prompt folder[src]:settings:swift     # "src" folder, swift theme

WILDCARDS/PATTERNS (FUTURE):
    --prompt user:settings:mark*               # All themes starting with "mark"
    --prompt workspace:mcp:*-mcpserver         # All MCP server themes
    --prompt user:*:swift                      # Swift configs across all categories
```

---

## Workflow Examples

### Setup New Swift Project
```zsh
# Install instructions + Swift configs + Xcode MCP + dev environment
configure_ai_instructions.zsh \\
    --no-prompt instructions \\
    --no-prompt user:settings:swift \\
    --no-prompt workspace:settings:swift \\
    --no-prompt workspace:mcp:xcode-mcpserver \\
    --no-prompt folder:settings:swift \\
    --dev-link \\
    --dev-vscode
```

### Interactive Selection (Current Repo State)
```zsh
# Let user choose what to install via menus
configure_ai_instructions.zsh \\
    --prompt user \\
    --prompt workspace \\
    --prompt folder \\
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
    --no-prompt user:settings:swift \\
    --no-prompt user:mcp:atlassian \\
    --prompt workspace              # Menu for workspace configs
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

1. **Multiple specifications**: Should `--prompt user:settings workspace:mcp` work, or require separate flags?
2. **Default behavior**: What happens when script runs with no args at all?
3. **Conflict resolution**: What if `--prompt` and `--no-prompt` both specify same config?
4. **Validation**: Should script validate scope:category:theme against available files?
5. **Discovery**: How does user know what themes are available? Add `--list` flag?

---

## Suggested Additional Flags

```
DISCOVERY:
    --list-scopes                  Show available scopes
    --list-categories [SCOPE]      Show categories for scope
    --list-themes [SCOPE[:CATEGORY]]
                                   Show available themes
    
    Examples:
        --list-themes user:settings
        --list-themes workspace
        --list-themes

VALIDATION:
    --dry-run <spec>               Show what would be installed without doing it
    --validate                     Check all template files for syntax errors

CLEANUP:
    --unlink <spec>                Remove previously installed configs
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
