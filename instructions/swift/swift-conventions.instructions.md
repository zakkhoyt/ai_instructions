---
applyTo: "**/*.swift"
---

# Swift Coding Conventions

> **AI Assistant Reference Guide**
> This document outlines Swift coding conventions based on the Hatch Mobile codebase. Use these patterns when working on Swift projects to maintain consistency and quality.

---

## Table of Contents

- [Repository Defaults & Tooling](#repository-defaults--tooling)
- [Project Architecture](#project-architecture)
- [File Organization](#file-organization)
- [Naming Conventions](#naming-conventions)
- [Type Design Patterns](#type-design-patterns)
- [Access Control](#access-control)
- [Error Handling](#error-handling)
- [Concurrency](#concurrency)
- [Documentation](#documentation)
- [Formatting Rules](#formatting-rules)
- [Code Quality Rules](#code-quality-rules)
- [Common Patterns](#common-patterns)

---

## Repository Defaults & Tooling

### Detecting the Hatch Nightlight App

Assume you are working on the Hatch Nightlight iOS app when any of these files exist:

- `iOS/hatch-sleep-app/Nightlight.xcworkspace`
- `iOS/hatch-sleep-app/Nightlight.xcodeproj`
- `iOS/hatch-sleep-app/HatchModules/Package.swift`

Once detected, follow the build/test defaults below instead of inventing new schemes or destinations.

### Toolchain and Command Requirements

1. **Verify Xcode 26.x every time**

     ```zsh
     xcodebuild_path="$(xcrun --find xcodebuild 2>/dev/null)"
     xcode_version="$("$xcodebuild_path" -version | head -n1)"
     if [[ "$xcode_version" != "Xcode 26."* ]]; then
         echo "ERROR: expected Xcode 26.x but found: $xcode_version" >&2
         exit 1
     fi
     ```

2. **Prefer `xcodebuild` over `swift *`** – most Hatch code targets iOS, so simulator and Designed for iPhone destinations are required. Only reach for `swift build/test/run` when a module is explicitly macOS-only.

3. **Use the default Nightlight scheme/destinations**

     - Debug builds on macOS (Designed for iPhone):

         ```zsh
         cd iOS/hatch-sleep-app && \
         set -o pipefail && \
         nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" build \
             -workspace ./Nightlight.xcworkspace \
             -scheme Nightlight_Development_iPhone_Only \
             -destination 'platform=macOS,variant=Designed for iPhone'
         ```

     - Tests on simulator (ships with Xcode 26):

         ```zsh
         cd iOS/hatch-sleep-app && \
         set -o pipefail && \
         nocorrect "$(xcrun --find xcodebuild 2>/dev/null)" test \
             -workspace ./Nightlight.xcworkspace \
             -scheme Nightlight_Development_iPhone_Only \
             -destination "platform=iOS Simulator,name=iPhone 17"
         ```

     Designed for iPhone destinations almost never run XCTest successfully, so always switch back to the iPhone 17 simulator for unit/UI tests.

4. **Leverage existing helper scripts** – `iOS/hatch-sleep-apple/Scripts/the-tool.zsh --help` prints validated command templates. Prefer those wrappers over handwritten pipelines whenever they already solve the task.

These defaults keep the documentation, automated tooling, and human workflows aligned as Hatch migrates to Xcode 26/iOS 26.

---

## Project Architecture

### Client Pattern (Point-Free Style)

Structure reusable components using the "Client" pattern with clear separation between interface, live implementation, and test mocks:

```swift
// Interface - Define the public API
public struct BLEClient: Sendable {
    public var state: CurrentValueSubject<CBManagerState, Never>
    public var startScanning: @Sendable (_ hardwareProducts: [HardwareProduct]) -> Void
    public var stopScanning: @Sendable () -> Void
    public var sendCommand: @Sendable (_ command: BLECommand) async throws -> Response
    
    public init(
        state: CurrentValueSubject<CBManagerState, Never>,
        startScanning: @escaping @Sendable (_ hardwareProducts: [HardwareProduct]) -> Void,
        stopScanning: @escaping @Sendable () -> Void,
        sendCommand: @escaping @Sendable (_ command: BLECommand) async throws -> Response
    ) {
        self.state = state
        self.startScanning = startScanning
        self.stopScanning = stopScanning
        self.sendCommand = sendCommand
    }
}

// Live Implementation - In separate file: ClientName+Live.swift
extension BLEClient {
    @MainActor
    public static func live(/* dependencies */) -> Self {
        let state = CurrentValueSubject<CBManagerState, Never>(.unknown)
        let coordinator = BLEClientCoordinator(/* ... */)
        
        return BLEClient(
            state: state,
            startScanning: { hardwareProducts in
                Task { @MainActor in
                    coordinator.startScanning(hardwareProducts: hardwareProducts)
                }
            },
            stopScanning: {
                Task { @MainActor in
                    coordinator.stopScanning()
                }
            },
            sendCommand: { command in
                try await Task { @MainActor in
                    try await coordinator.sendCommand(command: command)
                }.value
            }
        )
    }
}

// Test Mocks - In separate file: ClientName+Mocks.swift
extension BLEClient {
    public static var noOp: Self {
        let state = CurrentValueSubject<CBManagerState, Never>(.unknown)
        return BLEClient(
            state: state,
            startScanning: { _ in },
            stopScanning: {},
            sendCommand: { _ in Response() }
        )
    }
}
```

### Dependency Injection

- **Prefer init injection** over global dependencies
- Use `@MainActor` for properties requiring main thread access
- Inject dependencies explicitly in constructors

---

## File Organization

### File Structure

```swift
// 1. File header (if present)
//  FileName.swift
//  ModuleName
//
//  Created by Author on Date
//  Copyright hatch.co, Year.
//

// 2. Imports (grouped and organized)
@preconcurrency public import Combine
public import CoreBluetooth
import HatchClientMacros
import HatchLoggerMacros

// 3. Main type definition with MARK comments for organization
public struct TypeName {
    // MARK: - Properties
    
    // MARK: - API (scanning)
    
    // MARK: - API (connection)
    
    // MARK: - init
}

// 4. Extensions (organized by conformance or functionality)
extension TypeName: Equatable { }
extension TypeName { /* Helper methods */ }
```

### File Naming Patterns

- **Interface file**: `ClientName+Interface.swift` (or just `ClientName.swift`)
- **Live implementation**: `ClientName+Live.swift`
- **Mock implementations**: `ClientName+Mocks.swift`
- **Extensions**: `TypeName+ProtocolName.swift` or `TypeName+Functionality.swift`
- **Test support**: Place in `TestSupport/` directory

---

## Naming Conventions

### General Rules

- **Use descriptive names**: Prefer clarity over brevity
- **Avoid abbreviations**: Use `message` not `msg`, `configuration` not `config`
- **Exception for common terms**: `URL`, `ID`, `UUID`, `API`, `HTTP`, `BLE`, `IoT`

### Type Names

```swift
// Structs, Classes, Enums - UpperCamelCase
struct BLEClient { }
class BLEClientCoordinator { }
enum BLEResultsType { }

// Protocols - UpperCamelCase, often with "-able" or "-ing" suffix
protocol BLEInstructable { }
protocol EventOperationDelegate { }
```

### Function and Variable Names

```swift
// Functions and variables - lowerCamelCase
func startScanning(hardwareProducts: [HardwareProduct]) { }
var connectionEvent: AnyPublisher<ConnectionEvent, Never>
let discoveredDevices: [HatchIoTBLEDevice] = []

// Boolean properties - use "is", "has", "should", "can"
var isExecuting: Bool
var hasConnection: Bool
var shouldRetry: Bool

// Closures - descriptive action names
var didConnect: (_ peripheral: Peripheral) -> Void
var getFirmwareUpdateManifest: @Sendable (_ query: Query) async throws -> Manifest
```

### Constants

```swift
// Use lowerCamelCase for constants
let kContentFetchTimeout = EventOperation.Timeout(duration: 60)
private let accessQueue = DispatchQueue(label: "Threading Queue")
```

### Enum Cases

```swift
// Enum cases - lowerCamelCase
enum BLEResultsType: String, Codable, Sendable {
    case scan
    case connect = "connection"  // Raw values when needed
    case reconnect
}
```

### Developer-Only Functions

Prefix with `d_` to indicate developer/debug functionality:

```swift
case d_uart(instruction: any BLEInstructable)
case d_json(instruction: any BLEInstructable)
```

---

## Type Design Patterns

### Prefer Structs Over Classes

Use structs for value semantics and automatic thread safety:

```swift
// ✅ Preferred
public struct FirmwareUpdateClient {
    public var queryEvent: PassthroughSubject<FirmwareUpdate.QueryEvent, Never>
    public var getFirmwareUpdateManifest: @Sendable (_ query: Query) async throws -> Manifest
}

// ❌ Avoid unless reference semantics needed
public class FirmwareUpdateClient { }
```

### Use Classes When Necessary

Use classes when you need:
- Reference semantics
- Inheritance
- `@MainActor` for coordinating state

```swift
@MainActor
final class BLEClientCoordinator {
    // Coordinator pattern for managing stateful operations
}
```

### Protocol Design

```swift
// Protocols should be focused and composable
protocol EventOperationDelegate: AnyObject {
    func eventOperation(_ operation: EventOperation, updateMessage message: String)
    func eventOperation(_ operation: EventOperation, finished result: Result<T, Error>)
}
```

### Enums for State

```swift
public enum BLECommand: Sendable, Equatable {
    case automatic(instruction: any BLEInstructable, arguments: String = "")
    case d_uart(instruction: any BLEInstructable, arguments: String = "")
    case d_json(instruction: any BLEInstructable, arguments: String = "")
    
    // Computed properties for common operations
    public var route: String {
        switch self {
        case .automatic: "automatic"
        case .d_uart: "uart"
        case .d_json: "json"
        }
    }
}
```

---

## Access Control

### Access Control Hierarchy

```swift
// 1. Public - API surface
public struct ClientName { }

// 2. Internal (default) - module-only
struct InternalType { }

// 3. Private - file-scoped
private var subscriptions = Set<AnyCancellable>()

// 4. Fileprivate - file-scoped (use sparingly)
fileprivate var sharedState: State
```

### Access Control Best Practices

- **Avoid `internal` keyword**: It's the default, omitting it reduces noise
- **Mark implementation details `private`**
- **Use `public` judiciously**: Only expose what's necessary
- **`fileprivate` sparingly**: Use when sharing between extensions in same file

```swift
// ✅ Good - omit internal
struct MyType {
    var property: String  // Implicitly internal
}

// ❌ Bad - explicit internal is redundant
struct MyType {
    internal var property: String  // Lint warning
}
```

### Extension Access Control

Place access control on declarations, not extensions:

```swift
// ✅ Preferred
extension ClientName {
    public static func live() -> Self { }
    private func helperMethod() { }
}

// ❌ Avoid
public extension ClientName {
    static func live() -> Self { }
}
```

---

## Error Handling

### Error Types

Define errors as nested types within their context:

```swift
public struct BLEClient {
    public enum Error: Swift.Error, Equatable, Sendable {
        case unauthorized
        case timeout
        case deviceNotFound(UUID)
        case communicationFailed(String)
    }
}
```

### Throwing Functions

```swift
// Async throwing functions
public var sendCommand: @Sendable (_ command: BLECommand) async throws -> Response

// Result types for complex error handling
func eventOperation<T>(_ operation: EventOperation, finished result: Result<T, Error>)
```

### Error Messages

Always provide descriptive error messages:

```swift
// ✅ Good
assertionFailure("Device must be connected before sending commands")
preconditionFailure("encryptionKey cannot be empty")
fatalError("Coordinator must be initialized before use")

// ❌ Bad - empty messages not allowed (lint error)
assertionFailure()
preconditionFailure()
fatalError()
```

---

## Concurrency

### Sendable Conformance

Mark types as `Sendable` when thread-safe:

```swift
public struct BLEClient: Sendable { }
public enum BLECommand: Sendable { }
```

### @Sendable Closures

Use `@Sendable` for closures crossing concurrency boundaries:

```swift
public var startScanning: @Sendable (_ hardwareProducts: [HardwareProduct]) -> Void
public var sendCommand: @Sendable (_ command: BLECommand) async throws -> Response
```

### @MainActor Usage

Use `@MainActor` for types that must run on main thread:

```swift
// ViewModels must use @MainActor (lint enforced)
@Observable
@MainActor
final class CBCentralManagerClientViewModel {
    // All properties and methods run on main actor
}

// Coordinators managing UI-related state
@MainActor
final class BLEClientCoordinator {
    // Thread-safe state management
}
```

### Weak References in Async Contexts

Use `[weak self]` in async contexts to prevent retain cycles:

```swift
Task { @MainActor [weak device] in
    guard let device else {
        throw CommunicationEvent.Error.weakDeviceIsNil
    }
    // Use device safely
}
```

### @preconcurrency Import

Use for libraries not yet marked as Sendable:

```swift
@preconcurrency public import Combine
@preconcurrency import CoreBluetooth
```

---

## Documentation

### Documentation Comments

Use triple-slash comments for public APIs:

```swift
/// Communicate with a Hatch device using `BLE`
///
/// # Investigate. Associate. Communicate.
/// * **Investigate** - Scan the environment for potential Hatch devices
/// * **Associate** - Establish a connection with a Hatch device
/// * **Communicate** - Send commands and receive responses
public struct BLEClient: Sendable {
    /// Fetches firmware update information from Hatch's back end
    /// - Parameter query: An instance of ``FirmwareUpdate/Query``
    /// - Returns: A ``FirmwareUpdate/Manifest`` indicating if update is needed
    /// - Throws: Network or parsing errors
    public var getFirmwareUpdateManifest: @Sendable (_ query: Query) async throws -> Manifest
}
```

### Inline Comments

```swift
// Use double-slash for inline comments explaining "why", not "what"

// TODO: zakkhoyt - Consolidate sendCert into sendCommand
// - Jira: https://hatchbaby.atlassian.net/browse/HSD-12531
public var sendCertificate: @Sendable (/* ... */) async throws -> Response

// MARK: comments for organization
// MARK: - Properties
// MARK: - API (scanning)
// MARK: - init
```

### TODO Comments

Format TODOs consistently with Jira links:

```swift
// TODO: author - Description of work needed
// - Jira: https://hatchbaby.atlassian.net/browse/PROJECT-123

// FIXME comments are ephemeral - must be resolved before merging (lint enforced)
```

---

## Formatting Rules

### Indentation

- **4 spaces per indent level** (no tabs)
- **Xcode indentation enabled**
- Use SwiftFormat with `--xcodeindentation enabled`

### Line Length

- **Warning at 160 characters**
- **Error at 200 characters**
- Ignore comments, URLs, function declarations, interpolated strings

### Whitespace

```swift
// No trailing whitespace on non-blank lines
// Single blank line after imports
import Foundation

public struct MyType { }

// Blank lines between scopes
func firstFunction() { }

func secondFunction() { }

// No blank lines between imports
import CoreBluetooth
import Combine
import Foundation
```

### Wrapping Arguments

```swift
// Function definitions - wrap before first argument if needed
func startScanning(
    hardwareProducts: [HardwareProduct],
    includeDevicesInBLEBackupMode: Bool,
    allowDuplicateDiscoveries: Bool
) {
    // Implementation
}

// Function calls - wrap before first argument if needed
coordinator.startScanning(
    hardwareProducts: hardwareProducts,
    includeDevicesInBLEBackupMode: includeDevicesInBLEBackupMode,
    allowDuplicateDiscoveries: allowDuplicateDiscoveries
)

// Collections - wrap before first element if needed
let array = [
    "first",
    "second",
    "third",
]
```

### Commas

```swift
// No trailing commas (inline style)
let array = ["a", "b", "c"]

// Exception: multiline collections can have trailing comma
let array = [
    "a",
    "b",
    "c",  // OK in multiline
]
```

### Operators

```swift
// Spaces around operators
let sum = a + b
let range = 0..<10  // Exception: no space for ranges

// No spaces for range operators
let closedRange = 0...10
let halfOpenRange = 0..<10
```

### Control Flow

```swift
// else on same line as closing brace
if condition {
    // ...
} else {
    // ...
}

// guard else automatic formatting
guard let value = optional else {
    return
}
```

---

## Code Quality Rules

### Enforced Rules (Lint Errors)

```swift
// ✅ Use struct/class/enum name, not .init
let client = BLEClient()

// ❌ Avoid .init (lint error)
let client: BLEClient = .init()

// ✅ Provide error messages
assertionFailure("Device must be connected")
preconditionFailure("Invalid state")
fatalError("Unimplemented code path")

// ❌ Empty error messages (lint error)
assertionFailure()
preconditionFailure()
fatalError()

// ✅ Use UserDefaultsClient instead of UserDefaults
let client = UserDefaultsClient.live()

// ❌ Direct UserDefaults usage (lint error)
let defaults = UserDefaults.standard

// ✅ Use proper self unwrapping
guard let self else { return }

// ❌ Avoid safeSelf pattern (lint error)
guard let safeSelf = self else { return }
```

### Modifier Order

```swift
// Correct order: access, convenience, static/class, lazy
public static func live() -> Self { }
private lazy var formatter: DateFormatter = { }()
```

### Number Formatting

```swift
// Hexadecimal - uppercase
let hex = 0xFF

// No grouping separators (per project config)
let large = 1000000
let binary = 0b11110000
```

### Self Usage

```swift
// self only in initializers (unless required for disambiguation)
init(value: String) {
    self.value = value  // Required in init
}

func doSomething() {
    value = "new"  // No self needed
}

// Note: SwiftFormat `--selfrequired` for certain closures (e.g., os.Logger)
logger.info("Value: \(self.value, privacy: .public)")  // Keep self
```

### Redundant Type Annotations

```swift
// ✅ Inferred types
let name = "test"
let array: [String] = []  // OK when type can't be inferred

// ❌ Redundant (swiftformat will remove)
let name: String = "test"
```

### Semicolons

```swift
// Never use semicolons
let a = 1
let b = 2

// ❌ Avoid (swiftformat will remove)
let a = 1; let b = 2
```

---

## Common Patterns

### Combine Publishers

```swift
// Use PassthroughSubject for events
private let scanEvent = PassthroughSubject<ScanEvent, Never>()
public var scanEvent: AnyPublisher<ScanEvent, Never> {
    scanEventSubject.eraseToAnyPublisher()
}

// CurrentValueSubject for state
private let state = CurrentValueSubject<CBManagerState, Never>(.unknown)
public var state: CurrentValueSubject<CBManagerState, Never>
```

### Subscription Management

```swift
// Dictionary-based subscription storage with keys
private var subscriptions = [SubscriptionKey: AnyCancellable]()

enum SubscriptionKey: String {
    case state
    case scanState
}

// Store with key
publisher.sink { value in
    // Handle
}
.store(in: &subscriptions, key: .state)

// Or use Set for simpler cases
private var subscriptions = Set<AnyCancellable>()
publisher.sink { }.store(in: &subscriptions)
```

### Extensions for Identifiable

```swift
// Use @retroactive for conformances to external protocols
extension CBService: @retroactive Identifiable {
    public var id: String {
        uuid.uuidString
    }
}
```

### Computed Properties for Enum Cases

```swift
public enum BLECommand: Sendable {
    case automatic(instruction: any BLEInstructable, arguments: String)
    case d_uart(instruction: any BLEInstructable, arguments: String)
    
    // Extract associated values via computed properties
    public var instruction: any BLEInstructable {
        switch self {
        case .automatic(let instruction, _): instruction
        case .d_uart(let instruction, _): instruction
        }
    }
    
    public var arguments: String {
        switch self {
        case .automatic(_, let arguments): arguments
        case .d_uart(_, let arguments): arguments
        }
    }
}
```

### Operation Pattern (Legacy)

For sequential async operations with timeouts:

```swift
class EventOperation: Operation {
    struct Timeout {
        let duration: TimeInterval
        let debugErrorMessage: String?
    }
    
    private var _executing = false
    override var isExecuting: Bool {
        get { _executing }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    // Finish must be called in all code paths
    func finish<T>(result: Result<T, Error>) {
        // Implementation
    }
}
```

### Logger Usage

```swift
// Import os.Logger via macro or directly
import os

let logger = Logger(subsystem: "com.hatch", category: "BLE")

// Specify privacy levels
logger.debug("Scanning for devices: \(devices, privacy: .public)")
logger.info("Connection established")
logger.error("Failed with error: \(error.localizedDescription)")
```

---

## Tools Configuration

### SwiftFormat

Key settings from `.swiftformat`:

```bash
--swiftversion 5.10
--enable blankLineAfterImports
--enable blankLinesBetweenImports
--enable blockComments
--enable isEmpty
--enable wrapEnumCases
--enable wrapSwitchCases
--elseposition same-line
--patternlet inline
--xcodeindentation enabled
--self init-only
--semicolons never
--commas inline
--trimwhitespace nonblank-lines
```

### SwiftLint

Key opt-in rules:

```yaml
opt_in_rules:
  - array_init
  - closure_spacing
  - collection_alignment
  - implicit_return
  - multiline_arguments
  - multiline_parameters
  - multiline_literal_brackets
  - unused_import
  - vertical_whitespace_closing_braces
```

### Custom Lint Rules

Important project-specific rules:
- No `@Dependency` in models (use `@PublishedDependency`)
- ViewModels must use `@MainActor`
- Use `UserDefaultsClient` instead of `UserDefaults`
- Prefer `self` over `safeSelf` unwrapping
- Use type name over `.init`
- FIXME comments must be resolved before merge

---

## Anti-Patterns to Avoid

### ❌ Don't Use

```swift
// Image loading - use ContentImage not AsyncImage (no caching)
AsyncImage(url: url)  // Lint error

// Preprocessor - use runtime checks instead
#if HATCH_DEVELOPMENT  // Lint error - use isDev()
#if HATCH_RELEASE  // Lint error - use BuildMode check

// Direct UserDefaults
UserDefaults.standard  // Lint error

// Unnamed error messages
fatalError()  // Lint error

// .init syntax
let client: BLEClient = .init()  // Lint error

// Unnecessary internal
internal func doSomething()  // Lint warning

// UIWindow frame init (SwiftUI root view issue)
UIWindow(frame: bounds)  // Lint error - use UIWindow(windowScene:)
```

---

## Summary Checklist

When writing Swift code:

- ✅ Use Client pattern for reusable components
- ✅ Prefer structs over classes
- ✅ Mark types as `Sendable` when appropriate
- ✅ Use `@MainActor` for ViewModels and coordinators
- ✅ Provide descriptive names (avoid abbreviations)
- ✅ Document public APIs with doc comments
- ✅ Use `private` for implementation details
- ✅ Always provide error messages in assertions
- ✅ Wrap arguments before first parameter when needed
- ✅ Use proper self unwrapping: `guard let self`
- ✅ Avoid explicit `internal` access control
- ✅ Use MARK comments to organize code
- ✅ Link TODOs to Jira tickets
- ✅ Run SwiftFormat and SwiftLint before committing

---

## References

- [SwiftFormat Rules](https://github.com/nicklockwood/SwiftFormat/blob/master/Rules.md)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)
- [Point-Free Dependencies](https://github.com/pointfreeco/swift-dependencies)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
