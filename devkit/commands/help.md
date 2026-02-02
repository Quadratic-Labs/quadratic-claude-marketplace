---
description: Get help with DevKit features, troubleshoot issues, and recover from mistakes
argument-hint: Optional question or error description
allowed-tools: ["Task"]
---

# DevKit Help

Launch the DevKit Help agent to diagnose issues, explain features, and help with troubleshooting.

## Your Task

Use the Task tool to launch the devkit-help agent:

```
Task tool:
  subagent_type: "devkit:devkit-help"
  description: "Help with DevKit features and troubleshooting"
  prompt: "$ARGUMENTS"
```

**User question:** $ARGUMENTS

## When to Use

- You have questions about DevKit features
- Something didn't work as expected
- You made a mistake and need help recovering
- You want to understand how a DevKit skill works
