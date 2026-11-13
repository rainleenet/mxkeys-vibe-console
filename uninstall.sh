#!/bin/zsh
set -euo pipefail

UID_VALUE="$(id -u)"
LAUNCH_DIR="$HOME/Library/LaunchAgents"
HAMMERSPOON_DIR="$HOME/.hammerspoon"
BACKUP_DIR="$HOME/.mxkeys-vibe-console-backup/uninstall-$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BACKUP_DIR"

for label in io.github.mxkeys-vibe.hammerspoon io.github.mxkeys-vibe.keymap; do
  launchctl bootout "gui/$UID_VALUE/$label" 2>/dev/null || true
done

hidutil property --set '{"UserKeyMapping":[]}' >/dev/null

for file in \
  "$HAMMERSPOON_DIR/init.lua" \
  "$LAUNCH_DIR/io.github.mxkeys-vibe.hammerspoon.plist" \
  "$LAUNCH_DIR/io.github.mxkeys-vibe.keymap.plist"; do
  if [[ -e "$file" ]]; then
    mv "$file" "$BACKUP_DIR/"
  fi
done

print "MX Keys Vibe Console disabled."
print "Files were moved to: $BACKUP_DIR"
