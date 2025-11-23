---
applyTo: "**/*"
---

# AI Agent Terminal Command Execution Conventions

**IMPORTANT**: These conventions apply to how AI agents should execute terminal commands to maximize efficiency, collaboration, and debugging capability when working with humans.

---

## ⚡ Quick Compliance Checklist

When executing terminal commands as an AI agent, ensure:

- ✅ **Output persisted** - Long-running commands save full output to log files (see [Persist Command Output](#persist-command-output))
- ✅ **Human visibility** - Use `tee` to show output in real-time while capturing (see [Real-Time Human Visibility](#real-time-human-visibility))
- ✅ **Pagers bypassed** - Commands that use pagers include `| cat` or `--no-pager` (see [Bypass Pagers](#bypass-pagers-in-non-interactive-contexts))
- ✅ **Reusable logs** - Avoid re-running long commands; filter existing log files (see [Avoid Re-Running Commands](#avoid-re-running-long-commands))
- ✅ **Timestamps used** - Log files include timestamp for uniqueness (see [Log File Naming](#log-file-naming-conventions))

**→ If unsure about any item, refer to the detailed sections below.**

---

## Table of Contents

1. [Persist Command Output](#persist-command-output)
2. [Real-Time Human Visibility](#real-time-human-visibility)
3. [Avoid Re-Running Long Commands](#avoid-re-running-long-commands)
4. [Bypass Pagers in Non-Interactive Contexts](#bypass-pagers-in-non-interactive-contexts)
5. [Log File Naming Conventions](#log-file-naming-conventions)

---

## Persist Command Output

**CRITICAL**: When executing long-running commands or commands with substantial output, ALWAYS save the full output to a log file.

### Why This Matters

AI agents frequently make the mistake of filtering command output in real-time, then discovering the filter was incorrect or incomplete. This leads to re-running expensive operations:

❌ **Bad (wasteful re-execution):**
```zsh
# First attempt - filter too narrow
xcodebuild clean build | tail -n 20 | grep "ERROR"
# Whoops, grep came up empty

# Second attempt - wastes time re-running entire build
xcodebuild clean build | tail -n 30 | grep "ERROR\|error"
```

✅ **Good (reusable log file):**
```zsh
# Save full output once
log_file=".gitignored/build/xcodebuild_$(date +%Y%m%d_%H%M%S).log"
xcodebuild clean build > "$log_file" 2>&1

# Apply filters quickly without re-running
tail "$log_file" -n 20 | grep "ERROR"

# Refine filters instantly
tail "$log_file" -n 30 | grep "ERROR\|error"

# Try different approaches
grep -i "warning" "$log_file" | wc -l
```

### Benefits

1. **Efficiency**: Avoid expensive re-execution of commands
2. **Debugging**: Full output available for analysis
3. **Iteration**: Experiment with different filters instantly
4. **History**: Preserve output for future reference
5. **Collaboration**: Human can examine logs independently

### Standard Pattern

```zsh
# Create log directory if needed
mkdir -p .gitignored/build

# Execute command with full output capture
log_file=".gitignored/build/command_name_$(date +%Y%m%d_%H%M%S).log"
long_running_command arg1 arg2 > "$log_file" 2>&1

# Now filter/analyze the log file
grep "pattern" "$log_file"
tail -n 50 "$log_file"
wc -l "$log_file"
```

### When to Persist Output

Persist output for:
- **Build commands** (`xcodebuild`, `gradle`, `make`, `npm run build`)
- **Test suites** (`pytest`, `jest`, `xcodebuild test`)
- **Package installations** (`brew install`, `pip install`, `npm install`)
- **Git operations** with verbose output (`git log`, `git diff`)
- **Network operations** (`curl` with verbose, `wget`)
- **Any command** that takes >5 seconds to complete
- **Any command** with >100 lines of output

---

## Real-Time Human Visibility

**CRITICAL**: When filtering or processing command output, ensure the human can see what's happening in real-time. Humans often have critical information that can save significant time.

### The Problem

When AI agents directly filter output, humans lose visibility into the process:

❌ **Bad (human can't see what's happening):**
```zsh
# Human has no idea what warnings are being ignored
xcodebuild clean build | grep "ERROR"

# Human can't tell if the build is progressing or stuck
long_running_test | tail -n 10
```

### The Solution: Use `tee`

The `tee` command duplicates a stream: one copy to the terminal (for human visibility), another to a file or pipeline (for agent processing):

✅ **Good (human sees everything in real-time):**
```zsh
# Save full output to file AND show in terminal
log_file=".gitignored/build/build_$(date +%Y%m%d_%H%M%S).log"
xcodebuild clean build 2>&1 | tee "$log_file"

# Filter after the fact
grep "ERROR" "$log_file"
```

✅ **Good (advanced - show in terminal AND filter for agent):**
```zsh
# Human sees full output, agent gets filtered subset
log_file=".gitignored/build/build_$(date +%Y%m%d_%H%M%S).log"
xcodebuild clean build 2>&1 | tee "$log_file" | grep --line-buffered "ERROR"
```

### Why Human Visibility Matters

**Real-world example:**
```zsh
# AI agent runs this (human can't see details)
gradle build | grep "FAILED"

# Human watching terminal would have noticed:
# "Downloading dependencies from maven central (may take 10 minutes)..."
# "Connecting to repository: https://repo1.maven.org/maven2"
# "Connection timeout - retrying in 30 seconds..."

# Human could have said: "Our network requires VPN - I'll connect now"
# This saves 10+ minutes of waiting and debugging
```

### Standard `tee` Patterns

**Capture everything, show everything:**
```zsh
command 2>&1 | tee "$log_file"
```

**Capture everything, show filtered subset:**
```zsh
# Requires --line-buffered for real-time grep output
command 2>&1 | tee "$log_file" | grep --line-buffered "pattern"
```

**Append to existing log file:**
```zsh
command 2>&1 | tee -a "$log_file"
```

**Split stderr and stdout to separate files:**
```zsh
# More advanced - captures both streams separately
(command 2>&1 1>&3 | tee stderr.log) 3>&1 1>&2 | tee stdout.log
```

---

## Avoid Re-Running Long Commands

**CRITICAL**: Once a long-running command has been executed and its output saved, NEVER re-run it just to apply a different filter.

### The Anti-Pattern

❌ **Bad (wasteful):**
```zsh
# First attempt - 10 minutes to build
xcodebuild clean build | grep "ERROR" > errors1.log

# Realized we need warnings too - another 10 minutes wasted
xcodebuild clean build | grep "ERROR\|WARNING" > errors2.log

# Actually, let's see all Swift compiler messages - another 10 minutes
xcodebuild clean build | grep ".swift:" > swift_output.log
```

**Total time wasted: 30 minutes**

### The Correct Pattern

✅ **Good (efficient):**
```zsh
# First execution - 10 minutes (unavoidable)
log_file=".gitignored/build/xcodebuild_$(date +%Y%m%d_%H%M%S).log"
xcodebuild clean build > "$log_file" 2>&1

# Apply different filters instantly (< 1 second each)
grep "ERROR" "$log_file" > errors.log
grep "ERROR\|WARNING" "$log_file" > errors_and_warnings.log
grep ".swift:" "$log_file" > swift_output.log

# Count occurrences
grep "ERROR" "$log_file" | wc -l

# Complex filtering
grep ".swift:" "$log_file" | grep -v "warning:" | sort | uniq

# Statistical analysis
awk '/ERROR/ {errors++} /WARNING/ {warnings++} END {print "Errors:", errors, "Warnings:", warnings}' "$log_file"
```

**Total time: 10 minutes + a few seconds for all analysis**

### Multi-Stage Analysis Pattern

When iteratively refining analysis:

```zsh
# Initial execution (expensive)
log_file=".gitignored/build/build_$(date +%Y%m%d_%H%M%S).log"
xcodebuild clean build > "$log_file" 2>&1

# Stage 1: Quick overview
wc -l "$log_file"
grep -c "ERROR" "$log_file"
grep -c "warning" "$log_file"

# Stage 2: Detailed filtering (refined based on Stage 1 insights)
grep "ERROR" "$log_file" | grep ".swift:" > swift_errors.log
grep "ERROR" "$log_file" | grep -v ".swift:" > other_errors.log

# Stage 3: Statistical analysis (refined based on Stage 2)
grep ".swift:" "$log_file" | sed 's/.*\.swift:\([0-9]*\).*/\1/' | sort -n | uniq -c

# Stage 4: Final report generation
# ... and so on, all from the same log file
```

### When Re-Execution is Acceptable

Re-run a command only when:
1. **Testing a fix**: Verifying that a change resolved the issue
2. **State changed**: Environment or code has been modified
3. **Incremental operation**: Command is designed to be incremental (like `git pull`)
4. **Short duration**: Command completes in < 5 seconds

Otherwise, always work from saved log files.

---

## Bypass Pagers in Non-Interactive Contexts

**CRITICAL**: Many commands output to a pager (like `less`) instead of stdout, which causes AI agents to hang indefinitely waiting for user interaction.

### Common Commands That Use Pagers

- **Git**: `git diff`, `git log`, `git show`
- **GitHub CLI**: `gh repo view`, `gh issue view`, `gh pr view`
- **System tools**: `man`, `systemctl status`, `journalctl`
- **Any command** configured with `PAGER` environment variable

### The Problem

❌ **Bad (hangs indefinitely):**
```zsh
# Opens `less` pager and waits for user input - agent hangs
git log

# Opens pager in interactive mode - agent hangs
gh repo view owner/repo

# Opens man page viewer - agent hangs
man zsh
```

### Solutions

#### Solution 1: Pipe to `cat`

The simplest solution - forces output to stdout:

✅ **Good:**
```zsh
git log | cat
gh repo view owner/repo | cat
gh issue list | cat
```

#### Solution 2: Use `--no-pager` Flag

Many commands have a built-in flag to disable paging:

✅ **Good:**
```zsh
git --no-pager log
git --no-pager diff
git --no-pager show abc123
```

#### Solution 3: Environment Variable Override

Set pager to `cat` for specific command:

✅ **Good:**
```zsh
GH_PAGER=cat gh repo view owner/repo
PAGER=cat some_command
```

#### Solution 4: Global Disable (Use Cautiously)

Disable paging for entire script:

```zsh
export PAGER=cat
export GH_PAGER=cat

# Now all commands use cat as pager
git log
gh issue list
```

**Warning**: Only use global disable in automated scripts, never in interactive sessions.

### Decision Guide

| Scenario | Best Solution | Example |
|----------|---------------|---------|
| Git commands | `--no-pager` flag | `git --no-pager log` |
| GitHub CLI | `\| cat` or `GH_PAGER=cat` | `gh issue list \| cat` |
| One-off command | `\| cat` | `systemctl status \| cat` |
| Automated script | Global `export PAGER=cat` | See Solution 4 |
| Capturing to variable | `\| cat` | `output=$(git log \| cat)` |

### Real-World Examples

✅ **Good (AI agent-safe):**
```zsh
# Git log analysis
git --no-pager log --oneline | head -n 20

# GitHub repo inspection
repo_info=$(gh repo view --json owner,name | cat)

# System status check
systemctl status nginx | cat | grep "Active:"

# Piping to other tools
git --no-pager diff | grep "^+" | wc -l
```

❌ **Bad (will hang):**
```zsh
# These all open interactive pagers
git log
gh repo view owner/repo
man grep
systemctl status nginx
journalctl -u service-name
```

### When Pager is Appropriate

Pagers are appropriate ONLY in interactive human sessions:
- Manual inspection by human at terminal
- One-off queries where user wants to scroll/search
- Help documentation viewing

For AI agents: **ALWAYS bypass pagers in every context.**

---

## Log File Naming Conventions

**RECOMMENDED**: Use descriptive, timestamped names for log files to enable:
1. Easy identification of log contents
2. Chronological ordering
3. Avoiding filename collisions
4. Debugging session correlation

### Standard Naming Pattern

```zsh
.gitignored/<category>/<command_name>_<timestamp>.log
```

**Components:**
- **Directory**: `.gitignored/` ensures logs don't get committed
- **Category**: `build/`, `test/`, `deploy/`, etc. (groups related logs)
- **Command name**: Identifies what generated the log
- **Timestamp**: `YYYYMMDD_HHMMSS` format for uniqueness and sorting
- **Extension**: `.log` for clear file type

### Examples

```zsh
# Build logs
.gitignored/build/xcodebuild_20241122_143022.log
.gitignored/build/gradle_clean_20241122_143530.log
.gitignored/build/npm_build_20241122_144015.log

# Test logs
.gitignored/test/pytest_20241122_151200.log
.gitignored/test/xcodebuild_test_20241122_151845.log

# Deployment logs
.gitignored/deploy/kubectl_apply_20241122_160330.log

# Git operation logs
.gitignored/git/git_log_analysis_20241122_162215.log
```

### Creating Timestamped Logs

```zsh
# Generate timestamp
timestamp=$(date +%Y%m%d_%H%M%S)

# Use in log file name
log_file=".gitignored/build/xcodebuild_${timestamp}.log"
xcodebuild clean build > "$log_file" 2>&1

# Alternative: inline timestamp generation
log_file=".gitignored/build/xcodebuild_$(date +%Y%m%d_%H%M%S).log"
```

### Directory Structure

Organize logs by category:

```
.gitignored/
├── build/
│   ├── xcodebuild_20241122_143022.log
│   ├── gradle_clean_20241122_143530.log
│   └── npm_build_20241122_144015.log
├── test/
│   ├── pytest_20241122_151200.log
│   └── jest_20241122_152330.log
├── deploy/
│   └── kubectl_apply_20241122_160330.log
└── analysis/
    ├── compiler_warnings_20241122_163045.log
    └── code_coverage_20241122_164120.log
```

### Automated Directory Creation

Always create the log directory before writing:

```zsh
log_dir=".gitignored/build"
mkdir -p "$log_dir"

log_file="$log_dir/xcodebuild_$(date +%Y%m%d_%H%M%S).log"
xcodebuild clean build > "$log_file" 2>&1
```

### Benefits of This Convention

1. **Chronological sorting**: `ls -lt .gitignored/build/` shows newest first
2. **No collisions**: Timestamp ensures unique names
3. **Self-documenting**: Name reveals contents and creation time
4. **Easy cleanup**: `find .gitignored -name "*.log" -mtime +30 -delete`
5. **Git-safe**: `.gitignored/` prevents accidental commits

### Anti-Patterns

❌ **Bad (no structure):**
```zsh
# All logs in root - hard to organize
xcodebuild_log.txt
test_output.log
build.log
output.txt
```

❌ **Bad (no timestamp):**
```zsh
# Overwrites previous logs
.gitignored/xcodebuild.log
.gitignored/xcodebuild_2.log  # Manual versioning is error-prone
```

❌ **Bad (not gitignored):**
```zsh
# Could accidentally commit large logs
logs/build_output.log
```

---

## Summary: Agent Efficiency Rules

1. **Persist first, filter later** - Save full output, apply filters to the log file
2. **Human needs visibility** - Use `tee` to show output in real-time
3. **Never re-run long commands** - Work from saved logs for iterative analysis
4. **Bypass pagers always** - Use `| cat`, `--no-pager`, or `PAGER=cat`
5. **Name logs descriptively** - Include timestamp and category

Following these conventions will:
- **Reduce execution time** by 50-90% (avoiding re-runs)
- **Improve collaboration** (human can provide real-time input)
- **Enable better debugging** (full logs preserved)
- **Prevent hangs** (pagers bypassed)
- **Organize output** (structured log directories)

---

## References

- [Zsh Documentation](http://zsh.sourceforge.net/Doc/)
- [`tee` command](https://man7.org/linux/man-pages/man1/tee.1.html)
- [Git `--no-pager` option](https://git-scm.com/docs/git#Documentation/git.txt---no-pager)
- [GitHub CLI Pager Configuration](https://cli.github.com/manual/gh_help_environment)
