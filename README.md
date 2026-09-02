My dotfiles, based on [Dotbot](https://github.com/anishathalye/dotbot).

## Bootstrap a new Mac

### 1. Prerequisites

```sh
xcode-select --install
```

Plus [Homebrew](https://brew.sh/).

### 2. Clone without leaving a key behind

A fresh Mac has no SSH key. Rather than create a permanent one before the
machine is set up, use a throwaway **read-only deploy key** scoped to this repo
alone. Run it all in one terminal session — `$KEYDIR` does not survive a new
window.

```sh
KEYDIR=$(mktemp -d)
ssh-keygen -t ed25519 -f "$KEYDIR/bootstrap" -N "" -C "throwaway $(date +%F)"
pbcopy < "$KEYDIR/bootstrap.pub"
```

Paste it at `github.com/alexeyeryshev/dotfiles/settings/keys` → **Add deploy
key**, leaving **Allow write access** unchecked.

```sh
# -F /dev/null ignores ~/.ssh/config, IdentitiesOnly stops ssh offering anything else
GIT_SSH_COMMAND="ssh -F /dev/null -i $KEYDIR/bootstrap -o IdentitiesOnly=yes" \
  git clone git@github.com:alexeyeryshev/dotfiles.git ~/dotfiles

cd ~/dotfiles && git submodule update --init --recursive
```

Then destroy both ends — `rm -rf "$KEYDIR" && unset KEYDIR`, and delete the
deploy key on that same GitHub page.

Verify the host key instead of typing `yes` blind:

```sh
curl -s https://api.github.com/meta | python3 -c 'import sys,json;print(json.load(sys.stdin)["ssh_key_fingerprints"])'
```

Or skip the key entirely: `gh auth login` then `gh repo clone
alexeyeryshev/dotfiles ~/dotfiles` leaves nothing on disk to clean up.

### 3. Install

```sh
./install
```

Prompts for your password twice: `pmset` needs root for the display sleep
settings, `sysadminctl` for the screen lock.

### 4. Set up the real key

The bootstrap key was read-only and is gone. In Secretive (installed by the
Brewfile): allow notifications, create an **ECDSA-256** key with
**authentication required before each use**, and add its public key to GitHub
twice — once as an Authentication Key, once as a Signing Key.

```sh
ssh -T git@github.com   # Touch ID once
ssh -T git@github.com   # no prompt — multiplexing is working
```

### 5. Verify

```sh
macos/test-defaults.sh
```

Anything reported failed or unset has to be set by hand in System Settings —
notably **Start Screen Saver when inactive**, which macOS may refuse to accept
from a script.
