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
# to ssh-keygen, which finds the matching private key in the agent.
#
# Identifying WHICH agent key is the signing one is the awkward part. The SSH
# comment cannot do it: Secretive reports the same comment for every key here,
# and renaming a secret does not change what the agent reports, so a naming
# convention is not something this can rely on.
#
# Match against the list that is already authoritative instead -- the SIGNING
# keys registered on the GitHub account. That endpoint is public and needs no
# token, and an agent key appearing in it is the signing key by definition.
# Needs the key to be on GitHub already, which the notes below ask for anyway.
#
# Never writes on a failed match: a wrong or empty file makes git fail in a way
# that does not name the cause.
github_user=$(git config --get github.user 2>/dev/null)

matched=$(python3 - "$github_user" <<'PY' 2>/dev/null
import base64, json, subprocess, sys, urllib.request

user = sys.argv[1] if len(sys.argv) > 1 else ""
if not user:
    raise SystemExit

try:
    out = subprocess.run(["ssh-add", "-L"], capture_output=True, text=True, timeout=5).stdout
except Exception:
    raise SystemExit
agent = [l for l in out.strip().split("\n") if l.strip()]
if not agent:
    raise SystemExit

try:
    with urllib.request.urlopen(
        f"https://api.github.com/users/{user}/ssh_signing_keys", timeout=5
    ) as r:
        remote = json.load(r)
except Exception:
    raise SystemExit
if not isinstance(remote, list):
    raise SystemExit

blobs = set()
for k in remote:
    try:
        blobs.add(base64.b64decode(k["key"].split()[1]))
    except Exception:
        pass

for line in agent:
    try:
        if base64.b64decode(line.split()[1]) in blobs:
            print(line)
            break
    except Exception:
        pass
PY
)

if [ -n "$matched" ]; then
  printf '%s\n' "$matched" > "$SIGNING_PUB"
  chmod 600 "$SIGNING_PUB"
  printf "  ok   %-42s %s\n" "signing key matched against GitHub" \
    "$(ssh-keygen -lf "$SIGNING_PUB" 2>/dev/null | awk '{print $2}')"
elif [ -f "$SIGNING_PUB" ]; then
  printf "  ok   %-42s %s\n" "signing key file present" \
    "$(ssh-keygen -lf "$SIGNING_PUB" 2>/dev/null | awk '{print $2}')"
  echo "       Could not confirm it against GitHub's signing key list (no"
  echo "       network, no github.user set, or the key is not registered"
  echo "       there). Signing still works from this file."
else
  echo ""
  echo "  ##########################################################"
  echo "  #  No commit signing key                                 #"
  echo "  #                                                        #"
  echo "  #  commit.gpgsign is on and user.signingKey points at    #"
  echo "  #  ~/.ssh/git-signing.pub, so 'git commit' fails until   #"
  echo "  #  that file exists. Create the signing key in           #"
  echo "  #  Secretive, add it to GitHub as a SIGNING key, then    #"
  echo "  #  re-run this script -- it will find and write it.      #"
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
