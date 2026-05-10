# Claude Code Productivity Kit

Reusable Claude Code configuration for engineering workflows.

## Purpose

This directory contains reusable Claude Code skills, commands, agents, hooks, and project templates.

It is designed to:

- reduce repeated prompting
- improve code review consistency
- improve debugging discipline
- reduce unnecessary repository scanning
- enforce safer command execution
- provide reusable engineering workflows across projects

## Structure

- `global/` installs into `~/.claude/`
- `project-template/` installs into a project-local `.claude/`
- `scripts/` contains install and sync scripts

## Recommended Usage

Install personal global config:

~~~bash
./scripts/install-global-claude.sh
~~~

Install project-local template from inside a project:

~~~bash
/path/to/engineering-productivity/AI-Engineering/ClaudeCode/scripts/install-project-claude.sh
~~~

Project-specific files should be committed to the project repository.

Personal files under `~/.claude/` should not be committed to product repositories.

## Recommended Model

Use three layers:

| Layer                  | Location                                      | Purpose                                                      |
|------------------------|-----------------------------------------------|--------------------------------------------------------------|
| Personal global config | `~/.claude/`                                  | Personal Claude behavior, reusable skills, reusable commands |
| Reusable template      | `AI-Engineering/ClaudeCode/project-template/` | Starter `.claude/` structure for projects                    |
| Project-local config   | `<project>/.claude/`                          | Project-specific rules, maps, workflows, and decisions       |

## Notes

- Keep `CLAUDE.md` files short.
- Prefer skills for repeatable workflows.
- Prefer project maps for repository understanding.
- Prefer decisions for architecture constraints.
- Avoid putting large documentation directly into startup context.
