---
name: repo-profile
description: Inspect the current repository and create or update project-specific agent guidance under {{CONFIG_DIR}}/. By default, fills {{CONFIG_DIR}} files directly and only modifies {{CONFIG_DIR}} files.
---

# Repo Profile Skill

## Goal

Create accurate project-specific agent guidance for the current repository.

This skill bootstraps or refreshes the repository's `{{CONFIG_DIR}}/` files so future agent sessions can understand the
project with less repeated exploration.

## Default Behavior

When invoked as:

```text
/repo-profile
```

**Apply immediately. Do not propose. Do not ask for confirmation. Do not show a plan and wait.**

Execute in one pass:

1. Inspect the repository silently (no intermediate output).
2. Write or update files under `{{CONFIG_DIR}}/` with project-specific content.
3. Remove all generic TODO/template placeholders where evidence exists.
4. Add one or more concrete decisions if the evidence clearly supports them.
5. After all edits are complete, output the required summary.

The only time to pause is if an action would touch files outside `{{CONFIG_DIR}}/`.

## Supported Modes

### Default Apply Mode

```text
/repo-profile
```

Inspect and update `{{CONFIG_DIR}}/` files directly.

### Inspect Mode

```text
/repo-profile inspect
```

Inspect the repository and propose updates without editing.

### Refresh Mode

```text
/repo-profile refresh
```

Update existing `{{CONFIG_DIR}}/` files based on current repository state.

### Check Mode

```text
/repo-profile check
```

Check whether `{{CONFIG_DIR}}/` files are complete and specific enough. Do not edit.

### Decisions Mode

```text
/repo-profile decisions
```

Suggest architecture decision records based only on strong evidence. Do not invent decisions.

## Files To Create Or Update

Target files:

- `{{CONFIG_DIR}}/rules/repo.md`
- `{{CONFIG_DIR}}/rules/build.md`
- `{{CONFIG_DIR}}/maps/repo-map.md`
- `{{CONFIG_DIR}}/maps/entrypoints.md`
- `{{CONFIG_DIR}}/maps/dependency-map.md`
- `{{CONFIG_DIR}}/maps/ownership-map.md`
- `{{CONFIG_DIR}}/decisions/*.md`
- `{{CONFIG_DIR}}/workflows/*.md` only if workflow files are missing and templates are useful

## Hard Safety Rules

- Only edit files under `{{CONFIG_DIR}}/`.
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

1. `{{CONFIG_DIR}}/{{ENTRYPOINT}}`
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

```bash
pwd
git status --short
find . -maxdepth 2 -type d | sort
find . -maxdepth 2 -type f | sort
```

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
- If no build system exists, say so in `{{CONFIG_DIR}}/rules/build.md`.
- If no executable entrypoints exist, say so in `{{CONFIG_DIR}}/maps/entrypoints.md`.

## Required Output After Apply

After editing, return:

```md
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
```

## Required Verification

After editing, run:

```bash
grep -RIn "TODO\\|Fill this\\|Update this" {{CONFIG_DIR}} || true
find {{CONFIG_DIR}} -maxdepth 3 -type f | sort
```

Then summarize remaining placeholders.
