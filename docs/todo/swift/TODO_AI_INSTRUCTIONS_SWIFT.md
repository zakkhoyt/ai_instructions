
# For All

# compile, test, and run tooling
* `iOS` platforma: If the target or scheme is configured for `iOS` then the `xcodebuild <tool>` set should be used. 
  * `swift build` is not going to be capable of fully compling and linking an iOS project without some serious complication. The same is true for testing and running the app. 
  * `xcodebuild clean [args]` for cleaning
  * `xcodebuild build [args]` for compiling
  * `xcodebuild test [args]` for testing
* `macOS` platform: If the target or scheme is configured for `macOS` (and maybe `linux`) platform, then the `swift <tool>` commands should work, howeveer... the `xcodebuild` tools will work for this too
  * EX: A swift package with a library target that runs on `macOS` only: Use `swift <tool>`
  * EX: A swift package with a library target that runs on `macOS` and `iOS`: Since it supports `macOS` then  `swift <tool>` should work


For most cases, xcodebuild should be preferred because it works with any swift source type (package, workspace, project) and with any platform target (except `linux)

`swift <tool>` might be the option to use if the Agent machine is `linux` or if the swift code is purely for `macOS` platform. The latter will still work with xcodebuild though. 


## xcrun
`xcrun` works for locating where the correct version of  `swift*` binaries and `xc*` binaries on located on the `macOS` filesystem. 
Both tool families are shipped with xcode and reside in the same dir: `/Applications/${xcode_version}.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/`
```zsh

# get absolute path of `tool`
$ tool='swift'; echo "$(xcrun --find "$tool" 2>/dev/null)"

$ echo "# swift-package:\n$(xcrun --find swift-package 2>/dev/null)";
# swift-package:
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swift-package
```




## xcodebuild

> [!NOTE]
> Agents should always use `xcrun` to locate the relevant binaries vs the binary name itself
> There are often multiple Xcode versions installed on an iOS dev machine, so it's important that Agents use the right one
> The relative `xcrun` is set with `xcode-select -s <path>` or equiv
> EX: `"$(xcrun --find xcodebuild 2>/dev/null)"`

```zsh
$ echo "# xcodebuild:\n$(xcrun --find xcodebuild 2>/dev/null)"      
# xcodebuild:
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
```


Always include a `cd` or `pushd` command to enter the workspace dir, project dir, or package dir first. 
Always pick child most directory possible. EX: Package.swift is preferred over Nightlight.xcworkspace
```zsh
# clean then build
cd "$PACKAGE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" clean build \
  -scheme "Nightlight_Development" \
  -destination "platform=iOS Simulator,name=iPhone 16"
      
cd "$PACKAGE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" test \
  -scheme HatchIoTShadowClient \
  -destination 'generic/platform=iOS' \
  -configuration Debug
  
# clean then test
cd "$PACKAGE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" clean test \
  -scheme HatchIoTShadowClient \
  -destination 'generic/platform=iOS' \
  -configuration Debug
  
# clean and test a macOS macro
cd "$WORKSPACE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" clean test \
  -workspace Nightlight.xcworkspace \
  -scheme HatchLoggerMacros \
  -destination 'platform=macOS' \
  -configuration Debug
```


When working with Swift Packages using xcodebuild,  it will create a scheme named `$package_name-Package` which builds ever target in `Package.swift`
```zsh
# _2/HatchModules/.build/logs/HatchModules-Package_tests_20250626171913.log:    
/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -scheme HatchModules-Package -destination "platform=iOS Simulator,name=iPhone 16,OS=18.4" clean test
```




```zsh
zsh code
```


### Destination

Prefer this order:
1) macOS native. This only works when the target is being compiled to run on macOS (not catalyst, not designed for iphone)
 * `-destination 'platform=macOS'`
2) macOS (designed for iphone, catalyst). 
   * Most of our iOS projects are configured as `Designed for iPhone` where the iOS binary can be run on `My Mac (Designed for iPhone)`. 
   * [ ] I'm not sure what the `-destination '...'` equivalent is for this option. Please do informat me!
   * This doesn't always work with tests though.
3) iOS simulator. Next would be the iOS simulators. These cant' run all types of tests though
   * When specifying an iOS simulator, keep it as general as possible
     * use generic iOS simulator where possible: 
       * `-destination 'generic/platform=iOS Simulator'`
     * If you must define an iOS version, keep it as generic as possible
       * `-destination 'platform=iOS Simulator,name=iPhone 16 Pro'`
     * if you must use a device try:
       * `-destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'`
4) iOS device. Last in the line because of how cumbersome it can be to register the device, plug it in, wait for data transfers


## swift <tool>
Very similar to the [#xcodebuild](#xcodebuild) section. 

**--help pages**
```zsh
$ "$(xcrun --find swift-package 2>/dev/null)" --help
$ "$(xcrun --find swift-build 2>/dev/null)" --help
$ "$(xcrun --find swift-run 2>/dev/null)" --help
$ "$(xcrun --find swift-test 2>/dev/null)" --help
```



Always include a `cd` or `pushd` command to enter the workspace dir, project dir, or package dir first. 

```zsh



cd "$PACKAGE_DIR" && \
"$(xcrun --find swift-build 2>/dev/null)" \
  --package-path ${PACKAGE_DIR} \
  --product ${TOOL_NAME}


cd "$PACKAGE_DIR" && \
"$(xcrun --find swift-build 2>/dev/null)" \
  --package-path ${PACKAGE_DIR} \
  --product ${TOOL_NAME} \
  --configuration release \
  --arch arm64 --arch x86_64

cd "$PACKAGE_DIR" && \
"$(xcrun --find swift-test 2>/dev/null)" \
  --package-path ${PACKAGE_DIR} \
  --product ${TOOL_NAME}

```



# AI Agent Must Check their own Swift Changes
AI agents should **always** validate its code chaanges. Linting the swift code changes is never a good enough solution. 
1) Unit Tests / Snapshot tests is the most preferrable (capture known good data before the refactory, validate it after the refactory)
```zsh
cd "$PACKAGE_DIR" && \
"$(xcrun --find xcodebuild 2>/dev/null)" test \
  -scheme <scheme> \
  -destination 'generic/platform=iOS' \
  -configuration Debug

cd "$PACKAGE_DIR" && \
swift test <testTarget> [args]
```

2) If the code is an app or an executableTarget then Agent can run the binary
```zsh
swift run <exectuable_target> [args]
```

3) If the code is a library or some intermediate code where adding tests is super invovled or not possible, then the code should be validated to compile wihtout errors\x1B[1m
```zsh
swift build <library> [args]
```


* [ ] When AI agent uses a shell terminal, the word `build` MUST ALWAYS be quoted 
  * [ ] otherwise `oh-my-zsh` will try to autocorrect it to `.build` which will then prompt the human for input and it becomes a mess. 
    * [ ] TODO: how to disable autocorrect on a per-shell instance basis?
      * I jotted down "zsh arg `nocorrection` (SP?)". Have a look in `man zshall` and the `oh-my-zsh` documettation to find a potentisl soluion.
        * Can AI Agent disable this behavior upon assuming control of the terminal?
        * Can I create a terminal profile for AI to use? How do I ensure that when AI uses a terminal that I alrady had open that it will switch? 
* [ ] Agens must aways validate that their changes have not broken any compiling, behavior, etc... 
  * [ ] either with unit tests or `swift run echo_pretty <args>` then inspect the bytes of the output using `xxd` or similar tools 



## Adding Unit Tests
* if the Swift code being mondified is not covered by tests, the agent should add tests. 
  * for a Swift Package target of library, executable, etc.. the agent should add a testTarget (unit tests) if there is one. 

## Adding Snapshot Tests
If the swift code being modfified is a refactoring, then the agent should ensure that there are snapshot tests in place before modifying the code. 
* Aagent should modify the target to depend on pointfreeco's snapshot testing library by adding it to the `dependencies` section of `Package.swift` as well as to `testTarget.dependencies`
* Agent should also add snapshot tests to exercise the code that will be refactored
- [ ] **Add SnapshotTesting Dependency**: Update `Package.swift` to add a dependency on `https://github.com/pointfreeco/swift-snapshot-testing.git` using something similar to:
  ```swift
  dependencies: [
    .package(
        url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
        from: Version(1, 18, 7)
    ),
    //...
  ],
  ```
- [ ] **Create Test Target**: Add a `testTarget` for echo_pretty in `Package.swift`, for example:
  ```swift
  targets: [
    .testTarget(
      name: "EchoPrettyTests",
      dependencies: [
        "EchoPretty",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ],
      swiftSettings: swiftSettings
    ),
  ]
  ```









# Lint/Format rules
* Get AI to summarize those main rules defined at
  * .swiftformat
  * .swiftlint.yml
* Or provide how to run tools at any directory




# Compiling / Testing
* [X] ~~*Provide instructions for how to compile*~~ [2025-11-22]
  * quote "build" to avoid zsh autocorrecting
  * [ ] zsharg `nocorrection` (SP?)
  * [ ] HatchModules (all)
  * [ ] hatchModuels (partial)
  * [ ] other packages
  * [ ] App 
* [ ] Provide instructions for how to test
  * manual scheme setup if tests are new

```zsh
# quote "build" to avoid zsh autocorrecting
xcodebuild -scheme HatchIoTShadowClient -configuration Debug -destination 'generic/platform=iOS' "build"
```


* [ ] When building, compiling, running tests, save stdout/stderr to a temp file. Then reference that file instead of running the tests again (in cases where you didn't tail enough of the logs)