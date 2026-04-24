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
if [ "$fail" -eq 0 ]; then
  echo "All checks passed."
else
  echo "Some checks failed. Re-run macos/set-defaults.sh and log out/in."
fi

exit "$fail"
