---
name: refactor-to-client-module
description: Extract a piece of legacy Swift code from HatchBrain/HatchModels/HatchSleep into a new HatchModules client module. Produces Sources/{Interface,Live,Mocks,Coordinator,Models}, TestSupport/Failing, DocC catalog, unit + snapshot tests, and full Package.swift/xctestplan/xcscheme registration. Phased with one branch + one PR per phase.
---

# Refactor Legacy Code into a HatchModules Client Module

## Table of Contents

1. [When to Use This Skill](#1-when-to-use-this-skill)
2. [Target Module Layout](#2-target-module-layout)
3. [Phased Recipe](#3-phased-recipe-canonical-13-phase-split)
4. [Naming Conventions](#4-naming-conventions)
5. [Logging Conventions](#5-logging-conventions)
6. [Dual-Path Toggle — Legacy vs. Modern](#6-dual-path-toggle--legacy-vs-modern)
7. [Package.swift + Test Plan + Scheme Registration](#7-packageswift--test-plan--scheme-registration)
8. [Branch / PR / Phase Discipline](#8-branch--pr--phase-discipline)
9. [Quality Gates — Run Every Phase](#9-quality-gates--run-every-phase)
10. [Known Pitfalls](#10-known-pitfalls)
11. [User Preferences](#11-user-preferences-terse-non-obvious)
12. [Worked Example — HatchIoTBLEBackupClient](#12-worked-example--hatchiotblebackupclient)
13. [Related Skills and References](#13-related-skills-and-references)

---

## 1. When to Use This Skill

Trigger this skill when the user asks to:

- "Migrate `<file-or-directory>` into `HatchModules`"
- "Modularize `<legacy-feature>`"
- "Extract `<X>` as a client"
- "Wrap `<X>` in a `HatchModules` client"
- "Refactor `<X>` out of `HatchBrain` / `HatchModels` / `HatchSleep`"
- "Pull `<X>` into its own module"
- "Create a Hatch client for `<X>`"

### Do *not* use this skill for

- Green-field API clients for Hatch backend endpoints → use `.claude/skills/api-client-generator/`.
- Greenfield features that were never in the monolith → use `.claude/skills/ios-architecture/` + standard feature scaffolding.
- Renames / in-place refactors that stay inside the original module.
- Pure view / ViewModel extractions with no cross-module coupling — that is not a "client", that is a feature module.

### Signature of a good candidate

A legacy Swift file (or small cluster of files) that:

- Lives under `HatchBrain/`, `HatchModels/`, or `HatchSleep/`.
- Encapsulates a single system or external-service interaction (BLE, networking, storage, analytics, device telemetry, etc.).
- Is consumed from one or more places in the app monolith.
- Has stable behaviour (so the refactor's success criterion is 1:1 behavioural parity).

---

## 2. Target Module Layout

Every client module this skill produces follows this **invariant skeleton**. Do not deviate without a ticket-level reason.

```
HatchModules/Modules/Clients/Hatch<Module>/
├── Sources/
│   ├── Hatch<Module>+Interface.swift        # public struct, @Sendable closures, @NamedClientClosure
│   ├── Hatch<Module>+Live.swift             # @MainActor static func live(...)
│   ├── Hatch<Module>+Mocks.swift            # static var noOp, static func failing(error:)
│   ├── Coordinator/<Coordinator>.swift      # extracted legacy code, @MainActor final class
│   ├── Models/*.swift                       # Event, Error, Auth/Config types
│   ├── Features/*.swift                     # optional — feature-flag gating helpers
│   ├── Extensions/*.swift                   # optional — typed extensions / utilities
│   ├── UnifiedLogger.swift                  # module-scoped os.Logger
│   └── Hatch<Module>.docc/
│       ├── Hatch<Module>.md
│       └── Resources/Hatch<Module>.svg
├── TestSupport/Failing.swift                # Applyable conformance, failing-variant tests
└── Tests/
    ├── Hatch<Module>.xctestplan
    ├── UnitTests/UnitTests.swift            # Swift Testing @Test / #expect
    └── UnitTests/UnitSnapshotTests.swift    # swift-snapshot-testing
```

### The four canonical files

| File                              | Purpose                                       | Key patterns                                                                              |
| --------------------------------- | --------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `Hatch<Module>+Interface.swift`   | Public API surface                            | `public struct <Name>: Sendable`, `@Sendable` closure vars, `@NamedClientClosure` macro   |
| `Hatch<Module>+Live.swift`        | Real implementation, wires up the coordinator | `@MainActor public static func live(...) -> Self`, holds private state class              |
| `Hatch<Module>+Mocks.swift`       | Preview + unit test stubs                     | `public static var noOp`, `public static func failing(error:)`                            |
| `Coordinator/<Coordinator>.swift` | The extracted legacy code                     | `@MainActor final class`, owns the system-level resource (session, socket, peripheral, …) |

### Reference exemplars (read these first)

- `HatchBLEClient` — highest fidelity, has every part (Interface / Live / Mocks / Coordinator + extensions / Models / Extensions / `.swiftlint.yml` / Tests / TestSupport / DocC).
- `HatchFirmwareUpdateClient` — minimal but complete. Good starting template.
- `HatchAnalyticsClient` — shows the `Models/`/`Types/` split and `Dependencies/` integration.

> [!IMPORTANT]
> **Target name gets the `Hatch` prefix; the public struct name does not.** So `target "HatchIoTBLEBackupClient"` but `public struct IoTBLEBackupClient: Sendable`. This mirrors every existing client module in the monorepo.

---

## 3. Phased Recipe — Canonical 13-Phase Split

Each phase = one branch off the prior phase's branch = one PR targeting `main` = one green local `format + lint + build + test` cycle. **Push and update the PR body on every push.** See [§8](#8-branch--pr--phase-discipline) for the branch/PR/title template.

| Phase | Name                 | What ships                                                                                                                                                                                                                                                                                |
| ----- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | Scaffold             | Empty `HatchModules/Modules/Clients/Hatch<Module>/` directory tree, empty `Package.swift` entries (library + target + test target + test-support target), empty `xctestplan`, scheme entry. Verify `HatchModules` still builds in isolation.                                              |
| 2     | Port + tests         | Copy `<legacy-file>` verbatim into `Sources/Coordinator/<Coordinator>.swift`. Add `Interface.swift`, `Live.swift`, `Mocks.swift` stubs (closures returning defaults). Write minimum-viable `UnitTests.swift` and `UnitSnapshotTests.swift`. Compile the module in isolation.              |
| 3     | Feature-flag helper  | Add `FeatureFlag.enable<Name>Client`, `Argument.enable<Name>Client = "ENABLE_<NAME>_CLIENT"`, and a `shouldUseNew<Name>Client()` helper that returns `OR` of Statsig flag, Argument flag, and `ProcessInfo.processInfo.arguments.contains("ENABLE_<NAME>_CLIENT")`. Unit test the helper. |
| 4     | Dual-path enum       | Introduce the associated-value enum that wraps legacy vs. modern (see [§6](#6-dual-path-toggle--legacy-vs-modern)). Update dependent owner(s) to retain the enum, not two parallel optionals.                                                                                             |
| 5     | Modern call sites    | Under `.modern`, route every call site to the new client. **Lazy-init** the modern client only when the toggle is on.                                                                                                                                                                     |
| 6     | Legacy parity verify | Under `.legacy`, confirm nothing changed — same inputs, same outputs, same side-effects.                                                                                                                                                                                                  |
| 7     | Observability        | Add `#LogAll` calls inside the Coordinator + Live wiring using the format in [§5](#5-logging-conventions). Scopes: `prep`, `unsupported`, `modern`, `legacy`.                                                                                                                             |
| 8     | DocC + doc comments  | `Hatch<Module>.docc/` catalog, inline `///` doc comments on every public declaration, usage example in the catalog `.md`.                                                                                                                                                                 |
| 9     | Tests green locally  | Snapshot baselines recorded; unit tests pass on the local simulator. Do not rely on CI for first validation.                                                                                                                                                                              |
| 10    | Rollout wiring       | Feature flag plumbed through Statsig + Argument + ProcessInfo combined paths, verified end-to-end.                                                                                                                                                                                        |
| 11    | Dependent refactors  | Refactor adjacent modules that have to participate (dispatchers, scanners, feed providers). Inject shared state as a *new* lightweight struct — do not leak internals back into the dispatcher.                                                                                           |
| 12    | UI parity            | If a debug/status view observes the legacy path (e.g. a traffic monitor), wire the modern path through the **same** subjects/publishers so the UI behaves 1:1.                                                                                                                            |
| 13    | Cleanup              | Strip `#warning`s, `FIXME`s, stale ticket numbers in code comments, `swiftformat:disable`/`swiftlint:disable` directives, whitespace-only diffs. Rebase/pull `main`.                                                                                                                      |

> [!TIP]
> Tests belong in phase 2, not later. A client module without any tests is not merge-ready even if it compiles. The user's rule: *"WE need to include tests in any new client module … phase 2."*

> [!NOTE]
> The 13-phase shape is the template; collapse or split phases only when the work genuinely calls for it. Do not expand it to 20 phases "for thoroughness" — each phase has real PR review cost.

---

## 4. Naming Conventions

### Target / module / struct

| Entity         | Rule                                       | Example                                                 |
| -------------- | ------------------------------------------ | ------------------------------------------------------- |
| Swift target   | `Hatch` prefix                             | `HatchIoTBLEBackupClient`, `HatchFirmwareUpdateClient`  |
| Public struct  | No `Hatch` prefix                          | `IoTBLEBackupClient`, `FirmwareUpdateClient`            |
| Module folder  | Same as target                             | `HatchModules/Modules/Clients/HatchIoTBLEBackupClient/` |
| Coordinator    | `<Name>Coordinator` or `IoT<X>Coordinator` | `IoTBLEBackupCoordinator`, `BLEClientCoordinator`       |
| Interface file | `<Module>+Interface.swift`                 | `IoTBLEBackupClient+Interface.swift`                    |
| Live file      | `<Module>+Live.swift`                      | `IoTBLEBackupClient+Live.swift`                         |
| Mocks file     | `<Module>+Mocks.swift`                     | `IoTBLEBackupClient+Mocks.swift`                        |

### Acronyms — the casing rules

For `iot`, `ble`, `api`, `url`, `uuid`, `json`, `http`, `ui`, and similar acronyms:

| Position      | Casing        | Example                                             |
| ------------- | ------------- | --------------------------------------------------- |
| Start of name | All lowercase | `iotBLEBackupClient`, `bleClient`, `apiEndpoint`    |
| Mid-word      | All uppercase | `publishBLEShadow()`, `examineIoT()`, `parseJSON()` |
| End of name   | All uppercase | `deviceUUID`, `downloadURL`                         |

### Variable-name mirrors its type

A variable's identifier must be the same letters as its type, differing only in the leading character's case:

| Type                   | Correct variable       | Wrong                                   |
| ---------------------- | ---------------------- | --------------------------------------- |
| `BLEClient`            | `bleClient`            | `BLEClient`, `BleClient`, `client`      |
| `IoTBLEBackupClient`   | `iotBLEBackupClient`   | `bleBackupClient`, `iotBleBackupClient` |
| `FirmwareUpdateClient` | `firmwareUpdateClient` | `fwUpdateClient`                        |

---

## 5. Logging Conventions

### Preferred — `#LogAll` macro (inside HatchModules)

```swift
#LogAll(
    .debug,
    message: "[<Module> <scope>] - <message>",
    properties: [
        "key1": value1,
        "key2": value2
    ]
)
```

**One argument per line. One key:value per line inside the `properties` dictionary. Never collapse `#LogAll` to a single line.**

### Acceptable at module boundaries — `logger.<level>`

```swift
logger.debug("[<Module> <scope>] - <message>")
```

### Levels

| Level      | When to use                                                                          |
| ---------- | ------------------------------------------------------------------------------------ |
| `.debug`   | Default; routine progress of happy path                                              |
| `.warning` | Non-fatal degraded behaviour the reviewer should *notice* (e.g. fallback path taken) |
| `.fault`   | Publisher errors, unrecoverable failure, anything that ends a `.sink` chain          |

### Scopes (vocabulary is fixed)

| Scope         | Meaning                                                                         |
| ------------- | ------------------------------------------------------------------------------- |
| `prep`        | Not connected yet, but preparing to (legacy vs. modern undecided at this point) |
| `unsupported` | Feature is not enabled for the current configuration / product / device         |
| `modern`      | Using the new client (the subject of the refactor)                              |
| `legacy`      | Using the pre-refactor implementation                                           |

> [!WARNING]
> Do **not** leave personal prefixes like `[zakk …]` or scratch scopes in merged code. Every log line in the PR must use `[<Module> <scope>]` exactly.

---

## 6. Dual-Path Toggle — Legacy vs. Modern

### The preferred shape: associated-value enum

```swift
enum <Name>Controller {
    case legacy(<LegacyType>)
    case modern(<NewClient>)
}
```

The owning object holds **one** stored property of this enum type, not two parallel optionals. When the modern path is live, `modern(_)` is the case; when disabled, `legacy(_)` is the case. Every call site switches on the enum.

### The trigger helper

```swift
static func shouldUseNew<Name>Client() -> Bool {
    featureFlag.isEnabled(.enable<Name>Client)
    || ArgumentManager.isEnabled(.enable<Name>Client)
    || ProcessInfo.processInfo.arguments.contains("ENABLE_<NAME>_CLIENT")
}
```

### Decide once, not per call

Query `shouldUseNew<Name>Client()` **once** when the owner is constructed, and store the resulting enum case. Re-querying the flag at every call site is redundant and error-prone. The enum already carries the decision.

### Anti-pattern to avoid

```swift
// DO NOT do this — two parallel optionals:
private var modernClient: <NewClient>?
private var legacyObject: <LegacyType>?
```

Both optionals are always nillable at every call site; neither can be `guard let`-unwrapped alone without losing the other's state.

---

## 7. Package.swift + Test Plan + Scheme Registration

A new client module requires edits in **three** places. (Identical to the existing `api-client-generator` skill — reuse those instructions verbatim where they apply.)

### Three sites to update

| Site                                                                                              | Why                                                   |
| ------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `iOS/hatch-sleep-app/HatchModules/Package.swift`                                                  | Declare library + target + test-support + test target |
| `iOS/hatch-sleep-app/Nightlight_Development.xctestplan`                                           | Include new tests in the app test plan                |
| `iOS/hatch-sleep-app/Nightlight.xcodeproj/xcshareddata/xcschemes/Nightlight_Development.xcscheme` | Make tests runnable from Xcode                        |

### Four entries in `Package.swift`

1. `.library(name: "Hatch<Module>", targets: ["Hatch<Module>"])` — under `products:`.
2. `.target(name: "Hatch<Module>", dependencies: [...], path: "Modules/Clients/Hatch<Module>/Sources", resources: [], swiftSettings: swiftSettings)` — under `targets:`.
3. `.target(name: "Hatch<Module>TestSupport", dependencies: ["Hatch<Module>"], path: "Modules/Clients/Hatch<Module>/TestSupport", swiftSettings: swiftSettings)` — under `targets:`.
4. `.testTarget(name: "Hatch<Module>Tests", dependencies: ["Hatch<Module>", "Hatch<Module>TestSupport"], path: "Modules/Clients/Hatch<Module>/Tests", swiftSettings: swiftSettings)` — under `targets:`.

### Target `dependencies` list — minimum set

```swift
dependencies: [
    "HatchClientMacros",           // @NamedClientClosure, etc.
    "HatchLoggerMacros",            // #LogAll
    "HatchObservabilityClient"      // log sink
    // plus whatever the Coordinator actually needs (HatchBLEClient, HatchKeychainClient, …)
]
```

> [!TIP]
> Read the existing `HatchIoTBLEBackupClient` target entry in `HatchModules/Package.swift` (≈line 5616) as a copy-paste template. Diff the real entry against your new one before committing.

---

## 8. Branch / PR / Phase Discipline

This is the single most-emphasized rule the user repeats. Do not deviate.

### Branch name template

```
${git_author}/${jira_ticket_lower}/${feature_topic}/phase_${N}/${phase_topic}
```

Examples:

```
zakkhoyt/hsd-15235/ble_backup_client/phase_1/scaffold
zakkhoyt/hsd-15235/ble_backup_client/phase_2/port_and_tests
```

If there is no Jira ticket, drop that segment:

```
${git_author}/${feature_topic}/phase_${N}/${phase_topic}
```

And add `--label "Skip Jira Ticket Check"` to the `gh pr create` invocation.

### Branch lineage

- Phase 1's branch is cut from `main`.
- Phase N (N > 1) is cut from phase N-1's branch, **not** from `main`.
- Each phase's PR targets `main`. This is intentional — each phase's diff accumulates all prior phases. Reviewers see the incremental slice via the PR's compare range.

### PR title template

```
[<FeatureTitle> Phase <N>] <phase topic> [<TICKET-NUMBER>]
```

Example: `[BLE Backup Client Phase 2] Port and tests [HSD-15235]`

### First commit = empty commit, pushed + `gh pr create --draft`

Before any real work lands:

```zsh
git switch -c "zakkhoyt/hsd-15235/ble_backup_client/phase_2/port_and_tests"
git commit --allow-empty -m "Initial commit for phase 2 — Port and tests"
git push -u origin HEAD
gh pr create \
  --title "[BLE Backup Client Phase 2] Port and tests [HSD-15235]" \
  --body-file .github/PULL_REQUEST_TEMPLATE/default_no_comments.md \
  --base main \
  --assignee '@me' \
  --draft
```

The draft PR becomes the single place the reviewer watches as real commits land.

### PR body discipline

- Populate the PR body immediately on creation — use the template at `.github/PULL_REQUEST_TEMPLATE/default_no_comments.md`.
- Update the body on **every** subsequent `git push` so it reflects the full phase, not just the latest commit. The body describes the phase as a whole, not any single commit.

### Conflict resolution

- `git pull origin main` to resolve conflicts. **Do not** `git rebase origin/main`.
- Never `git push --force` on a shared branch. If a push is rejected, investigate why and resolve; do not force through.

---

## 9. Quality Gates — Run Every Phase

In this exact order:

```zsh
cd iOS/hatch-sleep-app
bundle exec fastlane format_all
bundle exec fastlane lint_all
# Build + test on the iPhone 16 Pro Max simulator (see SCRATCHPAD_AI_PLANNING_BUILDING_AND_UNIT_TESTS.md)
xcodebuild test \
  -workspace Nightlight.xcworkspace \
  -scheme Nightlight_Development_iPhone_Only \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
# Only then:
git add <paths>
git commit -m "Phase N — <topic>"
git push
# Update PR body (gh pr edit) if scope of the phase changed
```

### Hard rules

- **Always verify tests pass locally before trusting CI.** Assuming CI green is not acceptable.
- **Never suppress lint or format rules.** `// swiftlint:disable:next …` and `// swiftformat:disable …` are not acceptable. Fix the underlying issue.
- **Never `--no-verify`** a commit to bypass hooks. If a hook fails, debug and fix.
- Re-run the full gate after any non-trivial change. Partial re-runs hide regressions.

### Simulator of record

**iPhone 16 Pro Max.** Not iPhone 17, not "latest". The project calibrates snapshot baselines against this simulator; other simulators will produce noisy snapshot diffs.

---

## 10. Known Pitfalls

The following are traps encountered in previous refactors. Read them before starting a new phase.

### Argument / flag string-value collisions

Flag names that are substrings of each other can match each other during parsing:

```
ENABLE_X            ← matches
ENABLE_X_CLIENT     ← also matches when parser does substring checks
```

When introducing `ENABLE_<NEW>_CLIENT`, rename any older `ENABLE_<NEW>` to a non-substring alternative (e.g. `ENABLE_<NEW>_LEGACY`, `ENABLE_<NEW>_V1`) **before** wiring the new arg, not after.

### Retroactive conformances double-declared

If the new module (or a module it transitively imports) already defines a `@retroactive` conformance on a stdlib or framework type, the legacy code cannot keep its own retroactive conformance for the same type — the compiler will flag "redundant conformance". Check transitive conformances via `@retroactive` before duplicating.

### Whitespace-only diffs are review noise

Reverting whitespace-only changes from touched files is part of phase 13 cleanup. Run `git diff --ignore-all-space` during final review; anything that disappears there is noise that must be reverted.

### Rename scope creep

A wide rename like `iotBle*` → `iotBLE*` can pull in 40+ unrelated files. Keep renames scoped to files already in the PR. If the rename has to propagate further, land that as a separate follow-up PR.

### `Configs/GitBranch.xcconfig` re-appears

If your repo has an `xcconfig` that records the current git branch name, it keeps re-appearing in diffs. Add a final step to phase 13 that checks for and removes this file if it is unwanted.

### `@MainActor` placement

Put `@MainActor` on the `Live` factory function only. The public struct itself should **not** be `@MainActor` — it is a value type with `@Sendable` closures, and actor-isolating the whole struct blocks it from being used off-main.

```swift
// On the struct: no @MainActor
public struct <Module>: Sendable { ... }

// On the factory: @MainActor
extension <Module> {
    @MainActor
    public static func live(...) -> Self { ... }
}
```

### `@NamedClientClosure` on every closure

Every closure property on the `Interface` struct gets the `@NamedClientClosure` macro. This makes call sites read as named-argument function calls instead of positional tuple calls.

```swift
@NamedClientClosure
public var establishConnection: @Sendable (_ macAddress: String, _ authToken: UInt32) async throws -> Void
```

Reference: other client modules in `HatchModules/Modules/Clients/` all follow this.

### `#LogAll` formatting — one arg per line

The formatter cares. So does the reviewer. Never:

```swift
// Forbidden — single-line:
#LogAll(.debug, category: "[<Module> modern]", message: "\(foo)")
```

Always:

```swift
#LogAll(
    .debug,
    category: "[<Module> modern]",
    message: "\(foo)"
)
```

Same rule for dictionary literals: one `key: value` pair per line.

### Late subscribers need replay

If the Coordinator publishes state (connection state, session state) and there are consumers that subscribe *after* the session is established, use `CurrentValueSubject` (not `PassthroughSubject`) so late subscribers get the current state on subscription.

### Dispatcher shouldn't leak internals

When the refactor spans multiple modules and there is a shared dispatcher, resist the urge to add new public publishers to the dispatcher. Instead:

1. Define a lightweight struct (e.g. `TrafficBridge`) that owns the shared subjects.
2. Inject it into both the dispatcher and the UI observer.
3. The dispatcher forwards to it; the UI observer sinks from it.

The dispatcher's public surface stays flat.

### Comments — style and content

- Use `///` doc comments for **every** public type, var, function, property. Use `//` only for inline *why* comments on implementation details.
- Do not mention the Jira ticket number in code comments. That belongs in the PR body.
- Do not mention "phase N" or "legacy equivalent at line M" in code comments. That is PR-body material.
- Strip `#warning` markers before the final phase. `#warning` is a scratch-pad tool, not merge-ready content.

---

## 11. User Preferences (Terse, Non-Obvious)

Short list of the user's recurring preferences. Not all of these are in style guides; they come from direct review feedback.

- **Short status readouts, not long plan dumps.** When asked "where are we", reply with a paragraph or a small table that surfaces *what is next*, not a rewritten full plan.
- **Always `git pull origin main`, never `git rebase`.**
- **Never** skip pre-commit hooks (`--no-verify`) or signing. If a hook fails, debug and fix.
- **Never** force push.
- **Always** verify locally before trusting CI. Read CI logs only to confirm a fix that already passes locally.
- **Read AI instructions + chat history at the start of every fresh session.** The user explicitly requests this on session resumes; do it unprompted.
- **Use `#LogAll`** in `HatchModules/` (not `logger.`). If a sibling module uses `logger.`, mirror that for consistency within that file, but prefer `#LogAll` in new code.
- **Use `@NamedClientClosure`** on every closure in the `Interface` struct.
- **One request per response**: do the requested thing, then report. Do not bundle extra work into the same reply unless asked.

---

## 12. Worked Example — HatchIoTBLEBackupClient

This is the concrete refactor that produced this skill. Substitute these names with your own when applying the skill.

### Source → destination

| Aspect             | Before                                                                                                                                              | After                                                                                        |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Legacy file        | `iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoTBLEDevice/IoTBLEBackup/IoTBLEBackup.swift` (formerly `IoTBLEBackchannel.swift`) | — (stays in place; dual-path enum routes around it)                                          |
| New module root    | —                                                                                                                                                   | `iOS/hatch-sleep-app/HatchModules/Modules/Clients/HatchIoTBLEBackupClient/`                  |
| Target name        | —                                                                                                                                                   | `HatchIoTBLEBackupClient`                                                                    |
| Public struct      | —                                                                                                                                                   | `IoTBLEBackupClient`                                                                         |
| Coordinator file   | —                                                                                                                                                   | `Sources/Coordinator/IoTBLEBackupCoordinator.swift` (= the extracted legacy code)            |
| Live factory       | —                                                                                                                                                   | `@MainActor public static func live(bleClient:observabilityClient:) -> Self`                 |
| Mocks              | —                                                                                                                                                   | `static var noOp`, `static func failing(error:)`                                             |
| Feature flag       | —                                                                                                                                                   | `FeatureFlag.enableBLEBackupClient = "enable_ble_backup_client"`                             |
| Argument           | `Argument.enableBLEBackup = "ENABLE_BLE_BACKCHANNEL"` (renamed to avoid substring collision)                                                        | `Argument.enableBLEBackupClient = "ENABLE_BLE_BACKUP_CLIENT"`                                |
| Toggle helper      | —                                                                                                                                                   | `IoTBLEBackupFeature.shouldUseNewBLEBackupClient()` — OR of Statsig + Argument + ProcessInfo |
| Dual-path enum     | —                                                                                                                                                   | `enum IoTBLEBackupController { case legacy(IoTBLEBackup); case modern(IoTBLEBackupClient) }` |
| Dependent refactor | `IoTDeviceConnectionDispatcher`, `IoTShadowAdaptorConnectionScanner` absorbed shared subjects as a new `TrafficBridge` struct                       | —                                                                                            |
| UI parity          | `IoTCommunicationProtocolStatusView` wired through the same traffic/event publishers for both paths                                                 | —                                                                                            |
| PR                 | [hatch-baby/mobile #1752](https://github.com/hatch-baby/mobile/pull/1752)                                                                           | (merged)                                                                                     |

### Module tree delivered

```
HatchModules/Modules/Clients/HatchIoTBLEBackupClient/
├── Sources/
│   ├── IoTBLEBackupClient+Interface.swift
│   ├── IoTBLEBackupClient+Live.swift
│   ├── IoTBLEBackupClient+Mocks.swift
│   ├── Coordinator/IoTBLEBackupCoordinator.swift
│   ├── Features/IoTBLEBackupFeature.swift
│   ├── Models/IoTBLEBackupAuthenticationData.swift
│   ├── Models/IoTBLEBackupError.swift
│   ├── Models/IoTBLEBackupEvent.swift
│   ├── UnifiedLogger.swift
│   └── HatchIoTBLEBackupClient.docc/
│       ├── HatchIoTBLEBackupClient.md
│       └── Resources/HatchIoTBLEBackupClient.svg
├── TestSupport/Failing.swift
└── Tests/
    ├── HatchIoTBLEBackupClient.xctestplan
    └── UnitTests/
        ├── UnitTests.swift
        └── UnitSnapshotTests.swift
```

### Interface file shape

```swift
@preconcurrency public import Combine
import Foundation
import HatchClientMacros

public struct IoTBLEBackupClient: Sendable {
    @NamedClientClosure
    public var establishConnection: @Sendable (_ macAddress: String, _ authToken: UInt32) async throws -> Void

    @NamedClientClosure
    public var publishShadow: @Sendable (_ data: Data) async throws -> Void

    public var disconnect: @Sendable () -> Void

    public var event: AnyPublisher<IoTBLEBackupEvent, Never>

    public init(
        establishConnection: @escaping @Sendable (_ macAddress: String, _ authToken: UInt32) async throws -> Void,
        publishShadow: @escaping @Sendable (_ data: Data) async throws -> Void,
        disconnect: @escaping @Sendable () -> Void,
        event: AnyPublisher<IoTBLEBackupEvent, Never>
    ) {
        self.establishConnection = establishConnection
        self.publishShadow = publishShadow
        self.disconnect = disconnect
        self.event = event
    }
}
```

### Live factory shape

```swift
@MainActor
public static func live(
    bleClient: BLEClient,
    observabilityClient: HatchObservabilityClient
) -> Self {
    let eventSubject = CurrentValueSubject<IoTBLEBackupEvent?, Never>(nil)
    var coordinator: IoTBLEBackupCoordinator?
    var coordinatorEventSubscription: AnyCancellable?

    return IoTBLEBackupClient(
        establishConnection: { macAddress, authToken in
            let newCoordinator = try await Task { @MainActor in
                coordinator?.disconnect()                    // tear down old
                coordinatorEventSubscription = nil
                let c = IoTBLEBackupCoordinator(
                    macAddress: macAddress,
                    bleClient: bleClient,
                    observabilityClient: observabilityClient
                )
                coordinator = c
                coordinatorEventSubscription = c.eventSubject
                    .sink { event in eventSubject.send(event) }
                return c
            }.value
            try await newCoordinator.establishConnection(authToken: authToken)
        },
        // ... publishShadow, disconnect ...
        event: eventSubject.compactMap { $0 }.eraseToAnyPublisher()
    )
}
```

### Mocks file shape

```swift
extension IoTBLEBackupClient {
    public static var noOp: Self {
        let eventSubject = PassthroughSubject<IoTBLEBackupEvent, Never>()
        return IoTBLEBackupClient(
            establishConnection: { _, _ in },
            publishShadow: { _ in },
            disconnect: {},
            event: eventSubject.eraseToAnyPublisher()
        )
    }

    public static func failing(error: some Swift.Error & Sendable) -> Self {
        let eventSubject = PassthroughSubject<IoTBLEBackupEvent, Never>()
        return IoTBLEBackupClient(
            establishConnection: { _, _ in throw error },
            publishShadow: { _ in throw error },
            disconnect: {},
            event: eventSubject.eraseToAnyPublisher()
        )
    }
}
```

### Phased PR chain that was shipped

| Phase | PR                                                                                    |
| ----- | ------------------------------------------------------------------------------------- |
| 1-13  | [#1752 — BLE Backup Client migration](https://github.com/hatch-baby/mobile/pull/1752) |

(Earlier ArgumentKit-style refactors followed the same phased pattern: PRs #1563, #1564, #1565, #1569, #1573, #1574, #1593, #1594.)

---

## 13. Related Skills and References

### Use this skill alongside

| Skill                                  | Role                                                                   |
| -------------------------------------- | ---------------------------------------------------------------------- |
| `.claude/skills/ios-architecture/`     | Core Client-pattern architectural vocabulary                           |
| `.claude/skills/api-client-generator/` | Reuse its Package.swift / test plan / scheme registration instructions |
| `.claude/skills/swift-testing/`        | Swift Testing `@Test` / `#expect` conventions for new tests            |
| `.claude/skills/format/`               | Runs `bundle exec fastlane format_all`                                 |
| `.claude/skills/create-pull-request/`  | Produces the draft PR with the correct title + body template           |
| `.claude/skills/review-response/`      | Structured workflow for CodeRabbit / reviewer comments                 |

### Repository documentation to consult

| Doc                                                  | Relevance                                                |
| ---------------------------------------------------- | -------------------------------------------------------- |
| `docs/patterns/ios-architecture.md`                  | Canonical Client-pattern description (§25-63)            |
| `docs/workflows/ios-modular-dependency-container.md` | How modules register with the DI container               |
| `iOS/hatch-sleep-app/Documents/ADR/`                 | Architecture Decision Records                            |
| `.claude/skills/api-client-generator/SKILL.md`       | Package.swift / xctestplan / xcscheme registration sites |

### External references

- [Point-Free: Designing Dependencies](https://www.pointfree.co/collections/dependencies) — the conceptual foundation for the Client pattern.
- [Swift Argument Parser](https://apple.github.io/swift-argument-parser/) — help-text style followed by `Argument` definitions.
- [swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing) — snapshot library used by `UnitSnapshotTests.swift`.
- [Swift Testing](https://developer.apple.com/documentation/testing) — `@Test` / `#expect` framework used in new test files.

---

## Self-Check Before Finishing Any Phase

Before `git push` on any phase branch:

- [ ] Format + lint + build + test all pass locally on iPhone 16 Pro Max simulator.
- [ ] No `// swiftlint:disable` or `// swiftformat:disable` directives were added.
- [ ] No `#warning` markers in merged code.
- [ ] No `[zakk …]` or scratch scopes in log messages — only `[<Module> <scope>]`.
- [ ] `#LogAll` calls are multi-line (one arg per line, one dict pair per line).
- [ ] All public declarations have `///` doc comments.
- [ ] No Jira ticket number or "phase N" markers inside code comments.
- [ ] Whitespace-only diffs reverted.
- [ ] Rename scope stayed inside files already in this PR.
- [ ] Branch name matches `${git_author}/${jira_ticket_lower}/${feature_topic}/phase_${N}/${phase_topic}`.
- [ ] PR title matches `[<FeatureTitle> Phase <N>] <phase topic> [<TICKET-NUMBER>]`.
- [ ] PR body describes the **entire phase**, not just the latest commit.
- [ ] Target simulator is iPhone 16 Pro Max, not any other.
- [ ] No `git rebase`; merged `main` via `git pull origin main` if needed.
- [ ] No `git push --force`.
