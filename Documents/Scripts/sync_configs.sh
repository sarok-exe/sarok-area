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

echo "Generating pkg_list.txt inside .config/"
pacman -Qe > "$DEST_CONFIG/pkg_list.txt"

cd "$PROJECT_DIR"
rm -rf btop cava dunst kitty niri niri_caelestia quickshell thefuck yazi nvim micro starship.toml .bashrc pkg_list.txt hosts

echo "Sync finished. Everything is now inside .config"