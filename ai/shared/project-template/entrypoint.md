# Project Guide

## Primary Rule

Do not scan the whole repository by default.

Use progressive disclosure:

1. Read this file.
2. Read only the relevant rule file under `{{CONFIG_DIR}}/rules/`.
3. Use the relevant skill under `{{SKILLS_DIR}}` when the task matches.
4. Inspect only the files needed for the current task.

## Always Follow

- Prefer targeted reads over broad exploration.
- Before editing, identify the smallest set of files likely to change.
- For non-trivial work, explore first, then plan, then edit.
- Do not rewrite unrelated files.
- Do not perform large refactors unless explicitly requested.
- Prefer small, reviewable patches.
- Preserve existing architecture, naming, and style unless the task asks for redesign.
- After changes, run the narrowest relevant verification command.

## Rule Files

Read these only when relevant:

- `{{CONFIG_DIR}}/rules/shared.{{RULE_EXT}}` — general engineering behavior
- `{{CONFIG_DIR}}/rules/repo.{{RULE_EXT}}` — repository architecture and boundaries
- `{{CONFIG_DIR}}/rules/build.{{RULE_EXT}}` — build/CMake/Docker conventions
- `{{CONFIG_DIR}}/rules/testing.{{RULE_EXT}}` — test and validation rules
- `{{CONFIG_DIR}}/rules/style.{{RULE_EXT}}` — code style and review conventions

## Maps

Read these only when relevant:

- `{{CONFIG_DIR}}/maps/repo-map.{{RULE_EXT}}` — compact repository structure
- `{{CONFIG_DIR}}/maps/entrypoints.{{RULE_EXT}}` — CLIs, binaries, services, app entrypoints
- `{{CONFIG_DIR}}/maps/dependency-map.{{RULE_EXT}}` — dependency direction and architecture boundaries
- `{{CONFIG_DIR}}/maps/ownership-map.{{RULE_EXT}}` — component ownership

## Token Discipline

- Do not open generated files, build directories, vendored dependencies, or large logs unless needed.
- Summarize large outputs instead of pasting them back.
- Prefer `git diff --stat`, `git status`, targeted `grep`, and focused file reads.
- If context grows too large, summarize the current state and suggest compaction.
