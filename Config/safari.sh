#!/bin/bash

#===================================================================
# Safari & WebKit Config
#===================================================================


# Thank you to mathiasbynens/dotfiles/osx.sh for finding most of these macos preferences commands

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit'

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Show Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar-v2 -bool true

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

killall "Safari"
echo "Safari Config Done. Note that some of these changes require a logout/restart to take effect."