---
description: Configure MCP servers for your project based on detected needs
argument-hint: Optional specific MCP to configure
allowed-tools: ["Task"]
---

# MCP Setup

Launch the DevKit MCP Setup agent to configure Model Context Protocol servers for your project.

## Your Task

Use the Task tool to launch the devkit-mcp-setup agent:

```
Task tool:
  subagent_type: "devkit:devkit-mcp-setup"
  description: "MCP server configuration"
  prompt: "$ARGUMENTS"
```

**User input:** $ARGUMENTS

## When to Use

- Set up MCP servers for a new project
- Add database, filesystem, or API access to Claude
- Configure GitHub, Puppeteer, or other integrations
- Modify existing `.mcp.json` configuration
