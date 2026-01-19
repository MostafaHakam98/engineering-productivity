# Terminal Multiplexing

Quick reference for terminal multiplexers (`screen` and `tmux`) to manage multiple terminal sessions efficiently.

## What's Included

### `CheatSheet.md`
Quick reference for `screen` commands and workflows.

## Screen vs Tmux

### Screen
- **Built-in** on most Unix systems
- **Lightweight** and simple
- **Good for** basic session management

### Tmux
- **More features** (panes, windows, sessions)
- **Better configuration** options
- **Modern** and actively maintained
- **Recommended for** power users

## Quick Start

### Screen

```bash
# Start a named session
screen -S myproject

# Detach (keeps running in background)
Ctrl + a, then d

# List sessions
screen -ls

# Reattach to session
screen -r myproject

# Kill a session
screen -X -S myproject quit
```

See `CheatSheet.md` for more commands.

### Tmux

```bash
# Start a new session
tmux

# Start a named session
tmux new -s myproject

# Detach
Ctrl + b, then d

# List sessions
tmux ls

# Attach to session
tmux attach -t myproject

# Kill a session
tmux kill-session -t myproject
```

## Common Use Cases

1. **Long-running processes**: Start a process in a screen/tmux session, detach, and reconnect later
2. **Remote work**: SSH into a server, start a session, and reconnect from anywhere
3. **Multiple terminals**: Split panes/windows for different tasks
4. **Session persistence**: Keep work alive across terminal restarts

## Tips

- **Name your sessions**: Use descriptive names (`-S myproject`)
- **Detach before closing**: Always detach (don't just close terminal)
- **Use tmux for complex workflows**: Better for managing multiple panes/windows
- **Learn key bindings**: Master the prefix key (`Ctrl+a` for screen, `Ctrl+b` for tmux)

## Resources

- [Screen Manual](https://www.gnu.org/software/screen/manual/)
- [Tmux Manual](https://tmux.github.io/)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
