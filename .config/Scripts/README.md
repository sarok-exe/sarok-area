# ~/.config/Scripts/

| Script | Usage |
|---|---|
| `wprand` | Random wallpaper / rofi drun |
| `wprand s` | Wallpaper picker / `Mod+Shift+W` |
| `nightlight.sh` | Toggle wlsunset 3500K / `Mod+Shift+N` / waybar |
| `mic.sh` | Mic volume & mute / waybar |
| `ocr_selection.sh` | Region OCR / `Mod+S` |
| `update-kitty-theme` | Generate kitty colors from wallpaper (auto-runs on `wprand`) |
| `gen-kitty-theme.py` | Python script called by update-kitty-theme |

**Waybar**: `custom/mic` · `custom/nightlight`

**Niri**: `Mod+Shift+N` night · `Mod+Shift+W` wallpaper · `Mod+S` OCR · startup = mpvpaper w/ GIF

**Rofi**: `colors.rasi` (matugen) · `wallpaper.rasi` (grid picker)

**Kitty**: `theme.conf` auto-generated from matugen on wallpaper change

**Starship**: bash prompt via `~/.config/starship.toml` (minimal: `$directory$character`, no blank line)

**Cursor**: Bibata-Modern-Classic (extracted from AUR, set in niri + gsettings)

**Packages**: `wlsunset` · `mpvpaper` · `grim` · `slurp` · `tesseract` · `wl-clipboard` · `libnotify` · `matugen` · `imagemagick`
