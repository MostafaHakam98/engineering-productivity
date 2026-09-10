Use the `repo-profile` skill for this request.

Default behavior: inspect the current repository and update only `{{CONFIG_DIR}}/` files to create project-specific agent guidance.

Modes:
- `/repo-profile` updates `{{CONFIG_DIR}}/` directly.
- `/repo-profile inspect` proposes updates without editing.
- `/repo-profile refresh` updates existing guidance.
- `/repo-profile check` checks completeness without editing.
- `/repo-profile decisions` suggests architecture decisions only.

Arguments: $ARGUMENTS
