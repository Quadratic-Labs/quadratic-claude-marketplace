#!/bin/bash

# devflow StartSession Hook
# Greets the user and loads context about recent issues and branches

echo "🚀 Welcome to your dev session!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get user's git name for personalized greeting
USER_NAME=$(git config user.name 2>/dev/null || echo "Developer")
echo "👋 Hi $USER_NAME! Let me catch you up on what's been happening..."
echo ""

# Fetch latest from remote to ensure we have up-to-date info
echo "📡 Fetching latest from remote..."
git fetch origin --quiet 2>/dev/null

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"
echo ""

# Show recent branches you've been working on
echo "🌿 Recent branches you've worked on:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get recent local branches sorted by last commit date
git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:relative)|%(authorname)' --count=5 | while IFS='|' read -r branch date author; do
    if [ "$branch" = "$CURRENT_BRANCH" ]; then
        echo "  → $branch (current) - last commit $date"
    else
        echo "    $branch - last commit $date"
    fi
done

echo ""

# Show recent remote branches
echo "🌍 Recent remote branches:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
git for-each-ref --sort=-committerdate refs/remotes/origin/ --format='%(refname:short)|%(committerdate:relative)' --count=5 | while IFS='|' read -r branch date; do
    # Skip HEAD reference
    if [[ ! "$branch" =~ HEAD ]]; then
        BRANCH_NAME=${branch#origin/}
        echo "    $BRANCH_NAME - updated $date"
    fi
done

echo ""

# Try to fetch recent issues using gh CLI
if command -v gh &> /dev/null; then
    echo "🎫 Recent GitHub issues:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if gh is authenticated
    if gh auth status &>/dev/null; then
        # Get recent open issues
        gh issue list --limit 5 --state open --json number,title,updatedAt,author 2>/dev/null | \
        jq -r '.[] | "    #\(.number) - \(.title) (by \(.author.login), updated \(.updatedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>/dev/null || \
        echo "    (Unable to fetch issues)"

        echo ""

        # Get recently closed issues
        echo "📦 Recently closed issues:"
        gh issue list --limit 3 --state closed --json number,title,closedAt 2>/dev/null | \
        jq -r '.[] | "    #\(.number) - \(.title) (closed \(.closedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>/dev/null || \
        echo "    (Unable to fetch closed issues)"
    else
        echo "    ⚠️  GitHub CLI not authenticated. Run 'gh auth login' to see issues."
    fi
else
    echo "    ℹ️  GitHub CLI not installed. Install it to see recent issues."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ You're all set! What would you like to work on today?"
echo ""
