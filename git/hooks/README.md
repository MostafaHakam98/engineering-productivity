# Git Hooks

Pre-commit and pre-push hooks that enforce code quality and prevent common mistakes.

## What's Included

### `pre-commit`
Blocks commits that contain:
- **TODO/FIXME comments** in staged changes
- **Debug print statements** (Python)
- **Potential secrets** (private keys, API keys, tokens)

### `pre-push`
Runs before pushing to remote:
- **Python syntax check** (if Python files exist)
- **Django smoke tests** (if `manage.py` exists)

## Installation

### Quick Setup

Run the setup script to install hooks in your repository:

```bash
cd /path/to/your/repo
./path/to/engineering-productivity/GitHooks/setup.sh
```

Or manually:

```bash
# Copy hooks to your repository's .git/hooks/
cp GitHooks/pre-commit /path/to/your/repo/.git/hooks/
cp GitHooks/pre-push /path/to/your/repo/.git/hooks/

# Make them executable
chmod +x /path/to/your/repo/.git/hooks/pre-commit
chmod +x /path/to/your/repo/.git/hooks/pre-push
```

### Global Installation (All Repos)

To install hooks for all your Git repositories:

```bash
# Set up global git hooks directory
git config --global core.hooksPath ~/.git-hooks
mkdir -p ~/.git-hooks

# Copy hooks
cp GitHooks/pre-commit ~/.git-hooks/
cp GitHooks/pre-push ~/.git-hooks/

# Make executable
chmod +x ~/.git-hooks/pre-commit
chmod +x ~/.git-hooks/pre-push
```

## Customization

Edit the hook files to:
- Adjust regex patterns for your codebase
- Add project-specific checks
- Modify error messages
- Add support for other languages

## Bypassing Hooks (When Needed)

```bash
# Skip pre-commit hook
git commit --no-verify -m "message"

# Skip pre-push hook
git push --no-verify
```

⚠️ **Use sparingly** — hooks exist to catch mistakes early.

## Tips

1. **Test locally first**: Hooks run automatically, so test your changes before committing
2. **Keep hooks fast**: These hooks are designed to be quick checks, not full test suites
3. **Customize per project**: Different projects may need different rules
4. **Version control hooks**: Consider using [pre-commit framework](https://pre-commit.com/) for more complex setups
