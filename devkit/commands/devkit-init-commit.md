---
description: Trigger the smart commit workflow with safety checks
argument-hint: Optional commit message
allowed-tools: ["Skill"]
---

# DevKit Init Commit

Invoke the `/commit` skill to run the smart commit workflow.

## Your Task

Use the Skill tool to trigger the commit skill:

```
Skill tool:
  skill: "commit"
  args: "$ARGUMENTS"
```

**User arguments:** $ARGUMENTS
