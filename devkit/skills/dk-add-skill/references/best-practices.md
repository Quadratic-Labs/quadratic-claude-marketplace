# Progressive Disclosure

Read this when splitting a complex skill across multiple files.

**Three loading levels:**
1. Metadata (frontmatter) — always loaded (~100 tokens)
2. skill.md body — loaded when skill triggers
3. References/scripts — loaded on-demand

## Patterns

**Pattern 1: High-level guide → specific references**
- Main skill: overview + navigation to reference files
- References: domain-specific details
- Example: `references/forms.md`, `references/api.md` (Claude loads only what's needed)

**Pattern 2: Domain separation**
- Organize by topic so only relevant context loads
- Example: `references/finance.md`, `references/sales.md` (load 1, ignore others)

**Pattern 3: Conditional details**
- Main skill: common cases
- References: edge cases, advanced features
- Example: Main skill handles standard docs, `references/tracked-changes.md` for advanced

## Rules

- One level deep: `references/schema.md` not `references/db/schema.md`
- TOC for 100+ line files
- Descriptive names: `api-auth.md` not `doc2.md`
- Forward slashes in paths
