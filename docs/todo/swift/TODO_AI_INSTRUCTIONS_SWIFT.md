
# Capture stdout/stderr to a file 
Let the nature stdout/stderr flow to TTY. If you are monitoring you need ot use `tee` or some other splitter to monitor a duplicate stream. 

You could capture stdout/stderr to a file but then we woudl have to wait for the command to exit... unless you tail that file. 

The long and short is:
* I want to see the natural output in real time
* I want the natural output to be retained as a file so yuo dont' have to re-run long running commands ot look for some other string
* This preserves a history that both of use can refer to

```zsh
# Bad
xcodebuild test -workspace Nightlight.xcworkspace -scheme HatchLoggerMacros -destination 'platform=macOS' 2>&1 | grep -A 20 "Test Suite 'LogAllMacroTests'"
# whoops a test failed. now  AI is going ot want to this which is a huge waste of time
xcodebuild test -workspace Nightlight.xcworkspace -scheme HatchLoggerMacros -destination 'platform=macOS' 2>&1 | grep -A 20 "Failed"
```




# swift build vs xcodebuild
* [ ] TODO: always use xcodebuild. 
* [ ] No force unwrapping ever


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




# Lint/Format rules
* Get AI to summarize those main rules defined at
  * .swiftformat
  * .swiftlint.yml
* Or provide how to run tools at any directory




# Compiling / Testing
* [ ] Provide instructions for how to compile
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