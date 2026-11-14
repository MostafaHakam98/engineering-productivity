# Changelog

Versions use semantic versioning: MAJOR for incompatible interfaces, MINOR for
new functionality, PATCH for fixes. `VERSION` is the single source used by
`forge version`. Entries stay **Unreleased** until a tag is published; dates
record publication, not when development started.

## 1.1.0 — Unreleased

### Added

- Shared installer with recovery backups, per-file ownership fingerprints,
  symlink checks, and validation of paths before writes or pruning.
- Portable `forge`, `al`, and `bench` launchers and automatic `ENGPROD_DIR` setup.
- Offline installer integration tests, Chromium browser fixtures, disposable
  Ubuntu 22.04/24.04 sandbox runners, and GitHub Actions verification.
- Extension `--build-only` mode for compilation, tests, and VSIX packaging
  without changing an editor or agent configuration.
- Installation/recovery guide and validation report with explicit test limits.

### Fixed

- Destructive shell helpers require interactive confirmation, bulk branch cleanup
  only lists candidates, and fuzzy grep previews treat search patterns as data.
- Existing instructions, aliases, hooks, and generated scripts are backed up
  before replacement; edited obsolete kit files and unmanaged files survive.
- Legacy manifests cannot trigger recursive deletion; unsafe traversal paths
  and destination symlink ancestors are refused before installation.
- Hook setup honors an explicit repository path and supports Git worktrees.
- Shell startup no longer requires the author's environment module paths or
  personal checkout location; reinstalling/switching methods remains usable.
- Menu refresh uses the current AI and extension checks; installation failures
  propagate instead of being reported as successful completion.
- Browser `.env` parsing treats values as data; names containing `&` or `|`
  render correctly without shell execution or sed replacement expansion.
- GitLab file-tree names are HTML-escaped and file URLs encode path segments.
- Issue templates are restricted to their originating project and applying an
  existing issue header does not duplicate it.
- AI placeholders and Codex TOML strings preserve path metacharacters and
  literal backslashes. Nonempty render destinations are refused.
- Third-party skill installs use declared names, validate pins, preserve local
  collisions, and report upstream failures. Metwally's source and VSIX tooling
  are pinned; failed lockfile installs do not fall back to unpinned dependencies.

### Changed defaults / upgrade notes

- Claude permission merging requires explicit `--permissions`; review the
  allow/deny list first. Existing settings are preserved on normal installs.
- Shared AI instructions use the recipient's repository/account policy rather
  than the author's identity, assignee, or branch suffix.
- Git hooks are recommended per repository. Existing hooksPath policy is never
  silently redirected. Pre-push checks Python syntax without running application
  code, Django tests, writing bytecode, or touching databases.
- Pre-commit treats task markers as advisory (`ENGPROD_STRICT_HOOKS=1` makes them
  blocking). Legitimate Python `print()` calls are allowed. Credential checks
  are limited heuristics, not a general secret scanner.
- ActiTIME requires an explicit grid selector and first-weekday setting before
  grid operations. Writes require confirmation; synthetic Enter presses and
  positional previous-week clicks were removed. There is no undo/redo feature.
- Bash 4+, Python 3.10+, and Git 2.31+ are the supported baseline; see the
  installation guide for module-specific dependencies and platform coverage.

## 1.0.0 — Historical baseline

The CLI reported `1.0.0`; no release tag was present at audit time. This entry
summarizes the existing history through `12fdc82` (2026-09-10), rather than
claiming a previously published release.

- Modular Bash aliases, Starship configuration, shell management, Git hooks,
  browser userscripts, and editor/terminal/Ubuntu reference material.
- Interactive `forge` installer, module status, dependency diagnostics, and
  Claude benchmark runner.
- Shared AI skills, commands, agents, project templates, and adapters for
  Claude Code, Codex, Cursor, and Metwally/pi.
- Pinned external-skill declarations and a source-built editor-extension module.
