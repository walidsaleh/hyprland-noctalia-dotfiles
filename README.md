# hyprland-noctalia-dotfiles

Versioned backup of my **Hyprland + Noctalia** desktop configuration on CachyOS, along with keyd (keyboard remapping), Qt6ct, custom scripts and user systemd units. Designed to be cloned on a fresh machine and get everything working in ~10 minutes.

## Hardware

- **Laptop:** Dell Pro Max 16 Plus (MB16250)
- **External keyboard:** Keychron K3 (75%, Mac/Win switch, Bluetooth)
- **Displays:** 2 monitors (laptop + 4K external)

## Base software

- **Distro:** CachyOS
- **Compositor:** Hyprland (configured via Lua)
- **Bar:** Noctalia v5+
- **Terminal:** kitty
- **Editor:** VSCode
- **Browser:** Google Chrome
- **File manager:** Nautilus
- **Key remap:** keyd

## Layout

```
hyprland-noctalia-dotfiles/
├── noctalia/                                       → ~/.config/noctalia/
├── hypr/config/{inputs,monitors,workspaces}.lua    → ~/.config/hypr/config/
├── keyd/default.conf                               → ~/.config/keyd/ (and /etc/keyd/)
├── qt6ct/qt6ct.conf                                → ~/.config/qt6ct/
├── uwsm/env                                        → ~/.config/uwsm/
├── bin/                                            → ~/.local/bin/
└── systemd/user/                                   → ~/.config/systemd/user/
```

Every file is a **symlink** to `~/.config/...`. Edit in one place, reflected in both.

## Restore on a new machine

### 1. Dependencies (Arch/CachyOS)

```bash
sudo pacman -S hyprland noctalia kitty nautilus gnome-text-editor \
                gnome-calculator google-chrome satty brightnessctl \
                grim hyprpicker slurp wl-clipboard xdg-desktop-portal-hyprland \
                qt6ct noto-fonts noto-fonts-emoji keyd nwg-look adw-gtk-theme
yay -S visual-studio-code-bin teams-for-linux
```

### 2. Clone and link

```bash
git clone https://github.com/walidsaleh/hyprland-noctalia-dotfiles ~/hyprland-noctalia-dotfiles
cd ~/hyprland-noctalia-dotfiles

# Recreate all symlinks
ln -sf "$PWD/noctalia/config.toml"             ~/.config/noctalia/config.toml
ln -sf "$PWD/hypr/config/inputs.lua"           ~/.config/hypr/config/inputs.lua
ln -sf "$PWD/hypr/config/monitors.lua"         ~/.config/hypr/config/monitors.lua
ln -sf "$PWD/hypr/config/workspaces.lua"       ~/.config/hypr/config/workspaces.lua
ln -sf "$PWD/keyd/default.conf"                ~/.config/keyd/default.conf
sudo ln -sf "$PWD/keyd/default.conf"           /etc/keyd/default.conf
ln -sf "$PWD/qt6ct/qt6ct.conf"                 ~/.config/qt6ct/qt6ct.conf
ln -sf "$PWD/uwsm/env"                         ~/.config/uwsm/env
ln -sf "$PWD/bin/system-update.sh"             ~/.local/bin/system-update.sh
ln -sf "$PWD/bin/dotfiles-push.sh"             ~/.local/bin/dotfiles-push.sh

# Systemd user units
for f in systemd/user/*.{service,timer}; do
    ln -sf "$PWD/$f" ~/.config/systemd/user/$(basename "$f")
done
```

### 3. Enable services

```bash
# keyd (keyboard remap)
sudo systemctl enable --now keyd
sudo keyd reload

# Auto-update and auto-push timers
systemctl --user daemon-reload
systemctl --user enable --now yay-autoupdate.timer
systemctl --user enable --now hypr-persist-save.service
systemctl --user enable --now hypr-persist-autosave.timer
systemctl --user enable --now dotfiles-push.timer
```

### 4. Passwordless sudo for auto-update

```bash
sudo tee /etc/sudoers.d/yay-autoupdate > /dev/null << 'EOF'
walid ALL=(root) NOPASSWD: /usr/bin/pacman
EOF
sudo chmod 440 /etc/sudoers.d/yay-autoupdate
sudo visudo -c -f /etc/sudoers.d/yay-autoupdate
```

> Rename `walid` to your actual username.

## Notable customizations

### Keychron K3 keyboard

F-row ↔ multimedia swap via keyd, plus XKB modifier remap to coexist with the `es` layout:

- F1/F2 = screen brightness
- F3/F4 = launcher / control center (Noctalia)
- F5/F6 = keyboard backlight
- F7-F9 = media (prev/play/next)
- F10-F12 = mute / volume
- **Right Ctrl + F1-F12** = real F-keys (for IDE/terminal)
- **Right Super + key** = AltGr (level 3 shift) → `@`, `#`, `€`, etc.

### Workspaces

- 3 per monitor (configurable via `workspaces.lua` and `variables.lua`)
- Native Hyprland (no plugins)

### Session

- Window persistence with `hypr-persist`
- Auto-save every 5 min + save on shutdown via systemd ExecStop
- Auto-restore on Hyprland start

### Power button

Short press → opens the Noctalia session panel. Long press → emergency shutdown.

## Auto-update of the system

- Daily timer runs `yay -Syu --noconfirm` via systemd
- Detects kernel changes and creates a `~/.cache/reboot-required` flag
- Noctalia notifies at login if a reboot is pending

## License

MIT — do whatever you want with this.
