# Additional VS Code Exclusions from Common Tool Patterns

**Source:** Analysis of `~/code/repositories/hatch/hatch_sleep/2/iOS/hatch-sleep-app/.gitignore`

**Goal:** Identify common tool/dependency/build/cache directories that should be excluded from VS Code to prevent CPU waste on indexing.

---

## Already Covered in Main Plan

These patterns from the gitignore are already in the main settings plan:

✅ **Xcode:**
- `**/DerivedData/**` - Build artifacts
- `**/.build/**` - Swift Package Manager build
- `**/build/**` - Generic build output

✅ **Python:**
- `**/__pycache__/**` - Bytecode cache
- `**/.venv/lib/**` - Virtual environment packages

✅ **Node/JavaScript:**
- `**/node_modules/**` - npm dependencies

---

## Recommended Additional Exclusions

### Category A: Build & Dependency Management

**Ruby/Bundler:**
```json
"**/vendor/bundle/**": true,
".bundle/**": true
```
- Ruby gems installed locally via `bundle install --path vendor/bundle`

**CocoaPods:**
```json
"**/Pods/**": true
```
- iOS dependency manager (if you use it)
- Note: Hatch gitignore comments out `Pods/` - check if you need this

**Carthage:**
```json
"**/Carthage/Build/**": true
```
- Alternative iOS dependency manager

**Swift Package Manager (additional):**
```json
"**/.swiftpm/**": true
```
- Swift Package Manager state/cache

---

### Category B: Python Tools (additional patterns)

**Python Environments:**
```json
"**/env/**": true,
"**/venv/**": true,
"**/ENV/**": true,
"**/.Python": true
```
- Various Python virtual environment names

**Python Distribution:**
```json
"**/dist/**": true,
"**/eggs/**": true,
"**/.eggs/**": true,
"**/*.egg-info/**": true,
"**/wheels/**": true
```
- Package distribution artifacts

**Python Testing:**
```json
"**/htmlcov/**": true,
"**/.tox/**": true,
"**/.nox/**": true,
"**/.pytest_cache/**": true,
"**/.hypothesis/**": true,
"**/cover/**": true
```
- Test coverage and pytest cache

**Python Type Checking:**
```json
"**/.mypy_cache/**": true,
"**/.pytype/**": true,
"**/.pyre/**": true
```
- Type checker caches

**Python Documentation:**
```json
"**/docs/_build/**": true
```
- Sphinx documentation build output

---

### Category C: Fastlane (Hatch-Specific)

**Fastlane Outputs:**
```json
"**/fastlane/report.xml": true,
"**/fastlane/Preview.html": true,
"**/fastlane/screenshots/**": true,
"**/fastlane/test_output/**": true,
"**/fastlane/build/**": true,
"**/fastlane/Build/**": true
```
- iOS automation tool outputs

---

### Category D: IDE & Editor Files

**Already have `.vscode/` in gitignore, but worth ensuring:**
```json
"**/.idea/**": true
```
- IntelliJ/PyCharm project files

---

### Category E: Xcode (additional patterns)

**Xcode User Data:**
```json
"**/xcuserdata/**": true
```
- Per-user Xcode settings/state

**Xcode Build:**
```json
"**/Build/**": true,
"**/builds/**": true
```
- Alternative Xcode build output locations

**Swift Package Cache:**
```json
"**/.docc-build/**": true
```
- DocC documentation build output

---

### Category F: macOS System Files

These are low priority but could reduce noise:

```json
"**/.DS_Store": true,
"**/.AppleDouble": true,
"**/.LSOverride": true,
"**/._*": true
```
- macOS metadata files

---

## Prioritized Recommendations

### **High Priority** (likely to save CPU in Hatch projects)

Add to `files.watcherExclude` (no CPU watching):
```json
"**/vendor/bundle/**": true,
"**/Carthage/Build/**": true,
"**/.swiftpm/**": true,
"**/dist/**": true,
"**/*.egg-info/**": true,
"**/htmlcov/**": true,
"**/.pytest_cache/**": true,
"**/.mypy_cache/**": true,
"**/xcuserdata/**": true,
"**/fastlane/screenshots/**": true,
"**/fastlane/test_output/**": true
```

Add to `search.exclude` (not searchable):
- Same as above

Add to `files.exclude` (not visible):
- **Consider carefully** - some may need visibility (e.g., `xcuserdata` for debugging)

---

### **Medium Priority** (good for cleanup but less CPU impact)

```json
"**/env/**": true,
"**/venv/**": true,
"**/.tox/**": true,
"**/.eggs/**": true,
"**/docs/_build/**": true,
"**/.idea/**": true
```

---

### **Low Priority** (minimal impact but good hygiene)

```json
"**/.DS_Store": true,
"**/._*": true,
"**/.docc-build/**": true
```

---

## Pattern Analysis from Gitignore

**Observations:**

1. **Hatch uses Python heavily** - Many Python-related patterns suggest active Python tooling
2. **Ruby via Fastlane** - Bundle/vendor patterns indicate Ruby gem management
3. **Swift Package Manager** - Multiple `.swiftpm` patterns
4. **Custom Hatch patterns:**
   - `**/_gitignored/**` and `**/.gitignored/**` - Your custom ignore convention
   - Various `**/*.log` patterns for different tools (hatchCI, apns, attribution, etc.)

---

## Recommended Implementation Strategy

### Phase 1: High-Impact Additions (Do First)

Add these to the main settings plan before applying:

```json
// In files.watcherExclude:
"**/vendor/bundle/**": true,
"**/.swiftpm/**": true,
"**/xcuserdata/**": true,
"**/.pytest_cache/**": true,
"**/.mypy_cache/**": true,
"**/dist/**": true,
"**/*.egg-info/**": true
```

### Phase 2: Observe and Adjust

After Phase 1 and CPU stabilizes, consider adding:
- Carthage/CocoaPods if you use them
- Additional Python test/coverage directories
- Fastlane output directories

### Phase 3: Polish (Optional)

Add low-priority system file patterns for cleanliness.

---

## Pattern Syntax Notes

**From gitignore → VS Code settings:**

Gitignore uses:
- `build/` - matches directory at any level
- `/build/` - matches only at root level
- `*.log` - matches files at any level

VS Code settings use glob patterns:
- `**/build/**` - matches directory at any level, all contents
- `**/build` - matches directory at any level, just the dir
- `**/*.log` - matches files at any level

**Migration rule:** Gitignore `pattern/` → VS Code `**/pattern/**`

---

## Questions for Consideration

1. **Do you use CocoaPods?** If yes, add `**/Pods/**`
2. **Do you use Carthage?** If yes, already recommended
3. **Do you want system files hidden?** (`.DS_Store`, `._*`)
4. **Fastlane outputs:** Should screenshots/reports be hidden or visible for review?

---

## Next Steps

1. ✅ Review this analysis
2. ⏸️ Decide which Phase 1 patterns to add to main plan
3. ⏸️ Update main settings plan document with selected patterns
4. ⏸️ Apply updated settings
5. ⏸️ Monitor CPU after reload
6. ⏸️ Phase 2/3 additions as needed

---

**Note:** This document provides recommendations. The main plan (`PLAN_VSCODE_SETTINGS.md`) takes precedence. Merge selected patterns from this document into the main plan before implementation.
