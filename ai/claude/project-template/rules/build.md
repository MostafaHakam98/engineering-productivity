# Build Rules

## General

- Prefer existing build scripts and presets.
- Do not invent build commands if repository commands already exist.
- Prefer target-based CMake where applicable.
- Avoid global include directories and global link directives unless already established.
- Keep optional backends separable.

## CMake

Prefer:

~~~bash
cmake --preset <preset>
cmake --build --preset <preset> -j"$(nproc)"
~~~

For specific targets:

~~~bash
cmake --build --preset <preset> --target <target> -j"$(nproc)"
~~~

## Debugging Build Failures

Use this order:

1. Identify the exact failing target.
2. Identify whether failure is configure, compile, link, or runtime.
3. Inspect the nearest build configuration.
4. Inspect target dependencies.
5. Propose the smallest fix.
6. Rebuild only the failing target when possible.

## Do Not

- Add dependencies to broad aggregate targets without justification.
- Link unrelated backends to core runtime targets.
- Fix link errors by blindly adding libraries everywhere.
