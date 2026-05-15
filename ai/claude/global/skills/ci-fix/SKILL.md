---
name: ci-fix
description: Use when debugging or improving CI/CD pipelines, GitLab CI, GitHub Actions, Docker CI images, artifacts, caching, linting, tests, coverage, or license checks.
---

# CI Fix Skill

## Goal

Analyze CI failures and propose the smallest safe pipeline, script, or code fix.

## CI Debugging Order

1. Identify failed job and stage.
2. Identify failed command.
3. Extract first real error.
4. Determine whether failure is:
   - image issue
   - dependency issue
   - path issue
   - cache/artifact issue
   - permissions issue
   - test/lint issue
   - script syntax issue
   - environment issue
5. Propose minimal YAML, script, image, or code change.
6. Preserve existing pipeline structure.

## GitLab CI Rules

- Keep `script` entries valid YAML strings or arrays.
- Avoid duplicating setup across jobs if anchors/templates exist.
- Use artifacts only for required outputs.
- Use cache only for reusable dependencies/build outputs.
- Do not hide failures with `|| true` unless explicitly justified.
- Prefer job-local fixes before pipeline-wide changes.

## Output Format

~~~md
## Failed Area

...

## First Real Error

...

## Root Cause

...

## Minimal Fix

...

## Suggested Patch

...

## Verification

...
~~~
