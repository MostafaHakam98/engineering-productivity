# Git hooks

Small staged-content and Python syntax checks, installed per repository by
preference. These heuristics supplement your project's own checks.

## Behavior

- `pre-commit` blocks private-key headers and AWS access-key patterns in staged
  additions. It warns about TODO/FIXME markers; `ENGPROD_STRICT_HOOKS=1` makes
  those blocking. Ordinary Python `print()` calls are permitted. This is not a
  comprehensive secret scanner.
- `pre-push` parses tracked, present Python files with Python 3 without importing
  or executing them, writing bytecode, or running Django tests. Missing Python
  is reported as a skipped check.

## Installation

```bash
bash /path/to/engineering-productivity/git/hooks/setup.sh /path/to/repository
# Explicit opt-in for all repositories:
bash git/hooks/install-global.sh
```

The explicit repository takes precedence over the working directory. Git
worktrees are supported. Existing `core.hooksPath` policy is preserved; integrate
these scripts manually with existing hook managers. Conflicting hook files are
backed up before replacement. Replaced hooks are not automatically chained.
Global installation affects future commits and pushes in every repository that
uses the global path, so inspect existing checks before choosing it.

## Recovery

Backups are siblings named `<hook>.ep-backup-<random>`. Restore the exact backup
after inspecting it. For a new global hooksPath, a Git config backup is saved;
restore the previous setting to stop using the kit globally. See
[installation and recovery](../../docs/INSTALLATION.md).

For an exceptional bypass, Git supports `commit --no-verify` and `push --no-verify`.
Follow your project's policy when using them.
