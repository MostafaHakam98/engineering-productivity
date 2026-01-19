#!/bin/bash
# Enhanced setup script for bash aliases
# Supports multiple installation methods for instant application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.bashrc.d"
BASHRC_FILE="$HOME/.bashrc"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation method
INSTALL_METHOD="${1:-copy}"

# Load order definition (shared across all methods)
LOAD_ORDER=(
    "00:core:core.sh"
    "10:navigation:navigation.sh"
    "20:core:colors.sh"
    "30:core:ls.sh"
    "40:tools:tools.sh"
    "50:git:git.sh"
    "60:docker:docker.sh"
    "70:prompt:prompt.sh"
    "80:optional:fzf.sh"
    "90:optional:nvm.sh"
    "95:optional:atuin.sh"
    "99:core:path.sh"
)

# Old files from previous structure
OLD_FILES=(
    "00-core.sh" "10-navigation.sh" "20-colors.sh" "30-ls.sh"
    "40-tools.sh" "50-git.sh" "60-docker.sh" "70-prompt.sh"
    "80-fzf.sh" "90-nvm.sh" "95-atuin.sh" "99-path.sh"
)

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}     ${GREEN}Bash Aliases Setup${NC}                              ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate method
if [[ ! "$INSTALL_METHOD" =~ ^(copy|symlink|direct)$ ]]; then
    echo -e "${RED}❌ Invalid method: $INSTALL_METHOD${NC}"
    echo "Usage: $0 [copy|symlink|direct]"
    exit 1
fi

echo -e "${BLUE}Method: ${GREEN}$INSTALL_METHOD${NC} | ${BLUE}Source: ${GREEN}$SCRIPT_DIR${NC}"
echo ""

# Ensure bashrc.d sourcing
ensure_bashrc_sourcing() {
    local source_code='if [ -d ~/.bashrc.d ]; then
  for file in ~/.bashrc.d/*.sh; do
    [ -r "$file" ] && source "$file"
  done
  unset file
fi'

    if ! grep -q "bashrc.d" "$BASHRC_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  ~/.bashrc doesn't source ~/.bashrc.d/${NC}"
        if [[ -t 0 ]]; then
            # Only prompt if stdin is a terminal
            read -p "Add it automatically? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo "" >> "$BASHRC_FILE"
                echo "# Source bashrc.d files" >> "$BASHRC_FILE"
                echo "$source_code" >> "$BASHRC_FILE"
                echo -e "${GREEN}✅ Added to ~/.bashrc${NC}"
            fi
        else
            # Non-interactive: auto-add
            echo "" >> "$BASHRC_FILE"
            echo "# Source bashrc.d files" >> "$BASHRC_FILE"
            echo "$source_code" >> "$BASHRC_FILE"
            echo -e "${GREEN}✅ Added to ~/.bashrc${NC}"
        fi
    else
        echo -e "${GREEN}✅ ~/.bashrc already sources ~/.bashrc.d/${NC}"
    fi
}

# Cleanup old files
cleanup_old_files() {
    local new_names=()
    for entry in "${LOAD_ORDER[@]}"; do
        IFS=':' read -r number category filename <<< "$entry"
        new_names+=("${number}-${filename}")
    done

    echo -e "${BLUE}Cleaning up old files...${NC}"
    local removed=0
    
    # Handle case where directory doesn't exist or is empty
    if [[ ! -d "$TARGET_DIR" ]] || [[ -z "$(ls -A "$TARGET_DIR"/*.sh 2>/dev/null)" ]]; then
        echo -e "${GREEN}  No files to remove${NC}"
        return 0
    fi
    
    for old_file in "$TARGET_DIR"/*.sh; do
        [[ ! -f "$old_file" && ! -L "$old_file" ]] && continue
        
        local basename="$(basename "$old_file")"
        local should_remove=false
        
        # Check if old numbered file
        for old_name in "${OLD_FILES[@]}"; do
            [[ "$basename" == "$old_name" ]] && should_remove=true && break
        done
        
        # Check if new numbered file (will be replaced)
        for new_name in "${new_names[@]}"; do
            [[ "$basename" == "$new_name" ]] && should_remove=true && break
        done
        
        # Check if matches numbered pattern
        if [[ "$basename" =~ ^[0-9]{2}-.*\.sh$ ]]; then
            local base="${basename#*-}"
            for new_name in "${new_names[@]}"; do
                [[ "$new_name" =~ ^[0-9]{2}-${base}$ ]] && should_remove=true && break
            done
        fi
        
        if [[ "$should_remove" == true ]]; then
            if rm -v "$old_file" 2>/dev/null; then
                removed=$((removed + 1))
            fi
        else
            echo -e "${YELLOW}  Keeping: $basename${NC}"
        fi
    done
    
    [[ $removed -eq 0 ]] && echo -e "${GREEN}  No files to remove${NC}"
}

# Install via copy
install_copy() {
    echo -e "${BLUE}📋 Installing via copy...${NC}"
    mkdir -p "$TARGET_DIR"
    cleanup_old_files
    
    echo ""
    echo -e "${BLUE}Copying files...${NC}"
    local copied=0
    for entry in "${LOAD_ORDER[@]}"; do
        IFS=':' read -r number category filename <<< "$entry" || continue
        src="$SCRIPT_DIR/$category/$filename"
        if [[ -f "$src" ]]; then
            target="$TARGET_DIR/${number}-${filename}"
            if cp "$src" "$target" 2>/dev/null; then
                chmod +x "$target" 2>/dev/null || true
                echo "  ✓ ${number}-${filename}"
                copied=$((copied + 1))
            else
                echo -e "${RED}  ✗ Failed: ${number}-${filename}${NC}"
            fi
        else
            echo -e "${YELLOW}  ⚠ Missing: $category/$filename${NC}"
        fi
    done
    echo -e "${GREEN}  Copied $copied/${#LOAD_ORDER[@]} files${NC}"
    
    ensure_bashrc_sourcing
}

# Install via symlink
install_symlink() {
    echo -e "${BLUE}🔗 Installing via symlink...${NC}"
    mkdir -p "$TARGET_DIR"
    cleanup_old_files
    
    echo ""
    echo -e "${BLUE}Creating symlinks...${NC}"
    for entry in "${LOAD_ORDER[@]}"; do
        IFS=':' read -r number category filename <<< "$entry"
        src="$SCRIPT_DIR/$category/$filename"
        [[ -f "$src" ]] || continue
        target="$TARGET_DIR/${number}-${filename}"
        ln -sv "$src" "$target"
    done
    
    ensure_bashrc_sourcing
}

# Install via direct sourcing
install_direct() {
    echo -e "${BLUE}⚡ Installing via direct sourcing...${NC}"
    echo -e "${YELLOW}Updates are instant - no copying needed!${NC}"
    echo ""
    
    local loader="$SCRIPT_DIR/loader.sh"
    local source_line="[ -f \"$loader\" ] && source \"$loader\""
    
    if grep -qF "$loader" "$BASHRC_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ Already configured${NC}"
    else
        read -p "Add to ~/.bashrc? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$BASHRC_FILE"
            echo "# Source aliases directly from repository" >> "$BASHRC_FILE"
            echo "$source_line" >> "$BASHRC_FILE"
            echo -e "${GREEN}✅ Added${NC}"
        else
            echo -e "${YELLOW}Add manually:${NC}"
            echo "$source_line"
        fi
    fi
}

# Main
case "$INSTALL_METHOD" in
    copy) install_copy ;;
    symlink) install_symlink ;;
    direct) install_direct ;;
esac

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                    ${GREEN}✅ Complete!${NC}                      ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$INSTALL_METHOD" == "direct" ]]; then
    echo -e "${BLUE}Run: ${GREEN}source $SCRIPT_DIR/loader.sh${NC} (or restart terminal)"
else
    echo -e "${BLUE}Run: ${GREEN}source ~/.bashrc${NC} (or restart terminal)"
fi

echo ""
echo -e "${BLUE}See README.md for documentation${NC}"
