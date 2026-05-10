# Merge Request Checklist

## Purpose

Use this checklist before opening or marking a merge request as ready for review.

## Pre-MR Checks

- Confirm the change solves the stated issue.
- Confirm unrelated files were not modified.
- Confirm generated files were not edited manually.
- Confirm secrets, credentials, and local config files were not committed.
- Confirm the branch name follows the project convention.
- Confirm the commit message is meaningful.

## Code Quality

- Code follows nearby style.
- Functions/classes remain focused.
- Error handling is explicit.
- No broad refactor was mixed with a feature or bug fix.
- Public behavior changes are documented.

## Tests and Verification

- Narrowest relevant test was run.
- Build command was run when build files changed.
- CI-relevant scripts were checked when pipeline files changed.
- Manual verification is documented if automated testing is not available.

## Review Notes

Before opening the MR, summarize:

1. What changed.
2. Why it changed.
3. How it was verified.
4. Any known risks or follow-ups.
