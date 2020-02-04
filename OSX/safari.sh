#!/bin/bash

#===================================================================
# Safari & WebKit Config
#===================================================================

# Close any open System Preferences panes
osascript -e 'quit app "System Preferences"'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Show Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

killall "Safari" &> /dev/null
echo "Safari Config Done. Note that some of these changes require a logout/restart to take effect."
