# Browser Tools

Browser automation scripts, shortcuts, and workflows for efficient web usage.

## What's Included

### [scripts/](./scripts/) - TamperMonkey Automation Scripts
UserScripts for GitLab and ActiTIME that enhance productivity with keyboard shortcuts and automation.

**Installation:**
1. Configure `.env` file (copy from `.env.example` and fill in your values)
2. Run setup script: `cd browser/scripts && ./setup.sh`
3. Install [Tampermonkey](https://www.tampermonkey.net/) browser extension
4. Install configured scripts from generated `.js` files

**Documentation:** [scripts/README.md](./scripts/README.md)

### [shortcuts/](./shortcuts/) - Browser Keyboard Shortcuts
Keyboard shortcuts and workflows for efficient browser usage (Chrome-focused).

**Installation:** No installation needed — reference documentation

**Documentation:** [shortcuts/README.md](./shortcuts/README.md)

## Structure

This directory is organized by tool type:
- `scripts/` - TamperMonkey automation scripts (GitLab, ActiTIME)
- `shortcuts/` - Browser keyboard shortcuts and workflows

## Philosophy

> Tabs are cheap. Attention is not.

- **Keyboard-first**: Minimize mouse usage, maximize keyboard efficiency
- **Intentional navigation**: Know where you're going before you go
- **Clean workspace**: Close tabs you don't need
- **Automation**: Use scripts to eliminate repetitive tasks
