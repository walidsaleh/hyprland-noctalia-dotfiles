# dotfiles

Backup versionado de la configuración del sistema (Hyprland + Noctalia + keyd + Qt + scripts).

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
git clone <url> ~/dotfiles
cd ~/dotfiles
# Recrear los symlinks manualmente o con un script
```

## Push automático

Hay un timer systemd (`~/.config/systemd/user/dotfiles-push.timer`) que hace `git add + commit + push` una vez al día si hay cambios.
