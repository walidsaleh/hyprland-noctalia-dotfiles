#!/bin/bash
# Auto-commit y push de dotfiles si hay cambios
set -e

cd ~/dotfiles

# Si no hay cambios, salir silenciosamente
if git diff --quiet HEAD 2>/dev/null && [ -z "$(git status --porcelain)" ]; then
    exit 0
fi

git add -A

# Solo commitear si hay staged changes
if ! git diff --cached --quiet; then
    git commit -q -m "Auto-sync $(date '+%Y-%m-%d %H:%M:%S')"
    git push -q 2>&1 || notify-send -u critical "dotfiles push falló" "Revisa ~/dotfiles"
fi
