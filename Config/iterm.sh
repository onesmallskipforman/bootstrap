#!/bin/bash

#===================================================================
# iTerm 2 Config
#===================================================================


# Thank you to mathiasbynens/dotfiles/osx.sh for finding most of these macos preferences commands

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit'

# iterm2 pref plist
PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# rows and columns for new windows
/usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:Rows 20' "$PLIST"
/usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:Columns 80' "$PLIST"

# import homebrew theme from termcolors for iterm2 (from mbadolato/iTerm2-Color-Schemes)
if [[ ! -f "Termcolors/Homebrew.itermcolors" ]]; then
  open "Termcolors/Homebrew.itermcolors"
fi

echo "iTerm Config Done. Note that some of these changes require a logout/restart to take effect."