# Repository Map

## Purpose

This file gives Claude a compact map of the repository so it does not need to scan the full tree.

## Top-Level Areas

Fill this table per project.

| Path | Purpose | Notes |
|---|---|---|
| `src/` | Main source code | Update this description |
| `tests/` | Tests | Update this description |
| `scripts/` | Developer/CI scripts | Prefer existing scripts over inventing commands |
| `.gitlab-ci.yml` | GitLab CI pipeline | Keep scripts valid YAML strings or arrays |

## Do Not Scan By Default

Avoid opening these unless explicitly needed:

- `build/`
- `.cache/`
- `.venv/`
- `third_party/`
- generated files
- large logs
- binary outputs

## Recommended Exploration

For code tasks:

1. Read relevant source file.
2. Read nearby tests.
3. Read config/schema only if needed.

For CI tasks:

1. Read failed job output.
2. Read CI config.
3. Read referenced scripts only.
