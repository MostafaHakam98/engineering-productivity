# Dependency Map

## Purpose

This file defines architectural dependency direction.

## Dependency Direction

Fill this per project.

Example:

~~~text
CLI / API layer
    -> service layer
    -> domain layer
    -> infrastructure layer
~~~

## Rules

- Keep dependency direction explicit.
- Do not introduce reverse dependencies.
- Add dependencies to the smallest owning component.
- Do not fix architecture issues by adding broad imports or broad links.

## Red Flags

- Low-level component imports high-level component.
- Core package depends on application-specific backend without an interface.
- Build target links unrelated implementation-heavy library.
