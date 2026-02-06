---
name: add-skill
description: Scaffold and create new Claude Code skills with correct structure and best practices. Use when the user wants to create a skill, add a skill, build a new skill, or needs help structuring a skill for their project.
---

# Add Skill

You are executing the `/add-skill` command. Create a new Claude Code skill.

## Workflow

### 1. Gather Requirements

Ask: "What should this skill do? Include a concrete example."

From the answer, extract:
- **Name**: lowercase-with-hyphens, max 64 chars (prefer gerunds: `processing-pdfs`, `managing-data`)
- **Description**: third-person, what+when, max 1024 chars. Include trigger terms. Example: "Extract text from PDFs and merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction."
- **Resources**: scripts, reference docs, templates, or just instructions?

### 2. Choose Format

Ask ONE question:
```
AskUserQuestion:
  question: "Where should this skill live?"
  options:
    - label: "Standalone skill"
      description: "Single SKILL.md file (or directory with resources) in this project"
    - label: "Add to plugin"
      description: "Add to an existing Claude Code plugin's skills directory"
```

### 3. Create Files

**Standalone** (single SKILL.md or directory):
```markdown
---
name: <skill-name>
description: <third-person what+when with trigger terms>
---

# <Skill Title>

[Instructions here - keep under 500 lines]
```

**Plugin** (.skill JSON + skill.md):
```json
// .skill
{
  "name": "<skill-name>",
  "description": "<same as skill.md>",
  "version": "1.0.0",
  "command": "<command>",
  "instructions": "skill.md"
}
```

```yaml
# skill.md frontmatter (only name + description)
---
name: <skill-name>
description: <same as .skill>
---
```

**Bundled resources** (if needed):
- `scripts/` — executable code
- `references/` — domain knowledge loaded on-demand
- `assets/` — templates, images used in output

### 4. Write and Confirm

1. Write the skill files
2. List what was created
3. Show how to invoke (for plugin: `/<command>`)
4. Done — do NOT iterate or improve unless user asks

## Rules

- **Name**: lowercase, hyphens, numbers only. No "anthropic" or "claude". Max 64 chars.
- **Description**: third-person ("Processes files..." not "I help..."). Include what, when, and trigger keywords. Max 1024 chars.
- **Frontmatter fields**: ONLY `name`, `description`, `compatibility`, `license`, `metadata` are supported. Do NOT add `command`, `version`, `aliases`, `tags` to YAML frontmatter.
- **Plugin skills**: `command`, `aliases`, `version` go in `.skill` JSON only
- **Keep instructions under 500 lines** — split to references/ if longer
- **Do NOT create** README.md, CHANGELOG.md, or docs the skill doesn't need
- **Stop after creation** — no iteration step, no improvements unless user requests
