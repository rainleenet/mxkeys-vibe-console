#!/bin/zsh
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="$HOME/.mxkeys-vibe-console-backup/$(date +%Y%m%d-%H%M%S)"
HAMMERSPOON_DIR="$HOME/.hammerspoon"
LAUNCH_DIR="$HOME/Library/LaunchAgents"
BIN_DIR="$HOME/.local/bin"
GUARD="$BIN_DIR/mxkeys-vibe-hammerspoon-ensure-running"
UID_VALUE="$(id -u)"

if [[ ! -d /Applications/Hammerspoon.app ]]; then
  print "Hammerspoon is not installed. Install it first:"
  print "  brew install --cask hammerspoon"
  exit 1
fi

mkdir -p "$BACKUP_DIR" "$HAMMERSPOON_DIR" "$LAUNCH_DIR" "$BIN_DIR"

for file in \
  "$HAMMERSPOON_DIR/init.lua" \
  "$GUARD" \
  "$LAUNCH_DIR/io.github.mxkeys-vibe.hammerspoon.plist" \
  "$LAUNCH_DIR/io.github.mxkeys-vibe.keymap.plist"; do
  if [[ -e "$file" ]]; then
    cp -p "$file" "$BACKUP_DIR/"
  fi
done

cp "$PACKAGE_DIR/config/init.lua" "$HAMMERSPOON_DIR/init.lua"
cp "$PACKAGE_DIR/bin/hammerspoon-ensure-running" "$GUARD"
chmod +x "$GUARD"
cp "$PACKAGE_DIR/launchagents/io.github.mxkeys-vibe.hammerspoon.plist" "$LAUNCH_DIR/"
cp "$PACKAGE_DIR/launchagents/io.github.mxkeys-vibe.keymap.plist" "$LAUNCH_DIR/"

plutil -lint "$LAUNCH_DIR/io.github.mxkeys-vibe.hammerspoon.plist"
plutil -lint "$LAUNCH_DIR/io.github.mxkeys-vibe.keymap.plist"

launchctl bootout "gui/$UID_VALUE" "$LAUNCH_DIR/io.github.mxkeys-vibe.hammerspoon.plist" 2>/dev/null || true
launchctl bootout "gui/$UID_VALUE" "$LAUNCH_DIR/io.github.mxkeys-vibe.keymap.plist" 2>/dev/null || true
launchctl bootstrap "gui/$UID_VALUE" "$LAUNCH_DIR/io.github.mxkeys-vibe.hammerspoon.plist"
launchctl bootstrap "gui/$UID_VALUE" "$LAUNCH_DIR/io.github.mxkeys-vibe.keymap.plist"

open -gja /Applications/Hammerspoon.app

print ""
print "Installed. Backup: $BACKUP_DIR"
print "Next steps:"
print "1. Grant Hammerspoon Accessibility permission."
print "2. Configure ChatGPT Dictation: Control+Option+Shift+D."
print "3. Configure macOS Dictation: Control+Option+Command+D."
print "4. Run ./verify.sh and test the physical keys."
