#!/bin/bash
# wofi-emoji: a lightweight emoji picker for Wayland/Hyprland
exec 2>/dev/null

EMOJI_FILE="$HOME/.local/share/noctalia-emoji/emoji.txt"
mkdir -p "$(dirname "$EMOJI_FILE")"

# Build emoji list once if missing
if [ ! -f "$EMOJI_FILE" ]; then
    # Use Python for reliable parsing of Unicode emoji test file
    python3 << 'PYEOF' > "$EMOJI_FILE"
import re
import urllib.request

url = "https://unicode.org/Public/emoji/15.1/emoji-test.txt"
try:
    with urllib.request.urlopen(url, timeout=10) as r:
        data = r.read().decode("utf-8")
except Exception:
    data = ""

for line in data.splitlines():
    # Lines like: 1F600  ; fully-qualified # 😀 E1.0 grinning face
    m = re.match(r"^[0-9A-F]+\s+;\s+fully-qualified\s+#\s+(\S+)\s+E\d+\.\d+\s+(.+)$", line)
    if m:
        emoji, name = m.group(1), m.group(2).strip()
        print(f"{emoji}  {name}")
PYEOF

    # Fallback to a curated list if download failed
    if [ ! -s "$EMOJI_FILE" ]; then
        cat > "$EMOJI_FILE" << 'FALLBACK'
😀  grinning face
😃  grinning face with big eyes
😄  grinning face with smiling eyes
😁  beaming face with smiling eyes
😆  grinning squinting face
😅  grinning face with sweat
🤣  rolling on the floor laughing
😂  face with tears of joy
🙂  slightly smiling face
🙃  upside-down face
😉  winking face
😊  smiling face with smiling eyes
FALLBACK
    fi
fi

# Run wofi and copy selected emoji to clipboard
chosen=$(wofi --dmenu --prompt "Emoji" --width 700 --height 500 \
    < "$EMOJI_FILE" | awk '{print $1}')

[ -n "$chosen" ] && echo -n "$chosen" | wl-copy
