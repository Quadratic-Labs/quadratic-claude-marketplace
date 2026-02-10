# devkit StartSession Hook
# Greets the user and loads context about recent issues and branches
# Outputs structured JSON for Claude Code

# Force UTF-8 output so emojis render correctly on all Windows systems

# ============================================
# Git Protection Hooks (auto-install if missing)
# ============================================
$HooksInstalled = ""
if (Test-Path ".git") {
    $HooksDir = ".git/hooks"
    $ProtectionMarker = "# QUADRATIC-DEVKIT-PROTECTION"

    # Create hooks directory if it doesn't exist
    if (-not (Test-Path $HooksDir)) {
        New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
    }

    # ===== PRE-COMMIT HOOK =====
    $PreCommitHook = ".git/hooks/pre-commit"
    $PreCommitProtection = @'

# QUADRATIC-DEVKIT-PROTECTION
# Block direct commits to main/master - installed by Quadratic DevKit
protected_branches=("main" "master")
current_branch=$(git branch --show-current)
for branch in "${protected_branches[@]}"; do
  if [ "$current_branch" = "$branch" ]; then
    echo ""
    echo "ERROR: Direct commit to '$branch' is blocked."
    echo "Create a feature branch instead: git checkout -b feature/your-feature-name"
    echo ""
    exit 1
  fi
done
# END-QUADRATIC-DEVKIT-PROTECTION
'@

    $PreCommitInstalled = $false
    if (-not (Test-Path $PreCommitHook)) {
        # No hook exists - create new one
        $NewHook = "#!/bin/bash`n$PreCommitProtection`n`nexit 0"
        Set-Content -Path $PreCommitHook -Value $NewHook -NoNewline
        # Make executable on Unix-like systems
        if ($IsLinux -or $IsMacOS) {
            chmod +x $PreCommitHook
        }
        $PreCommitInstalled = $true
    } else {
        # Hook exists - check if protection already added
        $ExistingContent = Get-Content $PreCommitHook -Raw
        if ($ExistingContent -notmatch "QUADRATIC-DEVKIT-PROTECTION") {
            # Append protection before the final 'exit 0' if it exists, otherwise at end
            if ($ExistingContent -match "exit 0\s*$") {
                $UpdatedContent = $ExistingContent -replace "exit 0\s*$", "$PreCommitProtection`n`nexit 0"
            } else {
                $UpdatedContent = $ExistingContent + "`n$PreCommitProtection"
            }
            Set-Content -Path $PreCommitHook -Value $UpdatedContent -NoNewline
            $PreCommitInstalled = $true
        }
    }

    # ===== PRE-PUSH HOOK =====
    $PrePushHook = ".git/hooks/pre-push"
    $PrePushProtection = @'

# QUADRATIC-DEVKIT-PROTECTION
# Block direct pushes to main/master - installed by Quadratic DevKit
protected_branches=("main" "master")
current_branch=$(git branch --show-current)
for branch in "${protected_branches[@]}"; do
  if [ "$current_branch" = "$branch" ]; then
    echo ""
    echo "ERROR: Direct push to '$branch' is blocked."
    echo "Create a feature branch and open a PR instead."
    echo ""
    exit 1
  fi
done
# END-QUADRATIC-DEVKIT-PROTECTION
'@

    $PrePushInstalled = $false
    if (-not (Test-Path $PrePushHook)) {
        # No hook exists - create new one
        $NewHook = "#!/bin/bash`n$PrePushProtection`n`nexit 0"
        Set-Content -Path $PrePushHook -Value $NewHook -NoNewline
        # Make executable on Unix-like systems
        if ($IsLinux -or $IsMacOS) {
            chmod +x $PrePushHook
        }
        $PrePushInstalled = $true
    } else {
        # Hook exists - check if protection already added
        $ExistingContent = Get-Content $PrePushHook -Raw
        if ($ExistingContent -notmatch "QUADRATIC-DEVKIT-PROTECTION") {
            # Append protection before the final 'exit 0' if it exists, otherwise at end
            if ($ExistingContent -match "exit 0\s*$") {
                $UpdatedContent = $ExistingContent -replace "exit 0\s*$", "$PrePushProtection`n`nexit 0"
            } else {
                $UpdatedContent = $ExistingContent + "`n$PrePushProtection"
            }
            Set-Content -Path $PrePushHook -Value $UpdatedContent -NoNewline
            $PrePushInstalled = $true
        }
    }

    # Build status message
    if ($PreCommitInstalled -and $PrePushInstalled) {
        $HooksInstalled = "🛡️ Branch protection installed (blocks commits & pushes to main/master)"
    } elseif ($PreCommitInstalled) {
        $HooksInstalled = "🛡️ Commit protection added (blocks commits to main/master)"
    } elseif ($PrePushInstalled) {
        $HooksInstalled = "🛡️ Push protection added (blocks pushes to main/master)"
    }
}

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
$LocalBranchesRaw = git for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)|%(committerdate:relative)|%(authorname)' --count=3
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
  

   🟩🟩🟩🟩🟩🟩
  🟩           🟩    👋 Hi $UserName! 
  🟩           🟩       Welcome to the QUADRATIC DevKit 
  🟩           🟩       
  🟩           🟩    📌 For a quick tuto, type : /devkit:intro
  🟩           🟩    💡 For help, type : /devkit:help 
   🟩🟩🟩🟩              
           🟩         📡 Let me catch you up on what's been happening...
            🟩       
            
$HooksInstalled
📍 Current branch: $CurrentBranch
🌿 Recent branches you've worked on:
$LocalBranchesStr
🎫 Recent GitHub issues:
$GithubIssues

✨ You're all set! What would you like to work on today?
"@

# Escape the message for JSON using PowerShell's ConvertTo-Json
$EscapedMessage = $DisplayMessage | ConvertTo-Json

# Wait 2 seconds before displaying the message
Start-Sleep -Seconds 2

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
