---
applyTo: "**/*.swift"
---

# AI Agent Swift Terminal Command Execution Conventions

**IMPORTANT**: These conventions apply to how AI agents should execute Swift and Xcode build commands from the terminal to maximize efficiency and avoid common pitfalls.

---

## ⚡ Quick Compliance Checklist

When executing Swift/Xcode commands as an AI agent, ensure:

- ✅ **Tools located via xcrun** - Always use `xcrun --find` to locate binaries (see [Use xcrun to Locate Tools](#use-xcrun-to-locate-tools))
- ✅ **Change to project directory** - Use `cd` before build commands (see [Working Directory Navigation](#working-directory-navigation))
- ✅ **Prevent autocorrect** - Use `nocorrect` prefix to prevent zsh from correcting `build` to `.build` (see [Prevent Zsh Autocorrect](#prevent-zsh-autocorrect-on-build-command))
- ✅ **Choose correct tool** - Use `xcodebuild` for iOS, `swift` for macOS-only packages (see [Tool Selection Guide](#tool-selection-guide))
- ✅ **Validate changes** - Always test Swift code changes with tests or compilation (see [Validating Swift Code Changes](#validating-swift-code-changes))
- ✅ **Output persisted** - Use `2>&1 | tee logfile.log` pattern from agent-terminal-conventions (see [Persist Command Output](#persist-command-output))

**→ If unsure about any item, refer to the detailed sections below.**

---

## Table of Contents

1. [Tool Selection Guide](#tool-selection-guide)
2. [Use xcrun to Locate Tools](#use-xcrun-to-locate-tools)
3. [Working Directory Navigation](#working-directory-navigation)
4. [Prevent Zsh Autocorrect on Build Command](#prevent-zsh-autocorrect-on-build-command)
5. [xcodebuild Command Patterns](#xcodebuild-command-patterns)
6. [swift Command Patterns](#swift-command-patterns)
7. [Destination Preferences](#destination-preferences)
8. [Validating Swift Code Changes](#validating-swift-code-changes)
9. [Persist Command Output](#persist-command-output)

---

## Tool Selection Guide

Choose between `xcodebuild` and `swift` based on platform and project type:

### Use `xcodebuild` When:

- ✅ Target platform is **iOS** (simulator or device)
- ✅ Project uses **workspaces** (`.xcworkspace`)
- ✅ Project uses **Xcode projects** (`.xcodeproj`)
- ✅ Target platform is **macOS** (works for all cases)
- ✅ Target supports **multiple platforms** (iOS + macOS)

**Rationale**: `xcodebuild` is the universal tool that works with any Swift source type and any platform target (except Linux).

### Use `swift` When:

- ✅ Target platform is **macOS only** (pure Swift Package)
- ✅ Target platform is **Linux** (only option)
- ✅ Project is a **simple Swift Package** with no Xcode dependencies

**Rationale**: `swift` commands are simpler for pure Swift Packages, but `xcodebuild` also works for these.

### Decision Flowchart

```
Is target iOS? ────────────────────────> Use xcodebuild
    │
    No
    │
    ↓
Is it a workspace/project? ───────────> Use xcodebuild
    │
    No
    │
    ↓
Is it macOS + Linux? ─────────────────> Use swift (Linux requires it)
    │
    No
    │
    ↓
Is it macOS only? ────────────────────> Use either (prefer xcodebuild)
```

---

## Use xcrun to Locate Tools

**CRITICAL**: Always use `xcrun --find` to locate Xcode toolchain binaries. Never use bare command names.

### Why This Matters

Multiple Xcode versions are often installed on macOS development machines. Using `xcrun` ensures the correct version is used (as configured by `xcode-select`).

### Pattern

```zsh
# ✅ CORRECT - use xcrun to locate tool
"$(xcrun --find xcodebuild 2>/dev/null)" [args]
"$(xcrun --find swift 2>/dev/null)" [args]

# ❌ WRONG - bare command may use wrong Xcode version
xcodebuild [args]
swift [args]
```

### Tool Locations

Both `swift` and `xcodebuild` are shipped with Xcode:

```zsh
# Find xcodebuild (in Developer/usr/bin)
$ xcrun --find xcodebuild
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild

# Find swift (in Toolchains)
$ xcrun --find swift
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift
```

---

## Working Directory Navigation

**CRITICAL**: Always `cd` to the appropriate directory before running build commands.

### Priority Order (Most Specific → Least Specific)

1. **Swift Package directory** (contains `Package.swift`)
2. **Xcode project directory** (contains `.xcodeproj`)
3. **Xcode workspace directory** (contains `.xcworkspace`)

**Rationale**: Using the most specific directory reduces ambiguity and improves command reliability.

### Examples

```zsh
# ✅ GOOD - navigate to package directory first
cd "$PACKAGE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" clean build \
  -scheme "Nightlight_Development" \
  -destination "platform=iOS Simulator,name=iPhone 16"

# ✅ GOOD - navigate to workspace directory
cd "$WORKSPACE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" clean test \
  -workspace Nightlight.xcworkspace \
  -scheme HatchLoggerMacros \
  -destination 'platform=macOS'

# ❌ BAD - no directory navigation
"$(xcrun --find xcodebuild 2>/dev/null)" -workspace "$WORKSPACE_DIR/Nightlight.xcworkspace" ...
```

---

## Prevent Zsh Autocorrect on Build Command

**CRITICAL**: When `CORRECT_ALL` is enabled in zsh (common with oh-my-zsh), the word `build` gets autocorrected to `.build` (the Swift Package build directory).

### The Problem

```zsh
# With CORRECT_ALL enabled in a Swift Package directory
$ xcodebuild clean build -scheme MyScheme
zsh: correct 'build' to '.build' [nyae]?  # ← Prompts for user input, blocking the agent
```

### The Solution: Use `nocorrect`

`nocorrect` is a zsh precommand modifier that disables spelling correction for the entire command:

```zsh
# ✅ CORRECT - prevents autocorrect
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" clean build -scheme MyScheme

# ✅ ALSO CORRECT - works with swift commands
nocorrect "$(xcrun --find swift 2>/dev/null)" build
```

### Why Not Quote "build"?

Quoting `"build"` prevents autocorrect but is less readable:

```zsh
# ❌ LESS PREFERRED - works but harder to read
xcodebuild clean "build" -scheme MyScheme
```

**Use `nocorrect` instead** - it's clearer and handles the entire command.

### Technical Details

- `nocorrect` is a **reserved word** in zsh (not a builtin command)
- Must appear **before any other precommand modifier**
- Has **no effect in non-interactive shells** (only affects interactive agent sessions)
- Documented in `man zshmisc` under "PRECOMMAND MODIFIERS"

---

## xcodebuild Command Patterns

### Basic Build Commands

```zsh
# Clean then build
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" clean build \
  -scheme "Nightlight_Development" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  2>&1 | tee ".gitignored/build/xcodebuild_$(date +%Y%m%d_%H%M%S).log"

# Run tests
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" test \
  -scheme HatchIoTShadowClient \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  2>&1 | tee ".gitignored/test/xcodebuild_test_$(date +%Y%m%d_%H%M%S).log"

# Clean then test
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" clean test \
  -scheme HatchIoTShadowClient \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  2>&1 | tee ".gitignored/test/xcodebuild_clean_test_$(date +%Y%m%d_%H%M%S).log"
```

### Workspace Commands

```zsh
# Test macOS target from workspace
cd "$WORKSPACE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" clean test \
  -workspace Nightlight.xcworkspace \
  -scheme HatchLoggerMacros \
  -destination 'platform=macOS' \
  -configuration Debug \
  2>&1 | tee ".gitignored/test/xcodebuild_macos_test_$(date +%Y%m%d_%H%M%S).log"
```

### Swift Package Schemes

When working with Swift Packages, `xcodebuild` creates a scheme named `${PACKAGE_NAME}-Package` that builds all targets:

```zsh
# Build all targets in package
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" \
  -scheme HatchModules-Package \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=18.4" \
  clean test \
  2>&1 | tee ".gitignored/test/package_test_$(date +%Y%m%d_%H%M%S).log"

# Show available destinations for a package scheme
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" \
  -scheme HatchTerminal-Package \
  -showdestinations \
  2>&1 | tee ".gitignored/research/xcodebuild_showdestinations_$(date +%Y%m%d_%H%M%S).log"
```

**Note**: The `-Package` scheme suffix is automatically created by Xcode for Swift Packages and works with all xcodebuild commands including `-showdestinations`.

---

## swift Command Patterns

### Basic Commands

```zsh
# Build a product
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" build \
  --package-path "$PACKAGE_DIR" \
  --product "$TOOL_NAME" \
  2>&1 | tee ".gitignored/build/swift_build_$(date +%Y%m%d_%H%M%S).log"

# Build with specific configuration and architectures
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" build \
  --package-path "$PACKAGE_DIR" \
  --product "$TOOL_NAME" \
  --configuration release \
  --arch arm64 --arch x86_64 \
  2>&1 | tee ".gitignored/build/swift_build_release_$(date +%Y%m%d_%H%M%S).log"

# Run tests
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" test \
  --package-path "$PACKAGE_DIR" \
  2>&1 | tee ".gitignored/test/swift_test_$(date +%Y%m%d_%H%M%S).log"

# Run an executable
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" run "$EXECUTABLE_NAME" [args]
```

### Help Commands

```zsh
# View available subcommands
"$(xcrun --find swift 2>/dev/null)" --help
"$(xcrun --find swift 2>/dev/null)" build --help
"$(xcrun --find swift 2>/dev/null)" test --help
"$(xcrun --find swift 2>/dev/null)" run --help
```

---

## Destination Preferences

When specifying `-destination` for `xcodebuild`, prefer options in this order:

### 1. macOS Native (Most Preferred)

Use when target is compiled to run natively on macOS (not Catalyst, not "Designed for iPhone"):

```zsh
# macOS platform
-destination 'platform=macOS'
```

**Pros**: Fastest, most reliable, supports all test types

### 2. macOS Variants (Catalyst, Designed for iPad/iPhone, DriverKit)

Use when iOS project is configured to run on macOS via Catalyst or "Designed for iPad/iPhone":

```zsh
# Mac Catalyst (iOS app running via Catalyst on macOS)
-destination 'platform=macOS,variant=Mac Catalyst'

# Designed for iPad/iPhone (iOS app running natively on Apple Silicon Mac)
-destination 'platform=macOS,variant=Designed for [iPad,iPhone]'

# DriverKit (for driver development)
-destination 'platform=macOS,variant=DriverKit'
```

**Note**: These variants don't always work with tests. Prefer native macOS when possible.

### 3. iOS Simulator (Common Choice)

Use generic simulator when possible to avoid device-specific issues:

```zsh
# ✅ BEST - any available iOS simulator (no specific device)
-destination 'platform=iOS Simulator,name=Any iOS Simulator Device'

# ✅ GOOD - specific device model (uses any available matching simulator)
-destination 'platform=iOS Simulator,name=iPhone 16 Pro'

# ✅ GOOD - specific device by UDID (guarantees exact simulator instance)
-destination 'platform=iOS Simulator,id=56F1858F-84A3-43F6-9623-C254E22F540D'

# ✅ GOOD - specific device, OS version, and architecture
-destination 'platform=iOS Simulator,arch=arm64,OS=18.5,name=iPhone 16 Pro'

# ✅ GOOD - fully qualified with UDID (most specific)
-destination 'platform=iOS Simulator,arch=arm64,id=56F1858F-84A3-43F6-9623-C254E22F540D,OS=18.5,name=iPhone 16 Pro'
```

**Note**: Some tests cannot run on simulators (e.g., hardware-dependent features).

### 4. iOS Device (Physical Hardware)

Only use when simulator testing is insufficient:

```zsh
# ✅ Any connected iOS device
-destination 'platform=iOS,name=Any iOS Device'

# ✅ Specific device by name (if only one device with that name is connected)
-destination 'platform=iOS,name=Zakk's iPhone'

# ✅ Specific device by UDID (most reliable for multiple devices)
-destination 'platform=iOS,id=00008030-001234567890ABCD'
```

**Cons**: Requires device registration, physical connection, data transfers, provisioning profiles.

### 5. macOS Device (Specific Mac)

Use when you need to target a specific Mac by UDID:

```zsh
# ✅ Any Mac
-destination 'platform=macOS,name=Any Mac'

# ✅ Specific Mac by name
-destination 'platform=macOS,name=My Mac'

# ✅ Specific Mac by UDID and architecture
-destination 'platform=macOS,arch=arm64,id=00006021-00042101367B401E,name=My Mac'

# ✅ Specific Mac with Catalyst variant
-destination 'platform=macOS,arch=arm64,variant=Mac Catalyst,id=00006021-00042101367B401E,name=My Mac'

# ✅ Specific Mac with Designed for iPad/iPhone variant
-destination 'platform=macOS,arch=arm64,variant=Designed for [iPad,iPhone],id=00006021-00042101367B401E,name=My Mac'
```

**Note**: UDID format for Macs is typically `00006021-XXXXXXXXXXXXXXXX` (hardware identifier).

---

## Validating Swift Code Changes

**CRITICAL**: AI agents must **always** validate their Swift code changes. Linting alone is insufficient.

### Validation Priority Order

#### 1. Unit Tests / Snapshot Tests (Most Preferred)

Capture known good behavior before refactoring, validate after:

```zsh
# Run unit tests
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" test \
  -scheme MyScheme \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  2>&1 | tee ".gitignored/test/validation_test_$(date +%Y%m%d_%H%M%S).log"

# Or with swift test
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" test \
  2>&1 | tee ".gitignored/test/swift_validation_test_$(date +%Y%m%d_%H%M%S).log"
```

#### 2. Run the Executable (If Applicable)

If code is an app or executable target:

```zsh
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" run "$EXECUTABLE_NAME" [test_args] \
  2>&1 | tee ".gitignored/run/executable_test_$(date +%Y%m%d_%H%M%S).log"
```

#### 3. Compilation Check (Last Resort)

If code is a library where adding tests is impractical:

```zsh
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find swift 2>/dev/null)" build \
  2>&1 | tee ".gitignored/build/validation_build_$(date +%Y%m%d_%H%M%S).log"
```

**Note**: This only verifies compilation, not correctness.

### Adding Tests When Missing

**Rule**: If Swift code being modified lacks test coverage, agent should add tests.

#### Adding Unit Tests

For Swift Package targets (library, executable, etc.), add a `testTarget` if one doesn't exist:

```swift
// In Package.swift
targets: [
  .target(
    name: "MyLibrary",
    dependencies: []
  ),
  .testTarget(
    name: "MyLibraryTests",
    dependencies: ["MyLibrary"]
  ),
]
```

#### Adding Snapshot Tests (For Refactoring)

When refactoring code, ensure snapshot tests exist **before** modifying:

1. **Add SnapshotTesting dependency** to `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
    from: "1.18.7"
  ),
  // ...
],
```

2. **Add dependency to test target**:

```swift
targets: [
  .testTarget(
    name: "MyLibraryTests",
    dependencies: [
      "MyLibrary",
      .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
    ]
  ),
]
```

3. **Write snapshot tests** to capture current behavior
4. **Refactor code**
5. **Verify snapshots match** (no behavior changes)

---

## Persist Command Output

**CRITICAL**: Follow the patterns from `agent-terminal-conventions.instructions.md` for all Swift/Xcode build commands.

### Standard Pattern

Always use `2>&1 | tee` to capture both stdout and stderr while showing output to human:

```zsh
# Create log directory
mkdir -p .gitignored/build

# Execute command with full output capture
log_file=".gitignored/build/xcodebuild_$(date +%Y%m%d_%H%M%S).log"
cd "$PACKAGE_DIR" && \
nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" clean build \
  -scheme MyScheme \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | tee "$log_file"

# Now filter/analyze the log file (instant, no re-compilation)
grep "error:" "$log_file"
grep "warning:" "$log_file" | wc -l
tail -n 100 "$log_file"
```

### Why This Matters for Swift Builds

Swift compilation is expensive:
- **Full iOS app build**: 5-15 minutes
- **Swift Package build**: 1-5 minutes
- **Unit test run**: 2-10 minutes

Re-running these commands just to apply different filters wastes enormous amounts of time. **Always capture full output first, then filter the log file.**

---

## Summary: Agent Efficiency Rules for Swift

1. **Locate tools via xcrun** - `"$(xcrun --find xcodebuild 2>/dev/null)"`
2. **Navigate to project directory** - `cd "$PACKAGE_DIR" &&`
3. **Prevent autocorrect** - `nocorrect` before build commands
4. **Choose correct tool** - `xcodebuild` for iOS, `swift` for macOS-only
5. **Capture full output** - `2>&1 | tee logfile.log` on every build/test command
6. **Validate all changes** - Tests, execution, or compilation
7. **Add tests when missing** - Unit tests or snapshot tests

Following these conventions will:
- **Prevent blocking** (no autocorrect prompts)
- **Use correct Xcode version** (via xcrun)
- **Reduce compilation time** by 80-95% (avoid re-runs)
- **Ensure code quality** (validation required)
- **Improve collaboration** (human sees full output)

---

## References

- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Swift Package Manager Documentation](https://www.swift.org/package-manager/)
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [Point-Free Snapshot Testing](https://github.com/pointfreeco/swift-snapshot-testing)
- [Zsh Manual: Precommand Modifiers](http://zsh.sourceforge.net/Doc/Release/Shell-Grammar.html#Precommand-Modifiers)
