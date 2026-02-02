#!/bin/bash
# Check GitHub milestone status for release

set -e

MILESTONE_TITLE="$1"

if [ -z "$MILESTONE_TITLE" ]; then
  echo "Usage: $0 <milestone-title>"
  exit 1
fi

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed"
  exit 1
fi

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

echo "Checking milestone: $MILESTONE_TITLE in $REPO"
echo ""

# Get milestone data
MILESTONE_DATA=$(gh api "repos/$REPO/milestones" --jq ".[] | select(.title == \"$MILESTONE_TITLE\")")

if [ -z "$MILESTONE_DATA" ]; then
  echo "Warning: Milestone '$MILESTONE_TITLE' not found"
  exit 1
fi

# Parse milestone data
MILESTONE_NUMBER=$(echo "$MILESTONE_DATA" | jq -r '.number')
OPEN_ISSUES=$(echo "$MILESTONE_DATA" | jq -r '.open_issues')
CLOSED_ISSUES=$(echo "$MILESTONE_DATA" | jq -r '.closed_issues')
STATE=$(echo "$MILESTONE_DATA" | jq -r '.state')

echo "Milestone: $MILESTONE_TITLE (#$MILESTONE_NUMBER)"
echo "State: $STATE"
echo "Open issues: $OPEN_ISSUES"
echo "Closed issues: $CLOSED_ISSUES"
echo ""

if [ "$OPEN_ISSUES" -gt 0 ]; then
  echo "⚠️  WARNING: Milestone has $OPEN_ISSUES open issue(s)"
  echo ""
  echo "Open issues:"
  gh issue list --milestone "$MILESTONE_TITLE" --state open --json number,title,state,url --template '{{range .}}  #{{.number}} [{{.state}}] {{.title}}
    {{.url}}
{{end}}'
  exit 1
fi

echo "✓ Milestone is complete - all issues closed"
exit 0
