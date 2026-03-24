---
description: Scan workspace for large directories and files that may bog down VSCode, compare against exclusion settings, and present actionable findings
argument-hint: Optional workspace path (defaults to current workspace root)
---

# Workspace Size Scanner

Scan the current workspace for directories that are excessively large (by size or file count) and could cause VSCode performance problems (CPU spikes from indexing, file watching, search). Compare findings against VSCode exclusion settings and report what needs attention.

---

## Step 1: Temperature Check

Run a quick size check on the workspace root:

```zsh
du -s -k . 2>/dev/null | awk '{print $1}'
```

- If the result is **less than 102400** (under 100MB): report "Workspace is under 100MB — no size concerns detected" and **stop here**.
- If the result is **102400 or more**: continue to Step 2.

---

## Step 2: Find Large Directories by Size

Scan top-down with a depth limit of 5 levels. Report directories **>= 500MB**:

```zsh
du -k -d 5 . 2>/dev/null | awk '$1 >= 512000' | sort -rn
```

Record each result: directory path and size in MB (divide KB value by 1024).

---

## Step 3: Find Directories with Many Files

Scan top-down with a depth limit of 5 levels. Report directories with **>= 1000 files**:

```zsh
find . -maxdepth 5 -type f 2>/dev/null | awk -F/ '{OFS="/"; NF--; print}' | sort | uniq -c | sort -rn | awk '$1 >= 1000'
```

Record each result: directory path and file count.

---

## Step 4: Load VSCode Exclusion Settings

Read the exclusion patterns from these VSCode settings keys:
- `files.watcherExclude`
- `search.exclude`
- `files.exclude`

Load from **all three scopes** (files are JSONC — strip `//` and `/* */` comments before parsing):

| Scope | File Path |
|-------|-----------|
| User | `~/Library/Application Support/Code/User/settings.json` |
| Workspace | `*.code-workspace` files in the workspace root |
| Folder | `.vscode/settings.json` in the workspace root |

Collect all glob patterns where the value is `true`.

---

## Step 5: Classify Each Violation

For each violation found in Steps 2 and 3:

1. Check if the violation's path matches **any** exclusion glob pattern from Step 4.
2. Classify as:
   - **FYI** — the path matches at least one exclusion pattern (it's already handled)
   - **Alert** — the path does NOT match any exclusion pattern (it needs attention)

---

## Step 6: Report Results

### FYI Items

For each FYI violation, print an informational line. No action needed:

> FYI: Found `node_modules/` with 15,234 files (excluded in user settings via `files.watcherExclude: **/node_modules/**`)

> FYI: Found `.build/` at 3.1 GB (excluded in workspace settings via `search.exclude: **/.build/**`)

### Alert Items

For each Alert violation, present the user with an interactive choice. Include the violation details (path, size or file count, which thresholds were exceeded).

**Choices to offer for each alert:**

1. **Delete** — Remove the directory/file
2. **Exclude from VSCode settings** — Add an exclusion pattern (ask which scope: user / workspace / folder, and which settings keys: `files.watcherExclude`, `search.exclude`, `files.exclude`)
3. **Diagnose** — Inspect the directory contents to understand what is large and why
4. **Ignore** — Take no action right now

The user should also be able to type a custom response explaining what they want done.

---

## Example Output

```
Temperature check: workspace is 2.4 GB — scanning...

FYI: Found node_modules/ with 18,421 files (excluded in user settings via files.watcherExclude)
FYI: Found .build/ at 1.8 GB (excluded in user settings via search.exclude)
FYI: Found DerivedData/ at 892 MB (excluded in user settings via files.exclude)

Alert: Found logs/ at 23 GB — not covered by any VSCode exclusion setting.
  What would you like to do?
  1. Delete logs/
  2. Exclude from VSCode settings (choose scope)
  3. Diagnose — inspect what's inside
  4. Ignore

Alert: Found vendor/cache/ with 4,200 files — not covered by any VSCode exclusion setting.
  What would you like to do?
  1. Delete vendor/cache/
  2. Exclude from VSCode settings (choose scope)
  3. Diagnose — inspect what's inside
  4. Ignore
```
