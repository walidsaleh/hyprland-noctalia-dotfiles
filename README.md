# hyprland-noctalia-dotfiles

Backup versionado de la configuración de **Hyprland + Noctalia** en CachyOS, junto con keyd (remapeo de teclado), Qt6ct, scripts propios y unidades systemd de usuario.

## Estructura

```
noctalia/   → ~/.config/noctalia/config.toml
hypr/       → ~/.config/hypr/config/*.lua (inputs, monitors, workspaces)
keyd/       → ~/.config/keyd/default.conf
qt6ct/      → ~/.config/qt6ct/qt6ct.conf
uwsm/       → ~/.config/uwsm/env
bin/        → ~/.local/bin/* (scripts propios)
systemd/    → ~/.config/systemd/user/*.{service,timer}
```

Todo se gestiona con **symlinks**: los archivos viven aquí y se enlazan a `~/.config/...`. Editas el archivo en un sitio, queda en ambos.

## Restore en otra máquina

```bash
git clone <url> ~/hyprland-noctalia-dotfiles
cd ~/hyprland-noctalia-dotfiles
# Recrear los symlinks manualmente o con un script
```

## Push automático

Hay un timer systemd (`dotfiles-push.timer`) que hace `git add + commit + push` cada hora si hay cambios.
