#!/usr/bin/env zsh

# Test suite for configure_ai_instructions.zsh
# Usage: ./scripts/configure_ai_instructions_tests.zsh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test workspace
TEST_WORKSPACE="/tmp/ai_instructions_test_$$"
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/configure_ai_instructions.zsh"

function setup_test_workspace {
  echo "${YELLOW}Setting up test workspace: $TEST_WORKSPACE${NC}"
  rm -rf "$TEST_WORKSPACE"
  mkdir -p "$TEST_WORKSPACE"
  cd "$TEST_WORKSPACE"
  git init -q
}

function cleanup_test_workspace {
  echo "${YELLOW}Cleaning up test workspace${NC}"
  rm -rf "$TEST_WORKSPACE"
}

function test_start {
  TESTS_RUN=$((TESTS_RUN + 1))
  echo ""
  echo "${YELLOW}[TEST $TESTS_RUN]${NC} $1"
}

function test_pass {
  TESTS_PASSED=$((TESTS_PASSED + 1))
  echo "${GREEN}✓ PASS${NC}: $1"
}

function test_fail {
  TESTS_FAILED=$((TESTS_FAILED + 1))
  echo "${RED}✗ FAIL${NC}: $1"
}

function assert_file_exists {
  if [[ -f "$1" ]]; then
    test_pass "File exists: $1"
  else
    test_fail "File does not exist: $1"
  fi
}

function assert_symlink_exists {
  if [[ -L "$1" ]]; then
    test_pass "Symlink exists: $1"
  else
    test_fail "Symlink does not exist: $1"
  fi
}

function assert_file_contains {
  local file="$1"
  local pattern="$2"
  if grep -q "$pattern" "$file" 2>/dev/null; then
    test_pass "File contains pattern: $pattern"
  else
    test_fail "File does not contain pattern: $pattern"
  fi
}

function assert_path_not_exists {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    test_pass "Path does not exist (expected): $path"
  else
    test_fail "Path unexpectedly exists: $path"
  fi
}

function assert_checksums_count {
  local expected="$1"
  local actual=0
  local checksums_file="$TEST_WORKSPACE/.gitignored/.ai-checksums"
  if [[ -f "$checksums_file" ]]; then
    actual=$(wc -l < "$checksums_file" | tr -d ' ')
  fi
  if [[ "$actual" == "$expected" ]]; then
    test_pass "Checksums count: expected=$expected, actual=$actual"
  else
    test_fail "Checksums count: expected=$expected, actual=$actual"
  fi
}

# ==================== TESTS ====================

test_start "Symlink mode - all files"
setup_test_workspace
echo "all" | "$SCRIPT_PATH" --configure-type symlink >/dev/null 2>&1
assert_file_exists "$TEST_WORKSPACE/.github/copilot-instructions.md"
assert_symlink_exists "$TEST_WORKSPACE/.github/instructions/agent-terminal-conventions.instructions.md"
assert_checksums_count 0
cleanup_test_workspace

test_start "Copy mode - 3 files"
setup_test_workspace
echo "1 2 3" | "$SCRIPT_PATH" --configure-type copy >/dev/null 2>&1
assert_file_exists "$TEST_WORKSPACE/.github/copilot-instructions.md"
assert_file_exists "$TEST_WORKSPACE/.github/instructions/agent-swift-terminal-conventions.instructions.md"
# Should have 3 checksums for 3 copied files
assert_checksums_count 3
# Verify it's not a symlink
if [[ ! -L "$TEST_WORKSPACE/.github/instructions/agent-swift-terminal-conventions.instructions.md" ]]; then
  test_pass "File is a copy, not a symlink"
else
  test_fail "File is a symlink, should be a copy"
fi
cleanup_test_workspace

test_start "Mixed mode - copy then symlink"
setup_test_workspace
# First copy 3 files
echo "1 2 3" | "$SCRIPT_PATH" --configure-type copy >/dev/null 2>&1
assert_checksums_count 3
# Then symlink all files (should replace copies)
echo "all" | "$SCRIPT_PATH" --configure-type symlink >/dev/null 2>&1
# Checksums should now be 0 (all are symlinks)
assert_checksums_count 0
assert_symlink_exists "$TEST_WORKSPACE/.github/instructions/agent-swift-terminal-conventions.instructions.md"
cleanup_test_workspace

test_start "Instruction list regeneration"
setup_test_workspace
# Install 3 files
echo "1 2 3" | "$SCRIPT_PATH" --configure-type symlink >/dev/null 2>&1
# Check copilot-instructions.md has 3 entries
entry_count=$(grep -c "^- \[" "$TEST_WORKSPACE/.github/copilot-instructions.md" || echo 0)
if [[ "$entry_count" == "3" ]]; then
  test_pass "Instruction list has 3 entries"
else
  test_fail "Instruction list has $entry_count entries, expected 3"
fi
# Install all files
echo "all" | "$SCRIPT_PATH" --configure-type symlink >/dev/null 2>&1
# Check copilot-instructions.md has 9 entries
entry_count=$(grep -c "^- \[" "$TEST_WORKSPACE/.github/copilot-instructions.md" || echo 0)
if [[ "$entry_count" == "9" ]]; then
  test_pass "Instruction list has 9 entries"
else
  test_fail "Instruction list has $entry_count entries, expected 9"
fi
cleanup_test_workspace

test_start "Project analysis detection"
setup_test_workspace
# Create some project files
touch "$TEST_WORKSPACE/test.swift"
touch "$TEST_WORKSPACE/test.py"
touch "$TEST_WORKSPACE/package.json"
echo "all" | "$SCRIPT_PATH" --configure-type symlink >/dev/null 2>&1
assert_file_contains "$TEST_WORKSPACE/.github/copilot-instructions.md" "Swift"
assert_file_contains "$TEST_WORKSPACE/.github/copilot-instructions.md" "Python"
cleanup_test_workspace

test_start "Dry run mode"
setup_test_workspace
if output=$(echo "all" | "$SCRIPT_PATH" --configure-type symlink --dry-run 2>&1); then
  if echo "$output" | grep -q "DRY-RUN"; then
    test_pass "Dry run emitted DRY-RUN marker"
  else
    test_fail "Dry run output missing DRY-RUN marker"
  fi
else
  test_fail "Dry run command failed"
fi
# No files should be created
if [[ ! -f "$TEST_WORKSPACE/.github/copilot-instructions.md" ]]; then
  test_pass "Dry run did not create files"
else
  test_fail "Dry run created files"
fi
cleanup_test_workspace

test_start "Running from subdirectory uses git root"
setup_test_workspace
mkdir -p "$TEST_WORKSPACE/.github/instructions"
(
  cd "$TEST_WORKSPACE/.github/instructions"
  printf "1\n" | "$SCRIPT_PATH" --configure-type symlink >/dev/null 2>&1
)
assert_symlink_exists "$TEST_WORKSPACE/.github/instructions/agent-swift-terminal-conventions.instructions.md"
assert_path_not_exists "$TEST_WORKSPACE/.github/instructions/.github"
cleanup_test_workspace

test_start "VS Code workspace merge handles JSONC"
setup_test_workspace
cat <<'EOF' > "$TEST_WORKSPACE/Sample.code-workspace"
{
  // Root folders
  "folders": [
    {
      "path": ".",
    },
  ],
  "settings": {
    "existing.setting": true, // preserve this value
  },
}
EOF
# Provide empty selection to skip installing instructions while testing workspace merge
printf "\n" | "$SCRIPT_PATH" --configure-type symlink --vscode-settings >/dev/null 2>&1
assert_file_contains "$TEST_WORKSPACE/Sample.code-workspace" "existing.setting"
assert_file_contains "$TEST_WORKSPACE/Sample.code-workspace" "chat.agent.thinkingStyle"
cleanup_test_workspace

# ==================== SUMMARY ====================

echo ""
echo "========================================"
echo "Test Results"
echo "========================================"
echo "Tests run:    $TESTS_RUN"
echo "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [[ $TESTS_FAILED -gt 0 ]]; then
  echo "${RED}Tests failed: $TESTS_FAILED${NC}"
  exit 1
else
  echo "${GREEN}All tests passed!${NC}"
  exit 0
fi
