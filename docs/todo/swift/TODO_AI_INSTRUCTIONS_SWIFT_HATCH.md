


# Use a different derived data dir (.gitignored) so that I an use xcode at the same time
* How to do this with xcodebuild?



# pre-build macro targets when opeinign the project or first thin after a clean

The problme is that a developer opens the workspace (which is an IOS app). When they stumble on code that uses our custom Swift macros (`#LogAll`, and `@NamedClientClosure`), Xcode will render errors because it doesn't know what those are yet. 

To fix this, the dev can select each of those Macros' schemes, set the platform to `My Mac`, compile, then go back to the iOS scheme they were on (and change the platform back to iOS)

There must be a simper way. We can't be the only ones using SwiftMacros in an iOS project. 


Some thoughts: We do have a few things compile when the xcworkspace is opened to scheme `Nightlight_Development` (the main scheme). 
This scheme is configured with `Build` pre-action (a shellscript which executes `Setup.command`)

```sh
echo "Launching Scripts/Setup.command"
$SRCROOT/Setup.command
```

I was thinking we could add an xcodebuild command to `Setup.command` which should ensure those macros are compiled. 



Help me build a shell command to build these targets for the macOS platform
```zsh
# Need to specify "My Mac", however you do that with xcodebuild
xcodebuild build \
  -workspace Nightlight.xcworkspace \
  -scheme HatchLoggerMacros \
  -destination 'platform=macOS' \
  -configuration Debug

# xcodebuild test \
#   -scheme HatchLoggerMacrosImplementation \
#   -destination 'platform=macOS' 

xcodebuild test \
  -workspace Nightlight.xcworkspace \
  -scheme HatchLoggerMacros \
  -destination 'platform=macOS' 2>&1 \
 | tail -50


cd /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/1/iOS/hatch-sleep-app && \
xcodebuild test 
  -workspace Nightlight.xcworkspace 
  -scheme HatchLoggerMacrosImplementation 
  -destination 'platform=macOS' 2>&1 | \
tail -100



xcodebuild -workspace Nightlight.xcworkspace -list 2>&1 | grep -i "macro\|logger" | head -20
```


If there are better ways to to do this kind of thing, I'm def open to ideas. 





---
# Swift Package Warnings




```zsh
$ bundle exec fastlane unit_tests_development clean:true
Resolve Package Graph
Invalid Resource 'Resources/Assets.xcassets': File not found.Invalid Resource 'Resources/Localizable.xcstrings': File not found.2025-11-10 18:10:34.666 xcodebuild[31882:10462810]  DTDKRemoteDeviceConnection: Failed to start remote service "com.apple.mobile.notification_proxy" on device. Error: Error Domain=com.apple.dtdevicekit Code=811 "Failed to start remote service "com.apple.mobile.notification_proxy" on device." UserInfo={NSUnderlyingError=0xa2d4a0990 {Error Domain=com.apple.dt.MobileDeviceErrorDomain Code=-402653158 "The device
```




```zsh
$ Scripts/the-tool --nightlight --clean --build --nightlight --debug 2>/dev/null | tee "/Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_xcodebuild_10.log"
IS_DEBUG=--debug
Command line invocation:
    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -workspace ./Nightlight.xcworkspace -scheme Nightlight_Development -destination "platform=iOS Simulator,name=iPhone 16" clean build

Resolve Package Graph
Invalid Resource 'Resources/Assets.xcassets': File not found.Invalid Resource 'Resources/Localizable.xcstrings': File not found.
```





---

# Swift6 Compiler Warnings

Create an issue in hatch-baby/mobile to 


We have enabled early Swift6 adoptions and as such have a lot of compiler warnings. The goal here it add a comment (or body entry) to a pull request when the content increases that number (or a raw number at the very least). This will only apply to PRs that modify iOS code. 

Write a zsh script taht computes the number of compiler warnings, then categorizes them by removing dynamic parts of the logs like which file:line (we will want this data later though). 

Produce a report that lists each category of wraning (highest count to smallest) then lists the specific full message of that warning


Here are some commans I've been using to do this manually
```zsh
cd iOS/hatch-sleep-app

# clean then compile
xcodebuild clean build 
  -workspace Nightlight.xcworkspace 
  -scheme Nightlight_Development
  -destination 'platform=iOS Simulator'

# or
bundle exec fastlane unit_tests_development clean:true
```



## Extracting and Categorizing Warnings


<!-- * get compiler output
* filter logs down to warnings `grep '⚠️' |  grep '.swift:\|.m:\|.h:'`
* sort warnings into 2 groups
  * swift related (mentions `.swift`)
  * non-swift related (`obj-c`, asset catalogs, linker, etc...)
* for each group
  * categorize into warning categories (static portion of log messages)
  * sort by categories (highest count to lowest)
  * sort each category's logs by filename
 -->
* get compiler output
* filter logs down to warnings `grep '⚠️' |  grep '.swift:\|.m:\|.h:'`
* copy message to front of log, removing any words in single quotes (these are dynamic)
* sort by lex
  * categorize into warning categories (static portion of log messages)
  * sort by categories (highest count to lowest)
  * sort each category's logs by filename

* sort warnings into 2 groups
  * swift related (mentions `.swift`)
  * non-swift related (`obj-c`, asset catalogs, linker, etc...)


We can use xcodebuild or fastlane. I've been compiling the unit tests which tends to flush out all the warnings (maybe it's the `clean`)

Let's follow an example. 

### fastlane 
> [!NOTE]
> [Fastlane unit test output: compiler_warnings_bef_10.log](compiler_warnings_bef_10.log)
> [Filtered logs: compiler_warnings_bef_10.log](compiler_warnings_bef_10.log)


Capture compiler output to a log file
```zsh
bundle exec unit_tests_development clean:true > compiler_warnings_bef_10.log 2>&1
```

Filter the log file messages. The way we filter them depends on if we want to capture the line of code (with visual arrow) causing the warning, of if we want to synthesize it, or exclude it. I'm going to go with synthesizing since this makes the log parsing easier. 

Filter the logs file down to only Swift compiler warnings. 
*  lines that include `⚠️`
*  lines that include `.swift:`. 

```zsh
# Easy, warning one per line, but no code_visual
cat /Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_bef_10.log | grep '⚠️' |  grep '.swift:\|.m:\|.h:'`

# # More complex parsing: grab each warning and the following 2 lines which contain code_visual
# cat /Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_bef_10.log | grep '⚠️' -B2 > /Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_bef_30.log
```

Some logs are easier to parse because the message isn't "variable" (doesn't have a dynamic value in the message)

#### Static Warning Logs

In this case `'viewModel'` is dynamic (could be any variable name)
```log
[17:50:28]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoT/IoTShadowAdaptorConnectionManager.swift:141:9: case will never be executed
```

* date: (infer)
* timestamp: `17:52:47`
* file_absolute: `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoT/IoTShadowAdaptorConnectionManager.swift`
* file_relative: `iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoT/IoTShadowAdaptorConnectionManager.swift`
* line: `141`
* column: `9`
* compiler_warning: `case will never be executed`

`code_visual` can be parsed from the compiler output, or synthesized from `file`, `line`, and `column`. This example looks like so:
```swift
               case .none: return "None"
                     ^~~~
```

#### Dynamic Warning Logs


```log
[17:49:53]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchModules/Modules/HatchReusableUIComponents/Sources/Model/ConnectorLinePreferenceKeys/DarkContainerPreferenceKey.swift:11:16: static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode
```

* date: (infer)
* timestamp: `17:49:53`
* file_absolute: `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchModules/Modules/HatchReusableUIComponents/Sources/Model/ConnectorLinePreferenceKeys/DarkContainerPreferenceKey.swift`
* file_relative: `iOS/hatch-sleep-app/HatchModules/Modules/HatchReusableUIComponents/Sources/Model/ConnectorLinePreferenceKeys/DarkContainerPreferenceKey.swift`
* line: `11`
* column: `16`
* compiler_warning: `static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode`
* code_visual: (must compute)
  * xcodebuild gives this for free, but it's easy to make from the other properties
    * ```zsh
          static var defaultValue = [DarkContainerAnchor]()
                     ^
      ```


#### Staged files
* `docs/todo/swift/compiler_warnings_bef_40.log`: Copied log message to front of message followed by `" | "`
* `docs/todo/swift/compiler_warnings_bef_41.log`: A temp file where I copy the message from previous step, then remove the "dynamic" info (anything in between single quotes)
* `docs/todo/swift/compiler_warnings_bef_42.log`




### xcodebuild

> [!NOTE]
> [Fastlane unit test output: compiler_warnings_xcodebuild_10.log](compiler_warnings_xcodebuild_10.log)
> [Filtered logs: compiler_warnings_xcodebuild_20.log](compiler_warnings_xcodebuild_20.log)

Filter the logs file down to only Swift compiler warnings:
* Filter by `: warning: ` (or include the line number sytnax with regex `\d+: warning: `). 
* Filter by `.swift:`.  


```zsh
# Clean, build, save stdout and stderr output
xcodebuild -workspace "./Nightlight.xcworkspace" \
  -scheme "Nightlight_Development" \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  'clean' 'build' \
  2>&1 \
 | tee "compiler_warnings_xcodebuild_10"

# Filter down to lines with swift warnings
swift_warning_lines=(${(f)"$(cat compiler_warnings_xcodebuild_10.log | grep -E '\d+: warning: ' | grep -E '\.swift'"})
echo "Found ${#swift_warning_lines[@]} Swift compiiler warnings"
echo "swift_warning_lines:\n${(F)swift_warning_lines[@]}"
echo "Found ${#swift_warning_lines[@]} Swift compiiler warnings"
```



Some logs are easier to parse because the message isn't "variable" (doesn't have a dynamic value in the message)

#### Static Warning Logs

```log
/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoT/IoTShadowAdaptorConnectionManager.swift:141:9: warning: case will never be executed
```

* date: (infer)
* timestamp: `17:52:47`
* file_absolute: `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoT/IoTShadowAdaptorConnectionManager.swift`
* file_relative: `iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/Model/Devices/IoT/IoTShadowAdaptorConnectionManager.swift`
* line: `141`
* column: `9`
* compiler_warning: `case will never be executed`

`code_visual` can be parsed from the compiler output, or synthesized from `file`, `line`, and `column`. This example looks like so:
```swift
               case .none: return "None"
                     ^~~~
```


#### Dynamic Warning Logs

```zsh
In this case `'viewModel'` is dynamic (could be any variable name)
```


* date: (infer)
* timestamp: `17:52:47`
* file_absolute: `/Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/NightlightUnitTests/SwiftUIViewModels/LoginFlowViewModelTests.swift`
* file_relative: `iOS/hatch-sleep-app/NightlightUnitTests/SwiftUIViewModels/LoginFlowViewModelTests.swift`
* line: `170`
* column: `13`
* compiler_warning: `static property 'defaultValue' is not concurrency-safe because it is nonisolated global shared mutable state; this is an error in the Swift 6 language mode`

`code_visual` would look like this
```swift
    static var defaultValue = [DarkContainerAnchor]()
               ^
```

---

`.swift:378:38: `

```zsh
# log='/Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_bef_10.log'
# move warning to front of the message
cat $log | grep '⚠️' |  grep '.swift:' | sed -E 's|(.*\.swift:[0-9]+:[0-9]+: )(.*)|\2\1\2\n\n|g'

# extract warnings to own array
cat $log | grep '⚠️' |  grep '.swift:' | sed -E 's|(.*\.swift:[0-9]+:[0-9]+: )(.*)|\2\n\n|g'

```


# Regex Find/Replace
## Find
```re
\.swift:\d+:\d+: 
```
## Replace (ShellVSCodeXCode)
```re
replace
```



```zsh
log='/Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_bef_41_pre.log'
# move warning to front of the message
cat $log | sed -E 's|(.*\.swift:[0-9]+:[0-9]+: )(.*)|\2\1\2\n\n|g'

# extract warnings to own array
cat $log | sed -E "s|('[^']*')|<dynamic>|g"
cat $log | sed -E "s|( ?'[^']*' ?)|___|g"
```

# Regex Find/Replace
## Find
```re
( ?'[^']*')
( ?'[^']*' ?)
```
## Replace (ShellVSCodeXCode)
```re
```








```zsh
# fastlane output captured to a file
log='/Users/zakkhoyt/.ai/docs/todo/swift/compiler_warnings_bef_10.log'

# filter to warning lines
cat $log | grep '⚠️' 

# extract count of uniq messages

# extract message (still dynamic)
cat $log | grep '⚠️' | sed -E "s|(.*)(\.swift:[0-9]+:[0-9]+: )(.*)|\3|g" 

# extract messages (replacing dynamic content with `<dynamic>`, so they can be correlated and counted)
cat $log | grep '⚠️' | sed -E "s|(.*)(\.swift:[0-9]+:[0-9]+: )(.*)|\3|g" | sed -E "s|('[^']*')|<dynamic>|g"


cat $log | grep '⚠️' | sed -E "s|(.*)(\.swift:[0-9]+:[0-9]+: )(.*)|\3|g" | sed -E "s|('[^']*')|<dynamic>|g" | sort 
cat $log | grep '⚠️' | sed -E "s|(.*)(\.swift:[0-9]+:[0-9]+: )(.*)|\3|g" | sed -E "s|('[^']*')|<dynamic>|g" | sort | uniq -c

# full transform of log file
cat $log | grep '⚠️' | sed -E "s|(.*)(\.swift:[0-9]+:[0-9]+: )(.*)|\3|g" | sed -E "s|('[^']*')|<dynamic>|g" | sort | uniq -c | sort -r

# Complete to come up with counts
bundle exec unit_tests_development clean:true > compiler_warnings_bef_10.log; cat $log | grep '⚠️' | sed -E "s|(.*)(\.swift:[0-9]+:[0-9]+: )(.*)|\3|g" | sed -E "s|('[^']*')|<dynamic>|g" | sort | uniq -c | sort -r


# TODO: join the count of each with the full log lines (which point to the file, etc...)

echo "123 <dynamic> is deprecated: Use IoTDeviceStateEmitterClient directly for device state."

# 1: count
# 2: message_a
# 3: "<dynamic>"
# 4: message_b
message="123 <dynamic> is deprecated: Use IoTDeviceStateEmitterClient directly for device state."
message=" 123 <dynamic> is deprecated: Use IoTDeviceStateEmitterClient directly for device state."
message="  62 main actor-isolated instance method <dynamic> cannot be used to satisfy nonisolated requirement from protocol <dynamic>; this is an error in the Swift 6 language mode"

echo "$message" | sed -E "s|^[:space:]*([0-9]+)[:space:]*(.*)(<dynamic>)(.*)|\4|g"
echo "$message" | sed -E "s|^[:space:]*([0-9]+)[:space:]*(.*)(<dynamic>)(.*)|1: \1\n2: \2\n3: \3\n4: \4|g"
echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|1: \1\n2: \2\n3: \3\n4: \4|g"
echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|\1\n\2\n\3\n\4|g"

capture_groups=(${(f)"$(echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|\1\n\2\n\3\n\4|g")"}); echo "capture_groups:\n${(F)capture_groups[@]}"
echo "capture_groups:\n${(F)capture_groups[@]}"

# preserves empty lines
capture_groups=("${(@f)$(echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|\1\n\2\n\3\n\4|g")}");
echo "capture_groups:\n${(F)capture_groups[@]}"
slog_array_se "capture_groups" "${capture_groups[@]}"



# preserves empty lines
capture_groups=("${(@f)$(echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|\1\n\2\n\3\n\4|g")}");
echo "capture_groups:\n${(F)capture_groups[@]}"
slog_array_se "capture_groups" "${capture_groups[@]}"

message_parts=("${(@f)$(echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|'\2'\n'\4'|g")}");
echo "message_parts:\n${(F)message_parts[@]}"
slog_array_se "message_parts" "${message_parts[@]}"
message_parts=("${(f)$(echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|'\2'\n'\4'|g")}");
echo "message_parts:\n${(F)message_parts[@]}"
slog_array_se "message_parts" "${message_parts[@]}"


capture_groups=(${(f)"$(echo "$message" | sed -E "s|^[ ]*([0-9]+)[ ]*(.*)(<dynamic>)(.*)|\1\n\2\n\3\n\4|g")"}); echo "capture_groups:\n${(F)capture_groups[@]}"

```








````markdown

# 62 `main actor-isolated instance method <dynamic> cannot be used to satisfy nonisolated requirement from protocol <dynamic>; this is an error in the Swift 6 language mode`
```log
[17:49:53]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchModules/Modules/HatchReusableUIComponents/Sources/Views/Form/HatchTextFieldView.swift:401:14: call to main actor-isolated instance method 'placeholder(when:alignment:placeholder:)' in a synchronous nonisolated context; this is an error in the Swift 6 language mode
[17:49:54]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchModules/Modules/Features/HatchGuidanceSnippetsFeature/Sources/Views/CardStackHiddenView.swift:101:26: call to main actor-isolated instance method 'dynamicFont(_:color:)' in a synchronous nonisolated context; this is an error in the Swift 6 language mode
[17:49:55]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchModules/Modules/Features/HatchPersonalizedScheduleFeature/Sources/Helpers/KidRoutine+Helpers.swift:42:18: call to main actor-isolated instance method 'dynamicFont(_:color:)' in a synchronous nonisolated context; this is an error in the Swift 6 language mode
[17:50:26]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/HatchBLE/Device/DeviceConnector/ShadowIoTBLEDeviceConnector.swift:256:17: main actor-isolated instance method 'shadowAdaptorScanner(_:shouldUpgradeFirmwareFor:firmware:completion:)' cannot be used to satisfy nonisolated requirement from protocol 'ShadowAdaptorScannerDatasource'; this is an error in the Swift 6 language mode
[17:50:26]: ▸ ⚠️  /Users/zakkhoyt/code/repositories/hatch/hatch_sleep/0/iOS/hatch-sleep-app/HatchBrain/Sources/HatchBrain/HatchBLE/Device/DeviceConnector/ShadowIoTBLEDeviceConnector.swift:263:17: main actor-isolated instance method 'shadowAdaptorScannerMode' cannot be used to satisfy nonisolated requirement from protocol 'ShadowAdaptorScannerDatasource'; this is an error in the Swift 6 language mode
...
```

````