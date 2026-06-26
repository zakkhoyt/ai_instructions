---
name: write-markdown
description: "Write and format markdown files with strict conventions for research-backed content, inline footnote citations, icons, code formatting, tables, admonitions, links, images, and hotkeys. ALWAYS use this skill when creating or editing any *.md file, writing markdown documentation, producing research-backed deliverables, or formatting chat responses the user will copy to markdown notes. Also trigger when the user mentions markdown conventions, documentation formatting, citations, footnotes, or requests any markdown deliverable — even if they don't explicitly say 'markdown'."
---

# Write Markdown

This skill defines mandatory conventions for writing markdown files. Every rule here applies 100% of the time — no exceptions unless the user explicitly overrides.

The user maintains detailed notes in markdown files and frequently copies information from chat into these notes. All output must be formatted as markdown source code that can be pasted directly.

## Quick Compliance Checklist

Before writing or editing ANY markdown content, verify:

- Research every claim against primary official sources only — personal notes files are NOT acceptable factual references
- Cite every factual claim with a GitHub footnote `[^N]` — a references block alone is NEVER sufficient
- State uncertainty instead of guessing — never fabricate UI labels, features, or workflows
- Use markdown source format in chat responses (raw syntax, not rendered)
- Use fenced code blocks with language identifiers (never bare triple-backticks)
- Prefer long-form CLI arguments; annotate unavoidable short flags with `# -x: description` comments
- Format app/tool/company names in backticks: `Xcode`, `Homebrew`, `GitHub Actions`
- Format version numbers in backticks: macOS `15.0`, Ruby `3.2.0`
- Use `<kbd>` tags for keyboard shortcuts: <kbd>Cmd</kbd> + <kbd>C</kbd>
- Use HTML `<img>` tags for images (never `![]()`), always specify `width` or `height`
- Prefix app/company/tool names with inline icons (`<img ... height="16">`) from `docs/images/icons/` — see `references/icons-and-images.md`
- Use GFM admonitions (`> [!NOTE]`, `> [!WARNING]`, etc.)
- No bare URLs — always `[descriptive text](url)`
- Tables MUST be rectangular: pad all cells to column max width
- Lean into nested header sections over bold/italic headers
- Lean into nested lists for structured information

---

## Research-Backed Writing (Non-Negotiable)

These expectations apply to every markdown deliverable. Violations waste the user's time and break trust.

### Acceptable Source Hierarchy

1. **Official vendor documentation** (Apple Support, man pages, product docs) — primary source
2. **Official release notes and changelogs** — primary source for version-specific claims
3. **Reputable third-party references** (Stack Overflow accepted answers, established tech publications) — secondary; always note uncertainty
4. **User's personal notes** (`~/Documents/notes/**/*`, `~/.zsh_home/docs/**/*`, similar paths) — **NOT an acceptable factual source**. These files may contain errors and are often the notes that AI is being asked to supplement. They CAN be used as pointers to official URLs or as sources for file paths and code examples, but claims must be independently verified against official sources.

### Required Workflow

1. **Clarify scope**: Restate the question, target file, platforms, and constraints so gaps surface before writing
2. **Collect sources**: Gather official documentation, release notes, or vendor KBs that directly cover the requested behavior; save URLs for citation
3. **Fact-check line-by-line**: For each paragraph and table cell, confirm UI labels, feature availability, and limitations against collected sources
4. **Cite with footnotes**: Add a `[^N]` footnote after every factual claim; define all footnotes at the end of the document
5. **Highlight open issues**: If research exposes conflicting info or missing functionality, add an explicit "Unknowns" or "Needs Confirmation" section instead of speculating
6. **Summarize verification**: In the chat response accompanying the file, briefly mention which sources were consulted

### Acceptable vs Unacceptable

- ✅ Acceptable: "Apple does not expose a manual `Sync Now` control in Photos preferences; edits propagate automatically once both devices are online.[^1]" where `[^1]` links to the Apple Support article.
- ❌ Unacceptable: "Click the Photos `Sync Now` button on macOS to force updates" — fabricated UI element, no citation.
- ❌ Unacceptable: A `## References` section at the bottom with zero `[^N]` anchors in the document body — the reader cannot tell which link supports which claim.
- ❌ Unacceptable: Skimming unrelated blog posts or copy-pasting outdated lore without verification — this is lazy research and a violation of the research requirement.
- ❌ Unacceptable: Writing UI labels, toggles, or workflows for a specific OS/app version without confirming they actually exist in that exact version.

### Quick Check Before Submitting

- Every factual sentence and table cell has a `[^N]` footnote
- All footnote definitions appear at the end of the document
- Citations use `[text](url)` syntax inside footnote definitions — no bare URLs
- Uncertain areas are called out explicitly instead of filled with guesses
- The accompanying chat summary explains the verification effort

---

## Citations and Footnotes (Mandatory)

Use GitHub Flavored Markdown footnote syntax for every factual claim.

### Syntax

Inline reference — place immediately after the claim, before any punctuation:

```markdown
iTerm2 stores passwords in the macOS `login` keychain as generic password items.[^1]
```

Footnote definition — collect all definitions at the bottom of the document under a `## References` section:

```markdown
## References

[^1]: [iTerm2 Password Manager — iterm2.com](https://iterm2.com/features.html)
[^2]: [security(1) man page — ss64.com](https://ss64.com/mac/security.html)
```

### Rules

- **Every factual claim** in body text, table cells, and list items must have at least one `[^N]`
- **Footnote numbers are sequential** starting at `[^1]`
- **Footnote definitions live at the end** of the document, under `## References`
- **A references block alone is NOT sufficient** — if a fact has no corresponding inline `[^N]`, the citation is effectively missing
- **Personal notes files are not acceptable** as `[^N]` sources (see Source Hierarchy above)
- When a claim genuinely cannot be confirmed, write "Needs Confirmation" and omit the footnote rather than citing an unreliable source

### Table Cells

Every table cell that states a fact must have a footnote. Put the `[^N]` inside the cell:

```markdown
| `iTerm.app` field | `security` flag | Notes                          |
| ----------------- | --------------- | ------------------------------ |
| Account           | `-l <label>`    | The entry name shown in iTerm[^1] |
| Username          | `-a <account>`  | The credential username[^1]    |
```

---

## CLI Command Arguments

When documenting CLI commands in markdown:

### Prefer Long-Form Arguments

Use long-form arguments whenever the tool supports them:

```zsh
# Good — long-form is self-documenting
git commit --message "fix: correct typo" --no-verify
```

```zsh
# Avoid — short flags require reader to know the tool
git commit -m "fix: correct typo" -n
```

### Annotate Unavoidable Short Flags

When a CLI tool only exposes short flags (e.g., the macOS `security` command), add a comment block immediately above the invocation explaining every flag used:

```zsh
# -l: label     — entry name shown in iTerm.app's Password Manager (the "Account" field)
# -a: account   — credential username (the "Username" field)
# -s: service   — must be exactly "iTerm2" for the entry to appear in iTerm
# -T: trusted   — application allowed to access this item without prompting
# -w: password  — omit value to be prompted securely instead of passing on command line
security add-generic-password \
  -l "my-account" \
  -a "my-username" \
  -s "iTerm2" \
  -T "/Applications/iTerm.app" \
  -w
```

This rule comes from the `zsh` coding conventions and applies equally to CLI examples documented in markdown.

---

## Chat Response Formatting

The user copies chat responses directly into markdown notes. Format all responses as markdown source code.

### Markdown Source Format

Present information as raw markdown syntax, not rendered markdown:

````markdown
## Heading

This is **bold text** and this is *italic text*.

- List item 1
- List item 2

[Link text](https://example.com)

```code
example
```
````

### Reference Links (Always Include)

Include reference links when citing documentation, external resources, or related topics:

```markdown
**References:**
- [Primary Documentation](https://example.com/docs)
- [Tutorial](https://example.com/tutorial)
- [Stack Overflow Discussion](https://stackoverflow.com/questions/12345)
```

### Code in Chat

Use fenced code blocks with language identifiers for all code examples:

````markdown
```zsh
echo "Hello World"
```
````

For inline code references, use single backticks: Use the `grep` command to search files.

### URLs in Chat

Always use markdown link syntax with descriptive text:

```markdown
[GitHub Documentation](https://docs.github.com)
```

Never use bare URLs like `https://docs.github.com`.

---

## Code Formatting with Backticks

### App and Tool Names

Always format app, tool, company, and hardware vendor names with backticks:

```markdown
- Use `Xcode` to build the project
- Install `Homebrew` packages
- Configure `GitHub Actions` runner
```

### Semantic Version Numbers

Always format version numbers with backticks:

```markdown
- Requires macOS `12.7` or later
- Install Xcode `15.0`
- Using Ruby version `3.2.0`
```

### File Paths

Format file paths with backticks for inline references:

```markdown
See `docs/install/INSTALL.md` for installation instructions
```

---

## Code Blocks

Always specify a language identifier for syntax highlighting:

````markdown
```zsh
export IOSDEVELOPER_SHORTNAME='iosdeveloper'
```
````

````markdown
```json
{
  "name": "value"
}
```
````

Never use bare triple-backticks without a language identifier.

Common identifiers: `bash`, `zsh`, `python`, `swift`, `javascript`, `json`, `markdown`, `yaml`, `html`, `css`.

---

## Hotkey Markup

Use HTML `<kbd>` tags for keyboard shortcuts:

```markdown
Press <kbd>Cmd</kbd> + <kbd>C</kbd> to copy
Use <kbd>Cmd</kbd> + <kbd>V</kbd> to paste
Toggle full screen with <kbd>Cmd</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd>
```

Never write keyboard shortcuts as plain text like "Cmd+C" or "Ctrl-V".

---

## Admonitions

Use GitHub-flavored Markdown admonitions for important callouts:

```markdown
> [!NOTE]
> Additional context or clarification.

> [!TIP]
> Helpful tip or best practice.

> [!IMPORTANT]
> Critical information users must pay attention to.

> [!WARNING]
> Potential issues or risks.

> [!CAUTION]
> Strong warning about dangerous operations.
```

---

## Links

### Internal Links

Use relative paths for links within the same repository:

```markdown
See [Installation Guide](docs/install/INSTALL.md) for details
```

### External Links

Use descriptive link text — never "click here" or bare URLs:

```markdown
- [GitHub Actions: Self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Homebrew](https://brew.sh/) - Package manager for macOS
```

---

## Images

Use HTML `<img>` tags for every image. Markdown image syntax (`![alt](src)`) is not allowed.

- Always include a `width` attribute; default to `width="300"` unless a different value is required
- Do not set a `height` attribute (let the browser preserve aspect ratio)
- Derive `alt` from the final path component of `src`, converted to `snake_case`

```html
<img src="images/myTruck.png" alt="my_truck" width="300">
```

For icon and banner conventions (inline icons, standalone banners, acquisition workflow, naming), read `references/icons-and-images.md`.

---

## Lists

### Unordered Lists

Use `-` for bullet points:

```markdown
- Item 1
- Item 2
  - Nested item 2.1
  - Nested item 2.2
```

### Ordered Lists

Use `1.` for all items (auto-numbering):

```markdown
1. First step
1. Second step
1. Third step
```

---

## Page Breaks and Table of Contents

Use horizontal rules (`---`) between major sections.

Use [doctoc](https://github.com/thlorenz/doctoc) for automatic TOC generation:

```markdown
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
```

Update TOC after structural changes: `npx doctoc <file.md>`

---

## Table Formatting (MANDATORY)

Rectangular table formatting is mandatory. This rule applies 100% of the time to ALL markdown tables.

### Requirements

1. Calculate the maximum width for each column
2. Pad ALL cells to match their column's maximum width using single spaces
3. Align separators (pipes) vertically
4. Every row MUST have identical character width
5. Every line MUST end at the same column number with ` |`

### Example

```markdown
| Logic Pro Command   | Logic Shortcut   | REAPER Command                     | REAPER Shortcut               |
| ------------------- | ---------------- | ---------------------------------- | ----------------------------- |
| Show Smart Tempo    | Track menu       | Create Measure from Time Selection | Alt+Shift+C                   |
| Enable Flex         | Cmd+F            | Add Stretch Marker                 | Shift+W                       |
| Split at Cursor     | Cmd+T            | Split at Cursor                    | S                             |
```

"Jagged" tables where rows have different character counts are FORBIDDEN, even if the rendered HTML looks fine.

For extended examples and anti-patterns, read `references/table-formatting.md`.

---

## Summary Checklist

Before submitting any markdown file or chat response:

- [ ] Every factual claim has a `[^N]` footnote — not just a references section
- [ ] Footnote definitions appear at end of document under `## References`
- [ ] Citations use `[text](url)` syntax inside footnotes — no bare URLs
- [ ] Only official/reputable sources cited — personal notes files are NOT factual references
- [ ] Uncertain areas are called out explicitly, not filled with guesses
- [ ] CLI examples use long-form args; unavoidable short flags have `# -x: description` comment blocks
- [ ] App/tool names and version numbers are in backticks
- [ ] App/company/vendor names have inline icon prefixes from `docs/images/icons/` when available
- [ ] Code blocks have language identifiers
- [ ] Keyboard shortcuts use `<kbd>` tags
- [ ] Images use HTML `<img>` tags with `width` attribute
- [ ] Page breaks (`---`) separate major sections
- [ ] Table of contents updated with `npx doctoc <file.md>` if structure changed
- [ ] Tables are rectangular with padded columns
- [ ] Internal links use relative paths
- [ ] External links use descriptive text — not "click here" and not bare URLs
- [ ] Admonitions use GFM `> [!TYPE]` syntax
