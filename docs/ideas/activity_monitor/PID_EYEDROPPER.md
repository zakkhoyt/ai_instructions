# PID Eyedropper Monitor

![activity_monitor](../../../Documents/notes/docs/images/icons/activity_monitor.png) `Activity Monitor` style metrics are great once you already know the PID, but the intent here is to bolt on a crosshair picker so you can jump from any arbitrary window to the owning process and immediately inspect CPU, memory, and signing information without manual detective work.

---

## Goals

- Build a point-and-filter workflow that complements ![activity_monitor](../../../Documents/notes/docs/images/icons/activity_monitor.png) `Activity Monitor`, so double-clicking a sampled process can still launch the stock inspector while this tool accelerates discovery.
- Target ![macos](../../../Documents/notes/docs/images/icons/macos.png) `macOS` Sonoma and newer so we can rely on modern Accessibility API behaviors without legacy shims.
- Keep the workflow inside ![xcode](../../../Documents/notes/docs/images/icons/xcode.png) `Xcode`, the same host that already exposes ![accessibility_inspector](../../../Documents/notes/docs/images/icons/accessibility_inspector.png) `Accessibility Inspector` via Xcode > Open Developer Tool, so developers can reuse signing setups ([Apple – Accessibility Inspector](https://developer.apple.com/documentation/accessibility/accessibility-inspector)).

---

## Observations About Existing Tools

- ![accessibility_inspector](../../../Documents/notes/docs/images/icons/accessibility_inspector.png) `Accessibility Inspector` provides the Target an element button (eyedropper) to focus on whichever UI element sits under the cursor, surfacing Basic, Actions, Element, and Hierarchy panes for debugging accessibility data ([Apple – Inspecting the accessibility of the screens in your app](https://developer.apple.com/documentation/accessibility/inspecting-the-accessibility-of-screens)).
- Those panes are strictly accessibility metadata, so you still have to leave the inspector to identify PIDs, parent processes, and vendors, which motivates embedding the same crosshair into a telemetry-first surface ([Apple – Inspecting the accessibility of the screens in your app](https://developer.apple.com/documentation/accessibility/inspecting-the-accessibility-of-screens)).

---

## Feasibility Highlights

### 1. Cursor hit-testing to PID
Core Graphics window dictionaries expose `kCGWindowOwnerPID`, so once the eyedropper captures a screen point you can call the window-list APIs and read the owning process ID directly ([Apple – kCGWindowOwnerPID](https://developer.apple.com/documentation/coregraphics/kcgwindowownerpid)).

### 2. UI context overlay
![accessibility_inspector](../../../Documents/notes/docs/images/icons/accessibility_inspector.png) `Accessibility Inspector` already proves that you can convert a cursor position into an `AXUIElement` and display its metadata; the accessibility object model exposes element identity, position, and actions, so we can reuse the same approach to provide context while handing off to the PID viewer ([Apple – AXUIElement](https://developer.apple.com/documentation/applicationservices/axuielement)).

### 3. Process metadata and branding
Once the PID is known, ![xcode](../../../Documents/notes/docs/images/icons/xcode.png) `Xcode` tooling (or any Swift target) can hop through `NSRunningApplication(processIdentifier:)` to resolve bundle identifier, localized name, icon, executable URL, and activation hooks, which lets the UI show trustworthy vendor info next to the metrics ([Apple – NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication)).

### 4. Telemetry stream
libproc / `task_info` sampling for CPU, memory, and energy usage remains available, but we still need to validate the exact API mix (for example `proc_pid_rusage` vs. `host_processor_info`) on Apple Silicon and budget the security permissions separately.

---

## Architecture Outline

1. Eyedropper controller grabs the cursor position (on mouse-down) and requests the list of on-screen windows; read their bounds, pick the frontmost hit, and extract `kCGWindowOwnerPID` for the chosen window ([Apple – kCGWindowOwnerPID](https://developer.apple.com/documentation/coregraphics/kcgwindowownerpid)).
1. Instantiate an `AXUIElement` for both the owning app and the specific element under the cursor so you can mirror the inspector highlight, action list, and element description ([Apple – AXUIElement](https://developer.apple.com/documentation/applicationservices/axuielement)).
1. Hand the PID to a monitoring core that caches `NSRunningApplication` plus any proc/libproc handles required for sampling, so re-sampling the same target stays cheap ([Apple – NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication)).
1. Draw a small overlay (title bar or popover) anchored to the cursor to confirm the match, then push the PID into the main metrics table where CPU, memory, energy, threads, and open files updates stream just like ![activity_monitor](../../../Documents/notes/docs/images/icons/activity_monitor.png) `Activity Monitor`.
1. Persist recent samples so you can type-to-filter through historical matches or jump back to previously inspected windows without using the crosshair again.

---

## Implementation Plan

1. **Spike the eyedropper pipeline** – Build a minimal AppKit proof-of-concept that captures cursor position, resolves the window dictionary, and logs PID + bundle name.
1. **Accessibility context overlay** – Add the highlight rectangle plus metadata drawer by querying `AXUIElementCopyElementAtPosition`, confirming that the app has been granted accessibility trust.
1. **Metrics core** – Wrap libproc (`proc_pidinfo`/`proc_pid_rusage`) or `task_info` sampling behind an async scheduler so the UI can poll at 1s intervals without blocking.
1. **Process table UI** – Compose a SwiftUI (or AppKit) table that mimics top-like columns, add sorting, search, and quick actions (kill, sample, reveal in Finder).
1. **Polish + packaging** – Gate the overlay behind a menu-bar toggle, add preference panes for sampling interval and auto-pin rules, and sign/notarize for local distribution.

---

## Risks & Unknowns

- Need to measure whether the Accessibility permission prompt (`AXIsProcessTrustedWithOptions`) is sufficient or whether an app needs additional entitlements on managed fleets.
- Must confirm which telemetry API mix (libproc vs. `task_info` vs. `mach_vm`) provides the most accurate data on Apple Silicon without root privileges.
- The overlay must avoid stealing focus during drag gestures; we should prototype several interaction models (menu-bar app, floating palette, shortcut-triggered loupe).
- Packaging outside the Mac App Store is likely (sandbox restrictions make cross-process inspection hard), so we need to document manual installation, updates, and notarization.

---

## References

- [Apple – Accessibility Inspector](https://developer.apple.com/documentation/accessibility/accessibility-inspector)
- [Apple – Inspecting the accessibility of the screens in your app](https://developer.apple.com/documentation/accessibility/inspecting-the-accessibility-of-screens)
- [Apple – AXUIElement](https://developer.apple.com/documentation/applicationservices/axuielement)
- [Apple – kCGWindowOwnerPID](https://developer.apple.com/documentation/coregraphics/kcgwindowownerpid)
- [Apple – NSRunningApplication](https://developer.apple.com/documentation/appkit/nsrunningapplication)
