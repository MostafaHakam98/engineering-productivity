# Claude Code Hooks

## Purpose

Hooks may be used to automate safe checks around Claude Code actions.

This directory is intentionally documentation-first. Do not install aggressive hooks by default.

## Recommended Safe Hooks

Good hook candidates:

- Warn before editing secrets, certificates, or environment files.
- Warn before modifying CI, Docker, deployment, or CMake root files.
- Run `git diff --check` after edits.
- Run targeted formatting or lint checks for touched files.
- Log risky operations for later review.

## Avoid By Default

Avoid hooks that:

- Auto-format the whole repository.
- Run full test suites after every edit.
- Modify Git history.
- Run destructive cleanup commands.
- Change file permissions recursively.
- Install packages automatically.
- Touch deployment state automatically.

## Hook Policy

Hooks should be:

1. Safe
2. Predictable
3. Fast
4. Easy to disable
5. Scoped to the current repository
6. Explicit about what they are checking

## Suggested Hook Categories

| Category | Purpose | Default |
|---|---|---|
| Pre-edit warning | Warn before sensitive file edits | Recommended |
| Post-edit check | Run lightweight validation after edits | Optional |
| Pre-command guard | Block destructive commands | Recommended |
| Session logging | Track useful context | Optional |

## Sensitive Files

Claude should avoid editing these without explicit user confirmation:

- `.env`
- `.env.*`
- `*.pem`
- `*.key`
- `*.crt`
- `*.p12`
- `id_rsa`
- `id_ed25519`
- production deployment configs
- secrets files
- generated files
- vendored dependencies

## Recommended Start

Start with documentation and permission settings first.

Only add executable hooks after the workflow is stable.
