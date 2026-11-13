#!/bin/zsh
set -u

UID_VALUE="$(id -u)"
HS_CLI="/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs"
failures=0

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    print "OK   $label"
  else
    print "FAIL $label"
    failures=$((failures + 1))
  fi
}

check "Hammerspoon installed" test -d /Applications/Hammerspoon.app
check "Hammerspoon LaunchAgent" launchctl print "gui/$UID_VALUE/io.github.mxkeys-vibe.hammerspoon"
check "Keymap LaunchAgent" launchctl print "gui/$UID_VALUE/io.github.mxkeys-vibe.keymap"
check "Hammerspoon config" test -f "$HOME/.hammerspoon/init.lua"

if [[ -x "$HS_CLI" ]]; then
  ACCESSIBILITY="$($HS_CLI -c 'print(hs.accessibilityState())' 2>/dev/null | tail -1)"
  [[ "$ACCESSIBILITY" == "true" ]] && print "OK   Accessibility permission" || { print "FAIL Accessibility permission"; failures=$((failures + 1)); }

  HOTKEY_COUNT="$($HS_CLI -c 'local n=0; for _,h in ipairs(hs.hotkey.getHotkeys()) do if h.enabled then n=n+1 end end; print(n)' 2>/dev/null | tail -1)"
  if [[ "$HOTKEY_COUNT" == <-> ]] && (( HOTKEY_COUNT >= 16 )); then
    print "OK   Enabled hotkeys: $HOTKEY_COUNT"
  else
    print "FAIL Enabled hotkeys: ${HOTKEY_COUNT:-unknown}"
    failures=$((failures + 1))
  fi
fi

MAPPING_COUNT="$(hidutil property --get UserKeyMapping 2>/dev/null | grep -c HIDKeyboardModifierMappingSrc | tr -d ' ')"
if (( MAPPING_COUNT >= 5 )); then
  print "OK   HID mappings detected"
else
  print "FAIL HID mappings detected: $MAPPING_COUNT"
  failures=$((failures + 1))
fi

print ""
if (( failures == 0 )); then
  print "System checks passed. Complete the physical-key checklist in README.md."
  exit 0
fi

print "$failures check(s) failed. See README.md."
exit 1
