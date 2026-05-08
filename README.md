# sarok-area

My Arch Linux dotfiles with niri WM.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/sarok-exe/sarok-area/main/install.sh | bash
```

## What's Included

- **WM**: niri (Wayland compositor)
- **Bar**: waybar with mic & nightlight modules
- **Terminal**: kitty with matugen dynamic theming
- **Launcher**: rofi with wallpaper picker
- **Prompt**: starship (bash)
- **Cursor**: Bibata-Modern-Classic
- **Wallpapers**: animated GIF support via mpvpaper

## Scripts (`~/.config/Scripts/`)

| Script | Function |
|---|---|
| `wprand` | Random wallpaper / rofi picker |
| `nightlight.sh` | Toggle wlsunset 3500K |
| `mic.sh` | Mic volume control |
| `ocr_selection.sh` | Region screenshot → OCR |
| `update-kitty-theme` | Auto-generates kitty colors from wallpaper |

## Keybinds

| Key | Action |
|---|---|
| `Mod+Shift+N` | Toggle night light |
| `Mod+Shift+W` | Wallpaper picker |
| `Mod+S` | OCR region |
