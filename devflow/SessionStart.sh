#!/bin/bash

# devflow StartSession Hook
# Greets the user and loads context about recent issues and branches
# Outputs structured JSON for Claude Code

# Get user's git name for personalized greeting
USER_NAME=$(git config user.name 2>/dev/null || echo "Developer")

# Fetch latest from remote to ensure we have up-to-date info
git fetch origin --quiet 2>/dev/null

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Get recent local branches sorted by last commit date
LOCAL_BRANCHES=$(git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:relative)|%(authorname)' --count=5 | while IFS='|' read -r branch date author; do
    if [ "$branch" = "$CURRENT_BRANCH" ]; then
        echo "  → $branch (current) - last commit $date"
    else
        echo "    $branch - last commit $date"
    fi
done)

# Get recent remote branches
REMOTE_BRANCHES=$(git for-each-ref --sort=-committerdate refs/remotes/origin/ --format='%(refname:short)|%(committerdate:relative)' --count=5 | while IFS='|' read -r branch date; do
    # Skip HEAD reference
    if [[ ! "$branch" =~ HEAD ]]; then
        BRANCH_NAME=${branch#origin/}
        echo "    $BRANCH_NAME - updated $date"
    fi
done)

# Try to fetch recent issues using gh CLI
GITHUB_ISSUES=""
CLOSED_ISSUES=""
if command -v gh &> /dev/null; then
    # Check if gh is authenticated
    if gh auth status &>/dev/null; then
        # Get recent open issues
        GITHUB_ISSUES=$(gh issue list --limit 5 --state open --json number,title,updatedAt,author 2>/dev/null | \
        jq -r '.[] | "    #\(.number) - \(.title) (by \(.author.login), updated \(.updatedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>/dev/null || echo "")

        # Get recently closed issues
        CLOSED_ISSUES=$(gh issue list --limit 3 --state closed --json number,title,closedAt 2>/dev/null | \
        jq -r '.[] | "    #\(.number) - \(.title) (closed \(.closedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>/dev/null || echo "")
    fi
fi

# Build the display message
DISPLAY_MESSAGE="🚀 Welcome to your dev session!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👋 Hi $USER_NAME! Let me catch you up on what's been happening...

📡 Fetching latest from remote...
📍 Current branch: $CURRENT_BRANCH

🌿 Recent branches you've worked on:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$LOCAL_BRANCHES

🌍 Recent remote branches:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$REMOTE_BRANCHES

🎫 Recent GitHub issues:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$GITHUB_ISSUES

📦 Recently closed issues:
$CLOSED_ISSUES

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ You're all set! What would you like to work on today?"

# Escape the message for JSON (replace newlines, quotes, backslashes)
ESCAPED_MESSAGE=$(echo "$DISPLAY_MESSAGE" | jq -Rs .)

# Output structured JSON
cat <<EOF
{
  "suppressOutput": false,
  "continue": true,
  "systemMessage": $ESCAPED_MESSAGE,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $ESCAPED_MESSAGE
  }
}
EOF
