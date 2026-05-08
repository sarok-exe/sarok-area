#!/bin/bash
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_SRC="$REPO_DIR/.config"
LOG_FILE="/tmp/sarok-setup-$(date +%Y%m%d-%H%M%S).log"
FAILURES=()

DIM='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'
GREEN='\033[0;92m'; YELLOW='\033[0;93m'; RED='\033[0;91m'
MAGENTA='\033[0;95m'

TOTAL=7; cur=0

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }
step() { cur=$((cur + 1)); echo -e "\n  ${DIM}── ${NC}${BOLD}${cur}.${NC} ${BOLD}$*${NC}"; }
ok()   { echo -e "  ${GREEN}  ok${NC}    $1"; log "[OK] $1"; }
warn() { echo -e "  ${YELLOW}  warn${NC}  $1"; log "[WARN] $1"; }
fail() { echo -e "  ${RED}  fail${NC}  $1"; FAILURES+=("$1"); log "[FAIL] $1"; }

run() {
  local label="$1"; shift
  local start; start=$(date +%s)
  printf "  ${DIM}  \u00b7${NC} ${label}\n"
  "$@" 2>&1 | tee -a "$LOG_FILE" | grep -vE '^\s*[0-9]+K\s' || true
  local rc=${PIPESTATUS[0]}
  local total=$(($(date +%s) - start))
  tput cuu1 2>/dev/null || printf "\033[A"
  if [ $rc -eq 0 ]; then
    printf "  ${GREEN}  ok${NC}    ${label}  ${DIM}%ds${NC}\n" $total
  else
    printf "  ${RED}  fail${NC}  ${label}  ${DIM}%ds${NC}\n" $total
  fi
  return $rc
}

clear
echo
echo -e "  ${MAGENTA}┌──────────────────────────┐${NC}"
echo -e "  ${MAGENTA}│${NC}  ◆  ${BOLD}SAROK AREA${NC}          ${MAGENTA}│${NC}"
echo -e "  ${MAGENTA}│${NC}  ${DIM}arch linux setup${NC}       ${MAGENTA}│${NC}"
echo -e "  ${MAGENTA}└──────────────────────────┘${NC}"
echo
echo -e "  ${DIM}log → ${LOG_FILE}${NC}"
echo

command -v pacman &>/dev/null || { echo -e "  ${RED}requires arch linux${NC}"; exit 1; }
[ "$EUID" -eq 0 ] && { echo -e "  ${RED}do not run as root${NC}"; exit 1; }

if [ -f /var/lib/pacman/db.lck ]; then
  echo -e "  ${YELLOW}  warn${NC}  stale pacman lock found"
  echo -e "  ${DIM}         run: sudo rm /var/lib/pacman/db.lck${NC}"
  exit 1
fi

printf "  ${DIM}  \u00b7${NC} caching sudo password..."
sudo -v && printf "\033[2K\r  ${GREEN}  ok${NC}    password cached\n"

# ── 1. System & base packages ──────────────────────────────────
step "System & base packages"

[ -d "$REPO_DIR/etc" ] && run "Apply etc configs" sudo cp -rf "$REPO_DIR/etc/"* /etc/

run "Install base-devel git curl jq" sudo pacman -S --needed --noconfirm base-devel git curl jq

if command -v yay &>/dev/null; then
  ok "yay already installed"
else
  if git clone https://aur.archlinux.org/yay.git /tmp/yay >>"$LOG_FILE" 2>&1; then
    (cd /tmp/yay && makepkg -si --noconfirm >>"$LOG_FILE" 2>&1) && ok "yay installed" || fail "yay build failed"
  else fail "yay clone failed"; fi
  rm -rf /tmp/yay
fi

run "System upgrade" sudo pacman -Syu --noconfirm
run "Python pip upgrade" python -m pip install --user --upgrade pip --break-system-packages

# ── 2. Pacman packages ────────────────────────────────────────
step "Pacman packages"

PKGS=(
  # Compositor & WM
  niri xorg-xwayland wayland-protocols qt6-wayland
  swaybg swayidle swaylock swaync fuzzel wlr-randr

  # Terminal & shell
  kitty alacritty fish starship zoxide thefuck

  # Editors & dev tools
  neovim vim mousepad code
  cmake ninja meson vala mingw-w64-gcc
  nodejs npm github-cli
  python python-pip base-devel

  # File management
  yazi nautilus rsync zip unzip

  # System info
  fastfetch btop htop nload cmatrix

  # Audio & notifications
  cava dunst brightnessctl pamixer pavucontrol
  mpd mpc pipewire-alsa pipewire-jack blanket

  # Network
  networkmanager openssh iwd wireless_tools
  wget curl yt-dlp

  # UI components
  waybar rofi mako
  mpv imv feh flameshot
  adw-gtk-theme papirus-icon-theme nwg-look
  gnome-keyring gnome-tweaks

  # Fonts
  ttf-jetbrains-mono-nerd ttf-cascadia-code-nerd
  ttf-nerd-fonts-symbols-mono noto-fonts-cjk

  # Screenshot & OCR
  slurp grim tesseract tesseract-data-eng wl-clipboard libnotify

  # Input
  fcitx5 fcitx5-configtool fcitx5-table-extra

  # Apps
  firefox telegram-desktop obsidian
  inkscape foliate drawing
  dialect errands

  # System & hardware
  polkit ly
  intel-media-driver libva-intel-driver
  vulkan-intel vulkan-tools
  tlp powertop smartmontools zram-generator
  xdg-desktop-portal-wlr xdg-utils

  # Theming
  wlsunset imagemagick matugen gpu-screen-recorder

  # Misc
  libqalculate
)
run "Install ${#PKGS[@]} packages" sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# ── 3. AUR packages ───────────────────────────────────────────
step "AUR packages"

if command -v yay &>/dev/null; then
  run "AUR packages" \
    yay -S --needed --noconfirm --cleanafter=false --diffmenu=false --nodiffmenu --nocleanafter \
    keypunch rmpc awww gpu-screen-recorder gpu-screen-recorder-gtk \
    beaver-notes brave-bin pawn-appetit-bin
else fail "yay not available"; fi

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
  else warn "Could not install $pkg (needs manual sudo)"; fi
}
extract_aur mpvpaper mpvpaper
extract_aur bibata-cursor-theme-bin ""

# ── 4. Dotfiles ───────────────────────────────────────────────
step "Dotfiles"

mkdir -p "$HOME/.config"
if [ -d "$DOT_SRC" ]; then
  scripts_target="$HOME/.config/Scripts"
  if [ -e "$scripts_target" ]; then
    mv "$scripts_target" "$scripts_target.bak-$(date +%s)" && log "[Dotfiles] Backed up: Scripts"
  fi
  for item in "$DOT_SRC"/*; do
    name="$(basename "$item")"
    [ "$name" = "Scripts" ] && continue
    target="$HOME/.config/$name"
    [ -e "$target" ] && mv "$target" "$target.bak-$(date +%s)" && log "[Dotfiles] Backed up: $target"
    cp -rf "$item" "$target"
  done
  ok "Dotfiles copied"
else fail "Source directory not found: $DOT_SRC"; fi

SCRIPTS_DIR="$HOME/.config/Scripts"
if [ -d "$DOT_SRC/Scripts" ]; then
  mkdir -p "$SCRIPTS_DIR"
  cp -rn "$DOT_SRC/Scripts/"* "$SCRIPTS_DIR/"
  chmod +x "$SCRIPTS_DIR"/* 2>/dev/null
  [ -d "$DOT_SRC/scripts_legacy" ] && cp -rn "$DOT_SRC/scripts_legacy/"* "$SCRIPTS_DIR/" 2>/dev/null
  ok "Scripts copied"
fi

# ── 5. Shell & theming ────────────────────────────────────────
step "Shell & theming"

if ! grep -q "starship" "$HOME/.bashrc" 2>/dev/null; then
  echo -e '\n# Starship prompt\neval "$(starship init bash)"' >> "$HOME/.bashrc"
  ok "Starship added to .bashrc"
else ok "Starship already in .bashrc"; fi

CURSOR_DIR=$(find "$HOME/.local/share/icons" -maxdepth 1 -name "Bibata*" -type d 2>/dev/null | head -1)
if [ -n "$CURSOR_DIR" ]; then
  gsettings set org.gnome.desktop.interface cursor-theme "$(basename "$CURSOR_DIR")" 2>/dev/null || true
  gsettings set org.gnome.desktop.interface cursor-size 24 2>/dev/null || true
  ok "Bibata cursor set"
else warn "Bibata cursor not found"; fi

# ── 6. Services ───────────────────────────────────────────────
step "Services"

for svc in pipewire.service pipewire-pulse.service; do
  run "Enable ${svc}" sudo systemctl enable --now "$svc"
done
run "Disable MPD auto-start" systemctl --user disable mpd

# ── Cleanup ──────────────────────────────────────────────────
step "Cleanup"

rm -rf "$REPO_DIR"
ok "Removed repo directory"

# ── Summary ───────────────────────────────────────────────────
echo
if [ ${#FAILURES[@]} -eq 0 ]; then
  echo -e "  ${GREEN}  ok${NC}    ${BOLD}setup complete${NC} — all ${TOTAL} steps done"
else
  echo -e "  ${YELLOW}  warn${NC}  ${BOLD}setup finished with ${#FAILURES[@]} issue(s)${NC}"
  for f in "${FAILURES[@]}"; do echo -e "  ${RED}  fail${NC}  ${f}"; done
fi
echo
echo -e "  ${DIM}log → ${LOG_FILE}${NC}"
echo
echo -e "  ${BOLD}next:${NC}"
echo -e "    source ~/.bashrc"
echo -e "    set wallpaper → update-kitty-theme"
echo -e "    reboot"
echo
