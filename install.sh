#!/bin/bash

# ============================================================
#  Sarok Area — Bootstrap Installer
#  Usage: curl -fsSL https://raw.githubusercontent.com/sarok-exe/sarok-area/main/install.sh | bash
# ============================================================

set -euo pipefail

REPO_URL="https://github.com/sarok-exe/sarok-area.git"
INSTALL_DIR="$HOME/sarok-area"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
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

# Clone or update
if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "${GREEN}${BOLD}Directory exists. Updating...${NC}"
    cd "$INSTALL_DIR"
    git fetch origin main
    git reset --hard origin/main
else
    echo -e "${GREEN}${BOLD}Cloning repository...${NC}"
    rm -rf "$INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Verify setup.sh exists
if [ ! -f "setup.sh" ]; then
    echo -e "${RED}${BOLD}setup.sh not found after clone/pull.${NC}"
    echo "Repo contents:"
    ls -la
    exit 1
fi

# Run setup
echo ""
chmod +x setup.sh
bash setup.sh
