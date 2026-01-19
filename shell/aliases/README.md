# Bash Aliases & Shell Configuration

Modular, category-organized bash aliases for Git, Docker, navigation, and more. Designed for instant application with multiple installation methods.

## 🚀 Quick Start

### Instant Installation (Recommended)

```bash
cd shell/aliases
./setup.sh
```

This will:
- Copy aliases to `~/.bashrc.d/`
- Configure `~/.bashrc` to source them
- Make everything ready to use

### Alternative Installation Methods

```bash
# Method 1: Copy (default, recommended for most users)
./setup.sh copy

# Method 2: Symlink (updates reflect automatically)
./setup.sh symlink

# Method 3: Direct sourcing (instant updates, no copying)
./setup.sh direct
```

### Instant Application

After installation, either:
1. **Restart your terminal**, or
2. **Run**: `source ~/.bashrc`

For direct sourcing method, you can also:
```bash
source shell/aliases/loader.sh
```

## 📁 Structure

Aliases are organized by category for easy navigation and maintenance:

```
shell/aliases/
├── core/           # Core bash settings (history, colors, ls, path)
├── navigation/     # Navigation aliases (cd, .., etc.)
├── tools/          # General tool aliases (clear, bat, etc.)
├── git/            # Git aliases and helpers
├── docker/         # Docker aliases and helpers
├── prompt/         # Shell prompt configuration
├── optional/       # Optional tools (fzf, nvm, atuin)
├── loader.sh       # Direct sourcing loader
└── setup.sh        # Installation script
```

## 📋 Installation Methods

### 1. Copy Method (Default)
- **Best for**: Most users, stable setup
- **How it works**: Copies files to `~/.bashrc.d/`
- **Updates**: Re-run setup script to update
- **Pros**: Independent of repository location
- **Cons**: Requires re-running setup for updates

### 2. Symlink Method
- **Best for**: Users who want automatic updates
- **How it works**: Creates symlinks to repository files
- **Updates**: Automatic when repository is updated
- **Pros**: Updates reflect automatically
- **Cons**: Repository must remain in same location

### 3. Direct Sourcing Method
- **Best for**: Developers, instant updates
- **How it works**: Sources directly from repository via `loader.sh`
- **Updates**: Instant, no setup needed
- **Pros**: Instant updates, no copying
- **Cons**: Repository must be accessible

## 🗂️ Category Details

### `core/` - Core Bash Settings
Essential bash configuration:
- `core.sh` - History settings, shell options
- `colors.sh` - Color configuration
- `ls.sh` - Enhanced ls aliases
- `path.sh` - PATH modifications

### `navigation/` - Navigation
Quick navigation aliases:
- `..` - Go up one directory
- `...` - Go up two directories
- `....` - Go up three directories
- `.....` - Go up four directories

### `tools/` - General Tools
Common tool shortcuts:
- `c`, `cls` - Clear screen
- `mkdirp` - mkdir -p
- `rmf` - rm -rf
- `bat` - batcat alias
- `alert` - Notification for long commands

### `git/` - Git Aliases
Comprehensive Git shortcuts and helpers.

**Basic Shortcuts:**
- `g` - git
- `ga` - git add
- `gaa` - git add --all
- `gc` - git commit
- `gcm` - git commit -m
- `gco` - git checkout
- `gcb` - git checkout -b
- `gp` - git push
- `gpl` - git pull
- `gs` - git status
- `gl` - git log

**Useful Functions:**
- `gcbp <branch>` - Create branch and push upstream
- `gcam <message>` - Commit all changes with message
- `gcamp <message>` - Commit all and push
- `gup` - Update and rebase current branch
- `gwhat <file>` - Show what changed in a file
- `ghist <file>` - Show file history

**Advanced:**
- `gla` - Pretty graph log
- `gpf` - Push with force-with-lease (safer than force)
- `gri` - Interactive rebase
- `guncommit` - Undo last commit (keep changes)

### `docker/` - Docker Aliases
Docker and Docker Compose shortcuts.

**Basic Shortcuts:**
- `d` - docker
- `dc` - docker compose
- `dps` - docker ps
- `di` - docker images
- `dex` - docker exec -it

**Docker Compose:**
- `dcu` - docker compose up
- `dcud` - docker compose up -d
- `dcd` - docker compose down
- `dclf` - docker compose logs -f
- `dcp` - docker compose ps
- `dcb` - docker compose build

**Useful Functions:**
- `dbash <container>` - Enter container with bash
- `dsh <container>` - Enter container with sh
- `dcex <service>` - Exec into compose service
- `dcrun <service> <cmd>` - Run one-off command
- `dclean` - Clean up all Docker resources
- `dip <container>` - Show container IP

### `prompt/` - Prompt Configuration
Customizable shell prompt with color support.

### `optional/` - Optional Tools
Tools that may not be installed on all systems:
- `fzf.sh` - Fuzzy finder configuration
- `nvm.sh` - Node Version Manager
- `atuin.sh` - Atuin shell history

These are safe to use even if the tools aren't installed.

## 🔧 Customization

### Adding Your Own Aliases

1. **Create a custom file:**
   ```bash
   # Add to any category directory, or create a new one
   echo "# My custom aliases" > shell/aliases/custom/my-aliases.sh
   ```

2. **Or edit existing files:**
   ```bash
   # Edit any .sh file in the category directories
   nano shell/aliases/tools/tools.sh
   ```

3. **Re-run setup** (if using copy method) or **reload** (if using direct/symlink):
   ```bash
   # For copy method
   ./setup.sh
   
   # For direct/symlink method
   source ~/.bashrc
   ```

### Selective Loading

To load only specific categories, you can manually source:

```bash
# Load only git aliases
source shell/aliases/git/git.sh

# Load only docker aliases
source shell/aliases/docker/docker.sh
```

## 📖 Quick Reference

See [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) for a complete list of all aliases.

## 🛠️ Troubleshooting

### Aliases not working?

1. **Check if ~/.bashrc sources ~/.bashrc.d/:**
   ```bash
   grep "bashrc.d" ~/.bashrc
   ```

2. **Reload your shell:**
   ```bash
   source ~/.bashrc
   ```

3. **Check file permissions:**
   ```bash
   ls -la ~/.bashrc.d/
   ```

4. **Verify installation:**
   ```bash
   cd shell/aliases
   ./setup.sh
   ```

### Conflicts with existing aliases?

1. **Check what's already defined:**
   ```bash
   alias | grep <alias-name>
   ```

2. **Edit the conflicting file** in the appropriate category directory
3. **Re-run setup** or **reload**

## 💡 Tips

1. **Start with defaults**: The default setup works great for most users
2. **Use direct sourcing for development**: If you're actively editing aliases, use `./setup.sh direct`
3. **Customize gradually**: Add your own aliases as you discover needs
4. **Version control your customizations**: Keep your custom aliases in version control
5. **Test before committing**: Test new aliases before sharing

## 🔄 Updating

### Copy Method
```bash
cd shell/aliases
git pull  # Update repository
./setup.sh  # Re-install
```

### Symlink/Direct Method
```bash
cd shell/aliases
git pull  # Updates are instant!
source ~/.bashrc  # Or restart terminal
```

## 📝 Best Practices

- **Keep it modular**: Each category in its own directory
- **Use descriptive names**: File names should indicate purpose
- **Document custom aliases**: Add comments for complex aliases
- **Test changes**: Verify aliases work before committing
- **Version control**: Track all changes in git

---

> **Remember**: Productivity aliases should reduce friction. If an alias doesn't help, remove or modify it!
