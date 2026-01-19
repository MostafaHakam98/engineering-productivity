#!/bin/bash
# Enhanced setup script for bash aliases
# Supports multiple installation methods for instant application

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.bashrc.d"
BASHRC_FILE="$HOME/.bashrc"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation methods
METHOD_COPY="copy"
METHOD_SYMLINK="symlink"
METHOD_DIRECT="direct"

# Default method
INSTALL_METHOD="${1:-$METHOD_COPY}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}     ${GREEN}Bash Aliases Setup${NC}                              ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Validate installation method
if [[ ! "$INSTALL_METHOD" =~ ^($METHOD_COPY|$METHOD_SYMLINK|$METHOD_DIRECT)$ ]]; then
    echo -e "${RED}❌ Invalid installation method: $INSTALL_METHOD${NC}"
    echo ""
    echo "Usage: $0 [copy|symlink|direct]"
    echo ""
    echo "Methods:"
    echo "  copy     - Copy files to ~/.bashrc.d/ (default, recommended)"
    echo "  symlink  - Create symlinks to repository files"
    echo "  direct   - Source directly from repository (no copying)"
    exit 1
fi

echo -e "${BLUE}Installation method: ${GREEN}$INSTALL_METHOD${NC}"
echo -e "${BLUE}Source directory: ${GREEN}$SCRIPT_DIR${NC}"
echo ""

# Function to ensure bashrc.d sourcing
ensure_bashrc_sourcing() {
    local source_code="if [ -d ~/.bashrc.d ]; then
  for file in ~/.bashrc.d/*.sh; do
    [ -r \"\$file\" ] && source \"\$file\"
  done
  unset file
fi"

    if ! grep -q "bashrc.d" "$BASHRC_FILE" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Your ~/.bashrc doesn't source ~/.bashrc.d/${NC}"
        echo ""
        read -p "Would you like to add it automatically? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$BASHRC_FILE"
            echo "# Source bashrc.d files" >> "$BASHRC_FILE"
            echo "$source_code" >> "$BASHRC_FILE"
            echo -e "${GREEN}✅ Added to ~/.bashrc${NC}"
        else
            echo -e "${YELLOW}⚠️  You'll need to manually add the sourcing code to ~/.bashrc${NC}"
        fi
    else
        echo -e "${GREEN}✅ ~/.bashrc already sources ~/.bashrc.d/${NC}"
    fi
}

# Function to install via copy
install_copy() {
    echo -e "${BLUE}📋 Installing via copy method...${NC}"
    echo ""
    
    mkdir -p "$TARGET_DIR"
    
    # Build list of source files
    SOURCE_FILES=()
    for dir in core navigation tools git docker prompt optional; do
        dir_path="$SCRIPT_DIR/$dir"
        if [[ -d "$dir_path" ]]; then
            for file in "$dir_path"/*.sh; do
                if [[ -f "$file" ]]; then
                    SOURCE_FILES+=("$file")
                fi
            done
        fi
    done
    
    # Remove old files that are no longer in source
    echo -e "${BLUE}Cleaning up old files...${NC}"
    REMOVED_COUNT=0
    for old_file in "$TARGET_DIR"/*.sh; do
        if [[ -f "$old_file" ]]; then
            old_basename="$(basename "$old_file")"
            found=false
            for src_file in "${SOURCE_FILES[@]}"; do
                if [[ "$(basename "$src_file")" == "$old_basename" ]]; then
                    found=true
                    break
                fi
            done
            if [[ "$found" == false ]]; then
                rm -v "$old_file"
                ((REMOVED_COUNT++))
            fi
        fi
    done
    if [[ $REMOVED_COUNT -eq 0 ]]; then
        echo -e "${GREEN}  No old files to remove${NC}"
    fi
    
    # Copy files maintaining directory structure
    echo ""
    echo -e "${BLUE}Copying alias files...${NC}"
    for src_file in "${SOURCE_FILES[@]}"; do
        rel_path="${src_file#$SCRIPT_DIR/}"
        target_file="$TARGET_DIR/$(basename "$rel_path")"
        cp -v "$src_file" "$target_file"
        chmod +x "$target_file"
    done
    
    ensure_bashrc_sourcing
}

# Function to install via symlink
install_symlink() {
    echo -e "${BLUE}🔗 Installing via symlink method...${NC}"
    echo ""
    
    mkdir -p "$TARGET_DIR"
    
    # Create symlinks
    echo -e "${BLUE}Creating symlinks...${NC}"
    for dir in core navigation tools git docker prompt optional; do
        dir_path="$SCRIPT_DIR/$dir"
        if [[ -d "$dir_path" ]]; then
            for file in "$dir_path"/*.sh; do
                if [[ -f "$file" ]]; then
                    target_file="$TARGET_DIR/$(basename "$file")"
                    # Remove existing file/symlink
                    [[ -L "$target_file" || -f "$target_file" ]] && rm "$target_file"
                    ln -sv "$file" "$target_file"
                fi
            done
        fi
    done
    
    ensure_bashrc_sourcing
}

# Function to install via direct sourcing
install_direct() {
    echo -e "${BLUE}⚡ Installing via direct sourcing method...${NC}"
    echo ""
    echo -e "${YELLOW}This method sources aliases directly from the repository.${NC}"
    echo -e "${YELLOW}No files will be copied. Updates are instant!${NC}"
    echo ""
    
    local loader_path="$SCRIPT_DIR/loader.sh"
    local source_line="[ -f \"$loader_path\" ] && source \"$loader_path\""
    
    if grep -qF "$loader_path" "$BASHRC_FILE" 2>/dev/null; then
        echo -e "${GREEN}✅ Direct sourcing already configured in ~/.bashrc${NC}"
    else
        read -p "Add direct sourcing to ~/.bashrc? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "" >> "$BASHRC_FILE"
            echo "# Source aliases directly from repository" >> "$BASHRC_FILE"
            echo "$source_line" >> "$BASHRC_FILE"
            echo -e "${GREEN}✅ Added direct sourcing to ~/.bashrc${NC}"
        else
            echo -e "${YELLOW}⚠️  You can manually add this to ~/.bashrc:${NC}"
            echo ""
            echo "$source_line"
        fi
    fi
}

# Main installation logic
case "$INSTALL_METHOD" in
    "$METHOD_COPY")
        install_copy
        ;;
    "$METHOD_SYMLINK")
        install_symlink
        ;;
    "$METHOD_DIRECT")
        install_direct
        ;;
esac

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                    ${GREEN}✅ Setup Complete!${NC}                      ${GREEN}║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$INSTALL_METHOD" == "$METHOD_DIRECT" ]]; then
    echo -e "${BLUE}To use the aliases immediately, run:${NC}"
    echo -e "${GREEN}  source $SCRIPT_DIR/loader.sh${NC}"
    echo ""
    echo -e "${BLUE}Or restart your terminal.${NC}"
else
    echo -e "${BLUE}To use the aliases, either:${NC}"
    echo -e "${GREEN}  1. Restart your terminal, or${NC}"
    echo -e "${GREEN}  2. Run: source ~/.bashrc${NC}"
fi

echo ""
echo -e "${BLUE}See README.md for alias documentation.${NC}"
