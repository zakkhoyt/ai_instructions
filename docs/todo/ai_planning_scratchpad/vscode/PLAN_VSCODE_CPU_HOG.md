# VSCode CPU Diagnosis — Findings & Remediation Plan

## Diagnosis Summary

VSCode's `extension-host` process is consuming **220-1000%+ CPU sustained** for the `hatch.code-workspace`.

## Root Cause #1 (CRITICAL): Workspace `"path": "."` resolves to HOME directory via symlink

The workspace file is opened via a symlink chain:

```
~/hatch.code-workspace                                   (symlink)
  -> ~/_symlinks/_vscode_symlinks/hatch.code-workspace   (symlink)
    -> ~/Documents/HatchDocs/hatch.code-workspace        (actual file)
```

The workspace file contains `"path": "."`. VSCode resolves `"."` relative to the **first symlink** (`~/hatch.code-workspace`), so the workspace root becomes `/Users/zakkhoyt` -- **the entire HOME directory** (27,830+ files).

Evidence from `code --status`:

```
Folder (zakkhoyt): more than 27830 files
  File types: js(5533) ts(5037) md(1050) mjs(1005) map(951)
  Conf files: package.json(477)
```

This triggers three `rg` (ripgrep) processes at ~300% CPU each:
- `vscode.npm` searching for `**/package.json` across HOME (found 477)
- `github.copilot-chat` (x2) searching for `/.github/agents/*.md` across HOME

All three run with `--follow --no-ignore --no-config --no-ignore-global`, meaning they follow symlinks and ignore all gitignore rules.

## Root Cause #2: Todo Tree + Swift extension file scanning (when enabled)

V8 CPU profile (10s capture via Node.js inspector on port 51056) showed:

| Extension                              | CPU Share (of non-idle) | What It's Doing                                             |
| -------------------------------------- | ----------------------- | ----------------------------------------------------------- |
| `gruntfuggly.todo-tree` v0.0.226       | **47.8%**               | Scanning all files for TODO/FIXME patterns                  |
| `swiftlang.swift-vscode` v2.16.2       | **42.6%**               | Glob-matching every file against `Package.swift` patterns   |
| Everything else (Copilot, Codex, etc.) | **<1%**                 | Essentially idle                                            |

User has already disabled both extensions. Settings should still be configured for future re-enable.

### Additional Issues Found

1. **Extension host crashed** at 11:39 (exit code 5, "crashed") and auto-restarted
2. **GitHub Copilot Chat** throws `TypeError: e is not iterable` on every activation
3. **GitHub Actions extension** fails with `TypeError: Invalid URL` on every activation
4. **GitLens Launchpad** gets `502 Bad Gateway` from its pull request API calls

## Remediation Plan

### Fix 0 (CRITICAL): Change workspace paths from relative to absolute -- DONE

All `~/*.code-workspace` symlinks pointed to workspace files using `"path": "."` or relative `../` paths. VSCode resolves these relative to the symlink location (`~`), not the target, causing HOME directory scans.

**Fixed files** (all `"path"` entries converted to absolute paths):

| Workspace File                                                                  | Status |
| ------------------------------------------------------------------------------- | ------ |
| `/Users/zakkhoyt/Documents/HatchDocs/hatch.code-workspace`                     | DONE (user fixed) |
| `/Users/zakkhoyt/Documents/notes/notes.code-workspace`                          | DONE   |
| `/Users/zakkhoyt/.zsh_home/zsh_home.code-workspace`                            | DONE   |
| `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/scripts/scripts.code-workspace` | DONE   |

**Already OK** (no relative `"."` paths): `3DPrinting`, `blender`, `leonardo`, `lgtv`, `radio_control`

### Fix 1: Todo Tree -- add exclusion settings (extension disabled, configure for future re-enable)

Add to the `"settings"` block:

```json
"todo-tree.filtering.excludeGlobs": [
    "**/images/**",
    "**/screenshots/**",
    "**/videos/**",
    "**/assets/**",
    "**/*.png",
    "**/*.jpg",
    "**/*.gif",
    "**/*.pdf",
    "**/*.symbolsarchive",
    "**/*.pklg",
    "**/*.aiff",
    "**/*.zip"
],
"todo-tree.filtering.useBuiltInExcludes": "file and search excludes"
```

### Fix 2: Swift extension -- disable workspace scanning via `swift.disableAutoResolve`

Add to the `"settings"` block:

```json
"swift.disableAutoResolve": true
```

### Fix 3: GitHub Actions extension -- disable for this workspace

Crashes on every activation with `TypeError: Invalid URL`. Disable via Extensions sidebar: `@installed github actions` -> right-click -> `Disable (Workspace)`.

### Fix 4 (optional): GitLens Launchpad -- suppress failing API calls

```json
"gitlens.launchpad.indicator.enabled": false
```

## Verification

After applying fixes, run `code --status 2>&1 | cat` and confirm:
- `Folder` shows `HatchDocs` (not `zakkhoyt`)
- File count is ~2,632 (not 27,830+)
- Extension-host CPU drops to <5%
