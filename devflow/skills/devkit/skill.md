# DevKit Skill

**Command:** `/devkit` | **Aliases:** `/setup`, `/init`

## Workflow

### 1. Check User Status
Run `scripts/check-user.sh` → parse sections:
- `---STATUS---`: first_run true/false, config_path
- `---GIT_USER---`: name, email, commit_estimate
- `---CONFIG---`: existing preferences if any

### 2. Route by Status

| Status | Action |
|--------|--------|
| `first_run: true` | → First-Time Setup |
| `first_run: false` | → Returning User Menu |

---

## First-Time Setup

### Welcome
Greet user by git name if available:
"Welcome to DevFlow, [name]!"

### Ask Experience Level
Use AskUserQuestion with options:

**Question:** "What's your development experience level?"

| Option | Description |
|--------|-------------|
| Beginner | New to development, prefer detailed explanations |
| Intermediate | Comfortable with basics, balanced guidance |
| Advanced | Experienced, prefer minimal output |

**Smart suggestion**: Use `commit_estimate` from script:
- `low` → suggest Beginner
- `medium` → suggest Intermediate
- `high` → suggest Advanced

### Save Preferences
Run: `scripts/save-user.sh <level> "<name>"`

### Confirmation
Show saved preferences and explain what changes:

**Beginner:**
- Detailed step-by-step explanations
- Confirm before destructive actions
- Show helpful hints

**Intermediate:**
- Balanced explanations
- Hints shown, less confirmation

**Advanced:**
- Concise output
- Minimal confirmation
- Just get it done

### Show Available Skills
```
Available DevFlow skills:
  /commit  - Smart commits with safety checks
  /pr      - Pull request creation and updates
  /release - Version releases with changelog
  /devkit  - This setup (run again to change settings)
```

---

## Returning User Menu

### Show Current Settings
Display from config:
- Level: [level]
- Preferences: verbose, hints, confirm

### Offer Options
Use AskUserQuestion:

| Option | Action |
|--------|--------|
| View my settings | Show full config |
| Change experience level | Re-run level selection, save |
| Reset all preferences | Delete config, re-run setup |
| Show available skills | List skills with descriptions |
| Exit | Done |

### Change Level Flow
If user selects "Change experience level":
1. Ask new level (same as first-time)
2. Run `scripts/save-user.sh <new-level> "<name>"`
3. Confirm change

### Reset Flow
If user selects "Reset all preferences":
1. Confirm: "This will delete your DevFlow preferences. Continue?"
2. Run: `rm ~/.devflow/config.yaml`
3. Re-run first-time setup

---

## How Other Skills Use This

Other skills can check `~/.devflow/config.yaml` and adapt:

```yaml
# Read user level
user:
  level: intermediate

# Adapt behavior
preferences:
  verbose_explanations: false
  show_hints: true
  confirm_before_actions: false
```

| Level | Behavior |
|-------|----------|
| beginner | Explain each step, confirm actions, show all hints |
| intermediate | Brief explanations, show hints, less confirmation |
| advanced | Minimal output, no hints, just execute |

---

## Error Handling
- Config dir not writable → warn, continue without saving
- Script fails → fallback to asking directly, save manually
