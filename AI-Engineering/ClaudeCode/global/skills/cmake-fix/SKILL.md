---
name: cmake-fix
description: Use for CMake configuration, compile, link, target dependency, CUDA host compiler, MPI, or native build issues.
---

# CMake Fix Skill

## Goal

Fix native build issues using target-local, minimal, architecture-aware changes.

## CMake Failure Protocol

1. Identify phase:
   - configure
   - generate
   - compile
   - link
   - install
   - runtime
2. Identify target.
3. Identify first real error.
4. Inspect nearest `CMakeLists.txt`.
5. Inspect dependency ownership.
6. Fix target-local configuration.
7. Rebuild the same target.

## Rules

- Prefer target-based CMake.
- Prefer `target_link_libraries`, `target_include_directories`, and `target_compile_definitions` scoped to the owning target.
- Avoid global CMake state.
- Avoid linking broad aggregate libraries to fix narrow errors.
- Keep CUDA-specific options isolated from CPU-only targets.
- Do not add dependencies to top-level targets unless the top-level target truly owns them.
- If fixing a linker error, identify which target owns the missing symbol first.

## Output Format

~~~md
## Phase

...

## Target

...

## First Real Error

...

## Likely Owner

...

## Minimal CMake Change

...

## Rebuild Command

...
~~~
