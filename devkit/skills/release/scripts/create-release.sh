#!/bin/bash
# Create release branch and tag

set -e

VERSION="$1"
CONFIG_FILE="${2:-devkit/skills/release/release.yaml}"

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version> [config-file]"
  exit 1
fi

# Remove 'v' prefix if present for processing
VERSION_NUM="${VERSION#v}"

# Read config
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found: $CONFIG_FILE"
  exit 1
fi

# Extract patterns from config
if command -v yq &> /dev/null; then
  DEFAULT_BRANCH=$(yq eval '.release.default_branch' "$CONFIG_FILE")
  BRANCH_PATTERN=$(yq eval '.git.release_branch_pattern' "$CONFIG_FILE")
  TAG_PATTERN=$(yq eval '.git.tag_pattern' "$CONFIG_FILE")
  REQUIRE_CLEAN=$(yq eval '.checks.require_clean_worktree' "$CONFIG_FILE")
  REQUIRE_UPDATE=$(yq eval '.checks.require_up_to_date_main' "$CONFIG_FILE")
else
  # Fallback: grep extraction
  DEFAULT_BRANCH=$(grep "default_branch:" "$CONFIG_FILE" | sed 's/.*: *//')
  BRANCH_PATTERN=$(grep "release_branch_pattern:" "$CONFIG_FILE" | sed 's/.*: *//' | tr -d '"')
  TAG_PATTERN=$(grep "tag_pattern:" "$CONFIG_FILE" | sed 's/.*: *//' | tr -d '"')
  REQUIRE_CLEAN=$(grep "require_clean_worktree:" "$CONFIG_FILE" | sed 's/.*: *//')
  REQUIRE_UPDATE=$(grep "require_up_to_date_main:" "$CONFIG_FILE" | sed 's/.*: *//')
fi

# Default values
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
BRANCH_PATTERN="${BRANCH_PATTERN:-release/{version}}"
TAG_PATTERN="${TAG_PATTERN:-v{version}}"

# Replace {version} placeholder
RELEASE_BRANCH="${BRANCH_PATTERN//\{version\}/$VERSION_NUM}"
RELEASE_TAG="${TAG_PATTERN//\{version\}/$VERSION_NUM}"

echo "Creating release:"
echo "  Branch: $RELEASE_BRANCH"
echo "  Tag: $RELEASE_TAG"
echo ""

# Check if working tree is clean
if [ "$REQUIRE_CLEAN" = "true" ]; then
  if ! git diff-index --quiet HEAD --; then
    echo "Error: Working tree is not clean. Commit or stash changes first."
    git status --short
    exit 1
  fi
  echo "✓ Working tree is clean"
fi

# Check if on default branch and up to date
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$DEFAULT_BRANCH" ]; then
  echo "Warning: Not on $DEFAULT_BRANCH branch (currently on $CURRENT_BRANCH)"
  read -p "Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

if [ "$REQUIRE_UPDATE" = "true" ]; then
  echo "Fetching latest changes..."
  git fetch origin "$DEFAULT_BRANCH"

  LOCAL=$(git rev-parse @)
  REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "")

  if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
    echo "Error: $DEFAULT_BRANCH is not up to date with remote"
    exit 1
  fi
  echo "✓ Branch is up to date"
fi

# Create release branch
echo ""
echo "Creating release branch: $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH"

# Create tag
echo "Creating tag: $RELEASE_TAG"
git tag -a "$RELEASE_TAG" -m "Release $VERSION_NUM"

echo ""
echo "✓ Release branch and tag created successfully"
echo ""
echo "Next steps:"
echo "  1. Push branch: git push -u origin $RELEASE_BRANCH"
echo "  2. Push tag: git push origin $RELEASE_TAG"
echo "  3. Monitor CI/CD pipeline"
