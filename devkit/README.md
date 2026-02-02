# Devkit - Development Workflow Plugin

Comprehensive development workflow automation for software releases, testing, and quality checks.

**Location:** `devkit/`

## Skills

### Commit Workflow (`/commit`)

Smart commit workflow with safety checks, branch protection, and intelligent commit message generation.

**Features:**
- Protected branch detection (prompt to create branch, warn, or block)
- Sensitive file detection (`.env`, credentials, keys)
- Large file warnings
- Conventional or gitmoji commit message generation
- Post-commit push/PR suggestions

**Usage:**
```
/commit           # Interactive - analyzes changes, suggests message
/commit fix bug   # With message hint
/ci               # Alias
```

**Configuration:**

Edit `devkit/skills/commit/commit.yaml`:
```yaml
branches:
  protected: [main, master]
  on_protected_branch: prompt  # prompt | warn | block

conventions:
  style: conventional  # conventional | gitmoji | custom

checks:
  block_sensitive_files: true
  sensitive_patterns: [".env", "*.pem", "*secret*"]
  warn_large_files_kb: 500
```

---

### Pull Request Workflow (`/pr`)

Smart PR creation and updates with auto-generated descriptions and pre-flight checks.

**Features:**
- Create or update existing PRs
- Pre-flight checks (branch pushed, up-to-date, no WIP commits)
- Auto-detect base branch (main/master)
- Auto-link issues from branch name or commits
- Smart PR title generation from branch name
- Auto-generated summary from commits/diff
- Conditional prompts (screenshots for UI changes, large PR warnings)

**Usage:**
```
/pr             # Create ready PR (or update if exists)
/pr --draft     # Create draft PR
/pr update      # Update existing PR title/body
/pull-request   # Alias
```

**Configuration:**

Edit `devkit/skills/pr/pr.yaml`:
```yaml
base_branch: auto  # auto | main | master | develop

checks:
  require_pushed: true
  require_up_to_date: true
  block_wip_commits: true
  max_diff_lines_warning: 500

conventions:
  title_from_branch: true
  auto_link_issues: true
  require_test_plan: true
```

---

### Release Workflow (`/release`)

Automated release management with intelligent checks and GitHub integration.

**Features:**
- Milestone verification with issue status checks
- Intelligent version bump verification across multiple file types
- Interactive pre-release checklist (linting, tests, docs)
- Automated CHANGELOG and release notes generation
- Release branch and tag creation with configurable patterns
- CI/CD pipeline monitoring links

**Usage:**
```
/release              # Interactive - prompts for version
/release 1.2.3        # Release specific version
/release v1.2.3       # Release with v prefix
```

**Configuration:**

Edit `devkit/skills/release/release.yaml` to customize for your project:
- Set default branch and versioning scheme
- Configure version file paths (package.json, pyproject.toml, etc.)
- Customize branch and tag naming patterns
- Enable/disable milestone and issue checking
- Configure required pre-release checks

**Example Configuration:**
```yaml
release:
  default_branch: main
  versioning: semver
  version_files:
    - package.json
    - pyproject.toml

git:
  release_branch_pattern: "release/{version}"
  tag_pattern: "v{version}"

github:
  use_milestones: true
  use_issues: true

checks:
  require_clean_worktree: true
  require_up_to_date_main: true
```

---

### DevKit Setup (`/devkit`)

First-time setup and personalization. Adapts all skills to your experience level.

**Features:**
- First-run detection and onboarding
- Experience level selection (beginner/intermediate/advanced)
- Persistent preferences in `~/.devkit/config.yaml`
- Smart level suggestion based on git history
- Adapts verbosity and hints across all skills

**Usage:**
```
/devkit       # Setup or view settings
/setup        # Alias
/init         # Alias
```

**Experience Levels:**

| Level | Behavior |
|-------|----------|
| Beginner | Detailed explanations, confirm actions, show hints |
| Intermediate | Balanced guidance, hints shown |
| Advanced | Minimal output, just execute |

**Stored in:** `~/.devkit/config.yaml` (persists across all projects)

## Installation

1. Clone this repository or copy the `devkit/` directory to your project
2. Configure Claude Code to use the plugin:
   ```bash
   # Add to your Claude Code configuration
   export CLAUDE_PLUGINS_PATH="/path/to/quadratic-claude-marketplace/devkit"
   ```
3. Customize skill configs for your project:
   - `devkit/skills/commit/commit.yaml` - branch protection, conventions
   - `devkit/skills/pr/pr.yaml` - PR checks, auto-linking, templates
   - `devkit/skills/release/release.yaml` - versioning, GitHub integration
4. Run `/devkit` to set up your experience level
5. Use `/commit` for commits, `/pr` for pull requests, `/release` for releases

