## Local Development Setup

> **Developer-Specific Configuration**

This document contains local development preferences and shortcuts for this specific developer's setup.

### iOS Development Tools & Simulators

#### Xcode Build Tools
For all iOS development tasks, use the `mcp_xcodebuild-mc_*` family of tools for building, testing, and running applications.

#### Main Xcode Projects
- **Nightlight_Development** - Primary development project (for Xcode project-based operations)
- **WalkingSkeletonApp** - Secondary test/skeleton application
- **Nightlight.xcworkspace** - Primary workspace containing all integrated dependencies (use for SPM/module tests)

#### Workspace vs Project
- Use **Nightlight.xcworkspace** for SPM unit tests and comprehensive module testing
- Use **Nightlight.xcodeproj** for specific non-integrated features

#### Simulator Selection

**For Testing:**
- Device: iPhone 16 Pro Max (iOS 18.2)
- Identifier: `F83B369A-98BD-462C-A826-43771324C4A3`

**For Building & Other Tools:**
- Device: iPhone 16 Pro Max (iOS 18.6)
- Identifier: `E9AD42C0-9DC4-4BB7-85AB-39659BFD7B47`

When using simulator-related tools (build, run, test, install), specify the appropriate simulator by its UUID or name based on the task type.

### Running SPM Unit Tests

#### Prerequisites
- Use `Nightlight.xcworkspace` (not `.xcodeproj`)
- Use the `NightlightUnitTests` scheme (not a specific module scheme)
- Target simulator: `F83B369A-98BD-462C-A826-43771324C4A3` (Testing device)

#### Command for Running Tests
```
mcp_xcodebuild-mc_test_sim(
  workspacePath: "/Users/gabriel-hatch/workspace/mobile/iOS/hatch-sleep-app/Nightlight.xcworkspace",
  scheme: "NightlightUnitTests",
  simulatorId: "F83B369A-98BD-462C-A826-43771324C4A3"
)
```

#### Key Points
- The `NightlightUnitTests` scheme runs all SPM unit tests across HatchModules
- Individual test modules are integrated into `NightlightUnitTests` via xcodebuild compilation
- Tests for Swift Packages (e.g., `HatchIoTDeviceConnectionClientTests`) are included in the workspace build
- Results show total test counts and any failures/crashes for the entire suite