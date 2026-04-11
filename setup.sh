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

# ============================================================
#  1. Base Build Tools
# ============================================================
step "Base build tools"
run "Install base-devel git" sudo pacman -S --needed --noconfirm base-devel git

# ============================================================
#  2. yay (AUR Helper)
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
#  3. Full System Update
# ============================================================
step "System update"
run "pacman -Syu" sudo pacman -Syu --noconfirm

# ============================================================
#  4. Pacman Packages
# ============================================================
step "Pacman packages"

PKGS=(
    # Core System & Window Manager
    niri xorg-xwayland wayland-protocols qt6-wayland
    # Terminal & Shell tools
    kitty starship zoxide thefuck neovim 
    yazi fastfetch wiremix 
    # System Monitoring & Utils
    btop cava dunst libqalculate brightnessctl pamixer
    networkmanager openssh rsync zip unzip nload htop
    # Bar & Notifications
    waybar swaync wlogout mako
    # Media & Graphics
    mpv imv feh drawing inkscape flameshot
    # Screen Recording
    obsidian wl-screenrec wayland-record
    # Fonts
    ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd
    ttf-nerd-fonts-symbols-mono noto-fonts-cjk
    # Themes & Icons
    adw-gtk-theme papirus-icon-theme
    # Build tools
    cmake ninja slurp grim tesseract tesseract-data-eng wl-clipboard 
    # Development
    python python-pip base-devel
    # Fun
    cmatrix
    # Wine & Windows
    wine giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls
    mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse
    libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib
    libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite
    libxinerama lib32-libxinerama opencl-icd lib32-opencl-icd
    # Network tools
    wireshark-qt
    # Text editor
    mousepad
    # GPU tools
    vulkan-tools
)

run "Pacman install" sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# ============================================================
#  5. AUR Packages
# ============================================================
step "AUR packages"

if command -v yay &>/dev/null; then
    AUR_PKGS=(
        # Additional Tools
        obsidian-bin aseprite brave-bin nload blanket localsend dialect
        # Keep existing
        impala rmpc vesktop
	keypunch
    )
    run "AUR install" yay -S --needed --noconfirm "${AUR_PKGS[@]}"
else
    fail "yay not available, skipping AUR packages"
fi

# ============================================================
#  6. Flatpak
# ============================================================
step "Flatpak setup"

run "Install flatpak" sudo pacman -S --needed --noconfirm flatpak
run "Add Flathub remote" sudo flatpak remote-add --if-not-exists flathub \
    https://flathub.org/repo/flathub.flatpakrepo

FLAT_PKGS=(
    org.altaqwaa.Altaqwaa
    com.github.PintaProject.Pinta
    io.github.alainm23.planify
    io.github.mimbrero.WhatsAppDesktop
)

run "Flatpak install" flatpak install -y flathub "${FLAT_PKGS[@]}"

# ============================================================
#  7. Ollama (AI)
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
#  8. Python tools (pipx)
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
#  10. System Configs
# ============================================================
step "System configs (etc/)"

if [ -d "$REPO_DIR/etc" ]; then
    run "Copy system configs" sudo cp -rf "$REPO_DIR/etc/"* /etc/
    run "Lock hosts file" sudo chattr +i /etc/hosts
else
    warn "No etc/ directory found, skipping."
fi

# ============================================================
#  9. Deploy Dotfiles
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

# ============================================================
#  10. Shell & Services
# ============================================================
step "Shell & services"

# Set Bash as default with Starship
BASH_PATH="$(command -v bash 2>/dev/null || true)"
if [ -n "$BASH_PATH" ]; then
    if [ "$SHELL" != "$BASH_PATH" ]; then
        if chsh -s "$BASH_PATH" >>"$LOG_FILE" 2>&1; then
            ok "Bash set as default shell"
        else
            fail "Failed to set Bash as default shell"
        fi
    else
        ok "Bash already default shell"
    fi
else
    fail "Bash not found"
fi

# Configure Starship prompt in .bashrc
if ! grep -q 'starship init bash' "$HOME/.bashrc" 2>/dev/null; then
    echo 'eval "$(starship init bash)"' >> "$HOME/.bashrc"
    ok "Starship prompt added to .bashrc"
else
    ok "Starship already in .bashrc"
fi

# Configure thefuck in .bashrc
if ! grep -q 'thefuck --alias' "$HOME/.bashrc" 2>/dev/null; then
    echo 'eval "$(thefuck --alias)"' >> "$HOME/.bashrc"
    ok "thefuck added to .bashrc"
else
    ok "thefuck already in .bashrc"
fi

# Configure zoxide in .bashrc
if ! grep -q 'zoxide init bash' "$HOME/.bashrc" 2>/dev/null; then
    echo 'eval "$(zoxide init bash)"' >> "$HOME/.bashrc"
    ok "zoxide added to .bashrc"
else
    ok "zoxide already in .bashrc"
fi

# Enable services
for svc in iwd.service pipewire.service pipewire-pulse.service; do
    run "Enable $svc" sudo systemctl enable --now "$svc" 2>/dev/null || true
done

# ============================================================
#  Summary
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
echo -e "    exec bash"
echo -e "    ollama pull llama3.2"
echo -e "    sudo reboot"
echo ""
