---
description: DevKit setup and personalization - adapts to your experience level
argument-hint: Optional setup preference
allowed-tools: ["Task"]
---

# DevKit Setup

Launch the DevKit Setup agent to initialize and configure your DevKit preferences.

## Your Task

Use the Task tool to launch the devkit-setup agent:

```
Task tool:
  subagent_type: "devkit:devkit-setup"
  description: "DevKit setup and personalization"
  prompt: "$ARGUMENTS"
```

**User input:** $ARGUMENTS

## When to Use

- First-time DevKit setup
- Change your experience level preferences
- Update DevKit configuration
- Reset your preferences
