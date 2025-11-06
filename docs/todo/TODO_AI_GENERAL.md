


# ripgrep is installed and available and can be much more performant than grep. 

# .aiignore / .aiignored


# Use homebrew to install runtime tools to make things efficient


* how to auto allow things like pipes, $(...), {...}, for loops, etc...
EX: IT treats this grep special asks to allow `cancel|timeout|timed out`
```zsh
grep -iE "(cancel|timeout|timed out)" scripts/.gitignored/github_runner/_diag/Worker_20241104*.log | grep -v "CancellationToken" | head -20
```



# How to configure vscode's ai agent to auto-approve EVERY terminal command. 


Despite setting up both `user` and `workspace` settings to autoapprove
```zsh
"chat.tools.terminal.autoApprove": {
    "/.*/": {
        "approve": true,
        "matchCommandLine": true
    },
    "*": {
        "approve": true,
        "matchCommandLine": true
    },
}
```



# How to cconfigure copilot to see what it's thinkign in real time?




# Avoid filtering output. Instead use Tee
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"

or zome other approach where i can watch the output live
xcodebuild -workspace Nightlight.xcworkspace -scheme HatchIoTShadowClient -destination 'platform=iOS Simulator,name=iPhone 15' build 2>&1 | grep -A 5 "error:"