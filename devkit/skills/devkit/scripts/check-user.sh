#!/bin/bash
# Check DevKit user configuration
# Returns user status and preferences

CONFIG_DIR="$HOME/.devkit"
CONFIG_PATH="$CONFIG_DIR/config.yaml"

# Also check for git user info (for personalization)
GIT_USER=""
GIT_EMAIL=""
if command -v git &>/dev/null; then
  GIT_USER=$(git config --global user.name 2>/dev/null || echo "")
  GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")
fi

# Estimate experience from global git history (optional hint)
COMMIT_ESTIMATE="unknown"
if [ -d ".git" ]; then
  COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  if [ "$COMMIT_COUNT" -lt 50 ]; then
    COMMIT_ESTIMATE="low"
  elif [ "$COMMIT_COUNT" -lt 500 ]; then
    COMMIT_ESTIMATE="medium"
  else
    COMMIT_ESTIMATE="high"
  fi
fi

# Output
echo "---STATUS---"
if [ -f "$CONFIG_PATH" ]; then
  echo "first_run: false"
  echo "config_path: $CONFIG_PATH"
else
  echo "first_run: true"
  echo "config_path: $CONFIG_PATH"
fi

echo "---GIT_USER---"
echo "name: $GIT_USER"
echo "email: $GIT_EMAIL"
echo "commit_estimate: $COMMIT_ESTIMATE"

echo "---CONFIG---"
if [ -f "$CONFIG_PATH" ]; then
  cat "$CONFIG_PATH"
else
  echo "# No config found"
fi
