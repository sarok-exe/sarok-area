#!/bin/bash

# ============================================================
#  Sarok Area — Bootstrap Installer
#  Usage: curl -fsSL https://raw.githubusercontent.com/sarok-exe/sarok-area/main/install.sh | bash
# ============================================================

REPO_URL="https://github.com/sarok-exe/sarok-area.git"
INSTALL_DIR="$HOME/sarok-area"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

echo ""
echo -e "${BOLD}Sarok Area — Bootstrapping...${NC}"
echo ""

# Check git
if ! command -v git &>/dev/null; then
    echo -e "${RED}${BOLD}git is required but not found.${NC}"
    echo "Install it first: sudo pacman -S git"
    exit 1
fi

# Handle existing directory
if [ -d "$INSTALL_DIR" ]; then
    if [ -d "$INSTALL_DIR/.git" ]; then
        echo -e "${GREEN}${BOLD}Updating existing repo...${NC}"
        cd "$INSTALL_DIR"
        git fetch origin main && git reset --hard origin/main
    else
        echo -e "${YELLOW}${BOLD}Directory exists but is not a git repo. Re-cloning...${NC}"
        rm -rf "$INSTALL_DIR"
        git clone "$REPO_URL" "$INSTALL_DIR"
        cd "$INSTALL_DIR"
    fi
else
    echo -e "${GREEN}${BOLD}Cloning repository...${NC}"
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Verify setup.sh exists
if [ ! -f "setup.sh" ]; then
    echo -e "${RED}${BOLD}setup.sh not found! Current directory: $(pwd)${NC}"
    echo "Contents:"
    ls -la
    exit 1
fi

# Run setup
echo ""
chmod +x setup.sh
bash setup.sh
