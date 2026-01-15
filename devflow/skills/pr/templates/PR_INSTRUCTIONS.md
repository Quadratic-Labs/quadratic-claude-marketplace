# PR Body Generation Rules

Reference document for generating PR descriptions. Not loaded on every invocation.

## Section Rules

### Summary
- 2-3 bullet points max
- Focus on what changed and why
- Analyze commits and diff

### Type of Change
Detection from commit prefixes:
- `feat:` → Feature
- `fix:` → Bug fix
- `refactor:` → Refactor
- `docs:` → Documentation
- `test:` → Tests
- `ci:` → CI/Build
- API changes, removed exports → Breaking change

### Related Issues
- "Closes #X" for fully resolved issues
- "Related to #X" for partial
- Omit section if none found

### Test Plan
- Include if `require_test_plan: true`
- Suggest based on change type
- Omit if not required

### Screenshots
- Include ONLY if UI files changed (.tsx, .jsx, .vue, .css, .scss, .html)
- Prompt user to add, don't generate placeholders
- Omit entirely if no UI changes

## Example

Branch: `feature/123-add-user-settings`

```markdown
## Summary
- Add user settings page with profile editing
- Implement settings persistence to local storage

## Type of Change
- [x] Feature
- [ ] Bug fix
- [ ] Refactor
- [ ] Documentation
- [ ] Tests
- [ ] CI/Build
- [ ] Breaking change

## Related Issues
Closes #123

## Test Plan
- [ ] Settings persist after page refresh
- [ ] Validation errors display correctly
```
