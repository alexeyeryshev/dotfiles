My dotfiles based on Dotbot.

# Prerequisites
- Install Git.
- Install Brew - https://brew.sh/

# Install

1. Clone this or download to `~/dotfiles`.

```
git submodule update --init --recursive
```

2. Install. We need a `sudo` otherwise certain system level configs won't be set.
```sh
sudo ./install
```

# TODO
1. Automate Homewbrew install
2. Set fira code as default in iterm2
3. Fix Brewfile casks install