# Shell Tools

Shell and terminal tools for efficient command-line workflows.

## What's Included

### [aliases/](./aliases/) - Bash Aliases & Shell Configuration
Modular bash aliases for Git, Docker, navigation, and more. Organized by category with numbered load order.

**Installation:**
```bash
cd shell/aliases
./setup.sh
```

**Documentation:** [aliases/README.md](./aliases/README.md)

### [terminal/](./terminal/) - Terminal Session Management
Quick reference for terminal multiplexers (`screen` and `tmux`).

**Installation:** No installation needed — reference documentation

**Documentation:** [terminal/README.md](./terminal/README.md)

## Structure

This directory is organized by tool type:
- `aliases/` - Bash aliases and shell configuration
- `terminal/` - Terminal multiplexing (screen/tmux)

## Philosophy

- **Modular**: Each alias file is independent and can be customized
- **Keyboard-first**: Minimize typing, maximize efficiency
- **Session management**: Use multiplexers for long-running tasks
- **Version-controlled**: Track your shell configuration
