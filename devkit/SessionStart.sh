#!/bin/bash

# devkit StartSession Hook
# Greets the user and loads context about recent issues and branches
# Outputs structured JSON for Claude Code

# Check if jq is available
HAS_JQ=false
if command -v jq &> /dev/null; then
    HAS_JQ=true
fi

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
        if [ "$HAS_JQ" = true ]; then
            # Get recent open issues with jq formatting
            GITHUB_ISSUES=$(gh issue list --limit 5 --state open --json number,title,updatedAt,author 2>/dev/null | \
            jq -r '.[] | "    #\(.number) - \(.title) (by \(.author.login), updated \(.updatedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>/dev/null || echo "")

            # Get recently closed issues with jq formatting
            CLOSED_ISSUES=$(gh issue list --limit 3 --state closed --json number,title,closedAt 2>/dev/null | \
            jq -r '.[] | "    #\(.number) - \(.title) (closed \(.closedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>/dev/null || echo "")
        else
            # Fallback: use plain text format from gh CLI
            GITHUB_ISSUES=$(gh issue list --limit 5 --state open 2>/dev/null | sed 's/^/    /' || echo "")
            CLOSED_ISSUES=$(gh issue list --limit 3 --state closed 2>/dev/null | sed 's/^/    /' || echo "")
        fi
    fi
fi

# Build the display message

  
   🟩🟩🟩🟩🟩🟩
  🟩           🟩    👋 Hi $UserName! 
  🟩           🟩       Welcome to the QUADRATIC DevKit 
  🟩           🟩       
  🟩           🟩    💡 For help, type :
  🟩           🟩       /devkit:help
   🟩🟩🟩🟩              
           🟩  
            🟩       
            
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👋 Let me catch you up on what's been happening...

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
if [ "$HAS_JQ" = true ]; then
    ESCAPED_MESSAGE=$(echo "$DISPLAY_MESSAGE" | jq -Rs .)
else
    # Manual JSON escaping fallback when jq is not available
    # Use awk for more portable multiline handling
    ESCAPED_MESSAGE=$(printf '%s' "$DISPLAY_MESSAGE" | awk '
        BEGIN { ORS="" }
        {
            gsub(/\\/, "\\\\")
            gsub(/"/, "\\\"")
            gsub(/\t/, "\\t")
            gsub(/\r/, "")
            if (NR > 1) printf "\\n"
            print
        }
        END { }
    ')
    ESCAPED_MESSAGE="\"$ESCAPED_MESSAGE\""
fi

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
