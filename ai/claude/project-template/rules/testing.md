# Testing Rules

## Default Verification

Use the narrowest validation that proves the change:

- Unit test for local logic changes.
- Targeted build for build-system changes.
- Lint/format only for touched language or directory.
- CI pipeline reasoning only when local reproduction is unavailable.

## Before Running Tests

- Check existing test commands first.
- Prefer targeted tests over full suites.
- If a test requires services, containers, GPU, MPI, or cluster access, say so before running.

## After Failure

When a test fails:

1. Quote the failing command.
2. Extract the first meaningful error.
3. Identify whether it is caused by the change or environment.
4. Propose the smallest next action.
