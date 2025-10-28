
# Lint/Format rules
* Get AI to summarize those main rules defined at
  * .swiftformat
  * .swiftlint.yml
* Or provide how to run tools at any directory



# swift build vs xcodebuild
* [ ] TODO: always use xcodebuild. 

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