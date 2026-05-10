# Repository Rules

## Project Summary

Fill this section per project.

Example:

This repository contains:

- Python orchestration layer
- C++ runtime or agent layer
- Optional CUDA, MPI, Ray, or distributed execution paths
- CMake-based native build system
- CI/CD configuration

## Architecture Rules

- Keep high-level orchestration separate from low-level runtime execution.
- Keep interface/API targets separate from heavy implementation targets.
- Avoid introducing dependencies from low-level runtime components back into high-level orchestration.
- Do not make broad architectural changes without a plan.

## Exploration Order

When asked about the codebase:

1. Read this file.
2. Read the relevant `.claude/rules/*.md`.
3. Inspect build files or entrypoints.
4. Inspect implementation files only after understanding the boundary.

## Avoid

- Full-repo scans unless required.
- Editing generated files.
- Editing third-party/vendor code.
- Reformatting unrelated files.
