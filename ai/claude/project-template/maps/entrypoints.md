# Entrypoints

## Purpose

This file lists important execution entrypoints so Claude does not guess how the system starts.

## Application Entrypoints

Fill this table per project.

| Entrypoint | Purpose | Notes |
|---|---|---|
| `TODO` | TODO | TODO |

## Build Entrypoints

Fill this section per project.

Example:

~~~bash
cmake --preset <preset>
cmake --build --preset <preset> -j"$(nproc)"
~~~

## Rule

Before changing execution behavior, identify which entrypoint owns the behavior.
