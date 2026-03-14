# VS Code Additional Performance Settings

**Based on:** Installed extensions and official VS Code documentation

**Extensions analyzed:** 198 total, focusing on Git, search, and performance-impacting extensions

---

## Core VS Code Performance Settings

### File Watching & Indexing

```json
{
  "files.watcherExclude": {
    "**/*/.git/**": true,
    "**/.git/objects/**": true,
    "**/.git/refs/**": true,
    "**/.git/logs/**": true,
    "**/.build/**": true,
    "**/build/**": true,
    "**/Build/**": true,
    "**/DerivedData/**": true,
    "**/node_modules/**": true,
    "**/.venv/lib/**": true,
    "**/*cache*/**": true,
    "**/Library/Application Support/Code/User/workspaceStorage/**": true,
    "**/Library/Application Support/Code/User/globalStorage/**": true
  },
  "files.watcherInclude": [],
  "files.hotExit": "onExitAndWindowClose"
}
```

### Search Performance

```json
{
  "search.followSymlinks": false,
  "search.useGlobalIgnoreFiles": true,
  "search.useParentIgnoreFiles": true,
  "search.smartCase": true,
  "search.maxResults": 10000
}
```

### Large File Handling

```json
{
  "editor.largeFileOptimizations": true,
  "files.maxMemoryForLargeFilesMB": 4096,
  "editor.bracketPairColorization.enabled": false,
  "editor.guides.bracketPairs": false
}
```

**Note:** Disabling bracket colorization improves performance on large files significantly.

---

## Git Performance Settings

### Core Git Settings

```json
{
  "git.enabled": true,
  "git.autorefresh": true,
  "git.autofetch": false,
  "git.ignoreLimitWarning": true,
  "git.repositoryScanMaxDepth": 1,
  "git.scanRepositories": [],
  "git.detectSubmodules": false,
  "git.detectSubmodulesLimit": 0
}
```

**Key settings:**
- `git.repositoryScanMaxDepth: 1` - Only scan workspace root for .git (ignore nested)
- `git.detectSubmodules: false` - Don't scan for submodules (major performance win)
- `git.autofetch: false` - Manual fetch only (reduces network/CPU)

---

## Extension-Specific Settings

### GitLens (eamodio.gitlens)

**High-impact performance settings:**

```json
{
  "gitlens.codeLens.enabled": false,
  "gitlens.currentLine.enabled": false,
  "gitlens.hovers.currentLine.enabled": false,
  "gitlens.blame.avatars": false,
  "gitlens.blame.highlight.enabled": false,
  "gitlens.advanced.caching.enabled": true,
  "gitlens.advanced.fileHistoryFollowsRenames": false,
  "gitlens.ai.exclude.files": {
    "**/.build/**": true,
    "**/build/**": true,
    "**/Build/**": true,
    "**/DerivedData/**": true,
    "**/node_modules/**": true,
    "**/*cache*/**": true,
    "**/Pods/**": true,
    "**/Carthage/**": true
  },
  "gitlens.advanced.repositorySearchDepth": 1
}
```

**Why these matter:**
- `codeLens.enabled: false` - Biggest CPU saver (scans every file for git blame)
- `currentLine.enabled: false` - Stops real-time blame lookups on cursor move
- `repositorySearchDepth: 1` - Only workspace root, ignore nested .git

### Todo Tree (gruntfuggly.todo-tree)

**Already configured correctly:**

```json
{
  "todo-tree.filtering.useBuiltInExcludes": "file and search excludes",
  "todo-tree.filtering.excludeGlobs": [
    "**/node_modules/*/**",
    "**/.build/**",
    "**/build/**",
    "**/DerivedData/**",
    "**/Pods/**",
    "**/Carthage/**"
  ]
}
```

**Additional recommended:**

```json
{
  "todo-tree.tree.scanMode": "workspace only",
  "todo-tree.regex.enableMultiLine": false,
  "todo-tree.highlights.defaultHighlight": {
    "gutterIcon": false
  }
}
```

### Git History (donjayamanne.githistory)

```json
{
  "gitHistory.pageSize": 50,
  "gitHistory.showEditor": false
}
```

### GitHub Actions (github.vscode-github-actions)

```json
{
  "github-actions.workflows.pinned.refresh.enabled": true,
  "github-actions.workflows.pinned.refresh.interval": 300
}
```

**Note:** Already enabled but verify refresh interval isn't too aggressive.

---

## Additional VS Code Core Settings

### Editor Performance

```json
{
  "editor.minimap.enabled": false,
  "editor.renderWhitespace": "selection",
  "editor.semanticHighlighting.enabled": false,
  "editor.colorDecorators": false,
  "editor.suggest.localityBonus": true,
  "editor.quickSuggestions": {
    "comments": false
  }
}
```

### Workspace Trust (Performance Impact)

```json
{
  "security.workspace.trust.enabled": false
}
```

**Warning:** Only disable if you trust all code you open.

### Terminal Performance

```json
{
  "terminal.integrated.enablePersistentSessions": false,
  "terminal.integrated.smoothScrolling": false
}
```

---

## Summary of Recommendations

### Apply Immediately (High Impact)

1. **GitLens:** Disable code lens (`gitlens.codeLens.enabled: false`)
2. **Git:** Scan depth 1 (`git.repositoryScanMaxDepth: 1`)
3. **Git:** Disable submodule detection (`git.detectSubmodules: false`)
4. **Search:** Don't follow symlinks (`search.followSymlinks: false`)
5. **Editor:** Disable large file features (`editor.largeFileOptimizations: true`)

### Consider (Medium Impact)

1. **GitLens:** Disable current line blame (`gitlens.currentLine.enabled: false`)
2. **Minimap:** Disable if not used (`editor.minimap.enabled: false`)
3. **Semantic highlighting:** Disable (`editor.semanticHighlighting.enabled: false`)

### Monitor (Low Impact but Helpful)

1. **Todo Tree:** Ensure using built-in excludes
2. **GitHub Actions:** Reasonable refresh interval
3. **Bracket colorization:** Disable for large files

---

## Git-Specific Recommendations for Nested Repositories

**Problem:** Nested `.git/` directories in `vendor/`, `submodules/`, etc. cause VS Code to scan each as a separate repository.

**Solutions:**

```json
{
  "git.repositoryScanMaxDepth": 1,
  "git.detectSubmodules": false,
  "git.detectSubmodulesLimit": 0,
  "git.scanRepositories": [],
  "git.ignoredRepositories": [
    "**/vendor/**",
    "**/node_modules/**",
    "**/.build/**"
  ],
  "gitlens.advanced.repositorySearchDepth": 1
}
```

**Result:** VS Code only manages workspace root `.git/`, completely ignores nested repositories.

---

## Extension Exclusion Settings Matrix

| Extension | Setting | Pattern to Add |
|-----------|---------|----------------|
| GitLens | `gitlens.ai.exclude.files` | `**/.build/**`, `**/build/**`, `**/DerivedData/**` |
| Todo Tree | `todo-tree.filtering.excludeGlobs` | `**/.build/**`, `**/build/**`, `**/DerivedData/**` |
| ESLint | `eslint.workingDirectories` | Specify only source dirs |
| Pylint | `python.analysis.exclude` | `["**/node_modules/**", "**/.venv/**"]` |

---

## Performance Monitoring

**Built-in tool:** `Cmd+Shift+P` → "Developer: Show Running Extensions"

**Watch for:**
- Extensions with high activation time (>1s)
- Extensions with high CPU % while idle
- File watcher patterns that don't respect excludes

---

## Implementation Priority

### Phase 1 (Apply Now)
1. All `files.watcherExclude` patterns from main plan
2. `git.repositoryScanMaxDepth: 1`
3. `git.detectSubmodules: false`
4. `gitlens.codeLens.enabled: false`
5. `todo-tree.filtering.useBuiltInExcludes: "file and search excludes"` (already done ✅)

### Phase 2 (After Verifying CPU Drop)
1. `gitlens.currentLine.enabled: false`
2. `search.followSymlinks: false`
3. Extension-specific exclusions

### Phase 3 (Optional Polish)
1. Editor performance tweaks (minimap, semantic highlighting)
2. Terminal performance settings

---

**Next Step:** Merge these recommendations into main settings plan and apply.