---
name: add-skill
description: Scaffold and create new Claude Code skills with correct structure and best practices. Use when the user wants to create a skill, add a skill, build a new skill, or needs help structuring a skill for their project.
---

# Add Skill

You are executing the `/add-skill` command. Guide the user through creating a new Claude Code skill.

## Your Task

### 1. Understand the Need

Ask the user ONE targeted question. Follow up only if the scope is unclear.

> "What should this skill do? Give me a concrete example of how you'd use it."

From their answer, determine:
- **Purpose**: what the skill automates or provides
- **Triggers**: what a user would say to invoke it
- **Resources needed**: scripts, templates, reference docs, or just instructions

### 2. Detect Context

Silently assess:
```
Glob: pattern="**/SKILL.md"             → existing standalone skills
Glob: pattern="**/.skill"               → existing plugin skills
Glob: pattern="**/plugin.json"          → is this a plugin project?
Glob: pattern="*.py"                    → Python project?
Glob: pattern="package.json"            → Node project?
```

This determines:
- **Standalone skill** (default): no plugin.json, or user just wants a project skill
- **Plugin skill** (variant): plugin.json exists and user wants to add to their plugin

### 3. Plan the Skill

Determine the skill identity:

- **Name**: lowercase, hyphens only, max 64 chars. Prefer gerund form (`processing-pdfs`, `managing-data`). Must not contain "anthropic" or "claude".
- **Description**: max 1024 chars. Rules:
  - Always third person: "Processes files..." not "I help you..." or "You can use this..."
  - Include WHAT it does AND WHEN to trigger it
  - Include specific trigger terms (Claude uses this to pick from 100+ skills)
  - **Good**: `Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.`
  - **Bad**: `Helps with documents`

Present the plan to the user before creating files.

### 4. Create the Skill

#### Standalone format (default)

A standalone skill is a single `SKILL.md` file with YAML frontmatter, optionally inside a directory with bundled resources.

**Simple skill** (instructions only):
```
SKILL.md
```

**Skill with resources**:
```
<skill-name>/
├── SKILL.md            # Frontmatter + instructions (required)
├── scripts/            # Executable code (optional)
├── references/         # Supporting docs loaded on-demand (optional)
└── assets/             # Files used in output — templates, images (optional)
```

Write the `SKILL.md`:

```markdown
---
name: <skill-name>
description: <third-person description of what AND when>
---

# <Skill Name>

[Instructions here]
```

**Supported frontmatter fields:**
- `name` (required): max 64 chars, lowercase/hyphens/numbers only, no XML tags
- `description` (required): max 1024 chars, no XML tags
- `compatibility` (optional): compatibility constraints
- `license` (optional): license information
- `metadata` (optional): additional metadata

Only these fields are supported. Do NOT add `command`, `version`, `aliases`, `tags`, or `user_invocable` to frontmatter — they will be ignored.

#### Plugin format (variant)

Use this only when the user is adding a skill to a Claude Code plugin (has `plugin.json` with a `"skills"` path).

A plugin skill uses two files instead of one:

```
<plugin-skills-dir>/<skill-name>/
├── .skill              # JSON manifest for discovery (required)
├── skill.md            # Instructions with YAML frontmatter (required)
├── scripts/            # Optional
├── references/         # Optional
└── *.yaml              # Optional configuration
```

**`.skill` manifest** (JSON):
```json
{
  "name": "<skill-name>",
  "description": "<third-person description>",
  "version": "1.0.0",
  "command": "<command>",
  "aliases": ["<optional>"],
  "instructions": "skill.md"
}
```
Optional field: `"config": "<file>.yaml"`.

**`skill.md`** uses the same frontmatter as standalone skills — only `name` and `description` are supported:

```yaml
---
name: <skill-name>
description: <same as .skill>
---
```

All additional fields (`command`, `aliases`, `version`) live exclusively in the `.skill` JSON manifest, not in frontmatter.

**Plugin-specific notes:**
- `command` in `.skill` JSON defines how users invoke the skill via `/<command>`.
- `name` and `description` should match between `.skill` and frontmatter.
- Skill directory must be inside the path referenced by `plugin.json`'s `"skills"` field.

### 5. Write the Instructions Body

Whether standalone or plugin, the markdown body follows the same principles.

**Keep under 500 lines.** If longer, split into reference files. See [references/best-practices.md](references/best-practices.md) for progressive disclosure patterns.

Do NOT create README.md, CHANGELOG.md, INSTALLATION_GUIDE.md, or other auxiliary docs. Only create files the skill actually needs.

### 6. Choose Bundled Resources (If Needed)

Decide what to bundle based on the skill's needs:

- **scripts/**: Code that would be rewritten each time, or needs deterministic reliability. Scripts can be executed without loading into context (token-efficient). Example: a PDF rotation task → `scripts/rotate_pdf.py`
- **references/**: Domain knowledge Claude needs to look up while working. Loaded on-demand. Example: database schemas → `references/schema.md`
- **assets/**: Files used in output, not loaded into context. Example: project templates → `assets/boilerplate/`

If the skill is instructions-only, skip this step.

### 7. Validate

Before finishing, verify:

**All skills:**
- [ ] Name: lowercase, hyphens/numbers only, max 64 chars, no reserved words
- [ ] Description: third person, specific, under 1024 chars, includes what AND when
- [ ] Instructions body under 500 lines
- [ ] Forward slashes in all file paths
- [ ] No deeply nested references (one level from SKILL.md / skill.md)
- [ ] Consistent terminology throughout
- [ ] Scripts tested if included

**Plugin skills only:**
- [ ] `.skill` JSON is valid and parseable
- [ ] `name` and `description` match between `.skill` JSON and `skill.md` frontmatter
- [ ] `command` defined in `.skill` JSON
- [ ] Skill directory is inside the plugin's `"skills"` path

### 8. Confirm to User

Show what was created and how to use it:
> "Your skill is ready! Here's what was created: [list files]"

For plugin skills, also show: "Invoke it with `/<command>`."

### 9. Iterate (After Real Usage)

Skills improve through use. After the skill is used on real tasks:
1. Observe where Claude struggles or misses context
2. Update SKILL.md or bundled resources based on observed behavior, not assumptions
3. If Claude repeatedly reads the same reference file, consider moving that content into SKILL.md

## Important Rules

- Present the plan before creating files — get user confirmation
- Default to standalone format unless plugin structure is detected
- Only add knowledge Claude doesn't already have — it doesn't need to be told what PDFs are or how to write markdown
