# Refactor Checklist

## Purpose

Use this checklist before performing refactors.

## Before Refactoring

- Confirm the refactor has a clear goal.
- Confirm behavior should remain unchanged.
- Identify the owning component.
- Identify affected tests.
- Identify public APIs or interfaces that must remain stable.
- Separate mechanical cleanup from behavior changes.

## Refactor Rules

- Prefer small, reviewable steps.
- Avoid unrelated formatting changes.
- Preserve existing architecture unless explicitly changing it.
- Do not move files without updating imports, build files, and tests.
- Do not rename public interfaces without checking callers.
- Do not combine large refactors with feature work.

## Verification

After refactoring:

- Run targeted tests for the affected component.
- Run build command if imports, headers, CMake, or package structure changed.
- Run lint/format only on touched files where possible.
- Check `git diff --stat` for unexpected breadth.

## Review Summary Format

~~~md
## Refactor Goal

...

## Behavior Change

Expected: none / yes

## Files Changed

...

## Verification

...

## Risks

...
~~~
