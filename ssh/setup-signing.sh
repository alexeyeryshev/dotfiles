#!/bin/bash
# Seed ~/.ssh/allowed_signers from the key currently held in the SSH agent, so
# `git log --show-signature` can verify your own commits locally.
#
# The signing key itself is NOT written to .gitconfig: the Secure Enclave key
# has no file on disk and its identity is machine-specific, so .gitconfig sets
# gpg.ssh.defaultKeyCommand instead and git resolves it from the agent at
# signing time. Nothing here is machine-specific, so nothing dirties the repo.
#
# Idempotent. Re-run it after creating the key in Secretive.
set -u

sock="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
[ -S "$sock" ] && export SSH_AUTH_SOCK="$sock"

key="$(ssh-add -L 2>/dev/null | grep -E '^(ssh-|ecdsa-|sk-)' | head -1)"

if [ -z "$key" ]; then
  cat <<'BANNER'

  ############################################################
  #  Commit signing is ON, but the agent holds no key yet.    #
  #                                                           #
  #  Every `git commit` will fail until you:                  #
  #    1. open Secretive and allow notifications              #
  #    2. create an ECDSA-256 key, authentication required    #
  #       before each use                                     #
  #    3. re-run:  ./ssh/setup-signing.sh                     #
  #                                                           #
  #  Then add that public key to GitHub TWICE -- once as an   #
  #  Authentication Key, once as a Signing Key.               #
  ############################################################

BANNER
  exit 0
fi

email="$(git config --get user.email)"
if [ -z "$email" ]; then
  echo "  user.email is not set - cannot build an allowed_signers entry."
  echo "  Set it, then re-run: git config --global user.email you@example.com"
  exit 1
fi

signers="$HOME/.ssh/allowed_signers"

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
touch "$signers" && chmod 600 "$signers"

if grep -qF "$key" "$signers"; then
  echo "  signing key already present in $signers"
else
  echo "$email $key" >> "$signers"
  echo "  added signing key to $signers"
fi

echo "  signing ready -- commits will be signed with the Secure Enclave key"
