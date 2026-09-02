#!/bin/bash
# Verify the commit-signing setup: the public key file git signs with, and
# SecretAgent's notification permission.
#
# Advisory only, always exits 0. A fresh machine legitimately has none of this
# until Secretive has been launched and its keys created, and this runs as part
# of an unattended install.

SIGNING_PUB="$HOME/.ssh/git-signing.pub"

echo "Checking commit signing..."

# --- signing key file --------------------------------------------------------
# user.signingKey points at this file rather than at a literal key. Git hands it
# to ssh-keygen, which finds the matching private key in the agent. Two Secure
# Enclave keys are otherwise indistinguishable from outside the agent: it
# exposes no metadata beyond the comment and gives no ordering guarantee.
#
# Written only on a match -- a bare `grep > file` leaves an empty file behind,
# which git reports as a confusing signing failure.
if key=$(ssh-add -L 2>/dev/null | grep -m1 git-signing); then
  printf '%s\n' "$key" > "$SIGNING_PUB"
  chmod 600 "$SIGNING_PUB"
  printf "  ok   %-42s %s\n" "signing key provisioned" \
    "$(ssh-keygen -lf "$SIGNING_PUB" 2>/dev/null | awk '{print $2}')"
elif [ -f "$SIGNING_PUB" ]; then
  printf "  ok   %-42s %s\n" "signing key file present" \
    "$(ssh-keygen -lf "$SIGNING_PUB" 2>/dev/null | awk '{print $2}')"
  echo "       No agent key named 'git-signing', so this file cannot be"
  echo "       reprovisioned automatically. The file itself is what git signs"
  echo "       with, so signing is unaffected. Renaming a key in Secretive does"
  echo "       not reliably change the comment the agent reports, so on a new"
  echo "       machine pick the signing key out of 'ssh-add -L' by fingerprint"
  echo "       and write it here yourself."
else
  echo ""
  echo "  ##########################################################"
  echo "  #  No commit signing key                                 #"
  echo "  #                                                        #"
  echo "  #  commit.gpgsign is on and user.signingKey points at    #"
  echo "  #  ~/.ssh/git-signing.pub, so 'git commit' fails until   #"
  echo "  #  that file exists. In Secretive, create a key named    #"
  echo "  #  'git-signing' with Notify, add it to GitHub as a      #"
  echo "  #  SIGNING key, then re-run this or:                     #"
  echo "  #                                                        #"
  echo "  #    ssh-add -L | grep git-signing > ~/.ssh/git-signing.pub"
  echo "  ##########################################################"
  echo ""
fi

# --- SecretAgent notifications -----------------------------------------------
# The signing key is created with "Notify" rather than "Require Authentication",
# so commits do not cost a Touch ID tap each time. That makes the notification
# the ONLY remaining signal that the key was used: with it off, anything running
# as this user can sign commits silently.
#
# Worth knowing, and worth NOT over-claiming. An earlier version of this check
# read com.apple.ncprefs and treated flag bit 0x2000 as "notifications off".
# That was wrong: SecretAgent carried 0x2000 while notifications were working
# fine, so the check warned on a healthy machine. Those flag bits are
# reverse-engineered, undocumented, and evidently not stable across macOS
# releases. The on-disk plist is also written lazily, so it can lag a toggle by
# hours -- reading it at all races with the thing it is trying to observe.
#
# So this reports only what can be established: whether SecretAgent has ever
# registered with Notification Center. Present tells you nothing about the
# on/off state, which is why the real test named here is behavioural.
notify_registered=$(python3 - <<'PY' 2>/dev/null
import plistlib, os
p = os.path.expanduser("~/Library/Preferences/com.apple.ncprefs.plist")
try:
    apps = plistlib.load(open(p, "rb")).get("apps", [])
except Exception:
    raise SystemExit
print(any("Secretive.SecretAgent" in str(a.get("bundle-id", "")) for a in apps))
PY
)

if [ "$notify_registered" = "False" ]; then
  echo ""
  echo "  ##########################################################"
  echo "  #  SecretAgent has no notification registration          #"
  echo "  #                                                        #"
  echo "  #  The signing key uses Notify, not Touch ID, so the     #"
  echo "  #  notification is the only sign it was used. Launch     #"
  echo "  #  Secretive and allow notifications when asked.         #"
  echo "  ##########################################################"
  echo ""
else
  printf "  ok   %-42s %s\n" "SecretAgent registered for notifications" "verify below"
fi

echo "       Notification state cannot be read reliably. Confirm by behaviour:"
echo "       a banner should appear on the next 'git commit'."
