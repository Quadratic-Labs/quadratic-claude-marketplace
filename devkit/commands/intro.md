---
description: Get help with DevKit features or get a general presenetation of the devkit
argument-hint: Optional question
allowed-tools: ["Task"]
---

# DevKit Intro

Launch the DevKit Intro agent to explain features or present the devkit

## Your Task

Use the Task tool to launch the devkit-intro agent:

```
Task tool:
  subagent_type: "devkit:devkit-intro"
  description: "Help with DevKit features"
  prompt: "$ARGUMENTS"
```

**User question:** $ARGUMENTS

## When to Use

- You have questions about DevKit features
- You want a general presentation of the Devkit
