#!/bin/bash
set -uo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_SRC="$REPO_DIR/.config"
LOG_FILE="/tmp/sarok-setup-$(date +%Y%m%d-%H%M%S).log"
FAILURES=()

DIM='\033[0;90m'; BOLD='\033[1m'; NC='\033[0m'
GREEN='\033[0;92m'; YELLOW='\033[0;93m'; RED='\033[0;91m'
MAGENTA='\033[0;95m'

TOTAL=6; cur=0

log() { echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"; }
step() { cur=$((cur + 1)); echo -e "\n  ${DIM}── ${NC}${BOLD}${cur}.${NC} ${BOLD}$*${NC}"; }
ok()   { echo -e "  ${GREEN}  ok${NC}    $1"; log "[OK] $1"; }
warn() { echo -e "  ${YELLOW}  warn${NC}  $1"; log "[WARN] $1"; }
fail() { echo -e "  ${RED}  fail${NC}  $1"; FAILURES+=("$1"); log "[FAIL] $1"; }

run() {
  local label="$1"; shift
  local start; start=$(date +%s)
  echo -ne "  ${DIM}  ·${NC} ${label}${DIM}...${NC}"
  "$@" >> "$LOG_FILE" 2>&1 &
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    local now; now=$(date +%s)
    local elapsed=$((now - start))
    echo -ne "\r  ${DIM}  ${spin:$i:1}${NC} ${label}  ${DIM}${elapsed}s${NC}"
    sleep 0.12
  done
  wait $pid
  local rc=$?
  local end; end=$(date +%s)
  local total=$((end - start))
  if [ $rc -eq 0 ]; then
    echo -e "\r  ${GREEN}  ok${NC}    ${label}  ${DIM}${total}s${NC}"
  else
    echo -e "\r  ${RED}  fail${NC}  ${label}  ${DIM}${total}s${NC}"
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

echo -ne "  ${DIM}  ·${NC} caching sudo password..."
sudo -v && echo -e "\r  ${GREEN}  ok${NC}    password cached"

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
run "Install ${#PKGS[@]} packages" sudo pacman -S --needed --noconfirm "${PKGS[@]}"

# ── 3. AUR packages ───────────────────────────────────────────
step "AUR packages"

if command -v yay &>/dev/null; then
  run "opencode-bin, keypunch, rmpc, vesktop, awww, gpu-screen-recorder" \
    yay -S --needed --noconfirm --cleanafter=false --diffmenu=false --nodiffmenu --nocleanafter \
    opencode-bin keypunch rmpc vesktop awww gpu-screen-recorder gpu-screen-recorder-gtk
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

run "Ollama AI" bash -c 'command -v ollama &>/dev/null && exit 0; curl -fsSL https://ollama.com/install.sh | sh'

# ── 4. Dotfiles ───────────────────────────────────────────────
step "Dotfiles"

mkdir -p "$HOME/.config"
if [ -d "$DOT_SRC" ]; then
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
  ok "Dotfiles linked"
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
echo -e "    ollama pull llama3.2"
echo -e "    set wallpaper → update-kitty-theme"
echo -e "    reboot"
echo
