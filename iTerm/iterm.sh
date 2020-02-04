#!/bin/zsh

#===================================================================
# iTerm 2 Config
#===================================================================

cd "$(dirname $0)"

BACKUP="$PWD"

# Close any open System Preferences panes
osascript -e 'quit app "System Preferences"'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# iterm2 pref plist
# PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

# rows and columns for new windows
# /usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:Rows 20' "$PLIST"
# /usr/libexec/PlistBuddy -c 'Set :"New Bookmarks":0:Columns 80' "$PLIST"

start_if_needed() {
  local grep_name="[${1:0:1}]${1:1}"

  if [[ -z $(ps aux | grep -e "${grep_name}") ]]; then
    if [ -e ~/Applications/$1.app ]; then
      open ~/Applications/$1.app
    else
      if [ -e /Applications/$1.app ]; then
        open /Applications/$1.app
      fi
    fi
  fi

  true
}

# import homebrew theme from termcolors for iterm2 (from mbadolato/iTerm2-Color-Schemes)
# start_if_needed iTerm
open "$BACKUP/Homebrew.itermcolors" # -gj

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

echo "iTerm Config Done. Note that some of these changes require a logout/restart to take effect."
