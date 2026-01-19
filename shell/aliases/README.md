# Bash Aliases Setup

This directory contains modular bash alias files ready to be used in `~/.bashrc.d/`.

## Quick Setup

To use these aliases, copy them to your `~/.bashrc.d/` directory:

```bash
# Create the directory if it doesn't exist
mkdir -p ~/.bashrc.d

# Copy all alias files
cp Aliases/*.sh ~/.bashrc.d/

# Make sure they're executable
chmod +x ~/.bashrc.d/*.sh
```

Then ensure your `~/.bashrc` sources files from `~/.bashrc.d/`:

```bash
# Add this to your ~/.bashrc if not already present
if [ -d ~/.bashrc.d ]; then
  for file in ~/.bashrc.d/*.sh; do
    [ -r "$file" ] && source "$file"
  done
  unset file
fi
```

## File Organization

Files are numbered to control load order:
- `00-core.sh` - Core bash behavior and history settings
- `10-navigation.sh` - Navigation aliases (cd, .., etc.)
- `20-colors.sh` - Colors and dircolors configuration
- `30-ls.sh` - ls command aliases
- `40-tools.sh` - General tool aliases (clear, bat, vpn, etc.)
- `50-git.sh` - **Git aliases and helpers**
- `60-docker.sh` - **Docker aliases and helpers**
- `70-prompt.sh` - Shell prompt configuration
- `80-fzf.sh` - Fuzzy finder configuration and helpers
- `90-nvm.sh` - Node Version Manager
- `95-atuin.sh` - Atuin shell history
- `99-path.sh` - PATH modifications

## Git Aliases

### Basic Shortcuts
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

### Useful Functions
- `gcbp <branch>` - Create branch and push upstream
- `gcam <message>` - Commit all changes with message
- `gcamp <message>` - Commit all and push
- `gup` - Update and rebase current branch
- `gwhat <file>` - Show what changed in a file
- `ghist <file>` - Show file history

### Advanced
- `gla` - Pretty graph log
- `gpf` - Push with force-with-lease (safer than force)
- `gri` - Interactive rebase
- `guncommit` - Undo last commit (keep changes)

## Docker Aliases

### Basic Shortcuts
- `d` - docker
- `dc` - docker compose
- `dps` - docker ps
- `di` - docker images
- `dex` - docker exec -it

### Docker Compose
- `dcu` - docker compose up
- `dcud` - docker compose up -d
- `dcd` - docker compose down
- `dclf` - docker compose logs -f
- `dcp` - docker compose ps
- `dcb` - docker compose build

### Useful Functions
- `dbash <container>` - Enter container with bash
- `dsh <container>` - Enter container with sh
- `dcex <service>` - Exec into compose service
- `dcrun <service> <cmd>` - Run one-off command
- `dclean` - Clean up all Docker resources
- `dip <container>` - Show container IP
- `dcpfrom <container> <path>` - Copy from container
- `dcpto <path> <container> <path>` - Copy to container

### System Management
- `dsysdf` - Show Docker disk usage
- `dsysprune` - Clean up unused resources
- `dvolprune` - Remove unused volumes

## Tips

1. **Customize as needed**: Feel free to modify these aliases to match your workflow
2. **Add your own**: Create new numbered files (e.g., `45-custom.sh`) for your personal aliases
3. **Test before use**: Review the aliases to ensure they don't conflict with your existing setup
4. **Backup first**: Always backup your existing `~/.bashrc` and `~/.bashrc.d/` before copying
