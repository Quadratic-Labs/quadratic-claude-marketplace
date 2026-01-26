---
name: pr
description: Smart PR creation and updates with auto-generated descriptions and pre-flight checks
command: pr
aliases:
  - pull-request
version: 1.0.0
---

# PR Skill

You are executing the `/pr` command (alias: `/pull-request`). This skill helps create or update pull requests with smart PR descriptions and pre-flight checks.

**Usage:**
- `/pr` or `/pr --draft` - Create a new PR (optionally as draft)
- `/pr update` - Update an existing PR

## Your Task

Follow this workflow to create or update a pull request:

### 1. Gather Context
- Read the config file at `devkit/skills/pr/pr.yaml` to understand user preferences
- Run the pre-check script: `bash devkit/skills/pr/scripts/pre-checks.sh` and parse its output

**Script output format:**
```
{JSON header with branch info}
---COMMITS---
hash|subject (one per line)
---FILES---
changed files (one per line)
---STATS---
shortstat summary
---EXISTING_PR---
gh pr view JSON (if exists, empty otherwise)
```

### 2. Check for Existing PR
If the `---EXISTING_PR---` section contains data:
- Inform the user: "PR #X already exists: [title]"
- Ask: "Do you want to update this PR or create a new one?"
- If they choose update → skip to step 6 (update flow)

### 3. Pre-flight Checks
Based on the script output, perform these checks:

| Check | Action |
|-------|--------|
| `remote_exists: false` | Offer to push the branch: `git push -u origin <branch>` |
| `behind > 0` | Warn: "Your branch is X commits behind the base branch. Do you want to rebase?" |
| `ahead == 0` | Abort: "No commits to create a PR from" |
| WIP commits (scan commits for `WIP`, `fixup!`, `squash!`) | Warn or block based on config |

### 4. Analyze the Changes
From the script output, determine:
- **Issue numbers**: Parse from branch name (e.g., `feature/123-...`) or commit subjects (e.g., `fixes #456`)
- **Change type**: Scan commit message prefixes (`feat:`, `fix:`, `refactor:`, `docs:`, etc.)
- **UI changes**: Check if FILES contain `.tsx`, `.jsx`, `.vue`, `.css`, `.scss`, or `.html`
- **Test changes**: Check if FILES contain `test.`, `spec.`, or are in test directories

### 5. Generate PR Title
Generate a title from the branch name:
- `feature/add-user-login` → "Add user login"
- `fix/123-broken-auth` → "Fix broken auth"
- Capitalize appropriately and make it descriptive

Present the title to the user and let them confirm or edit it.

### 6. Generate PR Body
Use the template at `templates/PR_TEMPLATE.md` (if it exists) or follow this structure:

- **Summary**: Generate 2-3 bullet points from the commits
- **Type of Change**: Determine from commit prefixes (feature, bugfix, refactor, etc.)
- **Related Issues**: Add "Closes #X" if issue numbers were found
- **Test Plan**: Prompt the user for this if `require_test_plan: true` in config
- **Screenshots**: Prompt the user for screenshots ONLY if UI files were changed

Present the generated PR body to the user for approval or editing.

### 7. Create or Update the PR

**For creating a new PR:**
```bash
gh pr create --base <base-branch> --title "<title>" --body "<body>" [--draft]
```
Add `--draft` flag if user requested a draft PR.

**For updating an existing PR:**
```bash
gh pr edit <pr-number> --title "<title>" --body "<body>"
```

### 8. Post-PR Actions
After successfully creating/updating the PR:
- Display the PR URL
- Show the CI checks link: `https://github.com/<owner>/<repo>/pull/<number>/checks`
- If configured in `pr.yaml`, suggest adding reviewers: `gh pr edit <number> --add-reviewer <user>`

## Update Flow (`/pr update`)

When the user runs `/pr update` or when a PR already exists:
1. Fetch the current PR data: `gh pr view --json number,title,body`
2. Show the current title and body to the user
3. Ask what they want to update: title only, body only, or both
4. Re-analyze the commits and files for an updated description
5. Execute: `gh pr edit <number> --title "..." --body "..."`

## Smart Prompts

Based on the analysis, provide these contextual prompts:

| Condition | Prompt to User |
|-----------|----------------|
| UI files in the diff | "Would you like to add screenshots?" |
| More than 500 lines changed | "This is a large PR. Consider splitting it into smaller PRs?" |
| No issue linked | "Would you like to link this to an issue?" |
| PR already exists | "PR #X already exists. Update it?" |

## Error Handling

Handle these common errors gracefully:
- **`gh` not installed**: Guide user to install: https://cli.github.com
- **Not authenticated**: Run `gh auth login`
- **Push fails**: Show the error message and offer to retry
- **No commits**: Inform user there are no commits to create a PR from

## Important Rules
- Always respect the configuration settings in `pr.yaml`
- Use the GitHub CLI (`gh`) for all PR operations
- Present generated content for user approval before creating/updating PRs
- Provide helpful, actionable error messages
- Never create a PR without user confirmation of the title and body
