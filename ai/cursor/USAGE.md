# Cursor Kit Usage

## Install Global Rules

Run once to install personal global rules into `~/.cursor/rules/`:

```bash
./scripts/install-global.sh
```

These rules apply across all projects. They cover working style, output preferences,
and reusable workflows (debug, review, plan, caveman).

## Install Project Template

Run from inside a project directory to scaffold `.cursor/rules/`:

```bash
/path/to/engineering-productivity/ai/cursor/scripts/install-project.sh
```

Then fill in the project-specific map files:

- `.cursor/rules/repo-map.mdc` — top-level structure
- `.cursor/rules/entrypoints.mdc` — CLIs, services, binaries
- `.cursor/rules/dependency-map.mdc` — dependency direction
- `.cursor/rules/ownership-map.mdc` — component ownership
- `.cursor/rules/repo.mdc` — architecture rules

## Triggering Workflow Rules

Workflow rules (debug, review, plan, caveman) are Agent Requested.
Cursor's AI loads them automatically when the task matches.

You can also reference them manually in chat:

```
@debug  — use the debug workflow
@review — use the review workflow
@plan-change — use the plan-change workflow
@caveman — use the caveman approach
```

## Rule Loading Summary

| Rule file            | Loaded when                                    |
|----------------------|------------------------------------------------|
| `working-style.mdc`  | Always                                         |
| `output-style.mdc`   | Always                                         |
| `project.mdc`        | Always (project-level)                         |
| `debug.mdc`          | AI detects debugging task                      |
| `code-review.mdc`    | AI detects review task                         |
| `plan-change.mdc`    | AI detects planning task                       |
| `caveman.mdc`        | AI detects unclear/exploding-scope task        |
| `ci-fix.mdc`         | AI detects CI failure task                     |
| `cmake-fix.mdc`      | AI detects CMake/build failure task            |
| `build.mdc`          | Auto-attached on CMake/Docker files            |
| `testing.mdc`        | Auto-attached on test files                    |
| `shared.mdc`         | AI loads for general engineering tasks         |
| `repo.mdc`           | AI loads when architecture context is needed   |
| `style.mdc`          | AI loads for style or review tasks             |
| `repo-map.mdc`       | AI loads when exploring the repository         |
