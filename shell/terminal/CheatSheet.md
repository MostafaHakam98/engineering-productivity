# Terminal Cheat Sheet

Quick reference for terminal multiplexers and essential terminal shortcuts.

---

## Screen

### Session Management

| Command | Description |
|---------|-------------|
| `screen` | Start new session |
| `screen -S <name>` | Start named session |
| `screen -ls` | List all sessions |
| `screen -r <name>` | Reattach to session |
| `screen -r <pid>` | Reattach by PID |
| `screen -d -r <name>` | Detach and reattach (force) |
| `screen -X -S <name> quit` | Kill session |
| `screen -x` | Attach to existing session (multi-user) |

### Key Bindings (Ctrl+a prefix)

| Binding | Description |
|---------|-------------|
| `Ctrl+a, c` | Create new window |
| `Ctrl+a, n` | Next window |
| `Ctrl+a, p` | Previous window |
| `Ctrl+a, 0-9` | Switch to window number |
| `Ctrl+a, w` | List windows |
| `Ctrl+a, "` | Window selection menu |
| `Ctrl+a, d` | Detach session |
| `Ctrl+a, D D` | Detach and logout |
| `Ctrl+a, k` | Kill current window |
| `Ctrl+a, A` | Rename current window |
| `Ctrl+a, [` | Enter copy mode |
| `Ctrl+a, ]` | Paste |
| `Ctrl+a, ?` | Show help |
| `Ctrl+a, :` | Command prompt |
| `Ctrl+a, \` | Kill all windows and detach |
| `Ctrl+a, S` | Split horizontally |
| `Ctrl+a, |` | Split vertically |
| `Ctrl+a, Tab` | Switch between regions |
| `Ctrl+a, Q` | Close all regions except current |

### Copy Mode (after `Ctrl+a, [`)

| Key | Description |
|-----|-------------|
| `Space` | Start selection |
| `Enter` | Copy selection |
| `Esc` | Exit copy mode |
| Arrow keys | Navigate |
| `Page Up/Down` | Scroll |

---

## Tmux

### Session Management

| Command | Description |
|---------|-------------|
| `tmux` | Start new session |
| `tmux new -s <name>` | Start named session |
| `tmux ls` | List all sessions |
| `tmux attach -t <name>` | Attach to session |
| `tmux attach -d -t <name>` | Detach others and attach |
| `tmux kill-session -t <name>` | Kill session |
| `tmux kill-server` | Kill all sessions |
| `tmux rename-session -t <old> <new>` | Rename session |

### Key Bindings (Ctrl+b prefix)

| Binding | Description |
|---------|-------------|
| `Ctrl+b, c` | Create new window |
| `Ctrl+b, n` | Next window |
| `Ctrl+b, p` | Previous window |
| `Ctrl+b, 0-9` | Switch to window number |
| `Ctrl+b, w` | List windows |
| `Ctrl+b, ,` | Rename current window |
| `Ctrl+b, &` | Kill current window |
| `Ctrl+b, d` | Detach session |
| `Ctrl+b, %` | Split vertically (pane) |
| `Ctrl+b, "` | Split horizontally (pane) |
| `Ctrl+b, o` | Switch between panes |
| `Ctrl+b, q` | Show pane numbers |
| `Ctrl+b, x` | Kill current pane |
| `Ctrl+b, z` | Zoom/unzoom pane |
| `Ctrl+b, [` | Enter copy mode |
| `Ctrl+b, ]` | Paste |
| `Ctrl+b, ?` | Show key bindings |
| `Ctrl+b, :` | Command prompt |
| `Ctrl+b, s` | List sessions |
| `Ctrl+b, t` | Show clock |

### Copy Mode (after `Ctrl+b, [`)

| Key | Description |
|-----|-------------|
| `Space` | Start selection |
| `Enter` | Copy selection |
| `q` | Exit copy mode |
| `v` | Start selection |
| `y` | Copy selection |
| Arrow keys | Navigate |
| `Page Up/Down` | Scroll |

### Pane Management

| Binding | Description |
|---------|-------------|
| `Ctrl+b, %` | Split vertically |
| `Ctrl+b, "` | Split horizontally |
| `Ctrl+b, o` | Switch to next pane |
| `Ctrl+b, ;` | Switch to previous pane |
| `Ctrl+b, {` | Swap with previous pane |
| `Ctrl+b, }` | Swap with next pane |
| `Ctrl+b, Ctrl+Arrow` | Resize pane |
| `Ctrl+b, z` | Toggle zoom (fullscreen pane) |
| `Ctrl+b, x` | Kill current pane |
| `Ctrl+b, q` | Show pane numbers |

---

## General Terminal Shortcuts

### Bash/Readline Shortcuts

| Shortcut | Description |
|----------|-------------|
| `Ctrl+a` | Move to beginning of line |
| `Ctrl+e` | Move to end of line |
| `Ctrl+b` | Move back one character |
| `Ctrl+f` | Move forward one character |
| `Alt+b` | Move back one word |
| `Alt+f` | Move forward one word |
| `Ctrl+u` | Delete to beginning of line |
| `Ctrl+k` | Delete to end of line |
| `Ctrl+w` | Delete word before cursor |
| `Alt+d` | Delete word after cursor |
| `Ctrl+y` | Paste (yank) |
| `Ctrl+l` | Clear screen |
| `Ctrl+c` | Cancel current command |
| `Ctrl+d` | Exit shell / EOF |
| `Ctrl+r` | Search history (reverse) |
| `Ctrl+s` | Pause output (unpause with Ctrl+q) |
| `Ctrl+z` | Suspend process (resume with `fg`) |
| `Alt+.` | Insert last argument of previous command |
| `Alt+*` | Expand glob pattern |
| `Tab` | Auto-complete |
| `Ctrl+_` | Undo |

### History Navigation

| Shortcut | Description |
|----------|-------------|
| `↑` / `↓` | Navigate history |
| `Ctrl+r` | Reverse search history |
| `Ctrl+s` | Forward search history |
| `!!` | Repeat last command |
| `!<n>` | Execute command number n from history |
| `!<string>` | Execute most recent command starting with string |
| `!$` | Last argument of previous command |
| `!*` | All arguments of previous command |
| `Alt+.` | Insert last argument |

### Job Control

| Command | Description |
|---------|-------------|
| `jobs` | List background jobs |
| `fg` | Bring job to foreground |
| `fg %n` | Bring job n to foreground |
| `bg` | Resume suspended job in background |
| `bg %n` | Resume job n in background |
| `kill %n` | Kill job n |
| `Ctrl+z` | Suspend current job |
| `Ctrl+c` | Terminate current job |
| `Ctrl+d` | Send EOF |

### File Operations

| Command | Description |
|---------|-------------|
| `ls -la` | List all files (including hidden) |
| `ls -lh` | List with human-readable sizes |
| `ls -lt` | List sorted by time |
| `ls -ltr` | List sorted by time (reverse) |
| `tree` | Show directory tree |
| `find . -name "*.txt"` | Find files by name |
| `find . -type f -mtime -7` | Find files modified in last 7 days |
| `du -sh *` | Show directory sizes |
| `df -h` | Show disk usage |
| `stat <file>` | Show file details |

### Text Processing

| Command | Description |
|---------|-------------|
| `cat <file>` | Display file |
| `less <file>` | View file (scrollable) |
| `head -n 20 <file>` | Show first 20 lines |
| `tail -n 20 <file>` | Show last 20 lines |
| `tail -f <file>` | Follow file (watch updates) |
| `grep "pattern" <file>` | Search for pattern |
| `grep -r "pattern" .` | Recursive search |
| `grep -i "pattern" <file>` | Case-insensitive search |
| `sed 's/old/new/g' <file>` | Replace text |
| `awk '{print $1}' <file>` | Print first column |
| `sort <file>` | Sort lines |
| `uniq <file>` | Remove duplicate lines |
| `wc -l <file>` | Count lines |
| `cut -d',' -f1 <file>` | Cut by delimiter |

### Process Management

| Command | Description |
|---------|-------------|
| `ps aux` | List all processes |
| `ps aux \| grep <name>` | Find process by name |
| `top` | Interactive process viewer |
| `htop` | Enhanced process viewer |
| `kill <pid>` | Kill process |
| `kill -9 <pid>` | Force kill process |
| `killall <name>` | Kill all processes by name |
| `pkill <pattern>` | Kill processes by pattern |
| `pgrep <pattern>` | Find PIDs by pattern |
| `nohup <command> &` | Run command immune to hangups |
| `disown` | Remove job from shell's job table |

### Network

| Command | Description |
|---------|-------------|
| `netstat -tulpn` | Show network connections |
| `ss -tulpn` | Modern netstat alternative |
| `lsof -i :8080` | Show what's using port 8080 |
| `curl <url>` | Download/request URL |
| `wget <url>` | Download file |
| `ping <host>` | Ping host |
| `traceroute <host>` | Trace route to host |
| `dig <domain>` | DNS lookup |
| `nslookup <domain>` | DNS lookup (alternative) |

### System Info

| Command | Description |
|---------|-------------|
| `uname -a` | System information |
| `uptime` | System uptime |
| `free -h` | Memory usage |
| `df -h` | Disk space |
| `du -sh <dir>` | Directory size |
| `whoami` | Current user |
| `id` | User and group IDs |
| `env` | Environment variables |
| `history` | Command history |
| `date` | Current date/time |

### Useful Tips

- **Use `&&`** to chain commands: `cmd1 && cmd2` (runs cmd2 only if cmd1 succeeds)
- **Use `\|\|`** for fallback: `cmd1 \|\| cmd2` (runs cmd2 only if cmd1 fails)
- **Use `;`** to run sequentially: `cmd1; cmd2` (runs both regardless)
- **Use `&`** to run in background: `cmd &`
- **Use `()`** for subshell: `(cd /tmp && ls)`
- **Use `{}`** for brace expansion: `mkdir -p dir{1,2,3}`
- **Use `*`** for globbing: `ls *.txt`
- **Use `?`** for single character: `ls file?.txt`
- **Use `~`** for home directory: `cd ~`
- **Use `-`** for previous directory: `cd -`
- **Use `!!`** to repeat last command: `sudo !!`
- **Use `!$`** for last argument: `mkdir dir && cd !$`

---

## Quick Reference

### Most Common Screen Commands
```bash
screen -S demo      # Start named session
Ctrl+a, d           # Detach
screen -ls          # List sessions
screen -r demo      # Reattach
```

### Most Common Tmux Commands
```bash
tmux new -s demo    # Start named session
Ctrl+b, d           # Detach
tmux ls             # List sessions
tmux attach -t demo # Reattach
```

---

For more details, see [README.md](./README.md)
