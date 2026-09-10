# MR Review Conventions — `[Severity][Category]` Tagging

## Overview

Review comments often mix urgency with intent — a comment might be blocking but the author doesn't know it, or it might be a personal preference but reads like a requirement. This convention solves that by tagging every review comment with two pieces of information:

- **Severity** — does this need to be fixed before merge?
- **Category** — what kind of problem is this?

**Format:** `[Severity][Category] Your comment here.`

**Examples:**
```
[Blocker][Correctness] This changes behavior for the empty-input case and may break existing callers.
[Important][Tests] Please add a regression test for this new behavior.
[Suggestion][Maintainability] This helper could be extracted to reduce duplication.
[Nit][Cosmetics] Small typo in the comment.
```

---

## Severity Tiers

| Tier | Merge Impact | When to Use |
|---|---|---|
| `[Blocker]` | **Must fix before merge** | Correctness bugs, broken builds/tests, security risks, data integrity issues, major architectural problems |
| `[Important]` | **Expected to fix; deferral needs justification or a tracked follow-up** | Missing tests for new behavior, design concerns, significant maintainability issues, important implementation gaps |
| `[Suggestion]` | **Optional improvement; current state is acceptable** | Cleaner alternatives, simplifications, consistency improvements the author may or may not adopt |
| `[Nit]` | **Cosmetic / very minor; never blocks** | Formatting preferences, wording changes, typo fixes |

> **Rule of thumb:** If merging the current state introduces real risk → `[Blocker]`. If it matters but isn't dangerous → `[Important]`. If it's just better but not necessary → `[Suggestion]`. If it's purely cosmetic → `[Nit]`.

---

## Finding Categories

| Category | Covers | Typical Severity |
|---|---|---|
| `[Correctness]` | Logic bugs, wrong behavior, broken assumptions, missed edge cases, violated contracts | Blocker / Important |
| `[Security]` | Auth gaps, injection risks, unsafe data exposure, missing validation | Blocker / Important |
| `[Build/CI]` | Failing builds, failing tests, broken pipelines, unstable CI/CD flow | Blocker (if required pipeline affected) |
| `[Tests]` | Missing, weak, or non-asserting coverage for changed or new behavior | Important / Suggestion |
| `[Design]` | Module boundaries, misplaced responsibility, unnecessary coupling, abstraction leaks | Important / Suggestion |
| `[Maintainability]` | Duplication, unnecessary complexity, unclear control flow, poor naming, hidden assumptions | Important / Suggestion |
| `[Performance]` | Inefficient paths, excessive memory, scalability concerns, slow user-facing flows | Blocker (hot path) / Suggestion (cold path) |
| `[Conventions]` | Deviations from project patterns, naming conventions, or team-agreed structure | Suggestion (usually) |
| `[Cosmetics]` | Formatting, whitespace, comment wording, typo fixes | Nit |

---

## Severity × Category Reference

Use this as a quick sanity check. Combinations marked ✓ are common and expected.

| | `[Correctness]` | `[Security]` | `[Build/CI]` | `[Tests]` | `[Design]` | `[Maintainability]` | `[Performance]` | `[Conventions]` | `[Cosmetics]` |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `[Blocker]` | ✓ | ✓ | ✓ | | | | ✓* | | |
| `[Important]` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | | |
| `[Suggestion]` | | | | ✓ | ✓ | ✓ | ✓ | ✓ | |
| `[Nit]` | | | | | | | | ✓ | ✓ |

*`[Blocker][Performance]` applies only to hot paths, large-scale workflows, or user-facing regressions.

---

## Deferring an `[Important]` Comment

An `[Important]` comment does not have to block merge if both the author and reviewer agree. When deferring:

1. Acknowledge the comment explicitly in the thread.
2. Create a follow-up issue or task and link it in the thread.
3. The reviewer resolves the thread once the follow-up is tracked.

This keeps the MR moving without silently dropping legitimate concerns.

---

## Author and Reviewer Responsibilities

**As a reviewer:**
- Tag every comment. An untagged comment defaults to ambiguous — the author won't know whether to block on it.
- Do not use `[Blocker]` for stylistic preferences. That tier is reserved for real risk.
- Do not insist on `[Nit]` changes. State them once and move on.

**As an author:**
- Resolve all `[Blocker]` comments before requesting re-review.
- Address or explicitly defer all `[Important]` comments with justification.
- `[Suggestion]` and `[Nit]` comments are your call — you may decline them without explanation.

---

## Full Example Thread

```
[Blocker][Correctness]
The `processItems()` call here skips validation when the input list is empty.
This will silently produce incorrect output for callers that pass an empty collection.
Please add a guard before the loop.

---

[Important][Tests]
There are no tests covering the empty-input path mentioned above.
Even after the fix, please add a regression test so this doesn't regress silently.

---

[Suggestion][Design]
The retry logic here is duplicated from `retryWithBackoff()` in `utils/retry.go`.
Consider extracting or reusing that helper. Not blocking, just worth noting.

---

[Nit][Cosmetics]
"recieve" → "receive" in the doc comment on line 42.
```

---

## Background

This convention was established within the SCAI team and aligned with team lead Omar. It is also being proposed for adoption across ACAI to make cross-team reviews more consistent and easier to reason about. Adoption is recommended but not mandatory, at the time being. Teams may adapt it to fit their workflow.
