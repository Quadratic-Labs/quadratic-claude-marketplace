#!/bin/bash
# Save DevFlow user preferences
# Usage: save-user.sh <level> [name]

LEVEL="$1"
NAME="$2"

CONFIG_DIR="$HOME/.devflow"
CONFIG_PATH="$CONFIG_DIR/config.yaml"

# Validate level
if [ -z "$LEVEL" ]; then
  echo "Usage: $0 <level> [name]"
  echo "Levels: beginner, intermediate, advanced"
  exit 1
fi

case "$LEVEL" in
  beginner|intermediate|advanced)
    ;;
  *)
    echo "Invalid level: $LEVEL"
    echo "Valid levels: beginner, intermediate, advanced"
    exit 1
    ;;
esac

# Create directory
mkdir -p "$CONFIG_DIR"

# Get current date
DATE=$(date +%Y-%m-%d 2>/dev/null || date -I 2>/dev/null || echo "unknown")

# Determine preferences based on level
case "$LEVEL" in
  beginner)
    VERBOSE="true"
    HINTS="true"
    CONFIRM="true"
    ;;
  intermediate)
    VERBOSE="false"
    HINTS="true"
    CONFIRM="false"
    ;;
  advanced)
    VERBOSE="false"
    HINTS="false"
    CONFIRM="false"
    ;;
esac

# Write config
cat > "$CONFIG_PATH" << EOF
# DevFlow User Configuration
# Created: $DATE

user:
  name: "${NAME:-}"
  level: $LEVEL
  initialized_at: "$DATE"

preferences:
  verbose_explanations: $VERBOSE
  show_hints: $HINTS
  confirm_before_actions: $CONFIRM

# Customize behavior per skill
skills:
  commit:
    auto_stage: false
  pr:
    auto_push: false
  release:
    require_confirmation: true
EOF

echo "---SAVED---"
echo "path: $CONFIG_PATH"
echo "level: $LEVEL"
cat "$CONFIG_PATH"
