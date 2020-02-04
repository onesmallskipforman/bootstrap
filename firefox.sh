#!/bin/zsh

#===============================================================================
# FIREFOX USER SUPPORT INSTALL
#===============================================================================

# ensure app is not running
killall firefox &> /dev/null

# Folders
BACKUP=~/"Dropbox/Backup/Firefox"
CONFIG="$HOME/Library/Application Support/Firefox"
CMD="/Applications/Firefox.app/Contents/MacOS/firefox"

# make support and profile folders
rm -rf "$CONFIG"
mkdir -p "$CONFIG"
"$CMD" -CreateProfile default-release

# grab profile name, wipe, and make symlink
PROFILE=$(realpath "$CONFIG/Profiles"/*.default-release)
rm -rf "$PROFILE"
git -C "$BACKUP" clean -fdX
ln -sf "$BACKUP" "$PROFILE"

# open and close the browser headlessly, ensuring first user open isnt buggy
killall firefox &> /dev/null # insurance
"$CMD" -P default-release -headless &>/dev/null & #-setDefaultBrowser

# wait for multiple running processes
until [ $(pgrep -f Firefox | wc -l) -gt 2 ]
do
  sleep 0.5
done

# close and wait for close
osascript -e 'quit app "Firefox"'
open -g -W /Applications/Firefox.app

# git -C "$BACKUP" clean -fdx               \
#   -e "$BACKUP/prefs.js"                   \
#   -e "$BACKUP/compatibility.ini"          \
#   -e "$BACKUP/extensions"                 \
#   -e "$BACKUP/broadcast-listeners.json"   \
#   -e "$BACKUP/containers.json"            \
#   -e "$BACKUP/extension-preferences.json" \
#   -e "$BACKUP/extension-settings.json"    \
#   -e "$BACKUP/handlers.json"              \
#   -e "$BACKUP/logins.json"                \
#   -e "$BACKUP/signedInUser.json"          \
#   -e "$BACKUP/times.json"                 \
#   -e "$BACKUP/addons.json"                \
#   -e "$BACKUP/extensions.json"            \
#   -e "$BACKUP/sessionCheckpoints.json"    \
#   -e "$BACKUP/xulstore.json"
#   # -e "$BACKUP"/*.json
