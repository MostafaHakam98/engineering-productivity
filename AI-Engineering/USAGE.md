# AI Engineering — Usage Guide

Practical workflows for setting up and using the AI Engineering module day-to-day.

## Prerequisites

1. [Claude Code CLI](https://claude.ai/code) installed (`claude` available in PATH)
2. Shell aliases installed: `cd shell/aliases && ./setup.sh`
3. `ENGPROD_DIR` optionally set in `~/.bashrc` (defaults to `~/Desktop/Personal/engineering-productivity`)

---

## Initial Setup

### Step 1 — Install global Claude config

Run once on a new machine to install your personal Claude Code config into `~/.claude/`:

```bash
claude-install-global
# or directly:
AI-Engineering/ClaudeCode/scripts/install-global-claude.sh
```

This copies `AI-Engineering/ClaudeCode/global/` into `~/.claude/`, giving you:

- Personal `CLAUDE.md` with behavior rules
- Slash commands: `/review`, `/debug`, `/plan`, `/caveman`, `/ci-fix`, `/cmake-fix`, `/repo-profile`
- Reusable skills: `code-review`, `debug`, `plan-change`, `ci-fix`, `cmake-fix`, `caveman`
- Specialized agents: `build-doctor`, `code-reviewer`, `test-planner`

### Step 2 — Bootstrap a new project

From the root of a project that doesn't have a `.claude/` directory:

```bash
cd /path/to/your-project
claude-install-project
```

This copies the project template into `.claude/`. Then:

1. Edit `.claude/rules/repo.md` — describe the project architecture
2. Edit `.claude/rules/build.md` — add build conventions
3. Fill in `.claude/maps/repo-map.md` — compact structure overview
4. Fill in `.claude/maps/entrypoints.md` — binaries, CLIs, services
5. Commit `.claude/` to the project repository

### Step 3 — Sync template updates into an existing project

When the upstream template is updated, pull in non-project-specific changes:

```bash
cd /path/to/your-project
claude-sync-project
```

Project-specific files (repo rules, maps) are excluded from the sync.

---

## Daily Workflows

### Using slash commands in Claude Code

```
/review       — Review current branch diff or MR
/debug        — Debug a failing command or test
/plan         — Plan a non-trivial change before editing
/caveman      — Strip a failing task down to minimal observable facts
/ci-fix       — Debug a CI/CD pipeline failure
/cmake-fix    — Debug a CMake/build failure
/repo-profile — Profile current repo and update .claude/ config
```

`/repo-profile` accepts optional mode arguments:

| Mode                       | Behavior                            |
|----------------------------|-------------------------------------|
| `/repo-profile`            | Update `.claude/` directly          |
| `/repo-profile inspect`    | Propose updates without editing     |
| `/repo-profile refresh`    | Update existing guidance            |
| `/repo-profile check`      | Check completeness without editing  |
| `/repo-profile decisions`  | Suggest architecture decisions only |

### Navigating your Claude config

```bash
cdclaudeconfig     # cd to ~/.claude/
ls ~/.claude/      # see installed config
claude-help        # print all available commands and slash commands
```

### Keeping global config up to date

After pulling updates to this repository:

```bash
claude-install-global    # re-syncs ~/.claude/ with latest global/
```

---

## File Reference

### Global config (`~/.claude/` after install)

| Path                     | Purpose                                          |
|--------------------------|--------------------------------------------------|
| `CLAUDE.md`              | Global behavior: working style, token discipline |
| `commands/<name>.md`     | Slash command implementations                    |
| `skills/<name>/SKILL.md` | Reusable skill logic loaded by commands          |
| `agents/<name>.md`       | Specialized sub-agent definitions                |
| `hooks/README.md`        | Hook event documentation                         |
| `settings.json`          | Claude Code global settings                      |

### Project template (`.claude/` after install-project)

| Path                              | Purpose                                          |
|-----------------------------------|--------------------------------------------------|
| `CLAUDE.md`                       | Project-level rules and exploration order        |
| `rules/shared.md`                 | Engineering behavior and change discipline       |
| `rules/repo.md`                   | Repository architecture and boundaries           |
| `rules/build.md`                  | Build system conventions                         |
| `rules/testing.md`                | Test and validation rules                        |
| `rules/style.md`                  | Code style and review conventions                |
| `maps/repo-map.md`                | Compact repository structure overview            |
| `maps/entrypoints.md`             | CLIs, binaries, services, app entrypoints        |
| `maps/dependency-map.md`          | Dependency direction and architecture boundaries |
| `maps/ownership-map.md`           | Component ownership by team/person               |
| `workflows/debugging-playbook.md` | Step-by-step debugging workflow                  |
| `workflows/mr-checklist.md`       | Merge request review checklist                   |
| `workflows/refactor-checklist.md` | Safe refactor checklist                          |
| `decisions/README.md`             | Architecture decision records index              |

---

## Customization

### Overriding the repo path

If this repository lives somewhere other than `~/Desktop/Personal/engineering-productivity`:

```bash
# Add to ~/.bashrc before sourcing aliases
export ENGPROD_DIR="$HOME/code/engineering-productivity"
```

### Adding a new global skill

1. Create `AI-Engineering/ClaudeCode/global/skills/<name>/SKILL.md`
2. Reference it from a command in `global/commands/`
3. Re-run `claude-install-global` to push to `~/.claude/`

### Adding a new slash command

1. Create `AI-Engineering/ClaudeCode/global/commands/<name>.md`
2. Re-run `claude-install-global`
3. Use as `/name` inside Claude Code

---

## Troubleshooting

**`claude-install-global` not found**

Shell aliases not loaded. Run:

```bash
cd shell/aliases && ./setup.sh
source ~/.bashrc
```

**Scripts fail with "no such file"**

Check that `ENGPROD_DIR` points to the correct location:

```bash
echo "${ENGPROD_DIR:-$HOME/Desktop/Personal/engineering-productivity}"
ls "$ENGPROD_DIR/AI-Engineering/ClaudeCode/scripts/"
```

**`claude-install-project` refuses to run**

A `.claude/` directory already exists. Use `claude-sync-project` to update instead, or remove `.claude/` manually if
starting fresh.

**Skills or commands not recognized in Claude Code**

Re-run `claude-install-global` to ensure `~/.claude/` is current, then restart Claude Code.
