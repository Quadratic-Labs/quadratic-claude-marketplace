# DevFlow - Development Workflow Plugin

Comprehensive development workflow automation for software releases, testing, and quality checks.

**Location:** `devflow/`

## Skills

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

Edit `devflow/skills/release/release.yaml` to customize for your project:
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

## Installation

1. Clone this repository or copy the `devflow/` directory to your project
2. Configure Claude Code to use the plugin:
   ```bash
   # Add to your Claude Code configuration
   export CLAUDE_PLUGINS_PATH="/path/to/quadratic-claude-marketplace/devflow"
   ```
3. Customize `devflow/skills/release/release.yaml` for your project
4. Use `/release` command to start your first release

