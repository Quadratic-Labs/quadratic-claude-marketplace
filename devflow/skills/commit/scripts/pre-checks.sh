#!/bin/bash
# Pre-commit checks - gathers git state in one call
# Outputs JSON for easy parsing by the LLM

set -e

CONFIG_FILE="${1:-devflow/skills/commit/commit.yaml}"

# Check if in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo '{"error": "Not a git repository"}'
  exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "HEAD")

# Get default branch (try common names)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Get staged files
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')

# Get staged files count
STAGED_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')

# Get unstaged modified files
UNSTAGED_FILES=$(git diff --name-only 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')

# Get untracked files
UNTRACKED_FILES=$(git ls-files --others --exclude-standard 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')

# Check for merge conflicts
CONFLICTS=$(git diff --name-only --diff-filter=U 2>/dev/null | jq -R -s -c 'split("\n") | map(select(length > 0))')

# Get staged file sizes (for large file warning)
LARGE_FILES="[]"
if [ "$STAGED_COUNT" -gt 0 ]; then
  LARGE_FILES=$(git diff --cached --name-only 2>/dev/null | while read file; do
    if [ -f "$file" ]; then
      SIZE_KB=$(du -k "$file" 2>/dev/null | cut -f1)
      if [ "$SIZE_KB" -gt 100 ]; then
        echo "{\"file\": \"$file\", \"size_kb\": $SIZE_KB}"
      fi
    fi
  done | jq -s -c '.' 2>/dev/null || echo "[]")
fi

# Check working tree status
WORKTREE_CLEAN=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
if [ "$WORKTREE_CLEAN" -eq 0 ]; then
  WORKTREE_STATUS="clean"
else
  WORKTREE_STATUS="dirty"
fi

# Check if branch is ahead/behind remote
AHEAD=0
BEHIND=0
if git rev-parse --abbrev-ref @{upstream} &>/dev/null; then
  AHEAD=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo 0)
  BEHIND=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo 0)
fi

# Get last commit info
LAST_COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "")
LAST_COMMIT_MSG=$(git log -1 --pretty=%s 2>/dev/null || echo "")

# Parse protected branches from config if available
PROTECTED_BRANCHES="[]"
if [ -f "$CONFIG_FILE" ]; then
  # Try to extract protected branches using grep (fallback if yq not available)
  if command -v yq &> /dev/null; then
    PROTECTED_BRANCHES=$(yq -o=json '.branches.protected' "$CONFIG_FILE" 2>/dev/null || echo '["main", "master"]')
  else
    # Fallback: assume main and master are protected
    PROTECTED_BRANCHES='["main", "master"]'
  fi
fi

# Check if current branch is protected
IS_PROTECTED="false"
if echo "$PROTECTED_BRANCHES" | grep -q "\"$CURRENT_BRANCH\""; then
  IS_PROTECTED="true"
fi

# Output JSON
cat <<EOF
{
  "current_branch": "$CURRENT_BRANCH",
  "default_branch": "$DEFAULT_BRANCH",
  "is_protected_branch": $IS_PROTECTED,
  "protected_branches": $PROTECTED_BRANCHES,
  "staged_files": $STAGED_FILES,
  "staged_count": $STAGED_COUNT,
  "unstaged_files": $UNSTAGED_FILES,
  "untracked_files": $UNTRACKED_FILES,
  "conflicts": $CONFLICTS,
  "large_files": $LARGE_FILES,
  "worktree_status": "$WORKTREE_STATUS",
  "remote": {
    "ahead": $AHEAD,
    "behind": $BEHIND
  },
  "last_commit": {
    "hash": "$LAST_COMMIT_HASH",
    "message": "$LAST_COMMIT_MSG"
  }
}
EOF
