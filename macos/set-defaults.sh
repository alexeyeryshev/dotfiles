#!/bin/bash
# macOS defaults. Run as your user, never under sudo -- `defaults write`
# targets the effective user's preference domain, so root writes go to
# /var/root and never reach your account.
# https://macos-defaults.com/

# --- FileVault ---------------------------------------------------------------
# Checked, not enabled: `fdesetup enable` issues a recovery key that has to be
# captured interactively, so it cannot be done unattended. Everything below
# assumes this is on.
if ! fdesetup status 2>/dev/null | grep -q 'FileVault is On'; then
  echo ""
  echo "  ##########################################################"
  echo "  #  FileVault is OFF                                      #"
  echo "  #                                                        #"
  echo "  #  Apple silicon encrypts the volume either way, but     #"
  echo "  #  without FileVault the volume key is protected only    #"
  echo "  #  by the hardware UID -- the disk unlocks with no       #"
  echo "  #  password at all. Every control below assumes it is    #"
  echo "  #  on, so turn it on before trusting any of them.        #"
  echo "  #                                                        #"
  echo "  #  System Settings > Privacy & Security > FileVault      #"
  echo "  ##########################################################"
  echo ""
fi

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

# --- Touch ID for sudo -------------------------------------------------------
# /etc/pam.d/sudo_local survives OS updates; editing /etc/pam.d/sudo directly
# does not -- the updater overwrites it. Template ships with macOS 14+.
if [ -f /etc/pam.d/sudo_local.template ] && [ ! -f /etc/pam.d/sudo_local ]; then
  sudo cp /etc/pam.d/sudo_local.template /etc/pam.d/sudo_local
  sudo sed -i '' 's/^#auth/auth/' /etc/pam.d/sudo_local
  echo "  Touch ID for sudo enabled"
fi

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
