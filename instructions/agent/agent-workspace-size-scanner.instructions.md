---
applyTo: "**/*"
---

# Workspace Size Scanner — Automatic Check on Session Start

**IMPORTANT**: When starting work in any workspace, perform a quick workspace size check before diving into the task. Large directories and high file counts cause VSCode to spike CPU usage (indexing, file watching, search), degrading the experience for both the human and the agent.

---

## When to Run

- At the **start of every new chat session** or when switching workspaces
- The full procedure is defined in the `@workspace-size-scanner` prompt — invoke it or follow the steps below

---

## Quick Temperature Check

Run this first to decide if a full scan is warranted:

```zsh
du -s -k . 2>/dev/null | awk '{print $1}'
```

- If the result is **< 102400** (under 100MB): workspace is small, no scan needed. Proceed with the task.
- If the result is **>= 102400** (100MB or more): perform the full scan below.

---

## Full Scan Procedure

### 1. Find Large Directories by Size

Top-down, depth-limited to 5 levels. Report any directory >= 500MB:

```zsh
du -k -d 5 . 2>/dev/null | awk '$1 >= 512000' | sort -rn
```

### 2. Find Directories with Many Files

Top-down, depth-limited to 5 levels. Report any directory with >= 1000 files:

```zsh
find . -maxdepth 5 -type f 2>/dev/null | awk -F/ '{OFS="/"; NF--; print}' | sort | uniq -c | sort -rn | awk '$1 >= 1000'
```

### 3. Compare Against VSCode Exclusion Settings

Load exclusion patterns from `files.watcherExclude`, `search.exclude`, and `files.exclude` at all three VSCode scopes:

- **User settings**: `~/Library/Application Support/Code/User/settings.json`
- **Workspace settings**: any `*.code-workspace` file in the workspace root
- **Folder settings**: `.vscode/settings.json` in the workspace root

These files are JSONC (JSON with comments). Strip comments before parsing.

For each violation found in steps 1-2, check if the path matches any exclusion glob pattern from these settings.

### 4. Report Findings

Present results in two categories:

**FYI** (violation path is already covered by an exclusion pattern):
> FYI: Found `.build/` at 3.1 GB (excluded in user settings via `files.watcherExclude`)

No action needed — just inform the user so they know the exclusion is working.

**Alert** (violation path is NOT covered by any exclusion pattern):

Present each alert as an interactive choice for the user. Offer these options:

- **Delete** the directory/file
- **Exclude from VSCode settings** — and ask which scope: user, workspace, or folder
- **Diagnose** — inspect contents to understand what is large and why
- **Ignore** — no action needed

The user should also be able to type a custom response.

---

## References

- [VS Code `files.watcherExclude`](https://code.visualstudio.com/docs/getstarted/settings)
- [VS Code `search.exclude`](https://code.visualstudio.com/docs/getstarted/settings)
- [VS Code `files.exclude`](https://code.visualstudio.com/docs/getstarted/settings)
- [`@workspace-size-scanner` prompt](../prompts/workspace-size-scanner.prompt.md)
