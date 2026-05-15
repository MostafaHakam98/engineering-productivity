# Shell Aliases

Modular bash aliases organized by category. Includes an interactive CLI (`al`) for install, status, and management.

## Quick Start

```bash
cd shell/aliases
./al
```

This opens the interactive menu. Pick **1 → Install environment** and choose a method.

## al — CLI reference

| Command                                 | Description                              |
|-----------------------------------------|------------------------------------------|
| `./al`                                  | Interactive menu (default)               |
| `./al install [copy\|symlink\|direct]`  | Install environment                      |
| `./al status`                           | Show install state and .bashrc health    |
| `./al doctor`                           | Diagnose missing tools and config issues |
| `./al list [category]`                  | Print all aliases for a category         |
| `./al reload`                           | Print the reload command for your method |
| `./al starship <install\|diff\|status>` | Manage starship config                   |

## Install methods

| Method    | How it works                       | When to use            |
|-----------|------------------------------------|------------------------|
| `copy`    | Copies files to `~/.bashrc.d/`     | Most users (default)   |
| `symlink` | Symlinks into `~/.bashrc.d/`       | Want automatic updates |
| `direct`  | Sources `loader.sh` from `.bashrc` | Active development     |

After any install: `source ~/.bashrc` or open a new terminal.

## Structure

```
shell/aliases/
├── load-order.conf       # Single source of truth for load order
├── loader.sh             # Direct-sourcing loader (reads load-order.conf)
├── setup.sh              # File installer (reads load-order.conf)
├── al                    # CLI — run this
├── core/
│   ├── core.sh           # History, shell options          (00)
│   ├── colors.sh         # Color aliases                   (20)
│   ├── ls.sh             # ls aliases                      (30)
│   └── path.sh           # PATH modifications              (99)
├── navigation/           # cd, .., ... shortcuts           (10)
├── tools/                # clear, bat, vpn, nalert         (40)
├── ai/                   # Claude Code helpers             (45)
├── git/                  # Git aliases and functions       (50)
├── docker/               # Docker and Compose aliases      (60)
├── prompt/               # Shell prompt config             (70)
└── optional/
    ├── fzf.sh            # Fuzzy finder integration        (80)
    ├── nvm.sh            # Node Version Manager            (90)
    └── atuin.sh          # Atuin shell history             (95)
```

Optional files guard against missing tools — safe to load even if not installed.

## Adding a new category

1. Create `<category>/<category>.sh`
2. Add a line to `load-order.conf`: `NN:category:category.sh`
3. Re-run `./al install` (copy/symlink) or `source loader.sh` (direct)

No other files need changing.

## Alias reference

### Navigation

| Alias  | Command       | Description |
|--------|---------------|-------------|
| `..`   | `cd ..`       | Up one      |
| `...`  | `cd ../..`    | Up two      |
| `....` | `cd ../../..` | Up three    |

### Tools

| Alias      | Description                                   |
|------------|-----------------------------------------------|
| `c`, `cls` | Clear screen                                  |
| `mkdirp`   | `mkdir -p`                                    |
| `rmf`      | `rm -rf`                                      |
| `bat`      | `batcat` alias (Debian/Ubuntu only — guarded) |
| `nalert`   | Desktop notification for last command         |

### AI (Claude Code)

| Function                 | Description                                  |
|--------------------------|----------------------------------------------|
| `claude-install-global`  | Install global Claude config to `~/.claude/` |
| `claude-install-project` | Install project template into `./.claude/`   |
| `claude-sync-project`    | Sync template updates (non-destructive)      |
| `cdclaudeconfig`         | `cd ~/.claude/`                              |
| `claude-help`            | Print Claude Code commands reference         |

Set `ENGPROD_DIR` in `~/.bashrc` if the repo is not at its default location.

### Git

| Alias                | Command                           |
|----------------------|-----------------------------------|
| `g`                  | `git`                             |
| `ga` / `gaa` / `gap` | add / add --all / add --patch     |
| `gc` / `gcm`         | commit / commit -m                |
| `gco` / `gcb`        | checkout / checkout -b            |
| `gp` / `gpl`         | push / pull                       |
| `gs` / `gss`         | status / status --short           |
| `gd` / `gds`         | diff / diff --staged              |
| `gl` / `gla`         | log / log --all --graph --oneline |
| `gst` / `gstp`       | stash / stash pop                 |
| `gpf`                | push --force-with-lease           |
| `gri`                | rebase -i                         |
| `guncommit`          | reset --soft HEAD~1               |

Functions: `gcbp <branch>`, `gcam <msg>`, `gcamp <msg>`, `gup`, `gwhat <file>`, `ghist <file>`

### Docker

| Alias                  | Command                    |
|------------------------|----------------------------|
| `d` / `dc`             | docker / docker compose    |
| `dps` / `dpsa`         | ps / ps -a                 |
| `di`                   | images                     |
| `dex`                  | exec -it                   |
| `dcu` / `dcud`         | compose up / up -d         |
| `dcd`                  | compose down               |
| `dclf`                 | compose logs -f            |
| `dcb` / `dcrb`         | compose build / up --build |
| `dsysdf` / `dsysprune` | system df / system prune   |

Functions: `dbash`, `dsh`, `dcex`, `dcrun`, `dclean`, `dip`, `drmf`

FZF variants (require fzf): `dlogsf`, `dexecf`, `dstopf`, `dstartf`, `dinspectf`, `dstatsf`, `drmif`, `dclogf`, `dcexf`

### FZF file browsing

Requires fzf. Uses bat for previews, jq for JSON when available.

| Function           | Description                           |
|--------------------|---------------------------------------|
| `fls` / `fcat`     | Browse and preview files              |
| `fvim` / `fbat`    | Browse and open/view files            |
| `ffgrep [pattern]` | Search file contents with preview     |
| `fjq`              | Browse and preview JSON files         |
| `frecent`          | Recently modified files (last 7 days) |
| `frm`              | Browse and delete with confirmation   |
| `fcd` / `cdf`      | Browse and cd into directory          |
| `fh`               | Browse command history                |
| `fkill`            | Browse and kill processes             |

## Troubleshooting

**Aliases not loading:**

```bash
grep "bashrc.d" ~/.bashrc          # check sourcing is configured
ls ~/.bashrc.d/                    # check files are installed
./al doctor                        # diagnose all issues at once
```

**Conflict with system alias (e.g. alert, fgrep):**  
System aliases are expanded before function definitions are parsed. Rename the function in the relevant `.sh` file to
avoid the collision.

**Reload after changes:**

```bash
source ~/.bashrc          # copy or symlink mode
source loader.sh          # direct mode
```
