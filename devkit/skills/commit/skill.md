---
name: commit
description: Smart commit workflow with safety checks and conventional message generation
command: commit
aliases:
  - ci
version: 1.0.0
user_invocable: true
tags:
  - git
  - commit
---

# Commit Skill

You are executing the `/commit` command (alias: `/ci`). This skill helps create safe, well-formatted Git commits with conventional commit messages.

## Your Task

Follow this workflow to create a commit:

### 1. Gather Context
- Read the config file at `devkit/skills/commit/commit.yaml` to understand user preferences
- Run the pre-check script: `bash devkit/skills/commit/scripts/pre-checks.sh` and parse the JSON output

### 2. Branch Safety Check
Check if the user is on a protected branch (main/master). Based on the `on_protected_branch` config setting:

| Config | Behavior |
|--------|----------|
| `prompt` | Ask user to: Create new branch / Abort / Override (require branch name confirmation) |
| `warn` | Show warning but allow commit to continue |
| `block` | Hard stop - do not allow commit |

If user chooses "Create branch": suggest a name based on the changes (`fix/...`, `feature/...`, etc.), get confirmation, then run `git checkout -b <name>`.

### 3. Check for Staged Changes
If no changes are staged:
- Offer to show unstaged changes
- Offer to stage all changes (`git add -A`)
- Offer to stage specific files
- Or abort

### 4. Safety Checks
Based on config settings, check for:
- **Sensitive files** (`block_sensitive_files`): Check staged files against `sensitive_patterns`. If found, offer to unstage or abort.
- **Large files** (`warn_large_files_kb`): Warn about files exceeding the size threshold.
- **Untracked files** (`warn_untracked_files`): Mention them and ask if they should be staged.

### 5. Generate Commit Message
- Run `git diff --cached` to analyze the changes
- Generate a commit message based on `conventions.style`:
  - `conventional`: `type(scope): description` (types: feat, fix, docs, refactor, test, build, ci, chore, etc.)
  - `gitmoji`: `:emoji: description`
  - `custom`: Use the `custom_pattern` format

- Present the generated message to the user
- Allow them to: use as-is, edit it, or write their own
- Respect `max_subject_length` (default 72 chars)

### 6. Execute the Commit
Run:
```bash
git commit -m "<message>"
```

On success: Display the commit hash, files changed, insertions/deletions.
On failure: Explain what went wrong and offer to retry or abort.

### 7. Post-Commit Actions
Based on config:
- If `suggest_push` is true: Offer to push with `git push origin <branch>`
- If `suggest_pr` is true and not on default branch: Offer to create a PR

## Branch Naming Conventions
Use these prefixes when creating new branches:
- `fix/...` for bug fixes
- `feature/...` for new features
- `docs/...` for documentation
- `refactor/...` for refactoring

## Important Rules
- Never bypass pre-commit hooks
- Never force operations that could leave the repo in a bad state
- Always explain failures clearly
- Provide helpful remediation steps when errors occur
- Respect all configuration settings from `commit.yaml`
