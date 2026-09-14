#!/bin/bash
# Auto-update + reboot-required flag
set -e

LOG="$HOME/.cache/system-update.log"
FLAG="$HOME/.cache/reboot-required"

echo "=== $(date) ===" >> "$LOG"

# 1. Run update
/usr/bin/yay -Syu --noconfirm --answerclean All --answerdiff None --removemake >> "$LOG" 2>&1 || {
    echo "yay failed, see $LOG" | tee -a "$LOG"
    notify-send -u critical "Updates" "yay failed. Check $LOG"
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
    REASON="kernel updated ($RUNNING_KERNEL → $INSTALLED_KERNEL)"
fi

# Modules of running kernel gone (often the case after a kernel upgrade before reboot)
if [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
    NEEDS_REBOOT=1
    REASON="${REASON:+$REASON; }modules for the running kernel are no longer on disk"
fi

# 3. Write/clear flag
if [ "$NEEDS_REBOOT" = "1" ]; then
    echo "$REASON" > "$FLAG"
    echo "Reboot required: $REASON" >> "$LOG"
else
    rm -f "$FLAG"
fi

echo "Update complete (reboot: $([ "$NEEDS_REBOOT" = "1" ] && echo YES || echo no))" >> "$LOG"

# 4. Notify if real updates happened
if ! grep -q "no hay nada que hacer" "$LOG" 2>/dev/null; then
    UPDATED=$(grep -cE "^-> .{1,} \([^)]+\) ->" "$LOG" 2>/dev/null || echo "?")
    notify-send -u normal "Updates OK" "$UPDATED packages"
    echo "$(date +%s) $UPDATED" > "$HOME/.cache/last-updates"
fi
