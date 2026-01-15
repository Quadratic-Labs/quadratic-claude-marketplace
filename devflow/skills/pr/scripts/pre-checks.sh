#!/bin/bash
# PR pre-checks - gathers git/gh state in one call
# Outputs JSON for Claude to analyze
# Keep it simple: raw data only, let Claude do the intelligence

set -e

# Check if in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
  echo '{"error": "Not a git repository"}'
  exit 1
fi

# Check dependencies
GH_AVAILABLE=$( command -v gh &>/dev/null && echo "true" || echo "false" )

# Current branch
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -z "$CURRENT_BRANCH" ]; then
  echo '{"error": "Not on a branch (detached HEAD)"}'
  exit 1
fi

# Detect base branch (prefer main over master)
BASE_BRANCH=""
if git show-ref --quiet refs/remotes/origin/main 2>/dev/null; then
  BASE_BRANCH="main"
elif git show-ref --quiet refs/remotes/origin/master 2>/dev/null; then
  BASE_BRANCH="master"
fi

# Remote tracking
REMOTE_EXISTS=$( git show-ref --quiet "refs/remotes/origin/$CURRENT_BRANCH" 2>/dev/null && echo "true" || echo "false" )

# Ahead/behind base
BEHIND=0
AHEAD=0
if [ -n "$BASE_BRANCH" ]; then
  git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null || true
  BEHIND=$(git rev-list --count "HEAD..origin/$BASE_BRANCH" 2>/dev/null || echo 0)
  AHEAD=$(git rev-list --count "origin/$BASE_BRANCH..HEAD" 2>/dev/null || echo 0)
fi

# Commits since base (simple format - Claude parses)
COMMITS=""
if [ -n "$BASE_BRANCH" ] && [ "$AHEAD" -gt 0 ]; then
  COMMITS=$(git log "origin/$BASE_BRANCH..HEAD" --pretty=format:'%h|%s' 2>/dev/null | head -50)
fi

# Changed files (one per line)
CHANGED_FILES=""
if [ -n "$BASE_BRANCH" ]; then
  CHANGED_FILES=$(git diff --name-only "origin/$BASE_BRANCH..HEAD" 2>/dev/null)
fi

# Diff stats
STATS=$(git diff --shortstat "origin/$BASE_BRANCH..HEAD" 2>/dev/null || echo "")

# Existing PR
EXISTING_PR=""
if [ "$GH_AVAILABLE" = "true" ]; then
  EXISTING_PR=$(gh pr view --json number,url,title,state 2>/dev/null || echo "")
fi

# Output (simple format, Claude-friendly)
cat <<EOF
{
  "branch": "$CURRENT_BRANCH",
  "base": "$BASE_BRANCH",
  "remote_exists": $REMOTE_EXISTS,
  "behind": $BEHIND,
  "ahead": $AHEAD,
  "gh_available": $GH_AVAILABLE
}
---COMMITS---
$COMMITS
---FILES---
$CHANGED_FILES
---STATS---
$STATS
---EXISTING_PR---
$EXISTING_PR
EOF
