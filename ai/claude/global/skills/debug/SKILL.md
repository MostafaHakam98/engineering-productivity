---
name: debug
description: Use when a command, test, build, service, pipeline, or runtime behavior is failing.
---

# Debug Skill

## Goal

Debug failures by identifying the first real error and applying the smallest useful fix.

## Debugging Protocol

1. Capture the exact failing command.
2. Identify the first meaningful error.
3. Classify the failure:
   - configure
   - compile
   - link
   - test
   - runtime
   - permission
   - network
   - environment
   - dependency
4. Inspect the smallest relevant file.
5. Propose one fix.
6. Verify with the narrowest command.

## Output Format

~~~md
## Failure

...

## First Real Error

...

## Classification

...

## Likely Cause

...

## Smallest Fix

...

## Verification

...
~~~

## Rules

- Do not chase secondary errors before the first real error.
- Do not run full test suites before isolating the failure.
- Do not change configuration and code at the same time unless required.
- Prefer one hypothesis and one verification step at a time.
- If logs are large, summarize only the relevant error region.
