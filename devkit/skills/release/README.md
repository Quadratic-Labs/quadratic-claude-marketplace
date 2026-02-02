# Release Workflow Skill

Comprehensive automated release management for software projects using Claude Code.

## Overview

The Release Workflow skill guides you through the entire release process with intelligent automation:

1. **Milestone Verification** - Checks GitHub milestones and alerts on open issues
2. **Version Bump Verification** - Intelligently detects version numbers in your configured files
3. **Pre-release Checklist** - Interactive checklist for linting, tests, and documentation
4. **Documentation Updates** - Generates CHANGELOG and release notes from git history
5. **Release Creation** - Creates release branches and tags with configurable patterns
6. **CI/CD Monitoring** - Provides links to track deployment progress

## Quick Start

### 1. Configure Your Project

Edit `release.yaml` to match your project structure:

```yaml
release:
  default_branch: main
  versioning: semver
  version_files:
    - package.json        # Add your version files here
    - pyproject.toml
    - Cargo.toml

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

### 2. Run Your First Release

In Claude Code, simply type:
```
/release 1.0.0
```

Or let the assistant prompt you:
```
/release
```

### 3. Follow the Guided Process

The assistant will:
- Check your milestone status
- Verify version bumps
- Ask about code quality checks
- Generate changelog and release notes
- Create release branch and tag
- Provide CI/CD monitoring links

## Configuration Details

### Version Files

List all files in your project that contain version information:

```yaml
version_files:
  - package.json              # Node.js
  - pyproject.toml            # Python
  - Cargo.toml                # Rust
  - version.txt               # Custom
  - src/version.py            # Custom
```

The LLM will intelligently extract version numbers from these files regardless of format.

### Branch and Tag Patterns

Customize how release branches and tags are named:

```yaml
git:
  release_branch_pattern: "release/{version}"   # → release/1.2.3
  tag_pattern: "v{version}"                      # → v1.2.3
```

Use `{version}` as a placeholder for the version number.

### GitHub Integration

Enable milestone and issue checking:

```yaml
github:
  use_milestones: true    # Check milestone completion
  use_issues: true        # List open issues in milestone
```

Requires GitHub CLI (`gh`) to be installed and authenticated.

### Required Checks

Configure safety checks before release:

```yaml
checks:
  require_clean_worktree: true      # No uncommitted changes
  require_up_to_date_main: true     # Synced with remote
```

## Troubleshooting

### GitHub CLI Not Found

Install GitHub CLI:
```bash
# macOS
brew install gh

# Linux
sudo apt install gh

# Authenticate
gh auth login
```

### Version Not Detected

Ensure version files are listed correctly in `release.yaml`:
```yaml
version_files:
  - path/to/version/file.json
```

### Script Permission Denied

Make scripts executable:
```bash
chmod +x scripts/*.sh
```

## Examples

### Basic Release

```
User: /release 1.2.3
Assistant: Starting release process for version 1.2.3...
  ✓ Configuration loaded
  ✓ Milestone v1.2.3 complete - all issues closed
  ✓ Version bumped in all files
  [Interactive checklist]
  ✓ CHANGELOG updated
  ✓ Release branch created: release/1.2.3
  ✓ Tag created: v1.2.3

  Next: Push to remote and monitor CI/CD
```

### Release with Open Issues

```
User: /release 2.0.0
Assistant: Checking milestone v2.0.0...
  ⚠️  WARNING: Milestone has 3 open issues

  Open issues:
  #42 [open] Update API documentation
  #43 [in_progress] Add integration tests
  #44 [open] Review security audit

  How would you like to proceed?
  - Close resolved issues
  - Move issues to next milestone
  - Continue anyway (not recommended)
```

### Version Not Bumped

```
User: /release 1.3.0
Assistant: Checking version files...
  ❌ package.json - NOT bumped (still at 1.2.0)
  ❌ pyproject.toml - NOT bumped (still at 1.2.0)

  Please bump the version to 1.3.0 in these files.
  Would you like me to help update them?
```

## Advanced Usage

### Custom Version Files

For non-standard version files, add them to config:

```yaml
version_files:
  - src/constants.ts              # TypeScript constant
  - config/version.properties     # Java properties
  - lib/myapp/version.rb          # Ruby constant
```

The LLM will intelligently find version patterns in any file format.

### Multiple Release Branches

Configure different patterns for different release types:

```yaml
git:
  release_branch_pattern: "release/{version}"  # Regular releases
  # For hotfixes, manually specify: hotfix/{version}
```

### Custom Changelog Sections

Edit `templates/CHANGELOG_ENTRY.md` to add custom sections:

```markdown
## [{version}] - {date}

### 🚀 Performance
{performance}

### 🔒 Security
{security}
```

The LLM will categorize commits into your custom sections.

## Integration with CI/CD

### GitHub Actions

The skill provides monitoring links to GitHub Actions:

```
https://github.com/{owner}/{repo}/actions
```

### Creating GitHub Release

After pushing tag, create release:

```bash
gh release create v1.2.3 \
  --title "Release 1.2.3" \
  --notes-file release-notes.md
```

### Automated Deployment

Trigger deployment by pushing the release tag:

```bash
git push origin v1.2.3
```

Your CI/CD pipeline should be configured to deploy on release tags.

## FAQ

**Q: Can I skip the milestone check?**
A: Set `github.use_milestones: false` in config.

**Q: How do I handle pre-releases (alpha, beta)?**
A: Use semantic versioning: `/release 2.0.0-beta.1`

**Q: Can I customize commit categorization?**
A: Yes! The LLM adapts to your commit style. You can also edit templates.

**Q: What if my version is in a non-standard format?**
A: The LLM can extract most version patterns. Add the file to `version_files` and let the LLM handle it.

**Q: Can I use this without GitHub?**
A: Partially. Disable milestone checking, but you'll need git for branch/tag creation.

## Support

For issues or questions:
- Open an issue in the repository
- Check existing issues for solutions
- Contribute improvements via pull request

## Roadmap

Future enhancements:
- GitLab support
- Bitbucket support
- Automated version bumping
- Release notes from issue templates
- Custom pre-release hooks
- Rollback functionality
- Multi-repository releases

## License

Copyright © Quadratic. All rights reserved.
