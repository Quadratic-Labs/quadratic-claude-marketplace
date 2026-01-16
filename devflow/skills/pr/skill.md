# PR Skill

**Command:** `/pr [--draft]` | `/pr update` | **Alias:** `/pull-request`

## Workflow

### 1. Gather Context
- Read `devflow/skills/pr/pr.yaml`
- Run `scripts/pre-checks.sh` → parse output sections

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
gh pr view JSON (if exists)
```

### 2. Check for Existing PR
If `---EXISTING_PR---` contains data:
- Show: "PR #X already exists: [title]"
- Ask: "Update this PR?" or "Create new PR?"
- If update → jump to step 6 (update flow)

### 3. Pre-flight Checks

| Check | Action |
|-------|--------|
| `remote_exists: false` | Offer to push: `git push -u origin <branch>` |
| `behind > 0` | Warn: "Branch is X commits behind base. Rebase?" |
| `ahead == 0` | Abort: "No commits to create PR from" |
| WIP commits (scan COMMITS for `WIP`, `fixup!`, `squash!`) | Warn or block per config |

### 4. Extract Context (Claude analyzes)
From script output, Claude determines:
- **Issue numbers**: Parse from branch name (`feature/123-...`) or commit subjects (`fixes #456`)
- **Change type**: Scan commit prefixes (`feat:`, `fix:`, `refactor:`)
- **UI changes**: Check FILES for `.tsx`, `.jsx`, `.vue`, `.css`, `.scss`, `.html`
- **Test changes**: Check FILES for `test.`, `spec.`

### 5. Generate PR Title
From branch name:
- `feature/add-user-login` → "Add user login"
- `fix/123-broken-auth` → "Fix broken auth"

Let user confirm or edit.

### 6. Generate PR Body
Use `templates/PR_TEMPLATE.md` structure:
- **Summary**: From commits, 2-3 bullets
- **Type**: From commit prefixes
- **Issues**: "Closes #X" if found
- **Test Plan**: Prompt if `require_test_plan: true`
- **Screenshots**: Prompt only if UI files changed

Present for approval.

### 7. Create or Update PR

**Create (new PR):**
```bash
gh pr create --base <base> --title "<title>" --body "<body>" [--draft]
```

**Update (existing PR):**
```bash
gh pr edit <number> --title "<title>" --body "<body>"
```

### 8. Post-PR
- Show PR URL
- Show CI link: `https://github.com/<owner>/<repo>/pull/<num>/checks`
- Suggest reviewers: `gh pr edit <num> --add-reviewer <user>`

## Update Flow (`/pr update`)

When user runs `/pr update` or PR exists:
1. Fetch current PR: `gh pr view --json number,title,body`
2. Show current title/body
3. Ask what to update: title, body, or both
4. Re-analyze commits/files for updated description
5. Run `gh pr edit <number> --title "..." --body "..."`

## Smart Prompts

| Condition | Prompt |
|-----------|--------|
| UI files in diff | "Add screenshots?" |
| >500 lines changed | "Large PR. Consider splitting?" |
| No issue linked | "Link an issue?" |
| PR exists | "Update existing PR #X?" |

## Error Handling
- `gh` not installed → "Install: https://cli.github.com"
- Not authenticated → `gh auth login`
- Push fails → show error, retry option
