````instructions
---
applyTo: "**/*"
---

# Git Branching and GitHub Pull Request Conventions

**IMPORTANT**: These conventions apply when creating branches and pull requests in any repository.

---

## Branch Naming Convention

### Standard Format

All branches must follow this three-component pattern:

```
username/category/topic
```

**Component Rules:**
- **Separator**: Use forward slashes (`/`) between components
- **Casing**: Use `lower_snake_case` for all components
- **Exception**: Jira issue IDs preserve their original format (e.g., `HSD-12345`)

### Component Definitions

#### 1. Username (Mandatory)

The git user's identifier, converted to `lower_snake_case`.

**Detection Priority:**
1. `git config user.name` (convert to lower_snake_case)
2. Fallback to `whoami` output

**Examples:**
- Git config: "Zakk Hoyt" → `zakk_hoyt`
- Git config: "John Smith" → `john_smith`
- Whoami: "zakkhoyt" → `zakkhoyt`

**Implementation:**
```zsh
username=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
[[ -z "$username" ]] && username=$(whoami)
```

#### 2. Category (Optional, Recommended)

The work category or Jira issue identifier.

**Priority Order:**
1. **Jira Issue ID** (if available) - Format: `[A-Z]{2,4}-[0-9]{3,5}`
   - Examples: `HSD-12345`, `PROJ-456`, `BUG-9876`
   - Preserve original format (keep hyphens and uppercase)
2. **Code-based category** (if no Jira) - Describe what changed
   - Examples: `error_handling`, `api_client`, `database_schema`, `ci_pipeline`
3. **Generic fallback** (last resort)
   - `feature` - New functionality
   - `bugfix` - Bug fixes  
   - `refactor` - Code restructuring
   - `docs` - Documentation only
   - `chore` - Maintenance tasks
   - `hotfix` - Urgent production fixes

**Category Selection Guidelines:**
- **Prefer code-based categories** that describe the technical area being modified
- Use generic fallbacks only when changes span multiple areas
- Always include category to maintain three-component structure

#### 3. Topic (Mandatory)

Brief description of the specific change.

**Rules:**
- Use `lower_snake_case`
- Be specific and descriptive
- Keep concise (2-5 words ideal)
- Should be more specific than category

**Examples:**
- `fix_error_handling`
- `add_retry_logic`
- `update_conventions`
- `remove_deprecated_endpoints`

### Jira Issue Detection

**CRITICAL**: Before creating a branch, check if the repository uses Jira issues.

**Detection Steps:**

1. **Search merge commits** (highest signal):
   ```zsh
   git log --all --merges --oneline | grep -E '\[?[A-Z]{2,4}-[0-9]{3,5}\]?'
   ```

2. **Search all branches**:
   ```zsh
   git branch -a | grep -E '[A-Z]{2,4}-[0-9]{3,5}'
   ```

3. **Check recent PR titles** (if GitHub CLI available):
   ```zsh
   gh pr list --state all --limit 20 --json title | grep -E '[A-Z]{2,4}-[0-9]{3,5}'
   ```

**Decision Logic:**
- If **2+ matches** found across any search → Repository uses Jira
- If **1 match** found → Prompt user: "Is this repository tracked with Jira issues? (yes/no)"
- If **0 matches** → Repository does not use Jira, use code-based categories

### Complete Branch Name Examples

**With Jira Issue:**
```
zakk_hoyt/HSD-12345/fix_error_handling
john_smith/PROJ-456/add_authentication
developer/BUG-9876/patch_memory_leak
```

**Without Jira (Code-based Category):**
```
zakk_hoyt/error_handling/add_fatal_patterns
john_smith/api_client/implement_retry_logic
developer/database/add_user_index
```

**Without Jira (Generic Category Fallback):**
```
zakk_hoyt/refactor/cleanup_legacy_code
john_smith/docs/update_api_guide
developer/hotfix/critical_production_bug
```

---

## GitHub Pull Request Conventions

### PR Creation Requirements

**When to Create PR:**
- ✅ Always create PR when working directly on default branch (e.g., `main`, `master`)
- ✅ Create PR for any branch you want reviewed/merged
- ✅ Use draft PRs for work-in-progress changes

**Default Settings:**
- **Draft Status**: Always create as **draft** initially
- **Assignee**: Auto-assign to yourself (the PR author)
- **Reviewers**: Do not auto-assign reviewers (manual assignment as needed)
- **Labels**: Do not auto-assign labels (manual assignment as needed)
- **Linked Issues**: Auto-link Jira issues if present in branch name

### PR Title Format

**With Jira Issue:**
```
<Descriptive summary of changes> [JIRA-12345]
```

**Examples:**
```
Fix error handling in dev functions [HSD-21334]
Add retry logic to API client [PROJ-456]
Update documentation for new workflow [BUG-9876]
```

**Without Jira Issue:**
```
<Descriptive summary of changes>
```

**Examples:**
```
Refactor error handling to use fatal patterns
Add function-level error handling documentation
Implement pre-filled selection menu for installer
```

**Title Guidelines:**
- Start with verb in imperative mood: "Fix", "Add", "Update", "Refactor", "Remove"
- Be concise but descriptive (50-72 characters ideal)
- Place Jira issue at end in square brackets if available
- Do not include branch name in title

### PR Description Template

**REQUIRED**: All PRs must use this template for the body:

````markdown
# 🤝 Why am I opening this PR?

[Explain the motivation - what problem does this solve? What was the trigger?]

# 🎉 Changes

[List the key changes made - use bullet points for clarity]

# 🧪 Testing Story

[Describe how this was tested - manual testing, automated tests, verification steps]

# 🏋️ Effort to Review
Expected review effort: ☐/✅
* ☐ `x-small` (< 5 minutes)
* ☐ `small` (5-15 minutes)
* ☐ `medium` (15-30 minutes)
* ☐ `large` (30-60 minutes)
* ☐ `x-large` (> 60 minutes)

<!-- 
# References
* [Review comments that are easy to grok and grep](https://conventionalcomments.org)

## GitHub Flavored Markdown
* [GitHub: GitHub Flavored Markdown](https://github.github.com/gfm/) 
* [GitHub: Advanced Formatting](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting)
* [MARKDOWN_SYNTAX_GITHUB.md]($HOME/Documents/notes/markdown/MARKDOWN_SYNTAX_GITHUB.md)
-->
````

**Template Filling Guidelines:**

1. **Why am I opening this PR?**
   - Provide context and motivation
   - Link to related issues or discussions
   - Explain the problem being solved

2. **Changes**
   - Use bullet points for each major change
   - Group related changes together
   - Highlight breaking changes or migrations
   - Include file paths for significant modifications

3. **Testing Story**
   - Describe manual testing performed
   - List automated test coverage added/updated
   - Include verification commands or steps
   - Note any edge cases tested

4. **Effort to Review**
   - Check **one** box that best matches expected review time
   - Consider: lines changed, complexity, number of files
   - Be realistic to help reviewers plan their time

### Linking Jira Issues

**Automatic Detection:**

When creating a PR, automatically detect and link Jira issues from:
1. **Branch name**: Extract issue ID from category component
2. **Commit messages**: Scan for Jira patterns in commits on the branch

**Link Format:**

Add to PR description after template sections:

```markdown
---

**Related Issues:**
- [HSD-12345](https://jira.company.com/browse/HSD-12345)
```

**Note**: Update the Jira URL base (`jira.company.com`) to match your organization's Jira instance.

---

## Implementation Checklist

When creating a branch and PR, ensure:

- [ ] **Username extracted** from git config or whoami
- [ ] **Jira detection** performed (check merges, branches, PRs)
- [ ] **Category determined**:
  - [ ] Jira issue ID (if repo uses Jira and issue provided)
  - [ ] Code-based category (preferred if no Jira)
  - [ ] Generic fallback (last resort)
- [ ] **Topic created** - specific, descriptive, lower_snake_case
- [ ] **Branch name formatted** correctly: `username/category/topic`
- [ ] **Branch created** and checked out
- [ ] **Changes committed** to new branch
- [ ] **PR created** with:
  - [ ] Proper title format (with/without Jira)
  - [ ] Template-based description (all sections filled)
  - [ ] Draft status enabled
  - [ ] Self-assigned as assignee
  - [ ] Jira issue linked (if applicable)

---

## Quick Reference Commands

**Detect Jira usage:**
```zsh
# Check merge commits (most reliable)
git log --all --merges --oneline | grep -E '\[?[A-Z]{2,4}-[0-9]{3,5}\]?'

# Check branches
git branch -a | grep -E '[A-Z]{2,4}-[0-9]{3,5}'

# Check PRs (requires GitHub CLI)
gh pr list --state all --limit 20 --json title | grep -E '[A-Z]{2,4}-[0-9]{3,5}'
```

**Get username:**
```zsh
username=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
[[ -z "$username" ]] && username=$(whoami)
echo "$username"
```

**Create branch:**
```zsh
git checkout -b "$username/$category/$topic"
```

**Create draft PR (GitHub CLI):**
```zsh
gh pr create --draft --assignee @me --title "Title here" --body "$(cat pr_template.md)"
```

---

## Examples by Scenario

### Scenario 1: Repository with Jira, Issue Available

```zsh
# Detected: Repository uses Jira (found in merge commits)
# Given: User working on HSD-12345 to fix error handling

username="zakk_hoyt"
category="HSD-12345"
topic="fix_error_handling"

# Branch name
git checkout -b "zakk_hoyt/HSD-12345/fix_error_handling"

# PR title
"Fix error handling in dev functions [HSD-12345]"

# PR description includes link
"**Related Issues:**
- [HSD-12345](https://jira.company.com/browse/HSD-12345)"
```

### Scenario 2: Repository with Jira, No Issue Assigned

```zsh
# Detected: Repository uses Jira (found in branches)
# Action: Prompt user for Jira issue or proceed without

# Option A: User provides issue
category="HSD-98765"

# Option B: User says no issue, use code-based category
category="error_handling"

username="zakk_hoyt"
topic="add_fatal_patterns"

# Branch name
git checkout -b "zakk_hoyt/error_handling/add_fatal_patterns"

# PR title (no Jira)
"Add fatal error patterns to function documentation"
```

### Scenario 3: Repository Without Jira

```zsh
# Detected: No Jira usage found
# Action: Use code-based category

username="zakk_hoyt"
category="documentation"  # Code-based
topic="function_error_handling"

# Branch name
git checkout -b "zakk_hoyt/documentation/function_error_handling"

# PR title (no Jira)
"Document function-level error handling patterns"
```

### Scenario 4: Generic Changes Across Multiple Areas

```zsh
# Detected: No Jira usage
# Scenario: Refactoring that touches multiple subsystems

username="zakk_hoyt"
category="refactor"  # Generic fallback
topic="cleanup_legacy_utilities"

# Branch name
git checkout -b "zakk_hoyt/refactor/cleanup_legacy_utilities"

# PR title
"Refactor and cleanup legacy utility functions"
```

---

## Edge Cases and Troubleshooting

### Empty Git Config Username

**Problem**: `git config user.name` returns empty string

**Solution**: Fall back to `whoami`
```zsh
username=$(git config user.name | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
if [[ -z "$username" ]]; then
  username=$(whoami)
fi
```

### Spaces in Git Username

**Problem**: Git username contains spaces: "John Smith"

**Solution**: Convert spaces to underscores
```zsh
username=$(git config user.name | tr ' ' '_' | tr '[:upper:]' '[:lower:]')
# Result: "john_smith"
```

### Category Cannot Be Determined

**Problem**: No Jira, no clear code category

**Solution**: Use generic fallback with user confirmation
```zsh
# Prompt user to select from:
# - feature, bugfix, refactor, docs, chore, hotfix
# Default to "chore" if truly miscellaneous
```

### Multiple Jira Patterns in Repo

**Problem**: Found different Jira project prefixes (HSD-*, PROJ-*, BUG-*)

**Solution**: Repository uses Jira - proceed normally. Different prefixes are expected (different teams/projects).

### Working Directly on Default Branch

**Problem**: Currently on `main` or `master` with uncommitted changes

**Solution**:
1. **Stash changes**: `git stash`
2. **Create branch**: `git checkout -b username/category/topic`
3. **Apply stash**: `git stash pop`
4. **Commit and push**: Create PR immediately

````
