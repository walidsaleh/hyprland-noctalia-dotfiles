#!/bin/bash
# Auto-commit and push dotfiles if there are changes
set -e

cd ~/hyprland-noctalia-dotfiles

# If nothing changed, exit silently
if git diff --quiet HEAD 2>/dev/null && [ -z "$(git status --porcelain)" ]; then
    exit 0
fi

git add -A

# Only commit if there are staged changes
if ! git diff --cached --quiet; then
    git commit -q -m "Auto-sync $(date '+%Y-%m-%d %H:%M:%S')"
    git push -q 2>&1 || notify-send -u critical "dotfiles push failed" "Check ~/hyprland-noctalia-dotfiles"
fi
