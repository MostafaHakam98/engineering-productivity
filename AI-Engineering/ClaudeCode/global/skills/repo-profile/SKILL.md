---
name: repo-profile
description: Inspect the current repository and create or update project-specific Claude guidance under .claude/. By default, fills .claude files directly and only modifies .claude files.
---

# Repo Profile Skill

## Goal

Create accurate project-specific Claude guidance for the current repository.

This skill bootstraps or refreshes the repository's `.claude/` files so future Claude sessions can understand the
project with less repeated exploration.

## Default Behavior

When invoked as:

~~~text
/repo-profile
~~~

do the following by default:

1. Inspect the repository safely.
2. Update only files under `.claude/`.
3. Fill project-specific guidance files.
4. Remove generic TODO/template placeholders when enough evidence exists.
5. Add assumptions where evidence is incomplete.
6. Summarize changed files and remaining gaps.

Do not ask for confirmation unless a required action would modify files outside `.claude/`.

## Supported Modes

### Default Apply Mode

~~~text
/repo-profile
~~~

Inspect and update `.claude/` files directly.

### Inspect Mode

~~~text
/repo-profile inspect
~~~

Inspect the repository and propose updates without editing.

### Refresh Mode

~~~text
/repo-profile refresh
~~~

Update existing `.claude/` files based on current repository state.

### Check Mode

~~~text
/repo-profile check
~~~

Check whether `.claude/` files are complete and specific enough. Do not edit.

### Decisions Mode

~~~text
/repo-profile decisions
~~~

Suggest architecture decision records based only on strong evidence. Do not invent decisions.

## Files To Create Or Update

Target files:

- `.claude/rules/repo.md`
- `.claude/rules/build.md`
- `.claude/maps/repo-map.md`
- `.claude/maps/entrypoints.md`
- `.claude/maps/dependency-map.md`
- `.claude/maps/ownership-map.md`
- `.claude/decisions/*.md`
- `.claude/workflows/*.md` only if workflow files are missing and templates are useful

## Hard Safety Rules

- Only edit files under `.claude/`.
- Never edit source code.
- Never edit build files.
- Never edit CI files.
- Never edit README files.
- Never edit secrets, credentials, certificates, or environment files.
- Never run destructive commands.
- Never scan ignored/generated/vendor/build directories unless explicitly asked.

## Discovery Order

Use progressive discovery.

Start with:

1. `.claude/CLAUDE.md`
2. top-level tree only
3. `README.md`
4. top-level directory names
5. build/package/config files if present:
    - `pyproject.toml`
    - `package.json`
    - `CMakeLists.txt`
    - `Makefile`
    - `Dockerfile`
    - `docker-compose.yml`
    - `.gitlab-ci.yml`
    - `.github/workflows/*`
6. top-level `scripts/` directory if present

Prefer shallow commands:

~~~bash
pwd
git status --short
find . -maxdepth 2 -type d | sort
find . -maxdepth 2 -type f | sort
~~~

Avoid by default:

- `.git/`
- `build/`
- `dist/`
- `.cache/`
- `.venv/`
- `venv/`
- `node_modules/`
- `third_party/`
- generated files
- large logs
- binary outputs

## Inference Rules

- Infer only from evidence.
- Mark uncertain points as assumptions.
- Use top-level names and README content before reading implementation files.
- Do not invent architecture.
- Do not invent build commands.
- If no build system exists, say so in `.claude/rules/build.md`.
- If no executable entrypoints exist, say so in `.claude/maps/entrypoints.md`.

## Required Output After Apply

After editing, return:

~~~md
## Updated Files

- ...

## Facts Captured

- ...

## Assumptions

- ...

## Remaining Gaps

- ...

## Recommended Next Command

...
~~~

## Required Verification

After editing, run:

~~~bash
grep -RIn "TODO\\|Fill this\\|Update this" .claude || true
find .claude -maxdepth 3 -type f | sort
~~~

Then summarize remaining placeholders.
