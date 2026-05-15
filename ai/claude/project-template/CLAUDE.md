# Project Claude Guide

## Primary Rule

Do not scan the whole repository by default.

Use progressive disclosure:

1. Read this file.
2. Read only the relevant rule file under `.claude/rules/`.
3. Use the relevant skill under `.claude/skills/` when the task matches.
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

- `.claude/rules/shared.md` — general engineering behavior
- `.claude/rules/repo.md` — repository architecture and boundaries
- `.claude/rules/build.md` — build/CMake/Docker conventions
- `.claude/rules/testing.md` — test and validation rules
- `.claude/rules/style.md` — code style and review conventions

## Maps

Read these only when relevant:

- `.claude/maps/repo-map.md` — compact repository structure
- `.claude/maps/entrypoints.md` — CLIs, binaries, services, app entrypoints
- `.claude/maps/dependency-map.md` — dependency direction and architecture boundaries
- `.claude/maps/ownership-map.md` — component ownership

## Token Discipline

- Do not open generated files, build directories, vendored dependencies, or large logs unless needed.
- Summarize large outputs instead of pasting them back.
- Prefer `git diff --stat`, `git status`, targeted `grep`, and focused file reads.
- If context grows too large, summarize the current state and suggest compaction.
