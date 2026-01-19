# Git Tools

Git hooks and tools for code quality and workflow automation.

## What's Included

### [hooks/](./hooks/) - Pre-commit & Pre-push Hooks
Git hooks that enforce code quality and prevent common mistakes (TODO/FIXME, debug prints, secrets).

**Installation:**
```bash
cd git/hooks
./setup.sh
# Or specify a repository: ./setup.sh /path/to/repo
```

**Documentation:** [hooks/README.md](./hooks/README.md)

## Structure

This directory is organized by tool type:
- `hooks/` - Git hooks (pre-commit, pre-push)

## Philosophy

- **Quality gates**: Catch mistakes before they reach the repository
- **Fast checks**: Hooks should be quick, not comprehensive test suites
- **Customizable**: Modify patterns and checks for your codebase
- **Version-controlled**: Track hook improvements over time
