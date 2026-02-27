# TODO: Enforce AI Instructions By Default

**Problem**: AI agents frequently fail to follow instruction files, requiring constant vigilance and correction. This creates a frustrating cycle of:
- Spending time checking if conventions are followed
- Re-typing messages to correct the agent
- Time wasted away from actual problem-solving

**Goal**: Automate enforcement so the system validates code, not the user.

---

## Solution 1: Pre-Commit Validation Hook

Create a git hook that validates code against instructions BEFORE it's committed:

```zsh
#!/bin/zsh
# .git/hooks/pre-commit

# Check zsh files use modern expansion, not IFS/read for parsing
if git diff --cached --name-only | grep '\.zsh$' > /dev/null; then
  if git diff --cached | grep -E "IFS=.*read.*-r.*<<" > /dev/null; then
    echo "❌ BLOCKED: Zsh file uses bash-style parsing (IFS/read)"
    echo "Use zsh parameter expansion: \${(s.:.)var}"
    exit 1
  fi
fi

# Check for terminology violations
if git diff --cached | grep -iE "(subcategory|destination.*category)" > /dev/null; then
  echo "❌ BLOCKED: Inconsistent terminology detected"
  echo "Use: scope/category/theme"
  exit 1
fi
```

**Impact**: Stops bad code from entering the repo regardless of what the AI did.

**Priority**: HIGH - Most effective immediate solution

---

## Solution 2: Automated Linting as CI Check

GitHub Actions that fail PR if conventions violated:

```yaml
# .github/workflows/validate-conventions.yml
name: Validate Coding Conventions
on: [pull_request]
jobs:
  check-conventions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check zsh conventions
        run: |
          # Fail if IFS/read used for argument parsing
          ! grep -r "IFS=.*read.*-r" --include="*.zsh" scripts/
      - name: Check terminology
        run: |
          # Fail if old terms used
          ! grep -riE "(subcategory|destination.*category)" scripts/*.md
```

**Impact**: Automated enforcement - system checks, not user.

**Priority**: HIGH - Complements pre-commit hooks

---

## Solution 3: VSCode Workspace Settings with Strict Linting

Force conventions at editor level:

```jsonc
// .vscode/settings.json
{
  "shellcheck.enable": true,
  "shellcheck.customArgs": [
    "-s", "zsh",  // Force zsh checking
    "-e", "SC2034,SC2155"  // Enforce specific rules
  ],
  
  // Custom problem matchers for terminology
  "problemMatcher": [
    {
      "pattern": {
        "regexp": "(subcategory|destination)",
        "message": "Use correct terminology: scope/category/theme"
      }
    }
  ]
}
```

**Impact**: Real-time feedback in editor.

**Priority**: MEDIUM - Helpful but doesn't prevent commits

---

## Solution 4: Session Template that Forces Instruction Reading

Create a session starter script:

```zsh
#!/bin/zsh
# start_ai_session.zsh

echo "📋 Loading AI Instructions..."

# Detect applicable instructions
local -a instructions=()
[[ -f .github/copilot-instructions.md ]] && instructions+=(.github/copilot-instructions.md)
[[ -d .github/instructions ]] && instructions+=(.github/instructions/*.md)

if (( ${#instructions} == 0 )); then
  echo "⚠️  No AI instructions found in this repo"
  exit 1
fi

# Generate session preamble
cat > /tmp/ai_session_context.md <<EOF
# MANDATORY READING BEFORE ANY RESPONSES

## Active Instruction Files
$(for f in $instructions; do echo "- [$f]($f)"; done)

## Verification Checklist (AI MUST confirm)
☐ Read all instruction files above
☐ Identified language/framework from repo
☐ Will apply relevant conventions automatically
☐ Will cite which instruction guided each decision

**USER REQUIREMENT**: Confirm checklist completion before first response.
EOF

cat /tmp/ai_session_context.md
echo "\n✅ Copy this preamble to start your AI session"
```

**Usage**: Run at session start, paste output into chat. AI must confirm checklist.

**Impact**: Sets expectations upfront.

**Priority**: MEDIUM - Helps but relies on AI compliance

---

## Solution 5: Copilot Chat Participants (VSCode)

Create custom chat participant that enforces checking:

```typescript
// extension.ts
vscode.chat.createChatParticipant('strict-dev', async (request, context, progress, token) => {
  // Force instruction file reading before answering
  const instructions = await loadInstructions();
  
  if (!context.history.some(h => h.includes('confirmed reading instructions'))) {
    return {
      role: vscode.ChatResponseTurn.system,
      message: `❌ You must confirm reading instructions before I proceed:\n${instructions.join('\n')}`
    };
  }
  
  // Continue with request...
});
```

**Usage**: Users invoke with `@strict-dev` - it won't work unless agent confirms.

**Impact**: Programmatic enforcement at chat level.

**Priority**: LOW - Requires extension development

---

## Solution 6: Wrapper Script for All AI Code

Post-process ALL AI-generated code through validation:

```zsh
#!/bin/zsh
# validate_ai_output.zsh

local input_file=$1
local language=$2

case $language in
  zsh)
    # Check zsh conventions
    if grep -q "IFS=.*read.*-r" "$input_file"; then
      echo "❌ REJECTED: Uses bash patterns"
      return 1
    fi
    ;;
  markdown)
    # Check terminology
    if grep -qiE "(subcategory|destination.*category)" "$input_file"; then
      echo "❌ REJECTED: Wrong terminology"
      return 1
    fi
    ;;
esac

echo "✅ PASSED validation"
return 0
```

**Usage**: Make this part of workflow - AI output doesn't go in until it passes.

**Impact**: Final safety net before code enters repo.

**Priority**: MEDIUM - Good backstop but requires manual step

---

## Implementation Priority

**Phase 1 (Immediate)**:
1. Pre-commit hooks - Blocks bad commits automatically
2. CI validation - Catches what hooks miss

**Phase 2 (Short-term)**:
3. VSCode workspace settings - Real-time editor feedback
4. Session starter script - Sets expectations

**Phase 3 (Long-term)**:
5. Custom chat participant - Programmatic enforcement
6. Validation wrapper - Additional safety layer

---

## Key Principle

**Automation > Education**: The user-checking-agent-work cycle breaks when **the system enforces rules automatically**. User should spend zero time checking if conventions are followed - automated checks do that.

---

## Next Actions

- [ ] Implement pre-commit hook with zsh and terminology checks
- [ ] Add GitHub Actions workflow for CI validation
- [ ] Update VSCode workspace settings with linting rules
- [ ] Create session starter script for AI interactions
- [ ] Document enforcement system in README

---

## References

- Pre-commit hooks: https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
- GitHub Actions: https://docs.github.com/en/actions
- VSCode Tasks: https://code.visualstudio.com/docs/editor/tasks
- ShellCheck: https://www.shellcheck.net/
