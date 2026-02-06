# Progressive Disclosure Patterns

Read this when the skill being created is complex and needs content split across multiple files.

Skills use three loading levels:
1. **Metadata** (name + description) — always in context (~100 tokens)
2. **skill.md body** — loaded when skill triggers
3. **Reference files + scripts** — loaded/executed on demand

## Pattern 1: High-level guide with references

```markdown
# PDF Processing

## Quick start
[Most common usage with concise code example]

## Advanced features
- **Form filling**: See [forms.md](references/forms.md)
- **API reference**: See [reference.md](references/reference.md)
- **Examples**: See [examples.md](references/examples.md)
```

Claude loads reference files only when the user's task requires them.

## Pattern 2: Domain-specific organization

Organize by domain so only relevant context is loaded:

```
bigquery-skill/
├── skill.md (overview and navigation)
└── references/
    ├── finance.md
    ├── sales.md
    └── product.md
```

When user asks about sales, Claude only reads sales.md. Others stay on disk, zero token cost.

## Pattern 3: Conditional details

```markdown
## Creating documents
Use docx-js for new documents. See [docx-js.md](references/docx-js.md).

## Editing documents
For simple edits, modify XML directly.
**For tracked changes**: See [redlining.md](references/redlining.md)
```

Claude reads the reference only when the user needs that specific feature.

## Key rules

- Keep references one level deep from skill.md (no `a.md -> b.md -> c.md` chains)
- For files over 100 lines, include a table of contents at top
- Name files descriptively: `form_validation_rules.md` not `doc2.md`
- Use forward slashes in all paths
