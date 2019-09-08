#!/bin/bash

#===================================================================
# Terminal Config
#===================================================================


# Thank you to mathiasbynens/dotfiles/osx.sh for finding most of these macos preferences commands

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit'

# change terminal theme to Homebrew
defaults write com.apple.terminal "Default Window Settings" -string Homebrew
defaults write com.apple.terminal "Startup Window Settings" -string Homebrew

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# disable “focus follows mouse” for Terminal.app and all X11 apps
# i.e. hover over a window and start typing in it without clicking first
defaults write com.apple.terminal FocusFollowsMouse -bool false
#defaults write org.x.X11 wm_ffm -bool true

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
# defaults write com.apple.terminal SecureKeyboardEntry -bool true

# (RUNNING FROM OUTSIDE TERMINAL ONLY)
# quickly restart and quit app while hidden so changes take effect by the first use
# otherwise user will have to open once and quit before changes take place
# osascript -e 'tell application "Terminal" to quit'
# open -a Terminal.app -gj
# osascript -e 'tell application "Terminal" to quit'

echo "Terminal Config Done. Note that some of these changes require a logout/restart to take effect."