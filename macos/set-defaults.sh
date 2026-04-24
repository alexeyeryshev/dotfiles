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
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

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

# Apply changes that only need an app restart.
killall Finder Dock 2>/dev/null || true

echo ""
echo "Done. Some settings (key repeat, scroll direction, F-key state,"
echo "press-and-hold) only take effect after a logout/login or reboot."
