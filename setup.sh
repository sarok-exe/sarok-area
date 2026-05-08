#!/bin/bash
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_SRC="$REPO_DIR/.config"
LOG_FILE="/tmp/sarok-setup-$(date +%Y%m%d-%H%M%S).log"
FAILURES=()

MAGENTA='\033[1;35m'; CYAN='\033[1;36m'; GREEN='\033[1;32m'
YELLOW='\033[1;33m'; RED='\033[1;31m'; DIM='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'

TOTAL_STEPS=14; CURRENT_STEP=0

step() { CURRENT_STEP=$((CURRENT_STEP + 1)); echo ""; echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "  ${BOLD}${MAGENTA}▶${NC} ${BOLD}$CURRENT_STEP/$TOTAL_STEPS:${NC} $1"; echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
ok()   { echo -e "    ${GREEN}✓${NC} $1"; log "[OK] $1"; }
warn() { echo -e "    ${YELLOW}!${NC} $1"; log "[WARN] $1"; }
fail() { echo -e "    ${RED}✗${NC} $1"; FAILURES+=("$1"); log "[FAIL] $1"; }
run() { local l="$1"; shift; echo -e "  ${DIM}  → $*${NC}"; if "$@" 2>&1 | tee -a "$LOG_FILE"; then ok "$l"; else fail "$l"; fi; }
log() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"; }

clear
echo ""; echo -e "  ${MAGENTA}  ╔═══╗╔═══╗╔═══╗${NC}"; echo -e "  ${MAGENTA}  ║   ║║   ║║   ║${NC}"; echo -e "  ${MAGENTA}  ║   ║║   ║║   ║${NC}"; echo -e "  ${MAGENTA}  ╚═══╝╚═══╝╚═══╝${NC}"; echo ""
echo -e "  ${BOLD}  SAROK AREA${NC} — Arch Setup"; echo ""; echo -e "  ${DIM}  Log: $LOG_FILE${NC}"; echo ""

if ! command -v pacman &>/dev/null; then echo -e "  ${RED}Requires Arch Linux${NC}"; exit 1; fi
if [ "$EUID" -eq 0 ]; then echo -e "  ${RED}Do not run as root${NC}"; exit 1; fi

echo ""; echo -e "  ${CYAN}→ Getting sudo password...${NC}"; sudo -v; echo -e "  ${GREEN}✓ Password cached${NC}"

# 1. System configs
step "Deploy system configs"
[ -d "$REPO_DIR/etc" ] && run "Copy etc/" sudo cp -rf "$REPO_DIR/etc/"* /etc/

# 2. Base build tools
step "Base build tools"
run "Install base-devel git curl jq" sudo pacman -S --needed --noconfirm base-devel git curl jq

# 3. yay
step "AUR helper (yay)"
if command -v yay &>/dev/null; then
  ok "yay already installed"
else
  if git clone https://aur.archlinux.org/yay.git /tmp/yay >>"$LOG_FILE" 2>&1; then
    (cd /tmp/yay && makepkg -si --noconfirm >>"$LOG_FILE" 2>&1) && ok "yay installed" || fail "yay build failed"
  else; fail "yay clone failed"; fi
  rm -rf /tmp/yay
fi

# 4. System update
step "System update"
run "pacman -Syu" sudo pacman -Syu --noconfirm

# 5. Pacman packages
step "Pacman packages"
PKGS=(
  niri xorg-xwayland wayland-protocols qt6-wayland
  kitty starship zoxide thefuck neovim yazi fastfetch
  btop cava dunst brightnessctl pamixer pavucontrol
  networkmanager openssh rsync zip unzip
  waybar rofi
  mpv imv feh
  ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd
  ttf-nerd-fonts-symbols-mono noto-fonts-cjk
  adw-gtk-theme papirus-icon-theme
  cmake ninja slurp grim tesseract tesseract-data-eng wl-clipboard libnotify
  python python-pip base-devel
  mpd mpc
  wlsunset imagemagick matugen
)
run "Pacman install" sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# 6. Python tools
step "Python tools"
run "Upgrade pip" python -m pip install --user --upgrade pip

# 7. AUR packages
step "AUR packages"
if command -v yay &>/dev/null; then
  run "AUR install" yay -S --needed --noconfirm opencode-bin keypunch rmpc vesktop awww gpu-screen-recorder gpu-screen-recorder-gtk
else; fail "yay not available"; fi

# 8. Extract AUR packages (no sudo needed)
step "Extract AUR packages"
extract_aur() {
  local pkg="$1"; local bin="$2"
  if [ -n "$bin" ] && command -v "$bin" &>/dev/null; then ok "$bin already installed"; return 0; fi
  if yay -S --noconfirm "$pkg" >>"$LOG_FILE" 2>&1; then ok "$pkg installed"; return 0; fi
  local cache; cache=$(find ~/.cache/yay/"$pkg" -name "*.pkg.tar.zst" 2>/dev/null | head -1)
  if [ -n "$cache" ]; then
    mkdir -p ~/.local/bin ~/.local/share/icons
    tar --zstd -xf "$cache" -C /tmp usr/bin/ 2>/dev/null && cp /tmp/usr/bin/* ~/.local/bin/ 2>/dev/null
    tar --zstd -xf "$cache" -C /tmp usr/share/icons/ 2>/dev/null && cp -r /tmp/usr/share/icons/* ~/.local/share/icons/ 2>/dev/null
    rm -rf /tmp/usr; chmod +x ~/.local/bin/* 2>/dev/null
    ok "$pkg extracted to ~/.local"
  else; warn "Could not install $pkg (needs manual sudo)"; fi
}
extract_aur mpvpaper mpvpaper
extract_aur bibata-cursor-theme-bin ""

# 9. Ollama
step "Ollama AI"
if command -v ollama &>/dev/null; then ok "Ollama already installed"
else curl -fsSL https://ollama.com/install.sh | sh >> "$LOG_FILE" 2>&1 && ok "Ollama installed" || fail "Ollama install failed"; fi

# 10. Deploy dotfiles
step "Deploy dotfiles"
mkdir -p "$HOME/.config"
if [ -d "$DOT_SRC" ]; then
  # Backup Scripts separately — must stay a real directory for user modifications
  scripts_target="$HOME/.config/Scripts"
  if [ -e "$scripts_target" ] && [ ! -L "$scripts_target" ]; then
    mv "$scripts_target" "$scripts_target.bak-$(date +%s)" && log "[Dotfiles] Backed up: Scripts"
  elif [ -L "$scripts_target" ]; then
    rm "$scripts_target"
  fi
  for item in "$DOT_SRC"/*; do
    name="$(basename "$item")"
    [ "$name" = "Scripts" ] && continue
    target="$HOME/.config/$name"
    [ -e "$target" ] && [ ! -L "$target" ] && mv "$target" "$target.bak-$(date +%s)" && log "[Dotfiles] Backed up: $target"
    [ -L "$target" ] && rm "$target"
    ln -sf "$item" "$target"
  done
  ok "All dotfiles linked (Scripts handled separately)"
else; fail "Source directory not found: $DOT_SRC"; fi

# 11. Setup scripts
step "Setup scripts"
SCRIPTS_DIR="$HOME/.config/Scripts"
if [ -d "$DOT_SRC/Scripts" ]; then
  mkdir -p "$SCRIPTS_DIR"
  cp -rn "$DOT_SRC/Scripts/"* "$SCRIPTS_DIR/"
  chmod +x "$SCRIPTS_DIR"/* 2>/dev/null
  # Also copy legacy scripts
  [ -d "$DOT_SRC/scripts_legacy" ] && cp -rn "$DOT_SRC/scripts_legacy/"* "$SCRIPTS_DIR/" 2>/dev/null
  ok "Scripts copied to ~/.config/Scripts"
fi

# 12. Starship prompt
step "Starship prompt"
if ! grep -q "starship" "$HOME/.bashrc" 2>/dev/null; then
  echo -e '\n# Starship prompt\neval "$(starship init bash)"' >> "$HOME/.bashrc"
  ok "Starship added to .bashrc"
else; ok "Starship already in .bashrc"; fi

# 13. Cursor theme
step "Cursor theme"
CURSOR_DIR=$(find "$HOME/.local/share/icons" -maxdepth 1 -name "Bibata*" -type d 2>/dev/null | head -1)
if [ -n "$CURSOR_DIR" ]; then
  gsettings set org.gnome.desktop.interface cursor-theme "$(basename "$CURSOR_DIR")" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
  ok "Bibata cursor set"
else; warn "Bibata cursor not found"; fi

# 14. Services
step "Services"
for svc in pipewire.service pipewire-pulse.service; do
  run "Enable $svc" sudo systemctl enable --now "$svc" 2>/dev/null || true
done
run "Disable MPD auto-start" systemctl --user disable mpd 2>/dev/null || true

# Summary
echo ""; echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ ${#FAILURES[@]} -eq 0 ]; then
  echo -e "  ${GREEN}✓ SETUP COMPLETE${NC}"; echo ""; echo -e "  ${GREEN}All $TOTAL_STEPS steps done!${NC}"
else
  echo -e "  ${YELLOW}⚠ SETUP FINISHED (${#FAILURES[@]} issues)${NC}"
  for f in "${FAILURES[@]}"; do echo -e "    ${RED}✗ $f${NC}"; done
fi
echo ""; echo -e "  ${DIM}Log: $LOG_FILE${NC}"; echo ""
echo -e "  ${BOLD}Next:${NC}"
echo -e "    source ~/.bashrc"
echo -e "    ollama pull llama3.2"
echo -e "    Set wallpaper then: update-kitty-theme"
echo -e "    reboot"
echo ""
