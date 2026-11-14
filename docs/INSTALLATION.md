# Installation and recovery

## Supported baseline

The executable kit targets **Bash 4+, Python 3.10+, and Git 2.31+ on Linux**.
Installer tests run on Ubuntu 22.04 and 24.04, x86-64. macOS, Windows/WSL,
other distributions, ARM, live AI sessions, and editor activation are not
certified by these tests. Reference cheat sheets are separate documentation.
Do not run the installers with `sudo`.

| Module | Additional requirements | Scope |
|---|---|---|
| Shell | Bash; optional Starship, fzf, Atuin, NVM | `~/.bashrc`, kit aliases in `~/.bashrc.d`, launchers in `~/.local/bin`, Starship config |
| Hooks | Git; Python 3 for syntax checks | Chosen repository hooks, or explicit global opt-in |
| Browser | Python 3; Tampermonkey in a supported browser | Generates local files; browser installation is manual |
| AI | Python 3; corresponding agent installed separately | Selected agent's user configuration, or chosen project |
| External skills | Git, Python 3, public HTTPS access | Cache, `~/.agents/skills`, links in selected targets |
| Metwally | Node.js 22+, npm, `pi`, editor CLI | Public-source cache, VSIX, optional pi configuration |
| Benchmarks | Authenticated Claude CLI, jq, bc | Model requests billed to your account; results in benchmark directory |

The kit does not install operating-system packages or AI runtimes. Optional
shell helpers still require their named tools; site-specific SSH host aliases,
VPN, IDE paths, and destructive Git/Docker shortcuts must be reviewed before
use. Merely sourcing aliases does not invoke those shortcuts.

## Start with one module

From a reviewed checkout:

```bash
./forge version
./forge help
bash shell/aliases/setup.sh copy
# Open a fresh Bash terminal, then:
forge status
```

Keep the checkout in place: launchers and AI helpers refer to it. `copy` mode
freezes alias files until the next installation; `symlink` and `direct` modes
follow checkout changes. All three set `ENGPROD_DIR` to the actual location.
The installed Starship configuration is optional and may need a compatible font.

Install hooks in a test repository first:

```bash
bash /path/to/engineering-productivity/git/hooks/setup.sh /path/to/repository
# Global scope is an explicit separate choice:
bash git/hooks/install-global.sh
```

An existing `core.hooksPath` is preserved: integrate this kit with that tool
manually. Hook files with conflicting names are backed up, not chained. A new
kit hook replaces the active hook, so review existing policy before installing.

Preview AI config before applying it:

```bash
bash ai/scripts/port.sh codex --out /tmp/my-codex-preview
bash ai/scripts/install-global.sh codex --dry-run
bash ai/scripts/install-global.sh codex
# Only after reviewing ai/shared/permissions.json:
bash ai/scripts/install-global.sh claude --permissions
```

`--out` must be new or empty. Installing globally replaces the selected agent's
kit paths, including global instructions, with recovery backups. Project
installation refuses existing configuration unless `--force` is explicit;
`--force` also backs up replacements. Target files and extension build steps
are trusted code: review changes before running them.

## Browser configuration

```bash
cp .env.example .env
# Edit the four required fields. Values may be unquoted or fully quoted.
bash browser/scripts/setup.sh
```

The parser accepts one `KEY=value` per line and full-line `#` comments. It does
not expand variables, execute commands, or accept shell programs. Generated
scripts and `.env` must not be included in the kit you distribute. Reinstall
updated scripts manually in Tampermonkey after regeneration.

ActiTIME is disabled for grid operations until you review your site's markup
and set these constants in your installed userscript:

```javascript
const TIMESHEET_INPUT_SELECTOR = 'input.your-verified-hours-class';
const FIRST_COLUMN_WEEKDAY = 1; // 0=Sunday, 1=Monday, ..., 6=Saturday
```

The selector must match only editable hour fields, with exactly seven visible
cells per row. Change the default Sun–Thu schedule to match your organization.
Export before writing; the site may save `input`/`change` events immediately.
Fill and clear operations ask for confirmation. There is no undo/redo guarantee.

## Recovery and upgrades

Before replacement, an existing file or final symlink is moved to a unique
sibling named `<filename>.ep-backup-<random>`. Existing restrictive file
permissions are preserved. Destination symlink **ancestors** are refused;
symlinked dotfile directories and `.bashrc` need manual integration.

For example, inspect the matching backup, then restore the selected file:

```bash
ls -l ~/.claude/CLAUDE.md.ep-backup-*
# Substitute the exact backup you inspected:
cp -- ~/.claude/CLAUDE.md.ep-backup-EXACT ~/.claude/CLAUDE.md
```

Backups are not automatically deleted. State files named
`.engineering-productivity*.state.json` track installed fingerprints; manifests
list owned paths. On upgrade, obsolete files are removed only when their
fingerprint still matches. User-edited files remain. Legacy manifests without
fingerprints are validated but never used to authorize deletion. Empty leftover
directories are harmless and are not recursively removed.

To remove shell integration, remove the marked block from `.bashrc`, restore
any replaced files from the backups, and remove only kit launchers/alias files
listed in its shell manifest. For AI configuration, restore backups or remove
only the selected manifest's entries after reviewing them. There is no automatic
uninstaller. Stop and inspect state if an installer is interrupted: backups
protect replaced content, but installation across many files is not a transaction.

For global hooks, inspect the saved Git config backup and restore the previous
`core.hooksPath` value; do not blindly remove another tool's policy.

## Validation

```bash
bash scripts/test-sandbox.sh 22.04
bash scripts/test-sandbox.sh 24.04
bash scripts/test-browser-sandbox.sh
```

Docker builds fetch public test dependencies. Test execution is unprivileged,
uses a read-only container filesystem plus disposable temporary storage, and
has no network or mounted host home. Optional upstream checks require a
separate container with public network access; see [validation](VALIDATION.md).
