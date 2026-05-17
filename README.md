# Sarok Area

Arch Linux setup with Niri window manager.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/sarok-exe/sarok-area/main/install.sh | bash
```

## Manual

```bash
git clone git@github.com:sarok-exe/sarok-area.git ~/.sarok-area
cd ~/.sarok-area
./setup.sh
```

## Structure

- `setup.sh` - Main installer
- `etc/` - System configs (hosts, pacman.conf)
- `.config/` - User configs (niri, kitty, waybar, etc.)
- `install.sh` - Bootstrap (curl | bash)

## After Install

- Reboot or restart niri: `Mod+Shift+E`
- Set shell: `chsh -s /usr/bin/fish`