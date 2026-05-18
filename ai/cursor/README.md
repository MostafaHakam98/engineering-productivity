# Cursor Productivity Kit

Reusable Cursor configuration for engineering workflows.

## Purpose

This directory contains reusable Cursor rules and project templates.

It is designed to:

- reduce repeated prompting
- improve code review consistency
- improve debugging discipline
- reduce unnecessary repository scanning
- enforce safer command execution
- provide reusable engineering workflows across projects

## Structure

- `global/` installs into `~/.cursor/rules/`
- `project-template/` installs into a project-local `.cursor/`
- `scripts/` contains install scripts

## Recommended Usage

Install personal global config:

```bash
./scripts/install-global.sh
```

Install project-local template from inside a project:

```bash
/path/to/engineering-productivity/ai/cursor/scripts/install-project.sh
```

Project-specific files should be committed to the project repository.

Personal files under `~/.cursor/rules/` should not be committed to product repositories.

## Layer Model

| Layer                  | Location                       | Purpose                                            |
|------------------------|--------------------------------|----------------------------------------------------|
| Personal global rules  | `~/.cursor/rules/`             | Personal AI behavior, reusable workflow rules      |
| Reusable template      | `ai/cursor/project-template/`  | Starter `.cursor/` structure for projects          |
| Project-local rules    | `<project>/.cursor/rules/`     | Project-specific rules, maps, and architecture     |

## How Cursor Rules Work

Cursor rules are `.mdc` files with frontmatter that controls when they are loaded:

| Type             | Frontmatter                     | When loaded                                      |
|------------------|---------------------------------|--------------------------------------------------|
| Always Apply     | `alwaysApply: true`             | Every chat and Composer session                  |
| Auto Attached    | `globs: "*.ts,*.tsx"`           | When a matching file is open in context          |
| Agent Requested  | `description: "..."`            | AI decides based on description match            |
| Manual           | _(none of the above)_           | Only when referenced with `@ruleName` in chat    |

## Notes

- Keep `alwaysApply` rules short — they load every session.
- Use Agent Requested rules for workflow guidance (debug, review, plan).
- Use Auto Attached rules for language or toolchain-specific rules.
- Fill in project maps after installing the template.
- Reference rules manually with `@ruleName` in Cursor chat when needed.