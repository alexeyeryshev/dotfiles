#!/bin/bash
# Verify the values written by set-defaults.sh.
# Exits 0 if everything matches, 1 if any check fails.

fail=0

check() {
  local label="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    printf "  ok   %-45s = %s\n" "$label" "$actual"
  else
    printf "  FAIL %-45s expected=%s actual=%s\n" "$label" "$expected" "$actual"
    fail=1
  fi
}

read_default() {
  defaults read "$@" 2>/dev/null || echo "<unset>"
}

echo "Checking macOS defaults..."

check "global ApplePressAndHoldEnabled"      "0"    "$(read_default -g ApplePressAndHoldEnabled)"
check "global KeyRepeat"                     "2"    "$(read_default -g KeyRepeat)"
check "global InitialKeyRepeat"              "15"   "$(read_default -g InitialKeyRepeat)"
check "global swipescrolldirection"          "0"    "$(read_default -g com.apple.swipescrolldirection)"
check "global keyboard.fnState"              "1"    "$(read_default -g com.apple.keyboard.fnState)"
check "NetworkBrowser BrowseAllInterfaces"   "1"    "$(read_default com.apple.NetworkBrowser BrowseAllInterfaces)"
check "Finder FXPreferredViewStyle"          "Nlsv" "$(read_default com.apple.finder FXPreferredViewStyle)"
check "Dock autohide"                        "1"    "$(read_default com.apple.dock autohide)"
check "Dock tilesize"                        "72"   "$(read_default com.apple.dock tilesize)"

# ~/Library should not be hidden (chflags nohidden)
if ls -lO ~ 2>/dev/null | awk '$NF=="Library"{print $5}' | grep -qw hidden; then
  printf "  FAIL %-45s expected=visible actual=hidden\n" "~/Library visibility"
  fail=1
else
  printf "  ok   %-45s = visible\n" "~/Library visibility"
fi

echo ""
echo "Checking FileVault..."
if fdesetup status 2>/dev/null | grep -q 'FileVault is On'; then
  printf "  ok   %-45s = on\n" "FileVault"
else
  printf "  FAIL %-45s expected=on actual=%s\n" "FileVault" \
    "$(fdesetup status 2>/dev/null | head -1)"
  fail=1
fi

echo ""
echo "Checking screen lock..."

batt_ds=$(pmset -g custom | sed -n '/^Battery Power/,/^AC Power/p' | awk '/displaysleep/{print $2}')
ac_ds=$(pmset -g custom | sed -n '/^AC Power/,$p' | awk '/displaysleep/{print $2}')

check "displaysleep on battery (min)"        "2"    "$batt_ds"
check "displaysleep on AC (min)"             "5"    "$ac_ds"

# Informational: these have no stable machine-readable value to assert against.
printf "  info %-45s = %s\n" "screen lock delay" \
  "$(sysadminctl -screenLock status 2>&1 | tail -1)"
printf "  info %-45s = %s\n" "screensaver idleTime (want 120)" \
  "$(defaults -currentHost read com.apple.screensaver idleTime 2>/dev/null || echo '<unset>')"

if grep -qE '^auth[[:space:]]+sufficient[[:space:]]+pam_tid.so' /etc/pam.d/sudo_local 2>/dev/null; then
  printf "  ok   %-45s = enabled\n" "Touch ID for sudo"
else
  printf "  FAIL %-45s expected=enabled actual=not configured\n" "Touch ID for sudo"
  fail=1
fi

echo ""
if [ "$fail" -eq 0 ]; then
  echo "All checks passed."
else
  echo "Some checks failed. Re-run macos/set-defaults.sh and log out/in."
fi

exit "$fail"
