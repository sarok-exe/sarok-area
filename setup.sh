#!/bin/bash

# ============================================================
#  Sarok Area — Full Arch Linux Setup
# ============================================================

set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_SRC="$REPO_DIR/.config"
LOG_FILE="/tmp/sarok-setup-$(date +%Y%m%d-%H%M%S).log"
FAILURES=()

MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
DIM='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m'

TOTAL_STEPS=10
CURRENT_STEP=0

step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo ""
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BOLD}${MAGENTA}▶${NC} ${BOLD}$CURRENT_STEP/$TOTAL_STEPS:${NC} $1"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

ok()   { echo -e "    ${GREEN}✓${NC} $1"; log "[OK] $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; log "[WARN] $1"; }
fail() { echo -e "    ${RED}✗${NC} $1"; FAILURES+=("$1"); log "[FAIL] $1"; }

run() {
    local label="$1"
    shift
    echo -e "  ${DIM}  → $*${NC}"
    if "$@" 2>&1 | tee -a "$LOG_FILE"; then
        ok "$label"
    else
        fail "$label"
    fi
}

run_bg() {
    local label="$1"
    shift
    echo -e "  ${DIM}  → $*${NC}"
    if "$@" >> "$LOG_FILE" 2>&1; then
        ok "$label"
    else
        fail "$label"
    fi
}

log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"; }

clear
echo ""
echo -e "  ${MAGENTA}  ╔═══╗╔═══╗╔═══╗${NC}"
echo -e "  ${MAGENTA}  ║   ║║   ║║   ║${NC}"
echo -e "  ${MAGENTA}  ║   ║║   ║║   ║${NC}"
echo -e "  ${MAGENTA}  ╚═══╝╚═══╝╚═══╝${NC}"
echo ""
echo -e "  ${BOLD}  SAROK AREA${NC} — Arch Setup"
echo ""
echo -e "  ${DIM}  Log: $LOG_FILE${NC}"
echo ""

if ! command -v pacman &>/dev/null; then
    echo -e "  ${RED}Requires Arch Linux (pacman not found)${NC}"
    exit 1
fi

if [ "$EUID" -eq 0 ]; then
    echo -e "  ${RED}Do not run as root${NC}"
    exit 1
fi

# Ask for password once at start
echo ""
echo -e "  ${CYAN}→ Getting sudo password...${NC}"
sudo -v
echo -e "  ${GREEN}✓ Password cached${NC}"

# ============================================================
#  1. Deploy System Configs (etc/)
# ============================================================
step "Deploy system configs"

if [ -d "$REPO_DIR/etc" ]; then
    run "Copy etc/" sudo cp -rf "$REPO_DIR/etc/"* /etc/
fi

# ============================================================
#  2. Base Build Tools
# ============================================================
step "Base build tools"
run "Install base-devel git curl jq" sudo pacman -S --needed --noconfirm base-devel git curl jq

# ============================================================
#  3. yay (AUR Helper)
# ============================================================
step "AUR helper (yay)"

if command -v yay &>/dev/null; then
    ok "yay already installed"
else
    if git clone https://aur.archlinux.org/yay.git /tmp/yay >>"$LOG_FILE" 2>&1; then
        if (cd /tmp/yay && makepkg -si --noconfirm >>"$LOG_FILE" 2>&1); then
            ok "yay installed"
        else
            fail "yay build failed"
        fi
    else
        fail "yay clone failed"
    fi
    rm -rf /tmp/yay
fi

# ============================================================
#  4. System Update
# ============================================================
step "System update"
run "pacman -Syu" sudo pacman -Syu --noconfirm

# ============================================================
#  5. Pacman Packages
# ============================================================
step "Pacman packages"

PKGS=(
    # Core System & Window Manager
    niri xorg-xwayland wayland-protocols qt6-wayland
    # Terminal & Shell tools
    kitty fish starship zoxide thefuck neovim
    yazi fastfetch wiremix
    # System Monitoring & Utils
    btop cava dunst libqalculate brightnessctl pamixer pavucontrol
    networkmanager openssh rsync zip unzip nload htop
    # Bar & Notifications
    waybar swaync wlogout mako rofi
    # Media & Graphics
    mpv imv feh drawing inkscape flameshot
    # Fonts
    ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd
    ttf-nerd-fonts-symbols-mono noto-fonts-cjk
    # Themes & Icons
    adw-gtk-theme papirus-icon-theme gnome-tweaks
    # Build tools
    cmake ninja slurp grim tesseract tesseract-data-eng wl-clipboard
    # Development
    python python-pip base-devel
    # MPD Music Server
    mpd mpc
    # GPU tools
    vulkan-tools
    # Power management
    tlp powertop
    # OpenCode dependencies
    nodejs npm
)

run "Pacman install" sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# ============================================================
#  5. AUR Packages
# ============================================================
step "AUR packages"

if command -v yay &>/dev/null; then
    AUR_PKGS=(
        opencode-bin
        keypunch
        impala
        rmpc
        vesktop
        awww
        matugen
        gpu-screen-recorder
        gpu-screen-recorder-gtk
    )
    run "AUR install" yay -S --needed --noconfirm "${AUR_PKGS[@]}"
else
    fail "yay not available, skipping AUR packages"
fi

# ============================================================
#  6. Ollama (AI)
# ============================================================
step "Ollama AI"

if command -v ollama &>/dev/null; then
    ok "Ollama already installed"
else
    if curl -fsSL https://ollama.com/install.sh | sh >> "$LOG_FILE" 2>&1; then
        ok "Ollama installed"
    else
        fail "Ollama install failed"
    fi
fi

# ============================================================
#  6. Python tools (pipx)
# ============================================================
step "Python tools"

run "Install pipx" sudo pacman -S --needed --noconfirm python-pipx
if command -v pipx &>/dev/null; then
    pipx ensurepath >> "$LOG_FILE" 2>&1 || true
    ok "pipx configured"
else
    warn "pipx not available"
fi

# ============================================================
#  2. Base Build Tools
# ============================================================
step "Deploy dotfiles"

mkdir -p "$HOME/.config"

if [ -d "$DOT_SRC" ]; then
    for item in "$DOT_SRC"/*; do
        name="$(basename "$item")"
        target="$HOME/.config/$name"

        if [ -e "$target" ] && [ ! -L "$target" ]; then
            mv "$target" "$target.bak-$(date +%s)"
            log "[Dotfiles] Backed up: $target"
        fi

        [ -L "$target" ] && rm "$target"
        ln -sf "$item" "$target"
    done
    ok "All dotfiles linked"
else
    fail "Source directory not found: $DOT_SRC"
fi

# Copy scripts to ~/Documents/Scripts
SCRIPTS_DIR="$HOME/Documents/Scripts"
if [ -d "$DOT_SRC/scripts" ]; then
    mkdir -p "$SCRIPTS_DIR"
    cp -rf "$DOT_SRC/scripts/"* "$SCRIPTS_DIR/"
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true
    ok "Scripts copied to ~/Documents/Scripts"
fi

# ============================================================
#  11. Shell & Services
# ============================================================
step "Shell & services"

# Set Fish as default shell
FISH_PATH="$(command -v fish 2>/dev/null || true)"
if [ -n "$FISH_PATH" ]; then
    if [ "$SHELL" != "$FISH_PATH" ]; then
        if chsh -s "$FISH_PATH" >>"$LOG_FILE" 2>&1; then
            ok "Fish set as default shell"
        else
            fail "Failed to set Fish as default shell"
        fi
    else
        ok "Fish already default shell"
    fi
else
    warn "Fish not installed"
fi

# Configure Starship prompt in fish config
if command -v fish &>/dev/null && [ ! -f "$HOME/.config/fish/config.fish" ]; then
    mkdir -p "$HOME/.config/fish"
    echo 'starship init fish | source' >> "$HOME/.config/fish/config.fish"
    echo 'zoxide init fish | source' >> "$HOME/.config/fish/config.fish"
    ok "Fish prompt configured"
fi

# Enable essential services
for svc in iwd.service pipewire.service pipewire-pulse.service; do
    run "Enable $svc" sudo systemctl enable --now "$svc" 2>/dev/null || true
done

# Disable unnecessary startup services
run "Disable MPD auto-start" systemctl --user disable mpd 2>/dev/null || true
run "Disable quickshell" systemctl --user disable quickshell 2>/dev/null || true

# ============================================================
#  12. Summary
# ============================================================
echo ""
echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ ${#FAILURES[@]} -eq 0 ]; then
    echo -e "  ${GREEN}✓ SETUP COMPLETE${NC}"
    echo ""
    echo -e "  ${GREEN}All $TOTAL_STEPS steps done!${NC}"
else
    echo -e "  ${YELLOW}⚠ SETUP FINISHED (${#FAILURES[@]} issues)${NC}"
    echo ""
    for f in "${FAILURES[@]}"; do
        echo -e "    ${RED}✗ $f${NC}"
    done
fi

echo ""
echo -e "  ${DIM}Log: $LOG_FILE${NC}"
echo ""
echo -e "  ${BOLD}Next:${NC}"
echo -e "    exec fish"
echo -e "    ollama pull llama3.2"
echo -e "    sudo reboot"
echo ""