---
name: code-review
description: Use when reviewing code, diffs, merge requests, pull requests, or proposed changes.
---

# Code Review Skill

## Goal

Review code for correctness, safety, maintainability, architecture boundaries, and testability.

## Review Priorities

Review in this order:

1. Correctness
2. Safety
3. Architecture boundaries
4. Maintainability
5. Test coverage
6. Performance
7. Style

## Output Format

~~~md
## Blockers

- ...

## Important

- ...

## Suggestions

- ...

## Questions

- ...
~~~

## Finding Format

Each finding should include:

- Location
- Issue
- Impact
- Suggested fix

## Rules

- Do not nitpick formatting unless it affects maintainability.
- Do not request broad refactors unless necessary.
- Prefer actionable comments that can be pasted into merge requests.
- Separate must-fix issues from optional improvements.
- Point out missing tests when behavior changes.
