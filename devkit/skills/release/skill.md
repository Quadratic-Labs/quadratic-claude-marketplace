---
name: release
description: Interactive release workflow with automated checks and tasks
command: release
aliases:
  - rel
  - ship
version: 1.0.0
---

# Release Workflow Skill

**Command:** `/release [version]`

**Description:** Guide the user through the complete software release process with automated checks and tasks.

**Usage:**
- `/release` - Start interactive release process (prompts for version)
- `/release 1.2.3` - Start release process for specific version
- `/release v1.2.3` - Start release process for specific version (with v prefix)

## Configuration

The skill uses `release.yaml` for project-specific configuration:
- Default branch, versioning scheme (semver)
- Git branch and tag patterns
- GitHub integration settings
- Required checks before release

## Workflow Steps

When the user triggers a release (e.g., `/release` or "I want to create a release"), follow these steps:

### 1. Load Configuration and Context
Read the following files:
- `devkit/skills/release/release.yaml` - Project configuration
- `devkit/skills/release/checklist.md` - Release checklist
- Get current git branch, latest tags, and repository state

### 2. Verify Milestone and Issues (if enabled)
- Run `scripts/check-milestone.sh <milestone-title>` to check milestone status
- Check if there are open/in-progress issues in the target milestone
- If milestone has open issues, display them with links and ask user how to proceed
- Alert user if issues need requalification, reassignment, or closure
- Provide issue links for easy navigation

### 3. Verify Version Bumps
- Read `release.version_files` from `release.yaml` config
- Read each configured version file and intelligently extract the version number
- Get latest git tags using `git tag -l --sort=-v:refname | head -n 5`
- Compare the extracted versions against the latest git tags
- If version not bumped, propose to update version files

### 4. Pre-release Checklist
Use AskUserQuestion tool to ask about:
- Code quality checks (linting, formatting)
- Tests (unit, integration, property tests)
- Documentation updates
- Any project-specific checks from config

For each incomplete item, offer assistance:
- "Would you like me to run linting for you?"
- "Shall I run the test suite?"
- "Do you need help updating documentation?"

### 5. Update Release Documentation
- Get commits since last tag: `git log <last-tag>..HEAD --oneline`
- Analyze commit messages and intelligently categorize changes (features, fixes, breaking changes, etc.)
- Generate CHANGELOG.md entry using `templates/CHANGELOG_ENTRY.md` template
- Generate release notes using `templates/RELEASE_NOTES.md` template
- Update README.md if version references need updating
- Show changes to user for approval

### 6. Create Release Branch and Tag
- Ensure working tree is clean (git status)
- Ensure main/default branch is up to date
- Run `scripts/create-release.sh <version> devkit/skills/release/release.yaml`
  - This will create the branch and tag according to config patterns
- Push to remote: `git push -u origin <release-branch> && git push origin <tag>`

### 7. Monitor CI/CD
- Get repository info: `gh repo view --json url,nameWithOwner`
- Provide links to:
  - GitHub Actions: `https://github.com/{owner}/{repo}/actions`
  - Releases page: `https://github.com/{owner}/{repo}/releases`
  - Create release: `gh release create <tag> --notes-file <release-notes.md>`
- Show command to monitor deployment status

## Scripts

The skill uses minimal helper scripts in `scripts/` directory:
- `check-milestone.sh`: Verify GitHub milestone status (reduces token usage for API calls)
- `create-release.sh`: Create release branch and tag (reduces token usage for git operations)

Most intelligence tasks (version checking, changelog generation) are handled directly by the LLM for better accuracy and flexibility.

## Templates

Templates in `templates/` directory:
- `CHANGELOG_ENTRY.md`: Template for changelog entries
- `RELEASE_NOTES.md`: Template for release notes

## Token Optimization Tips

1. Use scripts for repetitive tasks (milestone checking, git operations)
2. Cache data - don't re-fetch milestone/issue data
3. Use templates for changelog/release notes generation
4. Batch git operations where possible
5. Only read version files once

## Error Handling

If any step fails:
1. Clearly explain what went wrong to the user
2. Provide specific remediation steps and guidance on how to fix it
3. Ask if user wants to retry or skip the step
4. Never proceed with release if critical checks fail

## User Experience Guidelines

- Be conversational but concise
- Use emoji sparingly for status indicators (✓, ⚠️, ❌)
- Provide clickable links for all GitHub resources
- Show progress through the workflow
- Celebrate successful release completion!

## Best Practices

- Always verify before making git operations
- Use `gh` CLI for GitHub API interactions when available
- Minimize token usage by using scripts for repetitive tasks
- Cache milestone/issue data to avoid repeated API calls
- Provide clickable links for all GitHub resources
