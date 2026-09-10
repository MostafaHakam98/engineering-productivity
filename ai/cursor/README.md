# Cursor Kit

Cursor is one **target** of the shared AI kit. The content it installs lives in
[`ai/shared/`](../shared/), not here. See [`ai/README.md`](../README.md) for the
porting model.

This directory holds only script shims kept so existing paths keep working.

## Install

```bash
ai-install cursor
forge install cursor
```

| Kit artifact | Lands at |
|---|---|
| `instructions.md` | `~/.cursor/rules/working-style.mdc` (`alwaysApply: true`) |
| `skills/<n>/` | `~/.cursor/rules/<n>.mdc` (`alwaysApply: false`) |
| `commands/<n>.md` | `~/.cursor/commands/<n>.md` |

## How skills become rules

Cursor has no skill loader, so each skill is converted to a single `.mdc` rule:
the SKILL.md frontmatter becomes Cursor's `description` + `alwaysApply: false`,
which is what makes the rule agent-requestable — Cursor pulls it in when the
description matches the task, the same trigger a skill uses.

A skill's bundled `references/` and `scripts/` cannot travel into a single
file. Rather than drop them silently, the generated rule ends with a
**Bundled Resources** section listing their repo-relative paths so the agent can
read them on demand.

Subagents and permission rules are not installed — Cursor has neither concept.

## Project config

```bash
ai-install-project cursor   # writes .cursor/rules/ here
```

The shared project template's rules, maps and workflows are flattened into
Cursor's single `rules/` directory as `.mdc` files, with cross-references
rewritten to match. The template's entry point becomes `project.mdc` with
`alwaysApply: true`.

Project rules should be committed to the product repository. Personal rules
under `~/.cursor/rules/` should not.
