#!/bin/bash

# firefox restore and backup function

SUPPORT="$HOME/Library/Application Support/Firefox"
BACKUP="Backups/Firefox"
CLI="/Applications/Firefox.app/Contents/MacOS/firefox"

if [[ $1 == "--backup" ]]; then
  # copy profile over
  PROFILE="$SUPPORT/Profiles/"*.default-release
  mkdir -p "$BACKUP/" &&
  cp -r "$SUPPORT/Profiles/"*.default-release "$BACKUP/"
elif [[ $1 == "--restore" ]]; then
  # remove old profile folders
  rm -rf "$SUPPORT"

  # create profile
  "$CLI" -CreateProfile default-release
  # PROFILE="$SUPPORT/Profiles/"*.default-release

  # copy backup to profile
  cp -r "$BACKUP/" "$SUPPORT/Profiles/"*.default-release

  echo "Setting Up Firefox"

  # run profile headless, trigger default browser dialoge and wait 60 seconds
  "$CLI" -headless &>/dev/null & #-setDefaultBrowser
  sleep 60
  osascript -e 'quit app "Firefox"'
else
  echo "Invalid Config Option"
fi

echo "Firefox profile restore done. Note that some of these changes require a logout/restart to take effect."