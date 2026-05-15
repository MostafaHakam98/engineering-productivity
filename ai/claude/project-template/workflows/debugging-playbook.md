# Debugging Playbook

## Purpose

Use this workflow when debugging project failures.

## Debugging Flow

1. Capture the exact failing command.
2. Capture the first meaningful error.
3. Classify the failure.
4. Identify the smallest owning file or component.
5. Make one hypothesis.
6. Apply one minimal fix.
7. Verify with the narrowest command.
8. Escalate only if the signal requires it.

## Failure Classification

Common classes:

- configure
- compile
- link
- test
- runtime
- permission
- network
- environment
- dependency
- CI-only
- data/configuration

## Rules

- Do not chase secondary errors first.
- Do not scan the whole repository unless the owner is unknown.
- Do not mix multiple fixes in one patch.
- Do not make architecture changes to fix local symptoms unless evidence requires it.
- Prefer reproducible commands over assumptions.

## Useful Commands

~~~bash
git status --short
git diff --stat
git diff
rg "<error-symbol-or-term>"
find . -maxdepth 3 -type f
~~~

## Debugging Summary Format

~~~md
## Failure

...

## First Real Error

...

## Classification

...

## Likely Owner

...

## Smallest Fix

...

## Verification

...
~~~
