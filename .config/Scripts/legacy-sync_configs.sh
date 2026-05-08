#!/bin/bash

SOURCE_CONFIG="$HOME/.config"
PROJECT_DIR="$HOME/Documents/Projects/sarok-area"
DEST_CONFIG="$PROJECT_DIR/.config"

mkdir -p "$DEST_CONFIG"

CONFIGS=(
    "niri"
    "kitty"
    "btop"
    "cava"
    "yazi"
    "waybar"
    "rofi"
    "thefuck"
    "dunst"
    "nvim"
    "starship.toml"
    "mpd"
    "rmpc"
    "matugen"
    "fish"
    "gtk-3.0"
    "gtk-4.0"
    "mako"
)

echo "Starting sync: Moving everything into $DEST_CONFIG"

for item in "${CONFIGS[@]}"; do
    if [ -e "$SOURCE_CONFIG/$item" ]; then
        echo "Syncing: $item"
        rsync -av --delete --exclude '.git' "$SOURCE_CONFIG/$item" "$DEST_CONFIG/"
    else
        echo "Skip: $item not found"
    fi
done

BASH_FILES=(
    ".bashrc"
    ".bash_profile"
    ".profile"
    "hosts"
)

for file in "${BASH_FILES[@]}"; do
    if [ -f "$HOME/$file" ]; then
        echo "Moving $file to .config/"
        cp "$HOME/$file" "$DEST_CONFIG/"
    fi
done

SCRIPTS_DIR="$DEST_CONFIG/scripts"
mkdir -p "$SCRIPTS_DIR"
if [ -d "$HOME/Documents/Scripts" ]; then
    echo "Syncing scripts from ~/Documents/Scripts"
    rsync -av --delete "$HOME/Documents/Scripts/" "$SCRIPTS_DIR/"
fi

echo "Generating pkg_list.txt inside .config/"
pacman -Qe > "$DEST_CONFIG/pkg_list.txt" 2>/dev/null || echo "Could not generate pkg_list"

cd "$PROJECT_DIR"
rm -rf btop cava dunst kitty niri niri_caelestia quickshell thefuck yazi nvim micro starship.toml .bashrc pkg_list.txt hosts mpd rmpc fish scripts gtk-3.0 gtk-4.0 mako

echo "Sync finished. Everything is now inside .config"