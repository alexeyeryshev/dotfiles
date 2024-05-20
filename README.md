My dotfiles based on Dotbot.

# Prerequisites
- Install Brew by following installation instructions from https://brew.sh/

# Install
```sh
./install
```

# TODO
1. Automate OS X defaults:

```
./set-defaults.sh
```
2. Automate Homewbrew install
3. Automate Iterm2 configuration -> not sure this is needed anymore
```
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/iterm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```
4. Set fira code as default in iterm2
5. Fix Brewfile casks install