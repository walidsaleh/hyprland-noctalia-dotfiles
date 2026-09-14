#!/bin/bash
# Auto-update + reboot-required flag
set -e

LOG="$HOME/.cache/system-update.log"
FLAG="$HOME/.cache/reboot-required"

echo "=== $(date) ===" >> "$LOG"

# 1. Run update
/usr/bin/yay -Syu --noconfirm --answerclean All --answerdiff None --removemake >> "$LOG" 2>&1 || {
    echo "yay falló, ver $LOG" | tee -a "$LOG"
    notify-send -u critical "Updates" "yay falló. Revisa $LOG"
    exit 1
}

# 2. Check reboot needed
RUNNING_KERNEL=$(uname -r | sed 's/-cachyos.*$//')
INSTALLED_KERNEL=$(pacman -Q linux-cachyos 2>/dev/null | awk '{print $2}')

NEEDS_REBOOT=0
REASON=""

# Kernel mismatch (installed != running)
if [ -n "$INSTALLED_KERNEL" ] && [ "$RUNNING_KERNEL" != "$INSTALLED_KERNEL" ]; then
    NEEDS_REBOOT=1
    REASON="kernel actualizado ($RUNNING_KERNEL → $INSTALLED_KERNEL)"
fi

# Modules of running kernel gone (often the case after a kernel upgrade before reboot)
if [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
    NEEDS_REBOOT=1
    REASON="${REASON:+$REASON; }módulos del kernel en uso ya no están en disco"
fi

# 3. Write/clear flag
if [ "$NEEDS_REBOOT" = "1" ]; then
    echo "$REASON" > "$FLAG"
    echo "Reboot required: $REASON" >> "$LOG"
else
    rm -f "$FLAG"
fi

echo "Update completo (reboot: $([ "$NEEDS_REBOOT" = "1" ] && echo SÍ || echo no))" >> "$LOG"

# 4. Notificar si hubo updates reales
if ! grep -q "no hay nada que hacer" "$LOG" 2>/dev/null; then
    UPDATED=$(grep -cE "^-> .{1,} \([^)]+\) ->" "$LOG" 2>/dev/null || echo "?")
    notify-send -u normal "Updates OK" "$UPDATED paquetes"
    echo "$(date +%s) $UPDATED" > "$HOME/.cache/last-updates"
fi
