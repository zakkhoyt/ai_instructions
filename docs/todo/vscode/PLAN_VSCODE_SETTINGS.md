# VS Code Settings.json Modification Plan - CORRECTED

**Target File:** `~/Library/Application Support/Code/User/settings.json`

**Goal:** Stop 1000% CPU usage by excluding large directories from VS Code indexing/watching/UI.

---

## CRITICAL CORRECTIONS

1. **Root .git patterns must use `.git/` not `**/.git/`**
   - `.git/objects/**` ✅ = Root workspace .git only
   - `**/.git/objects/**` ❌ = .git at ANY depth (wrong!)

2. **All 3 settings should be mostly identical** for maximum CPU reduction
   - files.exclude, search.exclude, files.watcherExclude should have same patterns
   - Exception: files.exclude uses 2-level visibility (`/*/*/**`) for build dirs

3. **search.exclude was missing .git and build patterns** - FIXED

---

## Pattern Rules

- `**/dirname/**` = Match at any depth, all contents
- `.git/dirname/**` = Match ONLY workspace root .git
- `**/*/.git/**` = Match nested .git (not root)
- `/*/*/**` = Show 2 levels, hide level 3+

---

## Common Patterns (ALL 3 Settings)

These appear in files.exclude, search.exclude, AND files.watcherExclude:

- `**/Library/Application Support/Code/User/workspaceStorage/**`
- `**/Library/Application Support/Code/User/globalStorage/**`
- `**/DerivedData/**`
- `**/node_modules/**`
- `**/*cache*/**`
- `**/__pycache__/**`
- `**/.venv/lib/**`
- `**/*/.git/**` (nested .git complete hide)

---

## Build Dirs (Different Per Setting)

**files.exclude** (2-level visibility):
- `**/.build/*/*/**`
- `**/build/*/*/**`
- `**/Build/*/*/**`
- `**/temp/*/*/**`
- `**/.docc-build/*/*/**`
- `**/*.doccarchive/*/*/**`
- `**/*.swiftpm/*/*/**`
- `**/Pods/*/*/**`
- `**/Carthage/*/*/**`
- `**/planning_references/*/**`

**search.exclude + files.watcherExclude** (full hide):
- `**/.build/**`
- `**/build/**`
- `**/Build/**`
- `**/temp/**`
- `**/.docc-build/**`
- `**/*.doccarchive/**`
- `**/*.swiftpm/**`
- `**/Pods/**`
- `**/Carthage/**`
- `**/planning_references/**`

---

## Root .git Selective (ALL 3 Settings)

Hide specific root .git subdirs (use `.git/` prefix - root only!):
- `.git/objects/**`
- `.git/refs/**`
- `.git/logs/**`
- `.git/index`
- `.git/packed-refs`
- `.git/FETCH_HEAD`
- `.git/ORIG_HEAD`
- `.git/HEAD`
- `.git/config`
- `.git/description`
- `.git/info/**`
- `.git/subtree-cache/**`

Show in root .git (NOT excluded):
- `.git/hooks/`
- `.git/ai/`
- `.git/gk/`

---

## Removed Exclusions

- `**/backup/**` - Now visible
- `**/.hatch/**` - Now visible
- `**/.venv/**` - Changed to `**/.venv/lib/**`

---

## FINAL JSON - files.exclude

```json
{
  "files.exclude": {
    "**/.scripts.bak/**": true,
    "**/*/.git/**": true,
    ".git/objects/**": true,
    ".git/refs/**": true,
    ".git/logs/**": true,
    ".git/index": true,
    ".git/packed-refs": true,
    ".git/FETCH_HEAD": true,
    ".git/ORIG_HEAD": true,
    ".git/HEAD": true,
    ".git/config": true,
    ".git/description": true,
    ".git/info/**": true,
    ".git/subtree-cache/**": true,
    "**/.build/*/*/**": true,
    "**/build/*/*/**": true,
    "**/Build/*/*/**": true,
    "**/temp/*/*/**": true,
    "**/.docc-build/*/*/**": true,
    "**/*.doccarchive/*/*/**": true,
    "**/*.swiftpm/*/*/**": true,
    "**/Pods/*/*/**": true,
    "**/Carthage/*/*/**": true,
    "**/planning_references/*/**": true,
    "**/DerivedData/**": true,
    "**/node_modules/**": true,
    "**/*cache*/**": true,
    "**/__pycache__/**": true,
    "**/.venv/lib/**": true,
    "**/Library/Application Support/Code/User/workspaceStorage/**": true,
    "**/Library/Application Support/Code/User/globalStorage/**": true
  }
}
```

---

## FINAL JSON - search.exclude

```json
{
  "search.exclude": {
    "**/*/.git/**": true,
    ".git/objects/**": true,
    ".git/refs/**": true,
    ".git/logs/**": true,
    ".git/index": true,
    ".git/packed-refs": true,
    ".git/FETCH_HEAD": true,
    ".git/ORIG_HEAD": true,
    ".git/HEAD": true,
    ".git/config": true,
    ".git/description": true,
    ".git/info/**": true,
    ".git/subtree-cache/**": true,
    "**/.build/**": true,
    "**/build/**": true,
    "**/Build/**": true,
    "**/temp/**": true,
    "**/.docc-build/**": true,
    "**/*.doccarchive/**": true,
    "**/*.swiftpm/**": true,
    "**/Pods/**": true,
    "**/Carthage/**": true,
    "**/planning_references/**": true,
    "**/DerivedData/**": true,
    "**/.venv/lib/**": true,
    "**/node_modules/**": true,
    "**/*cache*/**": true,
    "**/__pycache__/**": true,
    "**/bower_components": true,
    "**/Library/Application Support/Code/User/workspaceStorage/**": true,
    "**/Library/Application Support/Code/User/globalStorage/**": true
  }
}
```

---

## FINAL JSON - files.watcherExclude

```json
{
  "files.watcherExclude": {
    "**/Library/Application Support/Code/User/workspaceStorage/**": true,
    "**/Library/Application Support/Code/User/globalStorage/**": true,
    "**/*/.git/**": true,
    ".git/objects/**": true,
    ".git/refs/**": true,
    ".git/logs/**": true,
    ".git/index": true,
    ".git/packed-refs": true,
    ".git/FETCH_HEAD": true,
    ".git/ORIG_HEAD": true,
    ".git/HEAD": true,
    ".git/config": true,
    ".git/description": true,
    ".git/info/**": true,
    ".git/subtree-cache/**": true,
    "**/.build/**": true,
    "**/build/**": true,
    "**/Build/**": true,
    "**/temp/**": true,
    "**/.docc-build/**": true,
    "**/*.doccarchive/**": true,
    "**/*.swiftpm/**": true,
    "**/Pods/**": true,
    "**/Carthage/**": true,
    "**/planning_references/**": true,
    "**/node_modules/**": true,
    "**/.venv/lib/**": true,
    "**/*cache*/**": true,
    "**/__pycache__/**": true,
    "**/DerivedData/**": true
  }
}
```

---

## Expected Results

| Path                    | Explorer | Search | Watcher |
| ----------------------- | -------- | ------ | ------- |
| `workspaceStorage/`     | ❌       | ❌     | ❌      |
| `.pytest_cache/`        | ❌       | ❌     | ❌      |
| `.build/`               | ✅       | ❌     | ❌      |
| `.build/logs/`          | ✅       | ❌     | ❌      |
| `.build/logs/app.log`   | ✅       | ❌     | ❌      |
| `.build/logs/old/x.log` | ❌       | ❌     | ❌      |
| `.venv/bin/`            | ✅       | ✅     | ✅      |
| `.venv/lib/`            | ❌       | ❌     | ❌      |
| `.git/hooks/`           | ✅       | ✅     | ✅      |
| `.git/objects/`         | ❌       | ❌     | ❌      |
| `vendor/.git/`          | ❌       | ❌     | ❌      |
| `backup/`               | ✅       | ✅     | ✅      |

---

## Critical Fixes

1. **Root .git:** `.git/objects/**` targets workspace root only (not `**/.git/objects/**`)
2. **Nested .git:** `**/*/.git/**` hides ALL nested .git dirs completely
3. **Comprehensive search.exclude:** Now includes .git patterns and all build dirs
4. **Comprehensive watcherExclude:** Now includes everything for maximum CPU savings
5. **Cache wildcard:** `**/*cache*/**` catches all cache variants  

---

## Pattern Count Comparison

| Setting | Pattern Count |
|---------|--------------|
| files.exclude | 32 patterns |
| search.exclude | 32 patterns |
| files.watcherExclude | 30 patterns |

**All three settings now comprehensive and mostly identical.**

---

## No Duplicates

All patterns consolidated - each appears once per setting.

**Ready for re-implementation.**
