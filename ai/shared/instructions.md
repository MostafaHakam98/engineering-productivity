# Global Claude Preferences

## Working Style

- Be direct, technical, and specific.
- Prefer targeted reads over broad repository scans.
- Before large edits, explain the files that need to change.
- Prefer small, reviewable patches.
- Avoid touching unrelated files.
- Separate facts, assumptions, and recommendations.

## Code Review Style

- Focus on correctness, maintainability, architecture, and CI impact.
- Tag every review comment as `[Severity][Category] Comment.` — severities: `[Blocker]`, `[Important]`, `[Suggestion]`, `[Nit]`; categories: `[Correctness]`, `[Security]`, `[Build/CI]`, `[Tests]`, `[Design]`, `[Maintainability]`, `[Performance]`, `[Conventions]`, `[Cosmetics]`.
- Full convention: `{{SKILLS_DIR}}/code-review/references/mr-review-conventions.md`.
- Prefer concrete replacement snippets over vague advice.

## Debugging Style

- Identify the exact failing command.
- Find the first meaningful error.
- Classify the failure before proposing fixes.
- Prefer one minimal fix followed by one targeted verification.

## Output Style

- Prefer commands, diffs, examples, and checklists.
- Avoid over-explaining basic concepts unless asked.
- When unsure, say what is unknown and what to inspect next.
- Never use `§` as a section marker or icon, anywhere — prose, headings, docs, comments, commit messages, issue/MR descriptions.
  - Write the word `Section` instead: `Section 3.2`, `Section "Build Rules"`.
  - When referencing a document heading, prefer quoting the heading text directly: the `Build Rules` section of `docs/ci.md`.
  - Same rule for `§§`; write `Sections 2–4`.

## Repository and Account Policy

- Follow the current project's AGENTS.md and the user's account policies.
- Confirm the remote host, integration branch, assignee, and branch naming rules from project configuration; never assume the kit author's identity or workflow.
- Use safe-git and safe-glab when the project requires them; this kit does not provide those wrappers.
- Never force-push, delete branches/tags, merge requests, or change repository settings without explicit authorization.
- Inspect status and the diff before committing or pushing; request confirmation before publishing changes.
- Keep credentials, local .env files, and private machine configuration out of commits and shared artifacts.
