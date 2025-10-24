````instructions
---
applyTo:
  - "**/*.md"
---

# Markdown Documentation Conventions

**Applies to**: All markdown files (`**/*.md`) in this repository

## Overview

These conventions ensure consistent formatting, branding, and readability across all markdown documentation. They apply to all `.md` files, including README.md, documentation files, and guides.

## Icon Usage for Apps, Companies, and Hardware Vendors

### Icon Preparation Requirements

When adding icons for apps, companies, or hardware vendors mentioned in markdown documentation:

1. **Icon Acquisition**:
   - Download the app icon, company logo, or hardware vendor logo to a temporary location
   - Prefer 1:1 aspect ratio (square) images
   - Prefer transparent background (PNG format)

2. **Icon Processing**:
   - Resize to emoji size (approximately 16x16 to 32x32 pixels for inline use)
   - Add corner rounding if possible (to match emoji aesthetic)
   - Save final images to `docs/images/icons/`
   - Use `snake_case.png` for filenames (e.g., `xcode.png`, `mac_stadium.png`, `github_actions.png`)

3. **Icon Location**:
   - All icons must be stored in: `docs/images/icons/`
   - Use relative paths when referencing icons in markdown

### Icon Usage in Markdown

**CRITICAL**: When mentioning apps, companies, or hardware vendors in markdown:

1. **Prefix with icon**: Add the relevant icon before the name
2. **Format name with backticks**: Use code-style formatting for the name

**Format**:
```markdown
![icon](docs/images/icons/icon_name.png) `App Name`
```

**Examples**:

✅ **Good:**
```markdown
- Install ![xcode](docs/images/icons/xcode.png) `Xcode` using the xcodes CLI tool
- Configure ![github](docs/images/icons/github.png) `GitHub Actions` runner
- Provision hardware from ![macstadium](docs/images/icons/mac_stadium.png) `MacStadium`
- Building the ![hatch](docs/images/icons/hatch.png) `Hatch Sleep` iOS app
- Use ![homebrew](docs/images/icons/homebrew.png) `Homebrew` to install packages
```

❌ **Bad:**
```markdown
- Install Xcode using the xcodes CLI tool              # Missing icon and backticks
- Configure GitHub Actions runner                      # Missing icon and backticks
- Provision hardware from MacStadium                   # Missing icon and backticks
```

### Common Entities Requiring Icons

Create and use icons for these entities when mentioned in documentation:

**Development Tools**:
- ![xcode](docs/images/icons/xcode.png) `Xcode`
- ![homebrew](docs/images/icons/homebrew.png) `Homebrew`
- ![fastlane](docs/images/icons/fastlane.png) `Fastlane`
- ![ruby](docs/images/icons/ruby.png) `Ruby`
- ![github](docs/images/icons/github.png) `GitHub`
- ![github_actions](docs/images/icons/github_actions.png) `GitHub Actions`

**Operating Systems & Platforms**:
- ![macos](docs/images/icons/macos.png) `macOS`
- ![ios](docs/images/icons/ios.png) `iOS`
- ![apple](docs/images/icons/apple.png) `Apple`

**Companies & Services**:
- ![hatch](docs/images/icons/hatch.png) `Hatch`
- ![mac_stadium](docs/images/icons/mac_stadium.png) `MacStadium`

**Note**: This is not an exhaustive list. Add icons for any app, company, or hardware vendor mentioned in your documentation.

## Code Formatting with Backticks

### App and Tool Names

Always format app, tool, company, and hardware vendor names with backticks (code style):

✅ **Good:**
```markdown
- Use `Xcode` to build the project
- Install `Homebrew` packages
- Configure `GitHub Actions` runner
- Deploy to `MacStadium` infrastructure
```

❌ **Bad:**
```markdown
- Use Xcode to build the project                       # Missing backticks
- Install Homebrew packages                            # Missing backticks
```

### Semantic Version Numbers

Always format semantic version numbers with backticks (code style):

✅ **Good:**
```markdown
- Requires macOS `12.7` or later
- Install Xcode `15.0`
- Using Ruby version `3.2.0`
- Homebrew `4.0.0` or higher
```

❌ **Bad:**
```markdown
- Requires macOS 12.7 or later                         # Missing backticks
- Install Xcode 15.0                                   # Missing backticks
- Using Ruby version 3.2.0                             # Missing backticks
```

### Command-Line Commands

Use fenced code blocks with language identifiers for commands:

✅ **Good:**
````markdown
```zsh
./scripts/setup.zsh --action apple-dev
```
````

✅ **Also Good (for inline short commands):**
```markdown
Run `./scripts/setup.zsh --action apple-dev` to start setup
```

### File Paths

Format file paths with backticks for inline references:

✅ **Good:**
```markdown
See `docs/install/INSTALL.md` for installation instructions
Edit the configuration in `scripts/config/setup.config`
```

## Hotkey Markup

When documenting keyboard shortcuts, use the HTML `<kbd>` tag for visual emphasis:

✅ **Good:**
```markdown
Press <kbd>Cmd</kbd> + <kbd>C</kbd> to copy
Use <kbd>Cmd</kbd> + <kbd>V</kbd> to paste
Toggle full screen with <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd>
```

❌ **Bad:**
```markdown
Press Cmd+C to copy                                    # No visual emphasis
Use Cmd-V to paste                                     # No visual emphasis
```

## Admonitions

Use GitHub-flavored Markdown admonitions for important callouts:

### Note Admonition

```markdown
> [!NOTE]
> This is a note with additional context or clarification.
```

### Tip Admonition

```markdown
> [!TIP]
> This is a helpful tip or best practice.
```

### Important Admonition

```markdown
> [!IMPORTANT]
> This is critical information that users must pay attention to.
```

### Warning Admonition

```markdown
> [!WARNING]
> This is a warning about potential issues or risks.
```

### Caution Admonition

```markdown
> [!CAUTION]
> This is a strong warning about dangerous operations.
```

**Examples:**

✅ **Good:**
```markdown
> [!NOTE]
> The `iosdeveloper` account is created automatically during setup.

> [!IMPORTANT]
> Passwords are passed via environment variables and are **not** logged to stdout/stderr.

> [!WARNING]
> Disabling Gatekeeper reduces system security. Only use on isolated CI networks.
```

## Page Breaks

Use horizontal rules (`---`) to create visual page breaks between major sections:

✅ **Good:**
```markdown
# Section 1

Content for section 1...

---

# Section 2

Content for section 2...
```

## Table of Contents

Use [doctoc](https://github.com/thlorenz/doctoc) for automatic table of contents generation:

```markdown
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
<h1> Table of Contents -- </h1>

- [Section 1](#section-1)
- [Section 2](#section-2)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->
```

**Update TOC** after making structural changes:
```zsh
npx doctoc <file.md>
```

## Links

### Internal Links

Use relative paths for internal documentation links:

✅ **Good:**
```markdown
See [Installation Guide](docs/install/INSTALL.md) for details
Refer to [Contributing Guidelines](docs/CONTRIBUTING.md)
```

### External Links

Use descriptive link text with URLs:

✅ **Good:**
```markdown
- **[GitHub Actions: Self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)** - Official documentation
- **[Homebrew](https://brew.sh/)** - Package manager for macOS
```

❌ **Bad:**
```markdown
See https://docs.github.com/en/actions/hosting-your-own-runners    # No descriptive text
Click [here](https://brew.sh/)                                      # Generic link text
```

## Code Blocks

Always specify language for syntax highlighting:

✅ **Good:**
````markdown
```zsh
export IOSDEVELOPER_SHORTNAME='iosdeveloper'
./scripts/setup.zsh --action apple-dev
```
````

````markdown
```json
{
  "name": "value"
}
```
````

❌ **Bad:**
````markdown
```
export IOSDEVELOPER_SHORTNAME='iosdeveloper'
```
````

## Lists

### Unordered Lists

Use `-` for bullet points (consistent with existing markdown):

✅ **Good:**
```markdown
- Item 1
- Item 2
  - Nested item 2.1
  - Nested item 2.2
- Item 3
```

### Ordered Lists

Use `1.` for all items (auto-numbering):

✅ **Good:**
```markdown
1. First step
1. Second step
1. Third step
```

## Summary Checklist

When writing or reviewing markdown documentation, verify:

- [ ] App/company/vendor names prefixed with icons from `docs/images/icons/`
- [ ] App/company/vendor names formatted with backticks
- [ ] Version numbers formatted with backticks
- [ ] Hotkeys use `<kbd>` tags
- [ ] Admonitions used for important callouts
- [ ] Page breaks (`---`) between major sections
- [ ] Table of contents generated with doctoc
- [ ] Code blocks specify language
- [ ] Internal links use relative paths
- [ ] External links have descriptive text

````
