# Quick Reference - All Aliases

Complete reference of all available aliases and functions.

## Navigation

| Alias | Command | Description |
|-------|---------|-------------|
| `..` | `cd ..` | Go up one directory |
| `...` | `cd ../..` | Go up two directories |
| `....` | `cd ../../..` | Go up three directories |
| `.....` | `cd ../../../..` | Go up four directories |

## Tools

| Alias | Command | Description |
|-------|---------|-------------|
| `c` | `clear` | Clear screen |
| `cls` | `clear` | Clear screen (alternative) |
| `mkdirp` | `mkdir -p` | Create directory with parents |
| `rmf` | `rm -rf` | Remove recursively |
| `bat` | `batcat` | Bat command |
| `vpn` | `sudo openfortivpn` | VPN connection |
| `alert` | function | Notification for long commands |

## Git

### Basic Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `g` | `git` | Git command |
| `ga` | `git add` | Stage files |
| `gaa` | `git add --all` | Stage all files |
| `gap` | `git add --patch` | Stage interactively |
| `gb` | `git branch` | List branches |
| `gc` | `git commit` | Commit changes |
| `gcm` | `git commit -m` | Commit with message |
| `gca` | `git commit --amend` | Amend last commit |
| `gcan` | `git commit --amend --no-edit` | Amend without editing |
| `gco` | `git checkout` | Checkout branch |
| `gcb` | `git checkout -b` | Create and checkout branch |
| `gd` | `git diff` | Show changes |
| `gds` | `git diff --staged` | Show staged changes |
| `gf` | `git fetch` | Fetch from remote |
| `gl` | `git log` | Show commit log |
| `gla` | `git log --all --graph --decorate --oneline` | Pretty graph log |
| `glp` | `git log --pretty=format:"..."` | Formatted log |
| `gp` | `git push` | Push to remote |
| `gpf` | `git push --force-with-lease` | Safe force push |
| `gpl` | `git pull` | Pull from remote |
| `gplr` | `git pull --rebase` | Pull with rebase |
| `gr` | `git rebase` | Rebase |
| `gri` | `git rebase -i` | Interactive rebase |
| `grc` | `git rebase --continue` | Continue rebase |
| `gra` | `git rebase --abort` | Abort rebase |
| `gs` | `git status` | Show status |
| `gss` | `git status --short` | Short status |
| `gsb` | `git status -sb` | Status with branch |
| `gst` | `git stash` | Stash changes |
| `gstp` | `git stash pop` | Pop stash |
| `gstl` | `git stash list` | List stashes |
| `gsw` | `git switch` | Switch branch |
| `gswc` | `git switch -c` | Create and switch branch |
| `gbr` | `git branch --show-current` | Show current branch |
| `gremote` | `git remote -v` | Show remotes |
| `gball` | `git branch -a` | List all branches |
| `gblame` | `git blame` | Show file blame |
| `gcount` | `git rev-list --count HEAD` | Count commits |
| `glast` | `git log -1 --stat` | Last commit with stats |
| `guncommit` | `git reset --soft HEAD~1` | Undo last commit |
| `guncommit-hard` | `git reset --hard HEAD~1` | Hard undo commit |
| `gclean-dry` | `git clean -n` | Dry run clean |
| `gclean` | `git clean -fd` | Clean untracked files |
| `gbclean` | `git branch --merged \| grep ...` | Clean merged branches |

### Functions

| Function | Usage | Description |
|---------|-------|-------------|
| `gcbp` | `gcbp <branch>` | Create branch and push upstream |
| `gcam` | `gcam <message>` | Commit all changes with message |
| `gcamp` | `gcamp <message>` | Commit all and push |
| `gup` | `gup` | Update and rebase current branch |
| `gwhat` | `gwhat <file>` | Show what changed in a file |
| `ghist` | `ghist <file>` | Show file history |

## Docker

### Basic Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Docker command |
| `dps` | `docker ps` | List running containers |
| `dpsa` | `docker ps -a` | List all containers |
| `dpa` | `docker ps -a` | List all containers (alt) |
| `di` | `docker images` | List images |
| `dex` | `docker exec -it` | Execute in container |
| `dstop` | `docker stop` | Stop container |
| `dstart` | `docker start` | Start container |
| `drm` | `docker rm` | Remove container |
| `drmi` | `docker rmi` | Remove image |
| `dlog` | `docker logs` | Show logs |
| `dlogf` | `docker logs -f` | Follow logs |
| `dtop` | `docker top` | Show container processes |

### Docker Compose

| Alias | Command | Description |
|-------|---------|-------------|
| `dc` | `docker compose` | Docker Compose command |
| `dcu` | `docker compose up` | Start services |
| `dcud` | `docker compose up -d` | Start in background |
| `dcd` | `docker compose down` | Stop services |
| `dcp` | `docker compose ps` | List services |
| `dcb` | `docker compose build` | Build services |
| `dcrb` | `docker compose up --build` | Rebuild and start |
| `dce` | `docker compose exec` | Execute in service |
| `dcr` | `docker compose run` | Run one-off command |
| `dcre` | `docker compose restart` | Restart services |
| `dcstop` | `docker compose stop` | Stop services |
| `dcstart` | `docker compose start` | Start services |
| `dcl` | `docker compose logs` | Show logs |
| `dclf` | `docker compose logs -f` | Follow logs |

### System Management

| Alias | Command | Description |
|-------|---------|-------------|
| `dsys` | `docker system` | Docker system command |
| `dsysdf` | `docker system df` | Show disk usage |
| `dsysprune` | `docker system prune` | Clean up unused resources |
| `dsysprunea` | `docker system prune -a` | Clean up all unused resources |
| `dvol` | `docker volume` | Volume command |
| `dvols` | `docker volume ls` | List volumes |
| `dnet` | `docker network` | Network command |
| `dnets` | `docker network ls` | List networks |
| `drmia` | `docker rmi $(docker images -q)` | Remove all images |

### Functions

| Function | Usage | Description |
|---------|-------|-------------|
| `dbash` | `dbash <container>` | Enter container with bash |
| `dsh` | `dsh <container>` | Enter container with sh |
| `dcex` | `dcex <service>` | Exec into compose service |
| `dcrun` | `dcrun <service> <cmd>` | Run one-off command in service |
| `dclean` | `dclean` | Clean up all Docker resources |
| `dip` | `dip <container>` | Show container IP |
| `dcpfrom` | `dcpfrom <container> <path>` | Copy from container |
| `dcpto` | `dcpto <path> <container> <path>` | Copy to container |

## Tips

- Use `alias` command to see all defined aliases
- Use `type <alias>` to see what an alias does
- Check individual `.sh` files for complete documentation
- Customize aliases to match your workflow

---

For detailed documentation, see [README.md](./README.md)
