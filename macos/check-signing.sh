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
  echo "       no agent key named 'git-signing', so this file cannot be"
  echo "       reprovisioned. Rename the key in Secretive (Edit -> Save)."
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
# The ncprefs flag bits are reverse-engineered, not documented. 0x2000 tracking
# "notifications off" matches observation on macOS 26 but is a heuristic, so
# this warns and points at System Settings rather than asserting.
notify_state=$(python3 - <<'PY' 2>/dev/null
import plistlib, os, sys
p = os.path.expanduser("~/Library/Preferences/com.apple.ncprefs.plist")
try:
    apps = plistlib.load(open(p, "rb")).get("apps", [])
except Exception:
    sys.exit()
hit = [a for a in apps if "Secretive.SecretAgent" in str(a.get("bundle-id", ""))]
if not hit:
    print("missing")
else:
    print("off" if hit[0].get("flags", 0) & 0x2000 else "on")
PY
)

case "$notify_state" in
  on)
    printf "  ok   %-42s %s\n" "SecretAgent notifications" "enabled" ;;
  off|missing)
    [ "$notify_state" = missing ] \
      && detail="SecretAgent has never been granted notification access" \
      || detail="SecretAgent notifications appear to be turned off"
    echo ""
    echo "  ##########################################################"
    echo "  #  Commit signing is silent                              #"
    echo "  #                                                        #"
    echo "  #  The signing key uses Notify, not Touch ID, so the     #"
    echo "  #  notification is the only sign it was used. Without    #"
    echo "  #  it, any process running as you can sign commits as    #"
    echo "  #  you, with no prompt and no trace.                     #"
    echo "  #                                                        #"
    echo "  #  System Settings -> Notifications -> SecretAgent       #"
    echo "  ##########################################################"
    echo "  ($detail. The flag read is a heuristic -- confirm in System Settings.)"
    echo ""
    ;;
  *)
    echo "  --   SecretAgent notifications              could not be determined" ;;
esac
