---
name: plan-change
description: Use before making non-trivial edits, refactors, multi-file changes, or architectural changes.
---

# Plan Change Skill

## Goal

Create a minimal, reviewable implementation plan before editing.

## When To Use

Use this skill when:

- The requested change touches multiple files.
- The change affects architecture, build logic, CI, deployment, or data models.
- The user asks for a plan.
- The implementation path is not obvious.
- The change may introduce risk.

## Steps

1. Identify the requested outcome.
2. Identify affected areas.
3. Read only the necessary files.
4. Produce a short plan.
5. Identify risks.
6. Define verification.
7. Edit only after the plan is clear.

## Plan Format

~~~md
## Goal

...

## Files Likely Involved

- ...

## Proposed Change

1. ...
2. ...

## Risks

- ...

## Verification

- ...
~~~

## Rules

- Keep plans short.
- Do not plan broad refactors unless requested.
- Prefer incremental changes.
- If the request is simple, skip the heavy plan and proceed directly.
- Do not edit before understanding ownership and affected boundaries.
