# Unit Test

* See Also: `/Users/zakkhoyt/Documents/notes/apple/xcode/xcodebuild/XCODEBUILD_UNIT_TESTS.md`

## Selecting the correct simulator

Our Snapshot Tests in Nightlight_Development.xctestplan are written against `iPhone 16 Pro Max`
however, there might be many `iPhone 16 Pro Max` sims available on a system. We should select the one that 
best matches the version of `iOS` that was shipped with your current `Xcode`
```zsh
# List all simulators (*with)
$ xcodebuild \
  -scheme HatchModules-Package \
  -showdestinations

	Available destinations for the "HatchModules-Package" scheme:
		{ platform:macOS, arch:arm64, id:00006021-00042101367B401E, name:My Mac }
		{ platform:macOS, arch:arm64, variant:Mac Catalyst, id:00006021-00042101367B401E, name:My Mac }
		{ platform:macOS, arch:arm64, variant:DriverKit, id:00006021-00042101367B401E, name:My Mac }
		{ platform:macOS, arch:arm64, variant:Designed for [iPad,iPhone], id:00006021-00042101367B401E, name:My Mac }
		{ platform:DriverKit, name:Any DriverKit Host }
		{ platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder, name:Any iOS Device }
		{ platform:iOS Simulator, id:dvtdevice-DVTiOSDeviceSimulatorPlaceholder-iphonesimulator:placeholder, name:Any iOS Simulator Device }
		{ platform:macOS, name:Any Mac }
		{ platform:macOS, variant:Mac Catalyst, name:Any Mac }
    ...
		{ platform:iOS Simulator, arch:arm64, id:4D75F8F4-0763-4B8A-967A-6A184291A3B9, OS:18.2, name:iPhone 16 Pro Max }
		{ platform:iOS Simulator, arch:arm64, id:08CBCD9E-C9D3-4D5F-9232-F393C713498B, OS:18.4, name:iPhone 16 Pro Max }
		{ platform:iOS Simulator, arch:arm64, id:70CE2285-4FD4-43D4-95BA-E65A2E8FF818, OS:18.5, name:iPhone 16 Pro Max }
		{ platform:iOS Simulator, arch:arm64, id:FD366A63-3022-4847-ACB7-5E44F4A4A518, OS:26.0, name:iPhone 16 Pro Max }
    ...
```
```zsh
$ xcrun simctl list runtimes | grep -E 'iOS'
iOS 17.5 (17.5 - 21F79) - com.apple.CoreSimulator.SimRuntime.iOS-17-5
iOS 18.0 (18.0 - 22A5316j) - com.apple.CoreSimulator.SimRuntime.iOS-18-0
iOS 18.0 (18.0 - 22A5346a) - com.apple.CoreSimulator.SimRuntime.iOS-18-0
iOS 18.0 (18.0 - 22A3351) - com.apple.CoreSimulator.SimRuntime.iOS-18-0
iOS 18.1 (18.1 - 22B5023e) - com.apple.CoreSimulator.SimRuntime.iOS-18-1
iOS 18.1 (18.1 - 22B81) - com.apple.CoreSimulator.SimRuntime.iOS-18-1
iOS 18.2 (18.2 - 22C150) - com.apple.CoreSimulator.SimRuntime.iOS-18-2
iOS 18.4 (18.4 - 22E238) - com.apple.CoreSimulator.SimRuntime.iOS-18-4
iOS 18.5 (18.5 - 22F77) - com.apple.CoreSimulator.SimRuntime.iOS-18-5
iOS 26.0 (26.0 - 23A5260l) - com.apple.CoreSimulator.SimRuntime.iOS-26-0
iOS 26.0 (26.0 - 23A5297i) - com.apple.CoreSimulator.SimRuntime.iOS-26-0
iOS 26.1 (26.1 - 23B86) - com.apple.CoreSimulator.SimRuntime.iOS-26-1
```




## Test Plan (Nightlight_Development.xctestplan)

Here are 3 approaches to running `Nightlight_Development.xctestplan`




```zsh
cd iOS/hatch-sleep-app 
# This approach will autoselect the right simulator which the snapshot tests were designed for
bundle exec fastlane unit_tests_development
```

```zsh
cd iOS/hatch-sleep-app 
# This might have difficulty when there are more than a single 'iPhone 16 Pro Max'
# We want to select the one for the current version of Xcode (xcodebuild -version | head -n 1)
xcodebuild \
  -workspace ./Nightlight.xcworkspace \
  -scheme Nightlight_Development \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0' \
  -resultBundlePath ./fastlane/test_output/Nightlight_Development.xcresult \
  -enableCodeCoverage YES \
  -testPlan 'Nightlight_Development' \
  -retry-tests-on-failure
  -test-iterations 3 \
  build test \
  | tee '/Users/zakkhoyt/Library/Logs/scan/Nightlight-Nightlight_Development.log' 
```

```zsh
# uses a wrapper script to run Nightlight_Development.xctestplan
./Scripts/the_tool.zsh --nightlight --test
```

```zsh
cd iOS/hatch-sleep-app 
set -o pipefail && xcodebuild -workspace "./Nightlight.xcworkspace" \
    -scheme "Nightlight_Development" \
    -testPlan "Nightlight_Development" \
    -destination "platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0" \
    test \
| tee ".gitignored/xcodebuild/Nightlight_Nightlight_20260413_172720.log"
```



## All targets in HatchModules
```zsh
cd iOS/hatch-sleep-app/HatchModules

xcodebuild \
  -scheme HatchModules-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0' \
  test
  # clean test
```


## A particular .testTarget
```zsh
cd iOS/hatch-sleep-app/HatchModules
xcodebuild \
  -scheme "HatchModules-Package" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0' \
  -only-testing:"${my_test_target_name}" \
  test
  # clean test
```
```zsh
cd iOS/hatch-sleep-app/HatchModules
xcodebuild \
  -scheme "HatchModules-Package" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0' \
  -only-testing:"${my_test_target_name}" \
  test
  # clean test
```
```zsh
cd iOS/hatch-sleep-app/HatchModules
xcodebuild \
  -scheme "HatchModules-Package" \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0' \
  -only-testing:"${my_test_target_name}" \
  test
  # clean test
```


```zsh
# Runs all tests in the test target (bundle) named MyFeatureTests
-only-testing:MyFeatureTests

# Runs one test class inside that test target
-only-testing:MyFeatureTests/MyFeatureBehaviorTests

# Runs one test method
-only-testing:MyFeatureTests/MyFeatureBehaviorTests/testHappyPath
```



# TODO
## `OS=26.0`
```zsh
-destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=26.0'
```
