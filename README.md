# Engineering Productivity

A version-controlled toolkit for engineering workflow. Shell environment, Git hooks, browser automation, editor shortcuts, and AI tooling — each modular, documented, and independently installable.

## Quick Start

```bash
git clone <repo-url>
cd engineering-productivity
cp .env.example .env        # fill in your values
./forge install                # interactive installer
```

## Modules

| Module | What it does | CLI |
|---|---|---|
| **shell** | Modular bash aliases, starship prompt, shell manager | `./forge install shell` |
| **hooks** | Git pre-commit and pre-push quality checks | `./forge install hooks` |
| **browser** | TamperMonkey scripts for GitLab and ActiTIME | `./forge install browser` |
| **claude** | Global Claude Code config — skills, commands, agents | `./forge install claude` |

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
└── ai/
    └── claude/
        ├── global/             # Personal config — installs to ~/.claude/
        ├── project-template/   # Starter .claude/ for any project
        ├── benchmark/          # Claude Code skill benchmarks
        └── scripts/            # install-global.sh, install-project.sh, sync-project.sh
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

claude-install-global   Re-sync ~/.claude/ with latest global config
claude-install-project  Bootstrap .claude/ in a project directory
claude-sync-project     Pull template updates into an existing project
claude-help             Print all Claude commands and slash command reference
```

## Configuration

Browser scripts and some tools read from `.env` at the repo root:

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
- [ai/claude/README.md](ai/claude/README.md) — Claude Code kit structure
- [ai/claude/USAGE.md](ai/claude/USAGE.md) — day-to-day Claude Code workflows

## Philosophy

- **Modular** — each component works independently, install only what you need
- **Version-controlled** — every change is reviewable and reversible
- **Single entry point** — `./forge` covers installation, status, and help for the whole repo
- **Keyboard-first** — minimal mouse, maximal shortcuts across every layer
- **Domain-organized** — grouped by function (`shell/`, `git/`, `browser/`, `ai/`), not by tool

---

> Productivity tools only work if they reduce friction. If something doesn't fit your workflow, customize it or remove it.
