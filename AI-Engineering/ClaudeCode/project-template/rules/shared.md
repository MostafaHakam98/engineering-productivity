# Shared Engineering Rules

## Working Style

- Be direct, technical, and specific.
- Prefer commands, patches, and concrete examples.
- Avoid vague advice.
- Separate facts, assumptions, and recommendations.
- Ask only when the missing information blocks progress.

## Change Discipline

Before editing:

1. State the suspected area.
2. Identify the minimal files needed.
3. Explain the intended change.
4. Then edit.

After editing:

1. Show what changed.
2. Explain why.
3. Run or recommend the smallest useful verification.

## Safety

- Do not delete files without explicit reason.
- Do not modify secrets, credentials, certificates, or deployment configs casually.
- Do not run destructive commands unless explicitly requested.
- When using shell commands, prefer read-only commands first.
