# Starship Prompt

A clean, fast shell prompt using [Starship](https://starship.rs/). Configured to be readable without nerd fonts.

## What It Does

- Shows `user@host` (always visible, not just on SSH)
- Shows the current directory with smart truncation (3 levels from repo root)
- Shows the git branch and status (`*` modified, `+` staged, `?` untracked, `⇡/⇣` ahead/behind)
- Shows Docker context, Python env, and Node.js version when active
- Shows command duration for slow commands (>2s)
- Two-line prompt: context on line 1, `$`/`#` on line 2

## Installation

```bash
# Install Starship itself (if not already installed)
curl -sS https://starship.rs/install.sh | sh

# Install this config (via al CLI)
cd shell/aliases
./al starship install

# Or copy manually
cp shell/starship/starship.toml ~/.config/starship.toml

# Activate (add to ~/.bashrc if not already there)
eval "$(starship init bash)"
```

## Files

| File | Purpose |
|---|---|
| `starship.toml` | Prompt configuration — copy to `~/.config/starship.toml` |

## Customization

Edit `starship.toml` to enable or disable modules. The full module reference is at [starship.rs/config](https://starship.rs/config/).

The current config intentionally avoids nerd-font glyphs so it works in any terminal without patched fonts.
