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

## Comment Format

Tag every review comment with a severity and a category:

```
[Severity][Category] Comment text.
```

Full convention (tier definitions, category table, severity × category matrix,
deferral process): `references/mr-review-conventions.md` in this skill directory.
Read it before writing MR review comments.

Severities: `[Blocker]` (must fix before merge), `[Important]` (expected to fix;
deferral needs a tracked follow-up), `[Suggestion]` (optional), `[Nit]` (cosmetic,
never blocks).

Categories: `[Correctness]`, `[Security]`, `[Build/CI]`, `[Tests]`, `[Design]`,
`[Maintainability]`, `[Performance]`, `[Conventions]`, `[Cosmetics]`.

## Output Format

Group findings by severity, each comment individually tagged and pasteable into
a GitLab MR thread:

```md
## Blockers

- `path/to/file.py:42` — [Blocker][Correctness] ...

## Important

- `path/to/file.py:87` — [Important][Tests] ...

## Suggestions

- ... — [Suggestion][Design] ...

## Nits

- ... — [Nit][Cosmetics] ...

## Questions

- ...
```

## Finding Format

Each finding should include:

- Location
- `[Severity][Category]` tag
- Issue
- Impact
- Suggested fix

## Rules

- Tag every comment. An untagged comment is ambiguous — the author won't know whether to block on it.
- Do not use `[Blocker]` for stylistic preferences; that tier is reserved for real risk (correctness, security, broken builds, data integrity).
- `[Blocker][Performance]` applies only to hot paths, large-scale workflows, or user-facing regressions.
- State `[Nit]` comments once and move on; never insist on them.
- Do not nitpick formatting unless it affects maintainability.
- Do not request broad refactors unless necessary.
- Prefer actionable comments that can be pasted into merge requests.
- Point out missing tests when behavior changes (`[Important][Tests]`).
