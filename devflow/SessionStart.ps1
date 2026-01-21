# devflow StartSession Hook
# Greets the user and loads context about recent issues and branches
# Outputs structured JSON for Claude Code

# Check if jq is available
$HasJq = $null -ne (Get-Command jq -ErrorAction SilentlyContinue)

# Get user's git name for personalized greeting
$UserName = git config user.name 2>$null
if (-not $UserName) { $UserName = "Developer" }

# Fetch latest from remote to ensure we have up-to-date info
git fetch origin --quiet 2>$null

# Get current branch
$CurrentBranch = git branch --show-current

# Get recent local branches sorted by last commit date
$LocalBranchesRaw = git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:relative)|%(authorname)' --count=5
$LocalBranches = $LocalBranchesRaw | ForEach-Object {
    $parts = $_ -split '\|'
    $branch = $parts[0]
    $date = $parts[1]
    if ($branch -eq $CurrentBranch) {
        "  -> $branch (current) - last commit $date"
    } else {
        "    $branch - last commit $date"
    }
}
$LocalBranchesStr = $LocalBranches -join "`n"

# Get recent remote branches
$RemoteBranchesRaw = git for-each-ref --sort=-committerdate refs/remotes/origin/ --format='%(refname:short)|%(committerdate:relative)' --count=5
$RemoteBranches = $RemoteBranchesRaw | Where-Object { $_ -notmatch 'HEAD' } | ForEach-Object {
    $parts = $_ -split '\|'
    $branch = $parts[0] -replace '^origin/', ''
    $date = $parts[1]
    "    $branch - updated $date"
}
$RemoteBranchesStr = $RemoteBranches -join "`n"

# Try to fetch recent issues using gh CLI
$GithubIssues = ""
$ClosedIssues = ""

if (Get-Command gh -ErrorAction SilentlyContinue) {
    # Check if gh is authenticated
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        if ($HasJq) {
            # Get recent open issues with jq formatting
            $GithubIssues = gh issue list --limit 5 --state open --json number,title,updatedAt,author 2>$null |
                jq -r '.[] | "    #\(.number) - \(.title) (by \(.author.login), updated \(.updatedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>$null

            # Get recently closed issues with jq formatting
            $ClosedIssues = gh issue list --limit 3 --state closed --json number,title,closedAt 2>$null |
                jq -r '.[] | "    #\(.number) - \(.title) (closed \(.closedAt | fromdateiso8601 | strflocaltime("%Y-%m-%d")))"' 2>$null
        } else {
            # Fallback: use plain text format from gh CLI and add indentation
            $openIssues = gh issue list --limit 5 --state open 2>$null
            if ($openIssues) {
                $GithubIssues = ($openIssues | ForEach-Object { "    $_" }) -join "`n"
            }

            $closedIssuesRaw = gh issue list --limit 3 --state closed 2>$null
            if ($closedIssuesRaw) {
                $ClosedIssues = ($closedIssuesRaw | ForEach-Object { "    $_" }) -join "`n"
            }
        }
    }
}

# Build the display message
$DisplayMessage = @"
🚀 Welcome to your dev session!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

👋 Hi $UserName! Let me catch you up on what's been happening...

📡 Fetching latest from remote...
📍 Current branch: $CurrentBranch

🌿 Recent branches you've worked on:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$LocalBranchesStr

🌍 Recent remote branches:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$RemoteBranchesStr

🎫 Recent GitHub issues:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$GithubIssues

📦 Recently closed issues:
$ClosedIssues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ You're all set! What would you like to work on today?
"@

# Escape the message for JSON using PowerShell's ConvertTo-Json
$EscapedMessage = $DisplayMessage | ConvertTo-Json

# Output structured JSON
$output = @"
{
  "suppressOutput": false,
  "continue": true,
  "systemMessage": $EscapedMessage,
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": $EscapedMessage
  }
}
"@

Write-Output $output
