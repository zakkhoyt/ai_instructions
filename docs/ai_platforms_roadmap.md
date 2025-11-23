# AI Platforms Roadmap

This document outlines the multi-platform support strategy for the ai_instructions repository.

## Overview

The `ai_platforms/` directory contains platform-specific templates and configuration files for different AI coding assistants. The goal is to provide a unified workflow for installing coding conventions and instructions across multiple AI platforms.

## Directory Structure

```
ai_platforms/
├── copilot/         # GitHub Copilot (IMPLEMENTED ✅)
│   ├── instructions/
│   │   ├── agent/
│   │   ├── git/
│   │   ├── markdown/
│   │   ├── python/
│   │   ├── swift/
│   │   ├── userscript/
│   │   └── zsh/
│   └── copilot-instructions.template.md
├── claude/          # Claude AI (TODO 📋)
│   ├── .claude/
│   │   └── settings.template.json
│   └── CLAUDE.template.md
├── cursor/          # Cursor IDE (TODO 📋)
│   └── .cursor/
│       └── rules/
│           └── mobile.template.mdc
└── coderabbit/      # CodeRabbit (TODO 📋)
    └── .coderabbit.template.yaml
```

## Platform Status

### ✅ GitHub Copilot (IMPLEMENTED)

**Status:** Fully implemented with template synthesis

**Files Generated:**
- `.github/copilot-instructions.md` - Main instruction file with auto-generated content
- `.github/instructions/*.instructions.md` - Individual instruction files (symlinked or copied)

**Features:**
- Template-based synthesis with project analysis
- Auto-detection of languages, frameworks, and build tools
- Auto-generated instruction file list with markdown links
- User-editable sections preserved during updates
- `--regenerate-main` flag for full regeneration

**Template Markers:**
```markdown
<!-- AI_INSTRUCTIONS_PROJECT_ANALYSIS_START -->
**Detected Languages:** Swift, Python, TypeScript
**Detected Frameworks:** Swift Package Manager, Node.js/npm
**Build Tools:** Make, GitHub Actions
<!-- AI_INSTRUCTIONS_PROJECT_ANALYSIS_END -->

<!-- AI_INSTRUCTIONS_REGENERATE_START -->
- [Swift Conventions](.github/instructions/swift-conventions.instructions.md)
- [Python Conventions](.github/instructions/python-conventions.instructions.md)
<!-- AI_INSTRUCTIONS_REGENERATE_END -->
```

**Installation:**
```zsh
~/.ai/scripts/configure_ai_instructions.zsh --ai-platform copilot
```

---

### 📋 Claude AI (TODO)

**Status:** Placeholder templates created, implementation pending

**Expected Files:**
- `.claude/settings.json` - Claude configuration (references CLAUDE.md)
- `CLAUDE.md` - Main instruction file

**Research Needed:**
- [ ] How does Claude discover and load instruction files?
- [ ] Does Claude support multiple instruction files or only a single file?
- [ ] What is the format for `.claude/settings.json`?
- [ ] Can Claude reference external files like Copilot does?

**Proposed Approach:**

**Option A: Single File (Most Likely)**
- Synthesize all instructions into a single `CLAUDE.md` file
- Concatenate content from all `*.instructions.md` files
- Include project analysis section
- No separate instruction files needed

**Option B: Multiple Files via References**
- If Claude supports file references, use the same structure as Copilot
- Copy/symlink individual instruction files to a claude-specific directory
- Reference them from `CLAUDE.md`

**Implementation Tasks:**
1. Research Claude's instruction file discovery mechanism
2. Create template with proper Claude-specific formatting
3. Add synthesis logic to `configure_ai_instructions.zsh`
4. Test with real Claude projects

---

### 📋 Cursor IDE (TODO)

**Status:** Placeholder template created, implementation pending

**Expected Files:**
- `.cursor/rules/mobile.mdc` - Main rules file (markdown format)

**Research Needed:**
- [ ] What is the `.mdc` file format? (Looks like markdown)
- [ ] Does Cursor support multiple rule files or just one?
- [ ] Can rule files reference other files?
- [ ] Is there a specific schema or structure required?

**Proposed Approach:**

Similar to Claude, likely a single-file model:
- Synthesize all instructions into `mobile.mdc`
- Use markdown format with Cursor-specific sections
- Include project analysis
- Concatenate all instruction file content

**Implementation Tasks:**
1. Research Cursor's rules file format and capabilities
2. Determine if multiple files are supported
3. Create template with Cursor-specific formatting
4. Add synthesis logic to `configure_ai_instructions.zsh`
5. Test with real Cursor projects

---

### 📋 CodeRabbit (TODO)

**Status:** Placeholder template created, implementation pending

**Expected Files:**
- `.coderabbit.yaml` - Main configuration file (YAML format)

**Research Needed:**
- [ ] How does CodeRabbit use the YAML configuration?
- [ ] Can it reference external instruction files?
- [ ] What sections should be included for coding conventions?
- [ ] Are there hooks or custom rule sections?

**Proposed Approach:**

CodeRabbit uses YAML configuration, which is fundamentally different from markdown instruction files:

**Option A: Embed Instructions in YAML**
- Add a `custom_instructions` or similar section to `.coderabbit.yaml`
- Serialize instruction content as YAML strings
- May have character/length limits

**Option B: Reference External Files**
- If CodeRabbit supports external file references
- Keep instruction files separate and reference them
- Similar to Copilot's multi-file approach

**Example YAML Structure (hypothetical):**
```yaml
language: "en-US"
reviews:
  profile: "chill"
  custom_instructions:
    - path: ".github/instructions/swift-conventions.instructions.md"
    - path: ".github/instructions/python-conventions.instructions.md"
chat:
  auto_reply: true
```

**Implementation Tasks:**
1. Research CodeRabbit's configuration schema thoroughly
2. Determine if external file references are supported
3. Create YAML template with proper structure
4. Add YAML-specific synthesis logic to `configure_ai_instructions.zsh`
5. Test with real CodeRabbit projects

---

## Common Implementation Pattern

All platforms will follow this general workflow in `configure_ai_instructions.zsh`:

1. **Check platform:** `if [[ "$ai_platform" == "platform_name" ]]; then`
2. **Call synthesis function:** `synthesize_platform_instructions`
3. **Within synthesis function:**
   - Load template from `ai_platforms/platform_name/`
   - Analyze target project (languages, frameworks, tools)
   - Populate template with analysis results
   - Generate list of installed instruction files
   - Handle update vs regenerate logic
   - Prompt user if file exists and `--regenerate-main` not passed

## Instruction File Handling

### Copilot (Multi-File Model)
- Individual instruction files installed to `.github/instructions/`
- Main file (`copilot-instructions.md`) references them with relative links
- Files can be symlinked or copied
- Each file maintains its own identity

### Claude/Cursor (Single-File Model - Likely)
- Individual instruction files concatenated into single file
- Main file contains all instruction content inline
- Section headers derived from filename
- No separate instruction files in target project

### CodeRabbit (Configuration-Based - TBD)
- May use YAML references to external files
- Or embed instructions in YAML strings
- Requires thorough research

## Testing Strategy

For each platform:

1. **Create test project** with that platform configured
2. **Run configure script** with `--ai-platform platform_name`
3. **Verify files created** in expected locations
4. **Test AI platform** recognizes and uses the instructions
5. **Test update workflow** (modify instruction, re-run script)
6. **Test regenerate workflow** (`--regenerate-main` flag)

## Future Enhancements

- [ ] **Platform auto-detection**: Detect which AI platform is in use and default to it
- [ ] **Multi-platform projects**: Support installing for multiple platforms simultaneously
- [ ] **Instruction file validation**: Lint/validate instruction files before installation
- [ ] **Version tracking**: Track which version of instruction files are installed
- [ ] **Diff/merge support**: Show diffs when updating instructions in copy mode

## Contributing

When adding support for a new platform:

1. Create directory structure in `ai_platforms/new_platform/`
2. Add template files with proper naming
3. Implement `synthesize_new_platform_instructions()` function
4. Add platform to `get_platform_paths()` function
5. Update this roadmap document
6. Add tests for the new platform
7. Update main README.md with new platform support

---

*This roadmap is a living document. As we research and implement support for additional platforms, we'll update it with findings and implementation details.*
