# Commit Skill

**Command:** `/commit [message]` | **Alias:** `/ci`

## Workflow

### 1. Gather Context
- Read `devflow/skills/commit/commit.yaml`
- Run `scripts/pre-checks.sh` → parse JSON output

### 2. Branch Safety
If on protected branch, check `on_protected_branch` config:

| Config | Behavior |
|--------|----------|
| `prompt` | Ask: Create branch / Abort / Override (require branch name confirmation) |
| `warn` | Show warning, continue |
| `block` | Hard stop |

If user chooses "Create branch": suggest name based on changes (`fix/...`, `feature/...`), confirm, run `git checkout -b <name>`.

### 3. Staged Changes
If none: offer to show unstaged, stage all (`git add -A`), stage specific files, or abort.

### 4. Safety Checks
From config:
- **Sensitive files** (`block_sensitive_files`): match against `sensitive_patterns`, offer to unstage or abort
- **Large files** (`warn_large_files_kb`): warn with sizes
- **Untracked** (`warn_untracked_files`): mention, ask if should stage

### 5. Generate Commit Message
Run `git diff --cached` and analyze.

Based on `conventions.style`:
- `conventional`: `type(scope): description` (types: feat, fix, docs, refactor, etc.)
- `gitmoji`: `:emoji: description`

Present message, let user: use as-is, edit, or write own.

Respect `max_subject_length` (default 72).

### 6. Execute
```bash
git commit -m "<message>"
```
On success: show hash, files changed, insertions/deletions.
On failure: explain, offer retry/abort.

### 7. Post-Commit
Based on config:
- `suggest_push`: offer `git push origin <branch>`
- `suggest_pr`: offer PR creation (if not on default branch)

## Branch Name Conventions
- `fix/...` for bug fixes
- `feature/...` for new features
- `docs/...` for documentation
- `refactor/...` for refactoring

## Error Handling
- Explain what failed
- Offer remediation
- Never bypass pre-commit hooks
- Never leave repo in bad state
