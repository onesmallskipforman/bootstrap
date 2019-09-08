#!/bin/bash

#===================================================================
# General UI/UX
#===================================================================


# Thank you to mathiasbynens/dotfiles/osx.sh for finding most of these macos preferences commands

# Close any open System Preferences panes
osascript -e 'tell application "System Preferences" to quit'

# Turn Dark mode on (unfortunately have to disable system identity protection to use defaults)
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "SkippersMBP"
sudo scutil --set HostName "SkippersMBP"
sudo scutil --set LocalHostName "SkippersMBP"
sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

# allows apps downloaded from anywhere
sudo spctl --master-disable

# Always show scrollbars (Possible values: `WhenScrolling`, `Automatic` and `Always`)
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Set a custom wallpaper image
# osascript -e 'tell application "Finder" to set desktop picture to POSIX file "Wallpaper/neon.jpg"'

echo "OSX UI/UX Config Done. Note that some of these changes require a logout/restart to take effect."



