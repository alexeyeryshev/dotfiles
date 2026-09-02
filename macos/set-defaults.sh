#!/bin/bash
# This script supposed to set up macOS defaults.
# But it doesn't not really work.
# I used it as a notebook to set up defaults.
# https://macos-defaults.com/

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Use AirDrop over every interface. srsly this should be a default.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Always open everything in Finder's list view. This is important.
defaults write com.apple.finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set a fast key repeat (UI slider minimums, stable across System Settings).
# Settings > Keyboard > Key Repeat Rate
defaults write NSGlobalDomain KeyRepeat -int 2
# Settings > Keyboard > Delay Until Repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable natural-scrolling
# Settings > Trackpad > Scroll & Zoom > Scroll direction: Natural Off
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool FALSE

# Dock settings
# Settings > Dock > Automatically hide and show the Dock: On
defaults write com.apple.dock autohide -bool true
# Settings > Dock > Size: 72
defaults write com.apple.dock tilesize -int 72

# Get back F1 - F12 keys
# Settings > Keyboard > F1, F2, etc. keys: Show F1, F2, etc. keys
defaults write -g com.apple.keyboard.fnState -bool true

# --- Screen lock -------------------------------------------------------------
# time to lock = min(screen saver idle, display sleep) + password delay
#
# The password delay is measured FROM the screen saver starting or the display
# sleeping -- not from when you walked away. So "Immediately" paired with a long
# display timer still leaves the machine unlocked for that entire timer.
#
# Only two of the three levers are reliably scriptable: macOS 14 rewrote the
# screen saver and no longer consults the old undocumented defaults keys, so
# display sleep is what actually drives the lock here.

# Cache credentials once so the pmset calls below prompt at most a single time.
sudo -v

# Display sleep, in minutes. Documented, supported, needs root.
# Settings > Lock Screen > Turn display off ... when inactive
sudo pmset -b displaysleep 2   # on battery
sudo pmset -c displaysleep 5   # on power adapter

# Require the login password the moment the screen goes.
# Runs as you, NOT under sudo -- it sets the current user's screen lock.
# Settings > Lock Screen > Require password after screen saver begins ...
sysadminctl -screenLock immediate -password - || \
  echo "  screen lock NOT set - run: sysadminctl -screenLock immediate -password -"

# Best effort. Undocumented key, may be ignored on macOS 14+.
# Settings > Lock Screen > Start Screen Saver when inactive
defaults -currentHost write com.apple.screensaver idleTime -int 120

# Apply changes that only need an app restart.
killall Finder Dock 2>/dev/null || true

echo ""
echo "Done. Some settings (key repeat, scroll direction, F-key state,"
echo "press-and-hold) only take effect after a logout/login or reboot."
echo ""
echo "Check by hand: System Settings > Lock Screen >"
echo "  'Start Screen Saver when inactive' should read 2 minutes."
echo "  macOS may refuse to accept this one from a script."
echo ""
echo "Then run macos/test-defaults.sh to see what actually stuck."
