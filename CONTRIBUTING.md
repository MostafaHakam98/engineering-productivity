# Module Convention

This document defines what every module in this repository must have, so new modules are consistent and discoverable.

---

## Module Types

### Installable module
Has a setup script and is registered in `forge`. Examples: `shell/aliases/`, `git/hooks/`, `browser/scripts/`, `ai/claude/`.

### Docs-only module
Contains reference documentation with no setup step. Examples: `shell/terminal/`, `browser/shortcuts/`, `editor/vscode/`, `os/ubuntu/`.

---

## Required Files

### Every module directory

| File | Required | Notes |
|---|---|---|
| `README.md` | Yes | See sections below |

### Installable modules (additionally)

| File | Required | Notes |
|---|---|---|
| `setup.sh` or `scripts/` | Yes | Entry point for `forge install` |

### Every top-level domain directory (`shell/`, `git/`, `browser/`, `editor/`, `os/`, `ai/`)

| File | Required | Notes |
|---|---|---|
| `README.md` | Yes | Lists sub-modules with one-line descriptions and install commands |

---

## README Structure

### Module README (installable)

```markdown
# <Module Name>

One-sentence description.

## What It Does

- Bullet list of capabilities

## Installation

```bash
<install command>
```

## Usage (if applicable)

CLI reference or usage examples.

## Files

| File | Purpose |
|---|---|
| `<filename>` | what it does |
```

### Module README (docs-only)

```markdown
# <Module Name>

One-sentence description.

## What's Included

Reference to content files with brief descriptions.

## Files

| File | Purpose |
|---|---|
| `<filename>` | what it does |
```

### Domain README (top-level)

```markdown
# <Domain> Tools

One-sentence description.

## What's Included

### [<module>/](./<module>/) - <Module Name>
One-line description.

**Installation:** `<command>` or "No installation needed — reference documentation"

**Documentation:** [<module>/README.md](./<module>/README.md)

## Structure

- `<module>/` - one-liner

## Philosophy

- Bullet list
```

---

## Registering an Installable Module in forge

When adding an installable module, update three places in `forge`:

**1. Status function** — add `_s_<name>()` following the pattern of existing checks:
```bash
_s_mymodule() {
  # return "ok", "warn", or "none"
  [[ -f "$HOME/some/indicator" ]] && echo ok || echo none
}
```

**2. Menu item** — add an entry to `_ITEMS` in `cmd_menu`:
```bash
"m:mymodule:Short description of the module:install_mymodule"
```

**3. Install function** — add `install_mymodule()` following the pattern of existing installers:
```bash
install_mymodule() {
  # print description, prompt for options, run setup, print "What's next"
}
```

---

## Checklist for a New Module

- [ ] Module directory created under the appropriate domain (`shell/`, `git/`, `browser/`, `editor/`, `os/`, `ai/`)
- [ ] `README.md` with the correct sections for the module type
- [ ] Domain `README.md` updated to list the new module
- [ ] Root `README.md` module table updated (if installable)
- [ ] If installable: `setup.sh` or `scripts/` present
- [ ] If installable: `forge` updated (`_s_*`, `_ITEMS`, `install_*`)
- [ ] `.gitignore` updated if the module produces generated files
