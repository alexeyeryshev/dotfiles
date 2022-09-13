My dotfiles based on Dotbot.

# Prerequisites
- Install Brew by following installation instructions from https://brew.sh/

# Not automated configuration
1. Iterm2.
Kudos to those notes on iterm2 configuraiton:
- http://stratus3d.com/blog/2015/02/28/sync-iterm2-profile-with-dotfiles-repository/
- https://apple.stackexchange.com/a/111559


# TODO
1. Automate OS X defaults:

```
defaults write -g ApplePressAndHoldEnabled -bool false
```
2. Automate Homewbrew install
3. Automate Iterm2 configuration:
```
# Specify the preferences directory
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "~/dotfiles/iterm2"
# Tell iTerm2 to use the custom preferences in the directory
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true
```