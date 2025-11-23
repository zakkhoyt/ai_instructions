````instructions
---
applyTo: "**/*.py"
---

# Git Branching and GitHub Pull Request Conventions (Python)

**IMPORTANT**: These conventions apply when creating branches and pull requests in Python repositories.

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
2. Fallback to system username

**Examples:**
- Git config: "Zakk Hoyt" → `zakk_hoyt`
- Git config: "John Smith" → `john_smith`
- System: "zakkhoyt" → `zakkhoyt`

**Python Implementation:**
```python
import subprocess
import getpass
import re

def get_git_username():
    """Extract username from git config, convert to lower_snake_case."""
    try:
        username = subprocess.check_output(
            ['git', 'config', 'user.name'],
            text=True
        ).strip()
        # Convert to lower_snake_case
        username = username.lower().replace(' ', '_')
    except subprocess.CalledProcessError:
        # Fallback to system username
        username = getpass.getuser()
    
    return username
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

**Python Implementation:**
```python
import subprocess
import re

def detect_jira_usage():
    """
    Detect if repository uses Jira issues.
    Returns: bool - True if Jira is used, False otherwise
    """
    jira_pattern = re.compile(r'\[?[A-Z]{2,4}-[0-9]{3,5}\]?')
    match_count = 0
    
    # Check merge commits (highest signal)
    try:
        merge_commits = subprocess.check_output(
            ['git', 'log', '--all', '--merges', '--oneline'],
            text=True
        )
        match_count += len(jira_pattern.findall(merge_commits))
    except subprocess.CalledProcessError:
        pass
    
    # Check branch names
    try:
        branches = subprocess.check_output(
            ['git', 'branch', '-a'],
            text=True
        )
        match_count += len(jira_pattern.findall(branches))
    except subprocess.CalledProcessError:
        pass
    
    # Check PR titles (if GitHub CLI available)
    try:
        prs = subprocess.check_output(
            ['gh', 'pr', 'list', '--state', 'all', '--limit', '20', '--json', 'title'],
            text=True
        )
        match_count += len(jira_pattern.findall(prs))
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass
    
    return match_count >= 2
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

**Python Implementation:**
```python
import re

def extract_jira_from_branch(branch_name: str) -> str | None:
    """Extract Jira issue ID from branch name."""
    jira_pattern = re.compile(r'[A-Z]{2,4}-[0-9]{3,5}')
    match = jira_pattern.search(branch_name)
    return match.group(0) if match else None

def get_current_branch() -> str:
    """Get current git branch name."""
    result = subprocess.check_output(
        ['git', 'branch', '--show-current'],
        text=True
    )
    return result.strip()

# Usage
branch = get_current_branch()
jira_issue = extract_jira_from_branch(branch)
if jira_issue:
    print(f"Found Jira issue: {jira_issue}")
```

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

- [ ] **Username extracted** from git config or system username
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

## Python Helper Functions

### Complete Branch Creation Helper

```python
import subprocess
import getpass
import re
from typing import Optional

def get_git_username() -> str:
    """Extract username from git config, convert to lower_snake_case."""
    try:
        username = subprocess.check_output(
            ['git', 'config', 'user.name'],
            text=True
        ).strip()
        username = username.lower().replace(' ', '_')
    except subprocess.CalledProcessError:
        username = getpass.getuser()
    return username

def detect_jira_usage() -> bool:
    """Detect if repository uses Jira issues."""
    jira_pattern = re.compile(r'\[?[A-Z]{2,4}-[0-9]{3,5}\]?')
    match_count = 0
    
    try:
        merge_commits = subprocess.check_output(
            ['git', 'log', '--all', '--merges', '--oneline'],
            text=True
        )
        match_count += len(jira_pattern.findall(merge_commits))
    except subprocess.CalledProcessError:
        pass
    
    try:
        branches = subprocess.check_output(['git', 'branch', '-a'], text=True)
        match_count += len(jira_pattern.findall(branches))
    except subprocess.CalledProcessError:
        pass
    
    return match_count >= 2

def create_branch_name(
    username: str,
    category: str,
    topic: str
) -> str:
    """
    Create properly formatted branch name.
    
    Args:
        username: User identifier (lower_snake_case)
        category: Jira issue or code category (Jira preserves format, else lower_snake_case)
        topic: Specific change description (lower_snake_case)
    
    Returns:
        Formatted branch name: username/category/topic
    """
    # Jira issues preserve their format (e.g., HSD-12345)
    jira_pattern = re.compile(r'^[A-Z]{2,4}-[0-9]{3,5}$')
    if not jira_pattern.match(category):
        category = category.lower().replace(' ', '_')
    
    topic = topic.lower().replace(' ', '_')
    
    return f"{username}/{category}/{topic}"

def create_git_branch(branch_name: str) -> bool:
    """
    Create and checkout new git branch.
    
    Args:
        branch_name: Fully formatted branch name
    
    Returns:
        True if successful, False otherwise
    """
    try:
        subprocess.check_call(['git', 'checkout', '-b', branch_name])
        return True
    except subprocess.CalledProcessError as e:
        print(f"Failed to create branch: {e}")
        return False

# Example usage
if __name__ == "__main__":
    username = get_git_username()
    uses_jira = detect_jira_usage()
    
    if uses_jira:
        print("Repository uses Jira. Provide issue ID or code-based category.")
        category = input("Category (e.g., HSD-12345 or error_handling): ")
    else:
        print("Repository does not use Jira. Using code-based category.")
        category = input("Category (e.g., api_client, database): ")
    
    topic = input("Topic (e.g., fix_error_handling): ")
    
    branch_name = create_branch_name(username, category, topic)
    print(f"Creating branch: {branch_name}")
    
    if create_git_branch(branch_name):
        print("✓ Branch created successfully")
    else:
        print("✗ Failed to create branch")
```

---

## Examples by Scenario

### Scenario 1: Repository with Jira, Issue Available

```python
# Detected: Repository uses Jira (found in merge commits)
# Given: User working on HSD-12345 to fix error handling

username = "zakk_hoyt"
category = "HSD-12345"  # Jira issue (preserves format)
topic = "fix_error_handling"

# Branch name
branch_name = f"{username}/{category}/{topic}"
# Result: "zakk_hoyt/HSD-12345/fix_error_handling"

# PR title
pr_title = "Fix error handling in dev functions [HSD-12345]"
```

### Scenario 2: Repository with Jira, No Issue Assigned

```python
# Detected: Repository uses Jira (found in branches)
# Action: Prompt user for Jira issue or proceed without

# Option A: User provides issue
category = "HSD-98765"

# Option B: User says no issue, use code-based category
category = "error_handling"

username = "zakk_hoyt"
topic = "add_fatal_patterns"

branch_name = f"{username}/{category}/{topic}"
# Result: "zakk_hoyt/error_handling/add_fatal_patterns"

pr_title = "Add fatal error patterns to function documentation"
```

### Scenario 3: Repository Without Jira

```python
# Detected: No Jira usage found
# Action: Use code-based category

username = "zakk_hoyt"
category = "documentation"  # Code-based
topic = "function_error_handling"

branch_name = f"{username}/{category}/{topic}"
# Result: "zakk_hoyt/documentation/function_error_handling"

pr_title = "Document function-level error handling patterns"
```

### Scenario 4: Generic Changes Across Multiple Areas

```python
# Detected: No Jira usage
# Scenario: Refactoring that touches multiple subsystems

username = "zakk_hoyt"
category = "refactor"  # Generic fallback
topic = "cleanup_legacy_utilities"

branch_name = f"{username}/{category}/{topic}"
# Result: "zakk_hoyt/refactor/cleanup_legacy_utilities"

pr_title = "Refactor and cleanup legacy utility functions"
```

---

## Edge Cases and Troubleshooting

### Empty Git Config Username

**Problem**: `git config user.name` returns empty string

**Solution**: Fall back to system username
```python
def get_git_username():
    try:
        username = subprocess.check_output(
            ['git', 'config', 'user.name'],
            text=True
        ).strip()
        username = username.lower().replace(' ', '_')
    except subprocess.CalledProcessError:
        username = getpass.getuser()
    
    if not username:
        username = getpass.getuser()
    
    return username
```

### Spaces in Git Username

**Problem**: Git username contains spaces: "John Smith"

**Solution**: Convert spaces to underscores
```python
username = username.lower().replace(' ', '_')
# "John Smith" → "john_smith"
```

### Category Cannot Be Determined

**Problem**: No Jira, no clear code category

**Solution**: Use generic fallback with user confirmation
```python
def get_category(uses_jira: bool) -> str:
    if uses_jira:
        category = input("Jira issue or code category: ")
    else:
        print("Select category:")
        print("1. feature")
        print("2. bugfix")
        print("3. refactor")
        print("4. docs")
        print("5. chore")
        print("6. hotfix")
        print("7. custom")
        
        choice = input("Choose (1-7): ")
        categories = ["feature", "bugfix", "refactor", "docs", "chore", "hotfix"]
        
        if choice.isdigit() and 1 <= int(choice) <= 6:
            category = categories[int(choice) - 1]
        else:
            category = input("Enter custom category: ")
    
    return category
```

### Working Directly on Default Branch

**Problem**: Currently on `main` or `master` with uncommitted changes

**Solution**:
```python
import subprocess

def safe_branch_creation(branch_name: str) -> bool:
    """
    Safely create branch, handling uncommitted changes.
    
    Returns:
        True if successful, False otherwise
    """
    # Check current branch
    current_branch = subprocess.check_output(
        ['git', 'branch', '--show-current'],
        text=True
    ).strip()
    
    # Check for uncommitted changes
    try:
        subprocess.check_output(['git', 'diff', '--quiet'])
        has_changes = False
    except subprocess.CalledProcessError:
        has_changes = True
    
    if has_changes:
        print("Uncommitted changes detected. Stashing...")
        subprocess.check_call(['git', 'stash'])
        print("✓ Changes stashed")
    
    try:
        subprocess.check_call(['git', 'checkout', '-b', branch_name])
        print(f"✓ Created and checked out branch: {branch_name}")
        
        if has_changes:
            subprocess.check_call(['git', 'stash', 'pop'])
            print("✓ Changes restored from stash")
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"✗ Failed to create branch: {e}")
        
        # Restore stash if branch creation failed
        if has_changes:
            subprocess.check_call(['git', 'stash', 'pop'])
        
        return False
```

---

## Quick Reference

**Get username:**
```python
username = subprocess.check_output(['git', 'config', 'user.name'], text=True).strip()
username = username.lower().replace(' ', '_') or getpass.getuser()
```

**Detect Jira:**
```python
merge_commits = subprocess.check_output(['git', 'log', '--all', '--merges', '--oneline'], text=True)
uses_jira = len(re.findall(r'[A-Z]{2,4}-[0-9]{3,5}', merge_commits)) >= 2
```

**Create branch:**
```python
subprocess.check_call(['git', 'checkout', '-b', f"{username}/{category}/{topic}"])
```

**Create draft PR:**
```python
subprocess.check_call([
    'gh', 'pr', 'create',
    '--draft',
    '--assignee', '@me',
    '--title', title,
    '--body-file', 'pr_template.md'
])
```

````
