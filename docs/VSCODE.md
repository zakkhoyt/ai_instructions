


# Auto Approving AI Agent CLI

## Key Documentation Notes

From VS Code's settings documentation:
- Commands are evaluated for **every sub-command** within the full command line
- For `foo && bar` to auto-approve, BOTH `foo` AND `bar` must match `true` entries
- Use `{ "approve": true, "matchCommandLine": true }` to match against the **full command line** instead of sub-commands
- Command substitution `$(foo)` and process substitution `<(foo)` are **blocked by default** via broad rules
- Patterns are matched against the **start** of a command
- Regular expressions can be wrapped in `/` characters with optional flags like `i` for case-insensitivity

## Recommended Configuration

```json
// VSCode User Settings
// $HOME/Library/Application Support/Code/User/settings.json
{
  "chat.tools.terminal.autoApprove": {
    // Use matchCommandLine: true to match entire command lines
    // This bypasses the sub-command matching requirement
    
    // Match command lines with pipes and logical operators
    "/\\|/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/&&/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\|\\|/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/;/": {
        "approve": true,
        "matchCommandLine": true
    },
    
    // Override default blocks for command/process substitution
    "/\\$\\(/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/<\\(/": {
        "approve": true,
        "matchCommandLine": true
    },
    
    // Match command lines with parentheses, braces, backticks
    "/\\(/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\)/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\{/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\}/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/`/": {
        "approve": true,
        "matchCommandLine": true
    },
    
    // Redirections
    "/>/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/2>&1/": {
        "approve": true,
        "matchCommandLine": true
    },
    
    // Approve commonly blocked commands
    "xargs": true,
    "jq": true,
    "awk": true,
    "sed": true,
    "find": true,
    "grep": true,
    "head": true,
    "tail": true,
    "tee": true,
    
    // Catch-all for any command line (last resort)
    "/.*$/": {
        "approve": true,
        "matchCommandLine": true
    }
  }
}
```

```json
// VSCode Workspace Settings
// $vscode_workspace_dir/.vscode/settings.json
{
  "chat.tools.terminal.autoApprove": {
    // Same patterns as user settings above
    "/\\|/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/&&/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\|\\|/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\$\\(/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/<\\(/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\(/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/\\{/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/`/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/>/": {
        "approve": true,
        "matchCommandLine": true
    },
    "/2>&1/": {
        "approve": true,
        "matchCommandLine": true
    },
    "xargs": true,
    "jq": true,
    "awk": true,
    "sed": true,
    "find": true,
    "grep": true,
    "/.*$/": {
        "approve": true,
        "matchCommandLine": true
    }
  }
}
```


From user settings
```json
        "echo \"TERM_PROGRAM: ${TERM_PROGRAM:-not set}\"\necho \"COLUMNS: $COLUMNS\"\necho \"LINES: $LINES\"": {
            "approve": true,
            "matchCommandLine": true
        },
        "gh pr view 309 --json reviews,comments --jq '.reviews[] | select(.state == \"COMMENTED\" or .state == \"CHANGES_REQUESTED\") | {author: .author.login, body: .body, createdAt: .createdAt}'": {
            "approve": true,
            "matchCommandLine": true
        },
        "xcodebuild -scheme HatchIoTShadowClientTests -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' test 2>&1 | grep -E \"(Test Suite|Test Case.*passed|Test Case.*failed|Testing.*completed|Executed|TEST SUCCEEDED|TEST FAILED)\" | tail -30": {
            "approve": true,
            "matchCommandLine": true
        }
```

From workspace settings
```json
    "cd": true,
    "echo": true,
    "ls": true,
    "pwd": true,
    "cat": true,
    "head": true,
    "tail": true,
    "findstr": true,
    "wc": true,
    "tr": true,
    "cut": true,
    "cmp": true,
    "which": true,
    "basename": true,
    "dirname": true,
    "realpath": true,
    "readlink": true,
    "stat": true,
    "file": true,
    "du": true,
    "df": true,
    "sleep": true,
    "grep": true,
    "git status": true,
    "git log": true,
    "git show": true,
    "git diff": true,
    "git grep": true,
    "git branch": true,
    "/^git branch\\b.*-(d|D|m|M|-delete|-force)\\b/": false,
    "Get-ChildItem": true,
    "Get-Content": true,
    "Get-Date": true,
    "Get-Random": true,
    "Get-Location": true,
    "Write-Host": true,
    "Write-Output": true,
    "Split-Path": true,
    "Join-Path": true,
    "Start-Sleep": true,
    "Where-Object": true,
    "/^Select-[a-z0-9]/i": true,
    "/^Measure-[a-z0-9]/i": true,
    "/^Compare-[a-z0-9]/i": true,
    "/^Format-[a-z0-9]/i": true,
    "/^Sort-[a-z0-9]/i": true,
    "column": true,
    "/^column\\b.*-c\\s+[0-9]{4,}/": false,
    "date": true,
    "/^date\\b.*(-s|--set)\\b/": false,
    "find": true,
    "/^find\\b.*-(delete|exec|execdir|fprint|fprintf|fls|ok|okdir)\\b/": false,
    "sort": true,
    "/^sort\\b.*-(o|S)\\b/": false,
    "tree": true,
    "/^tree\\b.*-o\\b/": false,
    "/\\(.+\\)/s": {
      "approve": false,
      "matchCommandLine": true
    },
    "/\\{.+\\}/s": {
      "approve": false,
      "matchCommandLine": true
    },
    "/`.+`/s": {
      "approve": false,
      "matchCommandLine": true
    },
    "rm": false,
    "rmdir": false,
    "del": false,
    "Remove-Item": false,
    "ri": false,
    "rd": false,
    "erase": false,
    "dd": false,
    "kill": false,
    "ps": false,
    "top": false,
    "Stop-Process": false,
    "spps": false,
    "taskkill": false,
    "taskkill.exe": false,
    "curl": false,
    "wget": false,
    "Invoke-RestMethod": false,
    "Invoke-WebRequest": false,
    "irm": false,
    "iwr": false,
    "chmod": false,
    "chown": false,
    "Set-ItemProperty": false,
    "sp": false,
    "Set-Acl": false,
    "jq": false,
    "xargs": false,
    "eval": false,
    "Invoke-Expression": false,
    "iex": false

```