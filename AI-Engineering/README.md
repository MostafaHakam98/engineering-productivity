# AI Engineering

Reusable AI tooling, Claude Code configuration, and AI-assisted engineering workflows.

## Structure

```
AI-Engineering/
└── ClaudeCode/
    ├── global/             # Personal config — installs to ~/.claude/
    │   ├── CLAUDE.md       # Global Claude behavior and memory rules
    │   ├── commands/       # Slash commands (/review, /debug, /plan, etc.)
    │   ├── skills/         # Reusable skill implementations
    │   ├── agents/         # Specialized sub-agents
    │   ├── hooks/          # Event hooks (pre/post tool, session events)
    │   └── settings.json   # Global Claude Code settings
    ├── project-template/   # Starter template — installs into a project's .claude/
    │   ├── CLAUDE.md       # Project-level Claude behavior
    │   ├── rules/          # Engineering rules (shared, repo, build, testing, style)
    │   ├── maps/           # Codebase maps (repo, dependencies, entrypoints, ownership)
    │   ├── workflows/      # Repeatable checklists (debugging, MR, refactor)
    │   └── decisions/      # Architecture decision records
    └── scripts/            # Install and sync scripts
```

## Installation

### 1. Global Claude config (personal, machine-local)

Installs the `global/` directory into `~/.claude/`:

```bash
AI-Engineering/ClaudeCode/scripts/install-global-claude.sh
```

Or with the shell alias (after setting up `shell/aliases`):

```bash
claude-install-global
```

### 2. Project Claude template (per-repository)

Run from inside a project directory to create a `.claude/` config:

```bash
/path/to/engineering-productivity/AI-Engineering/ClaudeCode/scripts/install-project-claude.sh
```

Or with the shell alias:

```bash
claude-install-project
```

### 3. Sync template updates into an existing project

Non-destructively pulls in upstream template changes, skipping project-specific files:

```bash
claude-sync-project
```

## Shell Aliases

After running `shell/aliases/setup.sh`, the following are available:

| Command                  | Description                                            |
|--------------------------|--------------------------------------------------------|
| `claude-install-global`  | Install global Claude config to `~/.claude/`           |
| `claude-install-project` | Install project template into current dir's `.claude/` |
| `claude-sync-project`    | Sync template updates (non-destructive)                |
| `cdclaudeconfig`         | Navigate to `~/.claude/`                               |
| `claude-help`            | Print all commands and slash command reference          |

## Three-Layer Config Model

| Layer            | Location                                      | Purpose                                     |
|------------------|-----------------------------------------------|---------------------------------------------|
| Personal global  | `~/.claude/`                                  | Personal behavior, skills, commands, agents |
| Project template | `AI-Engineering/ClaudeCode/project-template/` | Starter structure — copy once per project   |
| Project-local    | `<project>/.claude/`                          | Project-specific rules, maps, and workflows |

Personal files under `~/.claude/` should not be committed to product repositories.
Project-local `.claude/` files should be committed to the project repository.

## Documentation

- [ClaudeCode/README.md](./ClaudeCode/README.md) — detailed guide for the ClaudeCode submodule
- [USAGE.md](./USAGE.md) — practical workflows and day-to-day usage
