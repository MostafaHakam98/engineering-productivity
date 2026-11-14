# Engineering Productivity

A version-controlled toolkit for engineering workflow. Shell environment, Git hooks, browser automation, editor shortcuts, and AI tooling — each modular, documented, and independently installable.

## Quick Start

```bash
git clone https://github.com/MostafaHakam98/engineering-productivity
cd engineering-productivity
./forge version
bash shell/aliases/setup.sh copy  # start with one module
# Open a new Bash terminal; use ./forge install for the guided full installer.
# Browser scripts need their own .env setup; see docs/INSTALLATION.md.
```

## Release and supported systems

Current development version: **1.1.0** (unreleased). See [CHANGELOG.md](CHANGELOG.md)
for features, fixes, history, and upgrade changes. The supported executable
baseline is Linux with Bash 4+, Python 3.10+, and Git 2.31+; installer coverage
is Ubuntu 22.04/24.04 on x86-64. Other platforms and live integrations require
separate validation.

Read [installation and recovery](docs/INSTALLATION.md) before sharing or installing,
and [validation evidence and limits](docs/VALIDATION.md) for what was actually
tested. Existing configurations receive recovery backups. Claude permissions
require explicit opt-in, and ActiTIME grid writes require explicit configuration.

## Modules

| Module | What it does | CLI |
|---|---|---|
| **shell** | Modular bash aliases, starship prompt, shell manager | `./forge install shell` |
| **hooks** | Git pre-commit and pre-push quality checks | `./forge install hooks` |
| **browser** | TamperMonkey scripts for GitLab and ActiTIME | `./forge install browser` |
| **ai** | Agent config for Claude, Codex, Cursor & Metwally from one source | `./forge install ai` |
| **ext** | Editor extensions built from source, with their agent config | `./forge install ext` |

## Structure

```
engineering-productivity/
├── forge                          # Top-level CLI (install, status, doctor, help)
├── bench                       # Claude Code benchmark runner
│
├── shell/
│   ├── aliases/                # Modular bash aliases with numbered load order
│   │   └── al                  # Shell environment CLI (install, status, doctor)
│   ├── starship/               # Starship prompt configuration
│   └── terminal/               # tmux / screen reference
│
├── git/
│   └── hooks/                  # Pre-commit & pre-push hooks
│
├── browser/
│   ├── scripts/                # TamperMonkey userscripts (configured from .env)
│   └── shortcuts/              # Chrome keyboard shortcuts reference
│
├── editor/
│   └── vscode/                 # VSCode tips and shortcuts
│
├── os/
│   └── ubuntu/                 # Ubuntu / GNOME shortcuts
│
├── extensions/                 # Editor extensions, declared not vendored
│   ├── install.sh              # Clone, build, install .vsix + agent config
│   └── metwally/               # Metwally Coding Agent (pi front-end)
│
└── ai/
    ├── shared/                 # ONE source of truth, tool-neutral
    │   ├── instructions.md     #   global behavior & style rules
    │   ├── skills/             #   SKILL.md dirs (+ references/, scripts/)
    │   ├── commands/           #   slash commands / prompt templates
    │   ├── agents/             #   subagent definitions
    │   ├── permissions.json    #   tool allow/deny rules
    │   ├── external-skills.json#   third-party skills, pinned & fetched
    │   └── project-template/   #   per-repository rules, maps, workflows
    ├── targets/                # One .target file per agent — add one, get an agent
    ├── scripts/                # port.sh, install-global.sh, install-project.sh
    ├── claude/                 # Claude-specific: benchmarks + shims
    └── cursor/                 # Cursor-specific: shims
```

## The forge CLI

```
forge                   Interactive menu with live module status
forge install [module]  Install one module or all (prompts for options)
forge status            Show what's installed across all modules
forge doctor            Check all dependencies and diagnose issues
forge help              Full command and alias reference
```

Each module also has its own focused CLI once installed:

```
al                      Shell environment manager (aliases + starship)
al install              Install with your preferred method
al status               Show load order and installed files
al doctor               Diagnose shell environment issues
al starship install     Install starship prompt config

ai-install <target|all> Render the shared config into an agent and install it
ai-port <target>        Render only, to a temp dir, to inspect before installing
ai-install-project <t>  Bootstrap a project template in the current directory
ai-external-skills      Fetch the declared third-party skills
ai-targets              List available agent targets
ext-install [name]      Build & install editor extensions from source
ai-help                 Print all AI commands, skills and slash commands
```

## Configuration

The browser script generator reads `.env` at the repo root as data:

```bash
cp .env.example .env
# Edit .env — required fields:
#   GITLAB_URL           your GitLab instance (without https://)
#   COMPANY_NAME         used in script metadata
#   AUTHOR_NAME          used in @author fields
#   STORAGE_KEY_PREFIX   short prefix for localStorage keys (2-3 chars)
```

## Documentation

- [shell/aliases/README.md](shell/aliases/README.md) — alias categories, load order, install methods
- [git/hooks/README.md](git/hooks/README.md) — hook behavior and bypass instructions
- [browser/scripts/README.md](browser/scripts/README.md) — script setup and TamperMonkey install
- [ai/README.md](ai/README.md) — the AI kit: one source, many agents, and how to add one
- [ai/claude/README.md](ai/claude/README.md) — Claude Code target
- [ai/claude/USAGE.md](ai/claude/USAGE.md) — day-to-day Claude Code workflows
- [ai/cursor/README.md](ai/cursor/README.md) — Cursor target
- [extensions/README.md](extensions/README.md) — editor extensions
- [extensions/metwally/README.md](extensions/metwally/README.md) — Metwally Coding Agent

## Philosophy

- **Modular** — each component works independently, install only what you need
- **Version-controlled** — every change is reviewable and reversible
- **Single entry point** — `./forge` covers installation, status, and help for the whole repo
- **Keyboard-first** — minimal mouse, maximal shortcuts across every layer
- **Domain-organized** — grouped by function (`shell/`, `git/`, `browser/`, `ai/`), not by tool

---

> Productivity tools only work if they reduce friction. If something doesn't fit your workflow, customize it or remove it.
