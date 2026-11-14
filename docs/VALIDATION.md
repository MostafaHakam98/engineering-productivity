# Kit validation — 1.1.0 preparation

Audit date: 2026-11-14. Release status: **unreleased**. These results describe
specific tested scenarios, not a guarantee for every machine or integration.

## Repository and branch audit

- Remote: `github.com/MostafaHakam98/engineering-productivity`.
- Baseline: `main` / `origin/main` at `12fdc82`.
- `FT-knowledge-sharing-session-HA` at `e04c2bb` is already an ancestor of main;
  there is no outstanding feature content to merge from that branch.
- No local or remote `devel` existed when refs were fetched. Creating a new
  integration branch is a separate publication decision.
- Corrections are prepared on `FIX-kit-release-safety-HA`. No protected-branch
  push, remote merge, branch deletion, or release tag was performed during audit.

## Executed checks

| Check | Environment | Result |
|---|---|---|
| Installer integration suite | Ubuntu 22.04, Bash 5.1, Python 3.10, unprivileged container | 21 tests passed |
| Installer integration suite | Ubuntu 24.04, Bash 5.2, Python 3.12, unprivileged container | 21 tests passed |
| ShellCheck error-level analysis | Explicit Bash dialect, both Ubuntu images | Passed |
| Browser fixture interactions | Chromium in Playwright 1.62.1 container | 4 scenarios passed |
| External skills | Disposable Node 22 / Debian container, public network | All 14 declared skills installed at pinned refs; reinstall passed |
| Metwally source build | Same optional integration container | Lockfile install and TypeScript compilation passed |
| Metwally upstream suite | Source revision `fdc9f223a16a3793a0ea72f1e466b40cd0772725` | 122 tests passed |
| VSIX packaging | Pinned `@vscode/vsce@3.7.1` | `metwally.vsix` built, 22 files, about 85 KB |
| Patch whitespace | `safe-git diff --check` | Passed |

The offline containers had a read-only root filesystem, disposable executable
`/tmp`, no network, no host home or Docker socket mounts, dropped capabilities,
and no privilege escalation. Docker builds fetched public dependencies. The
separate optional container had network access for public clones/npm packages,
with the same disposable home and no host account credentials.

The sandbox writes occurred in container temporary homes. No kit installation
was applied to the maintainer's actual shell, Git hooks, browser, editor, or
agent configuration.

## Coverage

The installer suite exercises:

- Bash/Python syntax and JSON parsing of maintained source, version/help/status,
  useful diagnostic exit statuses, and noninteractive menu rejection.
- Global AI rendering/installation for Claude, Codex, Cursor, and Metwally;
  no home changes on dry run; idempotent reinstalls; Cursor resource pointers;
  TOML parsing where Python's TOML parser is available.
- Existing-user-file backups, unmanaged skills, permission opt-in, preservation
  of existing settings and restrictive modes, invalid settings refusal, path
  traversal refusal, and symlink ancestor refusal before writes.
- Changed-vs-unchanged stale file pruning, nonempty preview destination refusal,
  and project template overwrite guards/backup behavior for every target.
- Shell copy → symlink → direct → copy switching, arbitrary checkout paths
  containing spaces, apostrophes, and ampersands, discoverable CLIs, retained
  user startup content, existing alias collisions, and noninteractive refusal
  of destructive convenience helpers.
- Explicit repository hook targets, worktrees, preservation of existing
  hooksPath policy, hook backup behavior, legitimate Python prints, credential
  markers, syntax failures, and no application/database/bytecode side effects.
- Browser `.env` parsing without executing command substitutions, replacement
  metacharacters, invalid host refusal, and generated-script recovery backups.
- Invalid optional-installer arguments before side effects; checkpoint JSON and
  activity projection helpers; terminal menu action/refresh/quit with a real
  pseudoterminal; benchmark result parsing and failure propagation with a fake
  Claude CLI. No billable model requests were sent.

The four browser scenarios interact with actual Chromium pages and intercept
all network requests:

1. Repository filenames containing hostile HTML stay text in both the sidebar
   and quick search; special path characters stay encoded in navigation URLs.
2. MR descriptions do not duplicate the same issue header, cross-project
   templates are ignored, and helper controls do not submit the form.
3. Default ActiTIME configuration makes no grid changes.
4. Explicitly configured ActiTIME honors cancel/confirm, maps a Monday-first
   grid to the configured workdays, preserves unrelated fields, and does not
   submit a form.

Reference-only terminal/editor/Ubuntu/browser shortcut material was inspected
as documentation; it was not executed as a universal platform test. Markdown
links were checked locally (template `(url)` placeholders excluded). AI skill
content and extension manifests remain instructions/trusted code, not a
sandbox or a proof of correctness for downstream projects.

Codex standalone TOML agent fields were checked against the
[official custom-agent documentation](https://learn.chatgpt.com/docs/agent-configuration/subagents).
Authenticated agent sessions were not exercised.

## Material findings addressed

- [Blocker][Security] Unsafe legacy manifest pruning and external skill
  replacement could remove unrelated data. Replaced with validated per-file
  ownership, fingerprint checks, and recovery backups.
- [Blocker][Security] File-tree HTML interpolation accepted repository-controlled
  names. Names/attributes are escaped and path segments encoded.
- [Blocker][Correctness] ActiTIME guessed hour fields from all visible inputs.
  Grid operations now require an explicit selector/day origin and confirmation.
- [Important][Correctness] Hook setup could ignore the supplied repository;
  global pre-push could execute Django against configured databases. Explicit
  targets/worktrees and read-only Python parsing replace that behavior.
- [Important][Maintainability] Machine-specific paths, missing command launchers,
  policy tied to the author's account, and broken menu refresh impaired sharing.
  Defaults now use the actual checkout and recipient/project policy.
- [Important][Tests] No repeatable release safety checks existed. Added offline
  integration tests, browser fixtures, sandbox runners, and GitHub Actions.

## Remaining boundaries

- No claim of “perfect” or “cannot break a machine.” Installers change the
  explicitly selected configuration. Backups support recovery; multiple-file
  installations are not transactional and are not tested against concurrent
  modification, disk exhaustion, or every filesystem/permission policy.
- Destination symlink ancestors are deliberately refused. Existing dotfile
  managers and global hook policies may need manual integration.
- Live GitLab/ActiTIME page versions and Tampermonkey installation were not
  tested against real accounts; the browser tests use controlled fixtures.
- Editor installation/activation, a running pi backend, real AI model calls,
  optional shell tool integrations, SSH/VPN endpoints, macOS, Windows/WSL,
  ARM, and other distributions are outside the executed matrix.
- Upstream extension tests/package creation do not certify third-party code
  against all security risks. npm build steps and installed coding agents run
  with user permissions. External skill pinning does not certify skill content.
- The GitHub Actions workflow is prepared; hosted CI results are unavailable
  until publication. No release tag or public release has been created.

## Reproduce

```bash
bash scripts/test-sandbox.sh 22.04
bash scripts/test-sandbox.sh 24.04
bash scripts/test-browser-sandbox.sh

# Optional: public network; still no host home or editor mounted.
docker build -f tests/optional.Dockerfile -t engineering-productivity-test:optional .
docker run --rm --cap-drop ALL --security-opt no-new-privileges \
  --read-only --tmpfs /tmp:rw,exec,nosuid,nodev,size=2g \
  engineering-productivity-test:optional
```

Raw local logs from the audit are in `/tmp/engineering-productivity-audit/`;
these are temporary evidence, not files to distribute with the kit. Version
history and upgrade changes are in [CHANGELOG.md](../CHANGELOG.md). Installation
scope and recovery steps are in [INSTALLATION.md](INSTALLATION.md).
